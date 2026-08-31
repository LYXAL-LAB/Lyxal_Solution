-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_list_all_caldav_sources                                    │
-- │  Récupère l'ensemble des sources actives pour la synchronisation        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_list_all_caldav_sources($params: object) {
    LET $sources = SELECT id, account, provider, auth_kind, url, username, password, access_token, refresh_token, sync_status, sync_state, last_synced
                     FROM booking_caldav_source
                    WHERE enabled == NONE OR enabled == true
                    ORDER BY last_synced ASC;

    RETURN $sources;
} COMMENT "Liste toutes les sources de calendrier distants actives pour les routines de synchronisation";
