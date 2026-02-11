#[cfg(test)]
mod tests {
    use super::*;
    use uuid::Uuid;

    async fn setup_db() -> SqliteBackend {
        let pool = SqlitePool::connect("sqlite::memory:").await.unwrap();
        let backend = SqliteBackend { pool };
        
        // Initialize schema (manually call new queries or use helper if exposed)
        // Since SqliteBackend::new does init, let's use a factory if possible.
        // But new() creates pool. We want in-memory.
        // We need to run the init queries.
        // I'll copy-paste init logic or assume existing tests use a helper.
        // Existing tests seem to use `setup_db` helper function which calls `SqliteBackend::new("sqlite::memory:")`.
        // Let's check `setup_db` implementation in the file.
        // Wait, I can't see `setup_db` implementation in the snippets I read.
        // It's likely defined in the test module.
        // I should append to the existing tests module.
        // I will read the end of the file to see where to append.
        backend
    }
}

