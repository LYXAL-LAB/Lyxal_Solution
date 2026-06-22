#[derive(Debug, Clone, Copy)]
pub struct Rect {
    pub left: f64,
    pub top: f64,
    pub width: f64,
    pub height: f64,
}

#[derive(Debug, Clone, Copy)]
pub struct Point { pub x: f64, pub y: f64 }

impl Rect {
    pub fn distance_to_point(&self, p: Point) -> f64 {
        let dx = (self.left - p.x).max(0.0).max(p.x - (self.left + self.width));
        let dy = (self.top - p.y).max(0.0).max(p.y - (self.top + self.height));
        (dx * dx + dy * dy).sqrt()
    }
}

