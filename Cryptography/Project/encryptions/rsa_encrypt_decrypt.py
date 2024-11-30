from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding, rsa
import os
import time

private_key = rsa.generate_private_key(
    public_exponent=65537,
    key_size=4096
    #1024
)

private_key_str = private_key.private_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PrivateFormat.PKCS8,
    encryption_algorithm=serialization.NoEncryption()
)

# We can print out the private-key.
print(private_key_str.decode("utf-8"))

public_key = private_key.public_key()

public_key_str = public_key.public_bytes(
   encoding=serialization.Encoding.PEM,
   format=serialization.PublicFormat.PKCS1
)

# We can print out the public-key.
print(public_key_str.decode("utf-8"))

short_plaintext = os.urandom(50)#########
before = time.perf_counter()
# We can encrypt a small plaintext message directly.
short_ciphertext = public_key.encrypt(
    short_plaintext,
    padding.OAEP(
        mgf=padding.MGF1(algorithm=hashes.SHA256()),
        algorithm=hashes.SHA256(),
        label=None
    )
)
# code you wish to time
after = time.perf_counter()
# We can decrypt the ciphertext.
short_plaintext_2 = private_key.decrypt(
    short_ciphertext,
    padding.OAEP(
        mgf=padding.MGF1(algorithm=hashes.SHA256()),
        algorithm=hashes.SHA256(),
        label=None
    )
)

print()
print("Plaintext: " + short_plaintext.hex())
print()
print("Ciphertext: " + short_ciphertext.hex())
print()
print("Original Plaintext: " + short_plaintext_2.hex())
print(f"{after - before:0.4f} secondsx")