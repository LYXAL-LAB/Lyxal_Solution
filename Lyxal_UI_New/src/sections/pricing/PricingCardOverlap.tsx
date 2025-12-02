import React from 'react';

// --- Sub-Components ---

const CheckIcon = () => (
  <span className="icon-[tabler--check] text-primary size-5 shrink-0">
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M5 12l5 5l10 -10"></path>
    </svg>
  </span>
);

const FeatureItem = ({ text }: { text: string }) => (
  <li className="flex items-center gap-2 py-1 text-base-content">
    <CheckIcon />
    <span>{text}</span>
  </li>
);

const FeatureItemFilled = ({ text }: { text: string }) => (
  <li className="flex items-center gap-2 py-1 text-base-content">
    <span className="icon-[tabler--circle-filled] text-primary size-2.5 shrink-0 flex items-center justify-center">
       <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="currentColor" className="w-full h-full">
         <circle cx="12" cy="12" r="12" />
       </svg>
    </span>
    <span>{text}</span>
  </li>
);

export default function PricingCardOverlap() {
  return (
    <section className="bg-base-100 relative overflow-hidden py-8 sm:py-16 lg:py-24">
      
      {/* Background Gradient Image */}
      <div className="absolute -left-[20rem] -bottom-[10rem] opacity-50 pointer-events-none">
        <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/pricing/image-02.png" alt="gradient" className="w-[50rem] h-[50rem] object-contain" />
      </div>

      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Header */}
        <div className="mb-16 md:space-y-6 flex flex-col items-center text-center">
          <h2 className="text-base-content text-3xl font-semibold md:text-3xl lg:text-4xl relative z-10">
            <span className="relative">
              Pricing Details
              {/* Underline Gradient */}
              <span className="absolute bottom-0 left-0 -z-10 h-3 w-full bg-gradient-to-r from-primary to-transparent opacity-30 blur-sm" aria-hidden="true"></span>
            </span>
          </h2>
          <p className="text-base-content/80 text-xl max-w-2xl">
            A Comprehensive Breakdown of Our Pricing Plans to Help You Make the Best Choice!
          </p>
        </div>

        {/* Pricing Cards */}
        <div className="flex flex-col md:flex-row justify-center gap-6 items-center md:items-stretch">

          {/* Essential Plan */}
          <div className="border border-base-content/20 w-full max-w-[23.75rem] rounded-3xl flex flex-col pb-4 bg-base-100 shadow-sm hover:shadow-md transition-shadow">
            {/* Top Card Section */}
            <div className="bg-base-200/50 rounded-t-3xl rounded-b-[2rem] p-6 flex flex-col gap-6 h-full">
              
              <div className="flex items-start justify-between">
                <div className="avatar placeholder">
                  <div className="bg-base-100 rounded-xl shadow-sm border border-base-content/5 w-12 h-12 flex items-center justify-center text-base-content">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M7 17m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0"></path><path d="M17 17m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0"></path><path d="M7 14v-8a5 5 0 0 1 10 0v8"></path><path d="M6 21v-13a3 3 0 0 1 3 -3h.5"></path><path d="M18 21v-13a3 3 0 0 0 -3 -3h-.5"></path></svg>
                  </div>
                </div>
              </div>

              <div>
                <h4 className="text-2xl font-semibold mb-1">Essential Plan</h4>
                <p className="text-base-content/70 text-sm">Ideal for startups and small teams</p>
              </div>

              <div className="flex items-baseline gap-1">
                <span className="text-primary text-4xl font-bold">$5</span>
                <span className="text-base-content/60 text-sm font-medium ml-1">/month</span>
              </div>

              <button className="btn btn-primary btn-outline w-full rounded-full mt-auto">Basic Access</button>
            </div>

            {/* Features List */}
            <div className="p-6 pt-2">
              <ul className="space-y-2">
                <FeatureItem text="1 user account" />
                <FeatureItem text="Up to 30 monthly transactions" />
                <FeatureItem text="10 crypto pairs" />
                <FeatureItem text="Basic market analysis" />
              </ul>
            </div>
          </div>

          {/* Advanced Plan (Highlighted) */}
          <div className="border border-base-content/20 w-full max-w-[23.75rem] rounded-3xl flex flex-col pb-4 bg-base-100 shadow-lg relative overflow-hidden">
            {/* Top Card Section */}
            <div className="bg-base-100 rounded-t-3xl rounded-b-[2rem] p-6 flex flex-col gap-6 shadow-md relative z-10">
              
              {/* Abstract BG in Card Header */}
              <div className="absolute -top-[11.75rem] -right-[9.5rem] w-96 h-96 opacity-50 pointer-events-none z-0">
                 <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/bg-gradient.png" alt="gradient" className="w-full h-full object-contain" />
              </div>

              <div className="flex items-start justify-between relative z-10">
                <div className="avatar placeholder">
                  <div className="bg-white rounded-xl shadow-md border border-base-content/5 w-12 h-12 flex items-center justify-center text-primary">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 12m-4 0a4 4 0 1 0 8 0a4 4 0 1 0 -8 0"></path><path d="M12 12m-8 0a8 8 0 1 0 16 0a8 8 0 1 0 -16 0"></path><path d="M12 2l0 2"></path><path d="M12 20l0 2"></path><path d="M20 12l2 0"></path><path d="M2 12l2 0"></path></svg>
                  </div>
                </div>
                <span className="badge badge-error text-white border-none rounded-full px-3 font-medium">Trending</span>
              </div>

              <div className="relative z-10">
                <h4 className="text-2xl font-semibold mb-1">Advanced Plan</h4>
                <p className="text-base-content/70 text-sm">Designed for teams and businesses.</p>
              </div>

              <div className="flex items-baseline gap-1 relative z-10">
                <span className="text-primary text-4xl font-bold">$49</span>
                <span className="text-base-content/60 text-sm font-medium ml-1">/month</span>
              </div>

              <button className="btn btn-primary w-full rounded-full mt-auto shadow-lg shadow-primary/20 relative z-10">Premium Access</button>
            </div>

            {/* Features List */}
            <div className="p-6 pt-6">
              <ul className="space-y-2 mb-6">
                <FeatureItem text="1 user account" />
                <FeatureItem text="Up to 30 monthly transactions" />
                <FeatureItem text="10 crypto pairs" />
                <FeatureItem text="Basic market analysis" />
              </ul>
              
              <div className="w-full h-px bg-base-content/10 mb-6"></div>

              <ul className="space-y-2">
                <FeatureItemFilled text="24/7 customer support" />
                <FeatureItemFilled text="User-friendly mobile app" />
                <FeatureItemFilled text="Strong data encryption" />
              </ul>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}

