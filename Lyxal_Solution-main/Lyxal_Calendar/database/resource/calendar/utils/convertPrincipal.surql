-- ============================================================================
-- Fichier : resource/calendar/utils/convertPrincipal.surql
-- Module : calendar
-- Fonction : fn::convertPrincipal
-- Description : Gère la conversion des identifiants de principaux.
--
-- REFLEXION D'ARCHITECTURE - (À ADAPTER SELON VOS BESOINS) :
-- Cette fonction est une simplification de la logique de Nextcloud. Elle devra
-- être affinée pour correspondre aux décisions d'architecture finales de Lyxal.
-- Les points à considérer sont :
--
-- 1. Format de l'Identifiant : Quel sera le format exact des identifiants ?
--    (ex: `users/uuid`, `organisation/user`, etc.). La logique de parsing
--    devra être adaptée à ce format.
--
-- 2. Multi-Tenancy : Comment gérer les identifiants globaux (pour le partage
--    entre différentes bases de données/namespaces) par rapport aux identifiants
--    locaux ?
--
-- 3. Types de Principaux : La fonction devra-t-elle différencier les types
--    de principaux (utilisateurs, groupes, services, etc.) ?
--    (ex: `principals/users/yaniss` vs `principals/groups/devs`).
--
-- Pour l'instant, elle assure une compatibilité de base en retirant le préfixe
-- "principals/", comme le fait Nextcloud dans le cas le plus simple.
-- ============================================================================
DEFINE FUNCTION fn::convertPrincipal($principalUri: string, $toDatabaseFormat: bool) {
    -- Logique de conversion du principal
    -- Exemple basique :
    IF $toDatabaseFormat {
        RETURN string::replace($principalUri, "principals/", "");
    } ELSE {
        RETURN $principalUri;
    };
};