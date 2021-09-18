#!/bin/sh

# Fetch the first argument (GitHub Actor)
USERNAME="action"
echo "Global GIT user-name: $USERNAME"
USEREMAIL="action@users.noreply.github.com"
echo "Global GIT user-email: $USEREMAIL"

# Fetch the second argument (GitHub Token) 
TOKEN=$2

# Fetch the third agument (GitHub Repository)
REPOSITORY=$3
echo "Target repository $REPOSITORY"

# Install Doxygen, GIT, and OpenSSH packages
apk add doxygen git openssh

# Generate code documentation
doxygen ./doc/doxygen.conf

# Set GIT global user configuration
git config --global user.email "$USEREMAIL"
git config --global user.name "$USERNAME"

# Add the generated code documentation to the GIT even they are ignored
git add --force ./doc/html

# Stash the generated code documentation
git stash save ./doc/html

# Synchronize with the remote repository
git remote update

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

# Set repository remote URL
REMOTEURL=https://${USERNAME}:${TOKEN}@github.com/${REPOSITORY}.git
#git remote set-url $REMOTEURL

# Push the changes to the remote GitHub Pages branch
git push
