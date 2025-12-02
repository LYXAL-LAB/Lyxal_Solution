import React, { useState, useMemo, useEffect } from 'react';
import { Search, ChevronUp, ChevronDown, Trash2, Edit, Eye, Download, Filter, Plus, X, ChevronLeft, ChevronRight, Upload, Grid3x3, List, Moon, Sun, Copy, Archive, Columns, FileText, Undo, Redo } from 'lucide-react';

export default function TableList() {
  const [searchTerm, setSearchTerm] = useState('');
  const [sortConfig, setSortConfig] = useState({ key: null, direction: 'asc' });
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(10);
  const [selectedRows, setSelectedRows] = useState([]);
  const [showFilters, setShowFilters] = useState(false);
  const [filterRole, setFilterRole] = useState('Tous');
  const [filterStatut, setFilterStatut] = useState('Tous');
  const [showAddModal, setShowAddModal] = useState(false);
  const [editingItem, setEditingItem] = useState(null);
  const [viewMode, setViewMode] = useState('table');
  const [darkMode, setDarkMode] = useState(false);
  const [showColumnSettings, setShowColumnSettings] = useState(false);
  const [toast, setToast] = useState(null);
  const [history, setHistory] = useState([]);
  const [historyIndex, setHistoryIndex] = useState(-1);
  const [visibleColumns, setVisibleColumns] = useState({ nom: true, prenom: true, email: true, role: true, statut: true });
  const [formData, setFormData] = useState({ nom: '', prenom: '', email: '', role: 'Développeur', statut: 'Actif' });
  const [data, setData] = useState([
    { id: 1, nom: 'Dupont', prenom: 'Jean', email: 'jean.dupont@email.com', role: 'Développeur', statut: 'Actif' },
    { id: 2, nom: 'Martin', prenom: 'Sophie', email: 'sophie.martin@email.com', role: 'Designer', statut: 'Actif' },
    { id: 3, nom: 'Bernard', prenom: 'Luc', email: 'luc.bernard@email.com', role: 'Manager', statut: 'Inactif' },
    { id: 4, nom: 'Dubois', prenom: 'Marie', email: 'marie.dubois@email.com', role: 'Développeur', statut: 'Actif' },
    { id: 5, nom: 'Thomas', prenom: 'Pierre', email: 'pierre.thomas@email.com', role: 'Testeur', statut: 'Actif' },
    { id: 6, nom: 'Petit', prenom: 'Claire', email: 'claire.petit@email.com', role: 'Designer', statut: 'Actif' },
    { id: 7, nom: 'Robert', prenom: 'Paul', email: 'paul.robert@email.com', role: 'Manager', statut: 'Inactif' },
    { id: 8, nom: 'Richard', prenom: 'Julie', email: 'julie.richard@email.com', role: 'Testeur', statut: 'Actif' },
  ]);

  const roles = ['Tous', 'Développeur', 'Designer', 'Manager', 'Testeur'];
  const statuts = ['Tous', 'Actif', 'Inactif'];

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const saveHistory = (newData) => {
    const newHist = history.slice(0, historyIndex + 1);
    newHist.push(JSON.parse(JSON.stringify(newData)));
    setHistory(newHist);
    setHistoryIndex(newHist.length - 1);
  };

  const undo = () => historyIndex > 0 && (setHistoryIndex(historyIndex - 1), setData(JSON.parse(JSON.stringify(history[historyIndex - 1]))), showToast('Annulé', 'info'));
  const redo = () => historyIndex < history.length - 1 && (setHistoryIndex(historyIndex + 1), setData(JSON.parse(JSON.stringify(history[historyIndex + 1]))), showToast('Rétabli', 'info'));

  const handleDelete = (id) => window.confirm('Supprimer ?') && (saveHistory(data.filter(i => i.id !== id)), setData(data.filter(i => i.id !== id)), showToast('Supprimé'));
  const handleDeleteSelected = () => window.confirm(`Supprimer ${selectedRows.length} ?`) && (saveHistory(data.filter(i => !selectedRows.includes(i.id))), setData(data.filter(i => !selectedRows.includes(i.id))), setSelectedRows([]), showToast('Supprimés'));
  const handleArchive = () => (saveHistory(data.map(i => selectedRows.includes(i.id) ? {...i, statut: 'Inactif'} : i)), setData(data.map(i => selectedRows.includes(i.id) ? {...i, statut: 'Inactif'} : i)), setSelectedRows([]), showToast('Archivés'));
  const handleDuplicate = () => {
    const items = data.filter(i => selectedRows.includes(i.id));
    const maxId = Math.max(...data.map(d => d.id), 0);
    const dup = items.map((i, idx) => ({...i, id: maxId + idx + 1, nom: `${i.nom} (copie)`}));
    saveHistory([...data, ...dup]);
    setData([...data, ...dup]);
    setSelectedRows([]);
    showToast('Dupliqués');
  };

  const handleExportCSV = () => {
    const h = Object.keys(visibleColumns).filter(k => visibleColumns[k]);
    const csv = [['ID', ...h.map(k => k.charAt(0).toUpperCase() + k.slice(1))].join(','), ...filteredData.map(i => [i.id, ...h.map(k => i[k])].join(','))].join('\n');
    const blob = new Blob([csv], {type: 'text/csv'});
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = 'export.csv';
    a.click();
    showToast('Exporté');
  };

  const handleAdd = () => {
    if (!formData.nom || !formData.prenom || !formData.email) return showToast('Champs requis', 'error');
    const newItem = {id: Math.max(...data.map(d => d.id), 0) + 1, ...formData};
    saveHistory([...data, newItem]);
    setData([...data, newItem]);
    setFormData({nom: '', prenom: '', email: '', role: 'Développeur', statut: 'Actif'});
    setShowAddModal(false);
    showToast('Ajouté');
  };

  const handleUpdate = () => {
    if (!formData.nom || !formData.prenom || !formData.email) return showToast('Champs requis', 'error');
    saveHistory(data.map(i => i.id === editingItem ? {...i, ...formData} : i));
    setData(data.map(i => i.id === editingItem ? {...i, ...formData} : i));
    setFormData({nom: '', prenom: '', email: '', role: 'Développeur', statut: 'Actif'});
    setShowAddModal(false);
    setEditingItem(null);
    showToast('Modifié');
  };

  const filteredData = useMemo(() => {
    let f = data.filter(i => Object.values(i).some(v => v.toString().toLowerCase().includes(searchTerm.toLowerCase())) && (filterRole === 'Tous' || i.role === filterRole) && (filterStatut === 'Tous' || i.statut === filterStatut));
    if (sortConfig.key) f.sort((a, b) => (a[sortConfig.key] < b[sortConfig.key] ? -1 : 1) * (sortConfig.direction === 'asc' ? 1 : -1));
    return f;
  }, [data, searchTerm, sortConfig, filterRole, filterStatut]);

  const totalPages = Math.ceil(filteredData.length / itemsPerPage);
  const paginatedData = filteredData.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage);

  const SortIcon = ({col}) => sortConfig.key !== col ? <ChevronUp className="w-4 h-4 opacity-30" /> : sortConfig.direction === 'asc' ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />;

  const bg = darkMode ? 'bg-gray-900' : 'bg-gradient-to-br from-slate-50 to-slate-100';
  const card = darkMode ? 'bg-gray-800' : 'bg-white';
  const txt = darkMode ? 'text-gray-100' : 'text-gray-900';
  const txt2 = darkMode ? 'text-gray-400' : 'text-gray-600';
  const border = darkMode ? 'border-gray-700' : 'border-gray-200';

  return (
    <div className={`min-h-screen ${bg} p-8`}>
      <div className="max-w-7xl mx-auto">
        {toast && <div className={`fixed top-4 right-4 z-50 px-6 py-4 rounded-lg shadow-lg ${toast.type === 'success' ? 'bg-green-600' : toast.type === 'error' ? 'bg-red-600' : 'bg-blue-600'} text-white`}>{toast.msg}</div>}
        
        <div className={`${card} rounded-xl shadow-lg overflow-hidden`}>
          <div className="bg-gradient-to-r from-blue-600 to-indigo-600 px-8 py-6">
            <div className="flex flex-wrap justify-between items-center gap-4">
              <div><h1 className="text-3xl font-bold text-white mb-2">Gestion Utilisateurs Pro</h1><p className="text-blue-100">Toutes fonctionnalités</p></div>
              <div className="flex gap-2">
                <button onClick={() => setDarkMode(!darkMode)} className="p-2 bg-white bg-opacity-20 text-white rounded-lg hover:bg-opacity-30">{darkMode ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}</button>
                <button onClick={undo} disabled={historyIndex <= 0} className="p-2 bg-white bg-opacity-20 text-white rounded-lg hover:bg-opacity-30 disabled:opacity-50"><Undo className="w-5 h-5" /></button>
                <button onClick={redo} disabled={historyIndex >= history.length - 1} className="p-2 bg-white bg-opacity-20 text-white rounded-lg hover:bg-opacity-30 disabled:opacity-50"><Redo className="w-5 h-5" /></button>
                <button onClick={() => (setShowAddModal(true), setEditingItem(null), setFormData({nom: '', prenom: '', email: '', role: 'Développeur', statut: 'Actif'}))} className="flex items-center gap-2 bg-white text-blue-600 px-4 py-2 rounded-lg font-semibold hover:bg-blue-50"><Plus className="w-5 h-5" />Ajouter</button>
              </div>
            </div>
          </div>

          <div className={`p-6 border-b ${border} space-y-4`}>
            <div className="flex flex-wrap gap-2 items-center justify-between">
              <div className="flex flex-wrap gap-2">
                <button onClick={() => setShowFilters(!showFilters)} className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium ${showFilters ? 'bg-blue-600 text-white' : 'bg-gray-100'}`}><Filter className="w-4 h-4" />Filtres</button>
                <button onClick={() => setShowColumnSettings(!showColumnSettings)} className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium ${showColumnSettings ? 'bg-blue-600 text-white' : 'bg-gray-100'}`}><Columns className="w-4 h-4" />Colonnes</button>
                <button onClick={handleExportCSV} className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg font-medium hover:bg-green-700"><Download className="w-4 h-4" />CSV</button>
                {selectedRows.length > 0 && (
                  <>
                    <button onClick={handleDuplicate} className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg font-medium hover:bg-blue-700"><Copy className="w-4 h-4" />Dupliquer ({selectedRows.length})</button>
                    <button onClick={handleArchive} className="flex items-center gap-2 px-4 py-2 bg-orange-600 text-white rounded-lg font-medium hover:bg-orange-700"><Archive className="w-4 h-4" />Archiver</button>
                    <button onClick={handleDeleteSelected} className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg font-medium hover:bg-red-700"><Trash2 className="w-4 h-4" />Supprimer</button>
                  </>
                )}
              </div>
              <div className="flex items-center gap-4">
                <div className="flex gap-2">
                  <button onClick={() => setViewMode('table')} className={`p-2 rounded-lg ${viewMode === 'table' ? 'bg-blue-600 text-white' : txt2}`}><List className="w-5 h-5" /></button>
                  <button onClick={() => setViewMode('grid')} className={`p-2 rounded-lg ${viewMode === 'grid' ? 'bg-blue-600 text-white' : txt2}`}><Grid3x3 className="w-5 h-5" /></button>
                </div>
                <select value={itemsPerPage} onChange={(e) => (setItemsPerPage(Number(e.target.value)), setCurrentPage(1))} className={`border ${border} ${card} ${txt} rounded-lg px-3 py-2`}>
                  <option value={5}>5</option><option value={10}>10</option><option value={25}>25</option><option value={50}>50</option>
                </select>
              </div>
            </div>

            <div className="relative">
              <Search className={`absolute left-4 top-1/2 transform -translate-y-1/2 ${txt2} w-5 h-5`} />
              <input type="text" placeholder="Rechercher..." value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} className={`w-full pl-12 pr-4 py-3 border ${border} ${card} ${txt} rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500`} />
            </div>

            {showColumnSettings && <div className={`flex flex-wrap gap-4 p-4 ${darkMode ? 'bg-gray-700' : 'bg-gray-50'} rounded-lg`}>{Object.keys(visibleColumns).map(c => <label key={c} className="flex items-center gap-2 cursor-pointer"><input type="checkbox" checked={visibleColumns[c]} onChange={(e) => setVisibleColumns({...visibleColumns, [c]: e.target.checked})} className="w-4 h-4" /><span className={`text-sm font-medium ${txt}`}>{c.charAt(0).toUpperCase() + c.slice(1)}</span></label>)}</div>}

            {showFilters && <div className={`flex flex-wrap gap-4 p-4 ${darkMode ? 'bg-gray-700' : 'bg-gray-50'} rounded-lg`}>
              <div className="flex-1 min-w-[200px]"><label className={`block text-sm font-medium ${txt} mb-2`}>Rôle</label><select value={filterRole} onChange={(e) => setFilterRole(e.target.value)} className={`w-full border ${border} ${card} ${txt} rounded-lg px-3 py-2`}>{roles.map(r => <option key={r}>{r}</option>)}</select></div>
              <div className="flex-1 min-w-[200px]"><label className={`block text-sm font-medium ${txt} mb-2`}>Statut</label><select value={filterStatut} onChange={(e) => setFilterStatut(e.target.value)} className={`w-full border ${border} ${card} ${txt} rounded-lg px-3 py-2`}>{statuts.map(s => <option key={s}>{s}</option>)}</select></div>
              <div className="flex items-end"><button onClick={() => (setFilterRole('Tous'), setFilterStatut('Tous'))} className={`px-4 py-2 ${txt2} font-medium`}>Réinitialiser</button></div>
            </div>}
          </div>

          {viewMode === 'table' ? (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className={darkMode ? 'bg-gray-700' : 'bg-gray-50'}>
                  <tr>
                    <th className="px-6 py-4 text-left w-12"><input type="checkbox" checked={selectedRows.length === paginatedData.length && paginatedData.length > 0} onChange={(e) => setSelectedRows(e.target.checked ? paginatedData.map(i => i.id) : [])} className="w-4 h-4" /></th>
                    {visibleColumns.nom && <th className="px-6 py-4 text-left"><button onClick={() => setSortConfig({key: 'nom', direction: sortConfig.key === 'nom' && sortConfig.direction === 'asc' ? 'desc' : 'asc'})} className={`flex items-center gap-2 font-semibold ${txt}`}>Nom<SortIcon col="nom" /></button></th>}
                    {visibleColumns.prenom && <th className="px-6 py-4 text-left"><button onClick={() => setSortConfig({key: 'prenom', direction: sortConfig.key === 'prenom' && sortConfig.direction === 'asc' ? 'desc' : 'asc'})} className={`flex items-center gap-2 font-semibold ${txt}`}>Prénom<SortIcon col="prenom" /></button></th>}
                    {visibleColumns.email && <th className="px-6 py-4 text-left"><button onClick={() => setSortConfig({key: 'email', direction: sortConfig.key === 'email' && sortConfig.direction === 'asc' ? 'desc' : 'asc'})} className={`flex items-center gap-2 font-semibold ${txt}`}>Email<SortIcon col="email" /></button></th>}
                    {visibleColumns.role && <th className="px-6 py-4 text-left"><button onClick={() => setSortConfig({key: 'role', direction: sortConfig.key === 'role' && sortConfig.direction === 'asc' ? 'desc' : 'asc'})} className={`flex items-center gap-2 font-semibold ${txt}`}>Rôle<SortIcon col="role" /></button></th>}
                    {visibleColumns.statut && <th className="px-6 py-4 text-left"><button onClick={() => setSortConfig({key: 'statut', direction: sortConfig.key === 'statut' && sortConfig.direction === 'asc' ? 'desc' : 'asc'})} className={`flex items-center gap-2 font-semibold ${txt}`}>Statut<SortIcon col="statut" /></button></th>}
                    <th className={`px-6 py-4 text-left font-semibold ${txt}`}>Actions</th>
                  </tr>
                </thead>
                <tbody className={`divide-y ${border}`}>
                  {paginatedData.map(i => (
                    <tr key={i.id} className={selectedRows.includes(i.id) ? 'bg-blue-50' : ''}>
                      <td className="px-6 py-4"><input type="checkbox" checked={selectedRows.includes(i.id)} onChange={() => setSelectedRows(selectedRows.includes(i.id) ? selectedRows.filter(r => r !== i.id) : [...selectedRows, i.id])} className="w-4 h-4" /></td>
                      {visibleColumns.nom && <td className={`px-6 py-4 font-medium ${txt}`}>{i.nom}</td>}
                      {visibleColumns.prenom && <td className={`px-6 py-4 ${txt}`}>{i.prenom}</td>}
                      {visibleColumns.email && <td className={`px-6 py-4 ${txt2}`}>{i.email}</td>}
                      {visibleColumns.role && <td className="px-6 py-4"><span className="inline-flex px-3 py-1 text-sm font-medium rounded-full bg-blue-100 text-blue-800">{i.role}</span></td>}
                      {visibleColumns.statut && <td className="px-6 py-4"><span className={`inline-flex px-3 py-1 text-sm font-medium rounded-full ${i.statut === 'Actif' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>{i.statut}</span></td>}
                      <td className="px-6 py-4"><div className="flex gap-2">
                        <button className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg"><Eye className="w-4 h-4" /></button>
                        <button onClick={() => (setEditingItem(i.id), setFormData(i), setShowAddModal(true))} className="p-2 text-green-600 hover:bg-green-50 rounded-lg"><Edit className="w-4 h-4" /></button>
                        <button onClick={() => handleDelete(i.id)} className="p-2 text-red-600 hover:bg-red-50 rounded-lg"><Trash2 className="w-4 h-4" /></button>
                      </div></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 p-6">
              {paginatedData.map(i => (
                <div key={i.id} className={`${card} border ${border} rounded-lg p-6 hover:shadow-lg transition-shadow`}>
                  <div className="flex justify-between items-start mb-4">
                    <div><h3 className={`text-lg font-bold ${txt}`}>{i.prenom} {i.nom}</h3><p className={`text-sm ${txt2}`}>{i.email}</p></div>
                    <input type="checkbox" checked={selectedRows.includes(i.id)} onChange={() => setSelectedRows(selectedRows.includes(i.id) ? selectedRows.filter(r => r !== i.id) : [...selectedRows, i.id])} className="w-4 h-4" />
                  </div>
                  <div className="flex gap-2 mb-4">
                    <span className="px-3 py-1 text-sm rounded-full bg-blue-100 text-blue-800">{i.role}</span>
                    <span className={`px-3 py-1 text-sm rounded-full ${i.statut === 'Actif' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>{i.statut}</span>
                  </div>
                  <div className="flex gap-2">
                    <button className="flex-1 p-2 text-blue-600 hover:bg-blue-50 rounded-lg"><Eye className="w-4 h-4 mx-auto" /></button>
                    <button onClick={() => (setEditingItem(i.id), setFormData(i), setShowAddModal(true))} className="flex-1 p-2 text-green-600 hover:bg-green-50 rounded-lg"><Edit className="w-4 h-4 mx-auto" /></button>
                    <button onClick={() => handleDelete(i.id)} className="flex-1 p-2 text-red-600 hover:bg-red-50 rounded-lg"><Trash2 className="w-4 h-4 mx-auto" /></button>
                  </div>
                </div>
              ))}
            </div>
          )}

          <div className={`px-6 py-4 ${darkMode ? 'bg-gray-700' : 'bg-gray-50'} border-t ${border} flex flex-wrap gap-4 items-center justify-between`}>
            <p className={`text-sm ${txt2}`}>Affichage {((currentPage - 1) * itemsPerPage) + 1}-{Math.min(currentPage * itemsPerPage, filteredData.length)} sur {filteredData.length}</p>
            <div className="flex gap-2">
              <button onClick={() => setCurrentPage(p => Math.max(1, p - 1))} disabled={currentPage === 1} className={`p-2 rounded-lg border ${border} hover:bg-gray-100 disabled:opacity-50`}><ChevronLeft className="w-5 h-5" /></button>
              {Array.from({length: totalPages}, (_, i) => i + 1).map(p => <button key={p} onClick={() => setCurrentPage(p)} className={`px-4 py-2 rounded-lg font-medium ${currentPage === p ? 'bg-blue-600 text-white' : `border ${border}`}`}>{p}</button>)}
              <button onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))} disabled={currentPage === totalPages} className={`p-2 rounded-lg border ${border} hover:bg-gray-100 disabled:opacity-50`}><ChevronRight className="w-5 h-5" /></button>
            </div>
          </div>
        </div>
      </div>

      {showAddModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className={`${card} rounded-xl shadow-2xl max-w-md w-full`}>
            <div className={`flex justify-between items-center p-6 border-b ${border}`}>
              <h2 className={`text-2xl font-bold ${txt}`}>{editingItem ? 'Modifier' : 'Nouvel'} utilisateur</h2>
              <button onClick={() => (setShowAddModal(false), setEditingItem(null))} className={txt2}><X className="w-6 h-6" /></button>
            </div>
            <div className="p-6 space-y-4">
              <div><label className={`block text-sm font-medium ${txt} mb-2`}>Nom *</label><input type="text" value={formData.nom} onChange={(e) => setFormData({...formData, nom: e.target.value})} className={`w-full border ${border} ${card} ${txt} rounded-lg px-4 py-2`} /></div>
              <div><label className={`block text-sm font-medium ${txt} mb-2`}>Prénom *</label><input type="text" value={formData.prenom} onChange={(e) => setFormData({...formData, prenom: e.target.value})} className={`w-full border ${border} ${card} ${txt} rounded-lg px-4 py-2`} /></div>
              <div><label className={`block text-sm font-medium ${txt} mb-2`}>Email *</label><input type="email" value={formData.email} onChange={(e) => setFormData({...formData, email: e.target.value})} className={`w-full border ${border} ${card} ${txt} rounded-lg px-4 py-2`} /></div>
              <div><label className={`block text-sm font-medium ${txt} mb-2`}>Rôle</label><select value={formData.role} onChange={(e) => setFormData({...formData, role: e.target.value})} className={`w-full border ${border} ${card} ${txt} rounded-lg px-4 py-2`}>{roles.filter(r => r !== 'Tous').map(r => <option key={r}>{r}</option>)}</select></div>
              <div><label className={`block text-sm font-medium ${txt} mb-2`}>Statut</label><select value={formData.statut} onChange={(e) => setFormData({...formData, statut: e.target.value})} className={`w-full border ${border} ${card} ${txt} rounded-lg px-4 py-2`}>{statuts.filter(s => s !== 'Tous').map(s => <option key={s}>{s}</option>)}</select></div>
            </div>
            <div className={`flex gap-3 p-6 border-t ${border}`}>
              <button onClick={() => (setShowAddModal(false), setEditingItem(null))} className={`flex-1 px-4 py-2 border ${border} rounded-lg font-medium hover:bg-gray-50`}>Annuler</button>
              <button onClick={editingItem ? handleUpdate : handleAdd} className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg font-medium hover:bg-blue-700">{editingItem ? 'Modifier' : 'Ajouter'}</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}