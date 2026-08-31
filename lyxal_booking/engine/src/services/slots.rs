use lyxal_surreal::LyxalSurrealCall;
use serde::Serialize;

#[derive(Debug, Clone, Serialize)]
struct CalculateSlotsParams {
    event_type_slug: String,
    from: String,
    to: String,
    timezone: String,
}

/// Service neutre d'orchestration du calcul de disponibilite.
pub async fn compute_slots(
    store: &crate::db::SurrealBookingStore,
    query: &crate::contracts::availability::AvailabilityQuery,
) -> anyhow::Result<crate::contracts::availability::AvailabilityResponse> {
    // 1. Validation métier de la plage temporelle (max MAX_AVAILABILITY_RANGE_DAYS jours, to > from)
    let (from_dt, to_dt) = crate::services::availability::validate_range(&query.date_from, &query.date_to)?;

    // 2. Normalisation et validation de la timezone IANA
    let tz = crate::services::availability::normalize_timezone(&query.time_zone)?;

    let from_rfc = from_dt.to_rfc3339();
    let to_rfc = to_dt.to_rfc3339();

    // 3. Implémentation interne isolee
    let params = CalculateSlotsParams {
        event_type_slug: query.event_type_slug.clone(),
        from: from_rfc,
        to: to_rfc,
        timezone: tz,
    };
    let slots: Vec<crate::contracts::availability::AvailabilitySlotResponse> = store
        .call_fn("booking_calculate_slots", params)
        .await
        .unwrap_or_default();

    Ok(crate::contracts::availability::AvailabilityResponse { slots })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::contracts::availability::AvailabilityQuery;

    #[test]
    fn test_compute_slots_validation_fails_on_inverted_range() {
        let query = AvailabilityQuery {
            event_type_slug: "consultation".to_string(),
            date_from: "2026-08-10T23:59:59Z".to_string(),
            date_to: "2026-08-01T00:00:00Z".to_string(),
            time_zone: "UTC".to_string(),
        };
        // validate_range doit échouer si date_to <= date_from
        let res = crate::services::availability::validate_range(&query.date_from, &query.date_to);
        assert!(res.is_err());
    }

    #[test]
    fn test_compute_slots_validation_succeeds_on_valid_range() {
        let query = AvailabilityQuery {
            event_type_slug: "consultation".to_string(),
            date_from: "2026-08-01T00:00:00Z".to_string(),
            date_to: "2026-08-05T23:59:59Z".to_string(),
            time_zone: "Europe/Paris".to_string(),
        };
        let res = crate::services::availability::validate_range(&query.date_from, &query.date_to);
        assert!(res.is_ok());
    }
}

