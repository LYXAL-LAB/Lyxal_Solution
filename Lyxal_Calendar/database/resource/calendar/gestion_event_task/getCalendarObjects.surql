-- ============================================================================
-- Fichier : resource/calendar/gestion_event_task/getCalendarObjects.surql
-- Module : calendar
-- Fonction : fn::getCalendarObjects
-- Description : Récupère la liste de tous les objets d'un calendrier (métadonnées uniquement).
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function getCalendarObjects($calendarId) {
		$calendar = $this->getCalendarById($calendarId);
		if (!$calendar) {
			return [];
		}
		$this->checkAccessToCalendar($calendar, ICalendar::ACCESS_READ);

		$stmt = $this->db->prepare('
			SELECT `uri`, `lastmodified`, `etag`, `size`, `componenttype`, `firstoccurence`, `lastoccurence`, `uid`, `classification`
			FROM `*PREFIX*calendarobjects`
			WHERE `calendarid` = ?
		');
		$stmt->execute([$calendarId]);

		$results = [];
		while ($row = $stmt->fetch()) {
			$results[] = [
				'calendarid' => $calendarId,
				'uri' => $row['uri'],
				'lastmodified' => (int)$row['lastmodified'],
				'etag' => $row['etag'],
				'size' => (int)$row['size'],
				'component' => $row['componenttype'],
				'firstoccurence' => $row['firstoccurence'],
				'lastoccurence' => $row['lastoccurence'],
				'uid' => $row['uid'],
				'classification' => $row['classification'],
			];
		}

		return $results;
	}
*/
