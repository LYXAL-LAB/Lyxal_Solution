-- ============================================================================
-- Fichier : resource/calendar/gestion_event_task/updateCalendarObject.surql
-- Module : calendar
-- Fonction : fn::updateCalendarObject
-- Description : Met à jour un événement existant.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function updateCalendarObject($calendarId, $objectUri, $calendarData) {
		$calendar = $this->getCalendarById($calendarId);
		$this->checkAccessToCalendar($calendar, ICalendar::ACCESS_READWRITE);

		try {
			$this->validateCalendarData($calendarData, $calendar);
		} catch (InvalidCalendarObjectException $e) {
			$this->logger->warning('Invalid calendar object for update in calendar {id}: {message}', [
				'id' => $calendarId,
				'message' => $e->getMessage(),
			]);
			throw $e;
		}

		$extraData = $this->getExtraCalendarObjectData($calendarId, $objectUri, $calendarData);

		$stmt = $this->db->prepare(
			'UPDATE `*PREFIX*calendarobjects` SET' .
			' `calendardata` = ?,' .
			' `lastmodified` = ?,' .
			' `etag` = ?,' .
			' `size` = ?,' .
			' `componenttype` = ?,' .
			' `firstoccurence` = ?,' .
			' `lastoccurence` = ?,' .
			' `uid` = ?,' .
			' `classification` = ?' .
			' WHERE `calendarid` = ? AND `uri` = ?'
		);
		$stmt->execute([
			$extraData['calendarData'],
			$extraData['lastmodified'],
			$extraData['etag'],
			$extraData['size'],
			$extraData['componentType'],
			$extraData['firstOccurence'],
			$extraData['lastOccurence'],
			$extraData['uid'],
			$extraData['classification'],
			$calendarId,
			$objectUri,
		]);

		$this->addChange($calendarId, $objectUri, CalendarObject::ACTION_MODIFY);

		return '"' . $extraData['etag'] . '"';
	}
*/
