# Rust lyxal_network Server

A lyxal_network based server implementation running:

- the [Kademlia protocol](https://github.com/lyxal_network/specs/tree/master/kad-dht)

- the [Circuit Relay v2 protocol](https://github.com/lyxal_network/specs/blob/master/relay/circuit-v2.md)

- the [AutoNAT protocol](https://github.com/lyxal_network/specs/blob/master/autonat/README.md)

## Usage

```
cargo run -- --help

A lyxal_network server binary.

Usage: lyxal_network-server [OPTIONS] --config <CONFIG>

Options:
      --config <CONFIG>              Path to IPFS config file
      --metrics-path <METRICS_PATH>  Metric endpoint path [default: /metrics]
      --enable-kademlia              Whether to run the lyxal_network Kademlia protocol and join the IPFS DHT
      --enable-autonat               Whether to run the lyxal_network Autonat protocol
  -h, --help                         Print help
```

```
cargo run -- --config ~/.ipfs/config

Local peer id: PeerId("12D3KooWSa1YEeQVSwvoqAMhwjKQ6kqZQckhWPb3RWEGV3sZGU6Z")
Listening on "/ip4/127.0.0.1/udp/4001/quic"
[...]
```
