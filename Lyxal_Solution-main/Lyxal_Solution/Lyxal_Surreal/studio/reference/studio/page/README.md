# 📦 Ordre d'Importation des Seeds pour `studio_page:test_page`

Ce document décrit l'ordre correct pour importer les seeds de la page `test_page` et ses données i18n associées dans SurrealDB.

---

## 🚀 Ordre Recommandé

1.  **Schéma `studio_page`**
    - Fichier : `database/studio/studio_page.surql`
    - **Pourquoi** : La table `studio_page` doit exister avant de pouvoir créer des `i18n_key` ou des `studio_page` qui la référencent.

2.  **Clés i18n pour `test_page`**
    - Fichier : `reference/studio/page/test_page_i18n_keys.surql`
    - **Pourquoi** : Les `i18n_key` doivent être créées avant d'être référencées par la page `test_page` ou ses traductions.

3.  **Traductions i18n pour `test_page`**
    - Fichier : `reference/studio/page/test_page_i18n_translations.surql`
    - **Pourquoi** : Les traductions (`RELATE i18n_key->translation->language`) dépendent de l'existence des `i18n_key`.

4.  **Schéma `studio_component` (si pas déjà importé)**
    - Fichier : `database/studio/studio_component.surql`
    - **Pourquoi** : La page utilise `test_button` qui doit exister.

5.  **Seed du composant `test_button` (si pas déjà importé)**
    - Fichier : `reference/studio/component/test_button.surql`
    - **Pourquoi** : La page référence le composant `test_button`.

6.  **Seed de la page `test_page`**
    - Fichier : `reference/studio/page/test_page.surql`
    - **Pourquoi** : La page `test_page` référence les `i18n_key` et utilise le composant `test_button`.

---

## 💡 Commande d'Importation (Exemple)

Assurez-vous d'être dans le bon namespace et la bonne base de données SurrealDB.

```bash
# 1. Importer le schéma studio_page
surreal import --conn http://localhost:8000 --ns lyxal --db lyxal --file database/studio/studio_page.surql

# 2. Importer les clés i18n
surreal import --conn http://localhost:8000 --ns lyxal --db lyxal --file reference/studio/page/test_page_i18n_keys.surql

# 3. Importer les traductions i18n
surreal import --conn http://localhost:8000 --ns lyxal --db lyxal --file reference/studio/page/test_page_i18n_translations.surql

# 4. Importer le schéma studio_component (si nécessaire)
surreal import --conn http://localhost:8000 --ns lyxal --db lyxal --file database/studio/studio_component.surql

# 5. Importer le composant test_button (si nécessaire)
surreal import --conn http://localhost:8000 --ns lyxal --db lyxal --file reference/studio/component/test_button.surql

# 6. Importer la page de test
surreal import --conn http://localhost:8000 --ns lyxal --db lyxal --file reference/studio/page/test_page.surql
```

---

## 🎯 **Pages Disponibles**

### **test_page** (Page de base)
Démontre l'utilisation d'un composant simple (`test_button`) dans une page.

### **circular_menu_demo** (Page avancée)
Démontre le composant `circular_menu` avec 6 configurations différentes.

---

## 🚀 **Commandes d'importation pour circular_menu_demo**

```bash
# 1. Schéma studio_page (si pas déjà importé)
surreal import --conn http://localhost:8000 --ns lyxal --db lyxal --file database/studio/studio_page.surql

# 2. Clés i18n de la page
surreal import --conn http://localhost:8000 --ns lyxal --db lyxal --file reference/studio/page/circular_menu_demo_i18n_keys.surql

# 3. Traductions i18n de la page
surreal import --conn http://localhost:8000 --ns lyxal --db lyxal --file reference/studio/page/circular_menu_demo_i18n_translations.surql

# 4. Schéma studio_component (si pas déjà importé)
surreal import --conn http://localhost:8000 --ns lyxal --db lyxal --file database/studio/studio_component.surql

# 5. Clés i18n du composant
surreal import --conn http://localhost:8000 --ns lyxal --db lyxal --file reference/studio/component/circular_menu_i18n_keys.surql

# 6. Traductions i18n du composant
surreal import --conn http://localhost:8000 --ns lyxal --db lyxal --file reference/studio/component/circular_menu_i18n_translations.surql

# 7. Composant circular_menu
surreal import --conn http://localhost:8000 --ns lyxal --db lyxal --file reference/studio/component/circular_menu.surql

# 8. Page de démonstration
surreal import --conn http://localhost:8000 --ns lyxal --db lyxal --file reference/studio/page/circular_menu_demo.surql
```

## 🧪 **Test de validation circular_menu_demo**

```surql
-- Vérifier que la page existe
SELECT * FROM studio_page:circular_menu_demo;

-- Vérifier les traductions de la page
SELECT
    ->title_i18n->translation->language.text AS title,
    ->description_i18n->translation->language.text AS description
FROM studio_page:circular_menu_demo
WHERE language.code = 'fr';

-- Vérifier que la page utilise bien circular_menu
SELECT content_structure FROM studio_page:circular_menu_demo;
```

---

**Suivez cet ordre pour garantir une importation sans erreur.**

