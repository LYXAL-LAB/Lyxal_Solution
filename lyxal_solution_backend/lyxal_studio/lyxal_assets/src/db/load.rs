pub struct AssetLoader;
impl AssetLoader {
    pub fn get_load_query(project_id: &str) -> String {
        format!(
            "SELECT id, projectId, name, filename, description, file.* \n             FROM asset WHERE projectId = '{}' AND file.status = 'UPLOADED' \n             ORDER BY id ASC", 
            project_id
        )
    }
}

