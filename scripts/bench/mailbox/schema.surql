-- Banc de mesure « boîte aux lettres » (lot 0 du programme courrier, décision C5).
-- Schéma d'essai, hors modules : il n'est installé par aucun manifeste et ne sert qu'au banc
-- `bench_mailbox.py`. Il modélise ce qu'un magasin de courrier doit tenir : un compte, ses
-- dossiers, et les métadonnées de ses messages (les octets des messages restent hors base).

DEFINE TABLE OVERWRITE bench_account SCHEMAFULL;
DEFINE FIELD OVERWRITE email ON TABLE bench_account TYPE string;

-- Dossier : compteurs IMAP (prochain UID, plus haut numéro de modification) et compteurs
-- tenus à jour à l'écriture (total, non lus), lus par la variante « compteur tenu ».
DEFINE TABLE OVERWRITE bench_mailbox SCHEMAFULL;
DEFINE FIELD OVERWRITE account ON TABLE bench_mailbox TYPE record<bench_account>;
DEFINE FIELD OVERWRITE name ON TABLE bench_mailbox TYPE string;
DEFINE FIELD OVERWRITE uid_validity ON TABLE bench_mailbox TYPE int;
DEFINE FIELD OVERWRITE uid_next ON TABLE bench_mailbox TYPE int;
DEFINE FIELD OVERWRITE highest_modseq ON TABLE bench_mailbox TYPE int;
DEFINE FIELD OVERWRITE total ON TABLE bench_mailbox TYPE int;
DEFINE FIELD OVERWRITE unseen ON TABLE bench_mailbox TYPE int;
DEFINE INDEX OVERWRITE bench_mailbox_account_name ON TABLE bench_mailbox FIELDS account, name UNIQUE;

-- Message : une ligne par message et par dossier.
DEFINE TABLE OVERWRITE bench_message SCHEMAFULL;
DEFINE FIELD OVERWRITE account ON TABLE bench_message TYPE record<bench_account>;
DEFINE FIELD OVERWRITE mailbox ON TABLE bench_message TYPE record<bench_mailbox>;
DEFINE FIELD OVERWRITE uid ON TABLE bench_message TYPE int;
DEFINE FIELD OVERWRITE modseq ON TABLE bench_message TYPE int;
DEFINE FIELD OVERWRITE received_at ON TABLE bench_message TYPE datetime;
DEFINE FIELD OVERWRITE size ON TABLE bench_message TYPE int;
DEFINE FIELD OVERWRITE seen ON TABLE bench_message TYPE bool;
DEFINE FIELD OVERWRITE flagged ON TABLE bench_message TYPE bool;
DEFINE FIELD OVERWRITE answered ON TABLE bench_message TYPE bool;
DEFINE FIELD OVERWRITE draft ON TABLE bench_message TYPE bool;
DEFINE FIELD OVERWRITE deleted ON TABLE bench_message TYPE bool;
DEFINE FIELD OVERWRITE keywords ON TABLE bench_message TYPE array<string>;
DEFINE FIELD OVERWRITE thread ON TABLE bench_message TYPE string;
DEFINE FIELD OVERWRITE message_id ON TABLE bench_message TYPE string;
DEFINE FIELD OVERWRITE from_addr ON TABLE bench_message TYPE string;
DEFINE FIELD OVERWRITE from_name ON TABLE bench_message TYPE string;
DEFINE FIELD OVERWRITE subject ON TABLE bench_message TYPE string;
DEFINE FIELD OVERWRITE blob_ref ON TABLE bench_message TYPE string;

-- Index qu'un magasin de courrier définirait.
DEFINE INDEX OVERWRITE bench_message_mailbox_uid ON TABLE bench_message FIELDS mailbox, uid UNIQUE;
DEFINE INDEX OVERWRITE bench_message_mailbox_received ON TABLE bench_message FIELDS mailbox, received_at;
DEFINE INDEX OVERWRITE bench_message_mailbox_modseq ON TABLE bench_message FIELDS mailbox, modseq;
DEFINE INDEX OVERWRITE bench_message_mailbox_seen ON TABLE bench_message FIELDS mailbox, seen;
DEFINE INDEX OVERWRITE bench_message_account_thread ON TABLE bench_message FIELDS account, thread;
DEFINE INDEX OVERWRITE bench_message_account_from ON TABLE bench_message FIELDS account, from_addr, received_at;
