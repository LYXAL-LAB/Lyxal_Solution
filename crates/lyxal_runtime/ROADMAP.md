# Feuille de route — `lyxal_runtime`

Évolutions prévues du moteur d'exécution. L'état actuel (manifeste, installation rejouable,
migrations sous bail, cycle de vie, workers supervisés, santé, réconciliation) et ses limites
sont décrits dans le [`README.md`](README.md) (§7). Aucune étape ne démarre sans ordre du CTO et
`implementation_plan.md` validé (`.agents/AGENTS.md` §3).

| Étape | Thème | Dépendances |
| :--- | :--- | :--- |
| 1 | Reprise guidée d'une migration interrompue | — |
| 2 | Retrait d'un module et de ses données | — |
| 3 | Coordination du cycle de vie entre nœuds | — |

---

## 1. Reprise guidée d'une migration interrompue

Une migration interrompue au milieu d'un script non transactionnel peut laisser un état partiel ;
la politique par défaut exige aujourd'hui une reprise manuelle, sans outil.

Critères d'acceptation :

- [ ] l'état d'une migration interrompue (module, version, script, nœud, date) est lisible par une
      fonction publique ;
- [ ] une opération explicite d'administration marque la migration comme reprise ou abandonnée,
      sous bail, avec trace ;
- [ ] tests : interruption simulée, reprise, refus sans bail.

## 2. Retrait d'un module et de ses données

La cible `Absent` arrête un module sans supprimer ses données. La désinstallation complète n'existe
pas.

Critères d'acceptation :

- [ ] retrait explicite, distinct de l'arrêt, refusé si un module installé en dépend ;
- [ ] suppression des ressources déclarées par le manifeste (tables, fonctions, événements,
      définitions d'erreurs) et de la release ;
- [ ] tests : retrait, refus pour dépendance, rejeu sans erreur.

## 3. Coordination du cycle de vie entre nœuds

La santé, le démarrage et l'arrêt sont locaux au nœud ; seules l'installation et les migrations
sont coordonnées par baux.

Critères d'acceptation :

- [ ] état de santé et de démarrage de chaque nœud publié en base et agrégé par module ;
- [ ] arrêt ou redémarrage d'un module demandé pour tous les nœuds ;
- [ ] tests à deux nœuds (perte d'un nœud, reprise).
