import React, { useState, useEffect, useMemo } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Mail, LogIn, Loader2, AlertCircle, CheckCircle2 } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Alert, AlertTitle, AlertDescription } from '../components/ui/Alert';
import { Input } from '../components/ui/Input';
import { Label } from '../components/ui/Label';
import { useAuthStore } from '../store/auth.store';
import { api } from '../lib/api';

export const AuthChoicePage: React.FC = () => {
    const { t } = useTranslation();
    const navigate = useNavigate();
    const [searchParams] = useSearchParams();
    const { isAuthenticated, initialized, checkAuth, startOAuthLogin } = useAuthStore();

    const [email, setEmail] = useState('');
    const [loading, setLoading] = useState(false);
    const [magicLinkSent, setMagicLinkSent] = useState(false);
    const [errorMessage, setErrorMessage] = useState('');

    // Read auth flags from global variables (injected in index.html)
    // In React dev mode these might not be set, so default to true for dev if needed, or false for strictness
    const oauthEnabled = (window as any).ACKIFY_OAUTH_ENABLED !== false; // Default to true if not defined (for dev)
    const magicLinkEnabled = (window as any).ACKIFY_MAGICLINK_ENABLED !== false; // Default to true if not defined

    const redirectTo = useMemo(() => {
        return searchParams.get('redirect') || '/';
    }, [searchParams]);

    useEffect(() => {
        const init = async () => {
            if (!initialized) {
                await checkAuth();
            }
            if (isAuthenticated) {
                navigate(redirectTo);
            } else {
                // Auto-redirect if only one method and it's OAuth
                // Note: In React strict mode this might run twice, be careful with side effects
                // For now we'll skip auto-redirect to avoid loops or issues during dev
                /*
                if (oauthEnabled && !magicLinkEnabled) {
                    loginWithOAuth();
                }
                */
            }
        };
        init();
    }, [isAuthenticated, initialized, checkAuth, navigate, redirectTo, oauthEnabled, magicLinkEnabled]);

    const loginWithOAuth = async () => {
        setLoading(true);
        setErrorMessage('');
        localStorage.setItem('preferredAuthMethod', 'oauth');

        try {
            await startOAuthLogin(redirectTo);
        } catch (error: any) {
            setErrorMessage(error.message || t('auth.oauth.error', 'Erreur lors de la connexion OAuth'));
            setLoading(false);
        }
    };

    const requestMagicLink = async (e: React.FormEvent) => {
        e.preventDefault();

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!email || !emailRegex.test(email)) {
            setErrorMessage(t('auth.magiclink.error_invalid_email', 'Email invalide'));
            return;
        }

        setLoading(true);
        setErrorMessage('');
        setMagicLinkSent(false);
        localStorage.setItem('preferredAuthMethod', 'magiclink');

        try {
            await api.post('/auth/magic-link/request', {
                email,
                redirectTo
            });

            setMagicLinkSent(true);
        } catch (error: any) {
            setErrorMessage(error.response?.data?.error?.message || error.message || t('auth.magiclink.error_send', 'Erreur lors de l\'envoi du lien magique'));
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-full box-border flex items-center justify-center bg-background py-12 px-4 sm:px-6 lg:px-8">
            <div className="max-w-md w-full space-y-8">
                <div className="text-center">
                    <h1 className="text-3xl font-bold text-foreground">
                        {t('auth.choice.title', 'Connexion')}
                    </h1>
                    <p className="mt-2 text-sm text-muted-foreground">
                        {t('auth.choice.subtitle', 'Choisissez votre méthode de connexion')}
                    </p>
                </div>

                {errorMessage && (
                    <Alert variant="destructive">
                        <div className="flex items-start">
                            <AlertCircle size={20} className="mr-3 mt-0.5" />
                            <div className="flex-1">
                                <AlertTitle>{t('common.error', 'Erreur')}</AlertTitle>
                                <AlertDescription>{errorMessage}</AlertDescription>
                            </div>
                        </div>
                    </Alert>
                )}

                {magicLinkSent && (
                    <Alert variant="default" className="border-green-200 bg-green-50 dark:bg-green-900/20">
                        <div className="flex items-start">
                            <CheckCircle2 size={20} className="mr-3 mt-0.5 text-green-600 dark:text-green-400" />
                            <div className="flex-1">
                                <AlertTitle className="text-green-800 dark:text-green-300">{t('auth.magiclink.sent.title', 'Lien envoyé !')}</AlertTitle>
                                <AlertDescription className="text-green-700 dark:text-green-400">
                                    {t('auth.magiclink.sent.message', 'Vérifiez votre boîte de réception.')}
                                    <br />
                                    <span className="text-xs text-green-600 dark:text-green-500">
                                        {t('auth.magiclink.sent.expire', 'Le lien expirera dans 15 minutes.')}
                                    </span>
                                </AlertDescription>
                            </div>
                        </div>
                    </Alert>
                )}

                {/* OAuth Login */}
                {oauthEnabled && (
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <LogIn className="h-5 w-5" />
                                {t('auth.oauth.title', 'Authentification Unique (SSO)')}
                            </CardTitle>
                            <CardDescription>
                                {t('auth.oauth.description', 'Connectez-vous avec votre compte d\'entreprise')}
                            </CardDescription>
                        </CardHeader>
                        <CardContent>
                            <Button
                                onClick={loginWithOAuth}
                                disabled={loading}
                                className="w-full"
                                size="lg"
                            >
                                {loading ? (
                                    <Loader2 className="h-4 w-4 animate-spin mr-2" />
                                ) : null}
                                {t('auth.oauth.button', 'Se connecter avec SSO')}
                            </Button>
                        </CardContent>
                    </Card>
                )}

                {/* Magic Link Login */}
                {magicLinkEnabled && (
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <Mail className="h-5 w-5" />
                                {t('auth.magiclink.title', 'Lien Magique')}
                            </CardTitle>
                            <CardDescription>
                                {t('auth.magiclink.description', 'Recevez un lien de connexion par email')}
                            </CardDescription>
                        </CardHeader>
                        <CardContent>
                            <form onSubmit={requestMagicLink} className="space-y-4">
                                <div>
                                    <Label htmlFor="email" className="mb-1">
                                        {t('auth.magiclink.email_label', 'Adresse email')}
                                    </Label>
                                    <Input
                                        id="email"
                                        value={email}
                                        onChange={(e) => setEmail(e.target.value)}
                                        type="email"
                                        required
                                        disabled={loading}
                                        placeholder={t('auth.magiclink.email_placeholder', 'vous@exemple.com')}
                                    />
                                </div>
                                <Button
                                    type="submit"
                                    disabled={loading}
                                    className="w-full"
                                    size="lg"
                                    variant="outline"
                                >
                                    {loading ? (
                                        <Loader2 className="h-4 w-4 animate-spin mr-2" />
                                    ) : (
                                        <Mail className="h-4 w-4 mr-2" />
                                    )}
                                    {t('auth.magiclink.button', 'Envoyer le lien magique')}
                                </Button>
                            </form>
                        </CardContent>
                    </Card>
                )}

                <p className="text-center text-xs text-muted-foreground">
                    {t('auth.choice.privacy', 'En vous connectant, vous acceptez nos conditions d\'utilisation.')}
                </p>
            </div>
        </div>
    );
};
