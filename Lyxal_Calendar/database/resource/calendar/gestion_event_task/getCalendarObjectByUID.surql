-- ============================================================================
-- Fichier : resource/calendar/gestion_event_task/getCalendarObjectByUID.surql
-- Module : calendar
-- Fonction : fn::getCalendarObjectByUID
-- Description : Retrouve un événement n'importe où dans les calendriers de l'utilisateur grâce à son identifiant unique global (UID).
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function getCalendarObjectByUID($principalUri, $uid) {
		$calendars = $this->getCalendarsForUser($principalUri);
		if (is_null($calendars)) {
			return null;
		}

		$calendarIds = array_map(function($calendar) {
			return $calendar['id'];
		}, $calendars);

		if (empty($calendarIds)) {
			return null;
		}

		$stmt = $this->db->prepare(
			'SELECT `calendardata` FROM `*PREFIX*calendarobjects`' .
			' WHERE `calendarid` IN (' . $this->db->quote($calendarIds, true) . ')' .
			' AND `uid` = ?'
		);
		$stmt->execute([$uid]);
		$result = $stmt->fetchColumn();
		return $result ? $result : null;
	}
*/
