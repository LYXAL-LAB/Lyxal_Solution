import React from 'react';

// --- Sub-Components ---

const CheckIcon = () => (
  <span className="icon-[tabler--circle-check] text-primary size-5 shrink-0 mt-0.5">
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0"></path>
      <path d="M9 12l2 2l4 -4"></path>
    </svg>
  </span>
);

const FeatureItem = ({ text }: { text: string }) => (
  <li className="flex items-start gap-3 py-1 text-base-content">
    <CheckIcon />
    <span>{text}</span>
  </li>
);

const BenefitItem = ({ icon, title, description }: { icon: React.ReactNode, title: string, description: string }) => (
  <div className="flex items-center gap-4">
    <div className="text-primary size-8 shrink-0 flex items-center justify-center">
      {icon}
    </div>
    <div className="text-base-content">
      <h4 className="font-semibold">{title}</h4>
      <p className="text-base-content/80 text-sm">{description}</p>
    </div>
  </div>
);

export default function PricingSingleCard() {
  return (
    <section className="bg-base-100 py-8 sm:py-16 lg:py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        {/* Main Grid */}
        <div className="flex flex-col md:flex-row gap-16 lg:gap-28">

          {/* Left Section - Info & Benefits */}
          <div className="flex-1 flex flex-col justify-between gap-12">
            <div className="space-y-4">
              <span className="badge badge-primary rounded-full px-3 py-1">Pricing Details</span>
              <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold text-base-content">
                Access All Features
              </h2>
              <p className="text-base-content/80 text-xl">
                Insight provides you with the tools & resources you need to build a stunning e-commerce site, portfolio, or dashboard for your business.
              </p>
            </div>

            {/* Benefits List */}
            <div className="space-y-8">
              <BenefitItem 
                icon={<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M12 17.75l-6.172 3.245l1.179 -6.873l-5 -4.867l6.9 -1l3.086 -6.253l3.086 6.253l6.9 1l-5 4.867l1.179 6.873z"></path></svg>}
                title="Unlimited Templates:"
                description="Insight gives you the tools & resources you need to design a website."
              />
              <BenefitItem 
                icon={<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M9 7m-4 0a4 4 0 1 0 8 0a4 4 0 1 0 -8 0"></path><path d="M3 21v-2a4 4 0 0 1 4 -4h4a4 4 0 0 1 4 4v2"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path><path d="M21 21v-2a4 4 0 0 0 -3 -3.85"></path></svg>}
                title="Collaborative Workspace:"
                description="Insight provides you with the tools & resources you need to work as a team."
              />
              <BenefitItem 
                icon={<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M10 13l2.5 0c2.5 0 2.5 -2.5 0 -2.5l-5 0"></path><path d="M12 12a6 6 0 1 0 5 -5.996"></path></svg>}
                title="Performance Analytics:"
                description="Insight gives you the tools & resources you need to track your website's success."
              />
            </div>
          </div>

          {/* Right Column - Plan Card */}
          <div className="card bg-base-100 shadow-xl shadow-base-300/20 border border-base-content/10 shrink-0 w-full md:max-w-lg h-fit">
            <div className="card-body p-8 gap-6">
              
              {/* Card Header with Border Bottom */}
              <div className="flex items-center justify-between gap-4 pb-6 border-b border-base-content/10">
                <div>
                  <h3 className="text-2xl font-semibold text-nowrap">Pro Plan</h3>
                  <p className="text-base-content/80 text-sm">per user, billed annually</p>
                </div>
                <div className="flex items-baseline gap-1 text-right">
                  <span className="text-base-content/80 text-lg font-medium">$</span>
                  <span className="text-6xl font-bold text-base-content">49</span>
                  <span className="text-base-content/80 text-sm font-medium">/month</span>
                </div>
              </div>

              {/* Features Section */}
              <div className="space-y-4">
                <h6 className="text-xs font-bold text-base-content/60 uppercase tracking-wider">EVERYTHING IN FREE, PLUS</h6>
                
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-x-6 gap-y-2">
                  <ul className="space-y-2">
                    <FeatureItem text="1x Business account & Cards" />
                    <FeatureItem text="1x Account" />
                    <FeatureItem text="30 transfer or direct debit" />
                    <FeatureItem text="10+ Integrations" />
                  </ul>
                  <ul className="space-y-2">
                    <FeatureItem text="1x Business account & Cards" />
                    <FeatureItem text="1x Account" />
                    <FeatureItem text="30 transfer or direct debit" />
                    <FeatureItem text="10+ Integrations" />
                  </ul>
                </div>
              </div>

              <button className="btn btn-primary w-full mt-4 shadow-lg shadow-primary/20">Start 14 days free trial</button>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}

