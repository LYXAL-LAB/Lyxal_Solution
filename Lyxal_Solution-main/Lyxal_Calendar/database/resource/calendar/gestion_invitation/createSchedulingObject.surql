-- ============================================================================
-- Fichier : resource/calendar/gestion_invitation/createSchedulingObject.surql
-- Module : calendar
-- Fonction : fn::createSchedulingObject
-- Description : Ajoute une nouvelle invitation dans la boîte de réception d'un utilisateur.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function createSchedulingObject($principalUri, $objectUri, $objectData) {
		$extraData = $this->getExtraCalendarObjectData(null, $objectUri, $objectData);

		$stmt = $this->db->prepare(
			'INSERT INTO `*PREFIX*schedulingobjects` (`principaluri`, `uri`, `calendardata`, `lastmodified`, `etag`, `size`)' .
			' VALUES (?, ?, ?, ?, ?, ?)'
		);
		$stmt->execute([
			$principalUri,
			$objectUri,
			$extraData['calendarData'],
			$extraData['lastmodified'],
			$extraData['etag'],
			$extraData['size'],
		]);
	}
*/
