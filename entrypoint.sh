#!/bin/bash
set -e

echo "🚀 Starting YOLO Trainer Container"

# Delete previous dataset cache from src/datasets and recreate the folder
echo "Deleting old dataset cache in /app/src/datasets..."
rm -rf /app/src/datasets/*
mkdir -p /app/src/datasets

# Check for launch arguments: either -tagged or -untagged must be provided with a dataset path
if [ "$1" = "-tagged" ]; then
    if [ -z "$2" ]; then
        echo "Error: -tagged option requires a dataset folder path as the second argument."
        exit 1
    fi
    echo "Tagged training selected. Copying dataset from $2 to /app/src/datasets..."
    cp -r "$2"/* /app/src/datasets/
elif [ "$1" = "-untagged" ]; then
    if [ -z "$2" ]; then
        echo "Error: -untagged option requires a dataset folder path as the second argument."
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

# Change directory to src (where training and conversion scripts are located)
cd /app/src

# Run the training script
echo "Running training..."
python3 train.py

# Run the conversion script
echo "Running RKNN conversion..."
python3 convert.py

echo "✅ Training and conversion completed!"
