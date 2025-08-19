from PIL import Image
import numpy as np

# Load image (ensure 1080x1920 or any size)
img = Image.open("test.jpg").convert("RGB")

# Convert to NumPy array and BGR
imgBGR = np.array(img)[:, :, ::-1]   # swap RGB -> BGR
h, w, _ = imgBGR.shape

block_size = 8  # 8x8 block size

# Open output file
with open("pixel_data.txt", "w") as f:

    # Go through 8x8 blocks
    for by in range(0, h, block_size):
        for bx in range(0, w, block_size):

            # Handle edge cases (if h or w not multiple of 8)
            y_end = min(by + block_size, h)
            x_end = min(bx + block_size, w)

            block = imgBGR[by:y_end, bx:x_end, :]

            # Pad to 8x8 if smaller at edges
            padded_block = np.zeros((block_size, block_size, 3), dtype=np.uint8)
            padded_block[:block.shape[0], :block.shape[1], :] = block

            # Flatten block (row-major, left→right, top→down)
            pixels = padded_block.transpose(1, 0, 2).reshape(-1, 3)

            # Loop through 64 pixels
            for (B, G, R) in pixels:
                Rbin = format(R, "08b")
                Gbin = format(G, "08b")
                Bbin = format(B, "08b")

                # Choose BGR (or RGB if needed)
                binStr = f"{Bbin}{Gbin}{Rbin}"   # BGR order
                # binStr = f"{Rbin}{Gbin}{Bbin}" # RGB order

                # Write pixel line
                f.write(f"\tdata_in <= 24'b{binStr};\n#10000;\n")

            # After finishing one 8x8 block, add control sequence
            f.write("#130000;\n")
            f.write("enable <= 1'b0;\n")
            f.write("#10000;\n")
            f.write("enable <= 1'b1;\n")

print("✅ Pixel data written to pixel_data.txt (supports any size, 8x8 block order with enable control)")
