-- Exemple de ProjectAnnouncement
CREATE project_announcement:1 SET 
  title = "Kickoff Meeting",
  project = project:1,
  date = time::now(),
  content = "Réunion de lancement du projet avec tous les intervenants.";

-- Exemple de AppBusinessSupport
CREATE app_business_support:1 SET 
  app = app:1,
  providerCompany = company:1;

-- Exemple de TaskTemplate
CREATE task_template:1 SET 
  internalDescription = "Étude préliminaire et cadrage du besoin client.";