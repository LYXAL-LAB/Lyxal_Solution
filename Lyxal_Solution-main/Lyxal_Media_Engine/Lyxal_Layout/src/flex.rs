use crate::node::{LayoutNode, FlexDirection, JustifyContent, AlignItems, FlexWrap, Dimension};
use crate::geometry::{Size, Rect};
use crate::measure::{measure, SizeConstraints};
use crate::{LyxalResult, LayoutError};

/// Result of a flex layout pass: A list of child rects relative to parent
pub struct FlexResult {
    pub content_size: Size,
    pub children_rects: Vec<Rect>,
}

pub fn layout_flex(node: &LayoutNode, constraints: SizeConstraints) -> LyxalResult<FlexResult> {
    let style = &node.style;
    let direction = style.flex_direction;
    let wrap = style.flex_wrap;
    let padding = style.padding;
    let gap = style.gap;
    
    // Effective available space
    let pad_w = padding.left + padding.right;
    let pad_h = padding.top + padding.bottom;
    
    let inner_max_w = (constraints.max.width - pad_w).max(0.0);
    let inner_max_h = (constraints.max.height - pad_h).max(0.0);
    
    // Helper to resolve Value/Percent/Auto
    let resolve_min = |d: &Dimension, parent: f32| -> f32 {
        match d {
            Dimension::Points(v) => *v,
            Dimension::Percent(p) => if parent.is_finite() { parent * p } else { 0.0 },
            Dimension::Auto => 0.0,
        }
    };
    
    let resolve_max = |d: &Dimension, parent: f32| -> f32 {
        match d {
            Dimension::Points(v) => *v,
            Dimension::Percent(p) => if parent.is_finite() { parent * p } else { f32::INFINITY },
            Dimension::Auto => f32::INFINITY,
        }
    };
    
    // 1. Determine Main/Cross Axis availability
    let (main_max, _cross_max) = match direction {
        FlexDirection::Row => (inner_max_w, inner_max_h),
        FlexDirection::Column => (inner_max_h, inner_max_w),
    };

    // 2. Measure Children
    let mut items = Vec::new();
    
    for child in &node.children {
        let child_constraint = SizeConstraints {
            min: Size::new(0.0, 0.0),
            max: Size::new(inner_max_w, inner_max_h), // Using reduced constraints
        };
        
        let mut size = measure(child, child_constraint)?; // Explicit error propagation
        
        if let Dimension::Points(w) = child.style.width { size.width = w; }
        if let Dimension::Points(h) = child.style.height { size.height = h; }
        
        // Apply Min/Max Constraints
        let min_w = resolve_min(&child.style.min_width, inner_max_w);
        let max_w = resolve_max(&child.style.max_width, inner_max_w);
        
        if min_w > max_w {
             return Err(LayoutError::InvalidConstraints(format!("min_width > max_width in Flex child {:?}", child.id)));
        }

        let max_w = max_w.max(min_w); // Safety fallback if we didn't error? No, explicit error above.
        
        let min_h = resolve_min(&child.style.min_height, inner_max_h);
        let max_h = resolve_max(&child.style.max_height, inner_max_h);
        
        if min_h > max_h {
             return Err(LayoutError::InvalidConstraints(format!("min_height > max_height in Flex child {:?}", child.id)));
        }

        let max_h = max_h.max(min_h);

        size.width = size.width.clamp(min_w, max_w);
        size.height = size.height.clamp(min_h, max_h);
        
        items.push(FlexItem { node: child, size, rect: Rect::default() });
    }

    // 3. Flex Lines (Wrapping)
    let mut lines: Vec<FlexLine> = Vec::new();
    let mut current_line = FlexLine::default();
    
    for item in &items {
        let item_main = match direction { FlexDirection::Row => item.size.width, _ => item.size.height };
        
        // Check wrap (account for gap!)
        let gap_space = if current_line.items.is_empty() { 0.0 } else { gap };
        
        if wrap == FlexWrap::Wrap && (current_line.main_size + gap_space + item_main) > main_max && !current_line.items.is_empty() {
             lines.push(current_line);
             current_line = FlexLine::default();
        }
        
        if !current_line.items.is_empty() {
            current_line.main_size += gap; // Add gap before item (if not first)
        }
        
        current_line.items.push(item.clone());
        current_line.main_size += item_main;
        current_line.cross_size = f32::max(current_line.cross_size, match direction { FlexDirection::Row => item.size.height, _ => item.size.width });
    }
    lines.push(current_line);

    // 4. Resolve Main Axis & Final Rects
    let mut final_rects = Vec::new();
    let mut current_cross_pos = 0.0;
    
    let mut container_inner_main = 0.0f32;
    // let mut container_inner_cross = 0.0f32;

    for line in &mut lines {
        // Determine space used by items
        let content_space = line.main_size;
        
        // Determine target size based on style.width/height
        let target_main = match direction {
             FlexDirection::Row => style.width,
             FlexDirection::Column => style.height, // Height usually doesn't stretch unless fixed
        };
        
        let available_space = match target_main {
            Dimension::Points(p) => p,
            Dimension::Percent(pct) => if main_max.is_finite() { main_max * pct } else { content_space },
            Dimension::Auto => content_space, // Shrink to fit
        };

        // Clamp to constraints
        // We already clamped inner_max_w/h earlier? No, main_max is effective max.
        // But `available_space` determines distribution.
        let available_space = available_space.min(main_max).max(content_space); // Cannot be smaller than content if no grow? 
        // Actually if fixed width < content, overflow happens.
        // For V1 Auto: available_space = content_space.
        
        let free_space = f32::max(0.0, available_space - line.main_size);
        
        // Flex Grow logic (simplified)
        let total_grow: f32 = line.items.iter().map(|i| i.node.style.flex_grow).sum();
        
        if total_grow > 0.0 {
            for item in &mut line.items {
                if item.node.style.flex_grow > 0.0 {
                    let share = (item.node.style.flex_grow / total_grow) * free_space;
                    match direction {
                        FlexDirection::Row => {
                            let min = resolve_min(&item.node.style.min_width, inner_max_w);
                            let max = resolve_max(&item.node.style.max_width, inner_max_w).max(min);
                            item.size.width = (item.size.width + share).clamp(min, max);
                        },
                        FlexDirection::Column => {
                            let min = resolve_min(&item.node.style.min_height, inner_max_h);
                            let max = resolve_max(&item.node.style.max_height, inner_max_h).max(min);
                            item.size.height = (item.size.height + share).clamp(min, max);
                        },
                    }
                }
            }
            line.main_size = available_space;
        }
        
        // Justify
        let (mut current_main_pos, spacing) = if total_grow == 0.0 {
            match style.justify_content {
                JustifyContent::Start => (0.0, 0.0),
                JustifyContent::Center => ((available_space - line.main_size) / 2.0, 0.0),
                JustifyContent::End => (available_space - line.main_size, 0.0),
                JustifyContent::SpaceBetween => {
                   if line.items.len() > 1 { (0.0, free_space / (line.items.len() - 1) as f32) } else { (0.0, 0.0) }
                },
                _ => (0.0, 0.0)
            }
        } else {
            (0.0, 0.0)
        };

        // Layout Items
        for (idx, item) in line.items.iter().enumerate() {
            if idx > 0 { current_main_pos += gap; } // Gap before item (except first) - Actually gap is part of main_size already?
            // Wait, justified spacing handles gaps implicitly if manually distributed?
            // But if Start/Center, gaps are fixed.
            // My default `current_main_pos` accumulation must include fixed gaps if not using `spacing`.
            // The `spacing` var above is ONLY for SpaceBetween dynamic spacing.
            // For Start/Center, spacing is 0.0, so we must add `gap` manually if `gap` property is set?
            // Yes, `line.main_size` included `gap`.
            // But `JustifyContent::SpaceBetween` usually overrides `gap`? No, SpaceBetween distributes *remaining* space.
            // In Flexbox, `gap` is minimum space.
            // For V1 simplification: Assume `gap` is valid space.
            // If `SpaceBetween` is used, the free space is distributed ON TOP of gaps? Or replaces?
            // CSS Gap replaces margins between.
            
            // To keep simple: Only add `gap` to pos if not `SpaceBetween`?
            // Or `SpaceBetween` calculation should have subtracted gaps from free space?
            // `available_space - line.main_size`. `line.main_size` INCLUDED gaps.
            // So `free_space` is correct.
            // If Spacing > 0 (SpaceBetween), we add it to `gap`? or it IS the gap?
            
            // Let's refine for V1: Just use `gap` always, and `spacing` adds to it.
            if idx > 0 { current_main_pos += spacing; }
            
            let (w, h) = (item.size.width, item.size.height);
            let (x, y) = match direction {
                FlexDirection::Row => (current_main_pos, current_cross_pos),
                FlexDirection::Column => (current_cross_pos, current_main_pos),
            };
            
            let cross_parent = line.cross_size;
            let cross_child = match direction { FlexDirection::Row => h, _ => w };
            let align_offset = match style.align_items {
                AlignItems::Start | AlignItems::Stretch => 0.0,
                AlignItems::Center => (cross_parent - cross_child) / 2.0,
                AlignItems::End => cross_parent - cross_child,
            };
            
            let final_rect_x = if direction == FlexDirection::Row { x } else { x + align_offset };
            let final_rect_y = if direction == FlexDirection::Column { y } else { y + align_offset };
            
            // APPLY PADDING OFFSET HERE
            let final_x = final_rect_x + padding.left;
            let final_y = final_rect_y + padding.top;
            
            let final_w = if direction == FlexDirection::Column && style.align_items == AlignItems::Stretch { line.cross_size } else { w };
            let final_h = if direction == FlexDirection::Row && style.align_items == AlignItems::Stretch { line.cross_size } else { h };

            final_rects.push(Rect::new(final_x, final_y, final_w, final_h));
            
            current_main_pos += match direction { FlexDirection::Row => final_w, _ => final_h };
        }
        
        container_inner_main = f32::max(container_inner_main, line.main_size);
        current_cross_pos += line.cross_size;
    }
    
    // container_inner_cross = current_cross_pos;

    let (inner_w, inner_h) = match direction {
        FlexDirection::Row => (container_inner_main, current_cross_pos),
        FlexDirection::Column => (current_cross_pos, container_inner_main),
    };
    
    // Final Size = Inner + Padding
    Ok(FlexResult {
        content_size: Size::new(inner_w + pad_w, inner_h + pad_h),
        children_rects: final_rects,
    })
}

#[derive(Clone)]
struct FlexItem<'a> {
    node: &'a LayoutNode,
    size: Size,
    rect: Rect,
}

#[derive(Default)]
struct FlexLine<'a> {
    items: Vec<FlexItem<'a>>,
    main_size: f32,
    cross_size: f32,
}
