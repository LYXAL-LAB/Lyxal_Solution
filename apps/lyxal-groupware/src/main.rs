// SPDX-License-Identifier: AGPL-3.0-only

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    lyxal_groupware::run().await
}
