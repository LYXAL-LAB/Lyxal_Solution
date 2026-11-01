#!/usr/bin/env python3
"""Check actual Rust trait bounds, with serde present in an isolated test workspace.

No root lockfile is used as an alternative build lock. All build outputs stay
in tools/contracts/target. Identity From/Into/Borrow implementations MUST work.
"""
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parent / "contracts"
result = subprocess.run(
    ["cargo", "build", "--offline", "--locked", "--manifest-path", str(ROOT / "Cargo.toml"),
     "--message-format=json"], capture_output=True, text=True, check=True,
)
libraries = {}
for line in result.stdout.splitlines():
    item = json.loads(line)
    if item.get("reason") == "compiler-artifact":
        for filename in item.get("filenames", []):
            if filename.endswith(".rlib"):
                libraries[item["target"]["name"]] = filename
output = ROOT / "target" / "contract-probe"
dependencies = str(Path(libraries["lyxal_crypto"]).parent)
arguments = ["rustc", "--edition=2021", "--crate-name", "contract_probe", "-",
             "-L", f"dependency={dependencies}", "-o", str(output)]
for name in ["lyxal_crypto", "serde", "zeroize"]:
    arguments.extend(["--extern", f"{name}={libraries[name]}"])


def compile_source(source):
    return subprocess.run(arguments, input=source, capture_output=True, text=True)


types = ["SecretBytes", "SecretString", "EncryptionKey", "HmacKey", "PasswordHash"]
for name in types:
    # Positive controls stop a missing dependency/name from masquerading as security.
    positive = f"""
use lyxal_crypto::{name};
fn positive<T: Send + Sync + Unpin + zeroize::ZeroizeOnDrop + std::fmt::Debug>() {{}}
fn identity(value: {name}) {{
    let _: &{name} = std::borrow::Borrow::borrow(&value);
    let _: {name} = value.into();
}}
fn main() {{ positive::<{name}>(); }}
"""
    checked = compile_source(positive)
    assert checked.returncode == 0, checked.stderr
    forbidden = ["Clone", "Copy", "Default", "std::fmt::Display", "PartialEq",
                 "Eq", "std::hash::Hash", "serde::Serialize", "std::ops::Deref",
                 "AsRef<[u8]>", "AsRef<str>", "std::borrow::Borrow<[u8]>",
                 "std::borrow::Borrow<str>", "Into<Vec<u8>>", "Into<String>",
                 "From<Vec<u8>>", "From<String>"]
    for bound in forbidden:
        negative = f"use lyxal_crypto::{name}; fn require<T: {bound}>() {{}} fn main() {{ require::<{name}>(); }}"
        checked = compile_source(negative)
        assert checked.returncode != 0, f"Unexpected {bound} on {name}"
        assert "E0277" in checked.stderr, checked.stderr
print(f"PASS: {len(types)} positive controls, {len(types) * len(forbidden)} forbidden trait bounds")
