-- ============================================================================
-- Fichier : resource/calendar/gestion_invitation/getSchedulingObjects.surql
-- Module : calendar
-- Fonction : fn::getSchedulingObjects
-- Description : Récupère la liste de toutes les invitations en attente pour un utilisateur.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function getSchedulingObjects($principalUri) {
		$stmt = $this->db->prepare(
			'SELECT `uri`, `calendardata`, `lastmodified`, `etag`, `size` FROM `*PREFIX*schedulingobjects`' .
			' WHERE `principaluri` = ?'
		);
		$stmt->execute([$principalUri]);

		$result = [];
		while ($row = $stmt->fetch()) {
			$result[] = [
				'uri' => $row['uri'],
				'calendardata' => $row['calendardata'],
				'lastmodified' => (int)$row['lastmodified'],
				'etag' => $row['etag'],
				'size' => (int)$row['size'],
			];
		}

		return $result;
	}
*/
