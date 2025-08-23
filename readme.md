# JPEG-Based Lossy Image Compression System

> **Hardware JPEG Encoder (SystemVerilog Implementation)**
> Real-time, low-power RGB to JPEG bitstream converter for embedded systems
>
> 🗕️ *Last updated: July 30, 2025*
> © 2025 [Maktab-e-Digital Systems Lahore](https://github.com/meds-uet). Licensed under the Apache 2.0 License.

---
# User Guide

Welcome to the **JPEG Encoder** project!
This tool allows you to **convert raw RGB images into JPEG compressed format** using a hardware-based encoder implemented in **SystemVerilog**.

---

## Features

* Converts **RGB images → YCbCr → DCT → Quantization → Huffman Encoding → JPEG Bitstream**
* Modular design in **SystemVerilog/Verilog**
* SystemVerilog testbenches for simulation and validation
* Works with **QuestaSim other HDL simulators**
* Includes a **batch file (`.bat`)** for running automated simulations
* Provides **Python utilities**:
  - Convert input images into pixel RGB data for simulation
  - Reconstruct JPEG images from generated hex bitstream

---

## Requirements

Before using, make sure you have:

* **HDL Simulator**: [QuestaSim](https://eda.sw.siemens.com/en-US/ic/questa/) or [Vivado](https://www.xilinx.com/products/design-tools/vivado.html)
* **Python 3.8+** (for validation & JPEG reconstruction) → [Download](https://www.python.org/downloads/)
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
### 3. Place the desired image in the testimage folder.
 /////////// tell about headers and selectionn here////////////////

### 4. Run with `.bat` File (Windows)

If you’re on **Windows**, simply double-click:

```
run_simulation.bat
```

This will **compile + simulate** the encoder.


### 5. Converted JPEG image in Output image folder


///// Make a new folder///////////////////////////

---

## 📂 Useful Links

* 📘 [JPEG Standard Overview](https://en.wikipedia.org/wiki/JPEG)
* 📗 [SystemVerilog Basics](https://www.chipverify.com/systemverilog/systemverilog-introduction)
* 🖼️ [Python Pillow (PIL)](https://pillow.readthedocs.io/en/stable/)

---

## 🤝 Contribution

We welcome contributions!

* Report issues in the [Issues tab](https://github.com/rmknae/JPEG--ENCODER/issues)
* Submit PRs with improvements or bug fixes

---

## Documentation Detailed

[![Documentation Status](https://meds-jpeg-docs.readthedocs.io/en/badge/?version=latest)](https://meds-jpeg-docs.readthedocs.io/en/latest/?badge=latest)

---

##  Licensing

Licensed under the **Apache License 2.0**
Copyright © 2025
**[Maktab-e-Digital Systems Lahore](https://github.com/meds-uet)**

---
