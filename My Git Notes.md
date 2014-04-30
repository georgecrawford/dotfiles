### Clean to remove unversioned files
* `g clean` Remove files not under version control
	* `-d` Remove directories as well
	* `-n` Dry-run
* **Typical:** `g clean -dn` then `g clean -d` **if it looks OK**


### Move unpushed commits to another branch 
* There are unpushed commits to v18 which should have been done on v17
* `g co v18` (wrong branch)
* `gl` - make a note of the commit hashes to move
* `g co v17` (correct branch)
* `g cherry-pick de59c56` (for each commit to move)
* `gl` check v17 history looks good
* `g co v18`
* `git reset --hard HEAD~N` go back **N** commits in history (2 for 2 cherry-picks!)
* `gl` check v18 history looks good

### Rebase to squash unpushed commits together
* `git rebase --interactive [hash]` where `[hash]` is a historical commit in the same branch.
* Opens a text file with the list of commits which will be rebased. You can reorder them, and add keywords before lines: 

```
# Commands:
#  p, pick = use commit
#  r, reword = use commit, but edit the commit message
#  e, edit = use commit, but stop for amending
#  s, squash = use commit, but meld into previous commit
#  f, fixup = like "squash", but discard this commit's log message
#  x, exec = run command (the rest of the line) using shell
#
# These lines can be re-ordered; they are executed from top to bottom.
```

###Stashing changes
* `g stash save "my message"`
* `g stash pop` or `g stash pop stash@{0}` - might cause conflicts
* `g stash branch NEWBRANCHNAME stash@{0}` - won't cause conflicts, can merge later
* `g stash list`
* `g stash show` or `g stash show stash@{0}`
* `g stash drop` or `g stash drop stash@{0}`

###Prod Jenkins to build a branch
* `g ci -m "Prod Jenkins" --allow-empty; push;`

###Find all the branches/tags containing a commit
* `g branch --contains [hash]` and `g tag --contains [hash]`

###Find which commit introduced a bug
```
$ git bisect start
$ git bisect good fd0a623
$ git bisect bad 256d850
```
* Git will then checkout a commit halfway between the good and bad. 
* Tell Git whether it's good or bad:

```
$ git bisect bad
Bisecting: 6 revisions left to test after this (roughly 3 steps)
```
...until you get the answer:

```
$ git bisect good
08b9bd41723a0a23687c59033c15d66c1840b4f3 is the first bad commit
```

### Undoing stuff
* Last unpushed commit was bad, revert to before the commit: `git reset --soft 'HEAD^'`