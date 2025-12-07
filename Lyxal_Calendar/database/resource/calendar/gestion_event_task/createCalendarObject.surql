-- ============================================================================
-- Fichier : resource/calendar/gestion_event_task/createCalendarObject.surql
-- Module : calendar
-- Fonction : fn::createCalendarObject
-- Description : Crée un nouvel événement ou une nouvelle tâche dans un calendrier.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function createCalendarObject($calendarId, $objectUri, $calendarData) {
		$calendar = $this->getCalendarById($calendarId);
		$this->checkAccessToCalendar($calendar, ICalendar::ACCESS_READWRITE);

		try {
			$this->validateCalendarData($calendarData, $calendar);
		} catch (InvalidCalendarObjectException $e) {
			$this->logger->warning('Invalid calendar object for creation in calendar {id}: {message}', [
				'id' => $calendarId,
				'message' => $e->getMessage(),
			]);
			throw $e;
		}

		$extraData = $this->getExtraCalendarObjectData($calendarId, $objectUri, $calendarData);

		$stmt = $this->db->prepare('INSERT INTO `*PREFIX*calendarobjects` (
			`calendarid`, `uri`, `calendardata`, `lastmodified`, `etag`, `size`, `componenttype`, `firstoccurence`, `lastoccurence`, `uid`, `classification`
			) VALUES (?,?,?,?,?,?,?,?,?,?,?)');
		$stmt->execute([
			$calendarId,
			$objectUri,
			$extraData['calendarData'],
			$extraData['lastmodified'],
			$extraData['etag'],
			$extraData['size'],
			$extraData['componentType'],
			$extraData['firstOccurence'],
			$extraData['lastOccurence'],
			$extraData['uid'],
			$extraData['classification'],
		]);

		$this->addChange($calendarId, $objectUri, CalendarObject::ACTION_ADD);

		return '"' . $extraData['etag'] . '"';
	}
*/
