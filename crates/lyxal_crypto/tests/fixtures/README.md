# Données de test de `lyxal_crypto`

Tout ce dossier est réservé aux tests : aucune clé ni aucun certificat ne doit servir ailleurs.

| Fichiers | Contenu |
| :--- | :--- |
| `rsa2048_test_only.*` | Clé RSA-2048 de test (PKCS#8 en Base64), sa clé publique et une signature RS256 calculée par OpenSSL (décision K8) |
| `wycheproof/` | Vecteurs AES-GCM, RSASSA-PKCS1-v1_5 SHA-256 (2048, 3072, 4096 bits) et Ed25519 du projet Wycheproof et sa licence Apache-2.0 (provenance : [`SOURCES.md`](../../SOURCES.md)) |
| `dkim/mail_auth/` | Corpus DKIM de `mail-auth` 0.16.0 (`001.txt` : message de la RFC 8463 annexe A ; `002.txt`, `003.txt`), copié tel quel avec ses licences `Apache-2.0 OR MIT` ; format : enregistrements DNS, ligne vide, message en fins de ligne LF |
| `dkim/lyxal_signed_test_only.txt` | Message signé pour ces tests (même format) : `ed25519-sha256` simple/simple avec la clé de la RFC 8463, `rsa-sha256` relaxed/relaxed avec `rsa2048_test_only` ; signatures calculées par OpenSSL (Python `cryptography` 50.0.1) avec une canonicalisation écrite depuis la RFC 6376 (celle de `tools/check_dkim_fixtures.py`) |
| `dkim/rsa768_test_only.spki.hex`, `dkim/rsa6144_test_only.spki.hex` | Clés publiques RSA (SubjectPublicKeyInfo en hexadécimal) trop courte et trop longue pour DKIM, générées par `openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:768` (resp. `6144`) puis `openssl pkey -pubout -outform DER` ; clés privées détruites |
| `tls_test_only/` | Autorité de test (`ca.pem`, sa clé est détruite après génération), certificats de serveur avec leurs clés et un certificat auto-signé, pour `tests/it/tls_server.rs`, `tests/it/tls_client.rs`, les essais unitaires de `src/tls.rs` et la cible de fuzzing `tls_pem` |

## Certificats TLS de test

Générés une fois par OpenSSL 3.0.13 le 20 novembre 2026, valides dix ans ; les tests vérifient
les chaînes à une date fixe (1er janvier 2027), indépendante de l'horloge. Depuis
`tests/fixtures/tls_test_only/` :

```sh
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out ca.key.pem
openssl req -x509 -new -key ca.key.pem -sha256 -days 3650 -subj "/CN=Lyxal Test CA" \
  -addext "basicConstraints=critical,CA:TRUE" -addext "keyUsage=critical,keyCertSign" -out ca.pem
leaf() { # nom, arguments de génération de la clé, noms couverts
  local name=$1 san=$3
  openssl genpkey $2 -out "$name.key.pem"
  openssl req -new -key "$name.key.pem" -subj "/CN=$name" -out "$name.csr"
  printf 'basicConstraints=critical,CA:FALSE\nextendedKeyUsage=serverAuth\nsubjectAltName=%s\n' "$san" > "$name.ext"
  openssl x509 -req -in "$name.csr" -CA ca.pem -CAkey ca.key.pem -CAcreateserial -sha256 \
    -days 3650 -extfile "$name.ext" -out "$name.cert.pem"
  cat "$name.cert.pem" ca.pem > "$name.chain.pem"
  rm "$name.csr" "$name.ext" "$name.cert.pem"
}
leaf p256 "-algorithm EC -pkeyopt ec_paramgen_curve:P-256" "DNS:mail.example.test"
leaf p256_next "-algorithm EC -pkeyopt ec_paramgen_curve:P-256" "DNS:mail.example.test"
leaf p384 "-algorithm EC -pkeyopt ec_paramgen_curve:P-384" "DNS:p384.example.test"
leaf p521 "-algorithm EC -pkeyopt ec_paramgen_curve:P-521" "DNS:p521.example.test"
leaf rsa2048 "-algorithm RSA -pkeyopt rsa_keygen_bits:2048" "DNS:rsa.example.test"
leaf rsa1024 "-algorithm RSA -pkeyopt rsa_keygen_bits:1024" "DNS:weak.example.test"
leaf ed25519 "-algorithm ED25519" "DNS:ed.example.test"
leaf wildcard "-algorithm EC -pkeyopt ec_paramgen_curve:P-256" "DNS:*.wild.example.test"
leaf default "-algorithm EC -pkeyopt ec_paramgen_curve:P-256" "DNS:default.example.test"
# Autres encodages des mêmes clés.
openssl ec -in p256.key.pem -out p256.sec1.key.pem
openssl rsa -in rsa2048.key.pem -traditional -out rsa2048.pkcs1.key.pem
openssl pkcs8 -topk8 -nocrypt -in p256.key.pem -outform DER -out p256.key.der
openssl x509 -in p256.chain.pem -outform DER -out p256.leaf.der
openssl pkcs8 -topk8 -v2 aes-256-cbc -passout pass:test-only -in p256.key.pem -out p256.encrypted.key.pem
rm -f ca.key.pem ca.srl
```

Certificat auto-signé (TLS côté client, généré le 27 novembre 2026 par OpenSSL 3.0.13, valide
dix ans) :

```sh
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out selfsigned.key.pem
openssl req -x509 -new -key selfsigned.key.pem -sha256 -days 3650 -subj "/CN=selfsigned" \
  -addext "basicConstraints=critical,CA:FALSE" -addext "extendedKeyUsage=serverAuth" \
  -addext "subjectAltName=DNS:mail.example.test" -out selfsigned.chain.pem
```

`p256_next` sert au remplacement à chaud (même nom, autre clé) ; `p521` et `rsa1024` aux refus
(courbe non retenue, clé RSA de moins de 2048 bits) ; `p256.encrypted.key.pem` au refus d'une
clé chiffrée.
