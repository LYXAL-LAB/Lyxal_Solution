-- ============================================================================
-- Fichier : resource/calendar/gestion_event_task/getMultipleCalendarObjects.surql
-- Module : calendar
-- Fonction : fn::getMultipleCalendarObjects
-- Description : Récupère les données complètes de plusieurs objets en une seule fois.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function getMultipleCalendarObjects($calendarId, array $uris) {
		$calendar = $this->getCalendarById($calendarId);
		if (!$calendar) {
			return [];
		}
		$this->checkAccessToCalendar($calendar, ICalendar::ACCESS_READ);

		$query = $this->db->prepare('
			SELECT `uri`, `calendardata`, `lastmodified`, `etag`, `size`
			FROM `*PREFIX*calendarobjects`
			WHERE `calendarid` = ? AND `uri` IN (' . $this->db->quote($uris, \PDO::PARAM_STR, true) . ')
		');
		$query->execute([$calendarId]);

		$results = [];
		while ($row = $query->fetch()) {
			$results[] = [
				'calendarid' => $calendarId,
				'uri' => $row['uri'],
				'calendardata' => $row['calendardata'],
				'lastmodified' => (int)$row['lastmodified'],
				'etag' => $row['etag'],
				'size' => (int)$row['size'],
			];
		}

		return $results;
	}
*/
