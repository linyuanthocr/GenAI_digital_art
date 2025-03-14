#!/bin/bash

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed. Please install it first."
    exit 1
fi

# Check if the correct number of arguments is provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <input_folder> <M>"
    exit 1
fi

input_folder="$1"
M="$2"
output_base="res"

# Get the list of PNG files in the input folder
png_files=($(ls -1 "$input_folder"/*.png | sort))

# Calculate the number of PNG files
N="${#png_files[@]}"

# Calculate the number of rows and columns for each image
num_rows=2
num_columns=$((N / (M * num_rows)))

# Set the row distance
row_distance=50

# Loop to generate M images
for ((i = 0; i < M; i++)); do
    start_index=$((i * num_columns * num_rows))
    end_index=$((start_index + (num_columns * num_rows) - 1))
    output_image="${output_base}_${i}.png"

    # Create an array to store the processed image filenames for this image
    processed_images=()

    # Loop through a subset of PNG files for this image
    for ((j = start_index; j <= end_index; j++)); do
        file="${png_files[$j]}"
        if [ -f "$file" ]; then
            # Get the filename (excluding extension) for the processed image
            filename="${file%.*}_processed.png"

            # Crop the right half of the image
            convert "$file" -crop 40%x100%+60%+0 "$filename"

            # Resize the cropped image to half width and half height
            convert "$filename" -resize 50%x50% "$filename"

            # Add shadow
            convert "$filename" \( +clone -background black -shadow 100x3+5+5 \) +swap -background none -layers merge +repage "$filename"

            # Append the processed image filename to the array
            processed_images+=("$filename")
        fi
    done

    # Combine the processed images into a big image with 2 rows
    #montage -mode concatenate -tile "${num_columns}x${num_rows}" "${processed_images[@]}" "$output_image"

    # Combine the processed images into a big image with 2 rows and add row distance
    montage -mode concatenate -tile "${num_columns}x${num_rows}" -geometry "+0+${row_distance}" "${processed_images[@]}" "$output_image"

    # Use identify to get the image width and height
    image_info=$(identify -format "%w %h" "$output_image")

    # Split the image_info into width and height variables
    read -r width height <<< "$image_info"
    
    new_height=$((height - 2 * row_distance))

    echo "Image heights: $height, $row_distance, $new_height"

    convert "$output_image" -gravity center -crop "$width"x"$new_height"+0+0 "$output_image"



    echo "Image $i generated: $output_image"

    # Clean up temporary processed images
    rm "${processed_images[@]}"
done


echo "Images processed and generated."
