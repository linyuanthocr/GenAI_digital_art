#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <input-folder> <output-folder>"
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

for ((i=0; i<${#files[@]}; i+=6)); do
    # Check if there are enough images left
    if [[ $((i+5)) -ge ${#files[@]} ]]; then
        break
    fi

    # Placeholder for the group of commands
    cmd_group=()

    # For each image in the group of 8, copy to temp and add to the command group
    for ((j=0; j<6; j++)); do
        # Copy the image to the temp directory
        cp "${files[$((i+j))]}" "${temp_folder}"
        temp_image="${temp_folder}/$(basename "${files[$((i+j))]}")"
        cmd_group+=(
            \( "${temp_image}" -resize 512x512 \)
        )
    done

    # Use montage for the group of 8 images, with the desired spacings
    montage "${cmd_group[@]}" -background none -geometry +0+80 -tile 3x2 "${output_folder}/$(printf "%05d.png" ${count})"
    #montage "${cmd_group[@]}" -background none -geometry +0+0 -tile 4x2 miff:- | convert - -splice 0x512+0+512 "${output_folder}/$(printf "%05d.png" ${count})"

    
    # Clear the temporary directory
    rm -rf "${temp_folder}"
    mkdir -p "${temp_folder}"

    ((count++))
done

# Remove the temporary directory
rm -rf "${temp_folder}"

echo "Processing complete!"
