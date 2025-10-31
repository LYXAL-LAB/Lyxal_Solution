# Inventaire des composants LyxalKitUI

Ce document liste tous les composants identifiés dans le dossier `lyxalsuite/lyxalkitui/src/components/` et leur classification par priorité pour l'intégration avec le système de thème.

## Composants de priorité haute

Ces composants sont fondamentaux, fréquemment utilisés ou critiques pour l'expérience utilisateur:

1. **Alert** - Affichage de messages d'information, d'avertissement ou d'erreur
2. **Badge** - Indicateurs visuels pour étiqueter ou marquer des éléments
3. **Button** (non trouvé dans la liste actuelle, à vérifier)
4. **Card** - Conteneur de contenu avec différentes variantes
5. **ThemeToggle** - Composant spécifique pour changer de thème (déjà partiellement intégré)
6. **Toggle** - Élément d'interface pour activer/désactiver des options

## Composants de priorité moyenne

Composants de formulaire, navigation et structure de page:

### Formulaires
1. **Checkbox** - Cases à cocher
2. **Combobox** - Champ de saisie avec liste déroulante
3. **Form** - Conteneur et gestionnaire de formulaires
4. **InputOTP** - Champ de saisie pour codes à usage unique
5. **Label** - Étiquettes de champs de formulaire
6. **RadioGroup** - Groupe de boutons radio
7. **Select** - Menu déroulant de sélection
8. **Slider** - Sélecteur de valeur sur une plage

### Navigation
1. **Breadcrumb** - Fil d'Ariane pour la navigation
2. **DropdownMenu** - Menu déroulant
3. **MenuBar** - Barre de menu horizontale
4. **NavigationMenu** - Menu de navigation principal
5. **Pagination** - Navigation entre les pages
6. **Sidebar** - Barre latérale de navigation
7. **Tabs** - Onglets de navigation

### Feedback et alertes
1. **Dialog** - Boîte de dialogue modale
2. **Popover** - Info-bulle avancée
3. **Toast** - Notification temporaire
4. **Tooltip** - Info-bulle simple

## Composants de priorité basse

Composants complexes, spécialisés ou moins fréquemment utilisés:

### Composants complexes
1. **Calendar** - Sélecteur de date sous forme de calendrier
2. **Carousel** - Carrousel d'images ou de contenu
3. **DataTable** - Tableau de données avancé
4. **DatePicker** - Sélecteur de date
5. **Drawer** - Panneau latéral escamotable

### Composants de structure
1. **Accordion** - Panneau pliable/dépliable
2. **AspectRatio** - Conteneur avec ratio d'aspect fixe
3. **Collapsible** - Élément pliable
4. **HoverCard** - Carte apparaissant au survol
5. **Modal** - Fenêtre modale
6. **Progress** - Barre de progression
7. **Resizable** - Élément redimensionnable
8. **ScrollArea** - Zone de défilement personnalisée
9. **Separator** - Séparateur visuel
10. **Sheet** - Feuille de contenu
11. **Skeleton** - Placeholder de chargement
12. **Table** - Tableau simple

### Composants divers
1. **AlertDialog** - Boîte de dialogue d'alerte
2. **Avatar** - Représentation visuelle d'un utilisateur
3. **Command** - Interface de commande
4. **ContextMenu** - Menu contextuel
5. **Loader** - Indicateur de chargement
6. **Sonner** - Gestionnaire de notifications avancé
7. **Switch** - Interrupteur
8. **ToggleGroup** - Groupe de boutons toggle

## Récapitulatif

- **Priorité haute**: 6 composants
- **Priorité moyenne**: 19 composants
- **Priorité basse**: 26 composants
- **Total**: 51 composants

## Notes sur l'inventaire

- Le composant Button semble manquer dans la liste des fichiers, à vérifier s'il est intégré dans un autre composant
- Le composant ThemeToggle est déjà partiellement intégré avec le système de thème
- Certains composants ont des dépendances entre eux qui devront être prises en compte lors de la migration 