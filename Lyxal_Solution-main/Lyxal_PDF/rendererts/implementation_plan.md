# Plan d'Implémentation : Support des Object Streams (PDF 1.5)

## Objectif
Implémenter la lecture des **Object Streams (Type 2)** dans `xref.ts`. Cela permettra au moteur de lire les fichiers PDF compressés modernes.

## Contexte
Actuellement, `xref.ts` lève une erreur lorsqu'il rencontre une entrée XRef de type 2 (Compressé). Ces entrées ne pointent pas vers un offset dans le fichier, mais vers un index dans un autre flux (le "Object Stream").

## Changements Proposés

### 1. Modification de `src/core/xref.ts`

#### A. Interface `XRefEntry`
Mettre à jour l'interface pour stocker les informations spécifiques aux entrées compressées.
```typescript
interface XRefEntry {
    offset: number; // Offset absolu OU Numéro d'objet du Stream (pour Type 2)
    gen: number;    // Génération OU Index dans le Stream (pour Type 2)
    free: boolean;
    uncompressed: boolean; // true = Type 1, false = Type 2
}
```

#### B. Méthode `fetch`
Implémenter la logique de récupération pour les entrées compressées (`!entry.uncompressed`).

**Algorithme :**
1.  Identifier le `objStmNum` (stocké dans `entry.offset`).
2.  Récupérer cet objet (qui est un `Stream`) via `this.fetch(new Ref(objStmNum, 0))`.
3.  Parser le header du stream :
    *   Le paramètre `N` (nombre d'objets) et `First` (offset du premier objet) sont dans le dictionnaire du stream.
    *   Le contenu commence par `N` paires d'entiers : `[objNum1, offset1, objNum2, offset2, ...]`.
4.  Trouver l'offset correspondant à notre index cible (`entry.gen`).
5.  Se positionner dans le stream à `First + offset`.
6.  Utiliser le `Parser` pour lire l'objet à cette position.

#### C. Cache des Object Streams
Pour éviter de re-parser le header du stream d'objets à chaque accès, nous pouvons mettre en cache les offsets parsés du stream.

## Vérification
*   Créer un test d'intégration ou utiliser un PDF de test connu pour utiliser des Object Streams.
*   Vérifier que l'erreur "Compressed object streams (Type 2) not implemented yet" disparaît.
