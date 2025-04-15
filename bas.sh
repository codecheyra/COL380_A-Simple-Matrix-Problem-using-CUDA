#!/bin/bash

# Output CSV file
OUTPUT="data.csv"

# Define the matrix sizes, number of matrices, and value ranges
matrix_sizes=("1000x1000" "1000x1000" "10000x10000" "10000x10000" "10000x100000")
matrix_counts=(1 10 1 10 1)
ranges=(1024 4096 100000 100000000)

# Header row

echo "r x c,|M|,1024,4096,1e5,1e8" > "$OUTPUT"

# Generate rows
for i in "${!matrix_sizes[@]}"; do
    row="${matrix_sizes[i]},${matrix_counts[i]}"
    for range in "${ranges[@]}"; do
        row="$row,"
    done
    echo "$row" >> "$OUTPUT"
done
