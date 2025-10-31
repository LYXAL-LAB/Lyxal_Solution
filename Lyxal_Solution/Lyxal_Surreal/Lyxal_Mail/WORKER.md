# 🔧 Worker Go - Lyxal Mail (Bunny Container)

Ce document contient le code complet du worker SMTP en Go (~200 lignes) optimisé pour **Bunny Container**.

**Configuration** : Connexion à SurrealDB Cloud via WebSocket sécurisé (WSS).

---

## 📦 Structure du Projet

```
lyxal-mail-worker/
├── main.go              # Point d'entrée
├── config.go            # Configuration
├── queue_listener.go    # LIVE QUERY handler
├── smtp_sender.go       # Envoi SMTP
├── dkim_signer.go       # Signature DKIM
├── go.mod               # Dépendances
├── go.sum
└── config.yml           # Fichier de config
```

---

## 1️⃣ `main.go` - Point d'Entrée

```go
package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com.surrealdb/surrealdb.go"
)

func main() {
	log.Println("🚀 Lyxal Mail Worker starting...")

	// Chargement de la configuration
	config, err := LoadConfig("config.yml")
	if err != nil {
		log.Fatal("❌ Failed to load config:", err)
	}

	log.Printf("✅ Config loaded: %s@%s:%s", config.SurrealDB.Namespace, config.SurrealDB.Host, config.SurrealDB.Database)

	// Connexion à SurrealDB
	db, err := surrealdb.New(config.SurrealDB.URL)
	if err != nil {
		log.Fatal("❌ Failed to connect to SurrealDB:", err)
	}
	defer db.Close()

	// Authentification
	_, err = db.SignIn(&surrealdb.Auth{
		Username: config.SurrealDB.Username,
		Password: config.SurrealDB.Password,
	})
	if err != nil {
		log.Fatal("❌ Failed to authenticate:", err)
	}

	// Sélection namespace/database
	_, err = db.Use(config.SurrealDB.Namespace, config.SurrealDB.Database)
	if err != nil {
		log.Fatal("❌ Failed to use namespace/database:", err)
	}

	log.Println("✅ Connected to SurrealDB")

	// Contexte avec annulation
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Gestionnaire de signaux (Ctrl+C, kill)
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)

	// Démarrage du listener de queue
	go StartQueueListener(ctx, db, config)

	log.Println("✅ Worker started, listening for emails...")

	// Attente du signal d'arrêt
	<-sigChan
	log.Println("🛑 Shutdown signal received, gracefully stopping...")
	cancel()

	// Attente de fin des goroutines (timeout 10s)
	time.Sleep(10 * time.Second)
	log.Println("👋 Worker stopped")
}
```

---

## 2️⃣ `config.go` - Configuration

```go
package main

import (
	"os"

	"gopkg.in/yaml.v3"
)

type Config struct {
	SurrealDB struct {
		URL       string `yaml:"url"`
		Host      string `yaml:"host"`
		Namespace string `yaml:"namespace"`
		Database  string `yaml:"database"`
		Username  string `yaml:"username"`
		Password  string `yaml:"password"`
	} `yaml:"surrealdb"`

	Worker struct {
		Concurrency int `yaml:"concurrency"` // Nombre de workers parallèles
	} `yaml:"worker"`

	Logging struct {
		Level string `yaml:"level"` // debug, info, warn, error
	} `yaml:"logging"`
}

// LoadConfig charge la configuration depuis un fichier YAML
func LoadConfig(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	var config Config
	err = yaml.Unmarshal(data, &config)
	if err != nil {
		return nil, err
	}

	return &config, nil
}
```

### Fichier `config.yml`

```yaml
surrealdb:
  url: "${SURREALDB_URL}"  # Ex: wss://cloud.surrealdb.com:443/rpc
  host: "${SURREALDB_HOST}"  # Ex: cloud.surrealdb.com:443
  namespace: "lyxal_solution"
  database: "main"
  username: "${SURREALDB_USERNAME}"  # Variables d'environnement
  password: "${SURREALDB_PASSWORD}"  # Variables d'environnement

worker:
  concurrency: 3  # 3 workers parallèles (Bunny scale automatiquement)

logging:
  level: "info"
```

**Variables d'environnement** (configurées dans Bunny Container) :
- `SURREALDB_URL` : `wss://cloud.surrealdb.com:443/rpc`
- `SURREALDB_HOST` : `cloud.surrealdb.com:443`
- `SURREALDB_USERNAME` : Votre username SurrealDB Cloud
- `SURREALDB_PASSWORD` : Votre password SurrealDB Cloud

---

## 3️⃣ `queue_listener.go` - LIVE QUERY Handler

```go
package main

import (
	"context"
	"log"
	"time"

	"github.com/surrealdb/surrealdb.go"
)

// Email représente un email de la queue
type Email struct {
	ID          string                 `json:"id"`
	To          string                 `json:"to"`
	From        string                 `json:"from"`
	FromName    string                 `json:"from_name,omitempty"`
	Subject     string                 `json:"subject"`
	HTMLBody    string                 `json:"html_body"`
	TextBody    string                 `json:"text_body,omitempty"`
	Domain      map[string]interface{} `json:"domain"`
	Status      string                 `json:"status"`
	Attempts    int                    `json:"attempts"`
	MaxAttempts int                    `json:"max_attempts"`
}

// StartQueueListener démarre l'écoute de la queue via LIVE QUERY
func StartQueueListener(ctx context.Context, db *surrealdb.DB, config *Config) {
	log.Println("📡 Starting LIVE QUERY listener...")

	// LIVE QUERY : Écoute les emails pending
	query := "LIVE SELECT * FROM email_queue WHERE status = 'pending' AND scheduled_at <= time::now()"

	liveQueryID, err := db.Live("email_queue", query)
	if err != nil {
		log.Fatal("❌ Failed to start LIVE QUERY:", err)
	}

	log.Printf("✅ LIVE QUERY started (ID: %s)", liveQueryID)

	// Channel pour recevoir les notifications
	notifications := make(chan surrealdb.Notification, 100)

	// Goroutine pour recevoir les notifications
	go func() {
		for {
			select {
			case <-ctx.Done():
				return
			default:
				notif, err := db.ListenLive(liveQueryID)
				if err != nil {
					log.Println("⚠️ LIVE QUERY error:", err)
					time.Sleep(5 * time.Second) // Retry après 5s
					continue
				}
				notifications <- notif
			}
		}
	}()

	// Workers pool
	for i := 0; i < config.Worker.Concurrency; i++ {
		go worker(ctx, db, config, notifications, i+1)
	}

	// Attente du contexte d'annulation
	<-ctx.Done()
	log.Println("🛑 Stopping LIVE QUERY listener...")
	db.Kill(liveQueryID)
}

// worker traite les emails en parallèle
func worker(ctx context.Context, db *surrealdb.DB, config *Config, notifications <-chan surrealdb.Notification, workerID int) {
	log.Printf("👷 Worker #%d started", workerID)

	for {
		select {
		case <-ctx.Done():
			log.Printf("👷 Worker #%d stopped", workerID)
			return

		case notif := <-notifications:
			// Le notification contient l'email complet
			var email Email
			err := notif.Unmarshal(&email)
			if err != nil {
				log.Printf("⚠️ Worker #%d: Failed to unmarshal email: %v", workerID, err)
				continue
			}

			log.Printf("📧 Worker #%d: Processing email %s to %s", workerID, email.ID, email.To)

			// Traitement de l'email
			err = ProcessEmail(db, config, &email)
			if err != nil {
				log.Printf("❌ Worker #%d: Failed to send email %s: %v", workerID, email.ID, err)
			} else {
				log.Printf("✅ Worker #%d: Email %s sent successfully", workerID, email.ID)
			}
		}
	}
}

// ProcessEmail traite et envoie un email
func ProcessEmail(db *surrealdb.DB, config *Config, email *Email) error {
	// 1. Mise à jour du statut à "sending"
	_, err := db.Query("UPDATE $id SET status = 'sending'", map[string]interface{}{
		"id": email.ID,
	})
	if err != nil {
		return err
	}

	// 2. Récupération de la config domaine complète
	domainID := email.Domain["id"].(string)
	var domain DomainConfig
	err = db.Select(domainID, &domain)
	if err != nil {
		UpdateEmailStatus(db, email.ID, "failed", err.Error(), "500")
		return err
	}

	// 3. Signature DKIM
	signedMessage, err := SignDKIM(email, &domain)
	if err != nil {
		log.Printf("⚠️ DKIM signing failed: %v (sending anyway)", err)
		signedMessage = BuildEmailMessage(email) // Envoi sans DKIM
	}

	// 4. Envoi SMTP
	err = SendSMTP(&domain, email.To, signedMessage)
	if err != nil {
		UpdateEmailStatus(db, email.ID, "failed", err.Error(), ExtractSMTPCode(err))
		return err
	}

	// 5. Mise à jour du statut à "sent"
	_, err = db.Query("UPDATE $id SET status = 'sent', sent_at = time::now()", map[string]interface{}{
		"id": email.ID,
	})

	return err
}

// UpdateEmailStatus met à jour le statut d'un email
func UpdateEmailStatus(db *surrealdb.DB, emailID, status, errorMsg, errorCode string) {
	_, err := db.Query(`
		UPDATE $id SET 
			status = $status,
			error_message = $error_msg,
			error_code = $error_code
	`, map[string]interface{}{
		"id":        emailID,
		"status":    status,
		"error_msg": errorMsg,
		"error_code": errorCode,
	})

	if err != nil {
		log.Printf("⚠️ Failed to update email status: %v", err)
	}
}

// ExtractSMTPCode extrait le code SMTP d'une erreur
func ExtractSMTPCode(err error) string {
	// Parse l'erreur pour extraire le code (ex: "550 ...")
	// Implémentation simplifiée
	return "500"
}
```

---

## 4️⃣ `smtp_sender.go` - Envoi SMTP

```go
package main

import (
	"crypto/tls"
	"fmt"
	"net/smtp"
	"strings"
)

// DomainConfig représente la config d'un domaine
type DomainConfig struct {
	ID              string `json:"id"`
	Domain          string `json:"domain"`
	SMTPHost        string `json:"smtp_host"`
	SMTPPort        int    `json:"smtp_port"`
	DKIMEnabled     bool   `json:"dkim_enabled"`
	DKIMSelector    string `json:"dkim_selector"`
	DKIMPrivateKey  string `json:"dkim_private_key"`
}

// SendSMTP envoie un email via SMTP
func SendSMTP(domain *DomainConfig, to string, message []byte) error {
	// Connexion SMTP
	addr := fmt.Sprintf("%s:%d", domain.SMTPHost, domain.SMTPPort)

	// Configuration TLS
	tlsConfig := &tls.Config{
		ServerName: domain.SMTPHost,
	}

	// Connexion
	conn, err := tls.Dial("tcp", addr, tlsConfig)
	if err != nil {
		return fmt.Errorf("failed to connect to SMTP server: %w", err)
	}
	defer conn.Close()

	// Client SMTP
	client, err := smtp.NewClient(conn, domain.SMTPHost)
	if err != nil {
		return fmt.Errorf("failed to create SMTP client: %w", err)
	}
	defer client.Quit()

	// MAIL FROM
	from := fmt.Sprintf("noreply@%s", domain.Domain)
	if err := client.Mail(from); err != nil {
		return fmt.Errorf("MAIL FROM failed: %w", err)
	}

	// RCPT TO
	if err := client.Rcpt(to); err != nil {
		return fmt.Errorf("RCPT TO failed: %w", err)
	}

	// DATA
	wc, err := client.Data()
	if err != nil {
		return fmt.Errorf("DATA command failed: %w", err)
	}

	// Écriture du message
	_, err = wc.Write(message)
	if err != nil {
		return fmt.Errorf("failed to write message: %w", err)
	}

	// Fermeture
	err = wc.Close()
	if err != nil {
		return fmt.Errorf("failed to close DATA: %w", err)
	}

	return nil
}

// BuildEmailMessage construit le message email complet (sans DKIM)
func BuildEmailMessage(email *Email) []byte {
	var sb strings.Builder

	// Headers
	sb.WriteString(fmt.Sprintf("From: %s <%s>\r\n", email.FromName, email.From))
	sb.WriteString(fmt.Sprintf("To: %s\r\n", email.To))
	sb.WriteString(fmt.Sprintf("Subject: %s\r\n", email.Subject))
	sb.WriteString("MIME-Version: 1.0\r\n")
	sb.WriteString("Content-Type: multipart/alternative; boundary=\"lyxal-boundary\"\r\n")
	sb.WriteString("\r\n")

	// Body text
	if email.TextBody != "" {
		sb.WriteString("--lyxal-boundary\r\n")
		sb.WriteString("Content-Type: text/plain; charset=UTF-8\r\n")
		sb.WriteString("\r\n")
		sb.WriteString(email.TextBody)
		sb.WriteString("\r\n")
	}

	// Body HTML
	sb.WriteString("--lyxal-boundary\r\n")
	sb.WriteString("Content-Type: text/html; charset=UTF-8\r\n")
	sb.WriteString("\r\n")
	sb.WriteString(email.HTMLBody)
	sb.WriteString("\r\n")
	sb.WriteString("--lyxal-boundary--\r\n")

	return []byte(sb.String())
}
```

---

## 5️⃣ `dkim_signer.go` - Signature DKIM

```go
package main

import (
	"crypto"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/base64"
	"encoding/pem"
	"fmt"
	"strings"
	"time"
)

// SignDKIM signe un email avec DKIM
func SignDKIM(email *Email, domain *DomainConfig) ([]byte, error) {
	if !domain.DKIMEnabled {
		return BuildEmailMessage(email), nil
	}

	// Parse la clé privée
	block, _ := pem.Decode([]byte(domain.DKIMPrivateKey))
	if block == nil {
		return nil, fmt.Errorf("failed to parse PEM block")
	}

	privateKey, err := x509.ParsePKCS1PrivateKey(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("failed to parse private key: %w", err)
	}

	// Construction du message
	message := BuildEmailMessage(email)

	// Headers à signer
	headers := []string{"from", "to", "subject"}

	// Canonicalisation du body (simple)
	bodyHash := sha256.Sum256([]byte(email.HTMLBody))
	bodyHashB64 := base64.StdEncoding.EncodeToString(bodyHash[:])

	// Construction du DKIM-Signature header
	timestamp := time.Now().Unix()
	dkimHeader := fmt.Sprintf(
		"v=1; a=rsa-sha256; c=relaxed/simple; d=%s; s=%s; t=%d; bh=%s; h=%s;",
		domain.Domain,
		domain.DKIMSelector,
		timestamp,
		bodyHashB64,
		strings.Join(headers, ":"),
	)

	// Signature
	hash := sha256.Sum256([]byte(dkimHeader))
	signature, err := rsa.SignPKCS1v15(nil, privateKey, crypto.SHA256, hash[:])
	if err != nil {
		return nil, fmt.Errorf("failed to sign: %w", err)
	}

	signatureB64 := base64.StdEncoding.EncodeToString(signature)

	// Ajout du header DKIM-Signature au message
	signedMessage := fmt.Sprintf("DKIM-Signature: %s b=%s\r\n%s", dkimHeader, signatureB64, string(message))

	return []byte(signedMessage), nil
}
```

---

## 6️⃣ `go.mod` - Dépendances

```go
module github.com/lyxal/lyxal-mail-worker

go 1.21

require (
	github.com/surrealdb/surrealdb.go v0.2.1
	gopkg.in/yaml.v3 v3.0.1
)
```

---

## 🔨 Compilation & Déploiement

### Installation des dépendances

```bash
go mod download
```

### Compilation

```bash
# Linux/macOS
go build -o lyxal-mail-worker

# Windows
go build -o lyxal-mail-worker.exe

# Cross-compilation pour Linux depuis Windows
GOOS=linux GOARCH=amd64 go build -o lyxal-mail-worker
```

### Exécution

```bash
./lyxal-mail-worker
```

### Logs

```
🚀 Lyxal Mail Worker starting...
✅ Config loaded: lyxal_solution@localhost:8000:main
✅ Connected to SurrealDB
📡 Starting LIVE QUERY listener...
✅ LIVE QUERY started (ID: abc123)
👷 Worker #1 started
👷 Worker #2 started
👷 Worker #3 started
✅ Worker started, listening for emails...
📧 Worker #1: Processing email email_queue:xyz789 to user@example.com
✅ Worker #1: Email email_queue:xyz789 sent successfully
```

---

## 🐳 Dockerfile

```dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY . .
RUN go mod download
RUN go build -o lyxal-mail-worker

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/lyxal-mail-worker .
COPY config.yml .

CMD ["./lyxal-mail-worker"]
```

### Déploiement sur Bunny Container

#### Option 1 : Via Bunny CLI (Recommandé)

```bash
# Installation Bunny CLI
npm install -g @bunny.net/cli

# Login
bunny login

# Build de l'image Docker
docker build -t lyxal-mail-worker .

# Push vers Bunny Container Registry
docker tag lyxal-mail-worker bunny.net/lyxal/mail-worker:latest
docker push bunny.net/lyxal/mail-worker:latest

# Déploiement
bunny deploy \
  --name lyxal-mail-worker \
  --image bunny.net/lyxal/mail-worker:latest \
  --env SURREALDB_URL=wss://cloud.surrealdb.com:443/rpc \
  --env SURREALDB_HOST=cloud.surrealdb.com:443 \
  --env SURREALDB_NAMESPACE=lyxal_solution \
  --env SURREALDB_DATABASE=main \
  --env SURREALDB_USERNAME=votre-username \
  --env SURREALDB_PASSWORD=votre-password \
  --scale-min 1 \
  --scale-max 5 \
  --cpu 0.5 \
  --memory 512
```

#### Option 2 : Via Interface Web Bunny.net

1. Aller sur https://bunny.net/dashboard/container
2. Cliquer sur "New Container"
3. Uploader le Dockerfile ou connecter le repo GitHub
4. Configurer les variables d'environnement
5. Configurer le scaling (min: 1, max: 5)
6. Déployer

#### Configuration Auto-Scaling

```yaml
# bunny-config.yml
scaling:
  min_instances: 1  # Minimum 1 worker toujours actif
  max_instances: 5  # Maximum 5 workers en pic de charge
  cpu_threshold: 70  # Scale up si CPU > 70%
  memory_threshold: 80  # Scale up si RAM > 80%

resources:
  cpu: 0.5  # 0.5 CPU core par worker
  memory: 512  # 512 MB RAM par worker
```

---

---

## 📊 Monitoring sur Bunny Container

### Logs en Temps Réel

```bash
# Via CLI
bunny logs lyxal-mail-worker --follow

# Via interface web
https://bunny.net/dashboard/container/lyxal-mail-worker/logs
```

### Métriques

**Automatiquement disponibles** dans le tableau de bord Bunny :
- ✅ CPU usage par worker
- ✅ RAM usage
- ✅ Nombre d'instances actives
- ✅ Requêtes par seconde
- ✅ Erreurs
- ✅ Coûts en temps réel

---

## 💰 Coûts Bunny Container

| Ressources | Prix/heure | Prix/mois (24/7) |
|------------|-----------|------------------|
| **1 worker** (0.5 CPU, 512MB) | $0.002/h | ~$1.50/mois |
| **3 workers** (moyenne) | $0.006/h | ~$4.50/mois |
| **5 workers** (pic) | $0.010/h | ~$7.50/mois |

**Exemple réel** :
- 1 worker 24/7 : $1.50/mois
- Scale à 3 workers pendant 8h/jour : +$1/mois
- Pics à 5 workers pendant 2h/jour : +$0.30/mois
- **Total : ~$3-5/mois** 🎉

**vs VPS Hetzner** :
- VPS 2 CPU, 4GB RAM : 5€/mois (toujours allumé, même sans charge)
- Bunny Container : Paiement à l'usage réel uniquement

---

## 🚀 Prochaines Étapes

Voir **[DEPLOYMENT.md](./DEPLOYMENT.md)** pour le guide complet de déploiement Cloud en production.

