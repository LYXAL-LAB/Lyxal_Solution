/**
 * 🏛️ LYXAL WORKSPACE — Panneau de Gestion Admin des Utilisateurs
 */

import React, { useEffect, useState } from 'react';
import { tenantAdminClient } from '../../sdk/admin/tenant_admin.client';
import { TenantAdminUserItem } from '../../sdk/admin/admin.types';
import { useToast } from '../../components/Toast';

export const UsersAdminPanel: React.FC = () => {
  const { addToast } = useToast();
  const [users, setUsers] = useState<TenantAdminUserItem[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [editingUserId, setEditingUserId] = useState<string | null>(null);
  const [selectedRole, setSelectedRole] = useState<string>('member');
  const [updating, setUpdating] = useState<boolean>(false);

  const loadUsers = async () => {
    setLoading(true);
    try {
      const res = await tenantAdminClient.listUsers(50);
      setUsers(res.users);
    } catch (err: unknown) {
      addToast('error', 'Erreur Utilisateurs', 'Échec du chargement de la liste des utilisateurs.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadUsers();
  }, []);

  const handleUpdateRole = async (userId: string) => {
    setUpdating(true);
    try {
      await tenantAdminClient.updateUserRole(userId, { role: selectedRole });
      addToast('success', 'Rôle Mis à Jour', `Le rôle de l'utilisateur a été modifié en ${selectedRole}.`);
      setEditingUserId(null);
      loadUsers();
    } catch (err: unknown) {
      addToast('error', 'Échec Modification', 'Impossible de modifier le rôle de cet utilisateur.');
    } finally {
      setUpdating(false);
    }
  };

  if (loading) {
    return (
      <div className="p-8 text-center text-slate-400 text-xs">
        <div className="w-5 h-5 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin mx-auto mb-2"></div>
        Chargement de la liste des utilisateurs...
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between border-b border-slate-800 pb-4">
        <div>
          <h3 className="text-lg font-bold text-white">Gestion des Utilisateurs & Rôles</h3>
          <p className="text-xs text-slate-400 mt-1">
            Gérez les privilèges et rôles des membres de l'organisation.
          </p>
        </div>
      </div>

      <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
        <table className="w-full text-left text-xs">
          <thead className="bg-slate-950/80 border-b border-slate-800 text-slate-400 font-semibold uppercase tracking-wider">
            <tr>
              <th className="p-4">Utilisateur</th>
              <th className="p-4">Adresse E-mail</th>
              <th className="p-4">Rôle</th>
              <th className="p-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-800 text-slate-300">
            {users.length === 0 ? (
              <tr>
                <td colSpan={4} className="p-6 text-center text-slate-400">
                  Aucun utilisateur trouvé.
                </td>
              </tr>
            ) : (
              users.map((user) => (
                <tr key={user.id} className="hover:bg-slate-950/40 transition">
                  <td className="p-4 font-bold text-slate-100">{user.name || 'Utilisateur'}</td>
                  <td className="p-4 font-mono text-slate-400">{user.email}</td>
                  <td className="p-4 font-mono uppercase font-bold text-indigo-400">{user.role}</td>
                  <td className="p-4 text-right">
                    {editingUserId === user.id ? (
                      <div className="flex items-center justify-end gap-2">
                        <select
                          value={selectedRole}
                          onChange={(e) => setSelectedRole(e.target.value)}
                          className="px-2 py-1 bg-slate-950 border border-slate-800 rounded text-xs text-slate-200"
                        >
                          <option value="member">member</option>
                          <option value="admin">admin</option>
                          <option value="owner">owner</option>
                        </select>
                        <button
                          onClick={() => handleUpdateRole(user.id)}
                          disabled={updating}
                          className="px-3 py-1 bg-indigo-600 hover:bg-indigo-500 text-white font-bold rounded transition disabled:opacity-50"
                        >
                          Enregistrer
                        </button>
                        <button
                          onClick={() => setEditingUserId(null)}
                          className="px-2 py-1 bg-slate-800 text-slate-400 rounded"
                        >
                          Annuler
                        </button>
                      </div>
                    ) : (
                      <button
                        onClick={() => {
                          setEditingUserId(user.id);
                          setSelectedRole(user.role);
                        }}
                        className="px-3 py-1 bg-slate-800 hover:bg-slate-700 text-slate-200 font-semibold rounded transition"
                      >
                        Changer Rôle
                      </button>
                    )}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};
