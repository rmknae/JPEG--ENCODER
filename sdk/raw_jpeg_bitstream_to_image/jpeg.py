from PIL import Image, ImageFile
from io import BytesIO
import os, sys

# Allow loading truncated images
ImageFile.LOAD_TRUNCATED_IMAGES = True  

# -----------------------------
# Project folders
# -----------------------------
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
header_folder = os.path.join(project_root, "Headers")
output_folder = os.path.join(project_root, "output_images")
os.makedirs(output_folder, exist_ok=True)

bitstream_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "bitstream_output.txt")
if not os.path.exists(bitstream_file):
    print(f" Bitstream file not found at {bitstream_file}")
    exit(1)

# -----------------------------
# Step 1: Custom header only
# -----------------------------
def patch_header_bytes(template_bytes, new_width, new_height):
    sof_index = template_bytes.find(b'\xFF\xC0')
    if sof_index == -1:
        raise ValueError("SOF0 marker not found in header.")
    offset = sof_index + 5
    template_bytes[offset:offset+2] = new_height.to_bytes(2, byteorder='big')
    template_bytes[offset+2:offset+4] = new_width.to_bytes(2, byteorder='big')
    return template_bytes

# ✅ Expect width, height, original name
if len(sys.argv) < 4:
    print("Usage: python jpeg.py <width> <height> <original_name>")
    exit(1)

new_width = int(sys.argv[1])
new_height = int(sys.argv[2])
original_base = os.path.splitext(os.path.basename(sys.argv[3]))[0]

# Use first available header as template
header_files = sorted([f for f in os.listdir(header_folder) if f.endswith(".bin")])
if not header_files:
    print(" No template headers available for custom patching!")
    exit(1)

header_path = os.path.join(header_folder, header_files[0])
with open(header_path, "rb") as f:
    header_bytes = bytearray(f.read())

header_bytes = patch_header_bytes(header_bytes, new_width, new_height)
print(f"\n ✅ Patched header for {new_width}x{new_height}")

# -----------------------------
# Step 2: Read hex bitstream
# -----------------------------
bit_bytes = bytearray()
with open(bitstream_file, "r") as f:
    for line in f:
        line = line.strip()
        if line:
            bit_bytes += bytes.fromhex(line)

# -----------------------------
# Step 3: Combine header + bitstream
# -----------------------------
jpeg_bytes = header_bytes + bit_bytes
if not jpeg_bytes.endswith(b'\xFF\xD9'):
    jpeg_bytes += b'\xFF\xD9'

# -----------------------------
# Step 4: Load image from memory
# -----------------------------
img = Image.open(BytesIO(jpeg_bytes))

# -----------------------------
# Step 5: Save final output
# -----------------------------
output_file = os.path.join(output_folder, f"{original_base}_compressed.jpg")

# ✅ Apply hidden quality factor
_hidden_quality = 30
img.save(output_file, quality=_hidden_quality)

print(f"\n JPEG image saved at {output_file}")
