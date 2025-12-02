import React, { useState } from 'react';

// --- Sub-Components ---

const CheckIcon = () => (
  <span className="icon-[tabler--circle-check] text-primary size-6 shrink-0 mt-0.5">
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0"></path>
      <path d="M9 12l2 2l4 -4"></path>
    </svg>
  </span>
);

const FeatureItem = ({ title, text }: { title: string, text: string }) => (
  <div className="flex items-start gap-3">
    <CheckIcon />
    <div>
      <p className="text-base-content">
        <span className="font-semibold mr-1">{title}</span>
        {text}
      </p>
    </div>
  </div>
);

export default function PricingSplitLayout() {
  const [selectedPlan, setSelectedPlan] = useState('starter');

  return (
    <section className="bg-base-100 py-8 sm:py-16 lg:py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        {/* Header */}
        <div className="mb-16 md:space-y-6 flex flex-col items-center text-center">
          <span className="badge badge-soft badge-primary rounded-full px-3 py-1 mb-4">Build intuitive Dashboards with ease</span>
          <h2 className="text-base-content text-3xl font-semibold md:text-3xl lg:text-4xl">
            Gain A Competitive Edge With Better UI!
          </h2>
          <p className="text-base-content/80 text-xl max-w-2xl mt-4">
            Gain A Competitive Edge With Better UI!
          </p>
        </div>

        {/* Main Content Card */}
        <div className="border border-primary rounded-3xl flex flex-col md:flex-row p-8 md:p-12 lg:p-16 gap-12 relative bg-base-100 shadow-sm">
          
          {/* Left Section - Plan Selection */}
          <div className="flex flex-col justify-center space-y-8 lg:w-1/2">
            <div className="space-y-4">
              <h3 className="text-3xl font-semibold text-base-content">Access All Features</h3>
              <p className="text-base-content/80 text-lg">
                Insight provides you with the tools & resources you need to build a stunning e-commerce site, portfolio, or dashboard for your business.
              </p>
            </div>

            {/* Pricing Options */}
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-1 xl:grid-cols-2 gap-4">
              
              {/* Starter Plan */}
              <div 
                className={`border rounded-2xl p-5 cursor-pointer transition-all ${selectedPlan === 'starter' ? 'border-primary bg-primary/5 ring-1 ring-primary' : 'border-base-content/20 hover:border-primary/50'}`}
                onClick={() => setSelectedPlan('starter')}
              >
                <div className="space-y-2">
                  <div className="flex justify-between items-center">
                    <h4 className="text-lg font-semibold">Starter</h4>
                    <span className="badge badge-primary text-xs font-bold">Popular</span>
                  </div>
                  <div className="flex items-baseline gap-1">
                    <span className="text-primary text-3xl font-bold">$99</span>
                    <span className="text-base-content/60 text-sm">/month</span>
                  </div>
                </div>
              </div>

              {/* Professional Plan */}
              <div 
                className={`border rounded-2xl p-5 cursor-pointer transition-all ${selectedPlan === 'professional' ? 'border-primary bg-primary/5 ring-1 ring-primary' : 'border-base-content/20 hover:border-primary/50'}`}
                onClick={() => setSelectedPlan('professional')}
              >
                <div className="space-y-2">
                  <h4 className="text-lg font-semibold">Professional</h4>
                  <div className="flex items-baseline gap-1">
                    <span className="text-primary text-3xl font-bold">$199</span>
                    <span className="text-base-content/60 text-sm">/month</span>
                  </div>
                </div>
              </div>

            </div>

            <button className="btn btn-primary w-full btn-lg rounded-xl">Start 14 days free trial</button>
          </div>

          {/* Vertical Divider (Desktop only) */}
          <div className="hidden md:block w-px bg-base-content/10 self-stretch mx-4"></div>
          {/* Horizontal Divider (Mobile only) */}
          <div className="md:hidden w-full h-px bg-base-content/10"></div>

          {/* Right Section - Features List */}
          <div className="space-y-6 lg:w-1/2 flex flex-col justify-center">
            <FeatureItem 
              title="Unlimited Components:"
              text="FlyonUI gives you access to a vast library of customizable components to enhance your projects."
            />
            <FeatureItem 
              title="Collaborative Workspace:"
              text="Work seamlessly with your team using our collaborative tools and resources."
            />
            <FeatureItem 
              title="Performance Analytics:"
              text="Track your UI performance and user engagement with built-in analytics tools."
            />
            <FeatureItem 
              title="Responsive Design Framework:"
              text="Optimize your UI for all devices with our responsive design options."
            />
            <FeatureItem 
              title="Theming and Customization:"
              text="Customize components effortlessly with consistent branding using custom themes."
            />
          </div>

        </div>
      </div>
    </section>
  );
}

