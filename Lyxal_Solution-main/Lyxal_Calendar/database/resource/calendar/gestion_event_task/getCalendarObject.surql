-- ============================================================================
-- Fichier : resource/calendar/gestion_event_task/getCalendarObject.surql
-- Module : calendar
-- Fonction : fn::getCalendarObject
-- Description : Récupère les données complètes d'un seul objet (y compris le contenu iCal).
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function getCalendarObject($calendarId, $objectUri) {
		$calendar = $this->getCalendarById($calendarId);
		if (!$calendar) {
			return null;
		}

		$this->checkAccessToCalendar($calendar, ICalendar::ACCESS_READ);

		$stmt = $this->db->prepare('
			SELECT `id`, `calendarid`, `uri`, `calendardata`, `lastmodified`, `etag`, `size`, `componenttype`, `firstoccurence`, `lastoccurence`, `uid`, `classification`
			FROM `*PREFIX*calendarobjects`
			WHERE `calendarid` = ? AND `uri` = ?
		');
		$stmt->execute([$calendarId, $objectUri]);

		$row = $stmt->fetch();
		if ($row === false) {
			return null;
		}

		return [
				'id' => (int)$row['id'],
				'calendarid' => (int)$row['calendarid'],
				'uri' => $row['uri'],
				'calendardata' => $row['calendardata'],
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
*/
