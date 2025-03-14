import os
import yaml
from ultralytics import YOLO

# Correct path within Docker
DATASET_PATH = "src/datasets/dataset.yaml"

if not os.path.exists(DATASET_PATH):
    raise FileNotFoundError(f"dataset.yaml not found at {DATASET_PATH}")

# Load and validate dataset config
with open(DATASET_PATH, "r") as file:
    dataset_config = yaml.safe_load(file)
    assert 'names' in dataset_config, "Invalid dataset.yaml format"


DATASET_PATH = "src/datasets/dataset.yaml"

# Train model
model = YOLO("yolov8n.pt")  # Use correct model name
model.train(
    data=DATASET_PATH,
    epochs=1,
    imgsz=640,
    batch=32, 
    workers=4,
    device=0
)

print("✅ Training complete!")