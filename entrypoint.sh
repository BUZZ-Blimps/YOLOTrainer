#!/bin/bash
set -e

echo "🚀 Starting YOLO Trainer Container"

# Delete previous dataset cache and recreate folders
echo "Clearing old dataset cache in /app/src/datasets..."
rm -rf /app/src/datasets/*
mkdir -p /app/src/datasets/images /app/src/datasets/labels

echo "Clearing old training outputs in /app/runs/detect..."
rm -rf /app/runs/detect/*
mkdir -p /app/runs/detect

# Validate arguments and copy dataset from the mounted volume (/user_dataset)
if [ "$1" = "-tagged" ]; then
    if [ -z "$2" ]; then
        echo "Error: -tagged requires a dataset path"
        exit 1
    fi
    echo "Tagged training selected. Copying dataset from $2 to /app/src/datasets..."
    cp -r "$2"/* /app/src/datasets/
elif [ "$1" = "-untagged" ]; then
    if [ -z "$2" ]; then
        echo "Error: -untagged requires a dataset path"
        exit 1
    fi
    echo "Untagged training selected. Copying dataset from $2 to /app/src/datasets..."
    cp -r "$2"/* /app/src/datasets/
else
    echo "Usage: entrypoint.sh -tagged <dataset_path> OR -untagged <dataset_path>"
    exit 1
fi

# Debug: List contents of the dataset directory and the images subfolder
echo "Listing contents of /app/src/datasets:"
ls -la /app/src/datasets

echo "Listing contents of /app/src/datasets/images:"
ls -la /app/src/datasets/images

# Activate virtual environment
echo "Activating virtual environment..."
source /opt/venv/bin/activate

# Change directory to src for training
cd /app/src

echo "Running training..."
python3 train.py

echo "Running RKNN conversion..."
python3 convert.py

echo "✅ Training and conversion completed!"
