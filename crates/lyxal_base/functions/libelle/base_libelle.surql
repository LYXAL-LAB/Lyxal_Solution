-- ============================================================================
-- FONCTIONS : libellés des unités et des types d'unités (clés lyxal_i18n)
-- MODULE    : lyxal_base
-- ============================================================================
-- Le libellé d'une unité est le texte de la clé base.unite_<code> ; celui d'un type, de la clé
-- base.unite_type_<code> (code en minuscules). Texte source en français, syntaxe plain.

-- ----------------------------------------------------------------------------
-- fn::base_libelle_name (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::base_libelle_name($kind: string, $code: string) -> string {
    RETURN string::concat($kind, "_", fn::sanitize_lowercase($code));
} COMMENT "Interne : nom de la clé du libellé dans l'espace de noms base ($kind : unite ou unite_type) ; clé complète : base.<nom>";

-- ----------------------------------------------------------------------------
-- fn::base_libelle_attach (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::base_libelle_attach($records: array<object>, $kind: string, $locale: string) -> object {
    IF array::len($records) = 0 { RETURN { error: NONE, records: [] }; };
    LET $resolved = fn::i18n_resolve_many({
        keys: array::map($records, |$r| string::concat("base.", fn::base_libelle_name($kind, $r.code))),
        locale: $locale
    });
    IF !$resolved.ok { RETURN { error: $resolved.error.code, records: [] }; };
    LET $texts = $resolved.data;
    RETURN {
        error: NONE,
        records: array::map(<array> (0..array::len($records)), |$i| object::extend($records[$i], { libelle: $texts[$i].text }))
    };
} COMMENT "Interne : ajoute à chaque enregistrement ({ code, … }) son libellé dans la langue demandée (repli de lyxal_i18n : langue parente, langue par défaut, texte source) ; { error, records }";

-- ----------------------------------------------------------------------------
-- fn::base_libelle_create (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::base_libelle_create($kind: string, $code: string, $libelle: string) -> option<string> {
    LET $created = fn::i18n_key_create({
        namespace: "base",
        name: fn::base_libelle_name($kind, $code),
        source_text: $libelle,
        syntax: "plain",
        description: IF $kind = "unite" { string::concat("Libellé de l'unité ", $code) } ELSE { string::concat("Libellé du type d'unité ", $code) }
    });
    RETURN IF $created.ok { NONE } ELSE { $created.error.code };
} COMMENT "Interne : crée la clé du libellé avec son texte source ; NONE, ou le code d'erreur I18N_* reçu";

-- ----------------------------------------------------------------------------
-- fn::base_libelle_update (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::base_libelle_update($kind: string, $code: string, $libelle: string) -> option<string> {
    LET $written = fn::i18n_translation_set({
        key: string::concat("base.", fn::base_libelle_name($kind, $code)),
        locale: "fr",
        text: $libelle
    });
    RETURN IF $written.ok { NONE } ELSE { $written.error.code };
} COMMENT "Interne : remplace le texte source du libellé, en français, langue source de l'espace de noms base (les traductions deviennent obsolètes) ; NONE, ou le code d'erreur I18N_* reçu";

-- ----------------------------------------------------------------------------
-- fn::base_libelle_delete (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::base_libelle_delete($kind: string, $code: string) -> option<string> {
    LET $deleted = fn::i18n_key_delete({ key: string::concat("base.", fn::base_libelle_name($kind, $code)) });
    RETURN IF $deleted.ok { NONE } ELSE { $deleted.error.code };
} COMMENT "Interne : supprime la clé du libellé et toutes ses traductions ; NONE, ou le code d'erreur I18N_* reçu";
