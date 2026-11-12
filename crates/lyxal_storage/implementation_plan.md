# Plan d'implémentation — `lyxal_storage`, lot 5 : contrôle du contenu

Cinquième lot du programme `lyxal_storage` (`implementation_plan.md` à la racine, décisions S4
et H2). Pendant l'écriture d'un fichier, son type réel est reconnu à partir de ses premiers
octets et, si un antivirus est configuré, son contenu est analysé, dans le même passage que
l'écriture. Les images et les PDF peuvent alors être affichés dans le navigateur. Aucune ligne
de code avant la validation du CTO (`.agents/AGENTS.md` §3).

## 1. Décisions demandées au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **K1** | Que fait-on d'un fichier dont le type annoncé ne correspond pas à son contenu (un fichier annoncé « image » qui n'en est pas une) ? | **On l'accepte, mais c'est le type réel qui est enregistré**, et les règles du bucket s'appliquent à ce type réel. Refuser gênerait des envois légitimes : les navigateurs annoncent souvent un type approximatif. Un type annoncé que l'on sait reconnaître mais que le contenu dément est enregistré comme « fichier binaire » |
| **K2** | Interdit-on certains types partout ? | **Oui : les programmes exécutables** (Windows, Linux, macOS) sont refusés par défaut, sur toute l'installation. La liste est un réglage, modifiable par l'installation ou par organisation |
| **K3** | Que devient un fichier dans lequel l'antivirus trouve un virus ? | **Il est refusé à l'envoi et rien n'est conservé.** Le garder en quarantaine obligerait à stocker et gérer des fichiers dangereux. La mise en quarantaine d'un fichier déjà accepté reste possible (fonction existante) |
| **K4** | Que fait-on si l'antivirus est configuré mais ne répond pas, ou si le fichier dépasse ce qu'il sait analyser ? | **L'envoi est refusé**, avec un message clair, à réessayer. Accepter sans contrôle donnerait une fausse sécurité. Sans antivirus configuré, rien ne change : seul le type réel est contrôlé (décision S4) |
| **K5** | Quels fichiers peuvent s'afficher dans le navigateur ? | **Les images PNG, JPEG, GIF, WebP et les PDF**, à la demande (`?inline`). Tout le reste, dont SVG et HTML qui peuvent contenir du code, reste proposé à l'enregistrement |

## 2. Type réel

* Bibliothèque `infer` (MIT) : reconnaissance par les premiers octets, sans lire le fichier
  entier ; une centaine de formats (images, PDF, archives, documents bureautiques, vidéos,
  exécutables).
* Type enregistré à la fin de l'écriture (`content_type`) :
  1. le type reconnu, s'il y en a un ;
  2. sinon le type annoncé, s'il n'est pas un type que `infer` sait reconnaître (texte, CSV,
     JSON…) ;
  3. sinon `application/octet-stream` (K1).
* `fn::storage_object_commit` applique déjà les types acceptés du bucket au type réel ; il
  applique en plus les types interdits (K2).

## 3. SurrealQL

| Élément | Changement |
| :--- | :--- |
| `storage_settings.blocked_types` | nouveau réglage : types MIME refusés ; par portée, comme les autres. Valeur par défaut du module : exécutables (`application/vnd.microsoft.portable-executable`, `application/x-executable`, `application/x-mach-binary`, `application/x-msdownload`) |
| `fn::storage_settings_set`, `fn::storage_settings_effective` | paramètre et valeur effective `blocked_types` |
| `fn::storage_object_limits` | type interdit : `STORAGE_OBJECT_TYPE_REFUSED` (à l'ouverture sur le type annoncé, à la fin sur le type réel) |

Fonctions Core réutilisées : `fn::validation_object_execute` (règles `array_of_strings`, `each`,
`mime_type`). Aucune fonction Core manquante. Erreurs ajoutées (thème `supports`) :
`STORAGE_OBJECT_INFECTED` (422), `STORAGE_SCANNER_UNAVAILABLE` (503, à réessayer).

## 4. Rust (`lyxal_storage`)

| Fichier | Contenu |
| :--- | :--- |
| `content.rs` | `detect(début, type annoncé) -> String` : règle du §2 |
| `scanner.rs` | `ContentScanner` (trait) : analyse un flux d'octets, rend « sain », « infecté (nom de la menace) » ou une erreur ; `ClamAvScanner` par la bibliothèque `clamav-client` (MIT), protocole `INSTREAM` du service `clamd`, en TCP ou par socket Unix ; `ScannerConfig` |
| `service.rs` | `StorageService::with_scanner` ; pendant `put`, chaque morceau est écrit sur le support, compté, haché et transmis à l'antivirus par un canal borné : un seul passage, mémoire bornée. Infecté ou antivirus en échec : écriture abandonnée, octets retirés, fiche supprimée (K3, K4) |
| `error.rs` | `StorageError::Infected` (nom de la menace journalisé, pas le contenu), `ScannerUnavailable` (`is_retryable`) |
| `module.rs` | la sonde interroge l'antivirus configuré (`PING`) ; injoignable : « dégradé » |

ClamAV (GPL) reste un service séparé, joint par le réseau : aucun code GPL n'est lié. Sa limite
de taille par flux (`StreamMaxLength`, 25 Mo par défaut) doit être au moins la taille maximale
des fichiers ; un fichier qui la dépasse est refusé (K4).

## 5. Hôte

* Configuration : `LYXAL__STORAGE__ANTIVIRUS__ADDRESS` (`hôte:port`) ou `__SOCKET` (chemin),
  `__TIMEOUT_SECONDS` (30 par défaut). Absente : pas d'antivirus.
* `GET …/objects/{clé}?inline` : `Content-Disposition: inline` si le type enregistré est dans
  la liste de K5 ; sinon `attachment` comme aujourd'hui. Dans tous les cas `nosniff` et
  `Content-Security-Policy: default-src 'none'; sandbox`.

## 6. Documents

`crates/lyxal_storage/README.md` et `ROADMAP.md` ; `apps/lyxal-server/README.md` ; ligne 5 du
plan racine passée à « Réalisé ». Ce plan est supprimé dans la demande de fusion de
l'implémentation.

## 7. Tests

* **Banc SurrealQL** : `blocked_types` (défaut, surcharge, effacement) ; type interdit refusé à
  l'ouverture et à la fin d'écriture ; droits.
* **Rust** (mémoire, disque, S3 de test) : PNG annoncé `image/png` ; PNG annoncé `text/plain`
  enregistré `image/png` ; texte annoncé `image/png` enregistré `application/octet-stream` ;
  texte annoncé `text/csv` conservé ; exécutable refusé sans octet laissé ; bucket limité aux
  PDF qui refuse une image annoncée PDF.
* **Antivirus** : faux service `clamd` lancé dans les tests (protocole `INSTREAM`) : fichier
  sain accepté ; signature de test EICAR refusée (`STORAGE_OBJECT_INFECTED`) sans octet ni
  fichier disponible ; service injoignable, délai dépassé, limite de taille : 
  `STORAGE_SCANNER_UNAVAILABLE` ; sonde dégradée.
* **Hôte** : `?inline` sur une image, un PDF, un SVG et un fichier texte ; en-têtes de
  sécurité ; envoi infecté refusé de bout en bout.
* Contrôle complet : `scripts/ci/ci_local.sh`. Un essai sur un vrai service ClamAV n'est pas
  dans les contrôles automatiques ; il est décrit dans le README pour être lancé à la main.

## 8. Checklist (§13)

* Architecture : reconnaissance du type et protocole de l'antivirus en Rust ; la règle des
  types interdits et acceptés reste en SurrealQL.
* Core : aucune extension. Crypto : aucune primitive ajoutée.
* Erreurs : aucune erreur silencieuse ; antivirus en échec = refus (K4).
* Licences : `infer` (MIT), `clamav-client` (MIT) ; ClamAV (GPL) non lié.
* Zéro dette : réglage ajouté dans le schéma cible, sans migration.
