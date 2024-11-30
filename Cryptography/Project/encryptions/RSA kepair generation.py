from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding, rsa
import os
import time


before = time.perf_counter()
private_key = rsa.generate_private_key(
    public_exponent=65537,
    key_size=15360
    #1024
)
after = time.perf_counter()


totaltime = (after - before)
print(totaltime , "seconds")
