#!/bin/sh

# Fetch the first argument (Doxygen configuratuin file path)
DOXYGENCONF=$1
if [ -f "$DOXYGENCONF" ]; then
    echo "Doxygen confiugration file path: $DOXYGENCONF"
else
    echo "Doxygen confiugration file cannot be found at: $DOXYGENCONF"
    exit 1;
fi

# Install Doxygen, GIT, and OpenSSH packages
apk add doxygen git openssh

# Try to generate code documentation
# Exit with error if the document generation failed
doxygen "$DOXYGENCONF" || exit 1

# Fetch the second agument (Generated HTML documents output folder) and
# strip the '/' character from the end of the directory path (if there is any)
HTMLOUTPUT=${2%/}
if [ -d "$HTMLOUTPUT" ]; then
    echo "Generated HTML documents output folder: $HTMLOUTPUT"
else
    echo "HTML documents output folder cannot be found at: $HTMLOUTPUT"
    exit 1;
fi

# Set Git user configuration
git config user.name github-actions[bot]
git config user.email github-actions[bot]@users.noreply.github.com

# Add the generated code documentation to the Git even they are ignored
git add --force "$HTMLOUTPUT"

# Stash the generated code documentation
git stash save "$HTMLOUTPUT"

# Synchronize with the remote repository
git remote update

# Fetch the third argument (GitHub Pages branch name)
GHPAGESBRANCH=$3

# Try to switch to the GitHub Pages branch
# Exit with error if the checkout failed
git checkout "$GHPAGESBRANCH" || exit 1

# Fetch the forth agument (GitHub Pages directory path)
GHPAGESDIR=$4
if [ -d "$GHPAGESDIR" ]; then
    # Remove all the files in GitHub Pages directory (if the directory exists)
    git rm -rf "$GHPAGESDIR"
else
    # Make the GitHub Pages directory if it does not exist
    mkdir "$GHPAGESDIR"
fi

# Pop the stashed generated code documentation
git stash pop

# Move the the generated code documentation to the GitHub Pages directory
# if two directories are not the same.
if [ ! "$(realpath "$GHPAGEDIR")" -ef "$(realpath "$HTMLOUPUT")" ]; then
    mv "$HTMLOUTPUT"/* "$GHPAGESDIR"
fi

# Add all the changes to the GIT
git add --all

# Commit all the changed to the the GitHub Pages branch
git commit -m "Auto commit."

# Push the changes to the remote GitHub Pages branch
git push
