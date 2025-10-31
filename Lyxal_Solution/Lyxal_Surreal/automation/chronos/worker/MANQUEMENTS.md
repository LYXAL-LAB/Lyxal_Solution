# Feuille de Route pour les Workers

Ce document a pour but de répartir les tâches et améliorations à apporter entre les différents composants du système (workers et fonctions DB) pour atteindre une parité fonctionnelle avec l'application C++ d'origine.

## Améliorations Transverses (Applicables aux deux workers)

- **Gestion des secrets :** Mettre en place une solution de gestion de secrets dédiée (ex: HashiCorp Vault, AWS Secrets Manager) pour ne pas exposer de mots de passe via les variables d'environnement.
- **Centralisation des logs :** Acheminer les logs JSON émis par les workers vers une plateforme de gestion centralisée (ex: ELK Stack, Splunk, Graylog).
- **Scalabilité multi-instances :** Adapter le design des workers pour permettre d'en lancer plusieurs instances en parallèle pour la haute disponibilité.
- **Tests unitaires et d'intégration :** Mettre en place une stratégie de tests pour les deux workers afin de valider leur comportement et de sécuriser les futures modifications.

## Tâches pour `surrealworker.ts` (Orchestrateur de Jobs)

### Sécurité
- **Verrouillage des jobs (Locking) :** Terminé. Le système utilise une table de relation (`scheduler_job_tag`) pour lier les jobs à des `system_tag` (`pending`, `processing`). La fonction `get_jobs_for_minute` modifie ces relations de manière transactionnelle pour garantir qu'un job n'est traité que par un seul worker.

### Robustesse et Fiabilité
- **Mécanisme de "Retry" / "Dead-Letter Queue" :** Terminé. La table `scheduler_job` a été enrichie de champs pour gérer les tentatives (`retry_count`, `max_retries`). La fonction `process_job_result` contient la logique pour passer un job en état `retrying` (avec un délai) ou `failed` après épuisement des tentatives.
- **Lissage de Charge (`deferMs`) :** Terminé. La table `scheduler_job` a été enrichie de champs (`defer`, `defer_max_ms`). Le `surrealworker` applique un délai aléatoire avant l'exécution des jobs concernés pour étaler la charge.

### Observabilité
- **Centralisation des Logs :** Pour construire un monitoring interne, stocker les logs structurés émis par les workers dans une table SurrealDB dédiée, au lieu de les afficher uniquement en console.
- **Persistance des Métriques :** Pour un suivi de performance à long terme, stocker périodiquement des "snapshots" des métriques des workers dans une table SurrealDB dédiée.
- **Rapport de Métriques Agrégées :** Calculer et rapporter des statistiques agrégées pour chaque "batch" de minute (jitter min/max/avg, temps total min/max/avg), comme le faisait le `WorkerThread` C++.

### Fonctionnalités
- **Concept de "Délégation" :** Implémenter la logique métier si le terme "déléguer" implique de confier des tâches à d'autres types de workers ou services.

## Tâches pour `notification.worker.ts` (Gestionnaire d'E-mails)

- **Mécanisme d'envoi d'e-mails :** Implémenter l'infrastructure complète pour l'envoi d'e-mails, qui doit :
    - Surveiller la table `scheduler_notification` via `LIVE QUERY`.
    - Gérer une file d'attente interne pour traiter les notifications de manière robuste.
    - Se connecter à un serveur SMTP pour envoyer les e-mails.
- **Gestion des templates et traductions :**
    - Récupérer les traductions (`phrases`) depuis la base de données.
    - Utiliser un moteur de template pour construire le corps et le sujet des e-mails.
    - Formater les données (dates, statuts) en fonction de la langue de l'utilisateur.
- **Gestion avancée des e-mails (VERP) :** Implémenter la logique de génération de l'adresse d'expéditeur VERP pour le suivi des bounces, incluant la signature HMAC.

## Tâches pour les Fonctions SurrealDB (.surql)

- **Logique de notification conditionnelle (dans `fn::...::process_job_result`) :** Modifier la logique actuelle pour n'envoyer des notifications que dans des cas précis, comme le faisait le C++ :
    - Au **premier échec** d'un job.
    - Au **premier succès** suivant une série d'échecs.
- **Données de Monitoring/TimeSeries (dans `fn::...::process_job_result`) :** Porter la logique de calcul d'histogrammes des temps de réponse pour les jobs de type `MONITORING`.
- **Substitution de Variables (dans `fn::...::job::create`) :** Intégrer la logique de remplacement des variables dynamiques (`%cjo:unixtime%`, `%cjo:uuid4%`) lors de la création/mise à jour d'un job.

