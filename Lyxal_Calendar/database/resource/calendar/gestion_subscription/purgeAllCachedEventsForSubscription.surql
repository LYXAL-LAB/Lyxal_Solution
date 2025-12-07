-- ============================================================================
-- Fichier : resource/calendar/gestion_subscription/purgeAllCachedEventsForSubscription.surql
-- Module : calendar
-- Fonction : fn::purgeAllCachedEventsForSubscription
-- Description : Vide le cache de tous les événements d'un calendrier auquel on est abonné.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function purgeAllCachedEventsForSubscription(int $subscriptionId) {
		$stmt = $this->db->prepare(
			'DELETE FROM `*PREFIX*calendarobjects_props`' .
			' WHERE `calendarid` = ?'
		);
		$stmt->execute([-$subscriptionId]);

		$stmt = $this->db->prepare(
			'DELETE FROM `*PREFIX*calendarobjects`' .
			' WHERE `calendarid` = ?'
		);
		$stmt->execute([-$subscriptionId]);
	}
*/
