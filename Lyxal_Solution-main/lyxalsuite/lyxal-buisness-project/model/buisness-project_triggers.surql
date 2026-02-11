-- Auto-calcul du nom complet du projet
DEFINE EVENT project_full_name ON TABLE project WHEN $after.code != NONE OR $after.name != NONE THEN {
  LET $fullName = ($after.code != NONE ? $after.code + " - " : "") + $after.name;
  UPDATE $this SET fullName = $fullName;
};

-- Mise à jour automatique du champ progress en fonction des tâches
DEFINE EVENT update_project_progress ON TABLE project_task WHEN $after.progress != $before.progress OR $after.project != $before.project THEN {
  LET $tasks = SELECT progress FROM project_task WHERE project = $after.project;
  LET $total = math::mean(array::flatten($tasks.map(t => t.progress)));
  UPDATE project[$after.project.id] SET progress = $total;
};

-- Mise à jour de la marge réelle d’un projet (coût vs turnover)
DEFINE EVENT update_real_margin ON TABLE project WHEN $after.turnover != NONE AND $after.cost != NONE THEN {
  LET $margin = ($after.turnover - $after.cost);
  UPDATE $this SET realMargin = $margin;
};

-- Ajout automatique d’un historique lors de la création d’un élément manuel
DEFINE EVENT log_manual_element ON TABLE manual_element WHEN $after.id != NONE THEN {
  RETURN "Manual element added for project " + $after.project.id;
};
