#!/bin/sh

# Fetch the first argument (Doxygen configuratuin file path)
DOXYGENCONF="./doc/doxygen.conf"
echo "Doxygen confiugration file path: $DOXYGENCONF"

# Fetch the second agument (Generated HTML documents output folder)
HTMLOUTPUT=$2
echo "Generated HTML documents output folder $HTMLOUTPUT"

# Install Doxygen, GIT, and OpenSSH packages
apk add doxygen git openssh

# Generate code documentation
doxygen $DOXYGENCONF

# Set GIT global user configuration
git config user.name actions
git config user.email actions@users.noreply.github.com

# Add the generated code documentation to the GIT even they are ignored
git add --force $HTMLOUTPUT

# Stash the generated code documentation
git stash save $HTMLOUTPUT

# Synchronize with the remote repository
git remote update

# Switch to the GitHub Pages branch
git checkout gh-pages

# Remove all the file in GitHub Pages branch
git rm -rf .

# Pop the stashed generated code documentation
git stash pop

# Move the the generated code documentation to the branch root
mv $HTMLOUTPUT/* .

# Add all the changes to the GIT
git add --all

# Commit all the changed to the the GitHub Pages branch
git commit -m "Auto commit."

# Push the changes to the remote GitHub Pages branch
git push
