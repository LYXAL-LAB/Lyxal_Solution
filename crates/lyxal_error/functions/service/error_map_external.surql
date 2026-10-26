-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_map_external                                                  │
-- │  Convertit un code d'erreur fournisseur vers une définition Lyxal       │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_map_external(
    $provider: option<string>,
    $service: option<string>,
    $external_code: option<string>,
    $http_status: option<int>
) {
    IF $provider == NONE OR $external_code == NONE {
        RETURN NONE;
    };

    LET $clean_provider = string::lowercase(string::trim($provider));
    LET $clean_ext_code = string::trim($external_code);

    LET $mappings = SELECT * FROM error_external_mapping 
                     WHERE provider = $clean_provider 
                       AND enabled = true 
                       AND (service = $service OR service = NONE) 
                     ORDER BY priority ASC;

    LET $match_res = NONE;

    FOR $m IN $mappings {
        LET $matched = IF $m.matcher == "exact" {
            $clean_ext_code == $m.external_code
        } ELSE IF $m.matcher == "prefix" {
            string::starts_with($clean_ext_code, $m.external_code)
        } ELSE IF $m.matcher == "contains" {
            string::contains($clean_ext_code, $m.external_code)
        } ELSE IF $m.matcher == "http_status" {
            $http_status != NONE AND string::from::number($http_status) == $m.external_code
        } ELSE {
            false
        };

        IF $matched AND $match_res == NONE {
            $match_res = {
                definition: $m.definition,
                retryable_override: $m.retryable_override,
                mapping: $m.id
            };
        };
    };

    RETURN $match_res;
} COMMENT "Convertit un code d'erreur fournisseur vers une correspondance canonique Lyxal";
