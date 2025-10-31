# 🌍 GUIDE COMPLET - Traductions des Codes d'Activité

## 🎯 OBJECTIF

Traduire **4 602 codes d'activité** × 3 libellés dans **4 langues** (en, es, de, it)  
= **55 224 traductions professionnelles** ✅

---

## 📊 MÉTHODE RECOMMANDÉE : DeepL API

**Pourquoi DeepL ?**
- ✅ Meilleure qualité pour les termes professionnels
- ✅ API gratuite jusqu'à **500 000 caractères/mois**
- ✅ Spécialisé dans les traductions techniques
- ✅ Support natif : FR → EN, ES, DE, IT

---

## 🚀 ÉTAPE PAR ÉTAPE

### **1. Obtenir une clé API DeepL (GRATUIT)**

#### a) Créer un compte DeepL API Free
1. Allez sur : https://www.deepl.com/pro-api
2. Cliquez sur **"S'inscrire gratuitement"**
3. Choisissez **"DeepL API Free"**
   - ✅ **500 000 caractères/mois GRATUIT**
   - ✅ Suffisant pour traduire tous les codes
4. Remplissez le formulaire avec :
   - Email
   - Carte bancaire (PAS de débit si < 500k caractères)
   - Informations personnelles

#### b) Récupérer votre clé API
1. Une fois connecté, allez dans **"Account"**
2. Section **"Authentication Key for DeepL API"**
3. Copiez votre clé (format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx:fx`)

---

### **2. Installer la bibliothèque DeepL**

```bash
pip install deepl
```

---

### **3. Configurer le script**

Éditez `translate_activity_codes.py` :

```python
# Ligne 14 : Remplacez par votre clé API
DEEPL_API_KEY = "votre-cle-api-ici:fx"
```

---

### **4. Lancer la traduction**

```bash
python Lyxal_Solution/translate_activity_codes.py
```

**Durée estimée :** 30-60 minutes (avec pauses pour éviter rate limiting)

---

### **5. Résultat**

Fichier généré : `business_activity_code_i18n_translations_FULL.surql`

Contient :
- ✅ **69 030 traductions** (4 602 codes × 3 libellés × 5 langues)
- ✅ Traductions professionnelles DeepL
- ✅ Cache pour éviter les doublons
- ✅ Prêt pour import SurrealDB

---

## 💰 COÛT ESTIMÉ

### **Option 1 : API Gratuite (Recommandée)**
- **500 000 caractères/mois** inclus
- Estimation : **200 000-300 000 caractères** pour tout traduire
- ✅ **GRATUIT** ✅

### **Option 2 : API Pro (si dépassement)**
- €5 par **1 million de caractères**
- Coût total estimé : **€1-2** (largement sous la limite gratuite)

---

## 📊 VOLUMÉTRIE

```
Codes à traduire:
  - NAF Rev 2:  1 728 codes × 3 libellés = 5 184 textes
  - NAF Rev 1:  1 045 codes × 3 libellés = 3 135 textes
  - NAF 1993:   1 026 codes × 3 libellés = 3 078 textes
  - NAP:          803 codes × 3 libellés = 2 409 textes
  ────────────────────────────────────────────────────
  TOTAL:        4 602 codes × 3 libellés = 13 806 textes

Traductions par langue:
  - Anglais:    13 806 traductions
  - Espagnol:   13 806 traductions
  - Allemand:   13 806 traductions
  - Italien:    13 806 traductions
  ────────────────────────────────────────
  TOTAL:        55 224 traductions + 13 806 originaux (fr) = 69 030
```

---

## ⚡ OPTIMISATIONS DU SCRIPT

Le script inclut :

1. **Cache de traductions** 
   - Évite de traduire 2 fois le même texte
   - Économise temps et tokens

2. **Rate limiting**
   - Pause de 0.1s entre chaque appel
   - Respecte les limites DeepL

3. **Gestion d'erreurs**
   - Fallback sur français en cas d'échec
   - Compteur d'erreurs

4. **Progress tracking**
   - Affichage tous les 100 codes
   - Estimation du temps restant

---

## 🧪 TESTER SANS API (Mode Simulation)

Si vous voulez tester le script sans API :

```python
# Dans translate_activity_codes.py, ligne 14
DEEPL_API_KEY = "VOTRE_CLE_API_DEEPL"  # Laisser tel quel

# Lancer le script
python Lyxal_Solution/translate_activity_codes.py
```

Le script génère un fichier avec des traductions **simulées** :
- ✅ Quelques vraies traductions pour les termes courants
- ⚠️ Préfixes `[EN]`, `[ES]`, etc. pour les autres

---

## 📝 EXEMPLE DE RÉSULTAT

### Avant (français pour toutes les langues)
```sql
RELATE i18n_key:i18n_activity_code_nafrev2_01_11z_long->i18n_translation->i18n_language:en
    SET text = 'Culture de céréales (à l\'exception du riz), de légumineuses et de graines oléagineuses';
```

### Après (vraie traduction)
```sql
RELATE i18n_key:i18n_activity_code_nafrev2_01_11z_long->i18n_translation->i18n_language:en
    SET text = 'Growing of cereals (except rice), leguminous crops and oil seeds';
```

---

## ✅ ALTERNATIVE : Nomenclature NACE (Européenne)

Si vous ne voulez pas utiliser DeepL, vous pouvez :

1. **Utiliser la nomenclature NACE** (équivalent européen de la NAF)
   - Disponible sur : https://ec.europa.eu/eurostat/ramon/
   - Traductions officielles dans **24 langues UE**
   - Correspondance NAF ↔ NACE disponible

2. **Je peux créer un script** pour :
   - Télécharger les traductions NACE
   - Faire le mapping NAF → NACE
   - Générer les seeds avec traductions officielles

Dites-moi si vous préférez cette approche !

---

## 🎯 RÉCAPITULATIF

**Pour obtenir les vraies traductions :**

1. ✅ Créer compte DeepL API Free (5 min)
2. ✅ Copier la clé API
3. ✅ `pip install deepl`
4. ✅ Configurer `DEEPL_API_KEY` dans le script
5. ✅ Lancer `python translate_activity_codes.py`
6. ✅ Attendre 30-60 min
7. ✅ Remplacer l'ancien fichier par le nouveau

**Total : GRATUIT + 1 heure** ✅

---

## ❓ BESOIN D'AIDE ?

Si vous avez des questions ou préférez une autre approche, je peux :
- ✅ Créer un script avec Google Translate (aussi gratuit)
- ✅ Utiliser la nomenclature NACE officielle
- ✅ Traduire seulement les codes les plus utilisés
- ✅ Autre solution sur mesure

**Dites-moi ce que vous préférez !** 🚀

