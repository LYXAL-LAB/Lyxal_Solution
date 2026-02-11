-- ============================================================================
-- Fichier : resource/calendar/gestion_event_task/exportCalendar.surql
-- Module : calendar
-- Fonction : fn::exportCalendar
-- Description : Exporte tous les événements d'un calendrier sous forme de flux de données.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function exportCalendar($calendarId, $targetResource, callable $converter = null) {
		$calendar = $this->getCalendarById($calendarId);
		$this->checkAccessToCalendar($calendar, ICalendar::ACCESS_READ);

		$stmt = $this->db->prepare('
			SELECT `calendardata`
			FROM `*PREFIX*calendarobjects`
			WHERE `calendarid` = ?
		');
		$stmt->execute([$calendarId]);

		fwrite($targetResource, "BEGIN:VCALENDAR\r\n");
		$properties = [
			'VERSION' => '2.0',
			'PRODID' => '-//Nextcloud calendar v' . \OCP\App::getAppVersion('calendar'),
		];
		foreach ($properties as $key => $value) {
			fwrite($targetResource, $key . ':' . $value . "\r\n");
		}

		while ($data = $stmt->fetchColumn()) {
			if ($converter) {
				$data = $converter($data);
			}
			fwrite($targetResource, $data);
		}

		fwrite($targetResource, "END:VCALENDAR\r\n");
	}
*/
