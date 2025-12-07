-- ============================================================================
-- Fichier : resource/calendar/gestion_share/updateShares.surql
-- Module : calendar
-- Fonction : fn::updateShares
-- Description : Met à jour la liste des partages pour un calendrier (ajoute ou retire des personnes).
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function updateShares(
		$calendarId,
		\Sabre\DAV\Xml\Element\Sharee $sharees,
		$notifications,
		$calendarOwner,
		$isPersonalCalendar = true
	) {
		$calendar = $this->getCalendarById($calendarId);

		if ($isPersonalCalendar) {
			$this->checkAccessToCalendar($calendar, ICalendar::ACCESS_SHARE);
		} else {
			$this->checkAccessToCalendar($calendar, ICalendar::ACCESS_OWNER);
		}

		$existingShares = $this->shareManager->getShares(
			$calendarOwner,
			IShare::TYPE_CALENDAR,
			$this->stripCalendarId($calendar['uri']),
			1, // only direct shares
			-1,
			-1
		);
		$existingSharesByPrincipal = [];
		foreach ($existingShares as $share) {
			$principal = 'principals/' . $share->getSharedWith();
			if ($share->getSharedWithType() === IShare::TYPE_GROUP) {
				$principal = 'principals/groups/' . $share->getSharedWith();
			}
			$existingSharesByPrincipal[$principal] = $share;
		}

		foreach ($sharees as $sharee) {
			if (isset($existingSharesByPrincipal[$sharee->principal])) {
				// update existing share
				$share = $existingSharesByPrincipal[$sharee->principal];

				if ($sharee->access === \Sabre\DAV\Sharing\Plugin::ACCESS_NOACCESS) {
					$this->shareManager->deleteShare($share->getId());
				} elseif ((int)$share->getPermissions() !== $this->getCalDAVPermissions($sharee->access)) {
					$share->setPermissions($this->getCalDAVPermissions($sharee->access));
					$this->shareManager->updateShare($share);
				}

				unset($existingSharesByPrincipal[$sharee->principal]);
			} else {
				// create a new share
				if ($sharee->access !== \Sabre\DAV\Sharing\Plugin::ACCESS_NOACCESS) {
					list($shareType, $shareWith) = $this->getPrincipalTypeAndName($sharee->principal);
					$share = $this->shareManager->newShare();
					$share->setNodeId($calendar['id']);
					$share->setPermissions($this->getCalDAVPermissions($sharee->access));
					$share->setSharedBy($calendarOwner);
					$share->setSharedWith($shareWith);
					$share->setShareType(IShare::TYPE_CALENDAR);
					$share->setSharedWithType($shareType);
					if (isset($sharee->properties['{DAV:}displayname'])) {
						$share->setShareName($sharee->properties['{DAV:}displayname']);
					} else {
						// try to get displayname as a fallback
						$share->setShareName($this->getPrincipalDisplayName($sharee->principal));
					}
					$this->shareManager->createShare($share);
				}
			}
		}

		// all left-over existing shares are to be deleted
		foreach ($existingSharesByPrincipal as $share) {
			$this->shareManager->deleteShare($share->getId());
		}

		return true;
	}
*/
