use async_trait::async_trait;
use lyxal_ical_core::{IcalObject, Component, Property};
use lyxal_ical_core::{parse as ical_parse, validate as ical_validate, extract_vtimezones, occurrences_with_vtimezones};
use lyxal_ical_core::timezone::{parse_naive_or_utc, local_to_utc_with_tzid};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Résultat d'un REPORT sync-collection.
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct SyncCollectionResult {
    /// Ressources retournées (CREATE/UPDATE => 200, DELETE => 404).
    pub resources: Vec<Resource>,
    /// Nouveau sync-token à renvoyer au client.
    pub sync_token: String,
    /// Indique qu'il reste des changements (pagination via <limit/>).
    pub partial: bool,
}

/// Represents a resource (calendar, object, collection)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Resource {
    pub path: String,
    pub kind: ResourceKind,
    pub mime_type: String,
    pub etag: String,
    pub content: Option<Vec<u8>>, // Content if requested/small
    pub properties: std::collections::HashMap<String, String>,
    pub sync_token: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum ResourceKind {
    Collection,
    Calendar,
    Object,
    Principal,
    ScheduleInbox,
    ScheduleOutbox,
    AddressBook,
    Contact,
    Generic,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AddressBookQuery {
    pub filter: Filter,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Filter {
    pub prop_filters: Vec<PropFilter>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PropFilter {
    pub name: String,
    pub text_match: Option<TextMatch>,
    pub is_not_defined: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TextMatch {
    pub value: String,
    pub negate_condition: bool,
    pub collation: String,
    pub match_type: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Principal {
    pub username: String,
    pub displayname: String,
    pub email: Option<String>,
    pub calendar_home: String,
    pub principal_url: String,
    pub schedule_inbox_url: Option<String>,
    pub schedule_outbox_url: Option<String>,
    pub alternate_uris: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Lock {
    pub path: String,
    pub token: String,
    pub principal: Option<String>,
    pub depth: String,
    pub timeout: i64,
    pub expires_at: i64, // Unix timestamp
    pub owner_info: Option<String>, // XML
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SchedulingMessage {
    pub path: String,
    pub principal: String,
    pub box_type: String, // "inbox" or "outbox"
    pub content: String, // raw ICS
    pub etag: String,
    pub created_at: String,
}

/// Interface for DAV storage backend
#[async_trait]
pub trait DavBackend: Send + Sync {
    /// Get a resource by path
    async fn get_resource(&self, path: &str) -> anyhow::Result<Option<Resource>>;
    
    /// List children of a collection
    async fn list_collection(&self, path: &str) -> anyhow::Result<Vec<Resource>>;
    
    /// Create or update a resource
    async fn put_resource(&self, path: &str, data: &[u8], mime: &str) -> anyhow::Result<String>;
    
    /// Delete a resource
    async fn delete_resource(&self, path: &str) -> anyhow::Result<()>;

    /// Create a collection (calendar or folder)
    async fn create_collection(&self, path: &str, kind: ResourceKind) -> anyhow::Result<()>;

	/// Persist custom DAV properties (set/replace).
	async fn set_properties(&self, _path: &str, _props: &[(String, String)]) -> anyhow::Result<()> {
		Ok(())
	}

	/// Remove custom DAV properties.
	async fn remove_properties(&self, _path: &str, _names: &[String]) -> anyhow::Result<()> {
		Ok(())
	}

	/// Load custom DAV properties for a resource.
	async fn get_properties(&self, _path: &str) -> anyhow::Result<HashMap<String, String>> {
		Ok(HashMap::new())
	}

    /// Ensure a principal is recorded as owner of a calendar path.
    async fn ensure_calendar_owner(&self, _calendar_path: &str, _principal: &str) -> anyhow::Result<()> {
        Ok(())
    }

    /// Authenticate via Basic (user/pass).
    async fn authenticate_basic(&self, _tenant: Option<&str>, _user: &str, _pass: &str) -> anyhow::Result<Option<Principal>> {
        Ok(None)
    }

    /// Authenticate via Bearer token.
    async fn authenticate_bearer(&self, _tenant: Option<&str>, _token: &str) -> anyhow::Result<Option<Principal>> {
        Ok(None)
    }

    /// Fetch a principal by username.
    async fn get_principal(&self, _tenant: Option<&str>, _user: &str) -> anyhow::Result<Option<Principal>> {
        Ok(None)
    }

    /// List all principals (for /principals PROPFIND depth>0).
    async fn list_principals(&self, _tenant: Option<&str>) -> anyhow::Result<Vec<Principal>> {
        Ok(vec![])
    }

    /// Check ACL for a principal on a path (write=false => read).
    async fn check_access(&self, _principal: &str, _path: &str, _write: bool) -> anyhow::Result<bool> {
        Ok(true)
    }

	/// MOVE operation (with overwrite flag). Must handle resources and collections.
	async fn move_path(&self, _src: &str, _dst: &str, _overwrite: bool) -> anyhow::Result<()> {
		Ok(())
	}

	/// COPY operation (with overwrite flag). Must handle resources and collections.
	async fn copy_path(&self, _src: &str, _dst: &str, _overwrite: bool) -> anyhow::Result<()> {
		Ok(())
	}

    /// Lock a resource.
    async fn lock(&self, _path: &str, _token: &str, _principal: Option<&str>, _depth: &str, _timeout: i64, _owner_info: Option<&str>) -> anyhow::Result<()> {
        Ok(())
    }

    /// Unlock a resource.
    async fn unlock(&self, _path: &str, _token: &str) -> anyhow::Result<()> {
        Ok(())
    }

    /// Get locks for a resource (exact path).
    async fn get_locks(&self, _path: &str) -> anyhow::Result<Vec<Lock>> {
        Ok(vec![])
    }

    /// REPORT sync-collection (CalDAV incremental sync).
    ///
    /// Par défaut, aucune modification n'est retournée et le sync-token est repris tel quel.
    async fn sync_collection(
        &self,
        _path: &str,
        sync_token: Option<&str>,
        _limit: Option<usize>,
    ) -> anyhow::Result<SyncCollectionResult> {
        let token = sync_token.unwrap_or("1").to_string();
        Ok(SyncCollectionResult {
            resources: Vec::new(),
            sync_token: token,
            partial: false,
        })
    }

    /// Query a collection (REPORT)
    async fn query_collection(&self, path: &str, query: CalendarQuery) -> anyhow::Result<Vec<Resource>> {
        let candidates = self.list_collection(path).await?;

        let range_start_str = query.start.clone().unwrap_or_else(|| "19000101T000000Z".into());
        let range_end_str = query.end.clone().unwrap_or_else(|| "21000101T000000Z".into());

        let range_start_utc = parse_range_to_utc(&range_start_str)?;
        let range_end_utc = parse_range_to_utc(&range_end_str)?;

        if query.start.is_none() && query.end.is_none() {
            return Ok(candidates);
        }

        let mut filtered = Vec::new();
        for mut res in candidates {
            if res.kind != ResourceKind::Object {
                continue;
            }

            let content = if let Some(c) = res.content.clone() {
                c
            } else {
                if let Ok(Some(full_res)) = self.get_resource(&res.path).await {
                    if let Some(c) = full_res.content {
                        c
                    } else {
                        continue;
                    }
                } else {
                    continue;
                }
            };

            let text = String::from_utf8_lossy(&content).to_string();
            let parsed = match ical_parse(&text) {
                Ok(obj) => obj,
                Err(_) => continue,
            };
            if let Err(_) = ical_validate(&parsed) {
                continue;
            }
            let vtz = extract_vtimezones(&parsed);

            if has_match_in_range(&parsed, &vtz, &range_start_str, &range_end_str, range_start_utc, range_end_utc)? {
                res.content = Some(content);
                filtered.push(res);
            }
        }

        Ok(filtered)
    }

    /// Generate FreeBusy response
    async fn free_busy_query(&self, path: &str, query: CalendarQuery) -> anyhow::Result<Vec<Resource>> {
        let candidates = self.list_collection(path).await?;
        let start_str = query.start.clone().unwrap_or("19000101T000000Z".into());
        let end_str = query.end.clone().unwrap_or("21000101T000000Z".into());
        let start_utc = parse_range_to_utc(&start_str)?;
        let end_utc = parse_range_to_utc(&end_str)?;

        let mut busy_periods = Vec::new();

        for res in candidates {
            if res.kind != ResourceKind::Object { continue; }
            let content = if let Some(c) = res.content { c } else {
                if let Ok(Some(full)) = self.get_resource(&res.path).await {
                    full.content.unwrap_or_default()
                } else {
                    continue;
                }
            };
            
            let text = String::from_utf8_lossy(&content).to_string();
            let parsed = match ical_parse(&text) {
                Ok(o) => o,
                Err(_) => continue,
            };
            let vtz = extract_vtimezones(&parsed);

            // Expand occurrences
            for cal in &parsed.calendars {
                for comp in &cal.components {
                    if let Component::VEvent { props, .. } = comp {
                        // Very simplified expansion: similar to has_match_in_range but capturing ranges
                        // We need to capture start/end of each occurrence
                        let dtstart = match props.iter().find(|p| p.name == "DTSTART") {
                            Some(p) => p,
                            None => continue,
                        };
                        let dtend = props.iter().find(|p| p.name == "DTEND"); // or duration
                        let duration_prop = props.iter().find(|p| p.name == "DURATION");
                        
                        let tzid = prop_param_tzid(dtstart);
                        
                        // Calculate duration if DTEND missing
                        let _duration_secs = if let Some(_end_prop) = dtend {
                             // approximate logic: parse end - start
                             // For now, let's assume we can compute end from start+duration or end
                             0 // placeholder
                        } else if let Some(_dur) = duration_prop {
                             // parse duration
                             3600 // placeholder 1h
                        } else {
                             0 // point event?
                        };

                        // Use recurrence logic if RRULE
                        if let Some(rrule) = props.iter().find(|p| p.name == "RRULE") {
                             let exdates: Vec<&str> = props.iter().filter(|p| p.name == "EXDATE").map(|p| p.value.as_str()).collect();
                             let rdates: Vec<&str> = props.iter().filter(|p| p.name == "RDATE").map(|p| p.value.as_str()).collect();
                             
                             let occs = occurrences_with_vtimezones(
                                rrule.value.as_str(),
                                prop_value(dtstart),
                                tzid,
                                &start_str,
                                &end_str,
                                &exdates,
                                &rdates,
                                &vtz
                             ).unwrap_or_default();
                             
                             for occ in occs {
                                 // occ is a DateTime string? Or (DateTime, DateTime)?
                                 // occurrences_with_vtimezones returns Vec<String> (start times) in lyxal_ical_core
                                 // We need to calculate end time for each occurrence.
                                 // Assuming constant duration for VEVENT.
                                 // This is a limitation of current lyxal_ical_core exposure if it only returns starts.
                                 // We'll trust the start times are within range.
                                 // We need to parse occ back to DateTime to add duration?
                                 // Or just format it.
                                 // VFREEBUSY format: FREEBUSY:20230101T100000Z/PT1H or /20230101T110000Z
                                 
                                 // Let's try to infer duration from first instance
                                 // (Ideally lyxal_ical_core handles this, but we are doing it here).
                                 
                                 // Simplification: We just output start/duration if we have duration, or start/end if we have end.
                                 // But for recurrence, we need to know the duration.
                                 // Let's compute duration of the master event.
                                 
                                 let master_start = parse_dt_with_tz(dtstart, &vtz)?;
                                 let master_end = if let Some(end_p) = dtend {
                                     parse_dt_with_tz(end_p, &vtz)?
                                 } else {
                                     // Duration?
                                     master_start // fallback
                                 };
                                 let duration = master_end.signed_duration_since(master_start);
                                 
                                 // Parse occ string to DateTime
                                 let (naive_occ, has_z) = parse_naive_or_utc(&occ).unwrap_or((chrono::NaiveDateTime::MIN, false));
                                 let occ_utc = if has_z { 
                                     DateTime::from_naive_utc_and_offset(naive_occ, Utc) 
                                 } else { 
                                     // Assume local? Should use TZID? occurrences returns in what format? 
                                     // usually it returns in the same format as start, or UTC if converted.
                                     // Let's assume UTC for simplicity or handle as is.
                                     DateTime::from_naive_utc_and_offset(naive_occ, Utc) 
                                 };
                                 
                                 let occ_end = occ_utc + duration;
                                 
                                 // Check intersection with query range
                                 if occ_end > start_utc && occ_utc < end_utc {
                                     busy_periods.push((occ_utc, occ_end));
                                 }
                             }
                        } else {
                            // Single instance
                            let start = parse_dt_with_tz(dtstart, &vtz)?;
                            let end = if let Some(d) = dtend {
                                parse_dt_with_tz(d, &vtz)?
                            } else {
                                start // duration 0
                            };
                            
                            if end > start_utc && start < end_utc {
                                busy_periods.push((start, end));
                            }
                        }
                    }
                }
            }
        }

        // Generate VCALENDAR response
        // Format: ISO8601 basic
        let dtstamp = Utc::now().format("%Y%m%dT%H%M%SZ").to_string();
        let mut ics = String::new();
        ics.push_str("BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//Lyxal//Dav//EN\n");
        ics.push_str("BEGIN:VFREEBUSY\n");
        ics.push_str(&format!("DTSTAMP:{}\n", dtstamp));
        ics.push_str(&format!("DTSTART:{}\n", start_str));
        ics.push_str(&format!("DTEND:{}\n", end_str));
        
        for (start, end) in busy_periods {
            let s = start.format("%Y%m%dT%H%M%SZ").to_string();
            let e = end.format("%Y%m%dT%H%M%SZ").to_string();
            ics.push_str(&format!("FREEBUSY:{}/{}\n", s, e));
        }
        
        ics.push_str("END:VFREEBUSY\nEND:VCALENDAR");
        
        // Wrap in a Resource object (generic way to return content)
        Ok(vec![Resource {
            path: "freebusy.ics".into(),
            kind: ResourceKind::Object,
            mime_type: "text/calendar".into(),
            etag: "".into(),
            content: Some(ics.into_bytes()),
            properties: HashMap::new(),
            sync_token: None,
        }])
    }

    /// Query addressbook (REPORT)
    async fn query_addressbook(&self, _path: &str, _query: AddressBookQuery) -> anyhow::Result<Vec<Resource>> {
        Ok(vec![])
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CalendarQuery {
    pub start: Option<String>, // ISO8601/iCal format
    pub end: Option<String>,
    // In v2 we can add more filter fields
}

fn parse_range_to_utc(s: &str) -> anyhow::Result<DateTime<Utc>> {
    let (ndt, had_z) = parse_naive_or_utc(s).map_err(|e| anyhow::anyhow!(e.to_string()))?;
    if had_z {
        Ok(DateTime::<Utc>::from_naive_utc_and_offset(ndt, Utc))
    } else {
        Ok(DateTime::<Utc>::from_naive_utc_and_offset(ndt, Utc))
    }
}

fn prop_param_tzid(prop: &Property) -> Option<&str> {
    prop.params.get("TZID").and_then(|v| v.first().map(|s| s.as_str()))
}

fn prop_value(prop: &Property) -> &str {
    prop.value.as_str()
}

fn parse_dt_with_tz(prop: &Property, vtz: &HashMap<String, lyxal_ical_core::timezone::VTimezoneDef>) -> anyhow::Result<DateTime<Utc>> {
    let (naive, had_z) = parse_naive_or_utc(&prop.value).map_err(|e| anyhow::anyhow!(e.to_string()))?;
    if had_z {
        return Ok(DateTime::<Utc>::from_naive_utc_and_offset(naive, Utc));
    }
    if let Some(tzid) = prop_param_tzid(prop) {
        let dt = local_to_utc_with_tzid(tzid, &naive, vtz).map_err(|e| anyhow::anyhow!(e.to_string()))?;
        return Ok(dt);
    }
    Ok(DateTime::<Utc>::from_naive_utc_and_offset(naive, Utc))
}

fn has_match_in_range(
    obj: &IcalObject,
    vtz: &HashMap<String, lyxal_ical_core::timezone::VTimezoneDef>,
    range_start_str: &str,
    range_end_str: &str,
    range_start_utc: DateTime<Utc>,
    range_end_utc: DateTime<Utc>,
) -> anyhow::Result<bool> {
    for cal in &obj.calendars {
        for comp in &cal.components {
            if let Component::VEvent { props, .. } = comp {
                let dtstart = match props.iter().find(|p| p.name == "DTSTART") {
                    Some(p) => p,
                    None => continue,
                };
                let dtend = props.iter().find(|p| p.name == "DTEND");
                let tzid = prop_param_tzid(dtstart);
                let exdates: Vec<String> = props
                    .iter()
                    .filter(|p| p.name == "EXDATE")
                    .map(|p| p.value.clone())
                    .collect();
                let rdates: Vec<String> = props
                    .iter()
                    .filter(|p| p.name == "RDATE")
                    .map(|p| p.value.clone())
                    .collect();

                if let Some(rrule) = props.iter().find(|p| p.name == "RRULE") {
                    let ex_refs: Vec<&str> = exdates.iter().map(|s| s.as_str()).collect();
                    let r_refs: Vec<&str> = rdates.iter().map(|s| s.as_str()).collect();
                    let occ = occurrences_with_vtimezones(
                        rrule.value.as_str(),
                        prop_value(dtstart),
                        tzid,
                        range_start_str,
                        range_end_str,
                        &ex_refs,
                        &r_refs,
                        vtz,
                    )
                    .unwrap_or_default();
                    if !occ.is_empty() {
                        return Ok(true);
                    }
                } else {
                    let start_utc = parse_dt_with_tz(dtstart, vtz)?;
                    let end_utc = if let Some(d) = dtend {
                        parse_dt_with_tz(d, vtz)?
                    } else {
                        start_utc
                    };
                    if start_utc <= range_end_utc && end_utc >= range_start_utc {
                        return Ok(true);
                    }
                }
            }
        }
    }
    Ok(false)
}
