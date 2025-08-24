from PIL import Image
import numpy as np
import os
import glob

# Get the project root (folder where this script's parent is)
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Path to rtl folder
rtl_path = os.path.join(project_root, "rtl")

# Ensure rtl exists
os.makedirs(rtl_path, exist_ok=True)

# Output file path
output_file = os.path.join(rtl_path, "pixel_data.txt")

# Folder where this script is located
script_dir = os.path.dirname(os.path.abspath(__file__))

# Find images inside script folder
image_files = glob.glob(os.path.join(script_dir, "*.jpg")) \
            + glob.glob(os.path.join(script_dir, "*.png")) \
            + glob.glob(os.path.join(script_dir, "*.bmp"))

if not image_files:
    print("❌ No image files found in this folder!")
    exit(1)

print("\nAvailable images in script folder:")
for i, img in enumerate(image_files, 1):
    print(f"  {i}. {os.path.basename(img)}")  # show only filename

# Ask user to pick one
choice = input("\nEnter image filename (or number): ").strip()

if choice.isdigit():
    image_name = image_files[int(choice) - 1]  # full path
else:
    # user typed a filename, build full path
    image_name = os.path.join(script_dir, choice)

# Read the image
img = Image.open(image_name).convert("RGB")

# Convert to NumPy array and BGR order
imgBGR = np.array(img)[:, :, ::-1]  # swap R<->B to make BGR

h, w, _ = imgBGR.shape
block_size = 8

# Count total number of 8x8 blocks
total_blocks = ((h + block_size - 1) // block_size) * ((w + block_size - 1) // block_size)
block_count = 0

with open(output_file, "w") as f:
    # Loop over blocks
    for by in range(0, h, block_size):
        for bx in range(0, w, block_size):
            block_count += 1
            is_last_block = (block_count == total_blocks)

            # Extract current block
            block = imgBGR[by:by+block_size, bx:bx+block_size, :]

            # Pad to 8x8 if needed
            padded_block = np.zeros((block_size, block_size, 3), dtype=np.uint8)
            padded_block[:block.shape[0], :block.shape[1], :] = block

            # Flatten block row-major
            pixels = padded_block.reshape(-1, 3)

            # If last block, assert EOF signal first
            if is_last_block:
                f.write("end_of_file_signal <= 1'b1;\n")

            # Write 64 pixels
            for (B, G, R) in pixels:
                binStr = f"{B:08b}{G:08b}{R:08b}"  # BGR order
                f.write(f"\tdata_in <= 24'b{binStr};\n#10000;\n")

            # After block trailer, only if not last block
            if not is_last_block:
                f.write("#130000;\n")
                f.write("enable <= 1'b0;\n")
                f.write("#10000;\n")
                f.write("enable <= 1'b1;\n")

print(f"\n✅ Pixel data written to {output_file}")
