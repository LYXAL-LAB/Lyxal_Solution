import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Plus, Pencil, Trash2, ToggleLeft, ToggleRight, BadgeCheck, Loader2 } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../components/ui/Table';
import { Alert, AlertDescription } from '../../components/ui/Alert';
import { api } from '../../lib/api';

interface Webhook {
    id: number;
    title: string;
    targetUrl: string;
    events: string[];
    active: boolean;
    description?: string;
}

export const AdminWebhooks: React.FC = () => {
    const { t } = useTranslation();
    const navigate = useNavigate();

    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [items, setItems] = useState<Webhook[]>([]);
    const [deleting, setDeleting] = useState<number | null>(null);
    const [toggling, setToggling] = useState<number | null>(null);

    const load = async () => {
        try {
            setLoading(true);
            setError('');
            const data = await api.get<Webhook[]>('/admin/webhooks');
            setItems(data);
        } catch (err: any) {
            setError(err.response?.data?.error?.message || err.message || 'Failed to load webhooks');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        load();
    }, []);

    const onDelete = async (id: number) => {
        if (!window.confirm(t('admin.webhooks.confirmDelete', 'Êtes-vous sûr de vouloir supprimer ce webhook ?'))) return;
        try {
            setDeleting(id);
            await api.delete(`/admin/webhooks/${id}`);
            await load();
        } catch (err: any) {
            setError(err.response?.data?.error?.message || err.message || 'Failed to delete webhook');
        } finally {
            setDeleting(null);
        }
    };

    const onToggle = async (id: number, enable: boolean) => {
        try {
            setToggling(id);
            await api.patch(`/admin/webhooks/${id}/toggle`, { active: enable });
            await load();
        } catch (err: any) {
            setError(err.response?.data?.error?.message || err.message || 'Failed to toggle webhook');
        } finally {
            setToggling(null);
        }
    };

    const formatEvents = (evts: string[]) => {
        return evts.map(e => t(`admin.webhooks.eventsMap.${e}`, e));
    };

    return (
        <div className="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
            <div className="mb-8 flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold">{t('admin.webhooks.title', 'Webhooks')}</h1>
                    <p className="text-muted-foreground">{t('admin.webhooks.subtitle', 'Gérez les notifications automatiques')}</p>
                </div>
                <Button onClick={() => navigate('/admin/webhooks/new')}>
                    <Plus size={16} className="mr-2" />
                    {t('admin.webhooks.new', 'Nouveau Webhook')}
                </Button>
            </div>

            {error && (
                <Alert variant="destructive" className="mb-4">
                    <AlertDescription>{error}</AlertDescription>
                </Alert>
            )}

            <Card className="clay-card">
                <CardHeader>
                    <CardTitle>{t('admin.webhooks.listTitle', 'Liste des Webhooks')}</CardTitle>
                    <CardDescription>{t('admin.webhooks.listSubtitle', 'Webhooks configurés pour votre instance')}</CardDescription>
                </CardHeader>
                <CardContent>
                    {loading ? (
                        <div className="flex items-center gap-3 py-10">
                            <Loader2 size={24} className="animate-spin" />
                            <span>{t('admin.loading', 'Chargement...')}</span>
                        </div>
                    ) : items.length > 0 ? (
                        <div className="rounded-md border border-border/40 overflow-hidden">
                            <Table>
                                <TableHeader>
                                    <TableRow>
                                        <TableHead>{t('admin.webhooks.columns.title', 'Nom')}</TableHead>
                                        <TableHead>{t('admin.webhooks.columns.url', 'URL Cible')}</TableHead>
                                        <TableHead>{t('admin.webhooks.columns.events', 'Événements')}</TableHead>
                                        <TableHead>{t('admin.webhooks.columns.status', 'Statut')}</TableHead>
                                        <TableHead className="text-right">{t('admin.webhooks.columns.actions', 'Actions')}</TableHead>
                                    </TableRow>
                                </TableHeader>
                                <TableBody>
                                    {items.map(wh => (
                                        <TableRow key={wh.id}>
                                            <TableCell>
                                                <div className="font-medium">{wh.title || '-'}</div>
                                                {wh.description && <div className="text-xs text-muted-foreground">{wh.description}</div>}
                                            </TableCell>
                                            <TableCell>
                                                <a href={wh.targetUrl} target="_blank" rel="noopener noreferrer" className="text-primary hover:underline">{wh.targetUrl}</a>
                                            </TableCell>
                                            <TableCell>
                                                <div className="flex flex-wrap gap-1">
                                                    {formatEvents(wh.events).map(e => (
                                                        <span key={e} className="px-2 py-0.5 text-xs rounded bg-muted">{e}</span>
                                                    ))}
                                                </div>
                                            </TableCell>
                                            <TableCell>
                                                {wh.active ? (
                                                    <span className="inline-flex items-center text-green-600"><BadgeCheck size={16} className="mr-1" />{t('admin.webhooks.status.enabled', 'Actif')}</span>
                                                ) : (
                                                    <span className="inline-flex items-center text-muted-foreground">{t('admin.webhooks.status.disabled', 'Inactif')}</span>
                                                )}
                                            </TableCell>
                                            <TableCell className="text-right">
                                                <div className="flex items-center justify-end gap-2">
                                                    <Button variant="outline" size="sm" onClick={() => navigate(`/admin/webhooks/${wh.id}`)}>
                                                        <Pencil size={14} className="mr-1" /> {t('admin.webhooks.edit', 'Éditer')}
                                                    </Button>
                                                    <Button variant="outline" size="sm" onClick={() => onToggle(wh.id, !wh.active)} disabled={toggling === wh.id}>
                                                        {toggling === wh.id ? (
                                                            <Loader2 size={14} className="mr-1 animate-spin" />
                                                        ) : !wh.active ? (
                                                            <ToggleRight size={14} className="mr-1" />
                                                        ) : (
                                                            <ToggleLeft size={14} className="mr-1" />
                                                        )}
                                                        {wh.active ? t('admin.webhooks.disable', 'Désactiver') : t('admin.webhooks.enable', 'Activer')}
                                                    </Button>
                                                    <Button variant="destructive" size="sm" onClick={() => onDelete(wh.id)} disabled={deleting === wh.id}>
                                                        {deleting === wh.id ? (
                                                            <Loader2 size={14} className="mr-1 animate-spin" />
                                                        ) : (
                                                            <Trash2 size={14} className="mr-1" />
                                                        )}
                                                        {t('admin.webhooks.delete', 'Supprimer')}
                                                    </Button>
                                                </div>
                                            </TableCell>
                                        </TableRow>
                                    ))}
                                </TableBody>
                            </Table>
                        </div>
                    ) : (
                        <div className="py-10 text-center text-muted-foreground">{t('admin.webhooks.empty', 'Aucun webhook configuré')}</div>
                    )}
                </CardContent>
            </Card>
        </div>
    );
};
