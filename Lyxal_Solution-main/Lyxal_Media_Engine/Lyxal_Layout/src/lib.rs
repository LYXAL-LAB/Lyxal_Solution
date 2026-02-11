//! # Lyxal Layout Engine
//!
//! A deterministic, constraint-based layout engine for programmatic image generation.
//! supports Flexbox (Row/Column), Grid (V1), and absolute positioning resolution.
//!
//! ## Core Functions
//! - `compute_layout(node, constraints)`: Calculates the layout tree.
//! - `resolve_to_scene(result)`: Flattens the layout into an absolute Scene.
//!
//! ## Example
//! ```rust
//! use Lyxal_Layout::*;
//! let root = LayoutNode::new(NodeType::Box);
//! let res = compute_layout(&root, SizeConstraints::default()).unwrap();
//! let scene = resolve_to_scene(&res, None);
//! ```

pub mod node;
pub mod geometry;
pub mod measure;
pub mod flex;
pub mod grid;
pub mod algo;
pub mod output;

pub use node::*;
pub use geometry::*;
pub use measure::*;
pub use flex::*;
pub use grid::*;
pub use algo::*;
pub use output::*;

#[derive(Debug, Clone, PartialEq)]
pub enum LayoutError {
    InvalidConstraints(String),
    MaxIterationReached,
    // Add more as needed
}

pub type LyxalResult<T> = std::result::Result<T, LayoutError>;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let node = LayoutNode::new(NodeType::Box).with_id("root");
        assert_eq!(node.id, Some("root".to_string()));
        assert!(matches!(node.node_type, NodeType::Box));
    }
}
