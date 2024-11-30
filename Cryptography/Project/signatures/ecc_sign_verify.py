from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import ec
import os
import time

private_key = ec.generate_private_key(
    ec.SECP521R1()
)

public_key = private_key.public_key()

message = os.urandom(10240)


before = time.perf_counter()

# We can sign the message using "hash-then-sign".
signature = private_key.sign(
    message,
    ec.ECDSA(hashes.SHA256())
)

# We can verify the signature.  If the signature is invalid it will
# raise an Exception.
public_key.verify(
    signature,
    message,
    ec.ECDSA(hashes.SHA256())
)

after = time.perf_counter()



totaltime = (after - before)
print(totaltime , "seconds")
#print()
#print("Message: " + message.hex())
#print()
#print("Signature: " + signature.hex())
