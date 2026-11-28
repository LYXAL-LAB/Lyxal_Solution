-- ============================================================================
-- TABLE  : infra_record
-- MODULE : lyxal_infra
-- RÔLE   : Enregistrements voulus (état désiré), déclarés par un propriétaire pour un sujet
-- ============================================================================
-- Un enregistrement voulu a un propriétaire (owner : identifiant de module, ou manual pour
-- l'administrateur) et un sujet (subject : clé opaque choisie par le propriétaire, sans nom de
-- domaine ni adresse). Une déclaration remplace tout l'ensemble du couple (owner, subject)
-- (fn::infra_records_declare). Clé : infra_record:⟨<32 premiers chiffres hexadécimaux du BLAKE3
-- de owner, subject, fqdn et type>⟩ (fn::infra__record_key). Valeurs canoniques et triées.
-- Lyxal ne touche chez l'hébergeur que ses propres écritures (provider_ids, applied_values).

DEFINE TABLE OVERWRITE infra_record
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::infra_can({ action: "read" }) OR fn::infra_can({ action: "declare" }) OR fn::infra_can({ action: "worker" })
        FOR create WHERE fn::infra_can({ action: "worker" })
            OR (owner = "manual" AND fn::infra_can({ action: "manage" }))
            OR (owner != "manual" AND fn::infra_can({ action: "declare" }))
        FOR update WHERE fn::infra_can({ action: "worker" }) OR fn::infra_can({ action: "manage" })
            OR (owner != "manual" AND fn::infra_can({ action: "declare" }))
        FOR delete WHERE fn::infra_can({ action: "worker" })
    COMMENT "Enregistrements DNS voulus : propriétaire, sujet, nom, type, valeurs, mode de cohabitation, état et écritures de Lyxal chez l'hébergeur";

DEFINE FIELD OVERWRITE owner ON TABLE infra_record
    TYPE string
    READONLY
    ASSERT fn::validation_snake_case_name($value, 1, 64).value == $value
    COMMENT "Propriétaire : identifiant de module (lyxal_mail…) ou manual (administrateur)";

DEFINE FIELD OVERWRITE subject ON TABLE infra_record
    TYPE string
    READONLY
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Sujet : clé opaque choisie par le propriétaire (mail_domain:01JD…), sans nom de domaine ni adresse";

DEFINE FIELD OVERWRITE tenant ON TABLE infra_record
    TYPE option<record<auth_organization>>
    COMMENT "Organisation pour qui l'enregistrement est déclaré (NONE : installation)";

DEFINE FIELD OVERWRITE zone ON TABLE infra_record
    TYPE option<record<infra_zone>>
    COMMENT "Zone rattachée qui couvre le nom (NONE : aucune, état unmanaged)";

DEFINE FIELD OVERWRITE fqdn ON TABLE infra_record
    TYPE string
    READONLY
    ASSERT fn::validation_dns_name($value, true, false, NONE).value == $value
    COMMENT "Nom complet (A-label, minuscules, sans point final)";

DEFINE FIELD OVERWRITE type ON TABLE infra_record
    TYPE string
    READONLY
    ASSERT $value IN ["A", "AAAA", "CNAME", "MX", "TXT", "SRV", "CAA"]
    COMMENT "Type : A, AAAA, CNAME, MX, TXT, SRV, CAA";

DEFINE FIELD OVERWRITE values ON TABLE infra_record
    TYPE array<string>
    ASSERT array::len($value) >= 1 AND array::len($value) <= 20 AND array::all($value, |$v| string::len($v) <= 4096)
    COMMENT "Valeurs canoniques et triées (1 à 20)";

DEFINE FIELD OVERWRITE ttl ON TABLE infra_record
    TYPE int
    ASSERT $value >= 60 AND $value <= 86400
    COMMENT "Durée de vie, en secondes";

DEFINE FIELD OVERWRITE mode ON TABLE infra_record
    TYPE string
    ASSERT $value IN ["exclusive", "shared"]
    COMMENT "exclusive : Lyxal veut tout le jeu (nom, type) ; shared : Lyxal n'ajoute que ses valeurs";

DEFINE FIELD OVERWRITE singleton_prefix ON TABLE infra_record
    TYPE option<string>
    ASSERT $value IS NONE OR (string::len($value) >= 1 AND string::len($value) <= 32)
    COMMENT "TXT partagé : préfixe unique (v=spf1…) ; une valeur étrangère de même préfixe est un conflit";

DEFINE FIELD OVERWRITE state ON TABLE infra_record
    TYPE string
    ASSERT $value IN ["unmanaged", "pending", "written", "published", "conflict", "yielded", "failed", "releasing", "released"]
    COMMENT "unmanaged (aucune zone), pending, written (écrit chez l'hébergeur), published (servi par tous les serveurs faisant autorité), conflict, yielded (valeur humaine laissée), failed, releasing (à retirer), released";

DEFINE FIELD OVERWRITE conflict ON TABLE infra_record
    TYPE option<object>
    COMMENT "Conflit en cours : { reason, observed, at }";

DEFINE FIELD OVERWRITE conflict.reason ON TABLE infra_record
    TYPE string
    ASSERT $value IN ["foreign_value", "foreign_singleton", "cname", "drift_modified"]
    COMMENT "foreign_value, foreign_singleton, cname, drift_modified";
DEFINE FIELD OVERWRITE conflict.observed ON TABLE infra_record
    TYPE array<string>
    ASSERT string::len(<string> $value) <= 4096
    COMMENT "Valeurs observées en cause (4 Kio au plus)";
DEFINE FIELD OVERWRITE conflict.at ON TABLE infra_record TYPE datetime COMMENT "Date d'entrée en conflit";

DEFINE FIELD OVERWRITE resolution ON TABLE infra_record
    TYPE option<object>
    COMMENT "Décision humaine sur le dernier conflit : { action, actor, at, applied_at }";

DEFINE FIELD OVERWRITE resolution.action ON TABLE infra_record
    TYPE string
    ASSERT $value IN ["take_over", "yield"]
    COMMENT "take_over : remplacer la valeur étrangère ; yield : laisser la valeur humaine";
DEFINE FIELD OVERWRITE resolution.actor ON TABLE infra_record TYPE string COMMENT "Auteur de la décision";
DEFINE FIELD OVERWRITE resolution.at ON TABLE infra_record TYPE datetime COMMENT "Date de la décision";
DEFINE FIELD OVERWRITE resolution.applied_at ON TABLE infra_record TYPE option<datetime> COMMENT "take_over : date de l'application chez l'hébergeur (la décision ne vaut qu'une fois)";

DEFINE FIELD OVERWRITE provider_ids ON TABLE infra_record
    TYPE array<object>
    DEFAULT []
    COMMENT "Écritures de Lyxal chez l'hébergeur : { id, value }";

DEFINE FIELD OVERWRITE provider_ids[*].id ON TABLE infra_record TYPE string COMMENT "Identifiant de l'enregistrement chez le fournisseur";
DEFINE FIELD OVERWRITE provider_ids[*].value ON TABLE infra_record TYPE string COMMENT "Valeur écrite";

DEFINE FIELD OVERWRITE applied_values ON TABLE infra_record
    TYPE array<string>
    DEFAULT []
    COMMENT "Valeurs écrites par Lyxal (une valeur différente chez l'hébergeur est une modification humaine)";

DEFINE FIELD OVERWRITE written_at ON TABLE infra_record TYPE option<datetime> COMMENT "Dernière écriture complète chez l'hébergeur";
DEFINE FIELD OVERWRITE published_at ON TABLE infra_record TYPE option<datetime> COMMENT "Publication constatée sur tous les serveurs faisant autorité";
DEFINE FIELD OVERWRITE verify_attempts ON TABLE infra_record TYPE int DEFAULT 0 COMMENT "Vérifications faites depuis written_at";
DEFINE FIELD OVERWRITE next_verify_at ON TABLE infra_record TYPE option<datetime> COMMENT "Prochaine vérification (état written)";

DEFINE FIELD OVERWRITE error ON TABLE infra_record
    TYPE option<object>
    COMMENT "Dernière erreur : { code, at }";
DEFINE FIELD OVERWRITE error.code ON TABLE infra_record TYPE string COMMENT "Code INFRA_*";
DEFINE FIELD OVERWRITE error.at ON TABLE infra_record TYPE datetime COMMENT "Date";

DEFINE FIELD OVERWRITE declared_at ON TABLE infra_record
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Dernière déclaration qui l'a changé";

DEFINE FIELD OVERWRITE updated_at ON TABLE infra_record
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE infra_record_subject ON TABLE infra_record FIELDS owner, subject;
DEFINE INDEX OVERWRITE infra_record_name ON TABLE infra_record FIELDS zone, fqdn, type;
DEFINE INDEX OVERWRITE infra_record_verify ON TABLE infra_record FIELDS state, next_verify_at;
DEFINE INDEX OVERWRITE infra_record_fqdn ON TABLE infra_record FIELDS fqdn;
