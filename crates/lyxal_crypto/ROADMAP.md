# Feuille de route — `lyxal_crypto`

Évolutions prévues de la fondation cryptographique. L'état actuel (API figée, enveloppe `enc:v2`,
contrats, fixtures et fuzzing en CI) est décrit dans le [`README.md`](README.md),
[`API_CONTRACT.md`](API_CONTRACT.md) et [`SECURITY.md`](SECURITY.md). Aucune étape ne démarre
sans ordre du CTO et `implementation_plan.md` validé (`.agents/AGENTS.md` §3).

| Étape | Thème | Dépendances |
| :--- | :--- | :--- |
| 1 | Audit de sécurité externe | avant la première mise en production |

Les primitives hors périmètre (Ed25519 / X25519, ChaCha20-Poly1305, post-quantique, KMS / HSM)
ne sont pas des étapes de cette feuille de route : elles n'y entrent que sur un besoin produit
validé par le CTO (`.agents/rules/lyxal_standards_and_checklist.md` §11.3).

---

## 1. Audit de sécurité externe

La bibliothèque n'est pas certifiée. Elle protège les secrets applicatifs de tous les modules ;
elle est revue par un tiers avant la première mise en production.

Critères d'acceptation :

- [ ] audit externe de l'API, de l'enveloppe `enc:v2`, de la gestion des clés et des
      dépendances ;
- [ ] chaque constat corrigé ou accepté par le CTO, avec justification ;
- [ ] `SECURITY.md` mis à jour (périmètre audité, limites connues).
