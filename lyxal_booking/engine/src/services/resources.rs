use anyhow::Result;
use serde::Serialize;
use surrealdb::RecordId;

use crate::contracts::auth::AuthenticatedUser;
use crate::contracts::resources::{
    CreateResourceRequest, DeleteResourceResponse, ResourceResponse, UpdateResourceRequest,
};
use lyxal_surreal::LyxalSurrealCall;
use crate::db::SurrealBookingStore;

#[derive(Debug, Clone, Serialize)]
struct CreateResourceParams {
    user_id: RecordId,
    name: String,
    resource_type: String,
    capacity: Option<i32>,
    location: Option<String>,
    description: Option<String>,
    feed_url: Option<String>,
    id: Option<RecordId>,
}

#[derive(Debug, Clone, Serialize)]
struct ListResourcesParams {
    user_id: RecordId,
}

#[derive(Debug, Clone, Serialize)]
struct GetResourceParams {
    resource_id: RecordId,
}

#[derive(Debug, Clone, Serialize)]
struct DeleteResourceParams {
    resource_id: RecordId,
}

#[derive(Debug, Clone, serde::Deserialize)]
struct CreateResourceResult {
    id: RecordId,
    created: bool,
}

#[derive(Debug, Clone, serde::Deserialize)]
struct DeleteResourceResult {
    resource_id: RecordId,
    deleted: bool,
}

// --- Services neutres d'orchestration pour les ressources ---

/// Crée une nouvelle ressource (salle, équipement, véhicule).
pub async fn create_resource(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    request: &CreateResourceRequest,
) -> Result<ResourceResponse> {
    let auth_rec = RecordId::from(("booking_account", auth.user_id.as_str()));
    let params = CreateResourceParams {
        user_id: auth_rec,
        name: request.name.clone(),
        resource_type: request.resource_type.clone(),
        capacity: request.capacity,
        location: request.location.clone(),
        description: request.description.clone(),
        feed_url: request.feed_url.clone(),
        id: None,
    };
    let res: CreateResourceResult = store
        .call_fn("booking_create_resource", params)
        .await?;

    Ok(ResourceResponse {
        id: res.id.to_string(),
        name: request.name.clone(),
        resource_type: request.resource_type.clone(),
        capacity: request.capacity,
        location: request.location.clone(),
        description: request.description.clone(),
        feed_url: request.feed_url.clone(),
        enabled: true,
    })
}

/// Liste les ressources configurées pour l'utilisateur.
pub async fn list_resources(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
) -> Result<Vec<ResourceResponse>> {
    let auth_rec = RecordId::from(("booking_account", auth.user_id.as_str()));
    let params = ListResourcesParams { user_id: auth_rec };
    let resources: Vec<ResourceResponse> = store
        .call_fn("booking_list_resources", params)
        .await?;

    Ok(resources)
}

/// Récupère les détails d'une ressource par son RecordId.
pub async fn get_resource(
    store: &SurrealBookingStore,
    _auth: &AuthenticatedUser,
    resource_id: &RecordId,
) -> Result<ResourceResponse> {
    let params = GetResourceParams {
        resource_id: resource_id.clone(),
    };
    let resource: ResourceResponse = store
        .call_fn("booking_get_resource", params)
        .await?;

    Ok(resource)
}

#[derive(Debug, Clone, Serialize)]
struct UpdateResourceParams {
    resource_id: RecordId,
    name: Option<String>,
    description: Option<String>,
    capacity: Option<i32>,
    location: Option<String>,
    enabled: Option<bool>,
}

/// Met à jour les informations d'une ressource via primitive scalaire fn::booking_update_resource.
pub async fn update_resource(
    store: &SurrealBookingStore,
    _auth: &AuthenticatedUser,
    resource_id: &RecordId,
    request: &UpdateResourceRequest,
) -> Result<ResourceResponse> {
    let params = UpdateResourceParams {
        resource_id: resource_id.clone(),
        name: Some(request.name.clone()),
        description: request.description.clone(),
        capacity: request.capacity,
        location: request.location.clone(),
        enabled: None,
    };
    let res: ResourceResponse = store
        .call_fn("booking_update_resource", params)
        .await?;

    Ok(res)
}

/// Supprime une ressource de manière atomique.
pub async fn delete_resource(
    store: &SurrealBookingStore,
    _auth: &AuthenticatedUser,
    resource_id: &RecordId,
) -> Result<DeleteResourceResponse> {
    let params = DeleteResourceParams {
        resource_id: resource_id.clone(),
    };
    let res: DeleteResourceResult = store
        .call_fn("booking_delete_resource", params)
        .await?;

    Ok(DeleteResourceResponse {
        deleted: res.deleted,
    })
}

/// Orchestration de la synchronisation d'un flux d'agenda de ressource (ICS/CalDAV).
pub async fn sync_resource(
    _store: &SurrealBookingStore,
    _auth: &AuthenticatedUser,
    resource_id: &RecordId,
) -> Result<crate::contracts::resources::SyncResourceResponse> {
    Ok(crate::contracts::resources::SyncResourceResponse {
        resource_id: resource_id.to_string(),
        synchronized_events: 0,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_create_resource_params_serialization() {
        let user_id = RecordId::from(("booking_account", "user_admin"));
        let params = CreateResourceParams {
            user_id,
            name: "Salle Conférence Alpha".to_string(),
            resource_type: "room".to_string(),
            capacity: Some(25),
            location: Some("Étage 3".to_string()),
            description: Some("Équipée vidéoprojecteur".to_string()),
            feed_url: None,
            id: None,
        };
        let val = serde_json::to_value(&params).unwrap();
        assert_eq!(val["name"], "Salle Conférence Alpha");
        assert_eq!(val["resource_type"], "room");
        assert_eq!(val["capacity"], 25);
    }

    #[test]
    fn test_delete_resource_params_serialization() {
        let resource_id = RecordId::from(("booking_resource", "res_99"));
        let params = DeleteResourceParams { resource_id };
        let val = serde_json::to_value(&params).unwrap();
        assert!(val.get("resource_id").is_some());
    }
}
