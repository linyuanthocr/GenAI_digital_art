#!/bin/bash

# Check for correct number of arguments
if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <input-folder>"
    exit 1
fi

input_folder="$1"
output_folder="$1/merge"
temp_folder="${input_folder}/tmp"
count=1

# Create the output folder if it doesn't exist
if [[ ! -d "${output_folder}" ]]; then
    mkdir -p "${output_folder}"
fi

# Check if the temporary folder exists and warn the user
if [[ -d "${temp_folder}" ]]; then
    echo "Temporary directory ${temp_folder} already exists. Exiting to prevent data loss."
    exit 1
else
    mkdir -p "${temp_folder}"
fi

# Collecting all PNGs into an array
files=()
while IFS= read -r; do
    files+=("$REPLY")
done <<< "$(find "${input_folder}" -type f -name '*.png' | sort)"

# Prepare the command group array
cmd_group=()

# Iterate over the positions in the 3 rows x 4 columns grid
for ((i=0; i<12; i++)); do
    # Skip the center two cells in the second row (positions 5 and 6)
    if [[ $i -eq 5 || $i -eq 6 ]]; then
        placeholder="${temp_folder}/placeholder_${i}.png"
        convert -size 512x512 xc:none "$placeholder"
        cmd_group+=("$placeholder")
    else
        # Adjust the index for image selection
        image_index=$i
        if [[ $i -gt 6 ]]; then
            ((image_index-=2))
        fi

        # Add the image or placeholder
        if [[ $image_index -lt ${#files[@]} ]]; then
            cp "${files[$image_index]}" "${temp_folder}"
            temp_image="${temp_folder}/$(basename "${files[$image_index]}")"
            cmd_group+=(
                \( "${temp_image}" -resize 512x512 \)
            )
        else
            # Add a placeholder if there are less than 10 images
            placeholder="${temp_folder}/placeholder_${image_index}.png"
            convert -size 512x512 xc:none "$placeholder"
            cmd_group+=("$placeholder")
        fi
    fi
done

# Use montage to create the 3x4 grid
montage "${cmd_group[@]}" -background none -geometry +0+20 -tile 4x3 "${output_folder}/merged_image.png"

# Remove the temporary directory
rm -rf "${temp_folder}"

echo "Processing complete!"
