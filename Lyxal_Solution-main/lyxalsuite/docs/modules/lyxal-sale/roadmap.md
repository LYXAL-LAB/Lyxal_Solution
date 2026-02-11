📘 Feuille de route lyxalsale – Intégration complète
🧩 MODULE CONCERNÉ : lyxalsale
Basé sur le module sale d’Axelor (devis, commandes, paniers, packs…)

1. 🎯 Objectif du module
Permettre la gestion complète du cycle de vente :

devis / commande client (sale_order)

lignes de commande complexes (sale_order_line)

paiements anticipés

taxation, marges, remises

packs de produits, paniers

catalogues clients

configurateurs dynamiques

2. 🧱 Architecture technique
A. SurrealDB
✅ Toutes les tables SCHEMAFUL créées

✅ Triggers pour séquences, totaux, fullName

✅ Relations graphe : has_sale_line, line_has_tax, etc.

✅ Enums normalisées en tables : status_type, line_type, discount_type, etc.

B. Backend gateway/lyxalsale/
 Générer les routes REST :

GET /sale-order

POST /sale-order

PATCH /sale-order/:id

DELETE /sale-order/:id

routes sale-order-line, advance-payment, configurator, etc.

 Générer tous les schémas Zod : validation stricte côté backend

 Règles d'accès : auth + contrôle multi-workspace

 Middleware audit + archiving

 Ajout hooks système : afterCreate, afterUpdate, afterDelete

C. SDK sdk/lyxalsale/
 Générer les services :

createSaleOrder()

updateSaleOrder()

getSaleOrderById()

listSaleOrders({ filters })

 Intégrer enums dynamiquement depuis SurrealDB

 Support relationnel automatique (expand: ["lines", "taxes", "configurator"])

 Typage TypeScript complet

D. UI (dans uicomponents ou app LYXAL)
 Composants réutilisables :

SaleOrderForm, SaleOrderLineForm

ConfiguratorBuilder, TaxSelector, PackComposer

 Composants connectés au SDK avec props 100 % typées

 Support mode draft, view, edit

 Support visualisation PDF/print

3. 🚀 Améliorations prévues à implémenter (en plus du modèle Axelor)
Amélioration	Description	Responsable
🔁 archived auto	Ajouter archived: true si status = COMPLETED depuis +90 jours	Trigger SDB
📦 fullName auto	Générer dynamiquement à chaque update saleOrderSeq	Trigger SDB
📊 marginRate, markup	Champs calculés sur sale_order (SUM des lignes)	Trigger + SDK
📑 Statuts enrichis	Ajouter : archived, expired, invoiced (dans status_type)	SDB + UI
🧠 IA : auto-devis	Option future pour pré-remplir un devis via assistant IA	À planifier
📥 Audit métier	Log métier : création, modification, annulation	Middleware
🔍 Filtres par workflow	Ajouter vues par statut + filtrage rapide (Drafts, Confirmed, etc.)	UI
🧾 Impression dynamique	Système de template d’impression (ex: template B2B, public, etc.)	SDK + UI

4. ✅ Priorisation des tâches
Étape	Tâches	Statut
1. Backend Gateway	routes, schémas, triggers, permissions	🔜 À faire
2. SDK Frontend	services, types, enums dynamiques	🔜 À faire
3. UI	composants dynamiques connectés SDK	⏳ En attente
4. IA + Automation	assistant devis + flux automatisés	⏳ Optionnel
5. Impression	PDF / print preview, templates multiples	⏳ Optionnel

5. 🧠 Notes Cursor
Ne pas utiliser de champ codé en dur pour les statusSelect, utiliser la table sale_order_status_type

Tous les liens entre sale_order ↔ sale_order_line doivent être en graphe (RELATE)

Pour chaque sale_order, les totaux (exTaxTotal, inTaxTotal) doivent être recalculés automatiquement à chaque ajout/suppression de ligne via has_sale_line

Utiliser createdAt, updatedAt, archived comme standard LYXAL

Aucun champ UI ne doit contenir de logique métier, tout doit être géré dans le backend + triggers SDB