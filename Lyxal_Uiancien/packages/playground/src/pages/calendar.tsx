import React from 'react';
import { Main } from '../layouts';
import { Pikaday, PikadayVue, ReactDayPicker } from '../components';

const CalendarPage: React.FC = () => {
  return (
    <Main theme="light">
      <div className="p-8">
        <h2 className="text-2xl font-bold mb-6">Calendar Components</h2>
        <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
          <div className="card bg-base-100 shadow-xl">
            <div className="card-body">
              <h3 className="card-title">Pikaday (React)</h3>
              <Pikaday format="YYYY-MM-DD" />
            </div>
          </div>
          <div className="card bg-base-100 shadow-xl">
            <div className="card-body">
              <h3 className="card-title">Pikaday (Vue-style)</h3>
              <PikadayVue format="DD/MM/YYYY" />
            </div>
          </div>
          <div className="card bg-base-100 shadow-xl">
            <div className="card-body">
              <h3 className="card-title">React Day Picker</h3>
              <ReactDayPicker />
            </div>
          </div>
        </div>
        <div className="mt-8">
          <div className="alert alert-info">
            <div>
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" className="stroke-current h-6 w-6 flex-shrink-0">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
              <span>These calendar components demonstrate different date picker implementations for Lyxal UI.</span>
            </div>
          </div>
        </div>
      </div>
    </Main>
  );
};

export default CalendarPage;
