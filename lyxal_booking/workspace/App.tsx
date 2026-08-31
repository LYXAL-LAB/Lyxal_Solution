/**
 * 🏛️ LYXAL WORKSPACE — Application React Principale
 */

import React, { useState } from 'react';
import { AppShell } from './layout/AppShell';
import { UserSettingsPage } from './modules/users/UserSettingsPage';
import { CalendarsPage } from './modules/calendars/CalendarsPage';
import { ResourcesPage } from './modules/resources/ResourcesPage';
import { EventTypesPage } from './modules/event-types/EventTypesPage';
import { AvailabilityPage } from './modules/availability/AvailabilityPage';
import { TeamsPage } from './modules/teams/TeamsPage';
import { BookingsPage } from './modules/bookings/BookingsPage';
import { PublicBookingPage } from './modules/public-booking/PublicBookingPage';
import { AdminPage } from './modules/admin/AdminPage';

export const App: React.FC = () => {
  const [activeModule, setActiveModule] = useState<string>('users');

  return (
    <AppShell activeModule={activeModule} onNavigate={setActiveModule}>
      {activeModule === 'users' && <UserSettingsPage />}
      {activeModule === 'calendars' && <CalendarsPage />}
      {activeModule === 'resources' && <ResourcesPage />}
      {activeModule === 'event-types' && <EventTypesPage />}
      {activeModule === 'availability' && <AvailabilityPage />}
      {activeModule === 'teams' && <TeamsPage />}
      {activeModule === 'bookings' && <BookingsPage />}
      {activeModule === 'public-booking' && <PublicBookingPage />}
      {activeModule === 'admin' && <AdminPage />}
      {activeModule !== 'users' &&
        activeModule !== 'calendars' &&
        activeModule !== 'resources' &&
        activeModule !== 'event-types' &&
        activeModule !== 'availability' &&
        activeModule !== 'teams' &&
        activeModule !== 'bookings' &&
        activeModule !== 'public-booking' &&
        activeModule !== 'admin' && (
          <div className="p-8 bg-slate-900 border border-slate-800 rounded-xl text-center">
            <h3 className="text-xl font-bold text-slate-200 capitalize">Module {activeModule.replace('-', ' ')}</h3>
            <p className="text-sm text-slate-400 mt-2">
              Le backend et l'API v1 de ce module sont <span className="text-amber-400 font-semibold">READY FOR UI</span>. L'écran frontend sera branché dans les prochaines étapes.
            </p>
          </div>
        )}
    </AppShell>
  );
};

export default App;
