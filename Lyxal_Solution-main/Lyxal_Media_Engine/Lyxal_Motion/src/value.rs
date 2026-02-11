use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum MotionValue {
    Scalar(f32),
    Vector2(f32, f32),
    Color(u8, u8, u8, u8), // RGBA
    TextReveal(usize), // Integer index, interpolation floors/rounds?
}

impl MotionValue {
    pub fn lerp(&self, other: &Self, t: f32) -> Option<Self> {
        match (self, other) {
            (MotionValue::Scalar(a), MotionValue::Scalar(b)) => {
                Some(MotionValue::Scalar(a + (b - a) * t))
            }
            (MotionValue::Vector2(ax, ay), MotionValue::Vector2(bx, by)) => {
                Some(MotionValue::Vector2(
                    ax + (bx - ax) * t,
                    ay + (by - ay) * t
                ))
            }
            (MotionValue::Color(r1, g1, b1, a1), MotionValue::Color(r2, g2, b2, a2)) => {
                let interpolate = |x: u8, y: u8| -> u8 {
                    ((x as f32) + ((y as f32) - (x as f32)) * t) as u8
                };
                Some(MotionValue::Color(
                    interpolate(*r1, *r2),
                    interpolate(*g1, *g2),
                    interpolate(*b1, *b2),
                    interpolate(*a1, *a2)
                ))
            }
            (MotionValue::TextReveal(a), MotionValue::TextReveal(b)) => {
                // Discrete or Float -> Int? 
                // Usually Reveal is 0 to N. Interpolating 0 to 10 at t=0.5 -> 5.
                let val = (*a as f32) + ((*b as f32) - (*a as f32)) * t;
                Some(MotionValue::TextReveal(val.round() as usize))
            }
            _ => None // Mismatched types
        }
    }
}
