/*
	-- Code PHP original de Nextcloud (référence)
	public function moveCalendar($uriName, $uriOrigin, $uriDestination, $newUriName = null) {
		// ... logique de UPDATE pour changer le champ `principaluri` ...
	}
*/

-- ============================================================================
-- Fichier : resource/calendar/gestion_calendar/moveCalendar.surql
-- Module : calendar
-- Fonction : fn::calendar_move (PLACEHOLDER)
-- Description : Transfère un calendrier d'un utilisateur à un autre.
--
-- !! NOTE D'ARCHITECTURE IMPORTANTE !!
-- Dans notre architecture multi-tenant où chaque utilisateur a sa propre base de
-- données, le "déplacement" d'un calendrier n'est pas une simple mise à jour
-- de champ. C'est une opération de migration de données complexe qui ne peut pas
-- être gérée par une simple fonction s'exécutant dans le contexte d'un seul
-- utilisateur.
--
-- Cette opération doit être orchestrée par un service d'administration de plus
-- haut niveau qui a les droits nécessaires pour accéder à plusieurs bases de données.
--
-- La logique requise est la suivante :
-- 1. Se connecter à la base de données de l'utilisateur d'origine.
-- 2. Lire l'enregistrement du calendrier à déplacer.
-- 3. Lire TOUS les enregistrements dépendants (événements dans `calendarobjects`,
--    propriétés dans `calendarobjectprops`, historique dans `calendarchanges`, etc.).
-- 4. Se connecter à la base de données de l'utilisateur de destination.
-- 5. Recréer le calendrier et tous ses enregistrements dépendants dans cette
--    nouvelle base de données.
-- 6. Revenir à la base de données de l'utilisateur d'origine et effectuer une
--    suppression permanente (hard delete) du calendrier et de toutes ses données.
--
-- Ce fichier est donc un placeholder pour cette logique d'administration future.
-- ============================================================================
