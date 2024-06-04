#!/bin/bash

SOURCE_DIR="$(pwd)/config"
TARGET_DIR="$HOME/.config"


SCRIPT_SOURCE_DIR="$(pwd)/scripts"
SCRIPT_TARGET_DIR="$HOME/.local/bin"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Source directory $SOURCE_DIR does not exist."
  exit 1
fi

if [ ! -d "$SCRIPT_SOURCE_DIR" ]; then
  echo "Source directory $SCRIPT_SOURCE_DIR does not exist."
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
echo "---------------------------"
echo "linking scripts ..."

for script in "$SCRIPT_SOURCE_DIR"/*; do
	if [ -f "$script" ]; then
		# Extract the script name
		script_name=$(basename "$script")
		# Target path
		target_path="$SCRIPT_TARGET_DIR/$script_name"
		# Remove the existing link in the target if it exists
		rm -f "$target_path"
		# Create a symbolic link from the source to the target
		echo "Linking $script to $target_path"
		ln -s "$script" "$target_path"
	fi
done

# misc configs

ln -s "$(pwd)/.tmux.conf" ~/.tmux.conf
ln -s "$(pwd)/.prettierrc" ~/.prettierrc

echo "---------------------------"
echo "finished"
