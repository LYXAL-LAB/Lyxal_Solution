-- ============================================================================
-- Fichier : resource/calendar/gestion_invitation/getSchedulingObject.surql
-- Module : calendar
-- Fonction : fn::getSchedulingObject
-- Description : Récupère les détails d'une seule invitation.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function getSchedulingObject($principalUri, $objectUri) {
		$stmt = $this->db->prepare(
			'SELECT `uri`, `calendardata`, `lastmodified`, `etag`, `size` FROM `*PREFIX*schedulingobjects`' .
			' WHERE `principaluri` = ? AND `uri` = ?'
		);
		$stmt->execute([$principalUri, $objectUri]);
		$row = $stmt->fetch();

		if (!$row) {
			return null;
		}

		return [
			'uri' => $row['uri'],
			'calendardata' => $row['calendardata'],
			'lastmodified' => (int)$row['lastmodified'],
			'etag' => $row['etag'],
			'size' => (int)$row['size'],
		];
	}
*/
