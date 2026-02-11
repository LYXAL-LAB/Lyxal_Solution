// components/LegalEditCategoryForm.jsx
// Formulaire d'édition de catégorie juridique
import { useState, useEffect } from 'react';
import { useSurrealDB } from '../hooks/useSurrealDB';

export function LegalEditCategoryForm({ categoryId, initialData, onSuccess, onCancel }) {
  const [formData, setFormData] = useState({
    name: initialData?.name || '',
    code: initialData?.code || '',
    description: initialData?.description || '',
    parentId: initialData?.parent_category || null,
    active: initialData?.active ?? true
  });
  const [loading, setLoading] = useState(false);
  const [categories, setCategories] = useState([]);
  const { db } = useSurrealDB();

  // Charger la liste des catégories pour le sélecteur parent
  useEffect(() => {
    const loadCategories = async () => {
      try {
        const result = await db.query(`
          SELECT id, name, level, parent_category 
          FROM legal_category 
          WHERE id != ${categoryId} AND active = true
          ORDER BY level, name
        `);
        setCategories(result[0] || []);
      } catch (error) {
        console.error('Erreur chargement catégories:', error);
      }
    };
    
    if (db) {
      loadCategories();
    }
  }, [db, categoryId]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      const result = await db.query(`
        RETURN fn::update_legal_category(
          ${categoryId},
          ${formData.name !== initialData?.name ? `'${formData.name}'` : 'NULL'},
          ${formData.code !== initialData?.code ? `'${formData.code}'` : 'NULL'},
          ${formData.description !== initialData?.description ? `'${formData.description}'` : 'NULL'},
          ${formData.parentId !== initialData?.parent_category ? (formData.parentId || 'NONE') : 'NULL'},
          ${formData.active !== initialData?.active ? formData.active : 'NULL'}
        )
      `);
      
      if (result[0]) {
        // Success avec DaisyUI toast
        toast.success(`Catégorie "${result[0].name}" mise à jour (Level ${result[0].level})`);
        onSuccess?.(result[0]);
      }
    } catch (error) {
      console.error('Erreur mise à jour:', error);
      toast.error('Erreur lors de la mise à jour');
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setFormData({
      name: initialData?.name || '',
      code: initialData?.code || '',
      description: initialData?.description || '',
      parentId: initialData?.parent_category || null,
      active: initialData?.active ?? true
    });
  };

  return (
    <div className="card w-96 bg-base-100 shadow-xl">
      <div className="card-body">
        <h2 className="card-title">Modifier Catégorie Juridique</h2>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="form-control">
            <label className="label">
              <span className="label-text">Nom</span>
            </label>
            <input 
              type="text" 
              className="input input-bordered" 
              value={formData.name}
              onChange={(e) => setFormData({...formData, name: e.target.value})}
              required 
            />
          </div>

          <div className="form-control">
            <label className="label">
              <span className="label-text">Code</span>
            </label>
            <input 
              type="text" 
              className="input input-bordered" 
              value={formData.code}
              onChange={(e) => setFormData({...formData, code: e.target.value})}
              required 
            />
          </div>

          <div className="form-control">
            <label className="label">
              <span className="label-text">Description</span>
            </label>
            <textarea 
              className="textarea textarea-bordered" 
              value={formData.description}
              onChange={(e) => setFormData({...formData, description: e.target.value})}
              rows="3"
            />
          </div>

          <div className="form-control">
            <label className="label">
              <span className="label-text">Catégorie Parent</span>
            </label>
            <select 
              className="select select-bordered"
              value={formData.parentId || ''}
              onChange={(e) => setFormData({...formData, parentId: e.target.value || null})}
            >
              <option value="">Catégorie racine</option>
              {categories.map(cat => (
                <option key={cat.id} value={cat.id}>
                  {'  '.repeat(cat.level - 1)}📁 {cat.name} (Level {cat.level})
                </option>
              ))}
            </select>
          </div>

          <div className="form-control">
            <label className="label cursor-pointer">
              <span className="label-text">Statut</span>
              <input 
                type="checkbox" 
                className="toggle toggle-primary" 
                checked={formData.active}
                onChange={(e) => setFormData({...formData, active: e.target.checked})}
              />
            </label>
            <div className="label">
              <span className="label-text-alt">
                {formData.active ? '🟢 Actif' : '🔴 Inactif'}
              </span>
            </div>
          </div>

          <div className="card-actions justify-between">
            <div className="flex gap-2">
              <button 
                type="button" 
                className="btn btn-ghost"
                onClick={handleReset}
              >
                Réinitialiser
              </button>
              <button 
                type="button" 
                className="btn btn-outline"
                onClick={onCancel}
              >
                Annuler
              </button>
            </div>
            <button 
              type="submit" 
              className={`btn btn-primary ${loading ? 'loading' : ''}`}
              disabled={loading}
            >
              {loading ? 'Mise à jour...' : 'Mettre à jour'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

// Hook personnalisé pour utiliser le composant d'édition
export function useLegalCategoryEdit() {
  const { db } = useSurrealDB();
  
  const updateCategory = async (categoryId, formData) => {
    try {
      const result = await db.query(`
        RETURN fn::update_legal_category(
          ${categoryId},
          '${formData.name}',
          '${formData.code}',
          '${formData.description}',
          ${formData.parentId || 'NONE'},
          ${formData.active}
        )
      `);
      
      return {
        success: true,
        data: result[0],
        message: `Catégorie "${result[0]?.name}" mise à jour avec succès`
      };
    } catch (error) {
      return {
        success: false,
        error: error.message,
        message: 'Erreur lors de la mise à jour de la catégorie'
      };
    }
  };
  
  return { updateCategory };
} 