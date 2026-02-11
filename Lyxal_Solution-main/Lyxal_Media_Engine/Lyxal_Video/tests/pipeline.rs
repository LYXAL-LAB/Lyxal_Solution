use lyxal_video::{Pipeline, SceneState, Timeline, VideoConfig};
use lyxal_layout::{LayoutNode, NodeType};
use lyxal_motion::{MotionTrack, Keyframe, MotionValue, EasingCurve};
use std::collections::HashMap;

#[test]
fn test_video_pipeline_determinism() {
    eprintln!("TEST STARTED");
    // 1. Setup Scene
    let mut root = LayoutNode::new(NodeType::Box)
        .with_id("root");
    
    root.style.width = lyxal_layout::Dimension::Points(100.0);
    root.style.height = lyxal_layout::Dimension::Points(100.0);
        
    let k1 = Keyframe { time: 0.0, value: MotionValue::Scalar(100.0), easing: EasingCurve::Linear };
    let k2 = Keyframe { time: 1.0, value: MotionValue::Scalar(200.0), easing: EasingCurve::Linear };
    
    let track = MotionTrack::new("width".to_string(), vec![k1, k2]);
    let mut tracks = HashMap::new();
    tracks.insert("root".to_string(), vec![track]);
    
    let scene = SceneState {
        root,
        tracks,
    };
    
    // 2. Setup Timeline
    let config = VideoConfig {
        width: 400,
        height: 400,
        fps: 10,
        duration_seconds: 1.0,
    };
    let timeline = Timeline::new(config);
    
    // 3. Init Pipeline
    let mut pipeline = Pipeline::new(timeline, scene);
    
    // 4. Render Frame 0 (t=0, width=100)
    // eprintln!("Rendering Frame 0...");
    // let f1 = pipeline.render_frame().expect("Frame 0 Render Failed");
    
    // Logic Verification
    pipeline.apply_motion(0.0);
    // Check root width. LayoutNode doesn't expose evaluated size directly here (compute_layout does),
    // but apply_motion updates STYLE.
    if let lyxal_layout::Dimension::Points(w) = pipeline.scene.root.style.width {
         assert_eq!(w, 100.0, "Frame 0 Width Mismatch");
    } else {
         panic!("Width style not set to Points");
    }

    // 5. Render Frame 5 (t=0.5, width=150)
    pipeline.timeline.current_frame = 5; // t = 0.5s
    // eprintln!("Rendering Frame 5...");
    
    pipeline.apply_motion(0.5);
    if let lyxal_layout::Dimension::Points(w) = pipeline.scene.root.style.width {
         assert_eq!(w, 150.0, "Frame 5 Width Mismatch (Expected 150.0, got {})", w);
    } else {
         panic!("Width style not set to Points @ Frame 5");
    }
    
    // 6. Determinism Check
    pipeline.apply_motion(0.5);
    if let lyxal_layout::Dimension::Points(w) = pipeline.scene.root.style.width {
         assert_eq!(w, 150.0, "Determinism Failed");
    }
}

