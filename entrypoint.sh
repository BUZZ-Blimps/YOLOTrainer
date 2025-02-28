#!/bin/bash
set -e

echo "🚀 Starting YOLO Trainer Container"

# Delete previous dataset cache and recreate folders
echo "Clearing old datasets..."
rm -rf /app/src/datasets/*
mkdir -p /app/src/datasets/{images,labels}

# Validate arguments and copy dataset
if [ "$1" = "-tagged" ]; then
    [ -z "$2" ] && echo "Error: -tagged requires dataset path" && exit 1
    echo "Copying tagged dataset from $2..."
    cp -r "$2"/* /app/src/datasets/
    # Convert COCO to YOLO format
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

# Activate virtual environment and run training
#source /opt/venv/bin/activate
#cd /app/src

echo "Training model..."
python3 src/train.py

echo "Converting to RKNN..."
python3  src/convert.py

echo "✅ All operations completed!"