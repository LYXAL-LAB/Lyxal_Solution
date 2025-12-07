-- ============================================================================
-- Fichier : resource/calendar/gestion_subscription/getSubscriptionsForUser.surql
-- Module : calendar
-- Fonction : fn::getSubscriptionsForUser
-- Description : Récupère la liste de tous les abonnements d'un utilisateur.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function getSubscriptionsForUser($principalUri) {
		$stmt = $this->db->prepare(
			'SELECT * FROM `*PREFIX*calendarsubscriptions`' .
			' WHERE `principaluri` = ?' .
			' ORDER BY `calendarorder` ASC'
		);
		$stmt->execute([$principalUri]);

		$subscriptions = [];
		while ($row = $stmt->fetch()) {
			$subscriptions[] = [
				'id' => (int)$row['id'],
				'uri' => $row['uri'],
				'principaluri' => $row['principaluri'],
				'source' => $row['source'],
				'displayname' => $row['displayname'],
				'refreshrate' => $row['refreshrate'],
				'calendarorder' => (int)$row['calendarorder'],
				'calendarcolor' => $row['calendarcolor'],
				'striptodos' => (bool)$row['striptodos'],
				'stripalarms' => (bool)$row['stripalarms'],
				'stripattachments' => (bool)$row['stripattachments'],
				'lastmodified' => (int)$row['lastmodified'],
			];
		}
		return $subscriptions;
	}
*/
