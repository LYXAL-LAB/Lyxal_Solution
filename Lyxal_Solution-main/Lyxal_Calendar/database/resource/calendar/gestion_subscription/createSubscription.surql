-- ============================================================================
-- Fichier : resource/calendar/gestion_subscription/createSubscription.surql
-- Module : calendar
-- Fonction : fn::createSubscription
-- Description : Crée un nouvel abonnement à un calendrier externe.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function createSubscription($principalUri, $uri, array $properties) {
		// The uri is a unique id, so we are not going to create it.
		// It needs to be specified by the user.
		// But it must not exist, yet.
		$stmt = $this->db->prepare('SELECT `id` FROM `*PREFIX*calendarsubscriptions` WHERE `principaluri` = ? AND `uri` = ?');
		$stmt->execute([$principalUri, $uri]);
		if ($stmt->fetch()) {
			throw new \Sabre\DAV\Exception\Forbidden('A subscription with this uri already exists.');
		}

		$fieldNames = [
			'`principaluri`',
			'`uri`',
		];
		$values = [
			$principalUri,
			$uri,
		];

		$propertyMap = [
			'{DAV:}displayname'                                  => 'displayname',
			'{http://apple.com/ns/ical/}calendar-color'           => 'calendarcolor',
			'{http://calendarserver.org/ns/}source'               => 'source',
			'{http://sabredav.org/ns}refreshrate'                  => 'refreshrate',
			'{urn:ietf:params:xml:ns:caldav}calendar-description' => 'description',
		];

		foreach ($properties as $propertyName => $propertyValue) {
			if (isset($propertyMap[$propertyName])) {
				$fieldName = $propertyMap[$propertyName];
				$fieldNames[] = '`' . $fieldName . '`';
				$values[] = $propertyValue;
			}
		}

		$fieldNames[] = '`lastmodified`';
		$values[] = time();

		$stmt = 'INSERT INTO `*PREFIX*calendarsubscriptions` (' . implode(', ', $fieldNames) . ') VALUES (' .
			rtrim(str_repeat('?,', count($values)), ',') . ')';

		$q = $this->db->prepare($stmt);
		$q->execute($values);

		return $this->db->lastInsertId('*PREFIX*calendarsubscriptions_id_seq');
	}
*/
