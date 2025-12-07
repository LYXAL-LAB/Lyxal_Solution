-- ============================================================================
-- Fichier : resource/calendar/gestion_event_task/restoreCalendarObject.surql
-- Module : calendar
-- Fonction : fn::restoreCalendarObject
-- Description : Restaure un événement depuis la corbeille.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function restoreCalendarObject(int $calendarId, string $objectUri) {
		$calendar = $this->getCalendarById($calendarId);
		$this->checkAccessToCalendar($calendar, ICalendar::ACCESS_READWRITE);

		$this->trashService->restoreFromTrash($calendar, $objectUri);
	}
*/
