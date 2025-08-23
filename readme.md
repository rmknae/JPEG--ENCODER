# JPEG-Based Lossy Image Compression System

**Hardware JPEG Encoder (SystemVerilog Implementation)**
*A real-time, low-power RGB → JPEG bitstream converter for embedded systems*

**Last updated:** August 23, 2025
© 2025 **Maktab-e-Digital Systems Lahore**. Licensed under the [Apache 2.0 License](LICENSE).

---

## User Guide

Welcome to the **JPEG Encoder** project!
This tool allows you to convert **raw RGB images into JPEG compressed format** using a **hardware-based encoder implemented in SystemVerilog**.

---

## Features

* Converts **RGB images → YCbCr → DCT → Quantization → Huffman Encoding → JPEG Bitstream**
* Modular design in **SystemVerilog/Verilog**
* **SystemVerilog testbenches** for simulation and validation
* Works with **QuestaSim** and other HDL simulators
* Includes a **batch file (`.bat`)** for running automated simulations on Windows
* For **Linux/Mac**, the same commands inside the `.bat` file can be run directly in the terminal
* Provides **Python utilities**:
  * Convert input images into pixel **RGB data** for simulation
  * Reconstruct **JPEG images from generated hex bitstream**

---

## Requirements

Before using, make sure you have:

* **HDL Simulator**: [QuestaSim](https://eda.sw.siemens.com/en-US/ic/questa/)
* **Python 3.8+** → [Download](https://www.python.org/downloads/)
* **Pillow (PIL)** for image handling → Install with:

  ```bash
  pip install pillow
  ```

---

## How to Run

### 1. Clone the Repository

```bash
git clone https://github.com/rmknae/JPEG--ENCODER.git
cd JPEG--ENCODER
```

### 2. Place Input Image

* Put your **test image** inside the `testimage/` folder.
* Supported formats: `.jpg`, `.png`, `.jpeg`.

> **Headers & Selection**
> During simulation, the encoder reads image **headers (size, format, pixel depth)** and selects the proper quantization and Huffman tables automatically.
> This ensures compatibility with baseline JPEG compression.
> ## Supported Image Sizes  (These headers are available in Headers folder)

> <div align="center">
 
> | Resolution   | Standard  |
> |--------------|-----------|
> | 1920 × 1080  | Full HD   |
> | 1280 × 720   | HD        |
> | 1024 × 768   | XGA       |
> | 800 × 600    | SVGA      |
> | 96 × 96      | Icon/Test |

> </div>

---

> ## Custom Resolution via `header.bin` (SOF0)  

> If you need a resolution not listed above, you can edit the static JPEG header file:  

> 1. Open **`header.bin`** in a hex editor → [hexed.it](https://hexed.it)  
> 2. Locate the **SOF0 (Start of Frame, Baseline DCT)** marker:  

> <div align="center">
> FF C0 00 11 08 HH HH WW WW ...
> </div>

> **Breakdown:**  
> - `FF C0` → SOF0 marker  
> - `00 11` → Segment length (17 bytes)  
> - `08` → Precision (8 bits)  
> - Next **2 bytes** → Height (big-endian)  
> - Next **2 bytes** → Width (big-endian)  

> 3. Convert your target resolution into **hex (big-endian)**: 
> 4. Overwrite the **[HH HH] [WW WW]** bytes with new height and width.  
> 5. Save the file and rerun the simulation.  

---

> ## Quick Reference (Common Sizes)  

> <div align="center">
 
> | Resolution  | Height (dec) | Height (hex) | Width (dec) | Width (hex) |
> |-------------|--------------|--------------|-------------|-------------|
> | 3840×2160   | 2160         | 08 70        | 3840        | 0F 00       | *(4K UHD)*  
> | 2560×1440   | 1440         | 05 A0        | 2560        | 0A 00       | *(QHD / 2K)*  
> | 1600×1200   | 1200         | 04 B0        | 1600        | 06 40       | *(UXGA)*  
> | 1280×1024   | 1024         | 04 00        | 1280        | 05 00       | *(SXGA)*  
> | 1366×768    | 768          | 03 00        | 1366        | 05 56       | *(HD+)*  
> | 320×240     | 240          | 00 F0        | 320         | 01 40       | *(QVGA)*  
> | 160×120     | 120          | 00 78        | 160         | 00 A0       | *(QQVGA)*  

> </div>

---

### 3. Run Simulation

#### Windows

If you’re on Windows, just double-click:

```bash
run.bat
```

This will do everything on its own.

#### Linux/Mac

Since `.bat` is Windows-only, copy the commands from `run.bat` and run them in the terminal, e.g.:

```bash
vlog ./src/*.sv ./testbench/*.sv
vsim -c -do "run -all; quit" tb_top
```

You can also create your own `run_sim.sh` shell script.

---

### 4. Output JPEG

* The final JPEG will be stored in a new folder:

```
output_image/
```

---

## Useful Links

* [JPEG Standard Overview](https://en.wikipedia.org/wiki/JPEG)
* [SystemVerilog Basics](https://www.chipverify.com/systemverilog/systemverilog-introduction)
* [Python Pillow (PIL)](https://pillow.readthedocs.io/en/stable/)

---

## Contribution

We welcome contributions!

* Report issues in the [Issues tab](https://github.com/rmknae/JPEG--ENCODER/issues)
* Submit PRs with improvements or bug fixes

---

## License

Licensed under the **Apache License 2.0**
© 2025 Maktab-e-Digital Systems Lahore

---
