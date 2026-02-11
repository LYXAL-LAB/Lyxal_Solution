use crate::node::{LayoutNode, GridTrack, Dimension};
use crate::geometry::{Size, Rect};
use crate::measure::{measure, SizeConstraints};
use crate::LyxalResult;

/// Result of a grid layout pass
pub struct GridResult {
    pub content_size: Size,
    pub children_rects: Vec<Rect>,
}

pub fn layout_grid(node: &LayoutNode, constraints: SizeConstraints) -> LyxalResult<GridResult> {
    let style = &node.style;
    let gap = style.gap;
    let padding = style.padding;
    let tracks = &style.grid_template_columns; 

    // Effective available space
    let pad_w = padding.left + padding.right;
    let pad_h = padding.top + padding.bottom;
    
    let inner_max_w = (constraints.max.width - pad_w).max(0.0);
    
    let mut resolved_tracks: Vec<f32> = Vec::new();
    
    if tracks.is_empty() {
        // Fallback: 1 column auto (width of container)
        resolved_tracks.push(inner_max_w); 
    } else {
        let mut total_fixed = 0.0;
        let mut total_fr = 0.0;
        let gap_total = (tracks.len() as f32 - 1.0).max(0.0) * gap;
        
        for track in tracks {
            match track {
                GridTrack::Points(p) => total_fixed += p,
                GridTrack::Fr(f) => total_fr += f,
                GridTrack::Auto => {
                    total_fr += 1.0; 
                }
            }
        }
        
        let available_for_fr = (inner_max_w - total_fixed - gap_total).max(0.0);
        let fr_unit = if total_fr > 0.0 { available_for_fr / total_fr } else { 0.0 };
        
        for track in tracks {
            let width = match track {
                GridTrack::Points(p) => *p,
                GridTrack::Fr(f) => f * fr_unit,
                GridTrack::Auto => fr_unit * 1.0, 
            };
            resolved_tracks.push(width);
        }
    }
    
    // 2. Place Items (Row Major)
    
    let num_cols = resolved_tracks.len();
    let mut current_col = 0;
    let mut current_row_height = 0.0f32;
    let mut rows: Vec<f32> = Vec::new(); // Heights of completed rows
    
    // Store rects temporarily (without Y)
    let mut temp_rects: Vec<Rect> = vec![Rect::default(); node.children.len()]; 
    
    // Loop through children to measure and determine row heights
    for (i, child) in node.children.iter().enumerate() {
        let span = child.style.column_span.max(1) as usize;
        let effective_span = span.min(num_cols); // Cap span at max cols
        
        // Wrap if span doesn't fit
        if current_col + effective_span > num_cols {
             // Finish current row
             rows.push(current_row_height);
             current_row_height = 0.0;
             current_col = 0;
        }
        
        // Determine Width of item based on tracks
        let mut item_width = 0.0;
        for k in 0..effective_span {
            if current_col + k < num_cols {
                item_width += resolved_tracks[current_col + k];
            }
        }
        // Add Gaps within span
        if effective_span > 1 {
            item_width += (effective_span as f32 - 1.0) * gap;
        }
        
        // Measure Child Height given Fixed Width
        let child_constraints = SizeConstraints {
            min: Size::new(item_width, 0.0),
            max: Size::new(item_width, f32::INFINITY), // Unconstrained height
        };
        
        let size = measure(child, child_constraints)?;
        let height = if let Dimension::Points(h) = child.style.height { h } else { size.height };
        
        // Update Row Max Height
        current_row_height = current_row_height.max(height);
        
        // Store X info (we need to resolve X based on tracks)
        // Calculate X offset
        let mut x_offset = 0.0;
        for k in 0..current_col {
            x_offset += resolved_tracks[k] + gap;
        }
        
        temp_rects[i] = Rect::new(x_offset, 0.0, item_width, height); // Y is 0 for now
        
        // Advance Col
        current_col += effective_span;
    }
    
    // Push last row height
    rows.push(current_row_height);
    
    // 3. Resolve Y positions
    let mut final_rects = Vec::new();
    let mut current_y = 0.0;
    
    // We need to replay the placement loop logic to know which item is in which row?
    // Or simpler: We know the flow.
    // Wait, the `temp_rects` have X and W. We just need Y.
    // The previous loop didn't store "Row Index" for each item.
    // Re-simulating to assign Y.
    
    current_col = 0;
    let mut current_row_idx = 0;
    
    for (i, child) in node.children.iter().enumerate() {
        let span = child.style.column_span.max(1) as usize;
        let effective_span = span.min(num_cols); // Cap span at max cols
        
        if current_col + effective_span > num_cols {
             current_y += rows[current_row_idx] + gap;
             current_row_idx += 1;
             current_col = 0;
        }
        
        let rect = &mut temp_rects[i];
        let final_x = rect.x + padding.left;
        let final_y = current_y + padding.top;
        
        // Should we stretch height to row height? 
        // Default align-items in grid is 'stretch'...
        // V1: Stretch to row height.
        let row_h = rows[current_row_idx];
        let final_h = row_h; // Stretch
        
        final_rects.push(Rect::new(final_x, final_y, rect.width, final_h));
        
        current_col += effective_span;
    }
    
    // Calculate total height
    let total_h = rows.iter().sum::<f32>() + ((rows.len() as f32 - 1.0).max(0.0) * gap) + pad_h;
    
    // Calculate effective total width
    let used_content_width: f32 = resolved_tracks.iter().sum::<f32>() + ((resolved_tracks.len() as f32 - 1.0).max(0.0) * gap);
    let used_border_width = used_content_width + pad_w;
    
    let final_w = if constraints.max.width.is_finite() {
        match style.width {
            Dimension::Points(p) => p,
            Dimension::Percent(pct) => constraints.max.width * pct,
            Dimension::Auto => constraints.max.width, // Stretch to constraint if finite
        }
    } else {
        used_border_width // Shrink to fit if unconstrained
    };

    Ok(GridResult {
        content_size: Size::new(final_w, total_h),
        children_rects: final_rects,
    })
}
