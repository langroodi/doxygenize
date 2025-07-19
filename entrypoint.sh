#!/bin/sh
# Enable console output
set -x

InstallDependencies () {
    # Install Doxygen, GIT, OpenSSH, Graphviz, and TrueType Free Font packages
    apk add doxygen git openssh graphviz ttf-freefont
}

ConfigureCustomHeader () {
    DOXYGENCONF=$1
    CUSTOMHEADER=$2
    TEMPDESTINATION="/tmp/custom_header.html"
    HTMLHEADER="HTML_HEADER"

    # Exit with error
    # if the 'HTML_HEADER' configuration entry already exists in the Doxygen configuration file
    if (grep -q "$HTMLHEADER" "$DOXYGENCONF")
    then
        echo "HTML header configuration entry already exists in the Doxygen configuration file"
        exit 1
    fi

    # Download the custom header file to the temp directory
    wget -O "$TEMPDESTINATION" "$CUSTOMHEADER" || exit 1

    # Append the 'HTML_HEADER' configuration entry to the Doxygen configuration file
    CONFIGURATIONENTRY="\n$HTMLHEADER=$TEMPDESTINATION"
    echo -e "$CONFIGURATIONENTRY" >> "$DOXYGENCONF"
}

ConfigureDarkMode () {
    DOXYGENCONF=$1
    DARKSTYLE="DARK"
    HTMLCOLORSTYLE="HTML_COLORSTYLE"

    # Append the 'HTML_COLORSTYLE' configuration entry to the Doxygen configuration file
    CONFIGURATIONENTRY="\n$HTMLCOLORSTYLE=$DARKSTYLE"
    echo -e "$CONFIGURATIONENTRY" >> "$DOXYGENCONF"
}

ConfigureGitUser () {
    # Set Git user configuration
    git config --global user.name github-actions[bot]
    git config --global user.email github-actions[bot]@users.noreply.github.com
    
    # Add shared GitHub Workspace as exception due to CVE-2022-24765
    git config --global --add safe.directory /github/workspace
}

DisableJekyll () {
    # Add .nojekyll file to disable GitHub Pages Jekyll processing
    # This allows pages with leading underscores
    touch "${1%/}/.nojekyll"
}

GetCurrentBranch () {
    # Get the current branch name
    echo "$(git rev-parse --abbrev-ref HEAD)"
}

PrepareGitHubPagesDirectory() {
    DESTINATIONDIR=$1
	
    # Remove all the files in GitHub Pages directory (if the directory exists)
    if [ -d "$DESTINATIONDIR" ]; then
        git rm -rf "$DESTINATIONDIR"
    fi
    
    # Create the GitHub Pages directory if it does not exist
    mkdir -p "$DESTINATIONDIR"
}

MigrateChanges () {
    SOURCEDIR=$1
    DESTINATIONBRANCH=$2
    DESTINATIONDIR=$3

    # Add the generated code documentation to the Git even if they are ignored
    git add --force "$SOURCEDIR"

    # Stash the generated code documentation
    git stash save "$SOURCEDIR"

    # Synchronize with the remote repository
    git remote update

    # Try to switch to the GitHub Pages branch
    # Exit with error if the checkout failed
    git checkout "$DESTINATIONBRANCH" || exit 1
    
    # Prepare destination directory
    PrepareGitHubPagesDirectory "$DESTINATIONDIR"

    # Pop the stashed generated code documentation
    git stash pop
}

CommitChanges () {
    DESTINATIONDIR=$1
    
    # Unstage all changes
    git reset
    
    # Add only the destination directory
    git add --force "$DESTINATIONDIR"
    
    # Check if there are any changes that are staged but not committed
    if (! git diff --cached --exit-code --shortstat) 
    then
   	
	# Commit all the changed to the the GitHub Pages branch
    	git commit -m "Auto commit" || exit 1
   	
	# Push the changes to the remote GitHub Pages branch
    	git push
    else
    	echo "There is no change in the documentation"
    fi
}

# Fetch the first argument (Doxygen configuration file path)
DOXYGENCONF=$1
if [ -f "$DOXYGENCONF" ]; then
    echo "Doxygen configuration file path: $DOXYGENCONF"
else
    echo "Doxygen configuration file cannot be found at: $DOXYGENCONF"
    exit 1
fi

# Fetch the second agument (Generated HTML documents output folder) and
# strip the '/' character from the end of the directory path (if there is any)
HTMLOUTPUT=${2%/}

# Fetch the third argument (GitHub Pages branch name)
GHPAGESBRANCH=$3

# Fetch the forth argument (GitHub Pages directory path)
GHPAGESDIR=$4

# Fetch the fifth argument (Toggle dark mode)
DARKMODE=$5

# Fetch the sixth argument (Custom Doxygen pages header HTML file URL)
CUSTOMHEADER=$6

InstallDependencies

# Customize Doxygen HTML pages header
# if the custom header has been set
if [ "$CUSTOMHEADER" != "" ]; then
    ConfigureCustomHeader "$DOXYGENCONF" "$CUSTOMHEADER"
fi

# Try to generate code documentation
# Exit with error if the document generation failed
doxygen "$DOXYGENCONF" || exit 1

# Check for existence of HTML output folder
if [ -d "$HTMLOUTPUT" ]; then
    echo "Generated HTML documents output folder: $HTMLOUTPUT"
else
    echo "HTML documents output folder cannot be found at: $HTMLOUTPUT"
    exit 1
fi

# Force the dark mode as the HTML color style
# if dark mode is enabled as action input
if [ $DARKMODE = true ]; then
    ConfigureDarkMode "$DOXYGENCONF"
fi

ConfigureGitUser

CURRENTBRANCH=$(GetCurrentBranch)

# Stash changes in the current branch and move them to the GitHub pages branch
# if the current branch and the determined GitHub page branch are not the same.
if [ "$CURRENTBRANCH" != "$GHPAGESBRANCH" ]; then
    MigrateChanges "$HTMLOUTPUT" "$GHPAGESBRANCH" "$GHPAGESDIR"
fi

# Move the the generated code documentation to the GitHub Pages directory
# if two directories are not the same.
if [ ! "$(realpath "$GHPAGESDIR")" -ef "$(realpath "$HTMLOUTPUT")" ]; then
    # Create the GitHub Pages directory if it does not exist
    mkdir -p "$GHPAGESDIR"
    
    mv "$HTMLOUTPUT"/* "$GHPAGESDIR"
fi

DisableJekyll "$GHPAGESDIR"

CommitChanges "$GHPAGESDIR"
