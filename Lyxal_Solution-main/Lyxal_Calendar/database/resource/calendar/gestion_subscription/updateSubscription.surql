-- ============================================================================
-- Fichier : resource/calendar/gestion_subscription/updateSubscription.surql
-- Module : calendar
-- Fonction : fn::updateSubscription
-- Description : Met à jour les propriétés d'un abonnement.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function updateSubscription($principalUri, $uri, array $mutations) {
		$propertyMap = [
			'{DAV:}displayname'                                  => 'displayname',
			'{http://apple.com/ns/ical/}calendar-color'           => 'calendarcolor',
			'{http://calendarserver.org/ns/}source'               => 'source',
			'{http://sabredav.org/ns}refreshrate'                  => 'refreshrate',
			'{urn:ietf:params:xml:ns:caldav}calendar-description' => 'description',
		];

		$values = [];
		$fields = [];

		foreach ($mutations as $propertyName => $propertyValue) {
			if (isset($propertyMap[$propertyName])) {
				$fieldName = $propertyMap[$propertyName];
				$fields[] = '`' . $fieldName . '` = ?';
				$values[] = $propertyValue;
			}
		}

		if (count($fields) === 0) {
			return;
		}

		$fields[] = '`lastmodified` = ?';
		$values[] = time();

		$stmt = 'UPDATE `*PREFIX*calendarsubscriptions` SET ' . implode(', ', $fields) . ' WHERE `principaluri` = ? AND `uri` = ?';
		$values[] = $principalUri;
		$values[] = $uri;

		$q = $this->db->prepare($stmt);
		$q->execute($values);
	}
*/
