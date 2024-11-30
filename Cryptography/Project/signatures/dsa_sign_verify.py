from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import dsa
import os
import time

private_key = dsa.generate_private_key(
    key_size=15360
)

public_key = private_key.public_key()

message = os.urandom(10240) #10kb

before = time.perf_counter()
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
after = time.perf_counter()

totaltime = (after - before)
print(totaltime , "seconds")
#print("Message: " + message.hex())
#print()
#print("Signature: " + signature.hex())
