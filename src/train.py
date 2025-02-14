import os
import yaml
from ultralytics import YOLO

# Path to dataset.yaml inside Docker
DATASET_PATH = "/home/amia/Desktop/BLIMPBLIMP/YOLOTrainer/src/datasets/dataset.yaml"

if not os.path.exists(DATASET_PATH):
    raise FileNotFoundError(f"❌ dataset.yaml not found at {DATASET_PATH}. Check if datasets/ is copied into the container.")

# Load dataset.yaml
with open(DATASET_PATH, "r") as file:
    dataset_config = yaml.safe_load(file)

# Train YOLO
model = YOLO("yolo11n.pt")
model.train(
    data=DATASET_PATH,
    epochs=150,
    imgsz=640,
    batch=32,
    workers=4,
    device=0  # Force using GPU device 0
)


print("✅ Training complete!")
