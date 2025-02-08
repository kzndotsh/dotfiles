from PIL import Image
import os

# Define your source and destination folders
source_folder = "."
vertical_folder = "vertical"
horizontal_folder = "horizontal"

# Create the destination folders if they don't exist
os.makedirs(vertical_folder, exist_ok=True)
os.makedirs(horizontal_folder, exist_ok=True)

# Loop through all files in the source folder
for filename in os.listdir(source_folder):
    if filename.endswith((".jpg", ".jpeg", ".png", ".gif", ".webp")):
        # Open the image
        with Image.open(os.path.join(source_folder, filename)) as img:
            # Check the orientation of the image
            width, height = img.size
            if width > height:
                # Horizontal image
                destination_path = os.path.join(horizontal_folder, filename)
            else:
                # Vertical image
                destination_path = os.path.join(vertical_folder, filename)
            
            # Move the image to the appropriate folder
            os.rename(os.path.join(source_folder, filename), destination_path)

print("Images organized by orientation.")
