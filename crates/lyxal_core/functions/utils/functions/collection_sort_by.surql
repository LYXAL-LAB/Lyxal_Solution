-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_collection_sort_by
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_collection_sort_by(
    $value: array<object>,
    $key: string,
    $direction: string
) -> array<object> {
    LET $clean_direction = string::lowercase(
        string::trim($direction)
    );

    RETURN IF $clean_direction = "asc" {
        array::fold(
            $value,
            [],
            |$sorted, $item| {
                LET $ik = $item[$key];
                IF $ik IS NONE OR type::is_null($ik) {
                    array::append($sorted, $item)
                } ELSE {
                    LET $before = array::filter($sorted, |$x| $x[$key] IS NOT NONE AND !type::is_null($x[$key]) AND $x[$key] <= $ik);
                    LET $after  = array::filter($sorted, |$x| $x[$key] IS NONE OR type::is_null($x[$key]) OR $x[$key] > $ik);
                    array::concat(array::append($before, $item), $after)
                }
            }
        )
    } ELSE IF $clean_direction = "desc" {
        array::fold(
            $value,
            [],
            |$sorted, $item| {
                LET $ik = $item[$key];
                IF $ik IS NONE OR type::is_null($ik) {
                    array::append($sorted, $item)
                } ELSE {
                    LET $before = array::filter($sorted, |$x| $x[$key] IS NOT NONE AND !type::is_null($x[$key]) AND $x[$key] >= $ik);
                    LET $after  = array::filter($sorted, |$x| $x[$key] IS NONE OR type::is_null($x[$key]) OR $x[$key] < $ik);
                    array::concat(array::append($before, $item), $after)
                }
            }
        )
    } ELSE {
        THROW "UTILS_INVALID_SORT_DIRECTION"
    };
}
COMMENT "Trie une collection d'objets selon une clé."
PERMISSIONS FULL;
