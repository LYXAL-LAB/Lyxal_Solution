pub struct SizeLimiter {
    pub max_size: u64,
    pub current_size: u64,
}

impl SizeLimiter {
    pub fn new(max_size: u64) -> Self {
        Self { max_size, current_size: 0 }
    }
    pub fn check(&mut self, chunk_size: u64) -> Result<(), String> {
        self.current_size += chunk_size;
        if self.current_size > self.max_size {
            return Err(format!("Size limit of {} bytes exceeded", self.max_size));
        }
        Ok(())
    }
}

