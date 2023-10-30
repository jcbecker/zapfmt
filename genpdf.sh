#!/bin/bash

# Check if the input file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_text_file>"
    exit 1
fi

# Read input file
input_file="$1"

# Function to escape special characters for LaTeX
escape_latex() {
    echo "$1" | sed -e 's/\&/\\&/g' -e 's/\$/\\\$/g' -e 's/\#/\\\#/g' -e 's/\_/\\\_/g' -e 's/\%/\\\%/g' -e 's/\xe2\x80\xaf/ /g' -e 's/\xc2\xa0/ /g'
}

# Create LaTeX file for generating PDF in the current directory
latex_file="chat.tex"

echo "\\documentclass{article}" > "$latex_file"
echo "\\usepackage[utf8]{inputenc}" >> "$latex_file" # Specify UTF-8 encoding
echo "\\usepackage{graphicx}" >> "$latex_file"
echo "\\begin{document}" >> "$latex_file"

# Extract messages from the input file and add to LaTeX file
while IFS= read -r line; do
    escaped_line=$(escape_latex "$line")
    if [[ $escaped_line == *".jpg (file attached)"* ]]; then
        image_file=$(echo "$escaped_line" | grep -oP 'IMG-\d+-WA\d+\.jpg')
        echo "\\textbf{Image:} $image_file\\\\\\\\" >> "$latex_file"
        echo "\\includegraphics[width=\\linewidth]{$image_file}\\\\\\\\" >> "$latex_file"
    else
        echo "\\begin{verbatim}" >> "$latex_file"
        echo "$escaped_line\\\\\\\\" >> "$latex_file"
        # sed 's/\xe2\x80\xaf/ /g' < "$escaped_line" >> "$latex_file"
        echo "\\end{verbatim}" >> "$latex_file"
    fi
done < "$input_file"

echo "\\end{document}" >> "$latex_file"

# Generate PDF from LaTeX file
pdflatex "$latex_file"

echo "PDF file generated: chat.pdf"
