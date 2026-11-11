-- ============================================================================
-- EVENTS : lyxal_storage
-- MODULE : lyxal_storage
-- RÔLE   : Garde des transitions d'état, préfixes à retirer et publication des événements storage.*
-- ============================================================================
-- Publiés par la base dans la transaction de la mutation (.agents/AGENTS.md §5.6.1) ; une
-- publication refusée fait échouer la mutation. Jamais de contenu.

-- ----------------------------------------------------------------------------
-- Garde des modifications d'une fiche (vaut aussi pour une modification directe de la table)
-- ----------------------------------------------------------------------------
-- Les fonctions publiques rendent une erreur lisible ; cette garde est le dernier rempart : une
-- session qui écrit directement dans la table est soumise aux mêmes règles
-- (fn::storage_object_update_refusal). Un événement voit l'identité de l'appelant.

DEFINE EVENT OVERWRITE storage_object_update_guard ON TABLE storage_object
WHEN $event = "UPDATE"
THEN {
    LET $refusal = fn::storage_object_update_refusal($before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE storage_object_created_guard ON TABLE storage_object
WHEN $event = "CREATE"
THEN {
    LET $bucket = (SELECT tenant, backend FROM ONLY $after.bucket);
    IF $after.state != "pending" OR $after.tenant != $bucket.tenant OR $after.backend != $bucket.backend { THROW "STORAGE_OBJECT_STATE_INVALID"; };
};

-- ----------------------------------------------------------------------------
-- Un bucket non vide ne se supprime qu'avec son organisation
-- ----------------------------------------------------------------------------
-- La purge d'une organisation (lyxal_auth) supprime ses buckets et leurs fiches en cascade ; à
-- ce moment l'organisation n'existe plus. Une fiche emportée par la suppression de son seul
-- bucket (le bucket n'existe plus, l'organisation si) fait échouer cette suppression, même en
-- écriture directe : le bucket et ses fiches restent.

DEFINE EVENT OVERWRITE storage_object_bucket_guard ON TABLE storage_object
WHEN $event = "DELETE"
THEN {
    IF !record::exists($before.bucket) AND ($before.tenant IS NONE OR record::exists($before.tenant)) {
        THROW "STORAGE_BUCKET_NOT_EMPTY";
    };
};

-- ----------------------------------------------------------------------------
-- Octets d'un bucket supprimé : préfixe à retirer par le worker
-- ----------------------------------------------------------------------------
-- Écrit dans la transaction de la suppression, dans une table du module : rien n'est publié et
-- aucun autre module n'est modifié. Vaut aussi pour un bucket supprimé avec son organisation,
-- dont les fiches partent en cascade sans passer par l'état deleted.

DEFINE EVENT OVERWRITE storage_bucket_reclaim ON TABLE storage_bucket
WHEN $event = "DELETE"
THEN {
    CREATE storage_reclaim CONTENT {
        backend: $before.backend,
        prefix: string::concat($before.scope_key, "/", <string> record::id($before.id))
    };
};

-- ----------------------------------------------------------------------------
-- storage.object.created, storage.object.deleted, storage.object.quarantined
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE storage_object_state_event ON TABLE storage_object
WHEN $event = "UPDATE" AND $before.state != $after.state
    AND ($after.state IN ["available", "quarantined"] OR ($after.state = "deleted" AND $before.state != "pending"))
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: IF $after.state = "available" { "storage.object.created" }
            ELSE IF $after.state = "quarantined" { "storage.object.quarantined" }
            ELSE { "storage.object.deleted" },
        producer: "lyxal_storage",
        source: $after.id,
        payload: {
            object_id: <string> $after.id,
            bucket_id: <string> $after.bucket,
            key: $after.key,
            tenant: IF $after.tenant IS NONE { NONE } ELSE { <string> $after.tenant },
            size: $after.size,
            content_type: $after.content_type
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};
