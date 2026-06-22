use leptos::*;
use std::sync::Arc;
// use lyxal_core::engine::local::Mem; // DELETED because it doesn't exist
use lyxal_core_kvs::Datastore;
use lyxal_types::LyxalStudioData;

#[derive(Clone)]
pub struct LyxalState {
    // Le moteur de base de données réel de ton fork, tournant en mémoire
    pub ds: Arc<Datastore>,
}

impl LyxalState {
    pub async fn new() -> Self {
        // Initialise Lyxal en mode mémoire (très rapide pour le builder)
        // Note: Si Datastore::new("mem://") ne compile pas, il faudra ajuster ici.
        // Mais l'erreur actuelle est sur l'import.
        let ds = Datastore::new("mem://").await.unwrap();
        Self { ds: Arc::new(ds) }
    }

    /// Exécute une requête SQL Lyxal directement dans le navigateur
    pub async fn query(&self, sql: &str) -> Result<serde_json::Value, String> {
        // Ici on utiliserait le moteur interne de ton fork pour traiter le SQL
        // Pour l'instant, c'est le squelette de la connection
        Ok(serde_json::Value::Null)
    }

    /// Synchronise les données de LyxalStudioData vers la base Lyxal locale
    pub async fn sync_from_data(&self, data: &LyxalStudioData) {
        // TODO: Parcourir les variables et les insérer dans Lyxal
        // ex: "CREATE variable:nom_var SET value = '...'"
    }
}

/// Évalue une expression en utilisant le vrai moteur de ton fork Lyxal
#[component]
pub fn LyxalExpression(expr: String) -> impl IntoView {
    let state = use_context::<LyxalState>().expect("LyxalState missing");
    
    // On crée une ressource Leptos qui va appeler Lyxal
    let eval_res = create_resource(
        move || expr.clone(),
        move |e| {
            let s = state.clone();
            async move { s.query(&e).await }
        }
    );

    view! {
        <span>
            {move || match eval_res.get() {
                Some(Ok(val)) => val.to_string(),
                _ => "...".to_string()
            }}
        </span>
    }
}
