# TODO: this is still missing some of the branches
git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D

# Deleted:
# Deleted branch dev (was 0fb956f).
# Deleted branch doc/wikis (was e95d34d).
# Deleted branch feat/apps (was fe0b1a4).
# Deleted branch feat/cli (was f1bed8b).
# Deleted branch feat/icon-extraction (was f44ea10).
# Deleted branch feat/restore-backup (was 606e491).
# Deleted branch fix/digest-verification (was 270ef96).
# Deleted branch fix/errors (was 894a727).
# Deleted branch fix/installer (was d22d0a2).
# Deleted branch fix/types (was bc1c9fe).
# Deleted branch hotfix/audit (was 8b6542d).
# Deleted branch hotfix/freetube (was 4b6265c).
# Deleted branch hotfix/package-management (was 45b357c).
# Deleted branch refactor/cleanup (was 54617e5).
# Deleted branch refactor/cli (was 6e1a2b8).
# Deleted branch refactor/logging-f-strings (was 784956e).
# Deleted branch refactor/simplify-code-architecture (was 7179b67).

# missed:
# feat/backup-restore            main                           refactor/structure
# feat/obsidian-digest           refactor/cleanup-architecture
# fix/connection_issue           refactor/modules

# We can search the missed like this:
git branch -vv | grep -E 'feat/|fix/|refactor/' | awk '{print $1}' | xargs git branch -D

# Deleted:
# Deleted branch feat/backup-restore (was 04dcbfe).
# Deleted branch feat/obsidian-digest (was 04dcbfe).
# Deleted branch fix/connection_issue (was ae5c75c).
# Deleted branch refactor/cleanup-architecture (was 17c4c84).
# Deleted branch refactor/modules (was 0bdff40).
# Deleted branch refactor/structure (was 6b6c022).

#TESTING: test this
# Proper mixed up one line local branch delete to clean unused merged branches from local git repository:
git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D && git branch -vv | grep -E 'feat/|fix/|refactor/' | awk '{print $1}' | xargs git branch -D
