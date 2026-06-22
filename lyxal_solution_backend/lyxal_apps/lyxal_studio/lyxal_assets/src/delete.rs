pub struct Deleter;
impl Deleter {
    pub fn get_cleanup_queries(ids: Vec<String>, project_id: &str, file_names: Vec<String>) -> Vec<String> {
        let mut queries = vec![
            format!("UPDATE project SET previewImageAssetId = NONE WHERE id = '{}' AND previewImageAssetId IN {:?}", project_id, ids),
            format!("DELETE asset WHERE id IN {:?} AND projectId = '{}'", ids, project_id)
        ];
        for name in file_names {
            queries.push(format!("UPDATE file SET isDeleted = true WHERE name = '{}' AND count(<-has_asset<-project) = 0", name));
        }
        queries
    }
}

