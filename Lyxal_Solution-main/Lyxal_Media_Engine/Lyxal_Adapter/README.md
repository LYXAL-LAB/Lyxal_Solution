# Lyxal Integration: Layout -> Render

This module adapts the output of `Lyxal_Layout` (Scene) to the input of `Lyxal_Image` (Layers).

## Flow
1. **User Intent**: `LayoutNode` (Intelligent Template)
2. **Layout Engine**: Computes constraints & positions -> `Scene` (Absolute)
3. **Adapter**: Maps `SceneLayer` -> `LayerConfig`
4. **Render Engine**: Rasterizes `LayerConfig` -> Pixels

## Rules
- **No Geometric Transformation**: Adapter trusts `Scene` coordinates.
- **Param Mapping**:
  - `Box` -> `ShapeRect` (Black Stroke)
  - `Text` -> `Text` (Black, Arial 24)
- **Zero Panic**: Operations are wrapped in Results.

## Usage
See `tests/e2e_render.rs` for a full pipeline example.
