# Données de test de `lyxal_crypto`

Tout ce dossier est réservé aux tests : aucune clé ni aucun certificat ne doit servir ailleurs.

| Fichiers | Contenu |
| :--- | :--- |
| `rsa2048_test_only.*` | Clé RSA-2048 de test (PKCS#8 en Base64), sa clé publique et une signature RS256 calculée par OpenSSL (décision K8) |
| `wycheproof/` | Vecteurs AES-GCM du projet Wycheproof et sa licence Apache-2.0 (provenance : [`SOURCES.md`](../../SOURCES.md)) |
| `tls_test_only/` | Autorité de test (`ca.pem`, sa clé est détruite après génération) et certificats de serveur avec leurs clés, pour `tests/it/tls_server.rs` et la cible de fuzzing `tls_pem` |

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

`p256_next` sert au remplacement à chaud (même nom, autre clé) ; `p521` et `rsa1024` aux refus
(courbe non retenue, clé RSA de moins de 2048 bits) ; `p256.encrypted.key.pem` au refus d'une
clé chiffrée.
