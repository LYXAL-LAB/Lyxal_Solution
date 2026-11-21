-- ============================================================================
-- TABLE  : storage_object
-- MODULE : lyxal_storage
-- RÔLE   : Fiche d'un fichier : adresse, propriétaire, taille, type, empreinte, état
-- ============================================================================
-- Un fichier est repéré par son bucket et sa clé, comme la valeur `file` de SurrealDB. Les octets
-- sont sur le support ; la fiche fait foi. États : pending (écriture en cours, jamais servi),
-- available, quarantined, deleted (octets à retirer par le worker). Les modules consommateurs
-- référencent une fiche par un champ `record<storage_object>` déclaré REFERENCE. Dans un bucket
-- chiffré, la fiche porte la clé du fichier scellée (content_key, illisible hors session système
-- et worker) ; l'empreinte et la taille stockée sont celles des octets chiffrés.

DEFINE TABLE OVERWRITE storage_object
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::storage_can({ action: "read", tenant: tenant })
        FOR create WHERE fn::storage_can({ action: "write", tenant: tenant })
        FOR update WHERE fn::storage_can({ action: "write", tenant: tenant }) OR fn::storage_can({ action: "worker", tenant: tenant })
        FOR delete WHERE fn::storage_can({ action: "worker", tenant: tenant })
    COMMENT "Fiche d'un fichier : adresse, propriétaire, taille, type, empreinte, état";

DEFINE FIELD OVERWRITE bucket ON TABLE storage_object
    TYPE record<storage_bucket>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Bucket ; un bucket non vide n'est supprimé qu'avec son organisation (garde storage_object_bucket_guard)";

DEFINE FIELD OVERWRITE tenant ON TABLE storage_object
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation du bucket (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE storage_object
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée (quota)";

DEFINE FIELD OVERWRITE key ON TABLE storage_object
    TYPE string
    READONLY
    ASSERT fn::validation_lyxal_storage_path($value, NONE, true, 512).value == $value
    COMMENT "Clé dans le bucket : chemin relatif (plans/2026/a.pdf)";

DEFINE FIELD OVERWRITE backend ON TABLE storage_object
    TYPE string
    READONLY
    COMMENT "Support du bucket, qui porte les octets";

DEFINE FIELD OVERWRITE path ON TABLE storage_object
    TYPE string
    VALUE string::concat(
        IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) },
        "/", <string> record::id($this.bucket), "/", <string> record::id($this.id))
    COMMENT "Emplacement des octets sur le support : <portée>/<clé du bucket>/<clé de la fiche>";

DEFINE FIELD OVERWRITE owner ON TABLE storage_object
    TYPE option<record<auth_identity>>
    REFERENCE ON DELETE UNSET
    COMMENT "Identité qui a écrit le fichier (NONE : session système ou identité supprimée)";

DEFINE FIELD OVERWRITE owner_application ON TABLE storage_object
    TYPE option<record<auth_application>>
    REFERENCE ON DELETE UNSET
    COMMENT "Application qui a écrit le fichier sans identité (compte de service) ; NONE sinon";

DEFINE FIELD OVERWRITE filename ON TABLE storage_object
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 255
    COMMENT "Nom d'origine du fichier";

DEFINE FIELD OVERWRITE declared_type ON TABLE storage_object
    TYPE option<string>
    COMMENT "Type MIME annoncé à l'ouverture de l'écriture";

DEFINE FIELD OVERWRITE declared_size ON TABLE storage_object
    TYPE option<int>
    ASSERT $value IS NONE OR $value >= 0
    COMMENT "Taille annoncée à l'ouverture de l'écriture, en octets";

DEFINE FIELD OVERWRITE content_type ON TABLE storage_object
    TYPE option<string>
    COMMENT "Type MIME réel, posé à la fin de l'écriture";

DEFINE FIELD OVERWRITE size ON TABLE storage_object
    TYPE option<int>
    ASSERT $value IS NONE OR $value >= 0
    COMMENT "Taille réelle en octets, posée à la fin de l'écriture";

DEFINE FIELD OVERWRITE blake3 ON TABLE storage_object
    TYPE option<string>
    ASSERT $value IS NONE OR fn::validation_checksum($value, "blake3").value == $value
    COMMENT "Empreinte BLAKE3 des octets stockés (64 caractères hexadécimaux : le chiffré dans un bucket chiffré, jamais le clair), posée à la fin de l'écriture";

DEFINE FIELD OVERWRITE content_key ON TABLE storage_object
    TYPE option<string>
    ASSERT $value IS NONE OR (string::starts_with($value, "enc:v2:") AND string::len($value) <= 4096)
    PERMISSIONS FOR select WHERE fn::storage_can({ action: "worker" })
    COMMENT "Bucket chiffré : clé du fichier scellée par la clé « fichiers » de l'organisation (enc:v2), posée à la fin de l'écriture, rescellée après une rotation ; illisible hors session système et worker ; effacée avec la fiche";

DEFINE FIELD OVERWRITE content_key_id ON TABLE storage_object
    TYPE option<string>
    VALUE IF $this.content_key IS NONE { NONE } ELSE { string::split($this.content_key, ":")[2] }
    COMMENT "Clé « fichiers » de l'organisation qui scelle la clé du fichier (rotation) ; NONE : fichier en clair";

DEFINE FIELD OVERWRITE stored_size ON TABLE storage_object
    TYPE option<int>
    VALUE IF $this.size IS NONE { NONE } ELSE IF $this.content_key IS NONE { $this.size } ELSE {
        -- Flux chiffré v1 : en-tête de 47 octets, puis chaque segment de 64 Kio suivi de son étiquette de 16 octets
        47 + $this.size + 16 * math::max([1, ($this.size + 65535) / 65536])
    }
    COMMENT "Taille des octets stockés sur le support : la taille réelle, ou celle du flux chiffré dans un bucket chiffré";

DEFINE FIELD OVERWRITE state ON TABLE storage_object
    TYPE string
    DEFAULT "pending"
    ASSERT $value IN ["pending", "available", "quarantined", "deleted"]
    COMMENT "État : pending, available, quarantined, deleted";

DEFINE FIELD OVERWRITE slot ON TABLE storage_object
    TYPE string
    VALUE IF $this.state = "deleted" { <string> $this.id } ELSE { $this.key }
    COMMENT "Adresse occupée : la clé tant que le fichier n'est pas supprimé (unicité par bucket)";

DEFINE FIELD OVERWRITE quarantine_reason ON TABLE storage_object
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 256
    COMMENT "Motif de la quarantaine";

DEFINE FIELD OVERWRITE pending_expires_at ON TABLE storage_object
    TYPE option<datetime>
    COMMENT "Fin du délai d'une écriture en attente";

DEFINE FIELD OVERWRITE resumable ON TABLE storage_object
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Envoi reprenable : octets reçus par parties (storage_upload_part), assemblées à la fin";

DEFINE FIELD OVERWRITE upload_claimed_until ON TABLE storage_object
    TYPE option<datetime>
    COMMENT "Assemblage d'un envoi reprenable en cours jusqu'à cette date : un seul assembleur à la fois";

DEFINE FIELD OVERWRITE upload_claim ON TABLE storage_object
    TYPE option<uuid>
    COMMENT "Jeton de la réservation d'assemblage en cours : seul son détenteur termine ou abandonne l'envoi";

DEFINE FIELD OVERWRITE deleted_at ON TABLE storage_object
    TYPE option<datetime>
    COMMENT "Suppression";

DEFINE FIELD OVERWRITE purge_after ON TABLE storage_object
    TYPE option<datetime>
    COMMENT "Date à partir de laquelle le worker retire les octets et la fiche";

DEFINE FIELD OVERWRITE created_at ON TABLE storage_object
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE updated_at ON TABLE storage_object
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE storage_object_slot ON TABLE storage_object FIELDS bucket, slot UNIQUE;
DEFINE INDEX OVERWRITE storage_object_scope ON TABLE storage_object FIELDS scope_key, state;
DEFINE INDEX OVERWRITE storage_object_state ON TABLE storage_object FIELDS state;
DEFINE INDEX OVERWRITE storage_object_content_key ON TABLE storage_object FIELDS content_key_id;
