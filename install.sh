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

for folder in "$SOURCE_DIR"/*; do
  if [ -d "$folder" ]; then
    folder_name=$(basename "$folder")
    target_path="$TARGET_DIR/$folder_name"

    if [ -d "$target_path" ]; then
      echo "Removing existing directory: $target_path"
      rm -rf "$target_path"
    elif [ -L "$target_path" ]; then
      echo "Removing existing symlink: $target_path"
      rm -f "$target_path"
    fi

    echo "Linking $folder to $target_path"
    ln -s "$folder" "$target_path"
  fi
done

echo "Symlinks have been created."
echo "---------------------------"
echo "linking scripts ..."

for script in "$SCRIPT_SOURCE_DIR"/*; do
	if [ -f "$script" ]; then
		script_name=$(basename "$script")
		target_path="$SCRIPT_TARGET_DIR/$script_name"
		rm -f "$target_path"
		echo "Linking $script to $target_path"
		ln -s "$script" "$target_path"
	fi
done

# misc configs

ln -s "$(pwd)/.tmux.conf" ~/.tmux.conf
ln -s "$(pwd)/.prettierrc" ~/.prettierrc

echo "---------------------------"
echo "finished"
