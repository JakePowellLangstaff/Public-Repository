from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding, rsa
import os
import time

private_key = rsa.generate_private_key(
    public_exponent=65537,
    key_size=15360
)

public_key = private_key.public_key()

message = os.urandom(2048)
before = time.perf_counter()
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
after = time.perf_counter()




totaltime = (after - before)
print(totaltime , "seconds")
#print("Message: " + message.hex())
#print("Signature: " + signature.hex())
