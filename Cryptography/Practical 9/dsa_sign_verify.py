from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import dsa
import os

private_key = dsa.generate_private_key(
    key_size=1024
)

public_key = private_key.public_key()

message = os.urandom(50)

# We can sign the message using "hash-then-sign".
signature = private_key.sign(
    message,
    hashes.SHA256()
)

# We can verify the signature.  If the signature is invalid it will
# raise an Exception.
public_key.verify(
    signature,
    message,
    hashes.SHA256()
)

print()
print("Message: " + message.hex())
print()
print("Signature: " + signature.hex())
