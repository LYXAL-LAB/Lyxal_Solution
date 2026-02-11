import React from 'react';

// --- Sub-Components ---

// Composant pour les badges "What's Included" pour éviter la répétition
const FeatureBadge = ({ title, icon }: { title: string; icon: React.ReactNode }) => (
  <div className="bg-base-100 rounded-box border-base-content/20 flex items-center justify-center gap-1.5 border px-3 py-2">
    <div className="avatar avatar-placeholder">
      <div className="bg-primary/10 text-primary rounded-lg w-8 h-8 flex items-center justify-center">
        {icon}
      </div>
    </div>
    <span className="text-base-content font-medium">{title}</span>
  </div>
);

export default function PricingPlanSelector() {
  return (
    <section className="bg-base-200 py-8 sm:py-16 lg:py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        {/* Header */}
        <div className="mb-12 flex flex-col items-center space-y-4 text-center sm:mb-16 lg:mb-24">
          <h2 className="text-base-content text-2xl font-semibold md:text-3xl lg:text-4xl">
            Select the Best Plan for You!
          </h2>
          <p className="text-base-content/80 text-xl">
            Discover Our Flexible Plans, Compare Features, and Choose the Ideal Option for Your Needs.
          </p>
        </div>

        <div className="space-y-10">
          {/* Pricing Options (Radio Cards) */}
          <div className="flex items-center justify-center gap-6 max-sm:flex-col">
            
            {/* Starter Plan */}
            <label className="cursor-pointer bg-base-100 group has-[:checked]:shadow-xl has-[:checked]:ring-2 has-[:checked]:ring-primary w-full p-6 rounded-box transition-all sm:max-w-md">
              <span className="flex items-center gap-5">
                <span className="text-base-content group-has-[:checked]:text-primary flex-1 text-3xl font-semibold">
                  Starter
                </span>
                <input type="radio" name="pricing_plan" className="radio radio-primary" defaultChecked />
              </span>
              <span className="divider my-6"></span>
              <span className="flex flex-col">
                <span className="text-base-content group-has-[:checked]:text-primary text-3xl font-semibold">
                  $99
                  <span className="group-has-[:checked]:text-base-content/80 text-base-content/50 text-lg font-normal ml-1">
                    /month
                  </span>
                </span>
                <span className="group-has-[:checked]:text-base-content text-base-content/50 text-base mt-1">
                  Ideal for Beginner owners.
                </span>
              </span>
            </label>

            {/* Lifetime Deal */}
            <label className="cursor-pointer bg-base-100 group has-[:checked]:shadow-xl has-[:checked]:ring-2 has-[:checked]:ring-primary w-full p-6 rounded-box transition-all sm:max-w-md">
              <span className="flex items-center gap-5">
                <span className="text-base-content group-has-[:checked]:text-primary flex-1 text-3xl font-semibold">
                  Lifetime Deal
                </span>
                <input type="radio" name="pricing_plan" className="radio radio-primary" />
              </span>
              <span className="divider my-6"></span>
              <span className="flex flex-col">
                <span className="text-base-content group-has-[:checked]:text-primary text-3xl font-semibold">
                  $199
                  <span className="group-has-[:checked]:text-base-content/80 text-base-content/50 text-lg font-normal ml-1">
                    One Time Payment
                  </span>
                </span>
                <span className="group-has-[:checked]:text-base-content text-base-content/50 text-base mt-1">
                  Ideal for Long-term projects.
                </span>
              </span>
            </label>
          </div>

          {/* Features Divider */}
          <div className="divider divider-dotted text-base font-medium opacity-70">What’s Included</div>

          {/* Features Badges */}
          <div className="flex flex-wrap items-center justify-center gap-4">
            
            <FeatureBadge 
              title="Components"
              icon={
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                  <path fillRule="evenodd" clipRule="evenodd" d="M3 12L6 15L9 12L6 9L3 12Z" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
                  <path fillRule="evenodd" clipRule="evenodd" d="M15 12L18 15L21 12L18 9L15 12Z" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
                  <path fillRule="evenodd" clipRule="evenodd" d="M9 6L12 9L15 6L12 3L9 6Z" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
                  <path fillRule="evenodd" clipRule="evenodd" d="M9 18L12 21L15 18L12 15L9 18Z" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
              }
            />

            <FeatureBadge 
              title="Templates"
              icon={
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M21 12V15C21 15.5523 20.5523 16 20 16H4C3.44772 16 3 15.5523 3 15V5C3 4.44772 3.44772 4 4 4H13" />
                  <path d="M7 20H17" />
                  <path d="M9 16V20" />
                  <path d="M15 16V20" />
                  <path d="M17 4H21V8" />
                  <path d="M16 9L21 4" />
                </svg>
              }
            />

            <FeatureBadge 
              title="Full Pages"
              icon={
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M14 3V7C14 7.55228 14.4477 8 15 8H19" />
                  <path fillRule="evenodd" clipRule="evenodd" d="M17 21H7C5.89543 21 5 20.1046 5 19V5C5 3.89543 5.89543 3 7 3H14L19 8V19C19 20.1046 18.1046 21 17 21Z" />
                </svg>
              }
            />

            <FeatureBadge 
              title="Dashboard"
              icon={
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                  <rect x="3" y="4" width="18" height="12" rx="1" />
                  <path d="M7 20H17" />
                  <path d="M9 16V20" />
                  <path d="M15 16V20" />
                  <path d="M9 12V8" />
                  <path d="M12 12V11" />
                  <path d="M15 12V10" />
                  <path d="M12 12V11" />
                </svg>
              }
            />

          </div>

          {/* CTA Button */}
          <div className="flex items-center justify-center mt-10">
            <button className="btn btn-primary btn-lg gap-2 shadow-lg hover:shadow-primary/50 transition-shadow">
              Choose Plan
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M5 12l14 0" />
                <path d="M13 18l6 -6" />
                <path d="M13 6l6 6" />
              </svg>
            </button>
          </div>

        </div>
      </div>
    </section>
  );
}

