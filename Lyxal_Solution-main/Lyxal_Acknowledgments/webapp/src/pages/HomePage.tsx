import React, { useState, useEffect, useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { useSearchParams, useNavigate } from 'react-router-dom';
import { FileText, Shield, CheckCircle2, AlertTriangle, Info, Users, Loader2, Zap, Clock } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../components/ui/Card';
import { Alert, AlertTitle, AlertDescription } from '../components/ui/Alert';
import { Button } from '../components/ui/Button';
import { DocumentForm } from '../components/DocumentForm';
import { SignButton } from '../components/SignButton';
import { SignatureList, Signature } from '../components/SignatureList';
import { useAuthStore } from '../store/auth.store';
import { useSignatureStore } from '../store/signature.store';
import { api } from '../lib/api';
import { cn } from '../lib/utils';

interface DocumentResponse {
    docId: string;
    url: string;
    title?: string;
    isNew: boolean;
    checksum?: string;
    checksumAlgorithm?: string;
}

export const HomePage: React.FC = () => {
    const { t } = useTranslation();
    const navigate = useNavigate();
    const [searchParams, setSearchParams] = useSearchParams();
    const { isAuthenticated, user, isAdmin, checkAuth, initialized } = useAuthStore();
    const { fetchDocumentSignatures } = useSignatureStore();

    const docIdParam = searchParams.get('doc');
    const [docId, setDocId] = useState<string | null>(null);
    const [currentDocument, setCurrentDocument] = useState<DocumentResponse | null>(null);
    const [documentSignatures, setDocumentSignatures] = useState<Signature[]>([]);

    const [loadingDocument, setLoadingDocument] = useState(false);
    const [loadingSignatures, setLoadingSignatures] = useState(false);
    const [errorMessage, setErrorMessage] = useState<string | null>(null);
    const [showSuccessMessage, setShowSuccessMessage] = useState(false);
    const [needsAuth, setNeedsAuth] = useState(false);

    // Check if document creation is restricted to admins
    // In React we can use environment variables or window config
    const onlyAdminCanCreate = (window as any).ACKIFY_ONLY_ADMIN_CAN_CREATE || false;
    const canCreateDocument = !onlyAdminCanCreate || isAdmin;

    const userHasSigned = useMemo(() => {
        if (!user?.email || documentSignatures.length === 0) {
            return false;
        }
        return documentSignatures.some(sig => sig.userEmail === user.email);
    }, [user, documentSignatures]);

    const loadDocumentSignatures = async (id: string) => {
        setLoadingSignatures(true);
        try {
            const sigs = await fetchDocumentSignatures(id);
            setDocumentSignatures(sigs);
        } catch (error) {
            console.error('Failed to load document signatures:', error);
        } finally {
            setLoadingSignatures(false);
        }
    };

    const handleDocumentReference = async (ref: string) => {
        try {
            setLoadingDocument(true);
            setErrorMessage(null);
            setNeedsAuth(false);

            // Call find-or-create API
            const doc = await api.post<DocumentResponse>('/documents/find-or-create', {
                url: ref
            });

            setDocId(doc.docId);
            setCurrentDocument(doc);

            // If the ref is not the same as the docID, update URL
            if (ref !== doc.docId) {
                setSearchParams({ doc: doc.docId }, { replace: true });
            }

            // Load signatures
            await loadDocumentSignatures(doc.docId);

        } catch (error: any) {
            console.error('Failed to load/create document:', error);

            if (error.response?.status === 401) {
                setErrorMessage(t('sign.error.authRequired', 'Authentification requise'));
                setNeedsAuth(true);
            } else {
                setErrorMessage(error.message || t('sign.error.loadFailed', 'Échec du chargement du document'));
                setNeedsAuth(false);
            }
        } finally {
            setLoadingDocument(false);
        }
    };

    const handleLoginClick = () => {
        const returnUrl = window.location.pathname + window.location.search;
        window.location.href = `/auth?returnUrl=${encodeURIComponent(returnUrl)}`;
    };

    const handleSigned = async () => {
        setShowSuccessMessage(true);
        setErrorMessage(null);

        if (docId) {
            await loadDocumentSignatures(docId);
        }

        setTimeout(() => {
            setShowSuccessMessage(false);
        }, 5000);
    };

    const handleError = (error: string) => {
        setErrorMessage(error);
        setShowSuccessMessage(false);
    };

    // Initial load
    useEffect(() => {
        const init = async () => {
            if (!initialized) {
                await checkAuth();
            }

            if (docIdParam) {
                handleDocumentReference(docIdParam);
            } else {
                // Reset state if no doc param
                setDocId(null);
                setCurrentDocument(null);
                setDocumentSignatures([]);
                setErrorMessage(null);
            }
        };
        init();
    }, [docIdParam, initialized, checkAuth]);

    return (
        <div className="relative">
            {/* Background decoration */}
            <div className="absolute inset-0 -z-10 overflow-hidden">
                <div className="absolute left-1/4 top-0 h-[400px] w-[400px] rounded-full bg-primary/5 blur-3xl"></div>
                <div className="absolute right-1/4 bottom-0 h-[400px] w-[400px] rounded-full bg-primary/5 blur-3xl"></div>
            </div>

            <div className="mx-auto max-w-4xl px-4 py-12 sm:px-6 lg:px-8">
                {/* Page Header */}
                <div className="mb-8 text-center">
                    <h1 className="mb-2 text-3xl font-bold tracking-tight text-foreground sm:text-4xl">
                        {t('sign.title', 'Confirmation de lecture')}
                    </h1>
                    <p className="text-lg text-muted-foreground">
                        {t('sign.subtitle', 'Signez et suivez la lecture de vos documents importants')}
                    </p>
                </div>

                {/* Error Message */}
                {errorMessage && !loadingDocument && (
                    <Alert variant="destructive" className="clay-card mb-6">
                        <div className="flex items-start">
                            <AlertTriangle size={20} className="mr-3 mt-0.5" />
                            <div className="flex-1">
                                <AlertTitle>{t('sign.error.title', 'Erreur')}</AlertTitle>
                                <AlertDescription>{errorMessage}</AlertDescription>
                                {needsAuth && (
                                    <div className="mt-4">
                                        <Button onClick={handleLoginClick} variant="default">
                                            {t('sign.error.loginButton', 'Se connecter')}
                                        </Button>
                                    </div>
                                )}
                            </div>
                        </div>
                    </Alert>
                )}

                {/* Loading State */}
                {loadingDocument ? (
                    <Card className="clay-card">
                        <CardContent className="py-12 text-center">
                            <Loader2 size={48} className="mx-auto mb-4 animate-spin text-primary" />
                            <h2 className="text-xl font-semibold mb-2">{t('sign.loading.title', 'Chargement du document...')}</h2>
                            <p className="text-muted-foreground">
                                {t('sign.loading.description', 'Veuillez patienter pendant que nous récupérons les informations.')}
                            </p>
                        </CardContent>
                    </Card>
                ) : !docId ? (
                    /* No Document: Show help message & form */
                    <Card className="clay-card">
                        <CardContent className="py-12 text-center">
                            <FileText size={48} className="mx-auto mb-4 text-muted-foreground" />
                            <h2 className="text-xl font-semibold mb-2">{t('sign.noDocument.title', 'Aucun document sélectionné')}</h2>
                            <p className="text-muted-foreground mb-4">
                                {t('sign.noDocument.description', 'Pour commencer, veuillez fournir l\'URL ou l\'ID d\'un document.')}
                            </p>
                            <div className="text-sm text-muted-foreground space-y-2 max-w-lg mx-auto">
                                <DocumentForm />
                                {!canCreateDocument && (
                                    <Alert variant="warning" className="mt-4 text-left">
                                        <div className="flex items-start">
                                            <AlertTriangle size={18} className="mr-3 mt-0.5" />
                                            <div className="flex-1 text-sm">
                                                <p>{t('sign.documentCreation.restrictedToAdmins', 'La création de nouveaux documents est réservée aux administrateurs.')}</p>
                                            </div>
                                        </div>
                                    </Alert>
                                )}
                            </div>
                        </CardContent>
                    </Card>
                ) : (
                    /* Main Content when doc ID is present */
                    <div className="space-y-6">
                        {/* Success Message */}
                        {showSuccessMessage && (
                            <Alert variant="default" className="clay-card border-green-500 bg-green-50 dark:bg-green-900/20">
                                <div className="flex items-start">
                                    <CheckCircle2 size={20} className="mr-3 mt-0.5 text-green-600 dark:text-green-400" />
                                    <div className="flex-1">
                                        <AlertTitle className="text-green-800 dark:text-green-300">{t('sign.success.title', 'Succès')}</AlertTitle>
                                        <AlertDescription className="text-green-700 dark:text-green-400">
                                            {t('sign.success.description', 'Votre confirmation de lecture a été enregistrée avec succès.')}
                                        </AlertDescription>
                                    </div>
                                </div>
                            </Alert>
                        )}

                        {/* Document Info Card */}
                        <Card className="clay-card">
                            <CardHeader>
                                <div className="flex items-start space-x-4">
                                    <div className="rounded-lg bg-primary/10 p-3">
                                        <FileText size={28} className="text-primary" />
                                    </div>
                                    <div className="flex-1">
                                        <CardTitle>
                                            {t('sign.document.title', 'Document')}
                                            {currentDocument?.title && ` : ${currentDocument.title}`}
                                        </CardTitle>
                                        <CardDescription className="mt-2">
                                            {currentDocument?.url ? (
                                                <a
                                                    href={currentDocument.url}
                                                    target="_blank"
                                                    rel="noopener noreferrer"
                                                    className="text-primary hover:underline font-mono text-xs break-all"
                                                >
                                                    {currentDocument.url}
                                                </a>
                                            ) : (
                                                <span className="font-mono text-xs">{docId}</span>
                                            )}
                                        </CardDescription>
                                    </div>
                                </div>
                            </CardHeader>

                            <CardContent>
                                <div className="space-y-4">
                                    {/* Sign Button Component */}
                                    <div className="pb-4">
                                        <SignButton
                                            docId={docId}
                                            signatures={documentSignatures}
                                            onSigned={handleSigned}
                                            onError={handleError}
                                        />
                                    </div>

                                    {/* Info Box (only shown if user hasn't signed yet) */}
                                    {!userHasSigned && (
                                        <Alert variant="default" className="border-l-4 border-l-blue-500 bg-blue-50 dark:bg-blue-900/20">
                                            <div className="flex items-start">
                                                <Info size={18} className="mr-3 mt-0.5 text-blue-600 dark:text-blue-400" />
                                                <div className="flex-1 space-y-2 text-sm text-blue-800 dark:text-blue-200">
                                                    <p>
                                                        {t('sign.info.description', 'En cliquant sur le bouton ci-dessus, vous confirmez avoir lu et compris le document.')}
                                                    </p>
                                                    <p className="font-medium">
                                                        {t('sign.info.recorded', 'Les informations suivantes seront enregistrées :')}
                                                    </p>
                                                    <ul className="list-disc space-y-1 pl-5">
                                                        <li>{t('sign.info.email', 'Email')} : <strong className="text-foreground">{user?.email}</strong></li>
                                                        <li>{t('sign.info.timestamp', 'Horodatage de la signature')}</li>
                                                        <li>{t('sign.info.signature', 'Signature cryptographique unique')}</li>
                                                        <li>{t('sign.info.hash', 'Empreinte numérique du document')}</li>
                                                    </ul>
                                                </div>
                                            </div>
                                        </Alert>
                                    )}
                                </div>
                            </CardContent>
                        </Card>

                        {/* Existing Confirmations */}
                        {documentSignatures.length > 0 ? (
                            <Card className="clay-card">
                                <CardHeader>
                                    <div className="flex items-center space-x-3">
                                        <div className="rounded-lg bg-primary/10 p-2">
                                            <Users size={20} className="text-primary" />
                                        </div>
                                        <div>
                                            <CardTitle>{t('sign.confirmations.title', 'Confirmations')}</CardTitle>
                                            <CardDescription>
                                                {t('sign.confirmations.count', '{{count}} personne(s) ont confirmé la lecture', { count: documentSignatures.length })}
                                            </CardDescription>
                                        </div>
                                    </div>
                                </CardHeader>

                                <CardContent>
                                    <SignatureList
                                        signatures={documentSignatures}
                                        loading={loadingSignatures}
                                        showUserInfo={true}
                                        showDetails={true}
                                    />
                                </CardContent>
                            </Card>
                        ) : (
                            !loadingSignatures && (
                                <Card className="clay-card">
                                    <CardContent className="py-12 text-center">
                                        <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-muted">
                                            <Users size={28} className="text-muted-foreground" />
                                        </div>
                                        <h3 className="mb-2 text-lg font-semibold text-foreground">
                                            {t('sign.empty.title', 'Aucune confirmation')}
                                        </h3>
                                        <p className="text-sm text-muted-foreground">
                                            {t('sign.empty.description', 'Soyez le premier à confirmer la lecture de ce document.')}
                                        </p>
                                    </CardContent>
                                </Card>
                            )
                        )}
                    </div>
                )}

                {/* How it Works Section (always visible) */}
                <div className="mt-16 pt-12 border-t border-border/40">
                    <div className="text-center mb-12">
                        <h2 className="mb-3 text-2xl font-bold tracking-tight text-foreground sm:text-3xl">
                            {t('sign.howItWorks.title', 'Comment ça marche ?')}
                        </h2>
                        <p className="text-muted-foreground max-w-2xl mx-auto">
                            {t('sign.howItWorks.subtitle', 'Un processus simple, sécurisé et transparent pour valider la lecture de vos documents.')}
                        </p>
                    </div>

                    {/* Steps Grid */}
                    <div className="grid gap-8 md:grid-cols-3 mb-12">
                        {/* Step 1 */}
                        <Card className="clay-card-hover text-center">
                            <CardContent className="pt-6">
                                <div className="mb-4 inline-flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10">
                                    <FileText size={24} className="text-primary" />
                                </div>
                                <h3 className="mb-2 text-lg font-semibold text-foreground">{t('sign.howItWorks.step1.title', '1. Partagez le lien')}</h3>
                                <p className="text-sm text-muted-foreground">
                                    {t('sign.howItWorks.step1.description', 'Envoyez le lien du document à vos collaborateurs (ex: ?doc=URL).')}
                                </p>
                            </CardContent>
                        </Card>

                        {/* Step 2 */}
                        <Card className="clay-card-hover text-center">
                            <CardContent className="pt-6">
                                <div className="mb-4 inline-flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10">
                                    <Shield size={24} className="text-primary" />
                                </div>
                                <h3 className="mb-2 text-lg font-semibold text-foreground">{t('sign.howItWorks.step2.title', '2. Authentification')}</h3>
                                <p className="text-sm text-muted-foreground">
                                    {t('sign.howItWorks.step2.description', 'Les utilisateurs se connectent de manière sécurisée pour confirmer leur identité.')}
                                </p>
                            </CardContent>
                        </Card>

                        {/* Step 3 */}
                        <Card className="clay-card-hover text-center">
                            <CardContent className="pt-6">
                                <div className="mb-4 inline-flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10">
                                    <CheckCircle2 size={24} className="text-primary" />
                                </div>
                                <h3 className="mb-2 text-lg font-semibold text-foreground">{t('sign.howItWorks.step3.title', '3. Confirmation')}</h3>
                                <p className="text-sm text-muted-foreground">
                                    {t('sign.howItWorks.step3.description', 'Une signature cryptographique infalsifiable est générée pour prouver la lecture.')}
                                </p>
                            </CardContent>
                        </Card>
                    </div>

                    {/* Features */}
                    <div className="grid gap-6 md:grid-cols-3">
                        <div className="flex items-start space-x-3">
                            <div className="rounded-lg bg-primary/10 p-2 mt-1">
                                <Shield size={20} className="text-primary" />
                            </div>
                            <div>
                                <h4 className="font-medium text-foreground mb-1">{t('sign.howItWorks.features.crypto.title', 'Sécurité Maximale')}</h4>
                                <p className="text-sm text-muted-foreground">
                                    {t('sign.howItWorks.features.crypto.description', 'Utilisation de SHA-256 et ECDSA pour garantir l\'intégrité des preuves.')}
                                </p>
                            </div>
                        </div>

                        <div className="flex items-start space-x-3">
                            <div className="rounded-lg bg-primary/10 p-2 mt-1">
                                <Zap size={20} className="text-primary" />
                            </div>
                            <div>
                                <h4 className="font-medium text-foreground mb-1">{t('sign.howItWorks.features.instant.title', 'Instantané')}</h4>
                                <p className="text-sm text-muted-foreground">
                                    {t('sign.howItWorks.features.instant.description', 'Pas de compte complexe à créer, validation en un clic.')}
                                </p>
                            </div>
                        </div>

                        <div className="flex items-start space-x-3">
                            <div className="rounded-lg bg-primary/10 p-2 mt-1">
                                <Clock size={20} className="text-primary" />
                            </div>
                            <div>
                                <h4 className="font-medium text-foreground mb-1">{t('sign.howItWorks.features.timestamp.title', 'Horodatage')}</h4>
                                <p className="text-sm text-muted-foreground">
                                    {t('sign.howItWorks.features.timestamp.description', 'Chaque signature est horodatée avec précision.')}
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};
