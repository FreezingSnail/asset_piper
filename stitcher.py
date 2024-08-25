import os
import re
from PIL import Image
from collections import defaultdict

def join_files_with_same_ending_number(input_dir, output_dir):
    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)

    # Group files by their ending number
    file_groups = defaultdict(list)
    for filename in os.listdir(input_dir):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp')):
            match = re.search(r'(\d+)\.[\w]+$', filename)
            if match:
                ending_number = match.group(1)
                file_groups[ending_number].append(os.path.join(input_dir, filename))

    # Process each group
    for ending_number, file_list in file_groups.items():
        if len(file_list) > 1:
            # Sort files to ensure consistent order
            file_list.sort()
            
            # Open all images in the group
            images = [Image.open(f) for f in file_list]
            
            # Calculate dimensions for the stitched image
            max_width = max(img.width for img in images)
            total_height = sum(img.height for img in images)
            
            # Create a new image with the calculated dimensions
            stitched_image = Image.new('RGB', (max_width, total_height))
            
            # Paste all images into the new image vertically
            y_offset = 0
            for img in images:
                # Center the image horizontally if it's narrower than the stitched image
                x_offset = (max_width - img.width) // 2
                stitched_image.paste(img, (x_offset, y_offset))
                y_offset += img.height
            
            # Save the stitched image
            output_filename = f"stitched_{ending_number}.png"
            output_path = os.path.join(output_dir, output_filename)
            stitched_image.save(output_path)
            print(f"Stitched image saved to {output_path}")
        else:
            print(f"Only one or no file found for ending number {ending_number}. Skipping.")



def stitch_images_in_directory(input_dir, output_path):
    print(f"Stitching images in directory: {input_dir}")
    # Get all image files in the input directory (not including subdirectories)
    image_files = []
    for file in os.listdir(input_dir):
        if file.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp')):
            image_files.append(os.path.join(input_dir, file))
    
    if not image_files:
        print("No image files found in the specified directory.")
        return
    
    # Open all images
    images = [Image.open(f) for f in image_files]
    
    # Calculate the total width and maximum height
    total_width = sum(img.width for img in images)
    max_height = max(img.height for img in images)
    
    # Create a new image with the calculated dimensions
    stitched_image = Image.new('RGB', (total_width, max_height))
    
    # Paste all images into the new image
    x_offset = 0
    for img in images:
        stitched_image.paste(img, (x_offset, 0))
        x_offset += img.width

    # trim dir so only the last part remains
    output_path = output_path + input_dir.split('/')[-2]+ '.png'
    # Save the stitched image
    print(f"Saving stitched image to {output_path}")
    stitched_image.save(output_path)


def get_subdirectories(directory):
    all_entries = [os.path.join(directory, entry) for entry in os.listdir(directory)]
    return [entry for entry in all_entries if os.path.isdir(entry)]
        




dirs = get_subdirectories('out/')
for d in dirs:
    stitch_images_in_directory(d+"/", 'tmp/')

join_files_with_same_ending_number('tmp/', 'stiched/')