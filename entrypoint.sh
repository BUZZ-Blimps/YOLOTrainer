#!/bin/bash
set -e

echo "🚀 Starting YOLO Trainer Container"

# Delete previous dataset cache and recreate folders
echo "Clearing old datasets..."
rm -rf src/datasets/*
mkdir -p src/datasets/images src/datasets/labels

# Delete previous dataset cache and recreate folders
echo "Clearing old cached training files"
sudo rm -rf runs/detect/*
sudo mkdir -p runs/detect



# Validate arguments and copy dataset
if [ "$1" = "-tagged" ]; then
    if [ -z "$2" ]; then
        echo "Error: -tagged requires dataset path"
        exit 1
    fi
    echo "Copying tagged dataset from $2..."
    cp -r "$2"/* src/datasets/
    echo "Files in src/datasets after copying:"
    ls -la src/datasets/
    echo "Converting COCO to YOLO..."
    python3 src/json_parser.py

elif [ "$1" = "-untagged" ]; then
    [ -z "$2" ] && echo "Error: -untagged requires dataset path" && exit 1
    echo "Copying untagged dataset from $2..."
    cp -r "$2"/* /app/src/datasets/
else
    echo "Usage: $0 -tagged <path> OR -untagged <path>"
    exit 1
fi



# Activate the virtual environment
echo "Activating virtual environment..."
source test-env/bin/activate


echo "Training model..."
test-env/bin/python3.10 src/train.py

echo "Converting to RKNN..."
test-env/bin/python3.10 src/convert.py


# Define the directory path
TRAIN_DIR="/home/amia/Desktop/BLIMPBLIMP/YOLOTrainer/best_rknn_model/runs/detect/train"

# Generate a timestamp (format: YYYYMMDD_HHMMSS)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# New directory name with timestamp
NEW_TRAIN_DIR="/home/amia/Desktop/BLIMPBLIMP/YOLOTrainer/best_rknn_model/runs/detect/train_${TIMESTAMP}"

# Rename the train directory if it exists
if [ -d "$TRAIN_DIR" ]; then
    mv "$TRAIN_DIR" "$NEW_TRAIN_DIR"
    echo "✅ Renamed 'train' to 'train_${TIMESTAMP}'"
else
    echo "⚠️ Directory 'train' not found, skipping rename."
fi




# Define the directory path
TRAIN_DIR="/home/amia/Desktop/BLIMPBLIMP/YOLOTrainer/best_rknn_model/runs/detect/train"

# Generate a timestamp (format: YYYYMMDD_HHMMSS)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# New directory name with timestamp
NEW_TRAIN_DIR="/home/amia/Desktop/BLIMPBLIMP/YOLOTrainer/best_rknn_model/runs/detect/train_${TIMESTAMP}"

# Rename the train directory if it exists
if [ -d "$TRAIN_DIR" ]; then
    mv "$TRAIN_DIR" "$NEW_TRAIN_DIR"
    echo "✅ Renamed 'train' to 'train_${TIMESTAMP}'"
fi


# New directory name with timestamp
TARGET_DIR="/home/amia/Desktop/BLIMPBLIMP/YOLOTrainer/best_rknn_model/runs/detect/train_${TIMESTAMP}"
SOURCE_DIR="runs/detect/train"
# Ensure the target parent directory exists
mkdir -p "$(dirname "$TARGET_DIR")"

# Check if the source directory exists before copying
if [ -d "$SOURCE_DIR" ]; then
    echo "Copying train directory to $TARGET_DIR..."
    cp -r "$SOURCE_DIR" "$TARGET_DIR"
    echo "✅ Train folder copied successfully to $TARGET_DIR"
else
    echo "⚠️ Source directory '$SOURCE_DIR' not found, skipping copy."
fi


echo "✅ All operations completed!"