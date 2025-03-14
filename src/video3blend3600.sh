#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 input_folder"
  exit 1
fi

# Input folder containing PNG images with transparency
input_folder="$1"

# Output video file name
output_video="output_video.mp4"

# Frame rate of the output video
frame_rate=3

# Background images
background1="/Users/helen/Desktop/ETsy/background/bg.jpg"
background2="/Users/helen/Desktop/ETsy/background/bgtrans.png"
# background2="/Users/helen/Desktop/ETsy/background/bgtransbig.png"


# Create a temporary directory for intermediate images
temp_dir="temp"
mkdir -p "$temp_dir"

# Step 1: Loop through each PNG image in the input folder
counter=0
for png_file in "$input_folder"/*.png; do
  if [ -e "$png_file" ]; then
    filename=$(basename -- "$png_file")
    filename_noext="${filename%.*}"

    # # Generate a temporary image by blending background1 + image + background2
    # ffmpeg -i "$background1" -i "$png_file" -i "$background2" -filter_complex "[0:v][1:v]overlay=0:0[bg1];[bg1][2:v]overlay=0:0" "$temp_dir/$(printf %04d $counter)-temp.png"
    # Resize the PNG file to 1024x1024
    RESIZED_PNG="$temp_dir/$(basename "$png_file" .png)_resized.png"
    convert "$png_file" -resize 1024x1024! "$RESIZED_PNG"

    # Generate a temporary image by blending background1 + resized image + background2
    ffmpeg -i "$background1" -i "$RESIZED_PNG" -i "$background2" -filter_complex "[0:v][1:v]overlay=0:0[bg1];[bg1][2:v]overlay=0:0" "$temp_dir/$(printf %04d $counter)-temp.png"
    counter=$((counter + 1))
    rm "$RESIZED_PNG"
  else
    echo "Warning: No PNG files found in $input_folder."
    exit 1
  fi
done

# Step 2: Concatenate the blended images into a video
ffmpeg -framerate "$frame_rate" -i "$temp_dir/%04d-temp.png" -c:v libx264 -vf "fps=$frame_rate" "$output_video"

# Step 3: Clean up temporary files
rm -rf "$temp_dir"

echo "Video generation complete. Output video: $output_video"