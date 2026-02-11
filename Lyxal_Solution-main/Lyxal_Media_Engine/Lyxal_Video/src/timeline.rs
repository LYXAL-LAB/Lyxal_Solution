use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct VideoConfig {
    pub width: u32,
    pub height: u32,
    pub fps: u32,
    pub duration_seconds: f32,
}

impl Default for VideoConfig {
    fn default() -> Self {
        Self {
            width: 1920,
            height: 1080,
            fps: 30,
            duration_seconds: 5.0,
        }
    }
}

pub struct Timeline {
    pub config: VideoConfig,
    pub current_frame: u32,
}

impl Timeline {
    pub fn new(config: VideoConfig) -> Self {
        Self {
            config,
            current_frame: 0,
        }
    }

    pub fn total_frames(&self) -> u32 {
        (self.config.duration_seconds * self.config.fps as f32).ceil() as u32
    }

    pub fn current_time(&self) -> f32 {
        self.current_frame as f32 / self.config.fps as f32
    }
    
    pub fn next_frame(&mut self) -> bool {
        if self.current_frame < self.total_frames() {
            self.current_frame += 1;
            true
        } else {
            false
        }
    }
    
    pub fn reset(&mut self) {
        self.current_frame = 0;
    }
}
