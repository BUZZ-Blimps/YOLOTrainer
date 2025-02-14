import yaml
import os
from ultralytics import YOLO

# Load configuration
with open("convert.yaml", "r") as file:
    config = yaml.safe_load(file)

# Define paths
trained_model_path = os.path.join(config["model"]["trained_model_dir"], config["model"]["trained_model_name"])
export_folder = config["model"]["export_dir"]
os.makedirs(export_folder, exist_ok=True)  # Ensure the export folder exists

# Load the trained model
model = YOLO(trained_model_path)

# Correct RKNN export
export_path = os.path.join(export_folder, "rk3588.rknn")

# Export to RKNN format for RK3588
model.export(format="rknn", name="rk3588")  # Target Rockchip processor
#os.rename("best-rk3588.rknn", export_path)  # Move file to correct folder

print(f"Model conversion to RKNN format completed.")
