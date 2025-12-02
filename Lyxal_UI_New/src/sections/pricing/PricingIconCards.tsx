import React, { useState } from 'react';

// --- Sub-Components ---

const CheckIcon = () => (
  <span className="icon-[tabler--check] text-primary size-5 shrink-0 mt-0.5">
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M5 12l5 5l10 -10"></path>
    </svg>
  </span>
);

const FeatureItem = ({ text }: { text: string }) => (
  <li className="flex items-start gap-2 py-1 text-base-content/80">
    <CheckIcon />
    <span>{text}</span>
  </li>
);

export default function PricingIconCards() {
  const [isAnnual, setIsAnnual] = useState(true);

  const prices = {
    essential: isAnnual ? 49 : 59,
    business: isAnnual ? 99 : 119,
    enterprise: isAnnual ? 299 : 349
  };

  return (
    <section className="bg-base-100 py-8 sm:py-16 lg:py-24 relative overflow-hidden">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Header */}
        <div className="mb-12 flex flex-col items-center space-y-4 text-center sm:mb-16 lg:mb-24">
          <div className="text-center">
            <h2 className="text-base-content text-3xl font-semibold md:text-3xl lg:text-4xl">
              Choose your right plan!
            </h2>
            <p className="text-base-content/80 text-xl max-w-2xl mt-4 mx-auto">
              Select from best plans, ensuring a perfect match. Need more or less? Customize your subscription for a seamless fit!
            </p>
          </div>
        </div>

        {/* Toggle Switch */}
        <div className="flex justify-center mb-10">
          <div className="flex items-center rounded-full border border-base-content/20 p-1 bg-base-200/50 backdrop-blur-sm">
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
          {/* Save Badge */}
          <div className="relative ml-4 flex items-center">
             <div className="absolute -left-3 top-1/2 -translate-y-1/2 -translate-x-full w-12 h-4 text-base-content/30">
               <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 45 14" fill="currentColor" className="w-full h-full rotate-180">
                  <path d="M43.6096 7.63949C44.0909 7.36868 44.2616 6.75895 43.9908 6.27762C43.72 5.79628 43.1102 5.62562 42.6289 5.89642L43.6096 7.63949ZM1.0941 2.40237C0.549028 2.49131 0.179254 3.00528 0.26819 3.55035L1.71751 12.4329C1.80645 12.978 2.32041 13.3477 2.86549 13.2588C3.41057 13.1699 3.78034 12.6559 3.6914 12.1108L2.40312 4.21523L10.2987 2.92695C10.8438 2.83801 11.2136 2.32404 11.1246 1.77897C11.0357 1.23389 10.5217 0.864116 9.97664 0.953052L1.0941 2.40237ZM43.1192 6.76795L42.6289 5.89642C30.7701 12.5684 21.5868 12.3994 14.919 10.3011C8.17493 8.17872 3.95418 4.09922 1.83915 2.57757L1.25514 3.38932L0.67113 4.20107C2.54588 5.54985 7.1711 9.95952 14.3186 12.2088C21.5424 14.4821 31.2962 14.5672 43.6096 7.63949L43.1192 6.76795Z" fillOpacity="0.5"></path>
               </svg>
             </div>
             <span className="badge badge-outline badge-primary rounded-full px-3 py-3 text-xs font-bold shadow-sm bg-base-100">Save 10%</span>
          </div>
        </div>

        {/* Pricing Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 items-start">

          {/* Essential Plan */}
          <div className="card bg-base-100 border border-base-content/20 shadow-none relative overflow-hidden">
            {/* Abstract BG Image */}
            <div className="absolute -top-[11.75rem] -right-[9.5rem] w-96 h-96 opacity-50 pointer-events-none">
               <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/bg-gradient.png" alt="gradient" className="w-full h-full object-contain" />
            </div>
            {/* Icon */}
            <div className="absolute top-4 right-4 text-primary/10">
              <svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1" strokeLinecap="round" strokeLinejoin="round"><path d="M4 13a8 8 0 0 1 7 7a6 6 0 0 0 3 -5a9 9 0 0 0 6 -8a3 3 0 0 0 -3 -3a9 9 0 0 0 -8 6a6 6 0 0 0 -5 3"></path><path d="M7 14a6 6 0 0 0 -3 6a6 6 0 0 0 6 -3"></path><circle cx="15" cy="9" r="1"></circle></svg>
            </div>

            <div className="card-body p-8 gap-6 relative z-10">
              <div>
                <h3 className="text-2xl font-semibold">Essential</h3>
                
                <div className="flex items-center gap-2 mt-4 mb-1">
                  <span className="text-lg font-medium text-base-content/80">$</span>
                  <span className="text-4xl font-bold text-base-content">{prices.essential}</span>
                  {isAnnual && <span className="badge badge-soft badge-error text-xs font-bold rounded-full">UP TO $20 OFF</span>}
                </div>
                <p className="text-base-content/80 text-sm">per user, billed annually</p>
              </div>

              <button className="btn btn-primary btn-soft w-full">Purchase Now</button>

              <div>
                <p className="font-semibold mb-3">For self-employed:</p>
                <ul className="space-y-2">
                  <FeatureItem text="1x Business account & Cards" />
                  <FeatureItem text="1x Account" />
                  <FeatureItem text="30 transfer or direct debit" />
                  <FeatureItem text="10+ Integrations" />
                </ul>
              </div>
            </div>
          </div>

          {/* Business Plan */}
          <div className="card bg-base-100 border border-primary shadow-xl relative overflow-hidden">
             {/* Abstract BG Image */}
             <div className="absolute -top-[11.75rem] -right-[9.5rem] w-96 h-96 opacity-50 pointer-events-none">
               <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/bg-gradient.png" alt="gradient" className="w-full h-full object-contain" />
            </div>
            {/* Icon */}
            <div className="absolute top-4 right-4 text-primary/10">
              <svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1" strokeLinecap="round" strokeLinejoin="round"><path d="M3 7m0 2a2 2 0 0 1 2 -2h14a2 2 0 0 1 2 2v9a2 2 0 0 1 -2 2h-14a2 2 0 0 1 -2 -2z"></path><path d="M8 7v-2a2 2 0 0 1 2 -2h4a2 2 0 0 1 2 2v2"></path><path d="M12 12l0 .01"></path><path d="M3 13a20 20 0 0 0 18 0"></path></svg>
            </div>

            <div className="card-body p-8 gap-6 relative z-10">
              <div>
                <h3 className="text-2xl font-semibold text-primary">Business</h3>
                
                <div className="flex items-center gap-2 mt-4 mb-1">
                  <span className="text-lg font-medium text-primary">$</span>
                  <span className="text-4xl font-bold text-primary">{prices.business}</span>
                  {isAnnual && <span className="badge badge-soft badge-error text-xs font-bold rounded-full">UP TO $40 OFF</span>}
                </div>
                <p className="text-base-content/80 text-sm">per user, billed annually</p>
              </div>

              <button className="btn btn-primary w-full shadow-lg shadow-primary/20">Purchase Now</button>

              <div>
                <p className="font-semibold mb-3">For micro-business:</p>
                <ul className="space-y-2">
                  <FeatureItem text="3x Business account & Cards" />
                  <FeatureItem text="Unlimited Accounts" />
                  <FeatureItem text="500 transfer or direct debit" />
                  <FeatureItem text="50+ Integrations" />
                </ul>
              </div>
            </div>
          </div>

          {/* Enterprise Plan */}
          <div className="card bg-base-100 border border-base-content/20 shadow-none relative overflow-hidden md:col-span-2 lg:col-span-1">
             {/* Abstract BG Image */}
             <div className="absolute -top-[11.75rem] -right-[9.5rem] w-96 h-96 opacity-50 pointer-events-none">
               <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/bg-gradient.png" alt="gradient" className="w-full h-full object-contain" />
            </div>
            {/* Icon */}
            <div className="absolute top-4 right-4 text-primary/10">
              <svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1" strokeLinecap="round" strokeLinejoin="round"><path d="M12 6l4 6l5 -4l-2 10h-14l-2 -10l5 4z"></path></svg>
            </div>

            <div className="card-body p-8 gap-6 relative z-10">
              <div>
                <h3 className="text-2xl font-semibold">Enterprise</h3>
                
                <div className="flex items-center gap-2 mt-4 mb-1">
                  <span className="text-lg font-medium text-base-content/80">$</span>
                  <span className="text-4xl font-bold text-base-content">{prices.enterprise}</span>
                  {isAnnual && <span className="badge badge-soft badge-error text-xs font-bold rounded-full">UP TO $80 OFF</span>}
                </div>
                <p className="text-base-content/80 text-sm">per user, billed annually</p>
              </div>

              <button className="btn btn-primary btn-soft w-full">Purchase Now</button>

              <div>
                <p className="font-semibold mb-3">For SMEs:</p>
                <ul className="space-y-2">
                  <FeatureItem text="30x Business account & Cards" />
                  <FeatureItem text="Unlimited Accounts" />
                  <FeatureItem text="1000 transfer or direct debit" />
                  <FeatureItem text="80+ Exclusive Integrations" />
                </ul>
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}

