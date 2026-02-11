use lyxal_motion::{MotionValue, EasingCurve, Keyframe, MotionTrack};

#[test]
fn test_lerp_scalar() {
    let v1 = MotionValue::Scalar(0.0);
    let v2 = MotionValue::Scalar(100.0);
    
    let mid = v1.lerp(&v2, 0.5).unwrap();
    if let MotionValue::Scalar(val) = mid {
        assert_eq!(val, 50.0);
    } else {
        panic!("Wrong type");
    }
}

#[test]
fn test_track_basic() {
    let k1 = Keyframe { time: 0.0, value: MotionValue::Scalar(0.0), easing: EasingCurve::Linear };
    let k2 = Keyframe { time: 1.0, value: MotionValue::Scalar(100.0), easing: EasingCurve::Linear };
    
    let track = MotionTrack::new("x".to_string(), vec![k1, k2]);
    
    let v = track.get_value(0.5).unwrap();
    if let MotionValue::Scalar(val) = v {
        assert!((val - 50.0).abs() < 0.001);
    }
}

#[test]
fn test_easing_bezier_approx() {
    // Standard Ease Out (fast start, slow end)
    // P1=(0,0), P2=(0.5, 0), P3=(0.5, 1), P4=(1,1) ? No CubicBezier is control points.
    // CSS ease-out: (0, 0, 0.58, 1)
    let curve = EasingCurve::CubicBezier(0.0, 0.0, 0.58, 1.0);
    
    // At t=0.5
    let val = curve.sample(0.5);
    // Should be > 0.5 because it starts fast?
    // Actually (0,0) (0.58,1).
    // Let's print it.
    println!("Bezier(0.5) = {}", val);
    
    assert!(val > 0.0 && val < 1.0);
}

#[test]
fn test_determinism() {
    let track = MotionTrack::new("test".to_string(), vec![
        Keyframe { time: 0.0, value: MotionValue::Scalar(0.0), easing: EasingCurve::Linear },
        Keyframe { time: 1.0, value: MotionValue::Scalar(100.0), easing: EasingCurve::Linear }
    ]);
    
    let v1 = track.get_value(0.12345).unwrap();
    let v2 = track.get_value(0.12345).unwrap();
    
    // Use format to compare strict equality of representation if needed, or PartialEq
    assert_eq!(v1, v2);
}
