#!/bin/bash

# Install Doxygen package
apk add doxygen

# Generate code documentation
doxygen ./doc/doxygen.conf

# Add the generated code documentation to the GIT
git add ./doc/html

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