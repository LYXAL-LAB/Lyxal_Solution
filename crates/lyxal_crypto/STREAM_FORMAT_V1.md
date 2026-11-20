# Format de flux v1 — spécification du chiffrement de fichiers

Cette spécification suffit à une implémentation indépendante du format de chiffrement en flux de
`lyxal_crypto` (décision C9 du lot 2 du programme courrier) : octets exacts de l'en-tête,
dérivation de la clé des segments, nonces, données associées, règles de rejet et vecteurs
littéraux. « DOIT » désigne une obligation du format. Toutes les tailles sont en **octets** ;
toutes les bornes sont inclusives. Les nombres binaires sont **gros-boutistes** (ordre réseau).

Le format chiffre un fichier de **n'importe quelle taille** (jusqu'à 2^48 octets) sans le tenir en
mémoire, et permet de lire une plage d'octets sans tout déchiffrer. Il complète l'enveloppe
[`enc:v2`](ENVELOPE_FORMAT_V2.md), limitée à 1 Mio, qui sert ici à sceller la clé du fichier.

## 1 Principe

```text
clé de l'organisation (EncryptionKey, enc:v2)
   └── clé du fichier (StreamKey, 32 octets tirés au hasard, une par fichier)
          scellée par enc:v2 et rangée dans la fiche du fichier, jamais dans le fichier
          └── clé des segments = HKDF-SHA256(clé du fichier, sel de l'en-tête)
                 └── contenu découpé en segments de 65 536 octets, chacun AES-256-GCM
```

Fichier chiffré = en-tête (47 octets, en clair) ‖ segment 0 ‖ segment 1 ‖ … ‖ segment N−1.
Chaque segment chiffré = texte chiffré (même longueur que le clair) ‖ tag de 16 octets.

## 2 En-tête (47 octets)

| Offsets demi-ouverts | Contenu | Valeur |
|---|---|---|
| `[0,4)` | marque | ASCII `LXS1` (`4c 58 53 31`) |
| `[4,5)` | version | `01` |
| `[5,6)` | suite | `01` = AES-256-GCM, HKDF-SHA256 |
| `[6,7)` | exposant de segment | `10` (2^16 = 65 536 octets de clair par segment) |
| `[7,8)` | indicateurs | `00` |
| `[8,40)` | sel | 32 octets aléatoires (CSPRNG), neufs pour chaque fichier |
| `[40,47)` | préfixe de nonce | 7 octets aléatoires (CSPRNG), neufs pour chaque fichier |

Aucune autre valeur n'est définie. Un lecteur DOIT refuser, **avant** tout déchiffrement : une
longueur d'en-tête différente de 47, une autre marque, une suite, un exposant ou des indicateurs
différents (`InvalidStreamHeader`) ; une autre version (`UnsupportedVersion`). Ce contrôle n'est
pas une authentification : l'en-tête est authentifié par chaque segment (§4).

## 3 Clé des segments

```text
DOMAINE = ASCII "lyxal:crypto:stream:v1:aes-256-gcm" suivi de 00   (35 octets)
HEX     = 6c7978616c3a63727970746f3a73747265616d3a76313a6165732d3235362d67636d00

CLE_SEGMENTS = HKDF-SHA256(IKM = clé du fichier (32 octets),
                           sel = en-tête[8,40),
                           info = DOMAINE,
                           L = 32)
```

HKDF selon la RFC 5869 (extraction puis expansion). La clé du fichier est tirée par le système
d'exploitation (`OsRng`), jamais dérivée d'un mot de passe.

## 4 Nonces et données associées

Nonce du segment `i` (12 octets, `i` de 0 à N−1) :

```text
NONCE(i) = en-tête[40,47) || U32BE(i) || DERNIER
DERNIER  = 01 si i = N−1, sinon 00
```

Données associées (AAD), identiques pour tous les segments d'un fichier :

```text
AAD = DOMAINE || en-tête (47 octets) || IDENTITÉ(contexte)
```

`IDENTITÉ` est l'encodage du `SecretContext` d'`enc:v2` (§3 de `ENVELOPE_FORMAT_V2.md`) **sans**
la constante `P` et **sans** `LP(key_id)` : l'octet de mode puis les champs `LP(...)` :

```text
mode tenant : 01 || LP(tenant) || LP(module) || LP(resource) || LP(record_id) || LP(field)
mode global : 02 || LP(purpose)
```

avec `LP(s) = U32BE(len(UTF8(s))) || UTF8(s)` et les mêmes règles de validation des champs
qu'`enc:v2` (§2). L'AAD n'est **jamais vide** : elle compte au moins 35 + 47 + 6 octets. Le
`DOMAINE` diffère de la constante `P` d'`enc:v2` : un segment ne peut pas être pris pour une
enveloppe, ni l'inverse.

## 5 Segments et tailles

* Tous les segments contiennent 65 536 octets de clair, sauf le dernier : de 1 à 65 536 octets,
  ou 0 seulement pour un fichier vide (un seul segment, tag seul).
* N = max(1, ⌈n / 65 536⌉) pour un clair de n octets ; N ≤ 2^32, donc n ≤ 2^48 (256 Tio).
* Taille chiffrée = 47 + n + 16 × N ; fichier vide = 63 octets ; surcoût ≈ 0,024 %.
* Segment `i` chiffré = AES-256-GCM(CLE_SEGMENTS, NONCE(i), clair du segment, AAD), tag complet
  de 16 octets (NIST SP 800-38D), jamais tronqué.

## 6 Lecture et règles de rejet

Le lecteur connaît la **taille totale** du fichier chiffré (fiche de stockage). Il DOIT :

1. contrôler l'en-tête (§2) ;
2. calculer `corps = taille − 47` ; refuser `corps < 16` ; N = ⌈corps / 65 552⌉ ; taille du
   dernier segment chiffré = `corps − (N−1) × 65 552`, refusée si elle est inférieure à 16, ou
   égale à 16 alors que N > 1 (dernier segment vide), ou si N > 2^32 (`InvalidStreamHeader`) ;
3. déchiffrer le segment `i` avec `DERNIER = 01` **seulement** si `i = N−1`, déduit de la taille
   totale, jamais d'une information du fichier ;
4. ne rendre le clair d'un segment qu'après vérification de son tag (`AuthenticationFailed`
   sinon), et effacer le tampon en cas d'échec.

Garanties qui en découlent :

| Altération | Effet |
|---|---|
| bit modifié dans un segment ou un tag | échec de ce segment |
| bit modifié dans l'en-tête | échec dès le premier segment lu (AAD et clé dérivée) |
| deux segments échangés, segment dupliqué ou pris dans un autre fichier | échec (index du nonce, sel et AAD) |
| fichier tronqué, même à une frontière de segment | échec du nouveau dernier segment (chiffré avec `DERNIER = 00`) |
| segment ajouté à la fin | échec de l'ancien dernier segment (chiffré avec `DERNIER = 01`) |
| autre contexte (organisation, fiche, champ) ou autre clé | échec de tout segment |

Non détecté, comme pour `enc:v2` : le remplacement par une **ancienne version complète** du même
fichier sous le même contexte et la même clé (rejeu) ; l'hôte s'en charge (les messages sont
immuables, chaque fichier a sa clé).

**Lecture en flux** : un segment rendu est authentique, mais les segments suivants ne sont pas
encore vérifiés. Une altération plus loin est détectée au segment concerné : l'appelant DOIT alors
interrompre sa réponse (fermer la connexion IMAP ou HTTP), jamais la terminer comme réussie.

**Lecture d'une plage** `[début, fin)` du clair : segments `⌊début / 65 536⌋` à
`⌊(fin − 1) / 65 536⌋`, situés aux offsets `47 + i × 65 552` du fichier chiffré ; ignorer
`début mod 65 536` octets au début du premier, rendre `fin − début` octets.

## 7 Vecteurs littéraux

Calculés par la bibliothèque Python `cryptography` 50.0.1 (OpenSSL 4.0.2 du 25 août 2026), sans appel, compilation
ni exécution de `lyxal_crypto`, puis contrôlés à chaque CI par `tools/check_stream_fixtures.py`
(même moteur indépendant) et par les tests privés `stream::vectors` du crate (RustCrypto), qui
lisent ce fichier sans recalculer les attendus. Contrôle préalable NIST AES-256-GCM : clé et
nonce nuls, clair et AAD vides => tag `530f8afbc74536b9a963b4f1c4cb738b`.

Paramètres de **test uniquement** : clé du fichier `00 01 … 1f`, sel `20 21 … 3f`, préfixe de
nonce `a0 a1 … a6` (imposés par une fonction de test privée ; jamais choisis par l'API publique).
Clair de `PLAINTEXT_LENGTH` octets : l'octet d'indice `k` vaut `k mod 251`. `CONTEXT` :
`tenant|tenant|module|resource|record_id|field` ou `global|purpose`. `TAGS_HEX` : tags des
segments dans l'ordre ; `CIPHERTEXT_SHA256` : SHA-256 du fichier chiffré complet.

```text
VECTOR=S0
KEY_HEX=000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
SALT_HEX=202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f
NONCE_PREFIX_HEX=a0a1a2a3a4a5a6
CONTEXT=tenant|Acme|storage|file|file_01|content
PLAINTEXT_LENGTH=0
HEADER_HEX=4c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a6
SEGMENT_KEY_HEX=79a4c49e3abb45508a46c8f58852f3a9eb0d1e792bd1f1ca3be23447077242f9
AAD_HEX=6c7978616c3a63727970746f3a73747265616d3a76313a6165732d3235362d67636d004c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a6010000000441636d650000000773746f726167650000000466696c650000000766696c655f303100000007636f6e74656e74
SEGMENTS=1
CIPHERTEXT_LENGTH=63
TAGS_HEX=b8cf7b2355c3d0395b5bb9e1be0fd9f1
CIPHERTEXT_SHA256=aae769a2dddd49d9c5d8e837f394f59bfb926bc675d6cf733c32471c4819d316
CIPHERTEXT_HEX=4c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a6b8cf7b2355c3d0395b5bb9e1be0fd9f1
```

```text
VECTOR=S1
KEY_HEX=000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
SALT_HEX=202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f
NONCE_PREFIX_HEX=a0a1a2a3a4a5a6
CONTEXT=tenant|Acme|storage|file|file_01|content
PLAINTEXT_LENGTH=1
HEADER_HEX=4c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a6
SEGMENT_KEY_HEX=79a4c49e3abb45508a46c8f58852f3a9eb0d1e792bd1f1ca3be23447077242f9
AAD_HEX=6c7978616c3a63727970746f3a73747265616d3a76313a6165732d3235362d67636d004c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a6010000000441636d650000000773746f726167650000000466696c650000000766696c655f303100000007636f6e74656e74
SEGMENTS=1
CIPHERTEXT_LENGTH=64
TAGS_HEX=938eafd1f91057e59e4483c1eb0b99a5
CIPHERTEXT_SHA256=e200e15125c1363d74b5865605868819e33aa153e5ca5e755965198eff5f336f
CIPHERTEXT_HEX=4c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a68a938eafd1f91057e59e4483c1eb0b99a5
```

```text
VECTOR=S65535
KEY_HEX=000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
SALT_HEX=202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f
NONCE_PREFIX_HEX=a0a1a2a3a4a5a6
CONTEXT=tenant|Acme|storage|file|file_01|content
PLAINTEXT_LENGTH=65535
HEADER_HEX=4c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a6
SEGMENT_KEY_HEX=79a4c49e3abb45508a46c8f58852f3a9eb0d1e792bd1f1ca3be23447077242f9
AAD_HEX=6c7978616c3a63727970746f3a73747265616d3a76313a6165732d3235362d67636d004c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a6010000000441636d650000000773746f726167650000000466696c650000000766696c655f303100000007636f6e74656e74
SEGMENTS=1
CIPHERTEXT_LENGTH=65598
TAGS_HEX=2b5c80fedfeccc7318cbc1b0f7e35875
CIPHERTEXT_SHA256=5c67a4065147f2177e4a3febbfa8ab3c7873ebb68b86f6d2e67139f8c3960f6a
```

```text
VECTOR=S65536
KEY_HEX=000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
SALT_HEX=202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f
NONCE_PREFIX_HEX=a0a1a2a3a4a5a6
CONTEXT=tenant|Acme|storage|file|file_01|content
PLAINTEXT_LENGTH=65536
HEADER_HEX=4c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a6
SEGMENT_KEY_HEX=79a4c49e3abb45508a46c8f58852f3a9eb0d1e792bd1f1ca3be23447077242f9
AAD_HEX=6c7978616c3a63727970746f3a73747265616d3a76313a6165732d3235362d67636d004c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a6010000000441636d650000000773746f726167650000000466696c650000000766696c655f303100000007636f6e74656e74
SEGMENTS=1
CIPHERTEXT_LENGTH=65599
TAGS_HEX=857270c2437c5a5cedfbd40e28eeea78
CIPHERTEXT_SHA256=9fdfc3bc474f288da319c41e379510bd15c6eb38a6bb098aeddd372b7a197009
```

```text
VECTOR=S65537
KEY_HEX=000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
SALT_HEX=202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f
NONCE_PREFIX_HEX=a0a1a2a3a4a5a6
CONTEXT=tenant|Acme|storage|file|file_01|content
PLAINTEXT_LENGTH=65537
HEADER_HEX=4c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a6
SEGMENT_KEY_HEX=79a4c49e3abb45508a46c8f58852f3a9eb0d1e792bd1f1ca3be23447077242f9
AAD_HEX=6c7978616c3a63727970746f3a73747265616d3a76313a6165732d3235362d67636d004c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a6010000000441636d650000000773746f726167650000000466696c650000000766696c655f303100000007636f6e74656e74
SEGMENTS=2
CIPHERTEXT_LENGTH=65616
TAGS_HEX=233bbcce9e02a1e0ab1bd123cff6f492,6a4bdb6a5e4a7ee98f887a7ae9d59c8c
CIPHERTEXT_SHA256=6073c6140b8f6ace13d283b2ab70d44b9b75f970bbd00f135175cd475048a5cf
```

```text
VECTOR=S200000
KEY_HEX=000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
SALT_HEX=202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f
NONCE_PREFIX_HEX=a0a1a2a3a4a5a6
CONTEXT=tenant|Acme|storage|file|file_01|content
PLAINTEXT_LENGTH=200000
HEADER_HEX=4c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a6
SEGMENT_KEY_HEX=79a4c49e3abb45508a46c8f58852f3a9eb0d1e792bd1f1ca3be23447077242f9
AAD_HEX=6c7978616c3a63727970746f3a73747265616d3a76313a6165732d3235362d67636d004c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a6010000000441636d650000000773746f726167650000000466696c650000000766696c655f303100000007636f6e74656e74
SEGMENTS=4
CIPHERTEXT_LENGTH=200111
TAGS_HEX=233bbcce9e02a1e0ab1bd123cff6f492,94f5737fb7107edc062a14243a48503d,934a304e2ecbb5a4c58c71c298ff1e37,772d7472c4de4056fa535e14980e2694
CIPHERTEXT_SHA256=acbea27838209c75be4ffa1520a03d441fee7523ae49d71448fa0469931fcb42
```

```text
VECTOR=G1
KEY_HEX=000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
SALT_HEX=202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f
NONCE_PREFIX_HEX=a0a1a2a3a4a5a6
CONTEXT=global|storage.test
PLAINTEXT_LENGTH=1
HEADER_HEX=4c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a6
SEGMENT_KEY_HEX=79a4c49e3abb45508a46c8f58852f3a9eb0d1e792bd1f1ca3be23447077242f9
AAD_HEX=6c7978616c3a63727970746f3a73747265616d3a76313a6165732d3235362d67636d004c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a6020000000c73746f726167652e74657374
SEGMENTS=1
CIPHERTEXT_LENGTH=64
TAGS_HEX=28cbd1ca500f5024e3c6882f88e8a26a
CIPHERTEXT_SHA256=ba0fcc01e5871bd4e1e1b0d572567a2db7f38dbaf88c552a0bebf841b8f74626
CIPHERTEXT_HEX=4c58533101011000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3fa0a1a2a3a4a5a68a28cbd1ca500f5024e3c6882f88e8a26a
```

S0 à S200000 encadrent les frontières de segment (vide, 1 octet, 65 535, 65 536 : un seul
segment plein et dernier, 65 537 : deux segments dont un dernier d'un octet, 200 000 : quatre
segments). G1 : même clair d'un octet que S1 en mode global ; seul le tag change (AAD).

Ces constantes sont des oracles à recopier littéralement, jamais à recalculer pour modifier un
résultat attendu. Vecteurs de rejet minimaux, sur S65537 : tronquer après le premier segment
(taille 47 + 65 552) DOIT échouer (le segment 0 est alors lu comme dernier) ; modifier le sel ou
un octet du préfixe de nonce, rouvrir avec le contexte `tenant|acme|...` ou en mode global, ou
lire le segment 1 à la place du segment 0, DOIVENT échouer à l'authentification.
