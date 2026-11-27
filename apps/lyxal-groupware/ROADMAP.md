# Feuille de route — `lyxal-groupware`

Évolutions à venir de l'hôte. L'état actuel est décrit dans le [`README.md`](README.md). Aucune
étape ne démarre sans ordre du CTO et plan validé (`.agents/AGENTS.md` §3). Le programme est
décrit par `implementation_plan.md` à la racine du dépôt.

| Étape | Thème | Plan ou lot |
| :--- | :--- | :--- |
| 2 | IMAP | lot 8 |
| 3 | POP3 | lot 9 |
| 4 | ManageSieve (dernier protocole : retrait de `UnavailableHandler`) | lot 10 |
| 5 | JMAP et découverte `/.well-known/…` sur le port HTTP | lot 12 |
| 6 | Certificats de `lyxal_secrets`, ACME, échéances, OCSP ; signal de rechargement immédiat si le besoin apparaît | lot 13 |
| 7 | DAV (agendas, contacts) ; séparation du port public et du port interne de santé | lot 15 |
| 8 | Durcissement, charge, essais réels (dont ceux de la réception SMTP : `crates/lyxal_mail/ROADMAP.md`) | lots 21, 22 |

## Points relevés au lot 3

* **Offre du code source (AGPL, article 13)** : le moyen de proposer le source aux utilisateurs
  d'un service réseau modifié relève du CTO (décision F2) ; rien n'est codé.
* **Avant d'héberger des handlers d'événements** : un seul handler par type d'événement et par
  processus (`lyxal_event`). Tâches : depuis le lot 4, l'hôte exécute la tâche `handler`
  `mail.maintenance` (réservée par ses seuls nœuds) et ses exécuteurs servent aussi les tâches
  `function` et `event` de la file `default`, comme ceux de `lyxal-server` ; des files réservées
  à un hôte restent à décider si une charge l'exige (`crates/lyxal_runtime/ROADMAP.md`).
* **ALPN de SMTP et de la soumission** : aucun nom enregistré à l'IANA à notre connaissance
  (registre non relu au lot 3) ; aucun ALPN n'est annoncé sur ces écoutes. À revoir si un nom
  est enregistré.
* **Proxys de confiance du port HTTP** (`X-Forwarded-For`, `lyxal_host::net::client_ip`) : sans
  objet tant que les routes du port HTTP n'utilisent pas l'adresse du client ; à ajouter avec
  les routes du DAV et de JMAP (lot 15).
* **Limites partagées entre nœuds** : compteurs par réseau en mémoire et par nœud ; depuis le
  lot 5, seuls les bannissements sont partagés (liste de blocage de l'installation, décision
  S18) ; un modèle partagé des compteurs reste à décider au lot 21 selon les mesures.

## Points relevés au lot 5

* **Banc SMTP contre le vrai binaire** : le générateur Python prévu par le plan du lot 5 (§10.5)
  n'est pas écrit ; la charge est mesurée dans le processus (`crates/lyxal_mail/tests/it/
  smtp_load.rs`). À écrire avec le lot 21 (charge), avec un serveur DNS d'essai.
* **Mesures DNS** : `hickory-resolver` n'expose pas les succès de son cache ; `/metrics` compte
  les requêtes et les pannes seulement.
* **Sonde DNS** : interroge `smtp.hostname` (A) ; une absence est une réponse : seule une panne
  dégrade la santé.
* **Essai de supervision** : une écoute dont la boucle échoue est redémarrée par le runtime sur
  la même socket (sockets gardées hors du worker) ; aucun cas d'échec ne peut être provoqué de
  l'extérieur au lot 3, l'essai viendra avec le premier cas réel.
