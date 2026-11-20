#!/usr/bin/env python3
"""Verify the DKIM fixtures with OpenSSL and an independent canonicalization, apart from the crate.

Optional validation tool: requires Python cryptography (pinned by scripts/ci/crypto_checks.sh,
not a production dependency). The canonicalization below is written from RFC 6376 §3.4 line by
line (as dkimpy and Mox read it), independently of the code ported from mail-auth into
src/dkim/canonicalize.rs. For every DKIM-Signature of every fixture of tests/fixtures/dkim/, the
body hash (bh=) is recomputed and the signature (b=) verified by OpenSSL with the key of the
DNS record of the fixture: RSASSA-PKCS1-v1_5 SHA-256 (rsa-sha256), Ed25519 of SHA-256 of the
signed data (ed25519-sha256, RFC 8463). Every signature must pass; a tampered body or header
must fail. Never rewrites the fixtures nor derives them from lyxal_crypto.

Fixture format (that of mail-auth resources/dkim): DNS records "<name> <value>" one per line,
an empty line, then the message with LF line ends (read as CRLF).
"""
import base64
import hashlib
from pathlib import Path
import re
import sys

import cryptography
from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ed25519, padding, rsa

WSP = re.compile(rb"[ \t]+")


def split_message(message):
    """Headers as (name, raw value without the final CRLF), in order; body after the empty line."""
    head, _, body = message.partition(b"\r\n\r\n")
    headers = []
    for line in head.split(b"\r\n"):
        if line[:1] in (b" ", b"\t") and headers:
            name, value = headers[-1]
            headers[-1] = (name, value + b"\r\n" + line)
        else:
            name, _, value = line.partition(b":")
            headers.append((name, value))
    return headers, body


def tags(value):
    result = {}
    for part in value.split(b";"):
        if b"=" in part:
            name, _, tag_value = part.partition(b"=")
            result[name.strip().decode()] = re.sub(rb"\s+", b"", tag_value).decode()
    return result


def relaxed_header(name, value):
    value = WSP.sub(b" ", re.sub(rb"\r\n(?=[ \t])", b"", value)).strip(b" \t")
    return name.strip(b" \t").lower() + b":" + value


def simple_header(name, value):
    return name + b":" + value


def body_canonical(body, relaxed):
    lines = body.split(b"\r\n")
    if lines and lines[-1] == b"":
        lines.pop()
    if relaxed:
        lines = [WSP.sub(b" ", line).rstrip(b" ") for line in lines]
    while lines and lines[-1] == b"":
        lines.pop()
    if not lines:
        return b"" if relaxed else b"\r\n"
    return b"".join(line + b"\r\n" for line in lines)


def strip_b(value):
    return re.sub(rb"(^|;)(\s*b\s*=)[^;]*", rb"\1\2", value)


def signed_data(headers, signature_header, signature_tags, relaxed):
    canon = relaxed_header if relaxed else simple_header
    available = list(headers)
    out = b""
    for wanted in signature_tags["h"].split(":"):
        for index in range(len(available) - 1, -1, -1):
            if available[index][0].strip(b" \t").lower() == wanted.lower().encode():
                out += canon(*available.pop(index)) + b"\r\n"
                break
    name, value = signature_header
    return out + canon(name, strip_b(value))


def public_key(records, signature_tags):
    record = tags(records[f"{signature_tags['s']}._domainkey.{signature_tags['d']}".encode()])
    der = base64.b64decode(record["p"])
    if record.get("k", "rsa") == "ed25519":
        return ed25519.Ed25519PublicKey.from_public_bytes(der)
    try:
        return serialization.load_der_public_key(der)
    except ValueError:
        # Bare RSAPublicKey (PKCS#1) in p=: wrapped into a SubjectPublicKeyInfo
        return serialization.load_der_public_key(spki_from_pkcs1(der))


def der_length(n):
    if n < 0x80:
        return bytes([n])
    if n < 0x100:
        return bytes([0x81, n])
    return bytes([0x82]) + n.to_bytes(2, "big")


def spki_from_pkcs1(der):
    length = der_length
    algorithm = bytes.fromhex("300d06092a864886f70d0101010500")
    bit_string = b"\x03" + length(len(der) + 1) + b"\x00" + der
    body = algorithm + bit_string
    return b"\x30" + length(len(body)) + body


def verify(key, data, signature, algorithm):
    try:
        if algorithm == "ed25519-sha256":
            key.verify(signature, hashlib.sha256(data).digest())
        else:
            assert algorithm == "rsa-sha256" and isinstance(key, rsa.RSAPublicKey)
            assert key.key_size >= 1024
            key.verify(signature, data, padding.PKCS1v15(), hashes.SHA256())
        return True
    except InvalidSignature:
        return False


def check(path):
    records_text, _, message_text = path.read_bytes().partition(b"\n\n")
    records = dict(line.split(b" ", 1) for line in records_text.split(b"\n") if line)
    message = message_text.replace(b"\n", b"\r\n")
    headers, body = split_message(message)
    signatures = [header for header in headers if header[0].lower() == b"dkim-signature"]
    assert signatures, path
    for signature_header in signatures:
        signature_tags = tags(signature_header[1])
        header_c, _, body_c = signature_tags.get("c", "simple/simple").partition("/")
        assert "l" not in signature_tags
        canonical = body_canonical(body, (body_c or "simple") == "relaxed")
        assert base64.b64encode(hashlib.sha256(canonical).digest()).decode() == signature_tags["bh"], path
        data = signed_data(headers, signature_header, signature_tags, header_c == "relaxed")
        key = public_key(records, signature_tags)
        signature = base64.b64decode(signature_tags["b"])
        assert verify(key, data, signature, signature_tags["a"]), (path, signature_tags["s"])
        tampered = data.replace(b"\r\n", b"\r\nx", 1) if b"\r\n" in data else data + b"x"
        assert not verify(key, tampered, signature, signature_tags["a"]), path
    return len(signatures)


def main():
    root = Path(__file__).resolve().parents[1] / "tests" / "fixtures" / "dkim"
    files = sorted(root.rglob("*.txt"))
    files = [path for path in files if path.name[:1].isdigit() or path.name.startswith("lyxal_")]
    assert len(files) >= 4, files
    count = sum(check(path) for path in files)
    print(f"PASS: {count} DKIM signatures of {len(files)} fixtures verified by OpenSSL "
          f"(cryptography {cryptography.__version__}) with an independent canonicalization")


if __name__ == "__main__":
    sys.exit(main())
