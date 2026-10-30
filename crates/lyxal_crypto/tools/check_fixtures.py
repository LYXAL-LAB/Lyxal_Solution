#!/usr/bin/env python3
"""Check published literal vectors with OpenSSL, independently of the Rust crate.

Optional validation tool: requires Python cryptography (not a production dependency).
Never rewrites fixtures or derives the expected ciphertext from lyxal_crypto.
"""
import base64
import json
from pathlib import Path
import re

import cryptography
from cryptography.hazmat.backends.openssl.backend import backend
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

spec = (Path(__file__).resolve().parents[1] / "ENVELOPE_FORMAT_V2.md").read_text()
key = bytes.fromhex(re.search(r"KEY_HEX=([0-9a-f]+)", spec).group(1))
assert AESGCM(bytes(32)).encrypt(bytes(12), b"", b"").hex() == "530f8afbc74536b9a963b4f1c4cb738b"
vectors = [dict(line.split("=", 1) for line in block.splitlines() if "=" in line)
           for block in re.findall(r"```text\n(.*?)\n```", spec, re.S)
           if block.startswith("NONCE_HEX=")]
assert len(vectors) == 3
for name, vector in zip(("T1", "T0", "G1"), vectors):
    tenant = name != "G1"
    fields = ["k1", "Acme", "booking", "setting", "rec_é", "password"] if tenant else ["k1", "smtp.password"]
    aad = b"lyxal:crypto:enc:v2:aes-256-gcm\0" + bytes([1 if tenant else 2])
    for field in fields:
        value = field.encode("utf-8")
        aad += len(value).to_bytes(4, "big") + value
    assert aad.hex() == vector["AAD_HEX"]
    assert len(aad) == int(vector["AAD_LENGTH"])
    nonce = bytes.fromhex(vector["NONCE_HEX"])
    plaintext = bytes.fromhex(vector["PLAINTEXT_HEX"])
    encrypted = AESGCM(key).encrypt(nonce, plaintext, aad)
    assert encrypted[:-16].hex() == vector["CIPHERTEXT_HEX"]
    assert encrypted[-16:].hex() == vector["TAG_HEX"]
    assert (nonce + encrypted).hex() == vector["PAYLOAD_HEX"]
    assert "enc:v2:k1:" + base64.urlsafe_b64encode(nonce + encrypted).decode().rstrip("=") == vector["ENVELOPE"]
    assert AESGCM(key).decrypt(nonce, encrypted, aad) == plaintext
print(json.dumps({"cryptography": cryptography.__version__, "backend": backend.openssl_version_text(),
                  "nist_control": "passed", "literal_vectors": ["T1", "T0", "G1"],
                  "aad_ciphertext_tag_payload_transport_roundtrip": "passed"}, indent=2))
