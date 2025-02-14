import json
import os
import yaml

# Define dataset paths
json_path = "datasets/result.json"         # Your COCO-style JSON file
images_folder = "datasets/images/"           # Folder containing the images
labels_folder = "datasets/labels/"           # Folder where YOLO label files will be saved
output_yaml_path = "datasets/dataset.yaml"   # Output YAML file for YOLO

# Ensure the labels directory exists
os.makedirs(labels_folder, exist_ok=True)

# Load the JSON annotation file
with open(json_path, "r") as file:
    data = json.load(file)

# Build category mapping: map original category id to a new 0-indexed class id,
# and collect class names in sorted order by original id.
categories = data["categories"]
cat_id_to_index = {}
names = []
for i, cat in enumerate(sorted(categories, key=lambda c: c["id"])):
    cat_id_to_index[cat["id"]] = i
    names.append(cat["name"])

# Create a dictionary to store YOLO label lines for each image
labels_by_image = {}

# Process each annotation and convert bounding boxes
for annotation in data["annotations"]:
    image_id = annotation["image_id"]
    category_id = annotation["category_id"]
    bbox = annotation["bbox"]  # COCO format: [x_min, y_min, width, height]

    # Find corresponding image details by image_id
    img_info = next((img for img in data["images"] if img["id"] == image_id), None)
    if img_info is None:
        continue  # Skip if image info is not found
    img_w, img_h = img_info["width"], img_info["height"]

    # Get the image's filename and derive its base name (without extension)
    image_filename = img_info["file_name"]  # e.g., "images/4a15e83b-frame_006281.jpg"
    base_name = os.path.splitext(os.path.basename(image_filename))[0]  # e.g., "4a15e83b-frame_006281"

    # Convert the COCO bounding box to YOLO format:
    # Calculate x_center, y_center, normalized width and height.
    x_min, y_min, box_w, box_h = bbox
    x_center = (x_min + box_w / 2) / img_w
    y_center = (y_min + box_h / 2) / img_h
    w_norm = box_w / img_w
    h_norm = box_h / img_h

    # Create the YOLO label line: class_index x_center y_center width height
    line = f"{cat_id_to_index[category_id]} {x_center:.6f} {y_center:.6f} {w_norm:.6f} {h_norm:.6f}"

    # Accumulate the line in a dictionary keyed by the image's base filename
    if base_name not in labels_by_image:
        labels_by_image[base_name] = []
    labels_by_image[base_name].append(line)

# Write one label file per image using the image's base filename
for base_name, lines in labels_by_image.items():
    label_file = os.path.join(labels_folder, f"{base_name}.txt")
    with open(label_file, "w") as f:
        f.write("\n".join(lines))

# Create the dataset.yaml file for YOLO training
dataset_yaml = {
    "path": "datasets",     # Root folder; YOLO expects images in datasets/images and labels in datasets/labels
    "train": "images",      # Training images folder (relative to 'path')
    "val": "images",        # Validation images folder (if using the same images)
    "nc": len(names),       # Number of classes
    "names": names          # List of class names
}

with open(output_yaml_path, "w") as file:
    yaml.dump(dataset_yaml, file, default_flow_style=False)

print("✅ Conversion complete!")
print(f"YOLO labels saved in: {labels_folder}")
print(f"Dataset YAML saved as: {output_yaml_path}")
