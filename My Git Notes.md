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
* `g reset --hard HEAD~N` go back **N** commits in history (2 for 2 cherry-picks!)
* `gl` check v18 history looks good

### Rebase to squash unpushed commits together
* `g rebase --interactive [hash]` where `[hash]` is a historical commit in the same branch.
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
* `g stash save "my message"` or `g stash save -p "my message"` to save select a patch interactively
* `g stash pop` or `g stash pop stash@{0}` - might cause conflicts
* `g stash branch NEWBRANCHNAME stash@{0}` - won't cause conflicts, can merge later
* `g stash list`
* `g stash show` or `g stash show stash@{0}` or `g stash show -p stash@{0}` to show the patch
* `g stash drop` or `g stash drop stash@{0}`

###Prod Jenkins to build a branch
* `g ci -m "prod Jenkins" --allow-empty; push;`

###Find all the branches/tags containing a commit
* `g branch --contains [hash]` and `g tag --contains [hash]`
* If the branch has already been merged, then find the merge commit: `g log [hash]..[version branch] --ancestry-path --merges --reverse -n1`

###Find the commits in one branch but not another
* `g cherry -v [feature-branch] [version-branch]`

###Delete merged-in branches
* To delete all branches that are already merged into the currently checked out branch: `g branch --merged | grep -v "\*" | xargs -n 1 git branch -d`

###Find which commit introduced a bug
```
$ g bisect start
$ g bisect good fd0a623
$ g bisect bad 256d850
```
* Git will then checkout a commit halfway between the good and bad. 
* Tell Git whether it's good or bad:

```
$ g bisect bad
Bisecting: 6 revisions left to test after this (roughly 3 steps)
```
...until you get the answer:

```
$ g bisect good
08b9bd41723a0a23687c59033c15d66c1840b4f3 is the first bad commit
```

### Undoing stuff
* Last unpushed commit was bad, revert to before the commit: `g reset --soft 'HEAD^'`

### Deleting stuff
* Delete branch on remote: `g push origin --delete [branch]`

### Default branch
* Select which branch is checked out by default (i.e. when you clone). By default, origin/HEAD will point at that. `g remote set-head origin [branch]`