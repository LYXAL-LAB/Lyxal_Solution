# Seeds : studio_component

## 📋 Ordre d'Importation

Pour créer le composant de test `test_button`, importez les fichiers dans cet ordre :

### 1. Schéma de base (déjà créé)
```
database/studio/studio_component.surql
```

### 2. Clés i18n (à créer en premier)
```
reference/studio/component/test_button_i18n_keys.surql
```

### 3. Traductions i18n (après les clés)
```
reference/studio/component/test_button_i18n_translations.surql
```

### 4. Seed du composant (après i18n)
```
reference/studio/component/test_button.surql
```

## ✅ Commande d'importation

```bash
# 1. Schéma (si pas déjà importé)
surreal import --conn http://localhost:8000 --ns lyxal --db studio database/studio/studio_component.surql

# 2. i18n Keys
surreal import --conn http://localhost:8000 --ns lyxal --db studio reference/studio/component/test_button_i18n_keys.surql

# 3. i18n Translations
surreal import --conn http://localhost:8000 --ns lyxal --db studio reference/studio/component/test_button_i18n_translations.surql

# 4. Seed Component
surreal import --conn http://localhost:8000 --ns lyxal --db studio reference/studio/component/test_button.surql
```

## 🧪 Test de validation

Après importation, testez avec :

```surql
-- Vérifier que le composant existe
SELECT * FROM studio_component:test_button;

-- Vérifier les traductions
SELECT 
    ->name_i18n->translation->language.text AS name
FROM studio_component:test_button
WHERE language.code = 'fr';
```

---

**Fichiers créés :**
- ✅ `test_button_i18n_keys.surql` - 2 clés i18n
- ✅ `test_button_i18n_translations.surql` - 10 traductions (5 langues × 2 clés)
- ✅ `test_button.surql` - Composant avec i18n intégré

