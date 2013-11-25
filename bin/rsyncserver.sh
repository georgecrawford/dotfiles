#!/bin/bash

# user@hostname or alias from .ssh/config
# you must use ssh key for authentication
SSHLOGIN=shell.ak.ft.com

#destination
LOCAL_DIR=`pwd`
SHELL_DIR=~/Shell/

if ! $(echo "$LOCAL_DIR" | grep "$SHELL_DIR" > /dev/null); then
	echo "Must be run from a subdirectory of $SHELL_DIR, not $LOCAL_DIR"
	exit 1
fi

# if ! $(echo "$LOCAL_DIR" | grep "/Users/george/Shell/econhtml5" > /dev/null); then
#     echo "Directory is $LOCAL_DIR - are you sure you want to do this?"
#     exit 1
# fi

LOCAL_PATH="${LOCAL_DIR/$SHELL_DIR/}"
LOCAL_PATH_HASH=$(md5 -qs $LOCAL_PATH)

# quote here, variable will be evaluated on remote
REMOTE_DIR='$HOME/'$LOCAL_PATH

PORT=$(($RANDOM%63000+2001))

MODULE=sync${UID}module$RANDOM

# dir/*** excludes the directory and all subdirs, so git/bzr repos are separate for local and remote
# no quotes around * are necessary
RSYNCFLAGS="--port=$PORT -razP --keep-dirlinks --inplace --update --exclude-from $HOME/ftlabs/rsync-exclude"

CONF="""
lock file = \$HOME/fswatch-rsyncd.$LOCAL_PATH_HASH.lock
log file = \$HOME/fswatch-rsyncd.$LOCAL_PATH_HASH.log
pid file = \$HOME/fswatch-rsyncd.$LOCAL_PATH_HASH.pid

[$MODULE]
	path = $REMOTE_DIR
	comment = Sandboxes
	read only = no
	list = yes
	use chroot = no
	munge symlinks = no
	ignore nonreadable = yes
	uid = 11826
	secrets file = \$HOME/fswatch-rsyncd.$LOCAL_PATH_HASH.secret
"""

# uploads config, echo replaces $HOME on remote
ssh "$SSHLOGIN" 'echo "'"$CONF"'" > fswatch-rsyncd."'"$LOCAL_PATH_HASH"'".conf'

# Run rsync daemon (in foreground of background ssh) on remote and tunnel it to localhost
{
trap 'echo Killing SSH $(jobs -p); kill $(jobs -p)' EXIT
while true; do
ssh "$SSHLOGIN" -L $PORT:localhost:$PORT '
	test -f fswatch-rsyncd.'$LOCAL_PATH_HASH'.pid && { kill `cat fswatch-rsyncd.'$LOCAL_PATH_HASH'.pid`; rm fswatch-rsyncd.'$LOCAL_PATH_HASH'.pid; }
	rsync -v --daemon --address=127.0.0.1 --port='$PORT' --no-detach --config=fswatch-rsyncd.'$LOCAL_PATH_HASH'.conf
' &
echo "connecting..."
wait
echo "ARRRGH, SERVER DIED"; sleep 1;
done
} &

# Ensure server is killed when script exits
trap 'echo Killing server script $(jobs -p); kill $(jobs -p)' EXIT

# Initial sync from server to client
while ! nc -z localhost $PORT; do
	echo "Waiting for rsync daemon to start on port localhost:$PORT"
	sleep 1;
done

sleep 1;
#test -d "$LOCAL_DIR" || mkdir "$LOCAL_DIR"

echo "Downloading"
# rsync -P $RSYNCFLAGS "rsync://rsyncclient@localhost/$MODULE/" "${LOCAL_DIR%/}"/ || {
# now that initial sync is done, -P is too verbose
rsync --partial $RSYNCFLAGS "rsync://rsyncclient@localhost/$MODULE/" "${LOCAL_DIR%/}"/ || {
	echo "Failed to sync data down";
	exit 1;
}

echo "Uploading"
rsync $RSYNCFLAGS "${LOCAL_DIR%/}"/ "rsync://rsyncclient@localhost/$MODULE/" || {
	echo "Failed to sync data up";
	exit 1;
}

fsevent.rb "$LOCAL_DIR" 'rsync '"$RSYNCFLAGS"' --delete-after %s --filter="+ */" '"$LOCAL_DIR"'/ rsync://rsyncclient@localhost/'"$MODULE"'/ && echo " ... uploaded"' '--filter="+ %s***"'

# Working fswatch example
# `dirname "$0"`/fswatch "$LOCAL_DIR" 'printf "Changes in %s..." "$FSWATCH_CHANGED_RELPATH"; echo -v '"$RSYNCFLAGS"' --delete-after --filter="+ ${FSWATCH_CHANGED_RELPATH}***" "--filter=+ */" "$FSWATCH_ROOT_PATH" rsync://rsyncclient@localhost/'"$MODULE"'/; rsync -v '"$RSYNCFLAGS"' --delete-after --filter="+ ${FSWATCH_CHANGED_RELPATH}***" "--filter=+ */" "$FSWATCH_ROOT_PATH" rsync://rsyncclient@localhost/'"$MODULE"'/ && echo "uploaded"'
