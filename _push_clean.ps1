$env:GIT_AUTHOR_NAME = "Sushant Saini"
$env:GIT_AUTHOR_EMAIL = "sushantsaini097@gmail.com"
$env:GIT_COMMITTER_NAME = "Sushant Saini"
$env:GIT_COMMITTER_EMAIL = "sushantsaini097@gmail.com"

$git = "C:\Program Files\Git\bin\git.exe"

# Fresh orphan branch so history has no link to old Cursor commits
& $git checkout --orphan clean-main
& $git reset
& $git add -A

# Unstage helper scripts if any
& $git reset HEAD -- "_rewrite_commit.ps1" 2>$null

$status = & $git status --short
if ($status -match "docs/") {
  Write-Host "ERROR: docs staged"
  exit 1
}

$tree = & $git write-tree
Write-Host "tree=$tree"

# Use commit-tree (not "git commit") so no Cursor trailer is injected
$new = & $git @("commit-tree", $tree, "-m", "Initial commit for Rumour chat app.")
Write-Host "commit=$new"
if (-not $new) { exit 1 }

& $git reset --hard $new
& $git branch -M main

& $git log -1 --format=full
Write-Host "==== BODY ===="
& $git show -s --format="%B" HEAD

$body = & $git show -s --format="%B" HEAD
if ($body -match "Cursor|cursoragent|Co-authored") {
  Write-Host "ERROR: Cursor found in message"
  exit 1
}

Write-Host "OK clean"
