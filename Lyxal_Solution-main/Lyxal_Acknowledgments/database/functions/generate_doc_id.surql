/*
 * Function: fn::generate_doc_id
 * Description: Génère un identifiant unique pour les documents.
 * Note: Remplace l'implémentation Go (Timestamp Base36 + Suffix) par ULID (Universally Unique Lexicographically Sortable Identifier).
 * Les ULIDs sont triables par temps (comme l'implémentation originale) mais plus standards et natifs à SurrealDB.
 * 
 * Retourne:
 * string - Un ULID unique.
 */

DEFINE FUNCTION fn::generate_doc_id() {
    RETURN rand::ulid();
};
