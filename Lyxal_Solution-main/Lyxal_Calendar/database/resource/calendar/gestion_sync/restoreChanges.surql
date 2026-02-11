-- ============================================================================
-- Fichier : resource/calendar/gestion_sync/restoreChanges.surql
-- Module : calendar
-- Fonction : fn::restoreChanges
-- Description : Régénère l'historique des changements pour un calendrier (utile après une restauration).
-- =.==========================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :
 
	public function restoreChanges(int $calendarId) {
		$this->cleanStorages([$calendarId], false);
		$stmt = $this->db->prepare('
			SELECT `uri`
			FROM `*PREFIX*calendarobjects`
			WHERE `calendarid` = ?
		');
		$stmt->execute([$calendarId]);
		while ($row = $stmt->fetch()) {
			$this->addChange($calendarId, $row['uri'], CalendarObject::ACTION_ADD);
		}
	}
*/
