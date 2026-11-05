-- ============================================================================
-- FONCTION : fn::catalogue_variante_fingerprint (interne)
-- MODULE   : lyxal_catalogue
-- RÔLE     : Empreinte canonique d'une combinaison d'attributs de variante
-- ============================================================================
-- Seul endroit où l'empreinte est calculée : événements de recalcul et de protection
-- (schema/07, schema/08) et contrôle de doublon de fn::catalogue_variante_set_attributs.
-- $params.pairs : tableau de { attribut, attribut_valeur } (Record IDs) ; l'ordre est
-- sans effet. Renvoie le SHA-256 hexadécimal de « attribut:valeur » triés, joints par « | ».

DEFINE FUNCTION OVERWRITE fn::catalogue_variante_fingerprint($params: object) -> string {
    LET $pairs = array::sort(array::map($params.pairs, |$a| string::concat(<string> $a.attribut, ":", <string> $a.attribut_valeur)));
    RETURN crypto::sha256(array::join($pairs, "|"));
} COMMENT "Interne : empreinte canonique (SHA-256) d'une combinaison d'attributs de variante";
