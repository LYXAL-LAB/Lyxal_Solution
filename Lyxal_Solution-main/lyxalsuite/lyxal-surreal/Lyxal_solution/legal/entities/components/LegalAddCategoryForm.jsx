// components/LegalAddCategoryForm.jsx
// Formulaire de création de catégorie juridique
import { useState } from 'react';
import { useSurrealDB } from '../hooks/useSurrealDB';

export function LegalAddCategoryForm() {
  const [formData, setFormData] = useState({
    name: '',
    code: '',
    description: '',
    parentId: null
  });
  const [loading, setLoading] = useState(false);
  const { db } = useSurrealDB();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      const result = await db.query(`
        RETURN fn::add_legal_category(
          '${formData.name}',
          '${formData.code}',
          '${formData.description}',
          ${formData.parentId || 'NONE'}
        )
      `);
      
      if (result[0]) {
        // Success avec DaisyUI toast
        toast.success(`Catégorie "${result[0].name}" créée (Level ${result[0].level})`);
        setFormData({ name: '', code: '', description: '', parentId: null });
      }
    } catch (error) {
      toast.error('Erreur lors de la création');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="card w-96 bg-base-100 shadow-xl">
      <div className="card-body">
        <h2 className="card-title">Nouvelle Catégorie Juridique</h2>
        
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

          <div className="card-actions justify-end">
            <button 
              type="submit" 
              className={`btn btn-primary ${loading ? 'loading' : ''}`}
              disabled={loading}
            >
              {loading ? 'Création...' : 'Créer Catégorie'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}