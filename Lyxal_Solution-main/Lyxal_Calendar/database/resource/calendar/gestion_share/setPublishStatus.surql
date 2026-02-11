-- ============================================================================
-- Fichier : resource/calendar/gestion_share/setPublishStatus.surql
-- Module : calendar
-- Fonction : fn::setPublishStatus
-- Description : Active ou désactive le partage public d'un calendrier via un lien.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :
 
	public function setPublishStatus($calendarId, $status) {
		$calendar = $this->getCalendarById($calendarId);
		$this->checkAccessToCalendar($calendar, ICalendar::ACCESS_READWRITE);

		$share = $this->shareManager->getShare(
			$this->principalBackend->getPrincipalByPath($calendar['principaluri'])['uid'],
			IShare::TYPE_CALENDAR,
			$this->stripCalendarId($calendar['uri']),
			IShare::TYPE_LINK,
			null
		);

		if ($status) {
			if ($share === null) {
				$share = $this->shareManager->newShare();
				$share->setNodeId($calendar['id']);
				$share->setPermissions(ICalendar::ACCESS_READ);
				$share->setSharedBy($this->principalBackend->getPrincipalByPath($calendar['principaluri'])['uid']);
				$share->setSharedWith(null);
				$share->setShareType(IShare::TYPE_CALENDAR);
				$share->setSharedWithType(IShare::TYPE_LINK);
				$this->shareManager->createShare($share);
			}
		} else {
			if ($share !== null) {
				$this->shareManager->deleteShare($share->getId());
			}
		}
	}
*/
