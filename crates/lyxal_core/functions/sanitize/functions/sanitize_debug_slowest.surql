-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_debug_slowest
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_debug_slowest($session:object,$limit:int)->array<object>{
 IF $limit<1{THROW "SANITIZE_DEBUG_INVALID_LIMIT";};
 LET $sorted = array::fold($session.traces,[],|$acc,$t|{LET $before=array::filter($acc,|$x|$x.duration>=$t.duration);LET $after=array::filter($acc,|$x|$x.duration<$t.duration);array::concat(array::append($before,$t),$after)});
 RETURN array::slice($sorted,0,$limit);
}
COMMENT "Retourne les traces les plus lentes."
PERMISSIONS FULL;
