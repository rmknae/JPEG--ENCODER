# Converts JPEG bitstream from simulation to an actual JPEG image using a header file
# Saves compressed version and upscales back to the original test.jpg size

from PIL import Image, ImageFile
import io
import os
import sys

ImageFile.LOAD_TRUNCATED_IMAGES = True  # allow loading incomplete JPEGs

# -------------------------
# Paths (portable)
# -------------------------
<<<<<<< HEAD
script_dir = os.path.dirname(os.path.abspath(__file__))        # folder where this script lives
rtl_dir = os.path.join(os.path.dirname(script_dir), 'rtl')    # rtl folder at same level as script folder
header_file = os.path.join(script_dir, 'header.bin')          # JPEG header
hex_file = os.path.join(rtl_dir, 'jpeg_output.hex')           # simulation hex in rtl folder
compressed_jpg = os.path.join(script_dir, 'output.jpg')       # compressed output
upscaled_jpg = os.path.join(script_dir, 'output_upscaled.jpg')# upscaled output
original_image = os.path.join(script_dir, 'test.jpg')         # original input image
=======
script_dir = os.path.dirname(os.path.abspath(__file__))  # folder where this script lives
header_file = os.path.join(script_dir, 'header.bin')    # JPEG header in same folder

# Accept hex_file and output paths from command-line arguments
if len(sys.argv) < 3:
    print("Usage: python for_all_hex_to_jpg.py <hex_file> <output_jpg>")
    sys.exit(1)

hex_file = sys.argv[1]
compressed_jpg = sys.argv[2]

# Optional upscaled output
upscaled_jpg = os.path.splitext(compressed_jpg)[0] + "_upscaled.jpg"
>>>>>>> 7c836686dfa8ecad753f06cc324096d5c0be7dc6

# -------------------------
# Step 1: Read the header
# -------------------------
if not os.path.exists(header_file):
    print(f"❌ ERROR: header file not found: {header_file}")
    sys.exit(1)

with open(header_file, 'rb') as f:
    header = f.read()

# -------------------------
# Step 2: Read the hex bitstream and convert to bytes
# -------------------------
if not os.path.exists(hex_file):
    print(f"❌ ERROR: hex file not found: {hex_file}")
    sys.exit(1)

<<<<<<< HEAD
bitstream_bytes = bytearray()
=======
if not os.path.exists(hex_file):
    print(f"❌ ERROR: hex file not found: {hex_file}")
    sys.exit(1)

>>>>>>> 7c836686dfa8ecad753f06cc324096d5c0be7dc6
with open(hex_file, 'r') as f:
    for line in f:
        line = line.strip()
        if line == '':
            continue
        val = int(line, 16)
        bytes_chunk = val.to_bytes(4, byteorder='big')  # 32-bit → 4 bytes
        bitstream_bytes.extend(bytes_chunk)

# -------------------------
# Step 3: Combine header + bitstream
# -------------------------
jpeg_data = header + bitstream_bytes

# -------------------------
# Step 4: Open from memory and save compressed version
# -------------------------
try:
    img = Image.open(io.BytesIO(jpeg_data))

    # Save compressed 96x96 version
    img.save(
        compressed_jpg,
        "JPEG",
        quality=40,
        optimize=True,
        progressive=True
    )
    print(f"📉 Compressed JPEG saved: {compressed_jpg}")

    # -------------------------
    # Step 5: Upscale back to the original test.jpg size
    # -------------------------
<<<<<<< HEAD
    if not os.path.exists(original_image):
        print(f"⚠️ Original image not found: {original_image}")
        original_size = (640, 480)  # fallback size
    else:
        with Image.open(original_image) as orig:
            original_size = orig.size  # get width and height from test.jpg

=======
    original_size = (640, 480)  # 👈 replace with your real original image size
>>>>>>> 7c836686dfa8ecad753f06cc324096d5c0be7dc6
    img_up = img.resize(original_size, Image.LANCZOS)
    img_up.save(
        upscaled_jpg,
        "JPEG",
        quality=40,
        optimize=True,
        progressive=True
    )
    print(f"📈 Upscaled JPEG saved: {upscaled_jpg} ({original_size[0]}x{original_size[1]})")

except Exception as e:
    print("⚠️ Could not recompress JPEG:", e)
