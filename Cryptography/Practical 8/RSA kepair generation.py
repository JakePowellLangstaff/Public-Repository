import time
from cryptography.hazmat.primitives.asymmetric import rsa
private_key = rsa.generate_private_key(
public_exponent=65537,
key_size=4096
before = time.perf_counter()
)
public_key = private_key.public_key()

from cryptography.hazmat.primitives import hashes, serialization
private_key_str = private_key.private_bytes(
encoding=serialization.Encoding.PEM,
format=serialization.PrivateFormat.PKCS8,
encryption_algorithm=serialization.NoEncryption()

)
# code you wish to time
after = time.perf_counter()
# We can print out the private-key.
print(private_key_str.decode("utf-8"))
public_key_str = public_key.public_bytes(
encoding=serialization.Encoding.PEM,
format=serialization.PublicFormat.PKCS1
)
# We can print out the public-key.
print(public_key_str.decode("utf-8"))






print(f"{after - before:0.4f} seconds")