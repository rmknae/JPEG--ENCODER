from PIL import Image, ImageFile
from io import BytesIO
import os

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
# Step 1: List headers
# -----------------------------
header_files = sorted([f for f in os.listdir(header_folder) if f.endswith(".bin")])
print("\n Available headers:")
for i, f in enumerate(header_files, 1):
    print(f"  {i}. {f}")

choice = input("\nEnter header filename, number, or type 'custom' for a new header: (The image which you placed in the script folder open it and in the bottom left side of it the resolution will be written as __x__ if any above size match write that otherwise, write custom)").strip()

# -----------------------------
# Step 2: Handle custom header
# -----------------------------
def patch_header_bytes(template_bytes, new_width, new_height):
    sof_index = template_bytes.find(b'\xFF\xC0')
    if sof_index == -1:
        raise ValueError("SOF0 marker not found in header.")
    offset = sof_index + 5
    template_bytes[offset:offset+2] = new_height.to_bytes(2, byteorder='big')
    template_bytes[offset+2:offset+4] = new_width.to_bytes(2, byteorder='big')
    return template_bytes

if choice.lower() == 'custom':
    size_input = input("Enter new size (WIDTHxHEIGHT, e.g., 1920x1080): ")
    try:
        new_width, new_height = map(int, size_input.lower().split('x'))
    except:
        print(" Invalid format!")
        exit(1)
    # Use first available header as template
    if not header_files:
        print(" No template headers available for custom patching!")
        exit(1)
    header_path = os.path.join(header_folder, header_files[0])
    with open(header_path, "rb") as f:
        header_bytes = bytearray(f.read())
    header_bytes = patch_header_bytes(header_bytes, new_width, new_height)
    header_file = f"custom_{new_width}x{new_height}.bin"
    print(f"\n Custom header generated in memory: {header_file}")

# -----------------------------
# Step 3: Use existing header
# -----------------------------
else:
    if choice.isdigit():
        idx = int(choice) - 1
        if 0 <= idx < len(header_files):
            header_file = header_files[idx]
        else:
            print(" Invalid number!")
            exit(1)
    elif choice in header_files:
        header_file = choice
    else:
        print("Header not found!")
        exit(1)
    header_path = os.path.join(header_folder, header_file)
    with open(header_path, "rb") as f:
        header_bytes = bytearray(f.read())
    print(f"\n Using header: {header_file}")

# -----------------------------
# Step 4: Read hex bitstream
# -----------------------------
bit_bytes = bytearray()
with open(bitstream_file, "r") as f:
    for line in f:
        line = line.strip()
        if line:
            bit_bytes += bytes.fromhex(line)

# -----------------------------
# Step 5: Combine header + bitstream
# -----------------------------
jpeg_bytes = header_bytes + bit_bytes
if not jpeg_bytes.endswith(b'\xFF\xD9'):
    jpeg_bytes += b'\xFF\xD9'

# -----------------------------
# Step 6: Load image from memory
# -----------------------------
img = Image.open(BytesIO(jpeg_bytes))

# -----------------------------
# Step 7: Save final output
# -----------------------------
output_file = os.path.join(
    output_folder,
    f"reconstructed_{os.path.splitext(header_file)[0]}.jpg"
)
img.save(output_file, quality=30)
print(f"\n JPEG image saved at {output_file}")
