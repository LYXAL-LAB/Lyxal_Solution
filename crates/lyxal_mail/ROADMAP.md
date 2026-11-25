# Feuille de route — `lyxal_mail`

Évolutions à venir du crate (socle courrier réalisé au lot 4, contrat réseau au lot 3). Son
objet et son état actuel sont décrits par le [`README.md`](README.md), les
études et les mesures par [`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md), la provenance des
sources par [`SOURCES.md`](SOURCES.md). Le programme est décrit par `implementation_plan.md` à la
racine du dépôt ; chaque lot a son propre plan, validé par le CTO avant toute ligne de code
(`.agents/AGENTS.md` §3).

## Lots du programme, dans l'ordre

| Lot | Contenu pour ce crate | Sources principales | Prérequis |
| :- | :--- | :--- | :--- |
| 5 — Réception SMTP | Serveur SMTP entrant, refus dès `RCPT TO`, SPF / DKIM / DMARC, `Authentication-Results`, antivirus, remise en boîte, événement `mail.message.received` ; ordre de remise fixé : antivirus → anti-spam → filtres → index → chiffrement | Stalwart `smtp/inbound` ; Mox `smtpserver` | lots 2, 3, 4 |
| 6 — Envoi | File par destination, tentatives, envoi vers les MX, dépôt authentifié (587 / 465), signature DKIM, avis de non-remise, adresses de retour signées, contrat public de dépôt | Stalwart `smtp/queue`, `smtp/outbound` ; Mox `queue`, `smtpclient`, `dsn` ; KumoMTA | lots 1, 5 |
| 7 — Transport sûr et rapports | MTA-STS, DANE, TLS-RPT, rapports DMARC reçus et émis, ARC | Stalwart `smtp/reporting`, `outbound/{dane,mta_sts}` ; Mox | lot 6 |
| 8 — IMAP | IMAP4rev2 et rev1, extensions (IDLE, CONDSTORE, QRESYNC, MOVE, UIDPLUS, SPECIAL-USE, QUOTA, ACL…) | Stalwart `imap` ; Mox `imapserver` | lots 1, 4 |
| 9 — Recherche et POP3 | Texte des pièces jointes, index plein texte, recherche IMAP ; POP3 | Stalwart `text-extract`, `pop3`, `store/search` | lot 8 |
| 10 — Sieve | Filtres à la réception, ManageSieve, réponse d'absence | Stalwart `managesieve`, `email/sieve` | lots 5, 8 |
| 11 — Anti-spam | Règles, listes DNS, classement bayésien et apprentissage, réputation, quarantaine (sans la partie IA de Stalwart, propriétaire) | Stalwart `spam-filter`, `nlp` ; Mox `junk` | lot 5 |
| 12 — JMAP courrier | Cœur JMAP, courrier, dépôt, identités, fils, push, WebSocket, blobs, quotas, Sieve | Stalwart `jmap` | lots 6, 8 |
| 13 — Administration du courrier | Routes HTTP (domaines, clés DKIM et rotation, contrôle DNS, file, quarantaine), certificats automatiques, configuration automatique des logiciels | Stalwart `common/network/{acme,autoconfig}` ; Mox `autotls` | lot 6 |
| 21 — Durcissement et conformité | Fuzzing, essais de charge, suites de conformité (décision P10), corrections | Bancs de Mox transposés | lots 12, 20 |
| 22 — Essais réels et clôture | Essais ci-dessous, audit `lyxal-audit`, procédures d'exploitation, documents définitifs | — | lot 21, moyens P11 |

## Points relevés au lot 0, à traiter dans les plans des lots

Mesures et essais détaillés dans [`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md) (section
« Mesures SurrealDB ») et dans le compte rendu du lot 0.

* **Recherche (lot 9).** Sans index plein texte, une recherche de sous-chaîne parcourt le
  dossier. L'index plein texte de SurrealDB 3.3.4 répond vite sur un mot, mais combiner un mot
  fréquent, un dossier et un tri par date est lent : à mesurer de nouveau avec le moteur de
  recherche retenu au lot 9.
* **Liste des suffixes publics (décision S4).** Embarquée par la crate `psl` à version figée
  (`EmbeddedSuffixList`) : la liste vieillit avec la version ; sa mise à jour (changement de
  version, par plan, décision P14) est à inscrire dans les procédures d'exploitation. La crate
  déclare `MIT/Apache-2.0` sans mentionner la MPL-2.0 de la liste qu'elle embarque : à confirmer
  par le CTO (repli : fichier de la liste sous MPL-2.0, exception nommée dans `deny.toml`).
  `PublicSuffixList` (liste fournie par l'appelant) ne sert plus qu'aux essais : à garder ou à
  retirer avec le branchement de la session SMTP (5d).
* **Domaines d'auteur multiples (lot 5).** DMARC évalue au plus 10 domaines distincts de `From` ;
  au-delà, les domaines sont ignorés : refus ou non d'un tel message à décider avec la session
  SMTP (5d).
* **Liste de blocage et bannissement (lot 5).** Table et fonctions en place (5c) ; restent à la
  session SMTP (5d) : lecture par chaque nœud toutes les 30 s, bannissement après récidive. Un
  réseau est rangé tel qu'il est donné (`fn::validation_cidr` valide la syntaxe, sans ramener
  l'adresse à son réseau : `192.0.2.7/24` et `192.0.2.0/24` sont deux entrées) : forme canonique
  à produire par l'appelant, ou primitive de `lyxal_core` à demander au CTO. Les entrées échues
  ne sont pas purgées (elles portent le nombre de récidives) : durée de conservation à décider.
  Les compteurs de cadence restent par nœud (lot 3).

## Points relevés au lot 4, à décider avant les protocoles

Mesures : [`README.md`](README.md), section « Mesures ».

* **Vue par date pour JMAP (lot 12).** `mail_message_date` sert les pages par date du lot 4 ;
  `Email/query` (tri par date dans tout le compte, filtres) et `Email/changes` sur `email_id`
  (un déplacement change l'identifiant de la fiche, pas `email_id`) se décident au lot 12.
* **Effacement des messages `\Deleted` d'un grand dossier.** `fn::mail_message_expunge` sans liste
  lit les messages `\Deleted` par l'index `(dossier, deleted)` : coût non mesuré sur une grande
  boîte, à mesurer au lot 8.
* **Débit de remise (décisions C5, P7, S11, S12) : objectif non atteint, à décider avant 5d.**
  Mesures du lot 5c (`README.md`, « Mesures de la remise ») : 11 à 25 remises par seconde sur un
  serveur SurrealDB, pour 300 visées ; aucune remise refusée sur un nœud. Une remise coûte 93 à
  96 ms de calcul à la base. Pistes, toutes hors du plan du lot 5 et à décider par le CTO :
  coût du moteur de validation de `lyxal_core` (2 ms pour un champ, 10,7 ms pour un élément de
  remise ; `fn::event_publish` 7 ms, fonctions de `lyxal_storage` 3,4 ms chacune) ; plusieurs
  connexions à la base par hôte (un serveur exécute une à une les requêtes d'une connexion) ;
  compteurs de volume de `lyxal_storage` écrits par chaque fichier d'une organisation (les
  écritures d'une organisation passent une à une dans le nœud) ; lecture du trousseau des clés
  « fichiers » à chaque scellement (13 ms).
* **Plage de 1 000 UID sous la session d'un membre.** Environ 0,3 ms de plus par fiche que sous
  la session système, non expliqué par la règle de lecture (13 µs) : à analyser avant le lot 8
  (`FETCH` de grandes plages).
* **Contention entre deux nœuds (décisions M6, S11).** Le compteur reste par compte ; dans un
  nœud, l'ordre par compte supprime les conflits. Entre deux nœuds simulés dans un processus
  (base embarquée, un compte, 20 clients) : 1 remise refusée sur 1 000 après rejeu (0,1 %, sous
  le seuil de 1 % du repli), 199 conflits rejoués. À mesurer de nouveau avec deux vrais hôtes et
  la session SMTP (5d), y compris les conflits sur les compteurs de volume de `lyxal_storage`.
  Le dépôt par un titulaire (`MailIngest::deliver`, `APPEND` au lot 8) ne passe pas par l'ordre
  par compte : à décider au lot 8.
* **Domaines internationaux et parties locales UTF-8 (décisions M10, S16).** Adresses de Lyxal
  en ASCII ; domaines convertis en forme ASCII en Rust par la session SMTP (5d) ; aucune
  extension de `lyxal_core` au lot 5 ; saisie d'un domaine ou d'une adresse en Unicode par un
  administrateur : question rouverte au lot 13.
* **Alias vers l'extérieur, listes** : lot 6.
* **Clés « fichiers » (décisions M19, S13).** Cache écrit dans `lyxal_secrets`
  (`FileKeys::with_cache`), pour les ouvertures seulement ; à activer par l'hôte (5d). Un
  scellement relit toujours le trousseau (13 ms par remise) : le sceller depuis le cache
  demanderait qu'une clé « fichiers » retirée ne puisse pas être détruite avant un délai plus
  long que la garde du cache (règle de `lyxal_secrets` à décider par le CTO).
* **Contenus en attente en retard dans la sonde.** La sonde ne compte pas les contenus `pending`
  restés au-delà de leur délai (aucune fonction publique ne les compte ; la maintenance les
  retire) : fonction à ajouter si l'exploitation en a besoin.
* **Essais encore à écrire.** Dépôt sur un serveur SurrealDB 3.3.4 réel (`ws://`) ; panne
  simulée entre chaque étape du dépôt (le banc couvre le refus de l'inscription et l'abandon
  d'un contenu) ; suppression d'une identité puis purge du compte, suppression d'une
  organisation, par le service Rust (couvertes par le banc SurrealQL).
* **À relire.** Modèle `email` de Stalwart (fils, état JMAP, appartenance à plusieurs dossiers) ;
  `maxMailboxesPerEmail` (RFC 8621 §1.3.1) et numéros de RFC cités de mémoire par le plan du lot
  4 ; acceptation de l'UTF-8 par `string::is_email` (SurrealDB 3.3.4).

## Chiffrement des boîtes (décision C7)

| Niveau | Principe | Place dans le programme | Ce que les lots doivent tenir dès maintenant |
| :- | :--- | :--- | :--- |
| **A** — au repos, clés de la plateforme | Contenu des messages et des pièces jointes chiffré avec une clé par organisation, scellée par la clé maîtresse (modèle de `lyxal_secrets`). Protège du vol d'un disque, d'une sauvegarde ou d'un compartiment S3. | **Dans le programme** : primitive disponible dans `lyxal_crypto` (chiffrement de fichiers en flux, `STREAM_FORMAT_V1.md` : une clé par fichier scellée par la clé de l'organisation, segments de 64 Kio, lecture d'une plage) ; branchée au lot 4 (où chiffrer : décision C11 du lot 2) | Les octets passent par `lyxal_storage` ; seule la clé **scellée** de chaque fichier est rangée dans sa fiche ; la déduplication des fichiers chiffrés est impossible |
| **B** — à la remise, clé publique de l'utilisateur | Chaque message est chiffré à l'arrivée avec la clé publique OpenPGP de l'utilisateur : le serveur ne peut plus le relire ; les logiciels classiques déchiffrent. Activable par compte. | **Lot optionnel après le lot 12**, bibliothèque `rpgp` (MIT / Apache-2.0) derrière `lyxal_crypto` | Lots 4 et 5 : drapeau « chiffré » et empreinte de la clé sur chaque message ; ordre antivirus → anti-spam → filtres → index → chiffrement |
| **C** — bout en bout | Clés créées et gardées côté client ; le serveur ne stocke que du chiffré. Exige nos propres logiciels clients (ou une passerelle) et retire au serveur la recherche, les filtres et l'anti-spam sur le contenu des boîtes qui l'activent. | **Gardé dans le programme, sans lot fixé à ce jour** ; plan instruit après le niveau B | Aucun lot ne ferme cette possibilité : modèle des clés par utilisateur, drapeau « chiffré », contenu des messages jamais supposé lisible par le serveur dans les contrats |

Questions encore ouvertes pour le plan du niveau B (étude Proton, §8) : accès d'un
administrateur d'organisation à la boîte d'un membre ; « clé perdue, courrier perdu » ; OpenPGP
seul ou OpenPGP et S/MIME ; recherche pour les comptes chiffrés ; chiffrement sortant vers les
correspondants qui publient une clé.

## Après le programme (décision C8)

Consigné ici, sans lot dans le programme.

### Fonctions à reprendre des logiciels de Proton dans le futur webmail

Le webmail est hors programme (§9 du plan) ; il se construira sur les fonctions publiques du
module. Cette liste sert à vérifier que le serveur porte ce qu'il faut.

| Fonction | Ce que le serveur doit offrir | Lot qui le prépare |
| :--- | :--- | :-: |
| Vue par conversation | Fils de discussion | 4 |
| Dossiers et libellés (un message dans un dossier, plusieurs libellés) | Boîtes IMAP, mots-clés IMAP / JMAP | 4, 8, 12 |
| Envoi différé ; annulation de l'envoi (délai de quelques secondes) | Envoi différé (`FUTURERELEASE`, `EmailSubmission` JMAP avec date) ; file retenue | 6, 12 |
| Mise en attente d'un message | Mot-clé et date de réveil ; tâche `lyxal_scheduler` | 12 ou après |
| Groupes de contacts | Groupes vCard (dans `lyxal_contacts`) | 19 |
| Filtres simples traduits en Sieve, éditeur Sieve | Sieve et ManageSieve | 10 |
| Expiration d'un message ; message protégé par mot de passe pour l'extérieur | Suppression planifiée ; page de lecture hors courrier | après |
| Désabonnement en un clic, vue « lettres d'information » | En-têtes `List-Unsubscribe` exposés | 6, 12 |
| Blocage des images distantes et des traceurs, nettoyage du HTML | Côté webmail | webmail |

### Alias d'adresses à la SimpleLogin

Alias jetables, alias inverses (le correspondant ne voit jamais la vraie adresse), désactivation
d'un alias qui reçoit du spam. Modèle : SimpleLogin (`simple-login/app`, AGPL-3.0, étude Proton
§6.3) : modèle de données et règles de réécriture à la réception et à l'envoi. **À instruire
avec le lot 13** ; toute reprise est inscrite dans `SOURCES.md`.

### Autres suites, hors programme

Stockage de fichiers WebDAV et JMAP fichiers ; bascule de `lyxal_notification` vers ce serveur
comme fournisseur par défaut (son propre plan, après le lot 6) ; migration depuis un autre
serveur de courrier ; DKIM v2 et signatures post-quantiques.

## Essais réels à faire

Les tests automatiques n'appellent aucun service réel : serveurs, clients et résolveur DNS sont
des imitations locales. Les essais réels se font sur ordre du CTO, avec les moyens qu'il fournit
(décision P11) ; secrets rangés dans `lyxal_secrets`, jamais dans le dépôt ni dans une
conversation. Chaque lot ajoute ici ses essais ; un essai réussi est retiré de la liste et noté
dans le `README.md`.

Moyens à fournir par le CTO (décision P11), avant le lot 22 et dès le lot 6 pour l'envoi :

* un **nom de domaine** d'essai et la main sur son **DNS** (MX, SPF, DKIM, DMARC, MTA-STS,
  TLS-RPT, enregistrements SRV de découverte, DNSSEC et TLSA pour DANE) ;
* une **adresse IP publique** avec le **port 25 ouvert en entrée et en sortie**, et la main sur
  son **DNS inverse** ;
* des **logiciels réels** : Thunderbird, Apple Mail (iPhone, Mac), Outlook, un client Android ;
* des **boîtes d'essai** chez Gmail, Outlook.com et Yahoo.

| Lot | Préalable | Action | Résultat attendu |
| :- | :--- | :--- | :--- |
| 5 | Domaine, MX, IP avec port 25 entrant | Envoyer depuis Gmail, Outlook.com et Yahoo vers une adresse du domaine | Message remis en boîte ; `Authentication-Results` exact (SPF, DKIM, DMARC) ; destinataire inconnu refusé dès `RCPT TO` ; essai de relais refusé |
| 5 | Idem | Laisser le port 25 ouvert une semaine | Aucun relais ouvert ; limites par IP tenues ; mémoire stable |
| 6 | Port 25 sortant, DNS inverse, SPF, DKIM, DMARC publiés | Envoyer vers Gmail, Outlook.com et Yahoo | Message en boîte de réception (pas en indésirables) ; SPF, DKIM et DMARC « pass » dans les en-têtes reçus |
| 6 | Idem | Envoyer vers une adresse inexistante | Avis de non-remise reçu et rattaché ; événement `mail.message.bounced` |
| 7 | DNSSEC et TLSA, politique MTA-STS, adresse TLS-RPT | Recevoir d'un expéditeur qui applique MTA-STS et DANE ; attendre les rapports | Livraison en TLS vérifié ; rapports TLS et DMARC reçus et lus |
| 8 | Thunderbird, Apple Mail, Outlook, client Android ; mot de passe d'application | Configurer le compte, lire, classer, supprimer, chercher, laisser en veille | Synchronisation juste entre logiciels ; pas de message en double ni perdu ; IDLE fonctionne |
| 9, 10 | Idem | Recherche dans le texte et les pièces jointes ; filtre Sieve et réponse d'absence | Résultats justes ; filtre appliqué à la réception |
| 11 | Flux réel sur le domaine d'essai | Laisser arriver du courrier pendant plusieurs semaines | Taux de faux positifs relevé ; apprentissage par déplacement vers « Indésirables » |
| 12 | Client JMAP | Lire, envoyer, recevoir une notification push | Conforme aux suites JMAP retenues |
| 13 | DNS du domaine | Obtenir un certificat automatique ; configuration automatique dans Thunderbird, Apple Mail, Outlook | Certificat délivré et renouvelé ; compte configuré sans saisie des serveurs |
| 22 | Tout ce qui précède | Rejouer l'ensemble avant la clôture | Liste vide |
