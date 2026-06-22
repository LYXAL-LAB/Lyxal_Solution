/// Portage de image-loaders.ts
pub fn ws_image_loader(src: &str, width: u32, quality: u32) -> String {
    // Note: This matches the Cloudflare-style URL construction in Webstudio
    let mut clean_src = src;
    if src.starts_with("/cgi/asset") {
        clean_src = &src["/cgi/asset".len()..];
    }
    format!("/cgi/image/width={},quality={},format=auto/{}", width, quality, clean_src.trim_start_matches('/'))
}

pub fn ws_video_loader(src: &str) -> String {
    let mut clean_src = src;
    if src.starts_with("/cgi/asset/") {
        clean_src = &src["/cgi/asset/".len()..];
    }
    format!("/cgi/video/{}", clean_src)
}

