import React from 'react';

// --- Sub-Components ---

const CheckIcon = () => (
  <span className="icon-[tabler--circle-check] text-primary size-5 mt-0.5 shrink-0">
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

export default function PricingList() {
  return (
    <section className="bg-base-100 py-8 sm:py-16 lg:py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        {/* Header */}
        <div className="mb-16 md:space-y-6 flex flex-col items-center text-center">
          <p className="text-primary text-sm font-medium uppercase tracking-wider">Pricing Details</p>
          <h2 className="text-base-content text-3xl font-semibold md:text-3xl lg:text-4xl">
            Choose your right plan!
          </h2>
          <p className="text-base-content/80 text-xl max-w-2xl">
            Select from best plans, ensuring a perfect match. Need more or less? Customize your subscription for a seamless fit!
          </p>
        </div>

        <div className="flex flex-col gap-6">

          {/* Starter Plan */}
          <div className="card border border-base-content/20 shadow-none overflow-hidden">
            <div className="card-body p-8 gap-0 sm:flex-row sm:items-start lg:items-center sm:pe-16 lg:pe-24">
              
              <div className="w-[9.25rem] shrink-0 max-sm:mb-6">
                <div className="avatar placeholder">
                  <div className="bg-base-200 rounded-2xl w-14 h-14 flex items-center justify-center text-base-content/70">
                    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M5 21c.5 -4.5 2.5 -8 7 -10"></path><path d="M9 18c6.218 0 10.5 -3.288 11 -12v-2h-4.014c-9 0 -11.986 4 -12 9c0 1 0 3 2 5h3z"></path></svg>
                  </div>
                </div>
              </div>

              <div className="flex flex-col lg:flex-row gap-6 lg:items-center w-full">
                <div className="w-full lg:w-1/3 xl:w-1/2 space-y-2">
                  <h4 className="text-2xl font-semibold">Starter Plan</h4>
                  <p className="text-base-content/80 text-sm">Best For Beginners</p>
                  <p className="text-primary font-semibold mt-6">Save up to 9%</p>
                  
                  <div className="flex items-baseline gap-1">
                    <span className="text-4xl font-bold text-base-content">$99</span>
                    <span className="text-base-content/60 text-sm font-medium">/month</span>
                  </div>
                </div>

                <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 w-full lg:w-2/3">
                  <ul className="space-y-3 flex-1">
                    <FeatureItem text="1x Business Account & Cards" />
                    <FeatureItem text="1x Account" />
                    <FeatureItem text="30 transfer or direct debit" />
                    <FeatureItem text="10+ Integrations" />
                  </ul>

                  <div className="flex flex-col sm:flex-row gap-3 shrink-0 mt-4 md:mt-0">
                    <button className="btn btn-outline btn-primary min-w-[140px]">Try For 15 Day’s</button>
                    <button className="btn btn-primary btn-soft min-w-[140px] gap-2">
                      Get Started
                      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 13a8 8 0 0 1 7 7a6 6 0 0 0 3 -5a9 9 0 0 0 6 -8a3 3 0 0 0 -3 -3a9 9 0 0 0 -8 6a6 6 0 0 0 -5 3"></path><path d="M7 14a6 6 0 0 0 -3 6a6 6 0 0 0 6 -3"></path><circle cx="15" cy="9" r="1"></circle></svg>
                    </button>
                  </div>
                </div>
              </div>

            </div>
          </div>

          {/* Professional Plan */}
          <div className="card border-2 border-primary bg-primary/5 shadow-sm overflow-hidden relative">
            <div className="card-body p-8 gap-0 sm:flex-row sm:items-start lg:items-center sm:pe-16 lg:pe-24">
              
              <div className="w-[9.25rem] shrink-0 max-sm:mb-6">
                <div className="avatar placeholder">
                  <div className="bg-white rounded-2xl w-14 h-14 flex items-center justify-center text-primary shadow-sm">
                    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M12 10a6 6 0 0 0 -6 -6h-3v2a6 6 0 0 0 6 6h3"></path><path d="M12 14a6 6 0 0 1 6 -6h3v1a6 6 0 0 1 -6 6h-3"></path><path d="M12 20l0 -10"></path></svg>
                  </div>
                </div>
              </div>

              <div className="flex flex-col lg:flex-row gap-6 lg:items-center w-full">
                <div className="w-full lg:w-1/3 xl:w-1/2 space-y-2">
                  <h4 className="text-2xl font-semibold text-primary">Professional Plan</h4>
                  <p className="text-base-content/80 text-sm">Ideal for Growing Businesses</p>
                  <p className="text-primary font-semibold mt-6">Save up to 15%</p>
                  
                  <div className="flex items-baseline gap-1">
                    <span className="text-4xl font-bold text-base-content">$199</span>
                    <span className="text-base-content/60 text-sm font-medium">/month</span>
                  </div>
                </div>

                <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 w-full lg:w-2/3">
                  <ul className="space-y-3 flex-1">
                    <FeatureItem text="2x Premium Business Account & Cards" />
                    <FeatureItem text="1x Savings Account" />
                    <FeatureItem text="3x Standard Business Accounts" />
                    <FeatureItem text="5x Personal Savings Accounts" />
                  </ul>

                  <div className="flex flex-col sm:flex-row gap-3 shrink-0 mt-4 md:mt-0">
                    <button className="btn btn-outline btn-primary min-w-[140px] bg-white hover:bg-primary hover:border-primary">Try For 15 Day’s</button>
                    <button className="btn btn-primary min-w-[140px] gap-2 shadow-lg shadow-primary/20">
                      Get Started
                      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 13a8 8 0 0 1 7 7a6 6 0 0 0 3 -5a9 9 0 0 0 6 -8a3 3 0 0 0 -3 -3a9 9 0 0 0 -8 6a6 6 0 0 0 -5 3"></path><path d="M7 14a6 6 0 0 0 -3 6a6 6 0 0 0 6 -3"></path><circle cx="15" cy="9" r="1"></circle></svg>
                    </button>
                  </div>
                </div>
              </div>

            </div>
          </div>

          {/* Enterprise Plan */}
          <div className="card border border-base-content/20 shadow-none overflow-hidden">
            <div className="card-body p-8 gap-0 sm:flex-row sm:items-start lg:items-center sm:pe-16 lg:pe-24">
              
              <div className="w-[9.25rem] shrink-0 max-sm:mb-6">
                <div className="avatar placeholder">
                  <div className="bg-base-200 rounded-2xl w-14 h-14 flex items-center justify-center text-base-content/70">
                    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M7 17m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0"></path><path d="M17 17m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0"></path><path d="M7 14v-8a5 5 0 0 1 10 0v8"></path><path d="M6 21v-13a3 3 0 0 1 3 -3h.5"></path><path d="M18 21v-13a3 3 0 0 0 -3 -3h-.5"></path></svg>
                  </div>
                </div>
              </div>

              <div className="flex flex-col lg:flex-row gap-6 lg:items-center w-full">
                <div className="w-full lg:w-1/3 xl:w-1/2 space-y-2">
                  <h4 className="text-2xl font-semibold">Enterprise Plan</h4>
                  <p className="text-base-content/80 text-sm">Tailored for Large Companies</p>
                  <p className="text-primary font-semibold mt-6">Save up to 20%</p>
                  
                  <div className="flex items-baseline gap-1">
                    <span className="text-4xl font-bold text-base-content">$499</span>
                    <span className="text-base-content/60 text-sm font-medium">/month</span>
                  </div>
                </div>

                <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 w-full lg:w-2/3">
                  <ul className="space-y-3 flex-1">
                    <FeatureItem text="Unlimited Online Banking Access" />
                    <FeatureItem text="5x ATM Withdrawals per Month" />
                    <FeatureItem text="1x International Money Transfer" />
                    <FeatureItem text="No Monthly Maintenance Fees" />
                  </ul>

                  <div className="flex flex-col sm:flex-row gap-3 shrink-0 mt-4 md:mt-0">
                    <button className="btn btn-outline btn-primary min-w-[140px]">Try For 15 Day’s</button>
                    <button className="btn btn-primary btn-soft min-w-[140px] gap-2">
                      Get Started
                      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 13a8 8 0 0 1 7 7a6 6 0 0 0 3 -5a9 9 0 0 0 6 -8a3 3 0 0 0 -3 -3a9 9 0 0 0 -8 6a6 6 0 0 0 -5 3"></path><path d="M7 14a6 6 0 0 0 -3 6a6 6 0 0 0 6 -3"></path><circle cx="15" cy="9" r="1"></circle></svg>
                    </button>
                  </div>
                </div>
              </div>

            </div>
          </div>

        </div>
      </div>
    </section>
  );
}

