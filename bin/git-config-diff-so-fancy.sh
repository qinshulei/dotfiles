#!/bin/bash
# config a repo use git diff so fancy
git config core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config color.ui true

git config color.diff-highlight.oldNormal    "red bold"
git config color.diff-highlight.oldHighlight "red bold 52"
git config color.diff-highlight.newNormal    "green bold"
git config color.diff-highlight.newHighlight "green bold 22"

git config color.diff.meta       "yellow"
git config color.diff.frag       "magenta bold"
git config color.diff.commit     "yellow bold"
git config color.diff.old        "red bold"
git config color.diff.new        "green bold"
git config color.diff.whitespace "red reverse"
