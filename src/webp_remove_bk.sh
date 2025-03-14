#!/bin/bash

# Check for input directory argument
if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <input-folder>"
    exit 1
fi

input_folder="$1"
output_folder="${input_folder}/res"

# Create the 'res' directory if it doesn't exist
mkdir -p "${output_folder}"

# Loop through all the PNG images in the input folder
for image in "${input_folder}"/*.WEBP; do
    # Extract just the filename from the path
    filename=$(basename "$image")
    # Use the rembg command to process the image
    rembg i -a "$image" "${output_folder}/${filename}"
done

echo "Processing complete!"
