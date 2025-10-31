# 🚀 Déploiement - Magic Containers

Guide complet pour déployer vos services Lyxal sur Bunny Magic Containers.

---

## 📋 Prérequis

### 1. Compte Bunny.net

```bash
# S'inscrire sur https://bunny.net
# Gratuit, pas de carte de crédit requise pour commencer
# $10 de crédit offert pour tester
```

### 2. Docker

```bash
# Installer Docker Desktop
# Windows/Mac: https://www.docker.com/products/docker-desktop
# Linux: sudo apt install docker.io

# Vérifier l'installation
docker --version
```

### 3. GitHub Account (pour CI/CD)

```bash
# Créer un compte sur https://github.com
# Créer un repo pour votre service
```

---

## 🎯 Méthode 1 : Déploiement Manuel (Dashboard)

### Étape 1 : Créer l'Application

1. Aller sur https://panel.bunny.net
2. Menu **Magic Containers**
3. Cliquer **Add Application**

### Étape 2 : Configuration

```yaml
Name: lyxal-mail-worker
Docker Image: lyxal/mail-worker:latest
Port: 3000
```

### Étape 3 : Variables d'Environnement

Cliquer **Environment Variables** et ajouter :

```
SURREALDB_URL=wss://cloud.surrealdb.com:443/rpc
SURREALDB_NAMESPACE=lyxal_solution
SURREALDB_DATABASE=main
SURREALDB_USERNAME=your-username
SURREALDB_PASSWORD=your-password
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USERNAME=your-smtp-username
SMTP_PASSWORD=your-smtp-password
```

### Étape 4 : Configuration Régions

**Option A : Auto (Recommandé)**
- Laisser "Auto-scaling" activé
- L'AI choisira les meilleures régions

**Option B : Manuel**
- Désactiver "Auto-scaling"
- Sélectionner les régions manuellement
- Exemple : Paris, New York, Singapore

### Étape 5 : Configuration Réseau (Optionnel)

Si besoin d'un **Anycast IP** (pour TCP/UDP) :
- Activer "Anycast IP"
- Coût : $2/mois
- Obtenir l'IP globale

### Étape 6 : Déployer

1. Cliquer **Deploy**
2. Attendre ~30 secondes
3. ✅ Application déployée !

### Étape 7 : Vérifier

```bash
# Tester le health check
curl https://lyxal-mail-worker.b-cdn.net/health

# Réponse attendue
{"status":"ok","service":"lyxal-mail-worker"}
```

---

## 🤖 Méthode 2 : Déploiement CI/CD (GitHub Actions)

### Étape 1 : Préparer le Repo

```bash
# Structure du repo
my-service/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── Dockerfile
├── package.json (ou go.mod, etc.)
└── src/
```

### Étape 2 : Créer le Workflow

**.github/workflows/deploy.yml**

```yaml
name: Deploy to Magic Containers

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Build and Push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            lyxal/my-service:latest
            lyxal/my-service:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
      
      - name: Deploy to Magic Containers
        run: |
          curl -X POST "https://api.bunny.net/containers/${{ secrets.BUNNY_CONTAINER_ID }}/deploy" \
            -H "AccessKey: ${{ secrets.BUNNY_API_KEY }}" \
            -H "Content-Type: application/json" \
            -d '{
              "image": "lyxal/my-service:${{ github.sha }}"
            }'
      
      - name: Wait for Deployment
        run: sleep 30
      
      - name: Health Check
        run: |
          curl -f https://my-service.b-cdn.net/health || exit 1
      
      - name: Notify Success
        if: success()
        run: |
          echo "✅ Deployment successful!"
```

### Étape 3 : Configurer les Secrets GitHub

Dans votre repo GitHub :
1. **Settings** → **Secrets and variables** → **Actions**
2. Ajouter les secrets :
   - `DOCKERHUB_USERNAME`
   - `DOCKERHUB_TOKEN`
   - `BUNNY_API_KEY`
   - `BUNNY_CONTAINER_ID`

### Étape 4 : Push et Deploy

```bash
git add .
git commit -m "Add CI/CD workflow"
git push origin main

# GitHub Actions se déclenche automatiquement
# Suivre les logs sur GitHub → Actions
```

---

## 🐳 Méthode 3 : Déploiement Local (Test)

### Tester Localement Avant Deploy

```bash
# 1. Build l'image
docker build -t lyxal-mail-worker:local .

# 2. Run localement
docker run -p 3000:3000 \
  -e SURREALDB_URL=wss://cloud.surrealdb.com:443/rpc \
  -e SMTP_HOST=smtp.example.com \
  lyxal-mail-worker:local

# 3. Tester
curl http://localhost:3000/health

# 4. Si OK, push sur Docker Hub
docker tag lyxal-mail-worker:local lyxal/mail-worker:latest
docker push lyxal/mail-worker:latest

# 5. Déployer sur Magic Containers (Dashboard ou API)
```

---

## 📊 Monitoring Post-Déploiement

### Dashboard Bunny

1. Aller sur https://panel.bunny.net
2. Menu **Magic Containers**
3. Sélectionner votre application

**Métriques Disponibles** :
- Requêtes par minute
- Latence moyenne/P95
- Utilisation CPU/RAM
- Régions actives
- Taux d'erreur

### Real-Time Logs

```
[2025-01-24 10:15:32] INFO: Service started
[2025-01-24 10:15:35] INFO: Connected to SurrealDB
[2025-01-24 10:15:38] INFO: Email sent (id: 123)
```

**Filtres disponibles** :
- Par niveau (INFO, WARN, ERROR)
- Par période (Last 1h, 24h, 7d)
- Recherche full-text

### Health Checks

Magic Containers ping votre endpoint `/health` toutes les **30 secondes**.

Si 3 checks échouent consécutivement :
- ⚠️ Container marqué "unhealthy"
- 🔄 Auto-restart du container
- 📧 Notification par email (si configuré)

---

## 🔧 Configuration Avancée

### Custom Domain

1. Dans Dashboard → Application → Settings
2. **Custom Domain** : `api.lyxal.com`
3. Ajouter un CNAME dans votre DNS :
   ```
   api.lyxal.com CNAME lyxal-mail-worker.b-cdn.net
   ```
4. SSL automatiquement provisionné (Let's Encrypt)

### Health Check Personnalisé

```yaml
Health Check:
  Path: /health
  Interval: 30s
  Timeout: 5s
  Unhealthy Threshold: 3
  Healthy Threshold: 2
```

### Resource Limits

```yaml
Resources:
  CPU: 0.1 - 2.0 vCPU (auto-scale)
  RAM: 128 MB - 4 GB (auto-scale)
  Storage: 10 GB max (éphémère)
```

### Auto-Scaling Rules

```yaml
Scaling:
  Min Pods: 1
  Max Pods: 10
  Target CPU: 70%
  Target RAM: 80%
  Scale Up: +1 pod si > 80% pendant 2 min
  Scale Down: -1 pod si < 30% pendant 5 min
```

---

## 🔄 Blue-Green Deployment

### Stratégie Zero-Downtime

```yaml
# .github/workflows/deploy-blue-green.yml
name: Blue-Green Deployment

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Build New Version (Green)
        run: |
          docker build -t lyxal/service:${{ github.sha }} .
          docker push lyxal/service:${{ github.sha }}
      
      - name: Deploy Green
        run: |
          # Créer nouvelle instance "green"
          curl -X POST "https://api.bunny.net/containers" \
            -H "AccessKey: ${{ secrets.BUNNY_API_KEY }}" \
            -d '{
              "name": "lyxal-service-green",
              "image": "lyxal/service:${{ github.sha }}"
            }'
      
      - name: Wait for Green to be Healthy
        run: |
          for i in {1..10}; do
            curl -f https://lyxal-service-green.b-cdn.net/health && break
            sleep 10
          done
      
      - name: Switch Traffic to Green
        run: |
          # Changer le DNS/routing vers green
          # Détails via API Bunny
      
      - name: Destroy Blue
        run: |
          # Supprimer l'ancienne instance après 5 min
          sleep 300
          curl -X DELETE "https://api.bunny.net/containers/lyxal-service-blue" \
            -H "AccessKey: ${{ secrets.BUNNY_API_KEY }}"
```

---

## 🛡️ Rollback

### Rollback Automatique

Si le health check échoue après deploy :

```yaml
- name: Deploy with Auto-Rollback
  run: |
    # Deploy nouvelle version
    curl -X POST "https://api.bunny.net/containers/deploy" \
      -d '{"image": "lyxal/service:new"}'
    
    # Wait et test
    sleep 30
    if ! curl -f https://service.b-cdn.net/health; then
      echo "Health check failed, rolling back..."
      curl -X POST "https://api.bunny.net/containers/deploy" \
        -d '{"image": "lyxal/service:previous"}'
      exit 1
    fi
```

### Rollback Manuel

Dans Dashboard :
1. Application → **Versions**
2. Sélectionner la version précédente
3. Cliquer **Rollback**
4. Confirmation en ~10 secondes

---

## 📈 Scaling Manual

### Augmenter les Ressources

```bash
# Via API Bunny
curl -X PATCH "https://api.bunny.net/containers/my-app" \
  -H "AccessKey: $BUNNY_API_KEY" \
  -d '{
    "resources": {
      "cpu_min": 0.5,
      "cpu_max": 2.0,
      "ram_min": 512,
      "ram_max": 2048
    }
  }'
```

### Forcer une Région

```bash
# Activer spécifiquement Paris et NY
curl -X PATCH "https://api.bunny.net/containers/my-app" \
  -d '{
    "regions": ["paris", "new-york"],
    "auto_scale": false
  }'
```

---

## 🐛 Debugging

### Logs en Temps Réel

```bash
# Via Dashboard → Application → Logs
# Ou via API (bientôt)
```

### SSH dans le Container (Debug Mode)

```bash
# Activer debug mode dans Dashboard
# Puis :
ssh debug@lyxal-service.b-cdn.net -p 2222

# Explorer
ps aux
df -h
cat /app/logs/error.log
```

### Test de Charge

```bash
# Installer k6
brew install k6

# Script de test
cat > load-test.js << EOF
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 },
    { duration: '5m', target: 100 },
    { duration: '2m', target: 0 },
  ],
};

export default function () {
  let res = http.get('https://service.b-cdn.net/health');
  check(res, { 'status was 200': (r) => r.status == 200 });
  sleep(1);
}
EOF

# Lancer
k6 run load-test.js
```

---

## ✅ Checklist de Déploiement

### Avant le Premier Deploy

- [ ] Dockerfile optimisé (multi-stage, Alpine)
- [ ] Health check endpoint `/health` implémenté
- [ ] Logs structurés (JSON)
- [ ] Graceful shutdown (SIGTERM)
- [ ] Variables d'environnement documentées
- [ ] Tests unitaires passent
- [ ] Image testée localement

### Premier Deploy

- [ ] Compte Bunny.net créé
- [ ] Docker Hub configuré
- [ ] Image pushed sur Docker Hub
- [ ] Application créée sur Magic Containers
- [ ] Variables d'environnement configurées
- [ ] Health check fonctionne
- [ ] Logs visibles dans Dashboard
- [ ] Custom domain configuré (optionnel)

### CI/CD Setup

- [ ] GitHub Actions workflow créé
- [ ] Secrets GitHub configurés
- [ ] Build et push automatiques
- [ ] Deploy automatique sur main
- [ ] Notifications configurées

### Post-Deploy

- [ ] Monitoring actif
- [ ] Alertes configurées (roadmap)
- [ ] Documentation à jour
- [ ] Équipe informée

---

## 💡 Conseils Pro

### 1. Toujours Tester Localement d'Abord

```bash
# Build → Run → Test → Push
docker-compose up
curl http://localhost:3000/health
# Si OK, deploy
```

### 2. Utiliser des Tags de Version

```bash
# Mauvais
docker tag app:latest

# Bon
docker tag app:v1.2.3
docker tag app:$GIT_SHA
```

### 3. Monitorer les Coûts

Dashboard → **Billing** → Voir la consommation en temps réel

### 4. Documenter les Env Vars

```
# .env.example
SURREALDB_URL=wss://cloud.surrealdb.com:443/rpc
SMTP_HOST=smtp.example.com
# etc.
```

### 5. Prévoir un Rollback Plan

Toujours garder au moins 2 versions déployables.

---

## 📞 Support

**Problèmes de déploiement ?**

1. Vérifier les logs (Dashboard → Logs)
2. Tester le health check : `curl https://app.b-cdn.net/health`
3. Vérifier les variables d'environnement
4. Contacter support Bunny : support@bunny.net
5. Discord Bunny : https://discord.gg/bunnynet

---

## 🚀 Prochaines Étapes

1. **[PRICING.md](./PRICING.md)** → Calculer vos coûts précis
2. Déployer votre premier service !
3. Configurer le monitoring
4. Automatiser avec CI/CD

---

**Magic Containers : Deploy en 5 Minutes, Scale à l'Infini** 🎩🚀

