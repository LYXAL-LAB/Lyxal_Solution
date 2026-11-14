# Feuille de route — `lyxal_secrets`

Évolutions à venir. L'état actuel est décrit par le [`README.md`](README.md) ; les sources par
[`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md). Aucune évolution ne démarre sans
`implementation_plan.md` validé par le CTO (`.agents/AGENTS.md` §3).

## Programme V1 en cours (`implementation_plan.md` à la racine)

| Lot | Contenu |
| :- | :--- |
| 6 | Clôture : audit, procédures (sauvegarde, clé maîtresse, urgence, compromission) |

## Après la V1

* Rotateurs des services extérieurs, livrés par les modules qui leur parlent (`lyxal_notification`,
  `lyxal_connect`).
* Portées d'accès par motifs (`*/smtp/**`) : comparaison de motifs à ajouter à `lyxal_core`
  (extension à valider).
* Secrets dynamiques (identifiants créés à la demande, avec bail).
* Synchronisation vers AWS, Azure, Google ou GitHub.
* Références entre secrets.
* Retour d'un dossier entier à un état passé.
* Clé maîtresse dans un KMS ou un HSM (extension de `lyxal_crypto`, validation CTO).
* Organisation « scellable ».
* Envoi du journal vers un outil de sécurité (SIEM) et durée de conservation réglable.
