use crate::validate::validate_domain;
use crate::cname::generate_cname;

pub struct DomainOps;

impl DomainOps {
    /// PrÃ©pare les donnÃ©es pour la crÃ©ation d'un domaine (Portage de create dans domain.ts)
    pub fn prepare_create(project_id: &str, domain_name: &str, user_id: &str) -> Result<serde_json::Value, String> {
        let validated = validate_domain(domain_name)?;
        let cname = generate_cname(user_id);
        
        Ok(serde_json::json!({
            "projectId": project_id,
            "domain": validated,
            "cname": cname,
            "status": "INITIALIZING"
        }))
    }

    /// GÃ©nÃ¨re la requÃªte de suppression (Portage de remove dans domain.ts)
    pub fn get_remove_query(project_id: &str, domain_id: &str) -> String {
        format!("DELETE project_domain WHERE in = '{}' AND out = '{}'", project_id, domain_id)
    }
}

