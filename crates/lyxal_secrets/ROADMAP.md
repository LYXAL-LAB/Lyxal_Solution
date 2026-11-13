# Feuille de route — `lyxal_secrets`

Évolutions à venir. L'état actuel est décrit par le [`README.md`](README.md) ; les sources par
[`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md). Aucune évolution ne démarre sans
`implementation_plan.md` validé par le CTO (`.agents/AGENTS.md` §3).

## Programme V1 en cours (`implementation_plan.md` à la racine)

| Lot | Contenu |
| :- | :--- |
| 3 | Cycle de vie : alertes avant échéance, rotation en quatre étapes, essai de rotation, rotation d'urgence, rotation planifiée des clés d'organisation |
| 4 | Accès avancés : accès temporaires par chemin, demandes d'accès et approbation des changements, accès d'urgence tracé |
| 5 | Hôte : routes HTTP, révélation avec double facteur, partage à usage unique |
| 6 | Clôture : audit, procédures (sauvegarde, clé maîtresse, urgence, compromission) |

## Après la V1

* Secrets dynamiques (identifiants créés à la demande, avec bail).
* Synchronisation vers AWS, Azure, Google ou GitHub.
* Références entre secrets.
* Retour d'un dossier entier à un état passé.
* Clé maîtresse dans un KMS ou un HSM (extension de `lyxal_crypto`, validation CTO).
* Organisation « scellable ».
* Envoi du journal vers un outil de sécurité (SIEM) et durée de conservation réglable.
