### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\price_line_source.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\price_line_source.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\price_line_source.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\price_line_source.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\price_line_source.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\price_line_source.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\price_line_source.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\price_line_source.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\price_line_source.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\price_line_source.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\price_line_source.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\price_line_source.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\price_line_source.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\price_line_source.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\price_line_source.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\price_line_source.rs
```rust
use serde::{de::Error, Deserialize, Serialize, Deserializer, Serializer};

#[derive(Default, Copy, Clone)]
pub enum PriceLineSource {
    #[default]
    LastBar     = 0,

    LastVisible = 1,
}

impl Serialize for PriceLineSource {
    fn serialize<S: Serializer>(&self, serializer: S) -> Result<S::Ok, S::Error> {
        serializer.serialize_u8(*self as u8)
    }
}

impl<'de> Deserialize<'de> for PriceLineSource {
    fn deserialize<D: Deserializer<'de>>(deserializer: D) -> Result<Self, D::Error> {
        match u8::deserialize(deserializer)? {
            0 => Ok(Self::LastBar),
            1 => Ok(Self::LastVisible),
            _ => Err(Error::custom("invalid value for PriceLineSource")),
        }
    }
}
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
