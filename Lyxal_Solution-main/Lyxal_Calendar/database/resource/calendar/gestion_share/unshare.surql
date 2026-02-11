-- ============================================================================
-- Fichier : resource/calendar/gestion_share/unshare.surql
-- Module : calendar
-- Fonction : fn::unshare
-- Description : Annule le partage d'un calendrier avec une personne.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :
 
	public function unshare($calendarId, $principalUri) {
		$calendar = $this->getCalendarById($calendarId);
		$this->checkAccessToCalendar($calendar, ICalendar::ACCESS_SHARE);

		list($shareType, $shareWith) = $this->getPrincipalTypeAndName($principalUri);
		$share = $this->shareManager->getShare(
			$this->principalBackend->getPrincipalByPath($calendar['principaluri'])['uid'],
			IShare::TYPE_CALENDAR,
			$this->stripCalendarId($calendar['uri']),
			$shareType,
			$shareWith
		);

		if ($share !== null) {
			$this->shareManager->deleteShare($share->getId());
		}
	}
*/
