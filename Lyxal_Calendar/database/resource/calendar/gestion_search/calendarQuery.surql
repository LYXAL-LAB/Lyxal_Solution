-- ============================================================================
-- Fichier : resource/calendar/gestion_search/calendarQuery.surql
-- Module : calendar
-- Fonction : fn::calendarQuery
-- Description : Exécute une recherche filtrée sur un calendrier (par exemple, "tous les VEVENT entre le 1er et le 31 janvier"). C'est cette fonction qui gère les filtres de date.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function calendarQuery($calendarId, array $filters) {
		$calendar = $this->getCalendarById($calendarId);
		$this->checkAccessToCalendar($calendar, ICalendar::ACCESS_READ);
		$componentType = null;
		if (isset($filters['comp-filters'][0]['comp-filters'][0]['name'])) {
			// A VCALENDAR can contain multiple components.
			// We only support VEVENT, VTODO and VJOURNAL.
			// It is possible to query for an invalid component.
			$componentType = $filters['comp-filters'][0]['comp-filters'][0]['name'];
			if (!in_array($componentType, ['VEVENT', 'VTODO', 'VJOURNAL'])) {
				return [];
			}
		}
		// A calendar can contain multiple components.
		// We need to make sure we only fetch the requested once.
		// The component is saved in the `*PREFIX*calendarobjects` table
		$values = [$calendarId];
		$query = 'SELECT `uri` FROM `*PREFIX*calendarobjects` WHERE `calendarid` = ?';
		if ($componentType) {
			$query .= ' AND `componenttype` = ?';
			$values[] = $componentType;
		}
		if (isset($filters['comp-filters'][0]['comp-filters'][0]['time-range'])) {
			$timeRange = $filters['comp-filters'][0]['comp-filters'][0]['time-range'];
			if (isset($timeRange['start'])) {
				$query .= ' AND `lastoccurence` > ?';
				$values[] = $timeRange['start']->getTimestamp();
			}
			if (isset($timeRange['end'])) {
				$query .= ' AND `firstoccurence` < ?';
				$values[] = $timeRange['end']->getTimestamp();
			}
		}

		$stmt = $this->db->prepare($query);
		$stmt->execute($values);

		$result = [];
		while ($row = $stmt->fetch(\PDO::FETCH_ASSOC)) {
			$result[] = $row['uri'];
		}

		return $result;
	}
*/
