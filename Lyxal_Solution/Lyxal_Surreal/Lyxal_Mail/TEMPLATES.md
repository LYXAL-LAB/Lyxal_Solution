# 📧 Templates - Lyxal Mail

Ce document explique le système de templates multilingues de Lyxal Mail.

---

## 🎯 Concept

Les templates Lyxal Mail sont :
- **Multilingues** : Support FR, EN, ES, DE, IT (extensible)
- **Variables dynamiques** : `{{variable}}` remplacées à l'envoi
- **Versionnés** : Historique des modifications
- **Testables** : Preview avant envoi

---

## 📋 Structure d'un Template

### Exemple Complet

```json
{
  "id": "email_template:verification_email",
  "code": "verification_email",
  "name": {
    "fr": "Email de vérification",
    "en": "Verification Email",
    "es": "Correo de verificación",
    "de": "Bestätigungs-E-Mail",
    "it": "Email di verifica"
  },
  "description": {
    "fr": "Email envoyé lors de l'inscription pour vérifier l'adresse email",
    "en": "Email sent during signup to verify email address"
  },
  "subject": {
    "fr": "Vérifiez votre adresse email - Lyxal",
    "en": "Verify your email address - Lyxal",
    "es": "Verifique su dirección de correo - Lyxal",
    "de": "Bestätigen Sie Ihre E-Mail-Adresse - Lyxal",
    "it": "Verifica il tuo indirizzo email - Lyxal"
  },
  "body_html": {
    "fr": "...",
    "en": "..."
  },
  "body_text": {
    "fr": "...",
    "en": "..."
  },
  "variables": ["first_name", "last_name", "verification_link"],
  "from_name": "Lyxal",
  "category": "transactional",
  "active": true
}
```

---

## 📝 Templates Essentiels

### 1. Email de Vérification

**Code** : `verification_email`
**Catégorie** : Transactional
**Variables** : `first_name`, `last_name`, `verification_link`

#### Français

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Vérification Email - Lyxal</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
    }
    .header {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 30px;
      text-align: center;
      border-radius: 10px 10px 0 0;
    }
    .content {
      background: #f9f9f9;
      padding: 30px;
      border-radius: 0 0 10px 10px;
    }
    .button {
      display: inline-block;
      padding: 15px 30px;
      background: #667eea;
      color: white;
      text-decoration: none;
      border-radius: 5px;
      font-weight: bold;
      margin: 20px 0;
    }
    .footer {
      text-align: center;
      color: #999;
      font-size: 12px;
      margin-top: 30px;
    }
  </style>
</head>
<body>
  <div class="header">
    <h1>Bienvenue chez Lyxal !</h1>
  </div>
  <div class="content">
    <p>Bonjour {{first_name}} {{last_name}},</p>
    
    <p>Merci de vous être inscrit sur Lyxal. Pour activer votre compte, veuillez cliquer sur le bouton ci-dessous :</p>
    
    <center>
      <a href="{{verification_link}}" class="button">Vérifier mon adresse email</a>
    </center>
    
    <p>Ou copiez/collez ce lien dans votre navigateur :</p>
    <p style="background: #fff; padding: 10px; border-left: 3px solid #667eea; word-break: break-all;">
      {{verification_link}}
    </p>
    
    <p><strong>Ce lien expire dans 24 heures.</strong></p>
    
    <p>Si vous n'avez pas créé de compte Lyxal, vous pouvez ignorer cet email.</p>
    
    <p>À bientôt,<br>L'équipe Lyxal</p>
  </div>
  <div class="footer">
    <p>© 2025 Lyxal. Tous droits réservés.</p>
    <p>Cet email a été envoyé à {{first_name}} {{last_name}}</p>
  </div>
</body>
</html>
```

#### English

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Email Verification - Lyxal</title>
  <!-- Même CSS que FR -->
</head>
<body>
  <div class="header">
    <h1>Welcome to Lyxal!</h1>
  </div>
  <div class="content">
    <p>Hello {{first_name}} {{last_name}},</p>
    
    <p>Thank you for signing up with Lyxal. To activate your account, please click the button below:</p>
    
    <center>
      <a href="{{verification_link}}" class="button">Verify my email address</a>
    </center>
    
    <p>Or copy/paste this link into your browser:</p>
    <p style="background: #fff; padding: 10px; border-left: 3px solid #667eea; word-break: break-all;">
      {{verification_link}}
    </p>
    
    <p><strong>This link expires in 24 hours.</strong></p>
    
    <p>If you didn't create a Lyxal account, you can safely ignore this email.</p>
    
    <p>See you soon,<br>The Lyxal Team</p>
  </div>
  <div class="footer">
    <p>© 2025 Lyxal. All rights reserved.</p>
    <p>This email was sent to {{first_name}} {{last_name}}</p>
  </div>
</body>
</html>
```

### 2. Email de Bienvenue

**Code** : `welcome_email`
**Catégorie** : Transactional
**Variables** : `first_name`

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Bienvenue - Lyxal</title>
</head>
<body>
  <div class="header">
    <h1>Votre compte est activé !</h1>
  </div>
  <div class="content">
    <p>Bonjour {{first_name}},</p>
    
    <p>Votre compte Lyxal est maintenant actif. Vous pouvez commencer à utiliser toutes nos fonctionnalités.</p>
    
    <h2>Pour commencer :</h2>
    <ul>
      <li>Complétez votre profil</li>
      <li>Explorez le tableau de bord</li>
      <li>Invitez votre équipe</li>
    </ul>
    
    <center>
      <a href="https://app.lyxal.com/dashboard" class="button">Accéder à mon compte</a>
    </center>
    
    <p>Besoin d'aide ? Consultez notre <a href="https://help.lyxal.com">centre d'aide</a> ou contactez-nous à <a href="mailto:support@lyxal.com">support@lyxal.com</a>.</p>
    
    <p>Bonne découverte !<br>L'équipe Lyxal</p>
  </div>
</body>
</html>
```

### 3. Mot de Passe Oublié

**Code** : `password_reset`
**Catégorie** : Transactional
**Variables** : `first_name`, `reset_link`

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Réinitialisation mot de passe - Lyxal</title>
</head>
<body>
  <div class="header">
    <h1>Réinitialisation de votre mot de passe</h1>
  </div>
  <div class="content">
    <p>Bonjour {{first_name}},</p>
    
    <p>Vous avez demandé à réinitialiser votre mot de passe Lyxal. Cliquez sur le bouton ci-dessous pour créer un nouveau mot de passe :</p>
    
    <center>
      <a href="{{reset_link}}" class="button">Réinitialiser mon mot de passe</a>
    </center>
    
    <p><strong>Ce lien expire dans 1 heure.</strong></p>
    
    <p><strong>Vous n'avez pas demandé cette réinitialisation ?</strong><br>
    Ignorez cet email. Votre mot de passe actuel reste inchangé.</p>
    
    <p>Pour votre sécurité, ne partagez jamais ce lien.</p>
    
    <p>L'équipe Lyxal</p>
  </div>
</body>
</html>
```

### 4. Notification Générique

**Code** : `notification`
**Catégorie** : Notification
**Variables** : `first_name`, `title`, `message`, `action_link`, `action_text`

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>{{title}} - Lyxal</title>
</head>
<body>
  <div class="header">
    <h1>{{title}}</h1>
  </div>
  <div class="content">
    <p>Bonjour {{first_name}},</p>
    
    <p>{{message}}</p>
    
    <center>
      <a href="{{action_link}}" class="button">{{action_text}}</a>
    </center>
    
    <p>L'équipe Lyxal</p>
  </div>
</body>
</html>
```

---

## 🛠️ Création d'un Nouveau Template

### Étape 1 : Définir le Template

```surql
CREATE email_template:mon_template SET
  code = "mon_template",
  name = {
    fr: "Mon Template",
    en: "My Template"
  },
  description = {
    fr: "Description de mon template",
    en: "My template description"
  },
  subject = {
    fr: "Sujet en français - {{variable}}",
    en: "Subject in English - {{variable}}"
  },
  body_html = {
    fr: "<html>...</html>",
    en: "<html>...</html>"
  },
  body_text = {
    fr: "Version texte...",
    en: "Text version..."
  },
  variables = ["variable1", "variable2"],
  from_name = "Lyxal",
  category = "transactional",
  active = true;
```

### Étape 2 : Tester le Template

```surql
-- Test d'envoi
SELECT fn::send_email(
  'test@example.com',
  'mon_template',
  {
    variable1: 'Valeur 1',
    variable2: 'Valeur 2'
  },
  'fr',
  'lyxal.com',
  NONE
);
```

### Étape 3 : Valider

- ✅ Email reçu
- ✅ Variables remplacées
- ✅ Design correct sur desktop/mobile
- ✅ Liens cliquables
- ✅ Pas d'erreurs

---

## 🎨 Best Practices Design

### 1. Responsive Design

```html
<!-- Viewport meta tag -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- CSS responsive -->
<style>
  @media only screen and (max-width: 600px) {
    .content {
      padding: 15px !important;
    }
    .button {
      display: block !important;
      width: 100% !important;
    }
  }
</style>
```

### 2. Fallback Texte

Toujours fournir une version texte brut :

```
Bonjour {{first_name}},

Merci de vous être inscrit sur Lyxal.

Cliquez sur ce lien pour vérifier votre email :
{{verification_link}}

Ce lien expire dans 24 heures.

L'équipe Lyxal
```

### 3. Dark Mode

```html
<style>
  @media (prefers-color-scheme: dark) {
    body {
      background: #1a1a1a !important;
      color: #ffffff !important;
    }
    .content {
      background: #2d2d2d !important;
    }
  }
</style>
```

### 4. Accessibilité

- Utiliser des couleurs contrastées (ratio 4.5:1 minimum)
- Taille de police ≥ 14px
- Alt text pour les images
- Liens descriptifs

---

## 🔍 Variables Disponibles Globales

Ces variables sont disponibles dans TOUS les templates :

| Variable | Description | Exemple |
|----------|-------------|---------|
| `{{current_year}}` | Année actuelle | 2025 |
| `{{domain}}` | Domaine d'envoi | lyxal.com |
| `{{company_name}}` | Nom de l'entreprise | Lyxal |
| `{{support_email}}` | Email support | support@lyxal.com |
| `{{unsubscribe_link}}` | Lien désabonnement | https://... |

---

## 📊 Analytics

### Tracking d'Ouverture (v1.1)

Ajouter un pixel invisible :

```html
<img src="https://track.lyxal.com/open/{{email_id}}.png" width="1" height="1" alt="" />
```

### Tracking de Clics (v1.1)

Rediriger les liens via un tracker :

```html
<!-- Lien original -->
<a href="{{verification_link}}">Vérifier</a>

<!-- Lien tracké -->
<a href="https://track.lyxal.com/click/{{email_id}}/{{link_id}}?url={{verification_link}}">Vérifier</a>
```

---

## 🚀 Prochaines Étapes

Voir **[DEPLOYMENT.md](./DEPLOYMENT.md)** pour déployer le système complet.

