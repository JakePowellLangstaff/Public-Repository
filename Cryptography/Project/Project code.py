from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding, rsa, dsa, ec
import os
import time


# Input for RSA and DSA public_exponent and key_size
print("### Configure RSA Parameters ###")
public_exponent = int(input("Enter public exponent (must be 65537 = 10kb msg): "))
key_size = int(input("Enter key size in bits (80=1024, 112=2048, 128=3072, 192=7680, 256=15360) \n : "))

# Input for DSA key size with validation (maximum 3072 bits)
print("\n### Configure DSA Key Size ###")
key_size_dsa = int(input("Enter DSA key size in bits (maximum 3072 bits) \n (80=1024, 112=2048, 128=3072) \n : "))
if key_size_dsa > 3072:
    raise ValueError("DSA key size cannot exceed 3072 bits. Please choose a smaller size.")

# Input for ECC Curve
print("\n### Configure ECC Parameters ###")
print("Available curves: SECP256R1, SECP384R1, SECP521R1")
curve_name = input("Enter ECC curve name: ").strip().upper()

# Map user input to ECC curve object
ecc_curves = {
    "SECP256R1": ec.SECP256R1(),
    "SECP384R1": ec.SECP384R1(),
    "SECP521R1": ec.SECP521R1()
}
curve = ecc_curves.get(curve_name)
if not curve:
    raise ValueError("Invalid ECC curve name. Please choose from SECP256R1, SECP384R1, or SECP521R1.")

# RSA Key Pair Generation Timing
print("\n### RSA Key Pair Generation ###")
before = time.perf_counter()
private_key_rsa = rsa.generate_private_key(
    public_exponent=public_exponent,
    key_size=key_size
)
after = time.perf_counter()
print(f"Key Generation Time: {after - before:.6f} seconds")

# RSA Encryption and Decryption Timing
print("\n### RSA Encryption and Decryption ###")
public_key_rsa = private_key_rsa.public_key()

def split_message(message, chunk_size):
    return [message[i:i+chunk_size] for i in range(0, len(message), chunk_size)]

def encrypt_message(public_key, message, chunk_size):
    encrypted_chunks = []
    for chunk in split_message(message, chunk_size):
        encrypted_chunks.append(public_key.encrypt(
            chunk,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        ))
    return encrypted_chunks

def decrypt_message(private_key, encrypted_chunks):
    decrypted_chunks = []
    for chunk in encrypted_chunks:
        decrypted_chunks.append(private_key.decrypt(
            chunk,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        ))
    return b"".join(decrypted_chunks)

long_plaintext = os.urandom(10240)  # 10 KB
before_encrypt = time.perf_counter()
long_ciphertext = encrypt_message(public_key_rsa, long_plaintext, 32)
after_encrypt = time.perf_counter()
print(f"Encryption Time: {after_encrypt - before_encrypt:.6f} seconds")

before_decrypt = time.perf_counter()
long_plaintext_2 = decrypt_message(private_key_rsa, long_ciphertext)
after_decrypt = time.perf_counter()
print(f"Decryption Time: {after_decrypt - before_decrypt:.6f} seconds")

# RSA Sign and Verify Timing
print("\n### RSA Sign and Verify ###")
message_rsa = os.urandom(2048)
before = time.perf_counter()
signature_rsa = private_key_rsa.sign(
    message_rsa,
    padding.PSS(
        mgf=padding.MGF1(hashes.SHA256()),
        salt_length=padding.PSS.MAX_LENGTH
    ),
    hashes.SHA256()
)
public_key_rsa.verify(
    signature_rsa,
    message_rsa,
    padding.PSS(
        mgf=padding.MGF1(hashes.SHA256()),
        salt_length=padding.PSS.MAX_LENGTH
    ),
    hashes.SHA256()
)
after = time.perf_counter()
print(f"Sign and Verify Time: {after - before:.6f} seconds")

# DSA Key Pair Generation Timing
print("\n### DSA Key Pair Generation ###")
before = time.perf_counter()
private_key_dsa = dsa.generate_private_key(
    key_size=key_size_dsa
)
after = time.perf_counter()
print(f"DSA Key Generation Time: {after - before:.6f} seconds")

public_key_dsa = private_key_dsa.public_key()
message_dsa = os.urandom(10240)  # 10 KB
before = time.perf_counter()
signature_dsa = private_key_dsa.sign(
    message_dsa,
    hashes.SHA256()
)
public_key_dsa.verify(
    signature_dsa,
    message_dsa,
    hashes.SHA256()
)
after = time.perf_counter()
print(f"DSA Sign and Verify Time: {after - before:.6f} seconds")

# ECC Sign and Verify Timing
print("\n### ECC Key Generation ###")
before = time.perf_counter()
private_key_ecc = ec.generate_private_key(curve)
after = time.perf_counter()
print(f"ECC Key Generation Time: {after - before:.6f} seconds")

public_key_ecc = private_key_ecc.public_key()
message_ecc = os.urandom(10240)  # 10 KB
before = time.perf_counter()
signature_ecc = private_key_ecc.sign(
    message_ecc,
    ec.ECDSA(hashes.SHA256())
)
public_key_ecc.verify(
    signature_ecc,
    message_ecc,
    ec.ECDSA(hashes.SHA256())
)
after = time.perf_counter()
print(f"ECC Sign and Verify Time: {after - before:.6f} seconds")
