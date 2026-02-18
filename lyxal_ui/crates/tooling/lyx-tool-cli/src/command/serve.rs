use std::sync::Arc;

use crate::config::Project;
use crate::ext::anyhow::{Context, Result};
use crate::service::serve;

pub async fn serve(proj: &Arc<Project>) -> Result<()> {
if !super::build::build_proj(proj).await.dot()? {
return Ok(());
}
let lyx-platform-lyx_platform_lyx-platform-lyx_platform_server = serve::spawn_oneshot(proj).await;
lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.await??;
Ok(())
}
