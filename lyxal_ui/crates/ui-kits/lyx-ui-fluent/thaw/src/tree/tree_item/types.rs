### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\tree\tree_item\types.rs
```rust
use leptos::{
    html,
    prelude::{expect_context, Memo, NodeRef},
};

#[derive(Debug, Default, PartialEq, Clone, Copy)]
pub enum TreeItemType {
    #[default]
    Leaf,
    Branch,
}

impl TreeItemType {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Leaf => "leaf",
            Self::Branch => "branch",
        }
    }
}

#[derive(Debug, Clone)]
pub(crate) struct TreeItemInjection {
    pub open: Memo<bool>,
    pub item_type: TreeItemType,
    pub subtree_ref: NodeRef<html::Div>,
}

impl TreeItemInjection {
    pub fn expect_context() -> Self {
        expect_context()
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
```
```
