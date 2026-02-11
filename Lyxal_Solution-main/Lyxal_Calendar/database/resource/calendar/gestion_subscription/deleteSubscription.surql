-- ============================================================================
-- Fichier : resource/calendar/gestion_subscription/deleteSubscription.surql
-- Module : calendar
-- Fonction : fn::deleteSubscription
-- Description : Supprime un abonnement.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function deleteSubscription($principalUri, $uri) {
		$stmt = $this->db->prepare(
			'DELETE FROM `*PREFIX*calendarsubscriptions`' .
			' WHERE `principaluri` = ? AND `uri` = ?'
		);
		$stmt->execute([$principalUri, $uri]);
	}
*/
