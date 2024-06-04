#!/bin/bash

SOURCE_DIR="$(pwd)/config"
TARGET_DIR="$HOME/.config"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Source directory $SOURCE_DIR does not exist."
  exit 1
fi
# Iterate through each folder in the source directory
for folder in "$SOURCE_DIR"/*; do
  if [ -d "$folder" ]; then
    # Extract the folder name
    folder_name=$(basename "$folder")

    # Target path
    target_path="$TARGET_DIR/$folder_name"

    # Remove the existing directory in the target if it exists
    if [ -d "$target_path" ]; then
      echo "Removing existing directory: $target_path"
      rm -rf "$target_path"
    elif [ -L "$target_path" ]; then
      echo "Removing existing symlink: $target_path"
      rm -f "$target_path"
    fi
    # Create a symbolic link from the source to the target
    echo "Linking $folder to $target_path"
    ln -s "$folder" "$target_path"
  fi
done
echo "Symlinks have been created."
