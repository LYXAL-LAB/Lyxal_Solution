-- ============================================================================
-- Fichier : resource/calendar/gestion_invitation/deleteSchedulingObject.surql
-- Module : calendar
-- Fonction : fn::deleteSchedulingObject
-- Description : Supprime une invitation.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function deleteSchedulingObject($principalUri, $objectUri) {
		$stmt = $this->db->prepare(
			'DELETE FROM `*PREFIX*schedulingobjects`' .
			' WHERE `principaluri` = ? AND `uri` = ?'
		);
		$stmt->execute([$principalUri, $objectUri]);
	}
*/
