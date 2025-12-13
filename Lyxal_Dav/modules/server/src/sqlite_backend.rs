use async_trait::async_trait;
use chrono::{DateTime, Utc};
use lyxal_dav_core::backend::{CalendarQuery, DavBackend, Resource, ResourceKind};
use sqlx::{Row, Sqlite, SqlitePool};
use std::collections::HashMap;

#[derive(Clone)]
pub struct SqliteBackend {
    pool: SqlitePool,
}

impl SqliteBackend {
    pub async fn new(database_url: &str) -> anyhow::Result<Self> {
        let pool = SqlitePool::connect(database_url).await?;

        // Calendars table (align with calendars.surql)
        sqlx::query(
            r#"
            CREATE TABLE IF NOT EXISTS calendars(
                path TEXT PRIMARY KEY,
                code TEXT UNIQUE,
                slug TEXT UNIQUE,
                displayname TEXT NOT NULL,
                description TEXT,
                timezone TEXT,
                color TEXT,
                components TEXT NOT NULL DEFAULT 'VEVENT,VTODO,VJOURNAL',
                transparent INTEGER NOT NULL DEFAULT 0,
                sync_token INTEGER NOT NULL DEFAULT 1,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            );
            "#,
        )
        .execute(&pool)
        .await?;

        // Calendar objects (align with calendarobjects.surql)
        sqlx::query(
            r#"
            CREATE TABLE IF NOT EXISTS calendarobjects(
                path TEXT PRIMARY KEY,
                calendar_path TEXT NOT NULL,
                uri TEXT NOT NULL,
                uid TEXT NOT NULL,
                etag TEXT NOT NULL,
                mime_type TEXT NOT NULL,
                calendardata TEXT NOT NULL,
                component_type TEXT,
                first_occurrence INTEGER,
                last_occurrence INTEGER,
                classification INTEGER NOT NULL DEFAULT 0,
                size INTEGER,
                lastmodified INTEGER,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY(calendar_path) REFERENCES calendars(path) ON DELETE CASCADE,
                UNIQUE(calendar_path, uri)
            );"#,
        )
        .execute(&pool)
        .await?;

        sqlx::query("CREATE INDEX IF NOT EXISTS idx_calendarobjects_calendar ON calendarobjects(calendar_path);")
            .execute(&pool)
            .await?;

        // Calendar changes (sync log)
        sqlx::query(
            r#"
            CREATE TABLE IF NOT EXISTS calendarchanges(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                calendar_path TEXT NOT NULL,
                uri TEXT NOT NULL,
                operation TEXT NOT NULL,
                synctoken INTEGER NOT NULL,
                created_at TEXT NOT NULL,
                FOREIGN KEY(calendar_path) REFERENCES calendars(path) ON DELETE CASCADE
            );"#,
        )
        .execute(&pool)
        .await?;

        Ok(Self { pool })
    }

    fn etag_for(path: &str, data: &[u8]) -> String {
        blake3::hash(&[path.as_bytes(), data].concat()).to_hex().to_string()
    }

    fn split_path(path: &str) -> Option<(String, String)> {
        path.rsplit_once('/')
            .and_then(|(left, right)| if left.is_empty() { None } else { Some((left.to_string(), right.to_string())) })
    }

    fn slug_from_path(path: &str) -> String {
        path.trim_matches('/').replace('/', "-")
    }

    fn code_from_slug(slug: &str) -> String {
        slug.replace('-', "_").to_ascii_uppercase()
    }

    async fn bump_sync_token_conn(&self, calendar: &str) -> anyhow::Result<i64> {
        let current: Option<i64> = sqlx::query_scalar::<Sqlite, i64>("SELECT sync_token FROM calendars WHERE path = ?")
            .bind(calendar)
            .fetch_optional(&self.pool)
            .await?;
        let next = current.unwrap_or(1).saturating_add(1);
        let now = Utc::now().to_rfc3339();
        sqlx::query::<Sqlite>("UPDATE calendars SET sync_token = ?, updated_at = ? WHERE path = ?")
            .bind(next)
            .bind(&now)
            .bind(calendar)
            .execute(&self.pool)
            .await?;
        Ok(next)
    }

    async fn record_change_conn(
        &self,
        calendar: &str,
        uri: &str,
        operation: &str,
        synctoken: i64,
    ) -> anyhow::Result<()> {
        let now = Utc::now().to_rfc3339();
        sqlx::query::<Sqlite>(
            "INSERT INTO calendarchanges(calendar_path, uri, operation, synctoken, created_at) VALUES(?, ?, ?, ?, ?)",
        )
        .bind(calendar)
        .bind(uri)
        .bind(operation)
        .bind(synctoken)
        .bind(now)
        .execute(&self.pool)
        .await?;
        Ok(())
    }
}

#[async_trait]
impl DavBackend for SqliteBackend {
    async fn get_resource(&self, path: &str) -> anyhow::Result<Option<Resource>> {
        // Calendar
        if let Some(row) = sqlx::query(
            "SELECT displayname, description, timezone, color, components, transparent, sync_token FROM calendars WHERE path = ?",
        )
        .bind(path)
        .fetch_optional(&self.pool)
        .await?
        {
            let displayname: String = row.try_get("displayname")?;
            let description: Option<String> = row.try_get("description").ok();
            let timezone: Option<String> = row.try_get("timezone").ok();
            let color: Option<String> = row.try_get("color").ok();
            let components: String = row.try_get("components")?;
            let transparent: i64 = row.try_get("transparent")?;
            let sync_token: i64 = row.try_get("sync_token")?;

            let mut properties = HashMap::new();
            properties.insert("D:displayname".into(), displayname);
            if let Some(desc) = description {
                properties.insert("D:calendar-description".into(), desc);
            }
            if let Some(tz) = timezone {
                properties.insert("C:calendar-timezone".into(), tz);
            }
            if let Some(col) = color {
                properties.insert("apple:calendar-color".into(), col);
            }
            properties.insert("C:supported-calendar-component-set".into(), components);
            properties.insert(
                "C:calendar-transparent".into(),
                if transparent != 0 { "1" } else { "0" }.into(),
            );

            return Ok(Some(Resource {
                path: path.to_string(),
                kind: ResourceKind::Calendar,
                mime_type: "text/calendar".into(),
                etag: sync_token.to_string(),
                content: None,
                properties,
                sync_token: Some(sync_token.to_string()),
            }));
        }

        // Object
        if let Some(row) = sqlx::query(
            "SELECT calendar_path, etag, mime_type, calendardata, component_type, classification FROM calendarobjects WHERE path = ?",
        )
        .bind(path)
        .fetch_optional(&self.pool)
        .await?
        {
            let mime: String = row.try_get("mime_type")?;
            let etag: String = row.try_get("etag")?;
            let content: String = row.try_get("calendardata")?;
            let component: Option<String> = row.try_get("component_type").ok();
            let classification: Option<i64> = row.try_get("classification").ok();

            let mut properties = HashMap::new();
            if let Some(c) = component {
                properties.insert("component".into(), c);
            }
            if let Some(classif) = classification {
                properties.insert("classification".into(), classif.to_string());
            }

            return Ok(Some(Resource {
                path: path.to_string(),
                kind: ResourceKind::Object,
                mime_type: mime,
                etag,
                content: Some(content.into_bytes()),
                properties,
                sync_token: None,
            }));
        }

        Ok(None)
    }

    async fn list_collection(&self, path: &str) -> anyhow::Result<Vec<Resource>> {
        let rows = sqlx::query(
            "SELECT path, etag, mime_type, calendardata, component_type, classification FROM calendarobjects WHERE calendar_path = ?",
        )
        .bind(path)
        .fetch_all(&self.pool)
        .await?;

        let resources = rows
            .into_iter()
            .map(|row| {
                let mut properties = HashMap::new();
                if let Ok(component) = row.try_get::<String, _>("component_type") {
                    properties.insert("component".into(), component);
                }
                if let Ok(classif) = row.try_get::<i64, _>("classification") {
                    properties.insert("classification".into(), classif.to_string());
                }

                Resource {
                    path: row.try_get("path").unwrap_or_default(),
                    kind: ResourceKind::Object,
                    mime_type: row.try_get("mime_type").unwrap_or_else(|_| "text/calendar".into()),
                    etag: row.try_get("etag").unwrap_or_default(),
                    content: row
                        .try_get::<String, _>("calendardata")
                        .map(|s| s.into_bytes())
                        .ok(),
                    properties,
                    sync_token: None,
                }
            })
            .collect();

        Ok(resources)
    }

    async fn put_resource(&self, path: &str, data: &[u8], mime: &str) -> anyhow::Result<String> {
        let Some((calendar_path, uri)) = Self::split_path(path) else {
            return Err(anyhow::anyhow!("Invalid path"));
        };

        let cal_exists = sqlx::query_scalar::<_, i64>("SELECT COUNT(*) FROM calendars WHERE path = ?")
            .bind(&calendar_path)
            .fetch_one(&self.pool)
            .await?;
        if cal_exists == 0 {
            return Err(anyhow::anyhow!("Calendar not found"));
        }

        let etag = Self::etag_for(path, data);
        let now = Utc::now();
        let now_rfc = now.to_rfc3339();
        let lastmodified = now.timestamp();
        let size = data.len() as i64;
        let calendardata = String::from_utf8_lossy(data).to_string();

        let existing: Option<String> = sqlx::query_scalar("SELECT etag FROM calendarobjects WHERE path = ?")
            .bind(path)
            .fetch_optional(&self.pool)
            .await?;

        sqlx::query::<Sqlite>(
            r#"
            INSERT INTO calendarobjects(path, calendar_path, uri, uid, etag, mime_type, calendardata, component_type, first_occurrence, last_occurrence, classification, size, lastmodified, created_at, updated_at)
            VALUES(?, ?, ?, ?, ?, ?, ?, NULL, NULL, NULL, 0, ?, ?, ?, ?)
            ON CONFLICT(path) DO UPDATE SET
              etag = excluded.etag,
              mime_type = excluded.mime_type,
              calendardata = excluded.calendardata,
              size = excluded.size,
              lastmodified = excluded.lastmodified,
              updated_at = excluded.updated_at
            "#,
        )
        .bind(path)
        .bind(&calendar_path)
        .bind(&uri)
        .bind(&etag) // fallback uid = etag
        .bind(&etag)
        .bind(mime)
        .bind(&calendardata)
        .bind(size)
        .bind(lastmodified)
        .bind(&now_rfc)
        .bind(&now_rfc)
        .execute(&self.pool)
        .await?;

        let new_sync = self.bump_sync_token_conn(&calendar_path).await?;
        let op = if existing.is_some() { "UPDATE" } else { "CREATE" };
        self.record_change_conn(&calendar_path, &uri, op, new_sync).await?;

        Ok(etag)
    }

    async fn delete_resource(&self, path: &str) -> anyhow::Result<()> {
        let Some((calendar_path, uri)) = Self::split_path(path) else {
            return Err(anyhow::anyhow!("Invalid path"));
        };

        let deleted = sqlx::query::<Sqlite>("DELETE FROM calendarobjects WHERE path = ?")
            .bind(path)
            .execute(&self.pool)
            .await?;

        if deleted.rows_affected() == 0 {
            return Ok(());
        }

        let new_sync = self.bump_sync_token_conn(&calendar_path).await?;
        self.record_change_conn(&calendar_path, &uri, "DELETE", new_sync).await?;

        Ok(())
    }

    async fn create_collection(&self, path: &str, kind: ResourceKind) -> anyhow::Result<()> {
        if kind != ResourceKind::Calendar && kind != ResourceKind::Collection {
            return Err(anyhow::anyhow!("Unsupported collection type"));
        }

        let slug = Self::slug_from_path(path);
        let code = Self::code_from_slug(&slug);
        let display = slug.clone();
        let now = Utc::now().to_rfc3339();

        sqlx::query::<Sqlite>(
            r#"
            INSERT INTO calendars(path, code, slug, displayname, description, timezone, color, components, transparent, sync_token, created_at, updated_at)
            VALUES(?, ?, ?, ?, NULL, NULL, NULL, 'VEVENT,VTODO,VJOURNAL', 0, 1, ?, ?)
            ON CONFLICT(path) DO NOTHING
            "#,
        )
        .bind(path)
        .bind(code)
        .bind(slug)
        .bind(display)
        .bind(&now)
        .bind(&now)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn query_collection(&self, path: &str, query: CalendarQuery) -> anyhow::Result<Vec<Resource>> {
        let children = self.list_collection(path).await?;
        if query.start.is_none() && query.end.is_none() {
            return Ok(children);
        }

        let range_start = if let Some(s) = &query.start {
            lyxal_dav_core::ical::parse_date(s).unwrap_or_else(|_| Utc::now())
        } else {
            DateTime::parse_from_rfc3339("1900-01-01T00:00:00Z").unwrap().with_timezone(&Utc)
        };
        let range_end = if let Some(s) = &query.end {
            lyxal_dav_core::ical::parse_date(s).unwrap_or_else(|_| Utc::now())
        } else {
            DateTime::parse_from_rfc3339("2100-01-01T00:00:00Z").unwrap().with_timezone(&Utc)
        };

        let mut filtered = Vec::new();
        for res in children {
            if res.kind != ResourceKind::Object {
                continue;
            }
            if let Some(content) = &res.content {
                if let Ok(events) = lyxal_dav_core::ical::events(&String::from_utf8_lossy(content)) {
                    if events.iter().any(|ev| lyxal_dav_core::ical::is_in_range(ev, range_start, range_end)) {
                        filtered.push(res.clone());
                    }
                }
            }
        }

        Ok(filtered)
    }
}

