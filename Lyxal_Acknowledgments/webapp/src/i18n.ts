import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

// Import translations directly or load them via http-backend
// For simplicity in this V1, we'll define them here or import JSONs if possible
// Since we have locales in backend/locales, we could symlink or copy them.
// For now, let's define basic en/fr structure.

const resources = {
    en: {
        translation: {
            "common.loading": "Loading...",
            "common.error": "An error occurred",
            "auth.login": "Login",
            "auth.magic_link": "Sign in with Magic Link",
            "auth.oauth": "Sign in with OAuth",
            "home.title": "Lyxal Acknowledgments",
            "home.subtitle": "Secure document signing and acknowledgment",
            "home.cta": "Sign a Document",
        }
    },
    fr: {
        translation: {
            "common.loading": "Chargement...",
            "common.error": "Une erreur est survenue",
            "auth.login": "Connexion",
            "auth.magic_link": "Connexion via Lien Magique",
            "auth.oauth": "Connexion via OAuth",
            "home.title": "Lyxal Acknowledgments",
            "home.subtitle": "Signature et accusé de réception sécurisés",
            "home.cta": "Signer un document",
        }
    }
};

i18n
    .use(initReactI18next)
    .init({
        resources,
        lng: "fr", // Default to French as per user preference
        fallbackLng: "en",
        interpolation: {
            escapeValue: false
        }
    });

export default i18n;
