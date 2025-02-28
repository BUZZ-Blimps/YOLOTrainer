import yaml
import os
from ultralytics import YOLO

# Load conversion config
with open("convert.yaml", "r") as file:
    config = yaml.safe_load(file)

# Define paths relative to Docker structure
model_dir = config["model"]["trained_model_dir"]
model_name = config["model"]["trained_model_name"]
export_dir = config["model"]["export_dir"]

trained_model_path = os.path.join(model_dir, model_name)
os.makedirs(export_dir, exist_ok=True)

# Export model
model = YOLO(trained_model_path)
export_path = os.path.join(export_dir, "model.rknn")
model.export(format="rknn", name=export_path)

print(f"✅ RKNN model saved to {export_path}")