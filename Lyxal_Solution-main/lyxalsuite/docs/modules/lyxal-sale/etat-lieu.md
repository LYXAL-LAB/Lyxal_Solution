✅ État des lieux – lyxalsale (27 mai 2025)
📦 1. Couverture fonctionnelle
Fonctionnalité principale	Statut	Détails
Gestion des commandes (sale_order)	✅ Complète	Tables, triggers, index, status
Lignes de commande (sale_order_line)	✅ Complète	Packs, produits, taxes
Paiements anticipés	✅ Complète	advance_payment intégré
Taxes sur lignes	✅ Complète	sale_order_line_tax + graphe
Configurateurs dynamiques	✅ Complète	configurator*, metaFields
Packs produits	✅ Complète	pack, pack_line, relations
Paniers clients	✅ Complète	cart, cart_line, enums
Catalogues clients	✅ Complète	customer_catalog, lien partner
Statuts de commande (enum)	✅ Complète	Table sale_order_status_type
Impression/numérotation automatique	✅ Complète	Triggers + séquence sale_order_seq

🧱 2. État technique SurrealDB
Élément	Statut	Notes
Tables SCHEMAFUL	✅ OK	15 tables métier créées
Relations graphe (RELATE)	✅ OK	5 relations ajoutées
Séquences (DEFINE SEQUENCE)	✅ OK	sale_order_seq avec padding
Triggers (DEFINE EVENT)	✅ OK	fullName, totaux, seq
Enums (*_type_select)	✅ OK	Créés comme tables dédiées
Champs système (createdAt, etc.)	✅ OK	Ajoutés partout
Contraintes (ASSERT, DEFAULT)	✅ OK	Présentes pour qty, price, etc.

🧠 3. Améliorations prévues (feuille de route intégrée)
Amélioration	Intégré ?	Commentaire
archived automatique	🔜	Trigger à faire dans Gateway
marginRate, markup	🔜	Calculs backend à implémenter
IA auto-devis	⏳ Option	À prévoir via assistant plus tard
Filtres/Workflow UI	⏳ Option	À faire dans app/interface
Impression dynamique (PDF)	⏳ Option	Système de template non encore créé
Statuts enrichis (expired…)	✅	Enum enrichie créée

🧰 4. Intégration LYXAL (par module)
Composant	Statut	Détails
gateway/lyxalsale/	🔜 À faire	Routes, schémas, contrôles d’accès
sdk/lyxalsale/	🔜 À faire	Services TypeScript, types, enums
uicomponents/	⏳ En attente	Composants dynamiques
interface/	⏳ En attente	Intégration complète UI
automations/	⏳ Optionnel	Agent IA + automatisation devis

📍 Résumé
🔧 Base SurrealDB prête à 100 %, propre et complète

📊 Structure évolutive compatible multi-entreprises, marque blanche, automatisation

✍️ Backend et SDK à générer

🎨 Interface UI non démarrée

📎 Aucune dépendance technique bloquante

