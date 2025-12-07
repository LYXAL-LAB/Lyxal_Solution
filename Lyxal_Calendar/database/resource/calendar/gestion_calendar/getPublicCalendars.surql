/*
	-- Code PHP original de Nextcloud (référence)
	public function getPublicCalendars() {
		// ... logique de JOIN entre dav_shares et calendars ...
		// ... WHERE access = 'public' ...
	}
*/

-- ============================================================================
-- Fichier : resource/calendar/gestion_calendar/getPublicCalendars.surql
-- Module : calendar
-- Fonction : fn::calendar_get_public (PLACEHOLDER)
-- Description : Récupère la liste de tous les calendriers partagés publiquement.
--
-- !! NOTE D'ARCHITECTURE IMPORTANTE !!
-- La recherche de TOUS les calendriers publics est une requête "cross-namespace"
-- par nature. Une fonction s'exécutant dans la base de données d'un utilisateur
-- spécifique ne peut pas voir les partages publics créés par d'autres utilisateurs.
--
-- La résolution de ce problème nécessitera une logique de backend de plus
-- haut niveau ou une modification de notre modèle de données.
--
-- Solutions Possibles :
-- 1. Table `davshares` Centralisée : Au lieu d'une table `davshares` par utilisateur,
--    une seule table globale contiendrait tous les partages. Une fonction
--    globale (pas une fonction utilisateur) pourrait alors facilement requêter
--    tous les partages publics.
--
-- 2. Index de Recherche Global : Un service externe pourrait indexer tous les
--    partages publics dans un moteur de recherche (ex: MeiliSearch, Elasticsearch)
--    pour les rendre facilement découvrables.
--
-- Ce fichier est donc un placeholder pour cette logique future.
-- ============================================================================

-- Le code ci-dessous est un exemple conceptuel de ce à quoi la requête pourrait
-- ressembler si la table `davshares` était globale.

-- DEFINE FUNCTION fn::calendar_get_public() {
--     -- Cette requête ne fonctionnerait que sur une table `davshares` globale
--     RETURN (
--         SELECT *, resource.* as calendar FROM davshares 
--         WHERE content.share_type = <share_types:calendar> 
--         AND content.access_level = <access_levels:public>
--     );
-- };
