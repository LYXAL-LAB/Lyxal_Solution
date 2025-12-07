-- ============================================================================
-- Fichier : resource/calendar/gestion_event_task/moveCalendarObject.surql
-- Module : calendar
-- Fonction : fn::moveCalendarObject
-- Description : Déplace un événement d'un calendrier à un autre.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function moveCalendarObject($sourceCalendarId, $sourceObjectUri, $destinationCalendarId, $destinationObjectUri, $calendarData) {
		// We have to check if the destination calendar allows the object
		$destinationCalendar = $this->getCalendarById($destinationCalendarId);
		$this->checkAccessToCalendar($destinationCalendar, ICalendar::ACCESS_READWRITE);

		try {
			$this->validateCalendarData($calendarData, $destinationCalendar);
		} catch (InvalidCalendarObjectException $e) {
			$this->logger->warning('Invalid calendar object for move to calendar {id}: {message}', [
				'id' => $destinationCalendarId,
				'message' => $e->getMessage(),
			]);
			throw $e;
		}

		// First we create the new object
		$this->createCalendarObject($destinationCalendarId, $destinationObjectUri, $calendarData);

		// Then we delete the old one
		$this->deleteCalendarObject($sourceCalendarId, $sourceObjectUri);

		return true;
	}
*/
