use anyhow::{bail, Result};
use chrono::{DateTime, Utc};
use chrono_tz::Tz;

/// Plage maximale autorisee pour la recherche de disponibilites (empeche l'explosion du moteur RRULE).
pub const MAX_AVAILABILITY_RANGE_DAYS: i64 = 60;

/// Valide la fenetre temporelle (from, to) et garantit que to > from et (to - from) <= MAX_AVAILABILITY_RANGE_DAYS.
pub fn validate_range(from_str: &str, to_str: &str) -> Result<(DateTime<Utc>, DateTime<Utc>)> {
    if from_str.trim().is_empty() || to_str.trim().is_empty() {
        bail!("Les parametres 'from' et 'to' sont obligatoires.");
    }

    let from = DateTime::parse_from_rfc3339(from_str)
        .map(|dt| dt.with_timezone(&Utc))
        .or_else(|_| {
            DateTime::parse_from_str(&format!("{}T00:00:00Z", from_str.trim()), "%Y-%m-%dT%H:%M:%SZ")
                .map(|dt| dt.with_timezone(&Utc))
        })
        .map_err(|_| anyhow::anyhow!("Format de date 'from' invalide. Utilisez ISO-8601 / RFC3339 (ex: 2026-08-01T00:00:00Z)."))?;

    let to = DateTime::parse_from_rfc3339(to_str)
        .map(|dt| dt.with_timezone(&Utc))
        .or_else(|_| {
            DateTime::parse_from_str(&format!("{}T23:59:59Z", to_str.trim()), "%Y-%m-%dT%H:%M:%SZ")
                .map(|dt| dt.with_timezone(&Utc))
        })
        .map_err(|_| anyhow::anyhow!("Format de date 'to' invalide. Utilisez ISO-8601 / RFC3339 (ex: 2026-08-31T23:59:59Z)."))?;

    if to <= from {
        bail!("La date de fin 'to' doit etre strictement superieure a la date de debut 'from'.");
    }

    let duration_days = (to - from).num_days();
    if duration_days > MAX_AVAILABILITY_RANGE_DAYS {
        bail!(
            "La plage de recherche ({}) depasse la limite maximale autorisee de {} jours.",
            duration_days,
            MAX_AVAILABILITY_RANGE_DAYS
        );
    }

    Ok((from, to))
}

/// Normalise et valide le nom IANA de la timezone.
pub fn normalize_timezone(tz_str: &str) -> Result<String> {
    let trimmed = tz_str.trim();
    if trimmed.is_empty() || trimmed.eq_ignore_ascii_case("auto") {
        return Ok("UTC".to_string());
    }

    if trimmed.parse::<Tz>().is_err() {
        bail!("Timezone IANA non reconnue: {}", trimmed);
    }

    Ok(trimmed.to_string())
}

use lyxal_surreal::LyxalSurrealCall;
use serde::Serialize;

#[derive(Debug, Clone, Serialize)]
struct GetAvailableSlotsParams {
    event_type_slug: String,
    date_from: String,
    date_to: String,
    time_zone: String,
}

#[derive(Debug, Clone, Serialize)]
struct GetUserAvailabilityRulesParams {
    user_id: String,
}

#[derive(Debug, Clone, Serialize)]
struct SaveAvailabilityRulesParams {
    user_id: String,
    name: String,
    time_zone: String,
    is_default: bool,
    rules: Vec<crate::contracts::availability::AvailabilityScheduleRule>,
}

#[derive(Debug, Clone, Serialize)]
struct GetAvailabilityOverridesParams {
    user_id: String,
}

#[derive(Debug, Clone, Serialize)]
struct SaveAvailabilityOverrideParams {
    user_id: String,
    date: String,
    unavailable: bool,
    start_time: Option<String>,
    end_time: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
struct DeleteAvailabilityOverrideParams {
    id: String,
}

/// Calcule les créneaux disponibles pour un type d'événement et une fenêtre temporelle donnée.
pub async fn get_available_slots(
    store: &crate::db::SurrealBookingStore,
    _auth: Option<&crate::contracts::auth::AuthenticatedUser>,
    query: &crate::contracts::availability::AvailabilityQuery,
) -> Result<crate::contracts::availability::AvailabilityResponse> {
    let (from_dt, to_dt) = validate_range(&query.date_from, &query.date_to)?;
    let clean_tz = normalize_timezone(&query.time_zone)?;

    let params = GetAvailableSlotsParams {
        event_type_slug: query.event_type_slug.clone(),
        date_from: from_dt.to_rfc3339(),
        date_to: to_dt.to_rfc3339(),
        time_zone: clean_tz,
    };
    let slots: Vec<crate::contracts::availability::AvailabilitySlotResponse> = store
        .call_fn("booking_get_available_slots", params)
        .await?;

    Ok(crate::contracts::availability::AvailabilityResponse { slots })
}

/// Récupère le planning d'ouverture de l'utilisateur authentifié.
pub async fn get_availability_schedules(
    store: &crate::db::SurrealBookingStore,
    auth: &crate::contracts::auth::AuthenticatedUser,
) -> Result<Vec<crate::contracts::availability::AvailabilityScheduleResponse>> {
    let params = GetUserAvailabilityRulesParams {
        user_id: auth.user_id.clone(),
    };
    let schedules: Vec<crate::contracts::availability::AvailabilityScheduleResponse> = store
        .call_fn("booking_get_user_availability_rules", params)
        .await?;

    Ok(schedules)
}

/// Enregistre les règles du planning d'ouverture de l'utilisateur.
pub async fn save_availability_schedule(
    store: &crate::db::SurrealBookingStore,
    auth: &crate::contracts::auth::AuthenticatedUser,
    request: &crate::contracts::availability::SaveAvailabilityScheduleRequest,
) -> Result<crate::contracts::availability::AvailabilityScheduleResponse> {
    let params = SaveAvailabilityRulesParams {
        user_id: auth.user_id.clone(),
        name: request.name.clone(),
        time_zone: request.time_zone.clone(),
        is_default: request.is_default,
        rules: request.rules.clone(),
    };
    let response: crate::contracts::availability::AvailabilityScheduleResponse = store
        .call_fn("booking_save_availability_rules", params)
        .await?;

    Ok(response)
}

/// Récupère la liste des exceptions ponctuelles de disponibilité de l'utilisateur.
pub async fn get_availability_overrides(
    store: &crate::db::SurrealBookingStore,
    auth: &crate::contracts::auth::AuthenticatedUser,
) -> Result<Vec<crate::contracts::availability::AvailabilityOverrideResponse>> {
    let params = GetAvailabilityOverridesParams {
        user_id: auth.user_id.clone(),
    };
    let overrides: Vec<crate::contracts::availability::AvailabilityOverrideResponse> = store
        .call_fn("booking_get_availability_overrides", params)
        .await?;

    Ok(overrides)
}

/// Enregistre ou met à jour une exception ponctuelle de disponibilité.
pub async fn save_availability_override(
    store: &crate::db::SurrealBookingStore,
    auth: &crate::contracts::auth::AuthenticatedUser,
    request: &crate::contracts::availability::SaveAvailabilityOverrideRequest,
) -> Result<crate::contracts::availability::AvailabilityOverrideResponse> {
    let params = SaveAvailabilityOverrideParams {
        user_id: auth.user_id.clone(),
        date: request.date.clone(),
        unavailable: request.unavailable,
        start_time: request.start_time.clone(),
        end_time: request.end_time.clone(),
    };
    let response: crate::contracts::availability::AvailabilityOverrideResponse = store
        .call_fn("booking_save_availability_override", params)
        .await?;

    Ok(response)
}

/// Supprime une exception ponctuelle par son ID.
pub async fn delete_availability_override(
    store: &crate::db::SurrealBookingStore,
    _auth: &crate::contracts::auth::AuthenticatedUser,
    override_id: &str,
) -> Result<crate::contracts::availability::DeleteAvailabilityOverrideResponse> {
    let params = DeleteAvailabilityOverrideParams {
        id: override_id.to_string(),
    };
    let response: crate::contracts::availability::DeleteAvailabilityOverrideResponse = store
        .call_fn("booking_delete_availability_override", params)
        .await?;

    Ok(response)
}

/// Vérifie si une période occupée chevauche l'intervalle [buf_start, buf_end).
pub fn has_conflict(
    busy: &[(chrono::NaiveDateTime, chrono::NaiveDateTime)],
    buf_start: chrono::NaiveDateTime,
    buf_end: chrono::NaiveDateTime,
) -> bool {
    busy.iter().any(|(s, e)| *s < buf_end && *e > buf_start)
}

/// Parse une chaîne de créneaux par jour (format "1:09:00-17:00;2:09:00-12:00,13:00-17:00").
pub fn parse_avail_schedule(
    schedule: Option<&str>,
    legacy_days: Option<&str>,
    legacy_windows: Option<&str>,
    legacy_start: Option<&str>,
    legacy_end: Option<&str>,
    user_default: Option<&str>,
) -> std::collections::BTreeMap<i32, Vec<(String, String)>> {
    if let Some(s) = schedule {
        let parsed = parse_schedule_string(s);
        if !parsed.is_empty() {
            return parsed;
        }
    }

    if let Some(s) = user_default {
        let parsed = parse_schedule_string(s);
        if !parsed.is_empty() {
            return parsed;
        }
    }

    let mut result = std::collections::BTreeMap::new();
    let days_str = legacy_days.unwrap_or("1,2,3,4,5");
    let windows = parse_avail_windows(legacy_windows, legacy_start, legacy_end);
    for day_str in days_str.split(',') {
        if let Ok(day) = day_str.trim().parse::<i32>() {
            if (0..=6).contains(&day) {
                result.insert(day, windows.clone());
            }
        }
    }
    result
}

fn parse_schedule_string(s: &str) -> std::collections::BTreeMap<i32, Vec<(String, String)>> {
    let mut map = std::collections::BTreeMap::new();
    for part in s.split(';') {
        let trimmed = part.trim();
        if trimmed.is_empty() {
            continue;
        }
        if let Some((day_str, windows_str)) = trimmed.split_once(':') {
            if let Ok(day) = day_str.trim().parse::<i32>() {
                if (0..=6).contains(&day) {
                    let mut windows = Vec::new();
                    for win in windows_str.split(',') {
                        let win_trimmed = win.trim();
                        if let Some((start, end)) = win_trimmed.split_once('-') {
                            let s = start.trim().to_string();
                            let e = end.trim().to_string();
                            if !s.is_empty() && !e.is_empty() {
                                windows.push((s, e));
                            }
                        }
                    }
                    if !windows.is_empty() {
                        map.insert(day, windows);
                    }
                }
            }
        }
    }
    map
}

fn parse_avail_windows(
    _windows: Option<&str>,
    start: Option<&str>,
    end: Option<&str>,
) -> Vec<(String, String)> {
    let s = start.unwrap_or("09:00").trim().to_string();
    let e = end.unwrap_or("17:00").trim().to_string();
    vec![(
        if s.is_empty() { "09:00".to_string() } else { s },
        if e.is_empty() { "17:00".to_string() } else { e },
    )]
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::{NaiveDate, NaiveDateTime};

    fn dt(y: i32, m: u32, d: u32, h: u32, mi: u32) -> NaiveDateTime {
        NaiveDate::from_ymd_opt(y, m, d)
            .unwrap()
            .and_hms_opt(h, mi, 0)
            .unwrap()
    }

    #[test]
    fn parse_avail_schedule_uses_user_default_when_submitted_is_empty() {
        let result = parse_avail_schedule(Some(""), None, None, None, None, Some("2:14:00-18:00"));
        assert_eq!(result.len(), 1);
        let windows = result.get(&2).expect("Tuesday should be set");
        assert_eq!(windows, &vec![("14:00".to_string(), "18:00".to_string())]);
    }

    #[test]
    fn parse_avail_schedule_prefers_submitted_over_user_default() {
        let result = parse_avail_schedule(
            Some("3:10:00-12:00"),
            None,
            None,
            None,
            None,
            Some("2:14:00-18:00"),
        );
        assert_eq!(result.len(), 1);
        let windows = result.get(&3).expect("Wednesday should be set");
        assert_eq!(windows, &vec![("10:00".to_string(), "12:00".to_string())]);
    }

    #[test]
    fn parse_avail_schedule_falls_back_to_legacy_when_both_empty() {
        let result = parse_avail_schedule(Some(""), None, None, None, None, Some(""));
        assert_eq!(result.len(), 5);
        for day in 1..=5 {
            let windows = result.get(&day).expect("weekday should be set");
            assert_eq!(windows, &vec![("09:00".to_string(), "17:00".to_string())]);
        }
    }

    #[test]
    fn conflict_overlapping_event() {
        let busy = vec![(dt(2026, 3, 15, 10, 0), dt(2026, 3, 15, 11, 0))];
        assert!(has_conflict(
            &busy,
            dt(2026, 3, 15, 10, 30),
            dt(2026, 3, 15, 11, 30)
        ));
    }

    #[test]
    fn conflict_no_overlap() {
        let busy = vec![(dt(2026, 3, 15, 10, 0), dt(2026, 3, 15, 11, 0))];
        assert!(!has_conflict(
            &busy,
            dt(2026, 3, 15, 11, 0),
            dt(2026, 3, 15, 12, 0)
        ));
    }

    #[test]
    fn conflict_event_contains_slot() {
        let busy = vec![(dt(2026, 3, 15, 9, 0), dt(2026, 3, 15, 17, 0))];
        assert!(has_conflict(
            &busy,
            dt(2026, 3, 15, 10, 0),
            dt(2026, 3, 15, 11, 0)
        ));
    }

    #[test]
    fn conflict_slot_contains_event() {
        let busy = vec![(dt(2026, 3, 15, 10, 15), dt(2026, 3, 15, 10, 45))];
        assert!(has_conflict(
            &busy,
            dt(2026, 3, 15, 10, 0),
            dt(2026, 3, 15, 11, 0)
        ));
    }

    #[test]
    fn conflict_adjacent_not_conflicting() {
        let busy = vec![
            (dt(2026, 3, 15, 9, 0), dt(2026, 3, 15, 10, 0)),
            (dt(2026, 3, 15, 11, 0), dt(2026, 3, 15, 12, 0)),
        ];
        assert!(!has_conflict(
            &busy,
            dt(2026, 3, 15, 10, 0),
            dt(2026, 3, 15, 11, 0)
        ));
    }

    #[test]
    fn conflict_empty_busy_list() {
        let busy: Vec<(NaiveDateTime, NaiveDateTime)> = vec![];
        assert!(!has_conflict(
            &busy,
            dt(2026, 3, 15, 10, 0),
            dt(2026, 3, 15, 11, 0)
        ));
    }

    #[test]
    fn conflict_buffer_causes_overlap() {
        let busy = vec![(dt(2026, 3, 15, 10, 0), dt(2026, 3, 15, 11, 0))];
        assert!(has_conflict(
            &busy,
            dt(2026, 3, 15, 10, 45),
            dt(2026, 3, 15, 12, 0)
        ));
    }

    #[test]
    fn test_validate_range() {
        let from = "2026-08-01T00:00:00Z";
        let to = "2026-08-10T23:59:59Z";
        let res = validate_range(from, to);
        assert!(res.is_ok());

        // Inversé
        assert!(validate_range(to, from).is_err());

        // Plage > 60 jours
        let too_far = "2026-11-01T00:00:00Z";
        assert!(validate_range(from, too_far).is_err());
    }

    #[test]
    fn test_normalize_timezone() {
        assert_eq!(normalize_timezone("UTC").unwrap(), "UTC");
        assert_eq!(normalize_timezone("auto").unwrap(), "UTC");
        assert_eq!(normalize_timezone("Europe/Paris").unwrap(), "Europe/Paris");
        assert!(normalize_timezone("Invalid/Timezone_XYZ").is_err());
    }
}
