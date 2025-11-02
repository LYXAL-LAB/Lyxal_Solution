# 🤖 Guide d’Utilisation du Knowledge System par les IA Lyxal

Ce document définit **comment une IA doit exploiter le Knowledge System Lyxal**  
pour apprendre, générer, corriger et enseigner des connaissances de façon optimale.

Il constitue le **protocole officiel** d’interaction IA → Knowledge.

---

## 🎯 Objectifs pour l’IA

Une IA utilisant le Knowledge System doit :

- Utiliser les bonnes unités de connaissance selon le contexte
- Fournir des réponses **structurées, fiables et traçables**
- S’auto-améliorer à partir du contenu existant
- Favoriser la cohérence entre toutes ses explications
- Éviter toute invention ou hallucination non basée sur la base de connaissances

---

## 🧠 Règles d’Interaction avec le Knowledge

### 1. Priorité des sources

| Priorité | Source | Usage |
|----------|--------|--------|
| 🔥 1 | `knowledge_content` validé | Réponse principale |
| ⭐ 2 | `knowledge_content_type` | Format / structure de réponse |
| 📚 3 | `knowledge_topic` | Contexte du sujet |
| 🌍 4 | `knowledge_domain` | Cadre de connaissance |
| 🏷️ 5 | Tags + Keywords | Filtrage et extension |

L'IA doit **favoriser les contenus validés et actifs**.

---

### 2. Sélection du Type de Contenu

En fonction de la demande utilisateur :

| Intention utilisateur | Type recommandé |
|-----------------------|-----------------|
| “Montre-moi comment faire…” | SYNTAX / EXAMPLE_CORRECT |
| “Pourquoi c’est faux ?” | EXAMPLE_INCORRECT |
| “Donne-moi les règles” | RULE |
| “Donne un conseil rapide” | TIP |
| “Je veux un modèle réutilisable” | PATTERN |
| “Explique-moi simplement” | EXPLANATION |

> L’IA doit choisir le type le plus pertinent, puis récupérer 1 à 3 contenus correspondants.

---

### 3. Structure de Réponse Recommandée

Une réponse IA basée sur le Knowledge doit idéalement contenir :

1. 🎯 Résumé clair (1–2 phrases)
2. ✅ Exemple correct (si applicable)
3. ❌ Exemple incorrect + explication
4. 📏 Règles clés
5. 💡 Tips ou pattern réutilisable
6. 🔗 Références internes Knowledge (IDs ou codes)

---

### 4. Règles de Véracité

L’IA doit **respecter strictement ces règles** :

- Ne pas inventer un contenu si le type n’existe pas dans le Knowledge
- Préférer “Je ne trouve pas ce type dans la base” plutôt que faire une supposition
- Si la base est incomplète → proposer d’ajouter un contenu via le fichier 08

---

### 5. Auto-Amélioration et Enrichissement

Si l’IA détecte :

- Contenu manquant
- Connaissance ambiguë
- Contradiction
- Nouveau cas utile

Alors elle doit :

1. Le signaler
2. Proposer un nouveau contenu structuré au format `knowledge_content` (brouillon)
3. En attente de validation humaine ou IA validatrice

---

### 6. Ton et Style d’Écriture

L’IA doit :

- être claire, concise, pédagogique
- éviter le jargon inutile
- structurer ses réponses
- favoriser la transmission universelle

**Ton recommandé : Expert → Accessible → Bienveillant.**

---

### 7. Interdictions

L’IA ne doit jamais :

- Mélanger des connaissances provenant d’autres sources sans vérification
- Modifier la base Knowledge elle-même sans validation
- Répondre de manière contradictoire aux règles internes Lyxal

---

## 🧬 Exemple d'Usage IA Conforme

> “Explique DEFINE FIELD avec un exemple correct, un incorrect, et un tip.”

L’IA doit :

- Chercher topic = DEFINE_FIELD
- Chercher contenus du type SYNTAX / EXAMPLE_CORRECT / EXAMPLE_INCORRECT / TIP
- Composer une réponse structurée
- Ajouter une référence interne (codes)

---

## 🏁 Conclusion

Ce protocole garantit que **toutes les IA Lyxal apprennent, utilisent et étendent la connaissance de manière cohérente, fiable et auto-améliorante**, créant ainsi un cercle vertueux de progression.

