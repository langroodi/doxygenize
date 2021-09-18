#!/bin/sh

# Argument $1 is GitHub Actor
USERNAME = $1
USEREMAIL = "$1@users.noreply.github.com"

# Install Doxygen and GIT package
apk add doxygen git

# Generate code documentation
doxygen ./doc/doxygen.conf

# Set GIT global user configuration
git config --global user.email "$USEREMAIL"
git config --global user.name "$USERNAME"

# Add the generated code documentation to the GIT even they are ignored
git add --force ./doc/html

# Stash the generated code documentation
git stash save ./doc/html

# Switch to the GitHub Pages branch
git checkout gh-pages

# Remove all the file in GitHub Pages branch
git rm -rf .

# Pop the stashed generated code documentation
git stash pop

# Move the the generated code documentation to the branch root
mv ./doc/html/* .

# Add all the changes to the GIT
git add --all

# Commit all the changed to the the GitHub Pages branch
git commit -m "Auto commit."