import React, { useEffect, useState, useMemo } from 'react';
import { useSearchParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Loader2, Check, ExternalLink, FileText } from 'lucide-react';
import { api } from '../lib/api';
import { Signature } from '../components/SignatureList';

interface DocumentData {
    id: string;
    title: string;
    signatures: Signature[];
    metadata: any;
}

export const EmbedPage: React.FC = () => {
    const { t } = useTranslation();
    const [searchParams] = useSearchParams();

    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [documentData, setDocumentData] = useState<DocumentData | null>(null);

    const docRef = searchParams.get('doc');

    const signUrl = useMemo(() => {
        const baseUrl = (window as any).ACKIFY_BASE_URL || window.location.origin;
        return `${baseUrl}/?doc=${encodeURIComponent(docRef || '')}`;
    }, [docRef]);

    const formatDateCompact = (dateString: string) => {
        const date = new Date(dateString);
        return date.toLocaleDateString('fr-FR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric'
        });
    };

    useEffect(() => {
        const loadDocument = async () => {
            if (!docRef) {
                setError(t('embed.missingDocId', 'ID du document manquant'));
                return;
            }

            try {
                setLoading(true);
                setError(null);

                // First, find or create the document to get the docID
                const doc = await api.post<{ docId: string; title?: string }>('/documents/find-or-create', {
                    url: docRef
                });

                // Then fetch signatures using the resolved docID
                const signatures = await api.get<Signature[]>(`/documents/${doc.docId}/signatures`);

                setDocumentData({
                    id: doc.docId,
                    title: doc.title || `Document ${doc.docId}`,
                    signatures: signatures || [],
                    metadata: {}
                });

            } catch (err: any) {
                const message = err.response?.data?.error?.message || err.message || 'Erreur de chargement';
                setError(message);
            } finally {
                setLoading(false);
            }
        };

        loadDocument();
    }, [docRef, t]);

    return (
        <div className="min-h-screen bg-background text-foreground p-4">
            {/* Loading state */}
            {loading && (
                <div className="flex items-center justify-center py-8">
                    <Loader2 className="animate-spin h-8 w-8 text-primary" />
                </div>
            )}

            {/* Error state */}
            {!loading && error && (
                <div className="bg-destructive/10 dark:bg-destructive/20 border border-destructive/50 rounded-lg p-4">
                    <p className="text-destructive text-sm">{error}</p>
                </div>
            )}

            {/* Document info and signatures */}
            {!loading && !error && documentData && (
                <div className="max-w-2xl mx-auto">
                    {/* Document header with signatures */}
                    {documentData.signatures.length > 0 ? (
                        <div>
                            <div className="mb-6">
                                <h2 className="text-xl font-bold text-foreground mb-2">
                                    {t('embed.document', 'Document')} {documentData.title}
                                </h2>
                                <div className="flex items-center justify-between mb-4">
                                    <div className="flex items-center space-x-4 text-sm text-muted-foreground">
                                        <span className="flex items-center">
                                            <Check className="w-4 h-4 mr-1" />
                                            {t('embed.confirmationsCount', '{{count}} confirmation(s)', { count: documentData.signatures.length })}
                                        </span>
                                        {documentData.metadata?.title && <span>{documentData.metadata.title}</span>}
                                    </div>
                                    {/* Sign button */}
                                    <a
                                        href={signUrl}
                                        target="_blank"
                                        rel="noopener noreferrer"
                                        className="inline-flex items-center px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background text-sm font-medium whitespace-nowrap"
                                    >
                                        <ExternalLink className="w-4 h-4 mr-2" />
                                        {t('embed.sign', 'Signer')}
                                    </a>
                                </div>
                            </div>

                            {/* Signatures list (compact) */}
                            <div className="space-y-2">
                                {documentData.signatures.map((signature) => (
                                    <div
                                        key={signature.id}
                                        className="bg-card text-card-foreground rounded-md px-3 py-2 border border-border flex items-center justify-between"
                                    >
                                        <div className="flex items-center space-x-2 min-w-0 flex-1">
                                            <Check className="w-4 h-4 text-green-600 dark:text-green-500 flex-shrink-0" />
                                            <span className="text-sm font-medium text-foreground truncate">{signature.userEmail}</span>
                                        </div>
                                        <span className="text-xs text-muted-foreground whitespace-nowrap ml-2">
                                            {formatDateCompact(signature.signedAt)}
                                        </span>
                                    </div>
                                ))}
                            </div>
                        </div>
                    ) : (
                        /* Empty state - No signatures yet */
                        <div className="text-center py-8">
                            <FileText className="w-16 h-16 mx-auto mb-4 text-muted-foreground" />
                            <p className="text-sm text-muted-foreground mb-4">{t('embed.noSignatures', 'Aucune signature pour le moment')}</p>
                            <a
                                href={signUrl}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="inline-flex items-center px-6 py-3 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background text-base font-medium"
                            >
                                <ExternalLink className="w-5 h-5 mr-2" />
                                {t('embed.signDocument', 'Signer ce document')}
                            </a>
                        </div>
                    )}

                    {/* Footer branding */}
                    <div className="mt-8 pt-4 border-t border-border text-center">
                        <a
                            href="https://github.com/btouchard/ackify-ce"
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-xs text-muted-foreground hover:text-foreground transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background rounded"
                        >
                            {t('embed.poweredBy', 'Propulsé par Ackify')}
                        </a>
                    </div>
                </div>
            )}
        </div>
    );
};
