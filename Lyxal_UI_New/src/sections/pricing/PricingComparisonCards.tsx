import React from 'react';

// --- Sub-Components ---

const CheckIcon = () => (
  <span className="icon-[tabler--check] text-primary mt-0.5 size-5 shrink-0">
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M5 12l5 5l10 -10"></path>
    </svg>
  </span>
);

const CrossIcon = () => (
  <span className="icon-[tabler--x] text-error mt-0.5 size-5 shrink-0">
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M18 6l-12 12"></path>
      <path d="M6 6l12 12"></path>
    </svg>
  </span>
);

// Icone Cross avec couleur primaire (pour le plan Startup)
const CrossIconPrimary = () => (
  <span className="icon-[tabler--x] text-primary mt-0.5 size-6 shrink-0">
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M18 6l-12 12"></path>
      <path d="M6 6l12 12"></path>
    </svg>
  </span>
);

const FeatureRow = ({ 
  icon, 
  title, 
  description 
}: { 
  icon: React.ReactNode; 
  title: string; 
  description: string;
}) => (
  <>
    <div className="flex items-start gap-3">
      {icon}
      <div>
        <span className="block text-base-content font-semibold mb-0.5">{title}</span>
        <span className="text-base-content/80">{description}</span>
      </div>
    </div>
    <div className="divider my-4"></div>
  </>
);

export default function PricingComparisonCards() {
  return (
    <section className="bg-base-100 py-8 sm:py-16 lg:py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        {/* Header */}
        <div className="mb-12 flex flex-col items-center space-y-4 text-center sm:mb-16 lg:mb-24">
          <p className="text-primary font-medium">Pricing Details</p>
          <h2 className="text-base-content text-3xl font-semibold md:text-3xl lg:text-4xl">
            Pay only for what suits you
          </h2>
          <p className="text-base-content/80 text-xl">Join a community of innovative businesses</p>
        </div>

        {/* Pricing Cards Container */}
        <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3 items-start">

          {/* Free Plan */}
          <div className="flex flex-col gap-6">
            {/* Card Header Part */}
            <div className="card border-2 border-base-content/20 rounded-3xl overflow-hidden relative">
              <div className="card-body p-8 gap-6">
                <h3 className="text-2xl font-semibold text-base-content mb-4">Free Plan</h3>
                
                <div className="flex items-baseline gap-1 mb-4">
                  <span className="text-base-content/80 text-lg font-medium">$</span>
                  <span className="text-base-content text-4xl font-bold">0</span>
                </div>

                <p className="text-base-content/80 mb-8 min-h-[3rem]">
                  Recommended for people with atleast 1 year experience in crypto markets.
                </p>

                <button className="btn btn-primary btn-soft w-full rounded-full">Get started for free</button>

                {/* Abstract BG Shape */}
                <svg className="absolute end-0 top-0 pointer-events-none" xmlns="http://www.w3.org/2000/svg" width="97" height="88" viewBox="0 0 97 88" fill="none">
                  <rect opacity="0.04" y="-5.86523" width="76.0099" height="93.0587" rx="7" fill="currentColor" className="text-primary"></rect>
                  <rect opacity="0.07" x="34.6348" y="-21.1953" width="76.0099" height="93.0587" rx="7" fill="currentColor" className="text-primary"></rect>
                </svg>
              </div>
            </div>

            {/* Features List Part */}
            <div>
              <FeatureRow 
                icon={<CheckIcon />}
                title="Basic features:"
                description="Access to essential tools and support."
              />
              <FeatureRow 
                icon={<CrossIcon />}
                title="Up to 50,000 monthly tasks:"
                description="Efficiently manage your operations."
              />
              <FeatureRow 
                icon={<CrossIcon />}
                title="Basic integrations:"
                description="Connect with popular apps."
              />
            </div>
          </div>

          {/* Startup Plan */}
          <div className="flex flex-col gap-6">
            {/* Card Header Part */}
            <div className="card border-2 border-primary rounded-3xl overflow-hidden relative">
              <div className="card-body p-8 gap-6">
                <h3 className="text-2xl font-semibold text-primary mb-4">Startup</h3>
                
                <div className="flex items-baseline gap-1 mb-4">
                  <span className="text-base-content/80 text-lg font-medium">$</span>
                  <span className="text-primary text-4xl font-bold">200</span>
                </div>

                <p className="text-base-content/80 mb-8 min-h-[3rem]">
                  Recommended for people with atleast 1 year experience in crypto markets.
                </p>

                <button className="btn btn-primary w-full rounded-full shadow-lg hover:shadow-primary/50">Buy this plan</button>

                {/* Abstract BG Shape */}
                <svg className="absolute end-0 top-0 pointer-events-none" xmlns="http://www.w3.org/2000/svg" width="97" height="88" viewBox="0 0 97 88" fill="none">
                  <rect opacity="0.04" y="-5.86523" width="76.0099" height="93.0587" rx="7" fill="currentColor" className="text-primary"></rect>
                  <rect opacity="0.07" x="34.6348" y="-21.1953" width="76.0099" height="93.0587" rx="7" fill="currentColor" className="text-primary"></rect>
                </svg>
              </div>
            </div>

            {/* Features List Part */}
            <div>
              <FeatureRow 
                icon={<CheckIcon />}
                title="Advanced features:"
                description="Access to all tools and support."
              />
              <FeatureRow 
                icon={<CrossIconPrimary />}
                title="Up to 50,000 monthly tasks:"
                description="Efficiently manage your operations."
              />
              <FeatureRow 
                icon={<CrossIcon />}
                title="Basic integrations:"
                description="Connect with popular apps."
              />
            </div>
          </div>

          {/* Enterprise Plan */}
          <div className="flex flex-col gap-6 md:col-span-2 lg:col-span-1">
            {/* Card Header Part */}
            <div className="card bg-primary text-primary-content rounded-3xl overflow-hidden relative">
              <div className="card-body p-8 gap-6">
                <h3 className="text-2xl font-semibold text-white mb-4">Enterprise</h3>
                
                <div className="flex items-baseline gap-1 mb-4">
                  <span className="text-white/80 text-lg font-medium">$</span>
                  <span className="text-white text-4xl font-bold">Custom</span>
                </div>

                <p className="text-white/80 mb-8 min-h-[3rem]">
                  Recommended for people with atleast 3 year experience in crypto markets.
                </p>

                <button className="btn bg-white text-primary hover:bg-white/90 border-none w-full rounded-full">
                  Buy this plan
                </button>

                {/* Abstract BG Shape */}
                <svg className="absolute end-0 top-0 pointer-events-none" xmlns="http://www.w3.org/2000/svg" width="101" height="88" viewBox="0 0 101 88" fill="none">
                  <rect opacity="0.04" y="-5.86523" width="76.0099" height="93.0587" rx="7" fill="white"></rect>
                  <rect opacity="0.07" x="34.6348" y="-21.1953" width="76.0099" height="93.0587" rx="7" fill="white"></rect>
                </svg>
              </div>
            </div>

            {/* Features List Part */}
            <div>
              <FeatureRow 
                icon={<CheckIcon />}
                title="Tailored solutions:"
                description="Customized features based on your requirements."
              />
              <FeatureRow 
                icon={<CheckIcon />}
                title="Up to 50,000 monthly tasks::"
                description="Efficiently manage your operations."
              />
              <FeatureRow 
                icon={<CheckIcon />}
                title="Basic integrations:"
                description="Connect with popular apps."
              />
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}

