# Load ~/.extra, ~/.bash_prompt, ~/.exports, ~/.aliases and ~/.functions
# ~/.extra can be used for settings you don’t want to commit
for file in ~/.{bash_prompt,exports,aliases,functions,path,k8s}; do
	[ -r "$file" ] && source "$file"
done
unset file



# init z   https://github.com/rupa/z
. ~/Projects/dotfiles/code/z/z.sh

# init rvm
#source ~/.rvm/scripts/rvm


# Case-insensitive globbing (used in pathname expansion)
#shopt -s nocaseglob

# Prefer US English and use UTF-8
#export LC_ALL="en_US.UTF-8"
#export LANG="en_US"

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh


# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults


# Initialize rbenv
# if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Add oh-my-git
source ~/Projects/Other/oh-my-git/prompt.sh

# The next line enables shell command completion for gcloud.
if [ -f '/usr/local/bin/google-cloud-sdk/completion.bash.inc' ]; then source '/usr/local/bin/google-cloud-sdk/completion.bash.inc'; fi

# Not currently working: https://github.com/kubernetes/minikube/issues/844
# source $(brew --prefix)/etc/bash_completion
source <(kubectl completion bash)

# Brew rbenv
eval "$(rbenv init -)"
