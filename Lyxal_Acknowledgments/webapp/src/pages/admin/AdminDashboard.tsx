import React, { useState, useEffect, useMemo } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { FileText, Users, CheckCircle, ExternalLink, Settings, Loader2, Plus, Search, Webhook } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { Input } from '../../components/ui/Input';
import { Alert, AlertDescription } from '../../components/ui/Alert';
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../components/ui/Table';
import { api } from '../../lib/api';

interface Document {
    docId: string;
    title?: string;
    url?: string;
    createdAt: string;
    createdBy: string;
}

interface DocumentListResponse {
    data: Document[];
    meta?: {
        total: number;
    };
}

export const AdminDashboard: React.FC = () => {
    const { t } = useTranslation();
    const navigate = useNavigate();

    const [documents, setDocuments] = useState<Document[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [newDocId, setNewDocId] = useState('');
    const [creating, setCreating] = useState(false);

    // Pagination & Filter
    const [searchQuery, setSearchQuery] = useState('');
    const [currentPage, setCurrentPage] = useState(1);
    const [perPage] = useState(20);
    const [totalDocsCount, setTotalDocsCount] = useState(0);

    // Computed
    const filteredDocuments = useMemo(() => {
        if (!searchQuery.trim()) return documents;
        const query = searchQuery.toLowerCase();
        return documents.filter(doc =>
            doc.docId.toLowerCase().includes(query) ||
            doc.title?.toLowerCase().includes(query) ||
            doc.url?.toLowerCase().includes(query)
        );
    }, [documents, searchQuery]);

    const totalPages = Math.ceil(totalDocsCount / perPage) || 1;

    // Computed KPIs
    const totalDocuments = totalDocsCount;
    // For now, return 0 as expectedSigners might not be available in the list view
    const totalSigners = 0;
    const activeDocuments = documents.length;

    const loadDocuments = async () => {
        try {
            setLoading(true);
            setError('');
            const offset = (currentPage - 1) * perPage;
            // Note: Adjust endpoint if necessary. Vue uses listDocuments(limit, offset)
            const response = await api.get<DocumentListResponse | Document[]>(`/admin/documents?limit=${perPage}&offset=${offset}`);

            let docs: Document[] = [];
            let total = 0;

            if (Array.isArray(response)) {
                docs = response;
                total = docs.length; // Fallback if no meta
            } else {
                docs = response.data;
                total = response.meta?.total || docs.length;
            }

            setDocuments(docs);
            setTotalDocsCount(total);
        } catch (err: any) {
            setError(err.response?.data?.error?.message || err.message || 'Failed to load documents');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadDocuments();
    }, [currentPage, perPage]);

    const nextPage = () => {
        if (currentPage < totalPages) {
            setCurrentPage(prev => prev + 1);
        }
    };

    const prevPage = () => {
        if (currentPage > 1) {
            setCurrentPage(prev => prev - 1);
        }
    };

    const createDocument = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!newDocId.trim()) return;

        try {
            setCreating(true);
            setError('');

            // Use findOrCreateDocument to handle URL, path, or ID
            const response = await api.post<{ docId: string }>('/documents/find-or-create', {
                url: newDocId.trim()
            });

            // Navigate to document detail page with the returned docId
            navigate(`/admin/docs/${response.docId}`);
        } catch (err: any) {
            setError(err.response?.data?.error?.message || err.message || 'Failed to create document');
        } finally {
            setCreating(false);
        }
    };

    const formatDate = (dateString: string) => {
        const date = new Date(dateString);
        return date.toLocaleDateString('fr-FR', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
    };

    return (
        <div className="relative min-h-[calc(100vh-4rem)]">
            <div className="absolute inset-0 -z-10 overflow-hidden">
                <div className="absolute left-1/4 top-0 h-[400px] w-[400px] rounded-full bg-primary/5 blur-3xl"></div>
                <div className="absolute right-1/4 bottom-0 h-[400px] w-[400px] rounded-full bg-primary/5 blur-3xl"></div>
            </div>

            <main className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
                {/* Page Header */}
                <div className="mb-8 flex items-start justify-between">
                    <div>
                        <h1 className="mb-2 text-3xl font-bold tracking-tight text-foreground sm:text-4xl">
                            {t('admin.title', 'Administration')}
                        </h1>
                        <p className="text-lg text-muted-foreground">
                            {t('admin.subtitle', 'Gérez vos documents et signatures')}
                        </p>
                    </div>
                    <Link to="/admin/webhooks">
                        <Button variant="outline">
                            <Webhook size={16} className="mr-2" />
                            {t('admin.webhooks.manage', 'Gérer les Webhooks')}
                        </Button>
                    </Link>
                </div>

                {/* Create Document Section */}
                <Card className="clay-card mb-8">
                    <CardHeader>
                        <CardTitle>{t('admin.documents.new', 'Nouveau Document')}</CardTitle>
                        <CardDescription>
                            {t('admin.documents.newDescription', 'Entrez un ID de document ou une URL pour commencer le suivi')}
                        </CardDescription>
                    </CardHeader>
                    <CardContent>
                        <form onSubmit={createDocument}>
                            {/* Desktop layout */}
                            <div className="hidden md:flex flex-row gap-4">
                                <div className="flex-1">
                                    <label htmlFor="newDocId" className="block text-sm font-medium text-foreground mb-2">
                                        {t('admin.documents.idLabel', 'ID du Document ou URL')}
                                    </label>
                                    <Input
                                        value={newDocId}
                                        onChange={e => setNewDocId(e.target.value)}
                                        id="newDocId"
                                        type="text"
                                        required
                                        placeholder={t('admin.documents.idPlaceholder', 'ex: contrat-2024-001 ou https://...')}
                                        className="w-full"
                                    />
                                    <p className="mt-1 text-xs text-muted-foreground">
                                        {t('admin.documents.idHelper', 'Si le document n\'existe pas, il sera créé automatiquement.')}
                                    </p>
                                </div>
                                <div className="pt-7">
                                    <Button type="submit" disabled={!newDocId || creating}>
                                        {creating ? (
                                            <Loader2 size={16} className="mr-2 animate-spin" />
                                        ) : (
                                            <FileText size={16} className="mr-2" />
                                        )}
                                        {creating ? t('admin.documentForm.creating', 'Création...') : t('common.confirm', 'Confirmer')}
                                    </Button>
                                </div>
                            </div>

                            {/* Mobile layout */}
                            <div className="md:hidden space-y-2">
                                <label htmlFor="newDocIdMobile" className="block text-sm font-medium text-foreground">
                                    {t('admin.documents.idLabel', 'ID du Document ou URL')}
                                </label>
                                <div className="flex gap-2">
                                    <Input
                                        value={newDocId}
                                        onChange={e => setNewDocId(e.target.value)}
                                        id="newDocIdMobile"
                                        type="text"
                                        required
                                        placeholder={t('admin.documents.idPlaceholder', 'ex: contrat-2024-001')}
                                        className="flex-1"
                                    />
                                    <Button type="submit" size="icon" disabled={!newDocId || creating} className="shrink-0">
                                        {creating ? <Loader2 size={20} className="animate-spin" /> : <Plus size={20} />}
                                    </Button>
                                </div>
                                <p className="text-xs text-muted-foreground">
                                    {t('admin.documents.idHelperShort', 'Création auto si inexistant')}
                                </p>
                            </div>
                        </form>
                    </CardContent>
                </Card>

                {error && (
                    <Alert variant="destructive" className="mb-6 clay-card">
                        <AlertDescription>{error}</AlertDescription>
                    </Alert>
                )}

                {loading ? (
                    <div className="flex flex-col items-center justify-center py-24">
                        <Loader2 size={48} className="animate-spin text-primary" />
                        <p className="mt-4 text-muted-foreground">{t('admin.loading', 'Chargement...')}</p>
                    </div>
                ) : (
                    <div>
                        {/* KPI Cards Desktop */}
                        <div className="hidden md:grid mb-8 gap-6 sm:grid-cols-2 lg:grid-cols-3">
                            <Card className="clay-card-hover">
                                <CardContent className="pt-6">
                                    <div className="flex items-center space-x-4">
                                        <div className="rounded-lg bg-primary/10 p-3">
                                            <FileText size={24} className="text-primary" />
                                        </div>
                                        <div className="flex-1">
                                            <p className="text-sm font-medium text-muted-foreground">{t('admin.dashboard.totalDocuments', 'Total Documents')}</p>
                                            <p className="text-2xl font-bold text-foreground">{totalDocuments}</p>
                                        </div>
                                    </div>
                                </CardContent>
                            </Card>

                            <Card className="clay-card-hover">
                                <CardContent className="pt-6">
                                    <div className="flex items-center space-x-4">
                                        <div className="rounded-lg bg-blue-500/10 p-3">
                                            <Users size={24} className="text-blue-600 dark:text-blue-400" />
                                        </div>
                                        <div className="flex-1">
                                            <p className="text-sm font-medium text-muted-foreground">{t('admin.dashboard.stats.expected', 'Lecteurs attendus')}</p>
                                            <p className="text-2xl font-bold text-foreground">{totalSigners}</p>
                                        </div>
                                    </div>
                                </CardContent>
                            </Card>

                            <Card className="clay-card-hover">
                                <CardContent className="pt-6">
                                    <div className="flex items-center space-x-4">
                                        <div className="rounded-lg bg-green-500/10 p-3">
                                            <CheckCircle size={24} className="text-green-600 dark:text-green-400" />
                                        </div>
                                        <div className="flex-1">
                                            <p className="text-sm font-medium text-muted-foreground">{t('admin.documents.actions', 'Documents actifs')}</p>
                                            <p className="text-2xl font-bold text-foreground">{activeDocuments}</p>
                                        </div>
                                    </div>
                                </CardContent>
                            </Card>
                        </div>

                        {/* Documents Table */}
                        <Card className="clay-card">
                            <CardHeader>
                                <CardTitle>{t('admin.documents.title', 'Documents')}</CardTitle>
                                <CardDescription className="mt-2">
                                    {t('admin.subtitle', 'Gérez vos documents et signatures')}
                                </CardDescription>
                            </CardHeader>

                            <CardContent>
                                {/* Search Filter */}
                                <div className="mb-6 relative">
                                    <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
                                    <Input
                                        value={searchQuery}
                                        onChange={e => setSearchQuery(e.target.value)}
                                        type="text"
                                        placeholder={t('admin.documents.search', 'Rechercher un document...')}
                                        className="pl-10"
                                    />
                                </div>

                                {/* Desktop Table */}
                                <div className="hidden md:block rounded-md border border-border/40">
                                    {filteredDocuments.length > 0 ? (
                                        <Table>
                                            <TableHeader>
                                                <TableRow>
                                                    <TableHead>{t('admin.documents.document', 'Document')}</TableHead>
                                                    <TableHead>{t('admin.documents.url', 'URL')}</TableHead>
                                                    <TableHead>{t('admin.documents.createdOn', 'Créé le')}</TableHead>
                                                    <TableHead>{t('admin.documents.by', 'Par')}</TableHead>
                                                    <TableHead className="text-right">{t('admin.documents.actions', 'Actions')}</TableHead>
                                                </TableRow>
                                            </TableHeader>
                                            <TableBody>
                                                {filteredDocuments.map(doc => (
                                                    <TableRow key={doc.docId}>
                                                        <TableCell>
                                                            <div className="space-y-1">
                                                                <div className="font-medium text-foreground">{doc.title || doc.docId}</div>
                                                                <div className="text-xs font-mono text-muted-foreground">{doc.docId}</div>
                                                            </div>
                                                        </TableCell>
                                                        <TableCell>
                                                            {doc.url ? (
                                                                <a
                                                                    href={doc.url}
                                                                    target="_blank"
                                                                    rel="noopener noreferrer"
                                                                    className="inline-flex items-center space-x-1 text-sm text-primary hover:underline"
                                                                >
                                                                    <span className="max-w-[200px] truncate">{doc.url}</span>
                                                                    <ExternalLink size={14} />
                                                                </a>
                                                            ) : (
                                                                <span className="text-xs text-muted-foreground">—</span>
                                                            )}
                                                        </TableCell>
                                                        <TableCell className="text-muted-foreground">
                                                            {formatDate(doc.createdAt)}
                                                        </TableCell>
                                                        <TableCell className="text-muted-foreground">
                                                            <span className="text-xs">{doc.createdBy}</span>
                                                        </TableCell>
                                                        <TableCell className="text-right">
                                                            <Link to={`/admin/docs/${doc.docId}`}>
                                                                <Button variant="ghost" size="sm">
                                                                    <Settings size={16} className="mr-1" />
                                                                    {t('admin.documents.manage', 'Gérer')}
                                                                </Button>
                                                            </Link>
                                                        </TableCell>
                                                    </TableRow>
                                                ))}
                                            </TableBody>
                                        </Table>
                                    ) : (
                                        <div className="py-12 text-center text-muted-foreground">
                                            {t('admin.documents.noResults', 'Aucun résultat trouvé')}
                                        </div>
                                    )}
                                </div>

                                {/* Mobile Cards */}
                                <div className="md:hidden space-y-4">
                                    {filteredDocuments.length > 0 ? (
                                        filteredDocuments.map(doc => (
                                            <Card key={doc.docId} className="clay-card-hover">
                                                <CardContent className="p-4">
                                                    <div className="mb-3">
                                                        <h3 className="font-medium text-foreground text-base">{doc.title || doc.docId}</h3>
                                                        <p className="text-xs font-mono text-muted-foreground mt-1">{doc.docId}</p>
                                                    </div>
                                                    {doc.url && (
                                                        <div className="mb-3">
                                                            <a
                                                                href={doc.url}
                                                                target="_blank"
                                                                rel="noopener noreferrer"
                                                                className="inline-flex items-center space-x-1 text-sm text-primary hover:underline"
                                                            >
                                                                <ExternalLink size={14} />
                                                                <span className="truncate max-w-[250px]">{doc.url}</span>
                                                            </a>
                                                        </div>
                                                    )}
                                                    <div className="flex flex-wrap items-center gap-3 text-sm text-muted-foreground mb-3">
                                                        <div className="flex items-center space-x-1">
                                                            <FileText size={14} />
                                                            <span>{formatDate(doc.createdAt)}</span>
                                                        </div>
                                                        <div className="flex items-center space-x-1">
                                                            <Users size={14} />
                                                            <span className="text-xs">{doc.createdBy}</span>
                                                        </div>
                                                    </div>
                                                    <div className="flex gap-2 pt-2 border-t border-border/40">
                                                        <Link to={`/admin/docs/${doc.docId}`} className="flex-1">
                                                            <Button variant="outline" size="sm" className="w-full">
                                                                <Settings size={16} className="mr-2" />
                                                                {t('admin.documents.manage', 'Gérer')}
                                                            </Button>
                                                        </Link>
                                                    </div>
                                                </CardContent>
                                            </Card>
                                        ))
                                    ) : (
                                        <div className="py-12 text-center text-muted-foreground">
                                            {t('admin.documents.noResults', 'Aucun résultat trouvé')}
                                        </div>
                                    )}
                                </div>

                                {/* Pagination */}
                                {filteredDocuments.length > 0 && !searchQuery && totalPages > 1 && (
                                    <div className="flex items-center justify-between mt-6 pt-4 border-t border-border/40">
                                        <div className="hidden md:block text-sm text-muted-foreground">
                                            {t('admin.documents.totalCount', 'Total: {{count}}', { count: totalDocuments })}
                                        </div>
                                        <div className="flex items-center gap-2 w-full md:w-auto justify-between md:justify-end">
                                            <Button
                                                variant="outline"
                                                size="sm"
                                                disabled={currentPage === 1}
                                                onClick={prevPage}
                                            >
                                                {t('common.previous', 'Précédent')}
                                            </Button>
                                            <span className="text-sm text-muted-foreground">
                                                {t('admin.documents.pagination.pageOf', 'Page {{current}} sur {{total}}', { current: currentPage, total: totalPages })}
                                            </span>
                                            <Button
                                                variant="outline"
                                                size="sm"
                                                disabled={currentPage >= totalPages}
                                                onClick={nextPage}
                                            >
                                                {t('common.next', 'Suivant')}
                                            </Button>
                                        </div>
                                    </div>
                                )}
                            </CardContent>
                        </Card>
                    </div>
                )}
            </main>
        </div>
    );
};
