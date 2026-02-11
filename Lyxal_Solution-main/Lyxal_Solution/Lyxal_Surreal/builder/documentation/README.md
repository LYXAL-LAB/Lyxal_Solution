# 📖 Documentation du Module Builder

Bienvenue dans la documentation du module Builder de Lyxal.

---

## 📋 Documents disponibles

### 🏗️ [Architecture du Module Builder](./ARCHITECTURE_MODULE_BUILDER.md)

**Document principal** - À lire en priorité

Ce document explique :
- Ce qu'est le module Builder
- Le rôle de `builder_catalogue`
- Pourquoi ces noms sont parfaits
- L'architecture complète du module
- Les relations avec les autres modules
- L'utilisation par l'IA
- Toutes les clarifications importantes

**⚠️ Document de référence** : En cas de doute sur le rôle du Builder ou du catalogue, consultez ce document.

---

## 🎯 Accès rapide

### Pour comprendre le Builder

```
❓ "C'est quoi le Builder ?"
   → Lisez la section "Qu'est-ce que le Builder ?"

❓ "Pourquoi s'appelle-t-il Builder ?"
   → Lisez la section "Pourquoi Builder ?"

❓ "Le catalogue contient quoi exactement ?"
   → Lisez la section "Le builder_catalogue"

❓ "Pourquoi le catalogue est dans builder/ ?"
   → Lisez la section "Pourquoi ne pas le mettre à la racine ?"
```

### Pour l'architecture

```
🏗️ Structure complète du module
   → Section "Architecture du module"

🔗 Relations avec autres modules
   → Section "Relations avec les autres modules"

📊 Comparaison des noms
   → Section "Comparaison noms envisagés"
```

### Pour l'IA

```
🤖 Découverte automatique
   → Section "Utilisation par l'IA"

🔄 Workflow IA + Builder
   → Section "Workflow IA + Builder"

📚 Différence avec INFO FOR DB
   → Section "builder_catalogue vs INFO FOR DB"
```

---

## 🎓 En bref

### Le Builder c'est quoi ?

**Un système de méta-programmation** qui construit dynamiquement l'application Lyxal.

### Le builder_catalogue c'est quoi ?

**Le registre central** de **TOUTES** les ressources Lyxal (tables, fonctions, modules, tout).

### Pourquoi dans builder/ ?

Parce que le **Builder orchestre** toutes les ressources, comme un chef d'orchestre possède la partition complète.

---

## 📚 Documentation externe

### Dans Lyxal_Solution/Definition/
- [VISION_LYXAL_ASSISTANT_UNIVERSEL.md](../../Definition/VISION_LYXAL_ASSISTANT_UNIVERSEL.md)
- [STRUCTURATION_DONNEES_FONDATION_IA.md](../../Definition/STRUCTURATION_DONNEES_FONDATION_IA.md)

### Dans Lyxal_Surreal/mcp_server/documentation/
- [MCP_AUTO_DISCOVERY.md](../../mcp_server/documentation/MCP_AUTO_DISCOVERY.md)
- [BUILDER_CATALOGUE_INTEGRATION.md](../../mcp_server/documentation/BUILDER_CATALOGUE_INTEGRATION.md)
- [CONFIGURATION_GUIDE.md](../../mcp_server/documentation/CONFIGURATION_GUIDE.md)

---

## 🚀 Évolution

Ce dossier `documentation/` contiendra à l'avenir :
- Guides d'utilisation du Builder
- Tutoriels de création de templates
- Documentation des fonctions builder
- Exemples de déploiement
- Bonnes pratiques

---

**Module** : Builder  
**Version** : 1.0.0  
**Date** : 27 octobre 2025

