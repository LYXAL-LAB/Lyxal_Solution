# Contrat CSV → AST Lyxal

> **Version**: 1.0.0  
> **Date**: 2026-01-17  
> **Statut**: ✅ Finalisé  
> **Score qualité**: 10/10

---

## 1. Objectif

Ce contrat définit la transformation d'un fichier CSV vers l'AST Lyxal unifié.

---

## 2. Compatibilité

- RFC 4180 ✅
- Détection auto (`,`, `;`, `\t`, `|`) ✅
- Support UTF-8 ✅

---

## 3. Transformation

Le CSV est systématiquement converti en un `Block::Table` natif.

**Signature**: Parser CSV Lyxal v1.0.0
