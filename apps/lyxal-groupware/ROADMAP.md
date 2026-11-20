# Feuille de route — `lyxal-groupware`

Évolutions à venir de l'hôte. L'état actuel est décrit dans le [`README.md`](README.md). Aucune
étape ne démarre sans ordre du CTO et plan validé (`.agents/AGENTS.md` §3). Le programme est
décrit par `implementation_plan.md` à la racine du dépôt.

| Étape | Thème | Plan ou lot |
| :--- | :--- | :--- |
| 1 | Réception SMTP, résolveur DNS, liste de blocage et bannissement | lot 5 |
| 2 | Envoi et dépôt authentifié (587, 465) | lot 6 |
| 3 | IMAP | lot 8 |
| 4 | POP3 | lot 9 |
| 5 | ManageSieve (dernier protocole : retrait de `UnavailableHandler`) | lot 10 |
| 6 | JMAP et découverte `/.well-known/…` sur le port HTTP | lot 12 |
| 7 | Certificats de `lyxal_secrets`, ACME, échéances, OCSP ; signal de rechargement immédiat si le besoin apparaît | lot 13 |
| 8 | DAV (agendas, contacts) ; séparation du port public et du port interne de santé | lot 15 |
| 9 | Durcissement, charge, essais réels | lots 21, 22 |

## Points relevés au lot 3

* **Offre du code source (AGPL, article 13)** : le moyen de proposer le source aux utilisateurs
  d'un service réseau modifié relève du CTO (décision F2) ; rien n'est codé.
* **Avant d'héberger des handlers d'événements ou des tâches** : un seul handler par type
  d'événement et par processus (`lyxal_event`) ; files du planificateur réservées à un hôte
  (`crates/lyxal_runtime/ROADMAP.md`).
* **ALPN de SMTP et de la soumission** : aucun nom enregistré à l'IANA à notre connaissance
  (registre non relu au lot 3) ; aucun ALPN n'est annoncé sur ces écoutes. À revoir si un nom
  est enregistré.
* **Proxys de confiance du port HTTP** (`X-Forwarded-For`, `lyxal_host::net::client_ip`) : sans
  objet tant que les routes du port HTTP n'utilisent pas l'adresse du client ; à ajouter avec
  les routes du DAV et de JMAP (lot 15).
* **Limites partagées entre nœuds** : compteurs par réseau en mémoire et par nœud ; modèle
  partagé à décider au lot 5 ou au lot 21 selon les mesures.
* **Essai de supervision** : une écoute dont la boucle échoue est redémarrée par le runtime sur
  la même socket (sockets gardées hors du worker) ; aucun cas d'échec ne peut être provoqué de
  l'extérieur au lot 3, l'essai viendra avec le premier cas réel.
