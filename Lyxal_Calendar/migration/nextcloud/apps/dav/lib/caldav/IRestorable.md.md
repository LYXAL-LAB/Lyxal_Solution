# Analyse du Fichier `IRestorable.php` de Nextcloud

Ce document décompose le contenu du fichier `IRestorable.php`. Il s'agit d'une interface PHP, un élément de définition architecturale.

---

## 1. Rôle et Responsabilités

`IRestorable.php` est une **interface**. Elle ne contient aucune implémentation ou logique métier. Son unique rôle est de définir un "contrat" ou une "capacité".

Toute classe qui implémente cette interface déclare publiquement : "Je suis un objet qui peut être restauré depuis la corbeille".

---

## 2. Définition de l'Interface

L'interface définit une seule et unique méthode :

- **`restore(): void`**:
  - **Contrat**: Une classe qui implémente `IRestorable` **doit** fournir une méthode publique nommée `restore`, qui ne prend aucun argument et ne retourne rien.
  - **Objectif**: Cette méthode est destinée à contenir la logique nécessaire pour sortir l'objet de la corbeille et le restaurer à son état précédent.

Nous avons déjà vu une implémentation de cette interface dans la classe `Calendar.php`, qui utilise cette méthode pour appeler `caldavBackend->restoreCalendar(...)`.

---

## Conclusion

`IRestorable.php` est un simple mais puissant outil d'architecture logicielle. Il permet au système de corbeille (le `Trashbin`) de savoir, de manière générique et découplée, si un objet DAV qu'il contient peut être restauré, sans avoir besoin de connaître le type concret de cet objet (que ce soit un `Calendar`, un `CalendarObject`, ou autre). C'est un principe clé de la programmation orientée objet pour obtenir un code flexible et extensible.
