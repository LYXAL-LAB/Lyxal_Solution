import React from 'react';
import { useTranslation } from 'react-i18next';
import { cn } from '../lib/utils';

export interface Signature {
    id: string;
    docId: string;
    docTitle?: string;
    docUrl?: string;
    userEmail: string;
    userName?: string;
    signedAt: string;
    nonce?: string;
    payloadHash?: string;
    signature: string;
    prevHash?: string;
    docDeletedAt?: string;
    serviceInfo?: {
        name: string;
        icon: string;
    };
}

interface SignatureListProps {
    signatures: Signature[];
    loading?: boolean;
    showUserInfo?: boolean;
    showDetails?: boolean;
    showActions?: boolean;
    emptyMessage?: string;
    isDeleted?: boolean;
    onViewDetails?: (signature: Signature) => void;
}

export const SignatureList: React.FC<SignatureListProps> = ({
    signatures,
    loading = false,
    showUserInfo = false,
    showDetails = true,
    showActions = false,
    emptyMessage,
    isDeleted = false,
    onViewDetails
}) => {
    const { t } = useTranslation();

    const formatDate = (dateString: string) => {
        const date = new Date(dateString);
        return date.toLocaleDateString('fr-FR', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
        });
    };

    if (loading) {
        return (
            <div className="flex justify-center py-8">
                <svg
                    className="animate-spin h-8 w-8 text-primary"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                >
                    <circle
                        className="opacity-25"
                        cx="12"
                        cy="12"
                        r="10"
                        stroke="currentColor"
                        strokeWidth="4"
                    ></circle>
                    <path
                        className="opacity-75"
                        fill="currentColor"
                        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                    ></path>
                </svg>
            </div>
        );
    }

    if (signatures.length === 0) {
        return (
            <div className="text-center py-12 px-4">
                <svg
                    className="mx-auto h-12 w-12 text-muted-foreground"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                >
                    <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth="2"
                        d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                    />
                </svg>
                <p className="mt-2 text-muted-foreground">{emptyMessage || t('signatureList.empty', 'Aucune signature trouvée')}</p>
            </div>
        );
    }

    return (
        <div className="space-y-4 w-full">
            {signatures.map((signature) => (
                <div
                    key={signature.id}
                    className={cn(
                        'shadow rounded-lg p-4 hover:shadow-md transition-shadow bg-card text-card-foreground border border-border',
                        isDeleted ? 'opacity-50' : ''
                    )}
                >
                    <div className="flex items-start justify-between">
                        <div className="flex-1">
                            <div className="flex items-center space-x-2">
                                <h3 className="text-lg font-medium text-foreground">
                                    {signature.docTitle || signature.docId}
                                </h3>
                                {!isDeleted ? (
                                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-400">
                                        <svg
                                            className="mr-1 h-3 w-3"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                        >
                                            <path
                                                strokeLinecap="round"
                                                strokeLinejoin="round"
                                                strokeWidth="2"
                                                d="M5 13l4 4L19 7"
                                            />
                                        </svg>
                                        {t('signatureList.confirmed', 'Confirmé')}
                                    </span>
                                ) : (
                                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-400">
                                        <svg
                                            className="mr-1 h-3 w-3"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                        >
                                            <path
                                                strokeLinecap="round"
                                                strokeLinejoin="round"
                                                strokeWidth="2"
                                                d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                                            />
                                        </svg>
                                        {t('signatureList.documentDeleted', 'Document supprimé')}
                                        {signature.docDeletedAt ? ` ${formatDate(signature.docDeletedAt)}` : ''}
                                    </span>
                                )}
                            </div>

                            <div className="mt-2 space-y-1 text-sm text-muted-foreground">
                                {signature.docTitle && (
                                    <p>
                                        <span className="font-medium">{t('signatureList.fields.id', 'ID')}:</span> {signature.docId}
                                    </p>
                                )}
                                {signature.docUrl && (
                                    <p>
                                        <span className="font-medium">{t('signatureList.fields.document', 'Document')}:</span>{' '}
                                        <a
                                            href={signature.docUrl}
                                            target="_blank"
                                            rel="noopener noreferrer"
                                            className="text-primary hover:text-primary/80 hover:underline focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background rounded"
                                        >
                                            {signature.docUrl}
                                        </a>
                                    </p>
                                )}
                                {showUserInfo && (
                                    <p>
                                        <span className="font-medium">{t('signatureList.fields.reader', 'Lecteur')}:</span>{' '}
                                        {signature.userName || signature.userEmail}
                                    </p>
                                )}
                                <p>
                                    <span className="font-medium">{t('signatureList.fields.date', 'Date')}:</span>{' '}
                                    {formatDate(signature.signedAt)}
                                </p>
                                {signature.serviceInfo && (
                                    <p className="flex items-center">
                                        <span className="font-medium mr-2">{t('signatureList.fields.source', 'Source')}:</span>
                                        <span className="inline-flex items-center space-x-1">
                                            <span dangerouslySetInnerHTML={{ __html: signature.serviceInfo.icon }}></span>
                                            <span>{signature.serviceInfo.name}</span>
                                        </span>
                                    </p>
                                )}
                            </div>

                            {showDetails && (
                                <div className="mt-3 pt-3 border-t border-border">
                                    <details className="text-xs text-muted-foreground group">
                                        <summary className="cursor-pointer hover:text-foreground font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background rounded">
                                            {t('signatureList.verificationDetails', 'Détails de vérification')}
                                        </summary>
                                        <div className="mt-2 space-y-1 font-mono bg-muted p-2 rounded border border-border">
                                            <p><span className="font-semibold">{t('signatureList.fields.id', 'ID')}:</span> {signature.id}</p>
                                            <p><span className="font-semibold">{t('signatureList.fields.nonce', 'Nonce')}:</span> {signature.nonce}</p>
                                            <p className="break-all">
                                                <span className="font-semibold">{t('signatureList.fields.hash', 'Hash')}:</span> {signature.payloadHash}
                                            </p>
                                            <p className="break-all">
                                                <span className="font-semibold">{t('signatureList.confirmation', 'Signature')}:</span>{' '}
                                                {signature.signature.substring(0, 64)}...
                                            </p>
                                            {signature.prevHash && (
                                                <p className="break-all">
                                                    <span className="font-semibold">{t('signatureList.previousHash', 'Hash précédent')}:</span> {signature.prevHash}
                                                </p>
                                            )}
                                        </div>
                                    </details>
                                </div>
                            )}
                        </div>

                        {showActions && (
                            <div className="ml-4">
                                <button
                                    onClick={() => onViewDetails && onViewDetails(signature)}
                                    className="text-primary hover:text-primary/80 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background rounded px-2 py-1"
                                >
                                    {t('signatureList.viewDetails', 'Voir détails')}
                                </button>
                            </div>
                        )}
                    </div>
                </div>
            ))}
        </div>
    );
};
