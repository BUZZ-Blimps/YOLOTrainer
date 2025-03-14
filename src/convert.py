import os
import yaml
import shutil
from ultralytics import YOLO

# Hard-coded export directory for the RKNN model
export_dir = "best_rknn_model/runs/detect/train/weights"
os.makedirs(export_dir, exist_ok=True)  # Ensure this directory exists

# Load conversion configuration
with open("src/convert.yaml", "r") as file:
    config = yaml.safe_load(file)

# Get model paths from the config
model_dir = config["model"]["trained_model_dir"]
model_name = config["model"]["trained_model_name"]
trained_model_path = os.path.join(model_dir, model_name)

# Load the trained YOLO model
model = YOLO(trained_model_path)

# Define the export filename (this is just our desired file name)
export_filename = "best-rk3566.rknn"
export_path = os.path.join(export_dir, export_filename)

# Export the model:
# Note: The "name" parameter here must be a valid RKNN processor name (e.g. "rk3566").
# The model.export() function will export the RKNN model to the current working directory.
model.export(format="rknn", name="rk3566")

# After exporting, the model file is likely saved as "best-rk3566.rknn" in the current directory.
# We then move it to our desired export directory.
default_export_file = export_filename  # Assuming the file is named "best-rk3566.rknn"
if os.path.exists(default_export_file):
    shutil.move(default_export_file, export_path)
    print(f"✅ RKNN model saved to {export_path}")
else:
    print("Exported file not found, please check the export process.")
