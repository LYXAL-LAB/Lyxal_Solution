import React from 'react';
import { clsx } from 'clsx';
import { Button } from '../components/Button/Button';
import { Input } from '../components/Input/Input';
import { Loader } from '../components/Loader/Loader';
import './LoginPage.css';
import { useTheme } from '../theme/hooks/useTheme';

export interface LoginPageProps {
  /** Titre de la page */
  title?: string;
  /** Sous-titre ou description */
  subtitle?: string;
  /** Logo à afficher */
  logo?: React.ReactNode;
  /** Fonction appelée lors de la soumission */
  onSubmit?: (credentials: { email: string; password: string }) => void | Promise<void>;
  /** URL de redirection après connexion */
  redirectAfterLogin?: string;
  /** État de chargement */
  loading?: boolean;
  /** Message d'erreur */
  error?: string;
  /** Lien vers la page d'inscription */
  signupLink?: string;
  /** Lien vers la récupération de mot de passe */
  forgotPasswordLink?: string;
  /** Classe CSS personnalisée */
  className?: string;
  /** Contenu personnalisé du footer */
  footer?: React.ReactNode;
}

/**
 * Page de connexion prête à l'emploi
 */
export function LoginPage({
  title = 'Connexion',
  subtitle = 'Connectez-vous à votre compte',
  logo,
  onSubmit,
  redirectAfterLogin,
  loading = false,
  error,
  signupLink,
  forgotPasswordLink,
  className,
  footer,
}: LoginPageProps) {
  const { currentTheme: theme } = useTheme();
  const [formData, setFormData] = React.useState({
    email: '',
    password: '',
  });
  const [formErrors, setFormErrors] = React.useState<{
    email?: string;
    password?: string;
  }>({});

  // Validation du formulaire
  const validateForm = React.useCallback(() => {
    const errors: typeof formErrors = {};

    if (!formData.email) {
      errors.email = 'L\'email est requis';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      errors.email = 'Format d\'email invalide';
    }

    if (!formData.password) {
      errors.password = 'Le mot de passe est requis';
    } else if (formData.password.length < 6) {
      errors.password = 'Le mot de passe doit contenir au moins 6 caractères';
    }

    setFormErrors(errors);
    return Object.keys(errors).length === 0;
  }, [formData]);

  // Gestion de la soumission
  const handleSubmit = React.useCallback(
    async (event: React.FormEvent) => {
      event.preventDefault();
      
      if (!validateForm() || loading) {
        return;
      }

      try {
        await onSubmit?.(formData);
        
        // Redirection si spécifiée
        if (redirectAfterLogin) {
          window.location.href = redirectAfterLogin;
        }
      } catch (err) {
        // L'erreur sera gérée par le composant parent
        console.error('Erreur de connexion:', err);
      }
    },
    [formData, validateForm, loading, onSubmit, redirectAfterLogin]
  );

  // Gestion des changements de champs
  const handleInputChange = React.useCallback(
    (field: keyof typeof formData) => (event: React.ChangeEvent<HTMLInputElement>) => {
      setFormData(prev => ({
        ...prev,
        [field]: event.target.value,
      }));
      
      // Effacer l'erreur du champ modifié
      if (formErrors[field]) {
        setFormErrors(prev => ({
          ...prev,
          [field]: undefined,
        }));
      }
    },
    [formErrors]
  );

  return (
    <div className={clsx('login-page', className)} style={{ backgroundColor: 'var(--color-base-100)' }}>
      <div className="login-container">
        <div className="login-card" style={{ backgroundColor: 'var(--color-base-200)', borderColor: 'var(--color-base-300)' }}>
          {/* Header */}
          <div className="login-header">
            {logo && <div className="login-logo">{logo}</div>}
            <h1 className="login-title" style={{ color: 'var(--color-base-content)' }}>{title}</h1>
            {subtitle && <p className="login-subtitle" style={{ color: 'var(--color-base-content-secondary)' }}>{subtitle}</p>}
          </div>

          {/* Formulaire */}
          <form className="login-form" onSubmit={handleSubmit}>
            {error && (
              <div className="login-error" style={{ backgroundColor: 'var(--color-error-light)', borderColor: 'var(--color-error)', color: 'var(--color-error-dark)' }}>
                {error}
              </div>
            )}

            <Input
              label="Email"
              type="email"
              value={formData.email}
              onChange={handleInputChange('email')}
              error={formErrors.email}
              placeholder="votre@email.com"
              disabled={loading}
              fullWidth
              icon={
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
                </svg>
              }
            />

            <Input
              label="Mot de passe"
              type="password"
              value={formData.password}
              onChange={handleInputChange('password')}
              error={formErrors.password}
              placeholder="••••••••"
              disabled={loading}
              fullWidth
              icon={
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
              }
            />

            <Button
              type="submit"
              variant="primary"
              size="lg"
              fullWidth
              loading={loading}
              disabled={loading}
            >
              {loading ? 'Connexion...' : 'Se connecter'}
            </Button>
          </form>

          {/* Liens */}
          <div className="login-links">
            {forgotPasswordLink && (
              <a href={forgotPasswordLink} className="login-link" style={{ color: 'var(--color-primary)' }}>
                Mot de passe oublié ?
              </a>
            )}
            {signupLink && (
              <a href={signupLink} className="login-link" style={{ color: 'var(--color-primary)' }}>
                Créer un compte
              </a>
            )}
          </div>

          {/* Footer personnalisé */}
          {footer && (
            <div className="login-footer" style={{ borderColor: 'var(--color-base-300)' }}>
              {footer}
            </div>
          )}
        </div>
      </div>

      {/* Loader plein écran si nécessaire */}
      {loading && (
        <Loader
          variant="spinner"
          size="lg"
          color="primary"
          label="Connexion en cours..."
          fullScreen
        />
      )}
    </div>
  );
}