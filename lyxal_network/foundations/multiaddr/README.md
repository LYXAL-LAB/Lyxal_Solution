# multiaddr

## Table of Contents

- [Install](#install)
- [Usage](#usage)
- [Maintainers](#maintainers)
- [Contribute](#contribute)
- [License](#license)

## Install

First add this to your `Cargo.toml`

```toml
[dependencies]
multiaddr = "*"
```

then run `cargo build`.

## Usage

```rust
extern crate multiaddr;

use multiaddr::{Multiaddr, multiaddr};

let address = "/ip4/127.0.0.1/tcp/1234".parse::<Multiaddr>().unwrap();
// or with a macro
let other = multiaddr!(Ip4([127, 0, 0, 1]), Udp(10500u16), QuicV1);

assert_eq!(address.to_string(), "/ip4/127.0.0.1/tcp/1234");
assert_eq!(other.to_string(), "/ip4/127.0.0.1/udp/10500/quic-v1");
```
