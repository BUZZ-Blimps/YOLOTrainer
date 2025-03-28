#!/bin/bash
set -e

echo "🚀 Starting YOLO Trainer Container"

# Delete previous dataset cache in src/datasets and recreate folders
echo "Clearing old dataset cache in /app/src/datasets..."
rm -rf /app/src/datasets/*
mkdir -p /app/src/datasets/images /app/src/datasets/labels

# Delete previous training outputs (runs/detect)
echo "Clearing old training outputs in /app/runs/detect..."
rm -rf /app/runs/detect/*
mkdir -p /app/runs/detect

# Validate launch arguments and copy dataset.
# NOTE: We assume the user will mount their dataset to a separate container path (e.g. /user_dataset)
if [ "$1" = "-tagged" ]; then
    if [ -z "$2" ]; then
        echo "Error: -tagged requires a dataset folder path"
        exit 1
    fi
    echo "Tagged training selected. Copying dataset from $2 to /app/src/datasets..."
    cp -r "$2"/* /app/src/datasets/
    echo "Files in /app/src/datasets after copying:"
    ls -la /app/src/datasets/
    echo "Converting COCO annotations to YOLO format..."
    python3 src/json_parser.py
elif [ "$1" = "-untagged" ]; then
    if [ -z "$2" ]; then
        echo "Error: -untagged requires a dataset folder path"
        exit 1
    fi
    echo "Untagged training selected. Copying dataset from $2 to /app/src/datasets..."
    cp -r "$2"/* /app/src/datasets/
else
    echo "Usage: entrypoint.sh -tagged <dataset_path> OR entrypoint.sh -untagged <dataset_path>"
    exit 1
fi

# Activate the virtual environment
echo "Activating virtual environment..."
source /opt/venv/bin/activate

# Change directory to src (where training and conversion scripts reside)
cd /app/src

# Run the training script
echo "Running training..."
python3 train.py

# Run the conversion script
echo "Running RKNN conversion..."
python3 convert.py

# (Optional) Rename or copy training output directories as needed
# Example: Renaming runs/detect/train to include a timestamp
TRAIN_DIR="/app/runs/detect/train"
if [ -d "$TRAIN_DIR" ]; then
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    NEW_TRAIN_DIR="/app/runs/detect/train_${TIMESTAMP}"
    mv "$TRAIN_DIR" "$NEW_TRAIN_DIR"
    echo "Renamed 'train' to 'train_${TIMESTAMP}'"
fi

echo "✅ Training and conversion completed!"
