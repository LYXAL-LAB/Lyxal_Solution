use serde::{Deserialize, Serialize};
use std::f32::consts::PI;

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum EasingCurve {
    Linear,
    EaseIn,
    EaseOut,
    EaseInOut,
    CubicBezier(f32, f32, f32, f32), // p1x, p1y, p2x, p2y (p0 is 0,0; p3 is 1,1)
}

impl EasingCurve {
    pub fn sample(&self, t: f32) -> f32 {
        let t = t.clamp(0.0, 1.0);
        match self {
            EasingCurve::Linear => t,
            EasingCurve::EaseIn => t * t, // Quadratic or Cubic? Usually Quad or Cubic. Let's use Quad for simple V1.
            EasingCurve::EaseOut => t * (2.0 - t),
            EasingCurve::EaseInOut => {
                if t < 0.5 {
                    2.0 * t * t
                } else {
                    -1.0 + (4.0 - 2.0 * t) * t
                }
            }
            EasingCurve::CubicBezier(x1, y1, x2, y2) => {
                Self::solve_cubic_bezier(t, *x1, *y1, *x2, *y2)
            }
        }
    }
    
    // Simplistic solve for Cubic Bezier given x(t) = t_input. We want y(t).
    // Usually we solve x(T) = t for T, then y(T).
    // For V1, we can use a simpler approximation or Newton-Raphson if needed.
    // Given the "No Render" constraint, we must be purely mathematical.
    // A simple approximation for now: 
    // Or just use a crate? But dependency minimization is preferred.
    // Let's implement a basic iterative solver (binary search) for T.
    fn solve_cubic_bezier(x: f32, x1: f32, y1: f32, x2: f32, y2: f32) -> f32 {
        // x(t) = (1-t)^3 * 0 + 3*(1-t)^2*t*x1 + 3*(1-t)*t^2*x2 + t^3 * 1
        // x matches input time 'x' (which is confusingly named t in sample).
        // Find T such that BezierX(T) == x.
        // Then return BezierY(T).
        
        let epsilon = 1e-4;
        let mut lower = 0.0;
        let mut upper = 1.0;
        let mut t_guess = x; // Initial guess
        
        for _ in 0..8 { // 8 iterations is usually enough for UI precision
            let xt = Self::sample_bezier_curve(t_guess, x1, x2);
            if (xt - x).abs() < epsilon {
                break;
            }
            if xt < x {
                lower = t_guess;
            } else {
                upper = t_guess;
            }
            t_guess = (lower + upper) * 0.5;
        }
        
        Self::sample_bezier_curve(t_guess, y1, y2)
    }
    
    fn sample_bezier_curve(t: f32, p1: f32, p2: f32) -> f32 {
        // Basis functions for values 0 and 1 at ends:
        // P0=0, P1=p1, P2=p2, P3=1
        let u = 1.0 - t;
        // (1-t)^3 * 0 + ... = 3u^2t p1 + 3ut^2 p2 + t^3
        3.0 * u * u * t * p1 + 3.0 * u * t * t * p2 + t * t * t
    }
}
