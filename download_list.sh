#!/bin/bash

# Define the directory where videos will be downloaded
DOWNLOAD_DIR="./videos"

# Create the download directory if it doesn't exist
mkdir -p "$DOWNLOAD_DIR"

# Function to sanitize video titles
sanitize_title() {
  local title="$1"
  # Replace spaces and special characters with underscores
  title=$(echo "$title" | sed 's/[^[:alnum:][:space:]]/_/g' | tr ' ' '_')
  # Remove any leading or trailing underscores
  title=$(echo "$title" | sed 's/^_*\|_*$//g')
  echo "$title"
}

# Read the download_list.txt file line by line
while IFS= read -r url; do
  # Extract the video title from the URL using yt-dlp's output template
  video_title=$(./yt-dlp --cookies-from-browser chrome --cookies cookies.txt --get-title "$url")

  # Sanitize the video title to create a valid file name
  sanitized_title=$(sanitize_title "$video_title")
  echo $sanitized_title

  # Define the expected output file name without extension
  output_file="${DOWNLOAD_DIR}/${sanitized_title}"

  # Check if the video already exists by checking for any file with the sanitized title prefix
  if find "$DOWNLOAD_DIR" -type f -name "${sanitized_title}.*" | grep -q .; then
    echo "Video '$sanitized_title' already exists. Skipping download."
  else
    echo "Downloading video '$sanitized_title'..."
    ./yt-dlp --cookies-from-browser chrome --cookies cookies.txt -o "${output_file}.%(ext)s" "$url"
  fi
done < download_list.txt

echo "All videos processed."
