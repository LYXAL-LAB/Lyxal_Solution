-- ============================================================================
-- Fichier : resource/calendar/gestion_share/getShares.surql
-- Module : calendar
-- Fonction : fn::getShares
-- Description : Récupère la liste des personnes avec qui un calendrier est partagé.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :
 
	public function getShares($calendarId) {
		$calendar = $this.getCalendarById($calendarId);
		$this.checkAccessToCalendar($calendar, ICalendar::ACCESS_READ);

		$shares = $this.shareManager->getShares(
			$this.principalBackend->getPrincipalByPath($calendar['principaluri'])['uid'],
			IShare::TYPE_CALENDAR,
			$this.stripCalendarId($calendar['uri']),
			1, // only direct shares
			-1,
			-1
		);

		$response = [];
		foreach ($shares as $share) {
			$principal = 'principals/' . $share->getSharedWith();
			if ($share->getSharedWithType() === IShare::TYPE_GROUP) {
				$principal = 'principals/groups/' . $share->getSharedWith();
			}
			$response[] = new \Sabre\DAV\Xml\Element\Sharee([
				'href' => $this.caldavBackend->getPrincipalByPath($principal)['uri'],
				'principal' => $principal,
				'access' => $this.getShareAccess($share->getPermissions()),
				'inviteStatus' => \Sabre\CalDAV\SharingPlugin::STATUS_ACCEPTED,
			]);
		}

		return $response;
	}
*/
