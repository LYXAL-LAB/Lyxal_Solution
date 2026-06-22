# Lyxal IPC Protocol

This crate contains the Lyxal Inter-Process Communication (IPC) protocol.

Starting with Lyxal 3.0, the Lyxal server exposes a gRPC interface. All
gRPC and protobuf messages are exposed under the `proto` module.

This crate also contains the Lyxal Flatbuffers protocol which is for
efficient transmission of Lyxal `Value`s.
