import React from 'react';
import { HiOutlineExclamationCircle } from 'react-icons/hi';

interface ErrorSectionProps {
  error: string;
  className?: string;
  title?: string;
}

export const ErrorSection: React.FC<ErrorSectionProps> = ({
  error,
  className = '',
  title = 'Erreur de connexion'
}) => {
  return (
    <section id="error-wrapper" className={`w-full flex justify-center ${className}`} style={{ paddingTop: '2rem', paddingBottom: '2rem' }} aria-labelledby="error-title">
      <div id="error-container" className="w-[90%] mx-auto">
        <div id="error-content" className="w-full flex justify-center">
          {/* Grille responsive pour conformité */}
          <div className="grid grid-cols-1 gap-4 w-full max-w-4xl">
            <div id="error-alert-wrapper" className="w-full">
              <div 
                id="error-alert" 
                className="bg-base-200 shadow-xl rounded-2xl border border-base-300 hover:shadow-2xl transition-all duration-300 p-6 alert alert-error"
                role="alert"
                aria-labelledby="error-title"
                aria-describedby="error-message"
              >
                <div id="error-icon-wrapper" className="flex-shrink-0" aria-hidden="true">
                  <HiOutlineExclamationCircle className="stroke-current shrink-0 h-6 w-6" />
                </div>
                
                <div id="error-text-content" className="flex flex-col gap-2">
                  <h3 id="error-title" className="text-3xl lg:text-4xl font-bold">
                    {title}
                  </h3>
                  <div id="error-message" className="text-base lg:text-lg">
                    {error}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}; 