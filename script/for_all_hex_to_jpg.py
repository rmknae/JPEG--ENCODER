# -*- coding: utf-8 -*-
"""
Created on Thu Aug 21 23:39:35 2025

@author: HH Traders
"""

# Converts JPEG bitstream (hex + header) to a real JPEG image
# Saves only the reconstructed image (no recompression, no hidden quality changes)

from PIL import Image, ImageFile
import io
import os
import sys

ImageFile.LOAD_TRUNCATED_IMAGES = True  # allow incomplete JPEGs

# -------------------------
# Paths (Desktop only)
# -------------------------
desktop = os.path.join(os.path.expanduser("~"), "Desktop")
header_file = os.path.join(desktop, "header.bin")     # JPEG header on Desktop
hex_file = os.path.join(desktop, "jpeg_output.hex")   # hex file on Desktop
output_jpg = os.path.join(desktop, "output.jpg")      # final reconstructed image

# -------------------------
# Step 1: Read header
# -------------------------
if not os.path.exists(header_file):
    print(f"❌ ERROR: header file not found: {header_file}")
    sys.exit(1)

with open(header_file, 'rb') as f:
    header = f.read()

# -------------------------
# Step 2: Read hex file (bitstream)
# -------------------------
if not os.path.exists(hex_file):
    print(f"❌ ERROR: hex file not found: {hex_file}")
    sys.exit(1)

bitstream_bytes = bytearray()
with open(hex_file, 'r') as f:
    for line in f:
        line = line.strip()
        if line == "":
            continue
        val = int(line, 16)
        bytes_chunk = val.to_bytes(4, byteorder="big")  # 32-bit word → 4 bytes
        bitstream_bytes.extend(bytes_chunk)

# -------------------------
# Step 3: Combine header + bitstream
# -------------------------
jpeg_data = header + bitstream_bytes

# -------------------------
# Step 4: Save reconstructed JPEG (no recompression)
# -------------------------
try:
    img = Image.open(io.BytesIO(jpeg_data))
    img.save(output_jpg, "JPEG")  # ✅ just save as-is
    print(f"✅ JPEG reconstructed and saved at: {output_jpg}")

except Exception as e:
    print("⚠️ Could not reconstruct JPEG:", e)
