-- ============================================================================
-- Fichier : resource/calendar/gestion_event_task/deleteCalendarObject.surql
-- Module : calendar
-- Fonction : fn::deleteCalendarObject
-- Description : Supprime un événement (le met à la corbeille ou le supprime définitivement).
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function deleteCalendarObject($calendarId, $objectUri) {
		$calendar = $this->getCalendarById($calendarId);
		$this->checkAccessToCalendar($calendar, ICalendar::ACCESS_READWRITE);

		if ($this->trashService->isEnabled()) {
			$this->trashService->moveToTrash($calendar, $objectUri);
		} else {
			$this->deleteCalendarObjectForReal($calendarId, $objectUri);
		}
		$this->addChange($calendarId, $objectUri, CalendarObject::ACTION_DELETE);
	}

	protected function deleteCalendarObjectForReal($calendarId, $objectUri) {
		$stmt = $this->db->prepare('DELETE FROM `*PREFIX*calendarobjects` WHERE `calendarid` = ? AND `uri` = ?');
		$stmt->execute([$calendarId, $objectUri]);

		// delete properties
		$stmt = $this->db->prepare('DELETE FROM `*PREFIX*calendarobject_props` WHERE `calendarid` = ? AND `uri` = ?');
		$stmt->execute([$calendarId, $objectUri]);
	}
*/
