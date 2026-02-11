import { useParams, useNavigate } from 'react-router-dom';
import { useEffect, useState } from 'react';
import { RouteService } from '@/services/RouteService';
import { StudioRoute } from '@/lib/studio/types/route';
import { RouteForm } from './components/RouteForm';
import { Button } from '@/components/ui/button';
import { ArrowLeft, Loader2 } from 'lucide-react';

export const RouteDetails = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [route, setRoute] = useState<StudioRoute | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const loadRoute = async () => {
      if (!id) return;

      try {
        setLoading(true);
        const routeData = await RouteService.getRouteById(id);
        setRoute(routeData);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to load route');
      } finally {
        setLoading(false);
      }
    };

    loadRoute();
  }, [id]);

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="flex items-center space-x-2">
          <Loader2 className="w-6 h-6 animate-spin" />
          <span>Loading route...</span>
        </div>
      </div>
    );
  }

  if (error || !route) {
    return (
      <div className="min-h-screen bg-gray-50 p-6">
        <div className="max-w-2xl mx-auto">
          <Button
            variant="ghost"
            onClick={() => navigate('/admin/routes')}
            className="mb-4"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Routes
          </Button>

          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
            {error || 'Route not found'}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <RouteForm route={route} />
    </div>
  );
};
