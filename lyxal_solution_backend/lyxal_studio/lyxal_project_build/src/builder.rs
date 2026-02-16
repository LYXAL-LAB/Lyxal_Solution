use crate::schema::ProjectBuild;
use lyxal_types::project::LyxalStudioData;
use nanoid::nanoid;
use chrono::Utc;

pub struct ProjectBuilder;

impl ProjectBuilder {
    /// Traduction de la logique build.ts
    /// Prend les donnÃ©es complÃ¨tes et gÃ©nÃ¨re un build de production optimisÃ©.
    pub fn create_build(project_id: &str, data: LyxalStudioData) -> ProjectBuild {
        ProjectBuild {
            id: nanoid!(21),
            project_id: project_id.to_string(),
            data, // Note: Ici on pourrait implÃ©menter le stripping des data d'Ã©dition
            version: 1,
            created_at: Utc::now().to_rfc3339(),
        }
    }
}

