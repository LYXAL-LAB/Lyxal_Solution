use std::fs;
use std::path::Path;

pub fn save_frame_sequence(frames: &[Vec<u8>], output_dir: &str) -> std::io::Result<()> {
    if !Path::new(output_dir).exists() {
        fs::create_dir_all(output_dir)?;
    }
    
    for (i, bytes) in frames.iter().enumerate() {
        let path = Path::new(output_dir).join(format!("frame_{:04}.png", i));
        fs::write(path, bytes)?;
    }
    Ok(())
}
