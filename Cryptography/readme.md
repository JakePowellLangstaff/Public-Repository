# Crypto Performance Tester

A Python script that compares the speed of different encryption and digital signature algorithms using the `cryptography` library.

It measures how long it takes to:

* Generate keys
* Encrypt and decrypt data
* Sign and verify messages

Across multiple cryptographic systems.

---

## What It Tests

### RSA

* Key generation
* Encryption / decryption (with chunking for large data)
* Signing and verification

### DSA

* Key generation
* Signing and verification

### ECC (Elliptic Curve)

* Key generation
* Signing and verification using ECDSA

---

## Features

* Real-time performance timing using `time.perf_counter()`
* Custom RSA key size and exponent input
* Custom DSA key size (with safety limit)
* Choice of ECC curve
* Uses random test data (no real files needed)

---

## Requirements

Install dependencies:

```bash id="crypto01"
pip install cryptography
```

---

## How to Run

```bash id="crypto02"
python your_script_name.py
```

You will be prompted to enter:

* RSA public exponent (usually 65537)
* RSA key size (1024 / 2048 / 3072 / etc.)
* DSA key size (max 3072)
* ECC curve (SECP256R1, SECP384R1, SECP521R1, etc.)

---

## Example Output

* RSA Key Generation Time
* RSA Encryption / Decryption Time
* RSA Sign / Verify Time
* DSA Sign / Verify Time
* ECC Key Generation / Sign / Verify Time

---

## Notes

* This project is for **benchmarking and learning purposes**
* Results will vary depending on CPU and system load
* Larger key sizes = slower performance but higher security

---

## Disclaimer

This tool is for educational use only.
It is not intended for production cryptography decisions.
