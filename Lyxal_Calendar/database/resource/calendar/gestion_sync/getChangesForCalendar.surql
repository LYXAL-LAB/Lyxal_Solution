-- ============================================================================
-- Fichier : resource/calendar/gestion_sync/getChangesForCalendar.surql
-- Module : calendar
-- Fonction : fn::getChangesForCalendar
-- Description : Retourne la liste des objets ajoutés, modifiés et supprimés dans un calendrier depuis la dernière synchronisation (via un syncToken).
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function getChangesForCalendar($calendarId, $syncToken, $syncLevel, $limit = null) {
		$calendar = $this->getCalendarById($calendarId);
		$this->checkAccessToCalendar($calendar, ICalendar::ACCESS_READ);

		// The sync-token is a timestamp. Not ideal, but it works.
		$stmt = $this.db->prepare('
			SELECT `uri`, `operation`
			FROM `*PREFIX*calendarchanges`
			WHERE `calendarid` = ? AND `synctoken` > ?
			ORDER BY `synctoken`
		');
		if ($limit !== null) {
			$stmt->setMaxResults($limit);
		}
		$stmt->execute([$calendarId, (int)$syncToken]);

		$result = [
			'syncToken' => $this->getCalendarById($calendarId)['synctoken'],
			'added'   => [],
			'modified'  => [],
			'deleted'   => [],
		];
		while ($row = $stmt->fetch()) {
			switch ((int)$row['operation']) {
				case CalendarObject::ACTION_ADD:
					$result['added'][] = $row['uri'];
					break;
				case CalendarObject::ACTION_MODIFY:
					$result['modified'][] = $row['uri'];
					break;
				case CalendarObject::ACTION_DELETE:
					$result['deleted'][] = $row['uri'];
					break;
			}
		}

		return $result;
	}
*/
