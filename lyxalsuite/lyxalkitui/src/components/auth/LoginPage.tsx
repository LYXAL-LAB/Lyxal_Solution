import React, { useState } from 'react';

export interface LoginPageProps {
  /**
   * Titre affiché en haut du formulaire
   * @default "LYXAL"
   */
  title?: string;
  /**
   * Sous-titre affiché sous le titre
   * @default "Connectez-vous à votre compte"
   */
  subtitle?: string;
  /**
   * Callback appelé lors de la soumission du formulaire
   */
  onSubmit?: (data: { email: string; password: string; rememberMe: boolean }) => Promise<void> | void;
  /**
   * Callback appelé lors du clic sur "Retour à l'accueil"
   */
  onNavigateHome?: () => void;
  /**
   * Callback appelé lors du clic sur "Mot de passe oublié"
   */
  onForgotPassword?: () => void;
  /**
   * Callback appelé lors du clic sur Google
   */
  onGoogleLogin?: () => void;
  /**
   * Callback appelé lors du clic sur GitHub
   */
  onGitHubLogin?: () => void;
  /**
   * État de chargement externe
   */
  isLoading?: boolean;
  /**
   * Afficher ou masquer les boutons sociaux
   * @default true
   */
  showSocialLogin?: boolean;
  /**
   * Afficher ou masquer le lien "Retour à l'accueil"
   * @default true
   */
  showBackHome?: boolean;
  /**
   * Afficher ou masquer le footer
   * @default true
   */
  showFooter?: boolean;
  /**
   * Texte du footer
   * @default "@LYXAL - 2025"
   */
  footerText?: string;
}

export const LoginPage: React.FC<LoginPageProps> = ({
  title = "LYXAL",
  subtitle = "Connectez-vous à votre compte",
  onSubmit,
  onNavigateHome,
  onForgotPassword,
  onGoogleLogin,
  onGitHubLogin,
  isLoading: externalLoading = false,
  showSocialLogin = true,
  showBackHome = true,
  showFooter = true,
  footerText = "@LYXAL - 2025"
}) => {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    rememberMe: false
  });

  const [internalLoading, setInternalLoading] = useState(false);
  const isLoading = externalLoading || internalLoading;

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (onSubmit) {
      setInternalLoading(true);
      try {
        await onSubmit(formData);
      } catch (error) {
        console.error('Erreur lors de la connexion:', error);
      } finally {
        setInternalLoading(false);
      }
    } else {
      // Comportement par défaut si pas de callback
      setInternalLoading(true);
      setTimeout(() => {
        setInternalLoading(false);
        console.log('Connexion avec:', formData);
      }, 2000);
    }
  };

  const handleBackHome = () => {
    if (onNavigateHome) {
      onNavigateHome();
    } else {
      window.location.href = '/';
    }
  };

  const handleForgotPassword = () => {
    if (onForgotPassword) {
      onForgotPassword();
    } else {
      console.log('Mot de passe oublié');
    }
  };

  return (
    <div id="signin-page" className="min-h-screen bg-base-100">
      {/* Main Content - Hero Layout DaisyUI */}
      <div id="signin-hero" className="hero min-h-screen">
        <div className="hero-content">
          {/* Login Card */}
          <div id="signin-card" className="card shrink-0 w-full max-w-md shadow-2xl bg-base-200">
            <div id="signin-card-body" className="card-body">
              <div id="signin-card-header" className="text-center mb-4">
                <h1 id="signin-card-title" className="text-4xl font-bold text-primary mb-2">{title}</h1>
                <p id="signin-card-subtitle" className="text-sm text-base-content/70">
                  {subtitle}
                </p>
              </div>

              <form id="signin-form" onSubmit={handleSubmit}>
                {/* Email Field */}
                <div id="email-field-container" className="form-control">
                  <label id="email-label" className="label">
                    <span id="email-label-text" className="label-text">Adresse email</span>
                  </label>
                  <input
                    id="email-input"
                    type="email"
                    name="email"
                    value={formData.email}
                    onChange={handleChange}
                    placeholder="votre@email.com"
                    className="input input-bordered w-full"
                    required
                  />
                </div>

                {/* Password Field */}
                <div id="password-field-container" className="form-control">
                  <label id="password-label" className="label">
                    <span id="password-label-text" className="label-text">Mot de passe</span>
                  </label>
                  <input
                    id="password-input"
                    type="password"
                    name="password"
                    value={formData.password}
                    onChange={handleChange}
                    placeholder="••••••••"
                    className="input input-bordered w-full"
                    required
                  />
                  <label id="forgot-password-label" className="label">
                    <button 
                      id="forgot-password-btn"
                      type="button"
                      className="label-text-alt link link-hover"
                      onClick={handleForgotPassword}
                    >
                      Mot de passe oublié ?
                    </button>
                  </label>
                </div>

                {/* Remember Me */}
                <div id="remember-me-container" className="form-control">
                  <label id="remember-me-label" className="label cursor-pointer justify-start">
                    <input
                      id="remember-me-checkbox"
                      type="checkbox"
                      name="rememberMe"
                      checked={formData.rememberMe}
                      onChange={handleChange}
                      className="checkbox checkbox-primary"
                    />
                    <span id="remember-me-text" className="label-text ml-2">Se souvenir de moi</span>
                  </label>
                </div>

                {/* Submit Button */}
                <div id="submit-button-container" className="form-control mt-6">
                  <button
                    id="submit-btn"
                    type="submit"
                    disabled={isLoading}
                    className="btn btn-primary w-full"
                  >
                    {isLoading && <span id="loading-spinner" className="loading loading-spinner loading-sm"></span>}
                    {isLoading ? 'Connexion...' : 'Se connecter'}
                  </button>
                </div>
              </form>

              {/* Social Login */}
              {showSocialLogin && (
                <>
                  {/* Divider */}
                  <div id="signin-divider" className="divider">ou</div>

                  <div id="social-login-container" className="space-y-2">
                    <button 
                      id="google-login-btn" 
                      className="btn btn-outline w-full"
                      onClick={onGoogleLogin}
                      type="button"
                    >
                      <svg id="google-icon" className="w-5 h-5 mr-2" viewBox="0 0 24 24">
                        <path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                        <path fill="currentColor" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                        <path fill="currentColor" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                        <path fill="currentColor" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                      </svg>
                      Continuer avec Google
                    </button>

                    <button 
                      id="github-login-btn" 
                      className="btn btn-outline w-full"
                      onClick={onGitHubLogin}
                      type="button"
                    >
                      <svg id="github-icon" className="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
                      </svg>
                      Continuer avec GitHub
                    </button>
                  </div>
                </>
              )}

              {/* Back to Home Link */}
              {showBackHome && (
                <div id="back-home-link-container" className="text-center mt-4">
                  <button 
                    id="back-home-btn"
                    onClick={handleBackHome}
                    className="link link-primary"
                    type="button"
                  >
                    Retour à l'accueil
                  </button>
                </div>
              )}

              {/* Footer */}
              {showFooter && (
                <div id="signin-footer" className="text-center mt-6 pt-4 border-t border-base-300">
                  <p id="signin-footer-text" className="text-xs text-base-content/50">
                    {footerText}
                  </p>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;