#!/bin/bash

# Exit script if any command fails
set -e

# Store the current branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Create and store a temporary directory name
TEMP_DIR=$(mktemp -d)

# Build the project using npm
npm run build

# Copy build directory to temporary directory
echo "Copying build directory to temporary location..."
cp -R ./build/* "$TEMP_DIR"

# Checkout gh-pages branch, creating it if it doesn't exist
echo "Switching to gh-pages branch..."
if git show-ref --verify --quiet refs/heads/gh-pages; then
  git checkout gh-pages
else
  git checkout --orphan gh-pages
  git rm -rf . >/dev/null 2>&1 || true
fi

# Remove all content except .git directory
echo "Cleaning gh-pages branch..."
find . -maxdepth 1 -not -path "./.git" -not -path "." -exec rm -rf {} \;

# Copy the build contents into the root directory
echo "Copying build files to gh-pages branch..."
cp -R "$TEMP_DIR"/* .

# Add all files
echo "Adding files to git..."
git add -A

# Commit with a meaningful message
echo "Committing changes..."
git commit -m "Deploy to GitHub Pages: $(date)" || {
  echo "No changes to commit. gh-pages branch is already up to date."
}

# Force push to GitHub
echo "Force pushing to gh-pages branch..."
git push -f origin gh-pages

# Go back to the original branch
echo "Switching back to $CURRENT_BRANCH branch..."
git checkout "$CURRENT_BRANCH"

# Clean up temporary directory
echo "Cleaning up..."
rm -rf "$TEMP_DIR"

echo "Deployment to gh-pages completed successfully!"
