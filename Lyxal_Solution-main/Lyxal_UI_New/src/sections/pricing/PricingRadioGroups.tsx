import React, { useState } from 'react';

// --- Sub-Components ---

const CheckIcon = () => (
  <span className="text-primary size-5.5 shrink-0 flex items-center justify-center rounded-full bg-primary/10">
    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="10" fill="currentColor" className="opacity-20" stroke="none"/>
      <path d="M5 12l5 5l10 -10"></path>
    </svg>
  </span>
);

const FeatureItem = ({ text }: { text: string }) => (
  <li className="flex items-center justify-between gap-3 py-1 text-base-content/80">
    <span>{text}</span>
    <span className="icon-[tabler--circle-check] text-primary size-5.5 shrink-0">
      <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0"></path>
        <path d="M9 12l2 2l4 -4"></path>
      </svg>
    </span>
  </li>
);

export default function PricingRadioGroups() {
  const [isAnnual, setIsAnnual] = useState(true);
  const [selectedPlan, setSelectedPlan] = useState('standard');

  // Pricing Data based on Toggle
  const prices = {
    business: isAnnual ? 99 : 119,
    standard: isAnnual ? 130 : 159,
    enterprise: isAnnual ? 199 : 219,
    custom: isAnnual ? 999 : 1299
  };

  return (
    <section className="bg-base-100 py-8 sm:py-16 lg:py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        {/* Header */}
        <div className="mb-16 flex flex-col md:flex-row items-end justify-between gap-6">
          <div className="max-w-2xl space-y-4">
            <h2 className="text-base-content text-3xl font-semibold md:text-3xl lg:text-4xl">
              Find the Perfect Plan for You!
            </h2>
            <p className="text-base-content/80 text-xl">
              Explore Our Wide Range of Plans, Compare Features, and Select the One That Perfectly Matches Your Needs and Budget
            </p>
          </div>

          {/* Toggle Switch */}
          <div className="relative flex h-fit items-center justify-center">
            <div className="flex items-center rounded-full border border-base-content/20 p-1">
              <button 
                onClick={() => setIsAnnual(false)}
                className={`btn btn-sm rounded-full border-none px-6 transition-all ${!isAnnual ? 'bg-primary text-primary-content hover:bg-primary' : 'bg-transparent text-base-content hover:bg-base-200'}`}
              >
                Monthly
              </button>
              <button 
                onClick={() => setIsAnnual(true)}
                className={`btn btn-sm rounded-full border-none px-6 transition-all ${isAnnual ? 'bg-primary text-primary-content hover:bg-primary' : 'bg-transparent text-base-content hover:bg-base-200'}`}
              >
                Yearly
              </button>
            </div>

            {/* Save 10% Badge */}
            <div className="absolute left-full top-1/2 -translate-y-1/2 ml-4 flex items-center">
              <div className="relative">
                <div className="absolute -left-3 top-1/2 -translate-y-1/2 -translate-x-full w-12 h-4 text-base-content/50">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 45 14" fill="currentColor" className="w-full h-full rotate-180">
                     <path d="M43.6096 7.63949C44.0909 7.36868 44.2616 6.75895 43.9908 6.27762C43.72 5.79628 43.1102 5.62562 42.6289 5.89642L43.6096 7.63949ZM1.0941 2.40237C0.549028 2.49131 0.179254 3.00528 0.26819 3.55035L1.71751 12.4329C1.80645 12.978 2.32041 13.3477 2.86549 13.2588C3.41057 13.1699 3.78034 12.6559 3.6914 12.1108L2.40312 4.21523L10.2987 2.92695C10.8438 2.83801 11.2136 2.32404 11.1246 1.77897C11.0357 1.23389 10.5217 0.864116 9.97664 0.953052L1.0941 2.40237ZM43.1192 6.76795L42.6289 5.89642C30.7701 12.5684 21.5868 12.3994 14.919 10.3011C8.17493 8.17872 3.95418 4.09922 1.83915 2.57757L1.25514 3.38932L0.67113 4.20107C2.54588 5.54985 7.1711 9.95952 14.3186 12.2088C21.5424 14.4821 31.2962 14.5672 43.6096 7.63949L43.1192 6.76795Z" fillOpacity="0.5"></path>
                  </svg>
                </div>
                <span className="badge badge-outline badge-primary rounded-full px-3 py-3 text-xs font-bold shadow-sm bg-base-100">Save 10%</span>
              </div>
            </div>
          </div>
        </div>

        {/* Pricing Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-12">

          {/* Left Column - Plan Selection (Radio List) */}
          <div className="space-y-5">
            
            {/* Business Plan */}
            <label className={`cursor-pointer flex items-center justify-between p-5 rounded-xl border transition-all ${selectedPlan === 'business' ? 'border-primary bg-primary/5 ring-1 ring-primary' : 'border-base-content/20 hover:border-base-content/40'}`}>
              <div className="flex items-center gap-4">
                <input 
                  type="radio" 
                  name="pricing-plan" 
                  className="radio radio-primary"
                  checked={selectedPlan === 'business'}
                  onChange={() => setSelectedPlan('business')}
                />
                <div>
                  <span className="block text-lg font-semibold">Business Plan</span>
                  {isAnnual && <span className="badge badge-soft badge-success text-xs rounded-full mt-1">Save 20%</span>}
                </div>
              </div>
              <div className="flex items-baseline gap-1">
                <span className="text-primary text-xl font-bold">$</span>
                <span className="text-primary text-3xl font-bold">{prices.business}</span>
                <span className="text-base-content/50 text-sm">/month</span>
              </div>
            </label>

            {/* Standard Plan */}
            <label className={`cursor-pointer flex items-center justify-between p-5 rounded-xl border transition-all ${selectedPlan === 'standard' ? 'border-primary bg-primary/5 ring-1 ring-primary' : 'border-base-content/20 hover:border-base-content/40'}`}>
              <div className="flex items-center gap-4">
                <input 
                  type="radio" 
                  name="pricing-plan" 
                  className="radio radio-primary"
                  checked={selectedPlan === 'standard'}
                  onChange={() => setSelectedPlan('standard')}
                />
                <div>
                  <span className="block text-lg font-semibold">Standard Plan</span>
                  {isAnnual && <span className="badge badge-soft badge-success text-xs rounded-full mt-1">Save 10%</span>}
                </div>
              </div>
              <div className="flex items-baseline gap-1">
                <span className="text-primary text-xl font-bold">$</span>
                <span className="text-primary text-3xl font-bold">{prices.standard}</span>
                <span className="text-base-content/50 text-sm">/month</span>
              </div>
            </label>

            {/* Enterprise Plan */}
            <label className={`cursor-pointer flex items-center justify-between p-5 rounded-xl border transition-all ${selectedPlan === 'enterprise' ? 'border-primary bg-primary/5 ring-1 ring-primary' : 'border-base-content/20 hover:border-base-content/40'}`}>
              <div className="flex items-center gap-4">
                <input 
                  type="radio" 
                  name="pricing-plan" 
                  className="radio radio-primary"
                  checked={selectedPlan === 'enterprise'}
                  onChange={() => setSelectedPlan('enterprise')}
                />
                <div>
                  <span className="block text-lg font-semibold">Enterprise Plan</span>
                  {isAnnual && <span className="badge badge-soft badge-success text-xs rounded-full mt-1">Save 20%</span>}
                </div>
              </div>
              <div className="flex items-baseline gap-1">
                <span className="text-primary text-xl font-bold">$</span>
                <span className="text-primary text-3xl font-bold">{prices.enterprise}</span>
                <span className="text-base-content/50 text-sm">/month</span>
              </div>
            </label>

            {/* Custom Licence */}
            <label className={`cursor-pointer flex items-center justify-between p-5 rounded-xl border transition-all ${selectedPlan === 'custom' ? 'border-primary bg-primary/5 ring-1 ring-primary' : 'border-base-content/20 hover:border-base-content/40'}`}>
              <div className="flex items-center gap-4">
                <input 
                  type="radio" 
                  name="pricing-plan" 
                  className="radio radio-primary"
                  checked={selectedPlan === 'custom'}
                  onChange={() => setSelectedPlan('custom')}
                />
                <div>
                  <span className="block text-lg font-semibold">Custom Licence</span>
                  {isAnnual && <span className="badge badge-soft badge-success text-xs rounded-full mt-1">Save 30%</span>}
                </div>
              </div>
              <div className="flex items-baseline gap-1">
                <span className="text-primary text-xl font-bold">$</span>
                <span className="text-primary text-3xl font-bold">{prices.custom}</span>
                <span className="text-base-content/50 text-sm">/month</span>
              </div>
            </label>

          </div>

          {/* Right Column - Features Details */}
          <div className="flex flex-col justify-between h-full">
            <div className="bg-base-200/50 rounded-2xl p-8 h-full border border-base-content/5">
              <h4 className="text-xl font-semibold mb-6">Includes :</h4>
              <ul className="space-y-3">
                <FeatureItem text="AI advisor for a day" />
                <FeatureItem text="2 auto tracking" />
                <FeatureItem text="7 Day transaction clearing" />
                <FeatureItem text="24/7 Customer support" />
                <FeatureItem text="Real-time data analytics" />
                <FeatureItem text="Multi-language support" />
                <FeatureItem text="Secure payment processing" />
                <FeatureItem text="Seamless integration with existing systems" />
                <FeatureItem text="Personalized user experience through AI" />
              </ul>
            </div>

            {/* Footer Action */}
            <div className="flex items-center justify-between mt-8 pt-6 border-t border-base-content/10">
              <button className="btn btn-primary btn-lg px-8">Purchase Now</button>
              <div className="flex items-center gap-3">
                <input type="checkbox" className="toggle toggle-primary" id="discount" defaultChecked />
                <label className="cursor-pointer font-medium text-base-content/80" htmlFor="discount">
                  Get Additional 5% Discount
                </label>
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}

