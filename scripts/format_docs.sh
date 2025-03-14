#!/bin/bash

# Check if prettier is installed
if ! command -v prettier &> /dev/null; then
    echo "Prettier is not installed. Installing..."
    npm install -g prettier
fi

# Format all markdown files
echo "Formatting markdown files..."
prettier --write "**/*.md" --prose-wrap always --print-width 80

echo "Formatting complete!" 