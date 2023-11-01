import os
import re
import shutil

# Define the directory to search
search_directory = '/dir'

# Define the keyword to filter files/folders
keyword = 'keyword'

# Define the destination directory for the links
destination_directory = '/dest'

# Regular expression pattern to match the keyword in filenames or folder names
escaped_keyword = re.escape(keyword)
pattern = re.compile('.*{}.*'.format(escaped_keyword))

# Function to create a symlink or hard link based on the file type
def create_link(source_path, dest_path):
    if os.path.isfile(source_path):
        os.symlink(source_path, dest_path)  # Create a symlink
    # else:
        # os.link(source_path, dest_path)  # Create a hard link

# Walk through the directory and its subdirectories
for root, dirs, files in os.walk(search_directory):
    for name in dirs + files:
        full_path = os.path.join(root, name)
        if pattern.match(name):
            dest_path = os.path.join(destination_directory, name)
            create_link(full_path, dest_path)
