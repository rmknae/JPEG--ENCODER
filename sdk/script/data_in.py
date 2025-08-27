from PIL import Image
import numpy as np
import os, glob, subprocess, sys

# Get project root and rtl path
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
rtl_path = os.path.join(project_root, "rtl")
os.makedirs(rtl_path, exist_ok=True)

# Folder where this script is located
script_dir = os.path.dirname(os.path.abspath(__file__))

# Find images in script folder
image_files = glob.glob(os.path.join(script_dir, "*.jpg")) \
            + glob.glob(os.path.join(script_dir, "*.png")) \
            + glob.glob(os.path.join(script_dir, "*.bmp"))

if not image_files:
    print("❌ No image files found in this folder!")
    sys.exit(1)

# Ask user choice
print("Do you want to compress (1) a single image or (2) all images?")
choice_mode = input("Enter 1 or 2: ").strip()

def process_image(image_name):
    """Generate pixel_data.txt, run QuestaSim and jpeg.py for one image"""
    output_file = os.path.join(rtl_path, "pixel_data.txt")

    # ---- Step 1: Write pixel_data.txt ----
    img = Image.open(image_name).convert("RGB")
    imgBGR = np.array(img)[:, :, ::-1]  # BGR

    h, w, _ = imgBGR.shape
    block_size = 8
    total_blocks = ((h + block_size - 1) // block_size) * ((w + block_size - 1) // block_size)
    block_count = 0

    with open(output_file, "w") as f:
        for by in range(0, h, block_size):
            for bx in range(0, w, block_size):
                block_count += 1
                is_last_block = (block_count == total_blocks)

                block = imgBGR[by:by+block_size, bx:bx+block_size, :]
                padded_block = np.zeros((block_size, block_size, 3), dtype=np.uint8)
                padded_block[:block.shape[0], :block.shape[1], :] = block

                pixels = padded_block.reshape(-1, 3)

                if is_last_block:
                    f.write("end_of_file_signal <= 1'b1;\n")

                for (B, G, R) in pixels:
                    binStr = f"{B:08b}{G:08b}{R:08b}"
                    f.write(f"\tdata_in <= 24'b{binStr};\n#10000;\n")

                if not is_last_block:
                    f.write("#130000;\n")
                    f.write("enable <= 1'b0;\n")
                    f.write("#10000;\n")
                    f.write("enable <= 1'b1;\n")

    print(f"✅ Pixel data written: {output_file}")

    # ---- Step 2: Run QuestaSim ----
    print("🔹 Running QuestaSim simulation ...")
    result = subprocess.run(["vsim", "-c", "-do", "do run.do; quit"])
    if result.returncode != 0:
        print("❌ Error in QuestaSim")
        sys.exit(1)

 # ---- Step 3: Reconstruct JPEG ----
    print("🔹 Generating JPEG image ...")
    result = subprocess.run([
        "python",
        os.path.join(project_root, "raw_jpeg_bitstream_to_image", "jpeg.py"),
        str(w), str(h), image_name   # ✅ pass original filename
    ])
    if result.returncode != 0:
        print("❌ Error in jpeg.py")
        sys.exit(1)

    print(f"✅ Finished processing {os.path.basename(image_name)}")

# ---- Main Control Flow ----
if choice_mode == "1":
    # Show available images
    print("\nAvailable images:")
    for i, img in enumerate(image_files, 1):
        print(f"  {i}. {os.path.basename(img)}")

    choice = input("\nEnter image filename (or number): ").strip()
    if choice.isdigit():
        image_name = image_files[int(choice) - 1]
    else:
        image_name = os.path.join(script_dir, choice)

    process_image(image_name)

elif choice_mode == "2":
    for img in image_files:
        print(f"\n🔹 Processing {os.path.basename(img)} ...")
        process_image(img)

else:
    print("❌ Invalid choice")
    sys.exit(1)
