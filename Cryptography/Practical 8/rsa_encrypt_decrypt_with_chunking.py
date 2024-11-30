from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding, rsa
import os

private_key = rsa.generate_private_key(
    public_exponent=65537,
    key_size=1024
)

public_key = private_key.public_key()

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

# We can encrypt/decrypt large messages using chunking.
long_plaintext = os.urandom(5000)
long_ciphertext = encrypt_message(public_key, long_plaintext, 32)
long_plaintext_2 = decrypt_message(private_key, long_ciphertext)

print()
print("Plaintext: " + long_plaintext.hex())
print()
print("Ciphertext: " + b"".join(long_ciphertext).hex())
print()
print("Original Plaintext: " + long_plaintext_2.hex())
