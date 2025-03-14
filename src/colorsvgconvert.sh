#!/bin/bash

# Check if the input argument (PNG folder) is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path-to-png-folder>"
    exit 1
fi

# Define input and output directories
input_dir="$1"
output_dir="${input_dir}/svg_outputs"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through each PNG file in the input directory
for png_file in "${input_dir}"/*.png; do
    # Extract the base filename without the extension
    base_name=$(basename "$png_file" .png)
    
    # Define the intermediate PNM, intermediate SVG, and final SVG filenames
    pnm_file="${output_dir}/${base_name}.pnm"
    temp_svg_file="${output_dir}/${base_name}_temp.svg"
    final_svg_file="${output_dir}/${base_name}.svg"
    
    # Convert the PNG file to a grayscale PNM
    convert "$png_file" -colorspace Gray "$pnm_file"
    
    # Convert the PNM file to SVG using potrace
    potrace "$pnm_file" -s -o "$temp_svg_file"
    
    # Use Inkscape to reapply the original colors to the SVG
    inkscape "$temp_svg_file" --verb=EditSelectAll --verb=SelectionGroup --verb=FileSave --verb=FileClose
    inkscape "$png_file" -l "$final_svg_file"
    
    # Remove the temporary files
    rm "$pnm_file" "$temp_svg_file"
    
    echo "Converted: $png_file -> $final_svg_file"
done

echo "Conversion completed."
