#!/bin/bash

PROJECT_DIR=$(pwd)
for dir in "$PROJECT_DIR"/*; do
  if [ -d "$dir" ]; then
    cd "$dir" || exit
    echo "Running cargo clean in $dir"
    cargo clean
    cd "$PROJECT_DIR" || exit
  fi
done
