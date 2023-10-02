#!/bin/bash
# Use the current directory as the project directory
PROJECT_DIR=$(pwd)
# Loop over all directories in the project directory
for dir in "$PROJECT_DIR"/*; do
  # Check if it is a directory
  if [ -d "$dir" ]; then
    # Change to the directory
    cd "$dir" || exit
    # Run cargo clean
    echo "Running cargo clean in $dir"
    cargo clean
    # Go back to the project directory
    cd "$PROJECT_DIR" || exit
  fi
done
