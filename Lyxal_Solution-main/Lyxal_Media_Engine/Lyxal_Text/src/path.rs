use serde::{Deserialize, Serialize};
use std::f32::consts::PI;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum PathGeometry {
    Circle {
        radius: f32,
        center_x: f32,
        center_y: f32,
        start_angle: f32, // Radians. 0 = Right, PI/2 = Bottom (Screen coords)
        clockwise: bool,
    },
    // TODO: Arc, Bezier
}

pub struct PathPoint {
    pub x: f32,
    pub y: f32,
    pub rotation: f32, // Tangent angle in radians
}

impl PathGeometry {
    pub fn get_point(&self, distance: f32) -> PathPoint {
        match self {
            PathGeometry::Circle { radius, center_x, center_y, start_angle, clockwise } => {
                // Circumference = 2 * PI * r
                // angle_delta = dist / r
                let angle_delta = distance / radius;
                
                let angle = if *clockwise {
                    start_angle + angle_delta
                } else {
                    start_angle - angle_delta
                };
                
                let x = center_x + radius * angle.cos();
                let y = center_y + radius * angle.sin();
                
                // Tangent rotation
                // Tangent to circle at angle theta is theta + PI/2 (cw) or theta - PI/2 ??
                // Screen coords: Y down.
                // Circle point (cos, sin). Tangent vector (-sin, cos)?
                // Angle of tangent:
                // If clockwise (increasing angle): Tangent is +90 deg from radius.
                // If ccw: -90 deg.
                
                let rotation = if *clockwise {
                    angle + PI / 2.0
                } else {
                    angle - PI / 2.0
                };
                
                PathPoint { x, y, rotation }
            }
        }
    }
}
