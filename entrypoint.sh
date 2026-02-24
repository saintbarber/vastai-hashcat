#!/bin/bash

DIRECTORY="wordlists"

# Loop through all .7z files in the directory
for file in "$DIRECTORY"/*.7z; do
  # Check if there are any .7z files
  [ -e "$file" ] || continue

  echo "Extracting: $file" 
  
  # Extract the .7z file to a folder with the same name (without extension)
  7zz x "$file" -o"$DIRECTORY"

  echo "Done: $file"
  rm "$file" 
done

sleep infinity # Needed to keep container open