#!/bin/bash

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed. Please install it first."
    exit 1
fi

# Check if the correct number of arguments is provided
if [ $# -ne 4 ]; then
    echo "Usage: $0 <input1.png> <input2.png> <input3.png> <output.png>"
    exit 1
fi

input1="$1"
input2="$2"
input3="$3"
output="$4"
watermark="/Users/helen/Desktop/logo/BGlogo small white3.png"

# Create a blank transparent canvas with the specified dimensions
convert -size 600x1500 xc:none canvas.png

# Resize each input image to 1500x1500
convert "$input1" -resize 1500x1500 resized_input1.png
convert "$input2" -resize 1500x1500 -background none -rotate 23 resized_input2.png
# Add shadow
convert resized_input2.png \( +clone -background black -shadow 100x3+5+5 \) +swap -background none -layers merge +repage resized_input2.png
convert "$input3" -resize 1500x1500 -background none -rotate 53 resized_input3.png
# Add shadow
convert resized_input3.png \( +clone -background black -shadow 100x3+5+5 \) +swap -background none -layers merge +repage resized_input3.png
# Place the first image to the right of the canvas
convert canvas.png resized_input1.png +append result1.png

# Place the second image on the canvas with the specified offset
convert result1.png resized_input2.png -geometry -304-143 -composite result2.png

# Place the third image on the canvas with the specified offset
convert result2.png resized_input3.png -geometry -930-300 -composite result3.png

# Downsample the result image to half its size (1050x750)
convert result3.png -resize 1050x750 result_downsampled.png

# # Create a temporary composite image with the watermark and desired opacity
# convert "$watermark" -alpha set -channel A -evaluate set 50% +channel composite_temp.png

# Composite the watermark onto the result image
composite -gravity center "$watermark" result_downsampled.png "$output"

# Clean up temporary files
rm canvas.png resized_input1.png resized_input2.png resized_input3.png result1.png result2.png result3.png result_downsampled.png

echo "Images combined, downsampled, and watermarked. Saved as $output"
