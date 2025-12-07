-- ============================================================================
-- Fichier : resource/calendar/gestion_search/calendarSearch.surql
-- Module : calendar
-- Fonction : fn::calendarSearch
-- Description : Exécute une recherche par mot-clé sur les propriétés des événements.
-- ============================================================================

/*
 modèle PHP de Nextcloud (CalDavBackend.php) :

	public function calendarSearch(array $calendarIds, array $searchProperties, $test = 'anyof') {
		$s = new Search($this->principalBackend, $this->caldavBackend);

		$uris = [];
		foreach ($this->runCalendarSearch($calendarIds, $searchProperties, $test) as $uri) {
			$uris[] = $uri;
		}

		return $uris;
	}

	protected function runCalendarSearch(array $calendarIds, array $searchProperties, $test = 'anyof') {
		$query = $this->db->getQueryBuilder();
		$query->select('o.uri')
			->from('calendarobjects', 'o')
			->leftJoin('o', 'calendarobject_props', 'p', 'o.id = p.calendarobjectid')
			->where($query->expr()->in('o.calendarid', $query->param('calendarids', IQueryBuilder::PARAM_INT_ARRAY)))
			->groupBy('o.uri')
			->setParameter('calendarids', $calendarIds, IQueryBuilder::PARAM_INT_ARRAY);

		$where = [];
		$i = 0;
		foreach ($searchProperties as $name => $value) {
			$i++;
			$value = str_replace(['%', '_'], ['\\%', '\\_'], $value);
			$w = $query->expr()->andX();
			$w->add($query->expr()->eq('p.name', $query->param('name' . $i, IQueryBuilder::PARAM_STR)));
			$w->add($query->expr()->like('p.value', $query->param('value' . $i, IQueryBuilder::PARAM_STR)));
			$where[] = $w;

			$query->setParameter('name' . $i, $name, IQueryBuilder::PARAM_STR);
			$query->setParameter('value' . $i, '%' . $value . '%', IQueryBuilder::PARAM_STR);
		}

		if ($test === 'anyof') {
			$query->andWhere($query->expr()->orX()->addMultiple($where));
		} else {
			$query->andWhere($query->expr()->andX()->addMultiple($where));
		}

		$result = $query->execute();
		$data = $result->fetchAll();
		$result->closeCursor();

		foreach ($data as $row) {
			yield $row['uri'];
		}
	}
*/
