#!/bin/bash

# Get the input folder path from the command-line argument
input_folder=$1

# Check if the input folder exists
if [ ! -d "$input_folder" ]; then
  echo "Error: $input_folder does not exist."
  exit 1
fi

# Initialize the counter
counter=20

# Loop through the PNG files in the input folder
for png_file in "$input_folder"/*.png; do
  # Pad the counter with zeros
  padded_counter=$(printf "%05d" $counter)

  # Rename the file
  new_filename="$padded_counter.png"
  mv "$png_file" "$input_folder/$new_filename"

  # Increment the counter
  counter=$((counter + 1))
done

