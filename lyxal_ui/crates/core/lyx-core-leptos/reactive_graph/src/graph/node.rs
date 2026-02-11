### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\graph\node.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\graph\node.rs
2: ```rust
3: 1: /// A node in the reactive graph.
4: 2: pub trait ReactiveNode {
5: 3:     /// Notifies the source's dependencies that it has changed.
6: 4:     fn mark_dirty(&self);
7: 5: 
8: 6:     /// Notifies the source's dependencies that it may have changed.
9: 7:     fn mark_check(&self);
10: 8: 
11: 9:     /// Marks that all subscribers need to be checked.
12: 10:     fn mark_subscribers_check(&self);
13: 11: 
14: 12:     /// Regenerates the value for this node, if needed, and returns whether
15: 13:     /// it has actually changed or not.
16: 14:     fn update_if_necessary(&self) -> bool;
17: 15: }
18: 16: 
19: 17: /// The current state of a reactive node.
20: 18: #[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
21: 19: pub enum ReactiveNodeState {
22: 20:     /// The node is known to be clean: i.e., either none of its sources have changed, or its
23: 21:     /// sources have changed but its value is unchanged and its dependencies do not need to change.
24: 22:     Clean,
25: 23:     /// The node may have changed, but it is not yet known whether it has actually changed.
26: 24:     Check,
27: 25:     /// The node's value has definitely changed, and subscribers will need to update.
28: 26:     Dirty,
29: 27: }
30: ```
```
