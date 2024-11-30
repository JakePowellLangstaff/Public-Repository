from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding, rsa
import os

private_key = rsa.generate_private_key(
    public_exponent=65537,
    key_size=1024
)

public_key = private_key.public_key()

message = os.urandom(1024)

# We can sign the message using "hash-then-sign".
signature = private_key.sign(
    message,
    padding.PSS(
        mgf=padding.MGF1(hashes.SHA256()),
        salt_length=padding.PSS.MAX_LENGTH
    ),
    hashes.SHA256()
)

# We can verify the signature.  If the signature is invalid it will
# raise an Exception.
public_key.verify(
    signature,
    message,
    padding.PSS(
        mgf=padding.MGF1(hashes.SHA256()),
        salt_length=padding.PSS.MAX_LENGTH
    ),
    hashes.SHA256()
)

print()
print("Message: " + message.hex())
print()
print("Signature: " + signature.hex())
