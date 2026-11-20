#!/usr/bin/env python3
"""Check the literal vectors of STREAM_FORMAT_V1.md with OpenSSL, independently of the crate.

Optional validation tool: requires Python cryptography (pinned by scripts/ci/crypto_checks.sh,
not a production dependency). The header, segment key, associated data, every segment and
every tag are recomputed from the specification alone (HKDF-SHA256 and AES-256-GCM of
OpenSSL), then compared with the published values; a decryption with each tampering rule of the
specification must fail. Never rewrites the fixtures nor derives them from lyxal_crypto.
"""
import hashlib
import json
from pathlib import Path
import re

import cryptography
from cryptography.exceptions import InvalidTag
from cryptography.hazmat.backends.openssl.backend import backend
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.kdf.hkdf import HKDF

DOMAIN = b"lyxal:crypto:stream:v1:aes-256-gcm\0"
SEGMENT = 65536


def lp(value):
    raw = value.encode("utf-8")
    return len(raw).to_bytes(4, "big") + raw


def identity(context):
    kind, *fields = context.split("|")
    mode = {"tenant": 1, "global": 2}[kind]
    assert len(fields) == (5 if mode == 1 else 1)
    return bytes([mode]) + b"".join(lp(field) for field in fields)


def plaintext(length):
    return bytes(i % 251 for i in range(length))


def nonce(prefix, index, last):
    return prefix + index.to_bytes(4, "big") + bytes([1 if last else 0])


def encrypt(key, salt, prefix, context, data):
    header = b"LXS1" + bytes([1, 1, 16, 0]) + salt + prefix
    assert len(header) == 47
    segment_key = HKDF(hashes.SHA256(), 32, salt, DOMAIN).derive(key)
    aad = DOMAIN + header + identity(context)
    chunks = [data[i:i + SEGMENT] for i in range(0, len(data), SEGMENT)] or [b""]
    aead = AESGCM(segment_key)
    segments = [aead.encrypt(nonce(prefix, i, i == len(chunks) - 1), chunk, aad)
                for i, chunk in enumerate(chunks)]
    return header, segment_key, aad, segments


spec = (Path(__file__).resolve().parents[1] / "STREAM_FORMAT_V1.md").read_text()
assert AESGCM(bytes(32)).encrypt(bytes(12), b"", b"").hex() == "530f8afbc74536b9a963b4f1c4cb738b"
blocks = [dict(line.split("=", 1) for line in block.splitlines() if "=" in line)
          for block in re.findall(r"```text\n(.*?)\n```", spec, re.S)
          if block.startswith("VECTOR=")]
names = [block["VECTOR"] for block in blocks]
assert names == ["S0", "S1", "S65535", "S65536", "S65537", "S200000", "G1"], names
for vector in blocks:
    key = bytes.fromhex(vector["KEY_HEX"])
    salt = bytes.fromhex(vector["SALT_HEX"])
    prefix = bytes.fromhex(vector["NONCE_PREFIX_HEX"])
    data = plaintext(int(vector["PLAINTEXT_LENGTH"]))
    header, segment_key, aad, segments = encrypt(key, salt, prefix, vector["CONTEXT"], data)
    ciphertext = header + b"".join(segments)
    assert header.hex() == vector["HEADER_HEX"], vector["VECTOR"]
    assert segment_key.hex() == vector["SEGMENT_KEY_HEX"], vector["VECTOR"]
    assert aad.hex() == vector["AAD_HEX"], vector["VECTOR"]
    assert len(ciphertext) == int(vector["CIPHERTEXT_LENGTH"]), vector["VECTOR"]
    assert int(vector["SEGMENTS"]) == len(segments), vector["VECTOR"]
    assert ",".join(s[-16:].hex() for s in segments) == vector["TAGS_HEX"], vector["VECTOR"]
    assert hashlib.sha256(ciphertext).hexdigest() == vector["CIPHERTEXT_SHA256"], vector["VECTOR"]
    if "CIPHERTEXT_HEX" in vector:
        assert ciphertext.hex() == vector["CIPHERTEXT_HEX"], vector["VECTOR"]
    # Rejection rules: the last segment opened as "not last", a non-last one as "last",
    # another segment index, and a modified header must all fail authentication.
    aead = AESGCM(segment_key)
    last = len(segments) - 1
    for index, segment in enumerate(segments):
        assert aead.decrypt(nonce(prefix, index, index == last), segment, aad) == \
            data[index * SEGMENT:(index + 1) * SEGMENT]
        for bad_nonce in (nonce(prefix, index, index != last), nonce(prefix, index + 1, index == last)):
            try:
                aead.decrypt(bad_nonce, segment, aad)
                raise AssertionError("tampered nonce accepted")
            except InvalidTag:
                pass
        try:
            aead.decrypt(nonce(prefix, index, index == last), segment, aad[:35] + b"X" + aad[36:])
            raise AssertionError("tampered header accepted")
        except InvalidTag:
            pass
print(json.dumps({"cryptography": cryptography.__version__, "backend": backend.openssl_version_text(),
                  "nist_control": "passed", "stream_vectors": names,
                  "header_key_aad_segments_tags_rejections": "passed"}, indent=2))
