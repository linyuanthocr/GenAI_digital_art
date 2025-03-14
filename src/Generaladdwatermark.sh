#!/bin/bash

# Check for the correct number of command-line arguments
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <input_folder>"
  exit 1
fi

input_folder="$1"
background_image="input/bk.png"
watermark_image="input/webtrans.png"

# Check if the input folder exists
if [ ! -d "$input_folder" ]; then
  echo "Input folder '$input_folder' does not exist."
  exit 1
fi

# Check if the background image exists
if [ ! -f "$background_image" ]; then
  echo "Background image '$background_image' does not exist."
  exit 1
fi

# Check if the watermark image exists
if [ ! -f "$watermark_image" ]; then
  echo "Watermark image '$watermark_image' does not exist."
  exit 1
fi

# Create an output directory if it doesn't exist
output_dir="$input_folder/output"
mkdir -p "$output_dir"

# Overlay the watermark on each image using the background
for image in "$input_folder"/*.png; do
  filename=$(basename "$image")
  output_image="$output_dir/$filename"

  # # Overlay the watermark using ImageMagick
  # composite -dissolve 50% -gravity center "$watermark_image" "$image" "$output_image"

  # Resize watermark to match the size of the image and overlay using ImageMagick
  convert "$watermark_image" -resize $(identify -format "%wx%h" "$image")\! resized_watermark.png
  composite -dissolve 50% -gravity center resized_watermark.png "$image" "$output_image"

  
  # # Combine the result with the background
  # composite -gravity center "$output_image" "$background_image" "$output_image"
  # Resize background to match the size of the output image and combine using ImageMagick
  convert "$background_image" -resize $(identify -format "%wx%h" "$output_image")\! resized_background.png
  composite -gravity center "$output_image" resized_background.png "$output_image"

  
  echo "Processed: $output_image"
done

echo "Image processing completed. Processed images are saved in the 'output' directory."
