/*
	-- Code PHP original de Nextcloud (référence)
	public function getCalendarsForUser($principalUri) {
		// ... logique pour récupérer les calendriers propres ...
		// ... logique pour récupérer les calendriers partagés ...
		// ... fusionner les deux listes ...
	}
*/

-- ============================================================================
-- Fichier : resource/calendar/gestion_calendar/getCalendarsForUser.surql
-- Module : calendar
-- Fonction : fn::calendar_get_all_for_user (INCOMPLET)
-- Description : Récupère TOUS les calendriers auxquels un utilisateur a accès.
--
-- !! NOTE D'ARCHITECTURE IMPORTANTE !!
-- Cette fonction est plus complexe qu'il n'y paraît dans notre architecture.
-- Elle doit retourner deux ensembles de données :
-- 1. Les calendriers propres à l'utilisateur : Ceux qui sont dans sa propre base de données.
--    (Logique implémentée dans `fn::calendar_get_own`)
-- 2. Les calendriers partagés par d'autres : Ceux qui sont dans les bases de données
--    d'autres utilisateurs.
--
-- La récupération des calendriers partagés ne peut pas se faire via une simple
-- fonction dans la base de données de l'utilisateur courant. Elle nécessitera
-- une logique "backend" de plus haut niveau, capable d'interroger la table
-- `davshares` de plusieurs utilisateurs pour trouver les partages destinés
-- à l'utilisateur courant.
--
-- Ce fichier est donc un placeholder pour cette logique future.
-- ============================================================================

-- DEFINE FUNCTION fn::calendar_get_all_for_user($user_id: string) {
--     -- Étape 1 : Récupérer les calendriers propres
--     LET $own_calendars = fn::calendar_get_own();
--
--     -- Étape 2 : Logique de récupération des calendriers partagés (à implémenter en backend)
--     -- LET $shared_calendars = ...
--
--     -- Étape 3 : Fusionner les résultats
--     -- RETURN array::union($own_calendars, $shared_calendars);
-- };
