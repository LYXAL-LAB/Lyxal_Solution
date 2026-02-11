import React, { useState, useEffect, useMemo } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
    ArrowLeft, Users, CheckCircle, Mail, Shield, Plus, Loader2, Copy, Clock, X, Trash2
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { Input } from '../../components/ui/Input';
import { Textarea } from '../../components/ui/Textarea';
import { Alert, AlertDescription } from '../../components/ui/Alert';
import { Badge } from '../../components/ui/Badge';
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../components/ui/Table';
import { ConfirmDialog } from '../../components/ui/ConfirmDialog';
import { api } from '../../lib/api';

interface DocumentStatus {
    document: {
        docId: string;
        title?: string;
        url?: string;
        checksum?: string;
        checksumAlgorithm?: string;
        description?: string;
        createdAt: string;
        createdBy: string;
    };
    stats: {
        expectedCount: number;
        signedCount: number;
        pendingCount: number;
        completionRate: number;
    };
    reminderStats: {
        totalSent: number;
        pendingCount: number;
        lastSentAt?: string;
    };
    expectedSigners: Array<{
        id: string;
        email: string;
        name?: string;
        userName?: string;
        hasSigned: boolean;
        signedAt?: string;
        addedAt: string;
        addedBy: string;
        reminderCount: number;
        lastReminderSent?: string;
        daysSinceAdded: number;
        daysSinceLastReminder?: number;
    }>;
    unexpectedSignatures: Array<{
        userEmail: string;
        userName?: string;
        signedAtUTC: string;
    }>;
    shareLink: string;
}

export const AdminDocumentDetail: React.FC = () => {
    const { t, i18n } = useTranslation();
    const { docId } = useParams<{ docId: string }>();
    const navigate = useNavigate();

    const [documentStatus, setDocumentStatus] = useState<DocumentStatus | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');

    // Modals
    const [showAddSignersModal, setShowAddSignersModal] = useState(false);
    const [showDeleteConfirmModal, setShowDeleteConfirmModal] = useState(false);
    const [showMetadataWarningModal, setShowMetadataWarningModal] = useState(false);
    const [showRemoveSignerModal, setShowRemoveSignerModal] = useState(false);
    const [showSendRemindersModal, setShowSendRemindersModal] = useState(false);
    const [signerToRemove, setSignerToRemove] = useState('');
    const [remindersMessage, setRemindersMessage] = useState('');

    // Metadata form
    const [metadataForm, setMetadataForm] = useState({
        title: '',
        url: '',
        checksum: '',
        checksumAlgorithm: 'SHA-256',
        description: ''
    });
    const [originalMetadata, setOriginalMetadata] = useState({ ...metadataForm });
    const [savingMetadata, setSavingMetadata] = useState(false);

    // Expected signers form
    const [signersEmails, setSignersEmails] = useState('');
    const [addingSigners, setAddingSigners] = useState(false);

    // Reminders
    const [sendMode, setSendMode] = useState<'all' | 'selected'>('all');
    const [selectedEmails, setSelectedEmails] = useState<string[]>([]);
    const [sendingReminders, setSendingReminders] = useState(false);

    // Delete
    const [deletingDocument, setDeletingDocument] = useState(false);

    const smtpEnabled = (window as any).ACKIFY_SMTP_ENABLED !== false; // Default true

    const loadDocumentStatus = async () => {
        if (!docId) return;
        try {
            setLoading(true);
            setError('');
            const data = await api.get<DocumentStatus>(`/admin/documents/${docId}/status`);
            setDocumentStatus(data);

            if (data.document) {
                const metadata = {
                    title: data.document.title || '',
                    url: data.document.url || '',
                    checksum: data.document.checksum || '',
                    checksumAlgorithm: data.document.checksumAlgorithm || 'SHA-256',
                    description: data.document.description || '',
                };
                setMetadataForm(metadata);
                setOriginalMetadata(metadata);
            }
        } catch (err: any) {
            setError(err.response?.data?.error?.message || err.message || 'Failed to load document status');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadDocumentStatus();
    }, [docId]);

    const formatDate = (dateString?: string) => {
        if (!dateString) return 'N/A';
        return new Date(dateString).toLocaleDateString('fr-FR', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
        });
    };

    const copyToClipboard = (text: string) => {
        navigator.clipboard.writeText(text);
        setSuccess(t('admin.documentDetail.copiedToClipboard', 'Copié dans le presse-papier'));
        setTimeout(() => setSuccess(''), 2000);
    };

    const hasCriticalFieldsChanged = () => {
        return (
            metadataForm.url !== originalMetadata.url ||
            metadataForm.checksum !== originalMetadata.checksum ||
            metadataForm.checksumAlgorithm !== originalMetadata.checksumAlgorithm ||
            metadataForm.description !== originalMetadata.description
        );
    };

    const handleSaveMetadata = () => {
        const expectedSignaturesCount = documentStatus?.stats.signedCount || 0;
        const unexpectedSignaturesCount = documentStatus?.unexpectedSignatures.length || 0;
        const totalSignatures = expectedSignaturesCount + unexpectedSignaturesCount;
        const hasSignatures = totalSignatures > 0;

        if (hasSignatures && hasCriticalFieldsChanged()) {
            setShowMetadataWarningModal(true);
        } else {
            saveMetadata();
        }
    };

    const saveMetadata = async () => {
        if (!docId) return;
        try {
            setSavingMetadata(true);
            setError('');
            setSuccess('');
            setShowMetadataWarningModal(false);
            await api.patch(`/admin/documents/${docId}/metadata`, metadataForm);
            setSuccess(t('admin.documentDetail.metadataSaved', 'Métadonnées enregistrées'));
            await loadDocumentStatus();
            setTimeout(() => setSuccess(''), 3000);
        } catch (err: any) {
            setError(err.response?.data?.error?.message || err.message || 'Failed to save metadata');
        } finally {
            setSavingMetadata(false);
        }
    };

    const addSigners = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!signersEmails.trim() || !docId) return;

        try {
            setAddingSigners(true);
            setError('');
            setSuccess('');

            const lines = signersEmails.split('\n').filter(l => l.trim());
            let addedCount = 0;

            for (const line of lines) {
                const trimmed = line.trim();
                const match = trimmed.match(/^(.+?)\s*<(.+?)>$/);
                const email = match && match[2] ? match[2].trim() : trimmed;
                const name = match && match[1] ? match[1].trim() : '';

                try {
                    await api.post(`/admin/documents/${docId}/expected-signers`, { email, name });
                    addedCount++;
                } catch (err) {
                    console.error(`Failed to add ${email}`, err);
                }
            }

            setShowAddSignersModal(false);
            setSignersEmails('');
            setSuccess(t('admin.documentDetail.signersAdded', '{{count}} signataire(s) ajouté(s)', { count: addedCount }));
            await loadDocumentStatus();
            setTimeout(() => setSuccess(''), 3000);
        } catch (err: any) {
            setError(err.response?.data?.error?.message || err.message || 'Failed to add signers');
        } finally {
            setAddingSigners(false);
        }
    };

    const confirmRemoveSigner = (email: string) => {
        setSignerToRemove(email);
        setShowRemoveSignerModal(true);
    };

    const removeSigner = async () => {
        if (!signerToRemove || !docId) return;
        try {
            setError('');
            setSuccess('');
            await api.delete(`/admin/documents/${docId}/expected-signers/${encodeURIComponent(signerToRemove)}`);
            setSuccess(t('admin.documentDetail.signerRemoved', 'Signataire retiré'));
            setShowRemoveSignerModal(false);
            setSignerToRemove('');
            await loadDocumentStatus();
            setTimeout(() => setSuccess(''), 3000);
        } catch (err: any) {
            setError(err.response?.data?.error?.message || err.message || 'Failed to remove signer');
        }
    };

    const confirmSendReminders = () => {
        const count = sendMode === 'all'
            ? documentStatus?.reminderStats.pendingCount || 0
            : selectedEmails.length;

        setRemindersMessage(
            sendMode === 'all'
                ? t('admin.documentDetail.confirmSendReminders', 'Envoyer une relance à {{count}} signataire(s) ?', { count })
                : t('admin.documentDetail.confirmSendRemindersSelected', 'Envoyer une relance à {{count}} signataire(s) sélectionné(s) ?', { count })
        );
        setShowSendRemindersModal(true);
    };

    const sendRemindersAction = async () => {
        if (!docId) return;
        try {
            setSendingReminders(true);
            setError('');
            setSuccess('');

            const normalizedLocale = i18n.language.split('-')[0];
            const response = await api.post<{ result: { successfullySent: number; failed: number; errors?: string[] } }>(
                `/admin/documents/${docId}/reminders`,
                {
                    emails: sendMode === 'selected' ? selectedEmails : undefined,
                    locale: normalizedLocale
                }
            );

            const result = response.result;
            setSelectedEmails([]);
            setShowSendRemindersModal(false);

            if (result.failed > 0) {
                setSuccess(t('admin.documentDetail.remindersSentPartial', '{{sent}} envoyé(s), {{failed}} échec(s)', { sent: result.successfullySent, failed: result.failed }));
            } else {
                setSuccess(t('admin.documentDetail.remindersSentSuccess', '{{count}} relance(s) envoyée(s)', { count: result.successfullySent }));
            }

            await loadDocumentStatus();
            setTimeout(() => setSuccess(''), 3000);
        } catch (err: any) {
            setError(err.response?.data?.error?.message || err.message || 'Failed to send reminders');
        } finally {
            setSendingReminders(false);
        }
    };

    const handleDeleteDocument = async () => {
        if (!docId) return;
        try {
            setDeletingDocument(true);
            setError('');
            await api.delete(`/admin/documents/${docId}`);
            setShowDeleteConfirmModal(false);
            navigate('/admin');
        } catch (err: any) {
            setError(err.response?.data?.error?.message || err.message || 'Failed to delete document');
            setShowDeleteConfirmModal(false);
        } finally {
            setDeletingDocument(false);
        }
    };

    const toggleEmailSelection = (email: string) => {
        setSelectedEmails(prev =>
            prev.includes(email) ? prev.filter(e => e !== email) : [...prev, email]
        );
    };

    if (loading) {
        return (
            <div className="flex flex-col items-center justify-center py-24">
                <Loader2 size={48} className="animate-spin text-primary" />
                <p className="mt-4 text-muted-foreground">{t('common.loading', 'Chargement...')}</p>
            </div>
        );
    }

    if (!documentStatus) return null;

    return (
        <div className="relative min-h-[calc(100vh-4rem)]">
            <div className="absolute inset-0 -z-10 overflow-hidden">
                <div className="absolute left-1/4 top-0 h-[400px] w-[400px] rounded-full bg-primary/5 blur-3xl"></div>
                <div className="absolute right-1/4 bottom-0 h-[400px] w-[400px] rounded-full bg-primary/5 blur-3xl"></div>
            </div>

            <main className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
                {/* Header */}
                <div className="mb-8">
                    <div className="flex items-center space-x-3 mb-2">
                        <Button variant="ghost" size="icon" onClick={() => navigate('/admin')}>
                            <ArrowLeft size={20} />
                        </Button>
                        <h1 className="text-3xl font-bold tracking-tight text-foreground sm:text-4xl">
                            {t('admin.documentDetail.title', 'Document')} {docId}
                        </h1>
                    </div>
                    <div className="flex items-center gap-3 ml-14">
                        <p className="text-sm text-muted-foreground font-mono">{documentStatus.shareLink}</p>
                        <Button onClick={() => copyToClipboard(documentStatus.shareLink)} variant="ghost" size="icon">
                            <Copy size={16} />
                        </Button>
                    </div>
                </div>

                {error && (
                    <Alert variant="destructive" className="mb-6 clay-card">
                        <AlertDescription>{error}</AlertDescription>
                    </Alert>
                )}

                {success && (
                    <Alert className="mb-6 clay-card bg-green-50 border-green-200 dark:bg-green-900/20">
                        <AlertDescription className="text-green-800 dark:text-green-200">{success}</AlertDescription>
                    </Alert>
                )}

                <div className="space-y-8">
                    {/* Stats Cards */}
                    <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
                        <Card className="clay-card-hover">
                            <CardContent className="pt-6">
                                <div className="flex items-center space-x-4">
                                    <div className="rounded-lg bg-blue-500/10 p-3">
                                        <Users size={24} className="text-blue-600" />
                                    </div>
                                    <div>
                                        <p className="text-sm font-medium text-muted-foreground">{t('admin.dashboard.stats.expected', 'Attendus')}</p>
                                        <p className="text-2xl font-bold text-foreground">{documentStatus.stats.expectedCount}</p>
                                    </div>
                                </div>
                            </CardContent>
                        </Card>
                        <Card className="clay-card-hover">
                            <CardContent className="pt-6">
                                <div className="flex items-center space-x-4">
                                    <div className="rounded-lg bg-green-500/10 p-3">
                                        <CheckCircle size={24} className="text-green-600" />
                                    </div>
                                    <div>
                                        <p className="text-sm font-medium text-muted-foreground">{t('admin.dashboard.stats.signed', 'Signés')}</p>
                                        <p className="text-2xl font-bold text-foreground">{documentStatus.stats.signedCount}</p>
                                    </div>
                                </div>
                            </CardContent>
                        </Card>
                        <Card className="clay-card-hover">
                            <CardContent className="pt-6">
                                <div className="flex items-center space-x-4">
                                    <div className="rounded-lg bg-orange-500/10 p-3">
                                        <Clock size={24} className="text-orange-600" />
                                    </div>
                                    <div>
                                        <p className="text-sm font-medium text-muted-foreground">{t('admin.dashboard.stats.pending', 'En attente')}</p>
                                        <p className="text-2xl font-bold text-foreground">{documentStatus.stats.pendingCount}</p>
                                    </div>
                                </div>
                            </CardContent>
                        </Card>
                        <Card className="clay-card-hover">
                            <CardContent className="pt-6">
                                <div className="flex items-center space-x-4">
                                    <div className="rounded-lg bg-purple-500/10 p-3">
                                        <Shield size={24} className="text-purple-600" />
                                    </div>
                                    <div>
                                        <p className="text-sm font-medium text-muted-foreground">{t('admin.dashboard.stats.completion', 'Complétude')}</p>
                                        <p className="text-2xl font-bold text-foreground">{Math.round(documentStatus.stats.completionRate)}%</p>
                                    </div>
                                </div>
                            </CardContent>
                        </Card>
                    </div>

                    {/* Metadata Form */}
                    <Card className="clay-card">
                        <CardHeader>
                            <CardTitle>{t('admin.documentDetail.metadata', 'Métadonnées')}</CardTitle>
                            <CardDescription>{t('admin.documentDetail.metadataDescription', 'Informations générales sur le document')}</CardDescription>
                        </CardHeader>
                        <CardContent>
                            <form onSubmit={(e) => { e.preventDefault(); handleSaveMetadata(); }} className="space-y-4">
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-sm font-medium mb-2">{t('admin.documentDetail.titleLabel', 'Titre')}</label>
                                        <Input value={metadataForm.title} onChange={e => setMetadataForm({ ...metadataForm, title: e.target.value })} />
                                    </div>
                                    <div>
                                        <label className="block text-sm font-medium mb-2">{t('admin.documentDetail.urlLabel', 'URL')}</label>
                                        <Input value={metadataForm.url} onChange={e => setMetadataForm({ ...metadataForm, url: e.target.value })} type="url" />
                                    </div>
                                </div>
                                <div className="grid grid-cols-1 md:grid-cols-[1fr_auto] gap-4">
                                    <div>
                                        <label className="block text-sm font-medium mb-2">{t('admin.documentDetail.checksumLabel', 'Checksum')}</label>
                                        <Input value={metadataForm.checksum} onChange={e => setMetadataForm({ ...metadataForm, checksum: e.target.value })} className="font-mono text-sm" />
                                    </div>
                                    <div className="md:min-w-[140px]">
                                        <label className="block text-sm font-medium mb-2">{t('admin.documentDetail.algorithmLabel', 'Algorithme')}</label>
                                        <select
                                            value={metadataForm.checksumAlgorithm}
                                            onChange={e => setMetadataForm({ ...metadataForm, checksumAlgorithm: e.target.value })}
                                            className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                                        >
                                            <option value="SHA-256">SHA-256</option>
                                            <option value="SHA-512">SHA-512</option>
                                            <option value="MD5">MD5</option>
                                        </select>
                                    </div>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium mb-2">{t('admin.documentDetail.descriptionLabel', 'Description')}</label>
                                    <Textarea value={metadataForm.description} onChange={e => setMetadataForm({ ...metadataForm, description: e.target.value })} rows={4} />
                                </div>
                                <div className="flex justify-end">
                                    <Button type="submit" disabled={savingMetadata}>
                                        {savingMetadata ? t('admin.documentDetail.saving', 'Enregistrement...') : t('common.save', 'Enregistrer')}
                                    </Button>
                                </div>
                            </form>
                        </CardContent>
                    </Card>

                    {/* Expected Signers */}
                    <Card className="clay-card">
                        <CardHeader>
                            <div className="flex items-center justify-between">
                                <div>
                                    <CardTitle>{t('admin.documentDetail.readers', 'Lecteurs attendus')}</CardTitle>
                                    <CardDescription>{documentStatus.stats.signedCount} / {documentStatus.stats.expectedCount} {t('admin.dashboard.stats.signed', 'signés').toLowerCase()}</CardDescription>
                                </div>
                                <Button onClick={() => setShowAddSignersModal(true)} size="sm">
                                    <Plus size={16} className="mr-2" />
                                    {t('admin.documentDetail.addButton', 'Ajouter')}
                                </Button>
                            </div>
                        </CardHeader>
                        <CardContent>
                            {documentStatus.expectedSigners.length > 0 ? (
                                <Table>
                                    <TableHeader>
                                        <TableRow>
                                            <TableHead>
                                                <input
                                                    type="checkbox"
                                                    className="rounded"
                                                    onChange={(e) => setSelectedEmails(e.target.checked ? documentStatus.expectedSigners.filter(s => !s.hasSigned).map(s => s.email) : [])}
                                                />
                                            </TableHead>
                                            <TableHead>{t('admin.documentDetail.reader', 'Lecteur')}</TableHead>
                                            <TableHead>{t('admin.documentDetail.status', 'Statut')}</TableHead>
                                            <TableHead>{t('admin.documentDetail.confirmedOn', 'Confirmé le')}</TableHead>
                                            <TableHead>{t('common.actions', 'Actions')}</TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {documentStatus.expectedSigners.map(signer => (
                                            <TableRow key={signer.email}>
                                                <TableCell>
                                                    {!signer.hasSigned && (
                                                        <input
                                                            type="checkbox"
                                                            className="rounded"
                                                            checked={selectedEmails.includes(signer.email)}
                                                            onChange={() => toggleEmailSelection(signer.email)}
                                                        />
                                                    )}
                                                </TableCell>
                                                <TableCell>
                                                    <div className="space-y-1">
                                                        <p className="font-medium">{signer.userName || signer.name || signer.email}</p>
                                                        <p className="text-xs text-muted-foreground">{signer.email}</p>
                                                    </div>
                                                </TableCell>
                                                <TableCell>
                                                    <Badge variant={signer.hasSigned ? 'default' : 'secondary'}>
                                                        {signer.hasSigned ? t('admin.documentDetail.statusConfirmed', 'Confirmé') : t('admin.documentDetail.statusPending', 'En attente')}
                                                    </Badge>
                                                </TableCell>
                                                <TableCell>
                                                    {signer.signedAt ? formatDate(signer.signedAt) : '-'}
                                                </TableCell>
                                                <TableCell>
                                                    {!signer.hasSigned ? (
                                                        <Button onClick={() => confirmRemoveSigner(signer.email)} variant="ghost" size="sm">
                                                            <Trash2 size={14} className="text-destructive" />
                                                        </Button>
                                                    ) : (
                                                        <span className="text-xs text-muted-foreground">-</span>
                                                    )}
                                                </TableCell>
                                            </TableRow>
                                        ))}
                                    </TableBody>
                                </Table>
                            ) : (
                                <div className="text-center py-8 text-muted-foreground">
                                    <Users size={48} className="mx-auto mb-4 opacity-50" />
                                    <p>{t('admin.documentDetail.noExpectedSigners', 'Aucun signataire attendu')}</p>
                                </div>
                            )}

                            {/* Unexpected Signatures */}
                            {documentStatus.unexpectedSignatures.length > 0 && (
                                <div className="mt-8 pt-8 border-t border-border">
                                    <h3 className="text-lg font-semibold mb-4 flex items-center">
                                        <span className="mr-2">⚠</span>
                                        {t('admin.documentDetail.unexpectedSignatures', 'Signatures non attendues')}
                                        <Badge variant="secondary" className="ml-2">{documentStatus.unexpectedSignatures.length}</Badge>
                                    </h3>
                                    <Table>
                                        <TableHeader>
                                            <TableRow>
                                                <TableHead>{t('admin.documentDetail.user', 'Utilisateur')}</TableHead>
                                                <TableHead>{t('admin.documentDetail.confirmedOn', 'Confirmé le')}</TableHead>
                                            </TableRow>
                                        </TableHeader>
                                        <TableBody>
                                            {documentStatus.unexpectedSignatures.map((sig, idx) => (
                                                <TableRow key={idx}>
                                                    <TableCell>
                                                        <div className="space-y-1">
                                                            <p className="font-medium">{sig.userName || sig.userEmail}</p>
                                                            <p className="text-xs text-muted-foreground">{sig.userEmail}</p>
                                                        </div>
                                                    </TableCell>
                                                    <TableCell>{formatDate(sig.signedAtUTC)}</TableCell>
                                                </TableRow>
                                            ))}
                                        </TableBody>
                                    </Table>
                                </div>
                            )}
                        </CardContent>
                    </Card>

                    {/* Reminders */}
                    {documentStatus.stats.expectedCount > 0 && (smtpEnabled || documentStatus.reminderStats.totalSent > 0) && (
                        <Card className="clay-card">
                            <CardHeader>
                                <CardTitle>{t('admin.documentDetail.reminders', 'Relances')}</CardTitle>
                                <CardDescription>{t('admin.documentDetail.remindersDescription', 'Gestion des relances par email')}</CardDescription>
                            </CardHeader>
                            <CardContent className="space-y-6">
                                <div className="grid gap-4 sm:grid-cols-3">
                                    <div className="bg-muted rounded-lg p-4">
                                        <p className="text-sm text-muted-foreground">{t('admin.documentDetail.remindersSent', 'Envoyées')}</p>
                                        <p className="text-2xl font-bold">{documentStatus.reminderStats.totalSent}</p>
                                    </div>
                                    <div className="bg-muted rounded-lg p-4">
                                        <p className="text-sm text-muted-foreground">{t('admin.documentDetail.toRemind', 'À relancer')}</p>
                                        <p className="text-2xl font-bold">{documentStatus.reminderStats.pendingCount}</p>
                                    </div>
                                    {documentStatus.reminderStats.lastSentAt && (
                                        <div className="bg-muted rounded-lg p-4">
                                            <p className="text-sm text-muted-foreground">{t('admin.documentDetail.lastReminder', 'Dernière relance')}</p>
                                            <p className="text-sm font-bold">{formatDate(documentStatus.reminderStats.lastSentAt)}</p>
                                        </div>
                                    )}
                                </div>

                                {!smtpEnabled && (
                                    <Alert className="border-orange-500 bg-orange-50 dark:bg-orange-900/20">
                                        <AlertDescription className="text-orange-800 dark:text-orange-200">
                                            {t('admin.documentDetail.emailServiceDisabled', 'Service email désactivé')}
                                        </AlertDescription>
                                    </Alert>
                                )}

                                {smtpEnabled && (
                                    <div className="space-y-4">
                                        <div className="space-y-2">
                                            <label className="flex items-center space-x-2">
                                                <input type="radio" checked={sendMode === 'all'} onChange={() => setSendMode('all')} className="rounded-full" />
                                                <span>{t('admin.documentDetail.sendToAll', 'Envoyer à tous ({{count}})', { count: documentStatus.reminderStats.pendingCount })}</span>
                                            </label>
                                            <label className="flex items-center space-x-2">
                                                <input type="radio" checked={sendMode === 'selected'} onChange={() => setSendMode('selected')} className="rounded-full" />
                                                <span>{t('admin.documentDetail.sendToSelected', 'Envoyer à la sélection ({{count}})', { count: selectedEmails.length })}</span>
                                            </label>
                                        </div>
                                        <Button onClick={confirmSendReminders} disabled={sendingReminders || (sendMode === 'selected' && selectedEmails.length === 0)}>
                                            <Mail size={16} className="mr-2" />
                                            {sendingReminders ? t('admin.documentDetail.sending', 'Envoi...') : t('admin.documentDetail.sendReminders', 'Envoyer les relances')}
                                        </Button>
                                    </div>
                                )}
                            </CardContent>
                        </Card>
                    )}

                    {/* Danger Zone */}
                    <Card className="clay-card border-destructive/50">
                        <CardHeader>
                            <CardTitle className="text-destructive">{t('admin.documentDetail.dangerZone', 'Zone de danger')}</CardTitle>
                            <CardDescription>{t('admin.documentDetail.dangerZoneDescription', 'Actions irréversibles')}</CardDescription>
                        </CardHeader>
                        <CardContent>
                            <div className="flex items-center justify-between p-4 bg-destructive/5 rounded-lg">
                                <div className="flex-1">
                                    <h3 className="font-semibold text-foreground mb-1">{t('admin.documentDetail.deleteDocument', 'Supprimer le document')}</h3>
                                    <p className="text-sm text-muted-foreground">
                                        {t('admin.documentDetail.deleteDocumentDescription', 'Cette action supprimera définitivement le document et toutes les signatures associées.')}
                                    </p>
                                </div>
                                <Button onClick={() => setShowDeleteConfirmModal(true)} variant="destructive" className="ml-4">
                                    <Trash2 size={16} className="mr-2" />
                                    {t('common.delete', 'Supprimer')}
                                </Button>
                            </div>
                        </CardContent>
                    </Card>
                </div>
            </main>

            {/* Modals */}
            {showAddSignersModal && (
                <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4" onClick={() => setShowAddSignersModal(false)}>
                    <Card className="max-w-2xl w-full" onClick={e => e.stopPropagation()}>
                        <CardHeader>
                            <div className="flex items-center justify-between">
                                <CardTitle>{t('admin.documentDetail.addSigners', 'Ajouter des signataires')}</CardTitle>
                                <Button variant="ghost" size="icon" onClick={() => setShowAddSignersModal(false)}>
                                    <X size={20} />
                                </Button>
                            </div>
                        </CardHeader>
                        <CardContent>
                            <form onSubmit={addSigners} className="space-y-4">
                                <div>
                                    <label className="block text-sm font-medium mb-2">{t('admin.documentDetail.emailsLabel', 'Emails')}</label>
                                    <Textarea value={signersEmails} onChange={e => setSignersEmails(e.target.value)} rows={8} placeholder={t('admin.documentDetail.emailsPlaceholder', 'Un email par ligne...')} />
                                </div>
                                <div className="flex justify-end space-x-3">
                                    <Button type="button" variant="outline" onClick={() => setShowAddSignersModal(false)}>{t('common.cancel', 'Annuler')}</Button>
                                    <Button type="submit" disabled={addingSigners || !signersEmails.trim()}>
                                        {addingSigners ? t('admin.documentDetail.adding', 'Ajout...') : t('admin.documentDetail.addButton', 'Ajouter')}
                                    </Button>
                                </div>
                            </form>
                        </CardContent>
                    </Card>
                </div>
            )}

            <ConfirmDialog
                open={showDeleteConfirmModal}
                onOpenChange={setShowDeleteConfirmModal}
                title={t('admin.documentDetail.deleteConfirmTitle', 'Supprimer le document ?')}
                message={t('admin.documentDetail.deleteWarning', 'Cette action est irréversible. Êtes-vous sûr ?')}
                confirmText={t('common.delete', 'Supprimer')}
                cancelText={t('common.cancel', 'Annuler')}
                variant="destructive"
                loading={deletingDocument}
                onConfirm={handleDeleteDocument}
                onCancel={() => setShowDeleteConfirmModal(false)}
            />

            <ConfirmDialog
                open={showRemoveSignerModal}
                onOpenChange={setShowRemoveSignerModal}
                title={t('admin.documentDetail.removeSignerTitle', 'Retirer le signataire')}
                message={t('admin.documentDetail.removeSignerMessage', 'Êtes-vous sûr de vouloir retirer ce signataire ?')}
                confirmText={t('common.remove', 'Retirer')}
                cancelText={t('common.cancel', 'Annuler')}
                variant="destructive"
                onConfirm={removeSigner}
                onCancel={() => setShowRemoveSignerModal(false)}
            />

            <ConfirmDialog
                open={showSendRemindersModal}
                onOpenChange={setShowSendRemindersModal}
                title={t('admin.documentDetail.sendRemindersTitle', 'Envoyer des relances')}
                message={remindersMessage}
                confirmText={t('common.send', 'Envoyer')}
                cancelText={t('common.cancel', 'Annuler')}
                variant="default"
                loading={sendingReminders}
                onConfirm={sendRemindersAction}
                onCancel={() => setShowSendRemindersModal(false)}
            />

            <ConfirmDialog
                open={showMetadataWarningModal}
                onOpenChange={setShowMetadataWarningModal}
                title={t('admin.documentDetail.metadataWarning.title', 'Attention')}
                message={t('admin.documentDetail.metadataWarning.message', 'Modifier ces champs alors que des signatures existent peut invalider les preuves. Continuer ?')}
                confirmText={t('common.save', 'Enregistrer')}
                cancelText={t('common.cancel', 'Annuler')}
                variant="warning"
                loading={savingMetadata}
                onConfirm={saveMetadata}
                onCancel={() => setShowMetadataWarningModal(false)}
            />
        </div>
    );
};
