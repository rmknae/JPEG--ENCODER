# JPEG-Based Lossy Image Compression System

**Hardware JPEG Encoder (SystemVerilog Implementation)**
*A real-time, low-power RGB → JPEG bitstream converter for embedded systems*

-----

**Last updated:** August 23, 2025
© 2025 **Maktab-e-Digital Systems Lahore**. Licensed under the [Apache 2.0 License](https://www.google.com/search?q=LICENSE).

-----

# User Guide

Welcome to the **JPEG Encoder** project\! This tool allows you to convert **raw RGB images into JPEG compressed format** using a **hardware-based encoder implemented in SystemVerilog**.

## Requirements

Before you begin, ensure you have the following software installed on your machine.

  * **HDL Simulator:** QuestaSim is the recommended simulator.
  * **Python 3.8+:** You can download the latest version from the official Python website. During installation, be sure to check the box to "Add Python to PATH".
                                     ``` python --version ```

  * **Python Libraries:** The project requires `Pillow` and `NumPy` for image handling and data processing. Install them using the command below:

<!-- end list -->

```bash
pip install pillow numpy
```
If your system uses python3, run:
```bash
python -m pip install pillow numpy
```
To verify if downloaded:
```bash
pip show pillow
pip show numpy
```
## Getting Started

Follow these steps to set up and run the JPEG encoder.

#### Step 1: Clone the Repository

Open your Command Prompt (Windows) or Terminal (Linux/Mac) and run the following commands:

```bash
git clone https://github.com/rmknae/JPEG--ENCODER.git
cd JPEG--ENCODER
```

#### Step 2: Place Input Image

Place your test image inside the `script/` folder. The workflow supports common formats such as `.jpg`, `.png`, and `.jpeg`.

#### Step 3: Run Simulation
***Click on the run.bat file simply.***

The `run.bat` file automates all the necessary steps for a full simulation and image generation. 
1. This script prompts the user to `select an image (1, 2, or 3)` from the script/ directory which you placed for compression.
2. After the image is chosen, it asks for the resolution for the JPEG header. You must enter the exact dimensions of the image you selected for the script to function correctly.

> **For Windows:**
> Simply double-click `run.bat`.
> **For Linux/Mac:**
> The `.bat` file is Windows-only, but you can achieve the same result by running the commands directly in your terminal. For example:

> ```bash
> python data_in.py
> vlog ./src/*.sv ./testbench/*.sv
> vsim -c -do "run -all; quit" tb_top
> python script/raw_jpeg_bitstream_to_image/jpeg.py
> ```
> You can also create your own `run_sim.sh` shell script to automate this.

#### Step 4: Output

The final JPEG image will be saved to a new folder named `output_images/`.

### Troubleshooting

| Problem | Solution |
| :--- | :--- |
| Python cannot find **Pillow** or **NumPy** | Run `pip install pillow numpy` in your Windows Command Prompt to install the libraries. |
| **`vsim` not found** | Add the QuestaSim installation folder (`win64`) to your Windows `PATH` environment variable. |
| **Paths with spaces** fail | Always wrap paths in quotes: `"C:\Users\HH Traders\Documents\JPEG--ENCODER"` |
| CMD closes immediately | Run `run.bat` from an already open Command Prompt window to keep error messages visible. |

> **Important:** Always run from a native Windows path. Avoid using `\\wsl.localhost\...` or any WSL paths, as they can cause compatibility issues.

-----

### Useful Links

  * [JPEG Standard Overview](https://en.wikipedia.org/wiki/JPEG)
  * [SystemVerilog Basics](https://www.chipverify.com/systemverilog/systemverilog-introduction)
  * [Python Pillow (PIL)](https://pillow.readthedocs.io/en/stable/)

-----

### Contribution

We welcome contributions\!

  * Report issues in the [Issues tab](https://github.com/rmknae/JPEG--ENCODER/issues)
  * Submit PRs with improvements or bug fixes

-----

### Documentation

[DOCUMENTATION](https://meds-jpeg-docs.readthedocs.io/en/latest/?badge=latest)

-----

---
> **Disclaimer:** This project is inspired by and makes reference to the [oc_jpegencode](https://github.com/chiggs/oc_jpegencode) repository. I have studied its implementation to understand JPEG encoding and have adapted certain  where applicable.

---

### Licensing

Licensed under the **Apache License 2.0**
Copyright © 2025
**[Maktab-e-Digital Systems Lahore](https://github.com/meds-uet)**
