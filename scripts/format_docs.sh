#!/bin/bash

# Format markdown files using Prettier
prettier --write "**/*.md" --prose-wrap always --print-width 80

# Show success message
echo "✨ Markdown files have been formatted!" 