-- ============================================================================
-- FONCTIONS : lecture et contrôle d'un message ICU MessageFormat 1
-- MODULE    : lyxal_i18n
-- ============================================================================
-- Contrôle à l'écriture (décision Q4) : arguments, types, branches et formes de pluriel. La
-- syntaxe complète reste vérifiée par le rendu Rust. Fonctions internes au module.

-- ----------------------------------------------------------------------------
-- fn::i18n_message_argument (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_message_argument($head: string, $selectors: array<string>) -> object {
    LET $parts = string::split($head, ",");
    RETURN {
        name: string::trim($parts[0]),
        kind: IF array::len($parts) > 1 { string::trim($parts[1]) } ELSE { "none" },
        selectors: $selectors
    };
} COMMENT "Interne : argument { name, kind, selectors } lu dans l'en-tête « nom[, type[, style]] » d'un argument MessageFormat";

-- ----------------------------------------------------------------------------
-- fn::i18n_message_step (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_message_step($state: object, $char: string) -> object {
    -- 1. Apostrophes : « '' » est une apostrophe ; « ' » devant { } # | ouvre un texte littéral
    --    fermé par l'apostrophe suivante
    LET $s = IF $state.quote {
        IF $state.pending {
            IF $char = "'" { $state + { pending: false, literal: true } }
            ELSE { $state + { pending: false, quote: false, literal: false } }
        } ELSE IF $char = "'" { $state + { pending: true, literal: true } }
        ELSE { $state + { literal: true } }
    } ELSE IF $state.pending {
        IF $char IN ["{", "}", "#", "|"] { $state + { pending: false, quote: true, literal: true } }
        ELSE IF $char = "'" { $state + { pending: false, literal: true } }
        ELSE { $state + { pending: false, literal: false } }
    } ELSE IF $char = "'" { $state + { pending: true, literal: true } }
    ELSE { $state + { literal: false } };
    IF $s.literal { RETURN $s; };
    -- 2. Structure : les accolades alternent (argument, puis sous-message d'une branche)
    LET $in_argument = $s.open_argument;
    LET $top = array::last($s.frames);
    LET $rest = array::slice($s.frames, 0, array::len($s.frames) - 1);
    IF $char = "{" {
        IF !$in_argument {
            RETURN $s + { frames: array::append($s.frames, { head: NONE, buffer: "", selectors: [] }), open_argument: true };
        };
        -- Sous-message d'une branche : l'en-tête se termine, le dernier mot est le sélecteur
        LET $words = string::words(IF $top.head IS NONE { array::join(array::slice(string::split($top.buffer, ","), 2), ",") } ELSE { $top.buffer });
        LET $frame = {
            head: $top.head ?? $top.buffer,
            buffer: "",
            selectors: array::append($top.selectors, array::last($words) ?? "")
        };
        RETURN $s + { frames: array::append($rest, $frame), open_argument: false };
    };
    IF $char = "}" {
        IF $in_argument {
            LET $argument = fn::i18n_message_argument($top.head ?? $top.buffer, $top.selectors);
            RETURN $s + { frames: $rest, arguments: array::append($s.arguments, $argument), open_argument: false };
        };
        -- Fin d'un sous-message : retour dans l'argument qui le contient
        IF array::len($s.frames) = 0 { RETURN $s + { balanced: false }; };
        RETURN $s + { open_argument: true };
    };
    IF $in_argument {
        RETURN $s + { frames: array::append($rest, $top + { buffer: $top.buffer + $char }) };
    };
    RETURN $s;
} COMMENT "Interne : avance d'un caractère la lecture d'un message MessageFormat (apostrophes d'échappement, alternance argument / sous-message)";

-- ----------------------------------------------------------------------------
-- fn::i18n_message_inspect (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_message_inspect($text: string) -> object {
    LET $chars = array::filter(string::split($text, ""), |$c| $c != "");
    LET $end = array::fold($chars,
        { quote: false, pending: false, literal: false, frames: [], open_argument: false, arguments: [], balanced: true },
        |$state, $char| fn::i18n_message_step($state, $char));
    RETURN { balanced: $end.balanced AND array::len($end.frames) = 0, arguments: $end.arguments };
} COMMENT "Interne : arguments d'un message MessageFormat 1 : { balanced, arguments: [{ name, kind, selectors }] } (accolades équilibrées, arguments imbriqués compris)";

-- ----------------------------------------------------------------------------
-- fn::i18n_message_check (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_message_check($input: object) -> object {
    LET $length = string::len($input.text);
    LET $too_long = IF $input.max_length IS NOT NONE AND $length > $input.max_length {
        [{ code: "too_long", max_length: $input.max_length, length: $length }]
    } ELSE { [] };
    IF $input.syntax = "plain" { RETURN { problems: $too_long, warnings: [] }; };
    LET $message = fn::i18n_message_inspect($input.text);
    IF !$message.balanced {
        RETURN { problems: array::concat($too_long, [{ code: "unbalanced_braces" }]), warnings: [] };
    };
    LET $declared = object::from_entries(array::map($input.params, |$p| [$p.name, $p.type]));
    LET $locale = (SELECT plural_cardinal, plural_ordinal FROM ONLY $input.locale);
    -- Type attendu du paramètre selon l'usage de l'argument
    LET $expected = { number: "number", plural: "number", selectordinal: "number", date: "datetime", time: "datetime", select: "string" };
    LET $issues = array::flatten(array::map($message.arguments, |$a| {
        IF !fn::validation_identifier($a.name, 1, 64).valid { RETURN [{ code: "invalid_argument", argument: $a.name }]; };
        IF $a.kind NOT IN ["none", "number", "date", "time", "plural", "selectordinal", "select"] {
            RETURN [{ code: "unsupported_type", argument: $a.name, type: $a.kind }];
        };
        IF $a.name NOT IN object::keys($declared) { RETURN [{ code: "unknown_argument", argument: $a.name }]; };
        IF $a.kind != "none" AND $declared[$a.name] != $expected[$a.kind] {
            RETURN [{ code: "type_mismatch", argument: $a.name, type: $a.kind, expected: $declared[$a.name] }];
        };
        IF $a.kind NOT IN ["plural", "selectordinal", "select"] { RETURN []; };
        LET $missing_other = IF "other" IN $a.selectors { [] } ELSE { [{ code: "missing_other", argument: $a.name }] };
        IF $a.kind = "select" { RETURN $missing_other; };
        LET $categories = IF $a.kind = "plural" { $locale.plural_cardinal } ELSE { $locale.plural_ordinal };
        -- « =N » désigne une valeur exacte, pas une catégorie
        LET $used = array::filter($a.selectors, |$s| !string::starts_with($s, "="));
        RETURN array::concat(
            $missing_other,
            array::map(array::filter($used, |$s| $s NOT IN $categories), |$s| { code: "unknown_category", argument: $a.name, category: $s }),
            array::map(array::filter($categories, |$c| $c NOT IN $used AND $c != "other"), |$c| { code: "missing_category", argument: $a.name, category: $c, warning: true })
        );
    }));
    LET $used_names = array::distinct(array::map($message.arguments, |$a| $a.name));
    RETURN {
        problems: array::concat($too_long, array::filter($issues, |$i| $i.warning IS NONE)),
        warnings: array::concat(
            array::map(array::filter($issues, |$i| $i.warning = true), |$i| { code: $i.code, argument: $i.argument, category: $i.category }),
            array::map(array::filter(object::keys($declared), |$n| $n NOT IN $used_names), |$n| { code: "unused_parameter", argument: $n })
        )
    };
} COMMENT "Interne : contrôle un texte ({ text, syntax, params, locale, max_length }) : { problems, warnings }. Refus : accolades, argument invalide, inconnu ou de type incompatible, branche other absente, catégorie de pluriel inconnue de la langue, longueur ; avertissements : catégorie absente, paramètre inutilisé";
