/**
 * tailwind-theme-system.ts - Plugin Tailwind personnalisé pour système de thèmes
 * Définit les variables CSS, composants de base et utilitaires
 */
import plugin from 'tailwindcss/plugin';
// ============= THÈMES PRÉDÉFINIS =============
const themes = {
    light: {
        // Couleurs sémantiques
        '--color-primary': '59 130 246', // RGB de #3b82f6
        '--color-primary-focus': '37 99 235',
        '--color-primary-content': '255 255 255',
        '--color-secondary': '16 185 129',
        '--color-secondary-focus': '5 150 105',
        '--color-secondary-content': '255 255 255',
        '--color-accent': '245 158 11',
        '--color-accent-focus': '217 119 6',
        '--color-accent-content': '255 255 255',
        '--color-neutral': '31 41 55',
        '--color-neutral-focus': '17 24 39',
        '--color-neutral-content': '255 255 255',
        // Couleurs de fond
        '--color-base-100': '255 255 255',
        '--color-base-200': '249 250 251',
        '--color-base-300': '243 244 246',
        '--color-base-content': '31 41 55',
        // États
        '--color-info': '14 165 233',
        '--color-success': '34 197 94',
        '--color-warning': '249 115 22',
        '--color-error': '239 68 68',
        // Design tokens
        '--rounded-box': '1rem',
        '--rounded-btn': '0.5rem',
        '--rounded-badge': '1.9rem',
        '--animation-btn': '0.25s',
        '--animation-input': '0.2s',
        '--btn-focus-scale': '0.95',
        '--border-btn': '1px',
        '--tab-border': '1px',
        '--tab-radius': '0.5rem',
    },
    dark: {
        '--color-primary': '96 165 250',
        '--color-primary-focus': '59 130 246',
        '--color-primary-content': '30 58 138',
        '--color-secondary': '52 211 153',
        '--color-secondary-focus': '16 185 129',
        '--color-secondary-content': '6 78 59',
        '--color-accent': '251 191 36',
        '--color-accent-focus': '245 158 11',
        '--color-accent-content': '120 53 15',
        '--color-neutral': '229 231 235',
        '--color-neutral-focus': '243 244 246',
        '--color-neutral-content': '17 24 39',
        '--color-base-100': '17 24 39',
        '--color-base-200': '31 41 55',
        '--color-base-300': '55 65 81',
        '--color-base-content': '229 231 235',
        '--color-info': '56 189 248',
        '--color-success': '74 222 128',
        '--color-warning': '251 146 60',
        '--color-error': '248 113 113',
        '--rounded-box': '1rem',
        '--rounded-btn': '0.5rem',
        '--rounded-badge': '1.9rem',
        '--animation-btn': '0.25s',
        '--animation-input': '0.2s',
        '--btn-focus-scale': '0.95',
        '--border-btn': '1px',
        '--tab-border': '1px',
        '--tab-radius': '0.5rem',
    },
    ocean: {
        '--color-primary': '6 182 212',
        '--color-primary-focus': '8 145 178',
        '--color-primary-content': '255 255 255',
        '--color-secondary': '14 116 144',
        '--color-secondary-focus': '22 78 99',
        '--color-secondary-content': '255 255 255',
        '--color-accent': '34 211 238',
        '--color-accent-focus': '6 182 212',
        '--color-accent-content': '8 51 68',
        '--color-neutral': '30 58 138',
        '--color-neutral-focus': '23 37 84',
        '--color-neutral-content': '255 255 255',
        '--color-base-100': '240 249 255',
        '--color-base-200': '224 242 254',
        '--color-base-300': '186 230 253',
        '--color-base-content': '12 74 110',
        '--color-info': '14 165 233',
        '--color-success': '5 150 105',
        '--color-warning': '234 179 8',
        '--color-error': '220 38 38',
        '--rounded-box': '1rem',
        '--rounded-btn': '0.5rem',
        '--rounded-badge': '1.9rem',
        '--animation-btn': '0.25s',
        '--animation-input': '0.2s',
        '--btn-focus-scale': '0.95',
        '--border-btn': '1px',
        '--tab-border': '1px',
        '--tab-radius': '0.5rem',
    },
};
// ============= PLUGIN =============
const themeSystem = plugin(function ({ addBase, addComponents, addUtilities }) {
    // 1. Générer les styles de base pour chaque thème
    const themeStyles = {};
    Object.keys(themes).forEach(themeName => {
        const selector = themeName === 'light' ? ':root' : `[data-theme="${themeName}"]`;
        themeStyles[selector] = themes[themeName];
    });
    addBase(themeStyles);
    // 2. Composants de base
    addComponents({
        // ============= BOUTONS =============
        '.btn': {
            display: 'inline-flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '0.5rem',
            padding: '0.5rem 1rem',
            fontSize: '0.875rem',
            fontWeight: '600',
            lineHeight: '1.25rem',
            textAlign: 'center',
            textDecoration: 'none',
            transition: `all var(--animation-btn) ease-in-out`,
            border: 'var(--border-btn) solid transparent',
            borderRadius: 'var(--rounded-btn)',
            cursor: 'pointer',
            userSelect: 'none',
            '&:active': {
                transform: 'scale(var(--btn-focus-scale))',
            },
            '&:disabled': {
                opacity: '0.6',
                cursor: 'not-allowed',
            },
        },
        '.btn-primary': {
            backgroundColor: 'rgb(var(--color-primary))',
            color: 'rgb(var(--color-primary-content))',
            '&:hover': {
                backgroundColor: 'rgb(var(--color-primary-focus))',
            },
        },
        '.btn-secondary': {
            backgroundColor: 'rgb(var(--color-secondary))',
            color: 'rgb(var(--color-secondary-content))',
            '&:hover': {
                backgroundColor: 'rgb(var(--color-secondary-focus))',
            },
        },
        '.btn-accent': {
            backgroundColor: 'rgb(var(--color-accent))',
            color: 'rgb(var(--color-accent-content))',
            '&:hover': {
                backgroundColor: 'rgb(var(--color-accent-focus))',
            },
        },
        '.btn-neutral': {
            backgroundColor: 'rgb(var(--color-neutral))',
            color: 'rgb(var(--color-neutral-content))',
            '&:hover': {
                backgroundColor: 'rgb(var(--color-neutral-focus))',
            },
        },
        '.btn-info': {
            backgroundColor: 'rgb(var(--color-info))',
            color: 'rgb(var(--color-base-100))',
            '&:hover': {
                backgroundColor: 'rgb(var(--color-info) / 0.8)',
            },
        },
        '.btn-ghost': {
            backgroundColor: 'transparent',
            color: 'rgb(var(--color-base-content))',
            '&:hover': {
                backgroundColor: 'rgb(var(--color-base-200))',
            },
        },
        '.btn-outline': {
            backgroundColor: 'transparent',
            borderColor: 'currentColor',
            '&:hover': {
                backgroundColor: 'rgb(var(--color-primary))',
                color: 'rgb(var(--color-primary-content))',
                borderColor: 'rgb(var(--color-primary))',
            },
        },
        // ============= TAILLES DE BOUTONS (AJOUT) =============
        '.btn-xs': {
            padding: '0.25rem 0.5rem',
            fontSize: '0.75rem',
            lineHeight: '1rem',
        },
        '.btn-sm': {
            padding: '0.375rem 0.75rem',
            fontSize: '0.875rem',
            lineHeight: '1.25rem',
        },
        '.btn-lg': {
            padding: '0.75rem 1.5rem',
            fontSize: '1rem',
            lineHeight: '1.5rem',
        },
        '.btn-xl': {
            padding: '1rem 2rem',
            fontSize: '1.125rem',
            lineHeight: '1.75rem',
        },
        // ============= VARIANTS AVANCÉS (AJOUT) =============
        '.btn-gradient': {
            backgroundImage: 'linear-gradient(to right, rgb(var(--color-primary)), rgb(var(--color-accent)))',
            color: 'rgb(var(--color-primary-content))',
            border: 'none',
            '&:hover': {
                opacity: '0.9',
            },
        },
        '.btn-neon': {
            backgroundColor: 'rgb(var(--color-primary))',
            color: 'rgb(var(--color-primary-content))',
            boxShadow: '0 0 10px rgba(var(--color-primary), 0.5)',
            '&:hover': {
                boxShadow: '0 0 20px rgba(var(--color-primary), 0.8)',
            },
        },
        '.btn-glass': {
            backgroundColor: 'rgba(255, 255, 255, 0.2)',
            backdropFilter: 'blur(10px)',
            border: '1px solid rgba(255, 255, 255, 0.3)',
            color: 'rgb(var(--color-base-content))',
            '&:hover': {
                backgroundColor: 'rgba(255, 255, 255, 0.3)',
            },
        },
        '.btn-3d': {
            boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
            '&:hover': {
                transform: 'translateY(-2px)',
                boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
            },
            '&:active': {
                transform: 'translateY(0)',
                boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
            },
        },
        // ============= ÉTATS SPÉCIAUX (AJOUT) =============
        '.btn-loading': {
            pointerEvents: 'none',
            position: 'relative',
            '&::before': {
                content: '""',
                display: 'inline-block',
                width: '1rem',
                height: '1rem',
                marginRight: '0.5rem',
                border: '2px solid currentColor',
                borderRightColor: 'transparent',
                borderRadius: '50%',
                animation: 'spin 0.6s linear infinite',
            },
        },
        '.btn-success': {
            backgroundColor: 'rgb(var(--color-success))',
            color: 'white',
            '&:hover': {
                opacity: '0.9',
            },
        },
        '.btn-warning': {
            backgroundColor: 'rgb(var(--color-warning))',
            color: 'rgb(var(--color-base-100))',
            '&:hover': {
                opacity: '0.9',
            },
        },
        '.btn-error': {
            backgroundColor: 'rgb(var(--color-error))',
            color: 'white',
            '&:hover': {
                opacity: '0.9',
            },
        },
        // ============= CARTES =============
        '.card': {
            position: 'relative',
            display: 'flex',
            flexDirection: 'column',
            borderRadius: 'var(--rounded-box)',
            backgroundColor: 'rgb(var(--color-base-100))',
            overflow: 'hidden',
        },
        '.card-body': {
            padding: '1.5rem',
            flex: '1 1 auto',
        },
        '.card-title': {
            fontSize: '1.25rem',
            fontWeight: '700',
            marginBottom: '0.5rem',
            color: 'rgb(var(--color-base-content))',
        },
        '.card-bordered': {
            border: '1px solid rgb(var(--color-base-300))',
        },
        // ============= INPUTS =============
        '.input': {
            display: 'flex',
            alignItems: 'center',
            height: '3rem',
            padding: '0.5rem 1rem',
            fontSize: '0.875rem',
            lineHeight: '1.25rem',
            borderRadius: 'var(--rounded-btn)',
            border: '1px solid rgb(var(--color-base-300))',
            backgroundColor: 'rgb(var(--color-base-100))',
            transition: `all var(--animation-input) ease-in-out`,
            '&:focus': {
                outline: 'none',
                borderColor: 'rgb(var(--color-primary))',
                boxShadow: '0 0 0 3px rgba(var(--color-primary), 0.1)',
            },
        },
        '.input-bordered': {
            borderWidth: '2px',
        },
        '.input-primary': {
            borderColor: 'rgb(var(--color-primary))',
            '&:focus': {
                borderColor: 'rgb(var(--color-primary-focus))',
            },
        },
        // ============= TOGGLE/SWITCH (AJOUT) =============
        '.toggle': {
            position: 'relative',
            display: 'inline-block',
            width: '3rem',
            height: '1.5rem',
            appearance: 'none',
            borderRadius: '9999px',
            backgroundColor: 'rgb(var(--color-base-300))',
            cursor: 'pointer',
            transition: 'background-color 0.2s',
            '&:checked': {
                backgroundColor: 'rgb(var(--color-primary))',
            },
            '&::after': {
                content: '""',
                position: 'absolute',
                top: '0.125rem',
                left: '0.125rem',
                width: '1.25rem',
                height: '1.25rem',
                borderRadius: '50%',
                backgroundColor: 'white',
                boxShadow: '0 2px 4px rgba(0,0,0,0.2)',
                transition: 'transform 0.2s',
            },
            '&:checked::after': {
                transform: 'translateX(1.5rem)',
            },
        },
        '.toggle-sm': {
            width: '2rem',
            height: '1rem',
            '&::after': {
                width: '0.75rem',
                height: '0.75rem',
            },
            '&:checked::after': {
                transform: 'translateX(1rem)',
            },
        },
        '.toggle-lg': {
            width: '4rem',
            height: '2rem',
            '&::after': {
                width: '1.75rem',
                height: '1.75rem',
            },
            '&:checked::after': {
                transform: 'translateX(2rem)',
            },
        },
        // ============= PROGRESS (AJOUT) =============
        '.progress': {
            height: '0.5rem',
            width: '100%',
            overflow: 'hidden',
            borderRadius: 'var(--rounded-badge)',
            backgroundColor: 'rgb(var(--color-base-300))',
            position: 'relative',
        },
        '.progress-primary': {
            '& > *': {
                backgroundColor: 'rgb(var(--color-primary))',
            },
        },
        '.progress-secondary': {
            '& > *': {
                backgroundColor: 'rgb(var(--color-secondary))',
            },
        },
        '.progress-success': {
            '& > *': {
                backgroundColor: 'rgb(var(--color-success))',
            },
        },
        // ============= BADGE =============
        '.badge': {
            display: 'inline-flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '0.25rem 0.75rem',
            fontSize: '0.75rem',
            fontWeight: '600',
            lineHeight: '1rem',
            borderRadius: 'var(--rounded-badge)',
            backgroundColor: 'rgb(var(--color-base-200))',
            color: 'rgb(var(--color-base-content))',
        },
        '.badge-primary': {
            backgroundColor: 'rgb(var(--color-primary))',
            color: 'rgb(var(--color-primary-content))',
        },
        '.badge-secondary': {
            backgroundColor: 'rgb(var(--color-secondary))',
            color: 'rgb(var(--color-secondary-content))',
        },
        '.badge-outline': {
            backgroundColor: 'transparent',
            border: '1px solid currentColor',
        },
        '.badge-lg': {
            padding: '0.375rem 1rem',
            fontSize: '0.875rem',
        },
        // ============= ALERT =============
        '.alert': {
            display: 'flex',
            alignItems: 'center',
            gap: '1rem',
            padding: '1rem',
            borderRadius: 'var(--rounded-box)',
            backgroundColor: 'rgb(var(--color-base-200))',
            color: 'rgb(var(--color-base-content))',
        },
        '.alert-info': {
            backgroundColor: 'rgb(var(--color-info) / 0.1)',
            color: 'rgb(var(--color-info))',
        },
        '.alert-success': {
            backgroundColor: 'rgb(var(--color-success) / 0.1)',
            color: 'rgb(var(--color-success))',
        },
        '.alert-warning': {
            backgroundColor: 'rgb(var(--color-warning) / 0.1)',
            color: 'rgb(var(--color-warning))',
        },
        '.alert-error': {
            backgroundColor: 'rgb(var(--color-error) / 0.1)',
            color: 'rgb(var(--color-error))',
        },
        // ============= MODAL =============
        '.modal': {
            position: 'fixed',
            inset: '0',
            zIndex: '999',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            backgroundColor: 'rgba(0, 0, 0, 0.5)',
            opacity: '0',
            pointerEvents: 'none',
            transition: 'opacity 0.2s ease-in-out',
            '&.modal-open': {
                opacity: '1',
                pointerEvents: 'auto',
            },
        },
        '.modal-box': {
            maxWidth: '32rem',
            padding: '1.5rem',
            borderRadius: 'var(--rounded-box)',
            backgroundColor: 'rgb(var(--color-base-100))',
            boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
        },
    });
    // 3. Utilitaires pour les couleurs
    addUtilities({
        // Backgrounds
        '.bg-primary': {
            backgroundColor: 'rgb(var(--color-primary))',
        },
        '.bg-primary-focus': {
            backgroundColor: 'rgb(var(--color-primary-focus))',
        },
        '.bg-secondary': {
            backgroundColor: 'rgb(var(--color-secondary))',
        },
        '.bg-accent': {
            backgroundColor: 'rgb(var(--color-accent))',
        },
        '.bg-base-100': {
            backgroundColor: 'rgb(var(--color-base-100))',
        },
        '.bg-base-200': {
            backgroundColor: 'rgb(var(--color-base-200))',
        },
        '.bg-base-300': {
            backgroundColor: 'rgb(var(--color-base-300))',
        },
        // Textes
        '.text-primary': {
            color: 'rgb(var(--color-primary))',
        },
        '.text-primary-content': {
            color: 'rgb(var(--color-primary-content))',
        },
        '.text-secondary': {
            color: 'rgb(var(--color-secondary))',
        },
        '.text-accent': {
            color: 'rgb(var(--color-accent))',
        },
        '.text-base-content': {
            color: 'rgb(var(--color-base-content))',
        },
        // Bordures
        '.border-primary': {
            borderColor: 'rgb(var(--color-primary))',
        },
        '.border-secondary': {
            borderColor: 'rgb(var(--color-secondary))',
        },
        '.border-accent': {
            borderColor: 'rgb(var(--color-accent))',
        },
        '.border-base-300': {
            borderColor: 'rgb(var(--color-base-300))',
        },
    });
});
export default themeSystem;
