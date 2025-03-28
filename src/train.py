import os
import yaml
import urllib.request
import tempfile
from ultralytics import YOLO

# Define the correct model filename
model_filename = "yolo11n.pt"

# Check if the model file exists; if not, download it.
if not os.path.exists(model_filename):
    print(f"Model file '{model_filename}' not found. Downloading pretrained model...")
    url = "https://github.com/ultralytics/assets/releases/download/v8.3.0/yolo11n.pt"
    try:
        urllib.request.urlretrieve(url, model_filename)
        print("Download complete.")
    except Exception as e:
        print(f"Failed to download the model: {e}")
        exit(1)

# Construct the full path to the dataset YAML.
# Assuming the current working directory is /app/src, the YAML should be at /app/src/datasets/dataset.yaml.
DATASET_PATH = os.path.join(os.getcwd(), "datasets", "dataset.yaml")
if not os.path.exists(DATASET_PATH):
    raise FileNotFoundError(f"dataset.yaml not found at {DATASET_PATH}")

# Load and validate the dataset configuration
with open(DATASET_PATH, "r") as file:
    dataset_config = yaml.safe_load(file)
    if 'names' not in dataset_config:
        raise ValueError("Invalid dataset.yaml format: missing 'names' key")

# Override the 'path' field in the dataset configuration.
# Since dataset.yaml is in /app/src/datasets and images are in /app/src/datasets/images,
# setting "path": "." tells YOLO to look in the current directory (i.e. /app/src/datasets).
dataset_config["path"] = "."

# Write the updated dataset configuration to a temporary YAML file.
with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".yaml") as tmp_file:
    yaml.dump(dataset_config, tmp_file, default_flow_style=False)
    temp_dataset_path = tmp_file.name

print(f"Using updated dataset configuration from: {temp_dataset_path}")

# Initialize the YOLO model using the pretrained file.
model = YOLO(model_filename)

# Start training using the updated dataset configuration.
model.train(
    data=temp_dataset_path,
    epochs=200,
    imgsz=640,
    batch=32,
    workers=4,
    device=0  # Using GPU device 0
)

print("✅ Training complete!")
