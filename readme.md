# JPEG-Based Lossy Image Compression System

> **Hardware JPEG Encoder (SystemVerilog Implementation)**
> Real-time, low-power RGB to JPEG bitstream converter for embedded systems
>
> 🗕️ *Last updated: July 30, 2025*
> © 2025 [Maktab-e-Digital Systems Lahore](https://github.com/meds-uet). Licensed under the Apache 2.0 License.

---

## Features

This project implements a full JPEG compression pipeline using modern SystemVerilog constructs:

- `logic` data type
- Color space transformation (RGB to YCbCr)
- 2D Discrete Cosine Transform (DCT) for Y, Cb, Cr
- Fixed-point quantization with precomputed reciprocals
- Huffman encoding for each 8×8 block
- FF byte-stuffing and bitstream output

---

## Documentation

[![Documentation Status](https://meds-jpeg-docs.readthedocs.io/en/badge/?version=latest)](https://meds-jpeg-docs.readthedocs.io/en/latest/?badge=latest)

---

##  Licensing

Licensed under the **Apache License 2.0**
Copyright © 2025
**[Maktab-e-Digital Systems Lahore](https://github.com/meds-uet)**

---
