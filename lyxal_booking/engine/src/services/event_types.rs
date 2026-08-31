use anyhow::Result;
use serde::Serialize;
use surrealdb::RecordId;

use crate::contracts::auth::AuthenticatedUser;
use crate::contracts::event_types::{
    CreateEventTypeRequest, DeleteEventTypeResponse, EventTypeResponse, UpdateEventTypeRequest,
};
use lyxal_surreal::LyxalSurrealCall;
use crate::db::SurrealBookingStore;

#[derive(Debug, Clone, Serialize)]
struct CreateEventTypeParams {
    user_id: String,
    title: String,
    slug: String,
    duration_minutes: u32,
    description: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
struct ListEventTypesParams {
    user_id: String,
}

#[derive(Debug, Clone, Serialize)]
struct GetEventTypeParams {
    user_id: String,
    event_type_id: RecordId,
}

#[derive(Debug, Clone, Serialize)]
struct UpdateEventTypeParams {
    user_id: String,
    event_type_id: RecordId,
    title: Option<String>,
    slug: Option<String>,
    duration_minutes: Option<u32>,
    description: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
struct DeleteEventTypeParams {
    user_id: String,
    event_type_id: RecordId,
}

#[derive(Debug, Clone, Serialize)]
struct ToggleEventTypeParams {
    user_id: String,
    id: RecordId,
}

#[derive(Debug, Clone, Serialize)]
struct GetEventTypeResourcesParams {
    event_type_id: RecordId,
}

#[derive(Debug, Clone, Serialize)]
struct UpdateEventTypeResourcesParams {
    user_id: String,
    slug: String,
    resource_ids: Vec<String>,
}

/// Crée un nouveau type d'événement / créneau de réservation (ex: "Consultation 30 min").
pub async fn create_event_type(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    request: &CreateEventTypeRequest,
) -> Result<EventTypeResponse> {
    let params = CreateEventTypeParams {
        user_id: auth.user_id.clone(),
        title: request.title.clone(),
        slug: request.slug.clone(),
        duration_minutes: request.duration_minutes,
        description: request.description.clone(),
    };
    let response: EventTypeResponse = store.call_fn("booking_create_event_type", params).await?;

    Ok(response)
}

/// Liste l'ensemble des types d'événements de l'utilisateur authentifié.
pub async fn list_event_types(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
) -> Result<Vec<EventTypeResponse>> {
    let params = ListEventTypesParams {
        user_id: auth.user_id.clone(),
    };
    let event_types: Vec<EventTypeResponse> = store.call_fn("booking_list_event_types", params).await?;

    Ok(event_types)
}

/// Récupère les détails d'un type d'événement par son RecordId.
pub async fn get_event_type(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    event_type_id: &RecordId,
) -> Result<EventTypeResponse> {
    let params = GetEventTypeParams {
        user_id: auth.user_id.clone(),
        event_type_id: event_type_id.clone(),
    };
    let event_type: EventTypeResponse = store.call_fn("booking_get_event_type", params).await?;

    Ok(event_type)
}

/// Met à jour les propriétés d'un type d'événement.
pub async fn update_event_type(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    event_type_id: &RecordId,
    request: &UpdateEventTypeRequest,
) -> Result<EventTypeResponse> {
    let params = UpdateEventTypeParams {
        user_id: auth.user_id.clone(),
        event_type_id: event_type_id.clone(),
        title: request.title.clone(),
        slug: request.slug.clone(),
        duration_minutes: request.duration_minutes,
        description: request.description.clone(),
    };
    let response: EventTypeResponse = store.call_fn("booking_update_event_type", params).await?;

    Ok(response)
}

/// Supprime proprement un type d'événement.
pub async fn delete_event_type(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    event_type_id: &RecordId,
) -> Result<DeleteEventTypeResponse> {
    let params = DeleteEventTypeParams {
        user_id: auth.user_id.clone(),
        event_type_id: event_type_id.clone(),
    };
    let response: DeleteEventTypeResponse = store.call_fn("booking_delete_event_type", params).await?;

    Ok(response)
}

/// Bascule le statut d'activation / masquage d'un type d'événement (toggle hidden/active).
pub async fn toggle_event_type(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    event_type_id: &RecordId,
) -> Result<crate::contracts::event_types::ToggleEventTypeResponse> {
    let params = ToggleEventTypeParams {
        user_id: auth.user_id.clone(),
        id: event_type_id.clone(),
    };
    let response = store.call_fn("booking_toggle_event_type", params).await?;

    Ok(response)
}

/// Récupère la liste des IDs de ressources rattachées à un type d'événement.
pub async fn get_event_type_resources(
    store: &SurrealBookingStore,
    _auth: &AuthenticatedUser,
    event_type_id: &RecordId,
) -> Result<Vec<String>> {
    let params = GetEventTypeResourcesParams {
        event_type_id: event_type_id.clone(),
    };
    let resources: Vec<String> = store.call_fn("booking_get_event_type_resources", params).await?;

    Ok(resources)
}

/// Met à jour de manière atomique la sélection des ressources rattachées à un créneau.
pub async fn update_event_type_resources(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    slug: &str,
    resource_ids: &[String],
) -> Result<crate::contracts::event_types::EventTypeResourcesResponse> {
    let params = UpdateEventTypeResourcesParams {
        user_id: auth.user_id.clone(),
        slug: slug.to_string(),
        resource_ids: resource_ids.to_vec(),
    };
    let response = store.call_fn("booking_update_event_type_resources", params).await?;

    Ok(response)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[derive(Debug, Serialize)]
    struct CanManageParams {
        account_id: RecordId,
        event_type_id: RecordId,
    }

    #[derive(Debug, Serialize)]
    struct FindManageableParams {
        account_id: RecordId,
        slug: String,
    }

    #[test]
    fn test_can_manage_params_serialization() {
        let account_id = RecordId::from(("booking_account", "user123"));
        let event_type_id = RecordId::from(("booking_event_type", "et456"));
        let params = CanManageParams {
            account_id,
            event_type_id,
        };
        let val = serde_json::to_value(&params).unwrap();
        assert!(val.get("account_id").is_some());
        assert!(val.get("event_type_id").is_some());
    }

    #[test]
    fn test_find_manageable_params_serialization() {
        let account_id = RecordId::from(("booking_account", "user123"));
        let params = FindManageableParams {
            account_id,
            slug: "demo-meeting".to_string(),
        };
        let val = serde_json::to_value(&params).unwrap();
        assert_eq!(val["slug"], "demo-meeting");
    }
}

