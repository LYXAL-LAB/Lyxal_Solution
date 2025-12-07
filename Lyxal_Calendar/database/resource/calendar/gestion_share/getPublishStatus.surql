-- ============================================================================
-- Fichier : resource/calendar/gestion_share/getPublishStatus.surql
-- Module : calendar
-- Fonction : fn::getPublishStatus
-- Description : Vérifie si un calendrier est partagé publiquement.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :
 
	public function getPublishStatus($calendarId) {
		$calendar = $this->getCalendarById($calendarId);
		$this->checkAccessToCalendar($calendar, ICalendar::ACCESS_READ);

		return $this->shareManager->isShared(
			$this->principalBackend->getPrincipalByPath($calendar['principaluri'])['uid'],
			IShare::TYPE_CALENDAR,
			$this->stripCalendarId($calendar['uri']),
			IShare::TYPE_LINK,
			null
		);
	}
*/
