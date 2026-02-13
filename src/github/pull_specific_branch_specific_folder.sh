BRANCH_NAME="main"

# Clone the repository .git information only
# Docs: https://git-scm.com/docs/git-clone
#
# --no-checkout :: Do not fetch any files, only the `.git` directory.
# --sparse :: Only files at the top-level directory, at the root of the repository, will be part of the checkout.
# --branch <branch_name> :: Only fetch the information for the given branch.
# --depth 1 :: Only fetch the tip commit, HEAD of the specified branch.
# --filter=blob:none :: Do not download any blob files.
git clone --no-checkout --sparse --branch "$BRANCH_NAME" --depth 1 --filter=blob:none https://github.com/Cyber-Syntax/dot-files.git cloned_files

cd cloned_files

# Select specific directories to checkout. In the case below this will be the directories `build-tool/` and `functions/edge`.
# Docs: https://git-scm.com/docs/git-sparse-checkout
git sparse-checkout set .config/alacritty/

# Actually checkout the above directories.
# Note: Any file in the root directory of the repository will also be part of the checkout.
git checkout "$BRANCH_NAME"
# or
git checkout HEAD
