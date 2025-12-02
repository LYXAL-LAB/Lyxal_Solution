import React, { useState } from 'react';

// --- Sub-Components ---

const CheckIcon = () => (
  <span className="icon-[tabler--check] size-5 shrink-0">
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M5 12l5 5l10 -10"></path>
    </svg>
  </span>
);

const FeatureItem = ({ text }: { text: string }) => (
  <li className="flex items-center gap-2 p-1 text-base-content/80">
    <CheckIcon />
    {text}
  </li>
);

const AccordionItem = ({ 
  id, 
  title, 
  description, 
  price, 
  priceAnnual, 
  isAnnual, 
  isExpanded, 
  onToggle, 
  isPopular = false 
}: { 
  id: string, 
  title: string, 
  description: string, 
  price: number, 
  priceAnnual: number, 
  isAnnual: boolean, 
  isExpanded: boolean, 
  onToggle: () => void, 
  isPopular?: boolean 
}) => {
  return (
    <div className={`collapse collapse-arrow bg-base-100 rounded-box transition-all duration-300 ${isExpanded ? 'bg-neutral text-neutral-content' : ''}`}>
      <input 
        type="radio" 
        name="pricing-accordion" 
        checked={isExpanded} 
        onChange={onToggle} 
        className="peer"
      />
      <div className={`collapse-title text-xl font-medium flex items-center justify-between ${isExpanded ? 'text-white' : 'text-base-content'}`}>
        <span className="flex items-center gap-4">
          {title}
          {isPopular && <span className="badge badge-primary text-primary-content border-none">Popular</span>}
        </span>
      </div>
      <div className="collapse-content">
        <div className="pt-4 pb-2 space-y-6">
          <p className={isExpanded ? 'text-neutral-content/80' : 'text-base-content/80'}>
            {description}
          </p>
          
          <div className="flex items-center justify-between gap-4">
            <div className="flex items-baseline gap-1">
              <span className={`text-lg font-medium ${isExpanded ? 'text-neutral-content/80' : 'text-base-content/80'}`}>$</span>
              <span className={`text-3xl font-bold ${isExpanded ? 'text-white' : 'text-base-content'}`}>
                {isAnnual ? priceAnnual : price}
              </span>
              <span className={`text-sm font-medium ${isExpanded ? 'text-neutral-content/60' : 'text-base-content/60'}`}>/month</span>
            </div>
            
            <button className={`btn btn-sm ${isExpanded ? 'btn-primary text-primary-content border-none' : 'btn-outline btn-primary'}`}>
              Choose Plan
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default function PricingAccordion() {
  const [isAnnual, setIsAnnual] = useState(true);
  const [activePlan, setActivePlan] = useState<string>('pro');

  return (
    <section className="bg-base-100 py-8 sm:py-16 lg:py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-16 lg:gap-24">
          
          {/* Left Section - Text & Features */}
          <div>
            <h2 className="text-base-content text-3xl font-semibold md:text-3xl lg:text-4xl mb-4">
              Check out our simple pricing options for your business!
            </h2>
            <p className="text-base-content/80 text-lg mb-8">
              Explore our top subscription plans and choose the one that best suits your needs! Whether you need more features or prefer a streamlined option, you can easily tailor your subscription for the perfect fit.
            </p>

            {/* Toggle Section */}
            <div className="flex items-center gap-3 mb-8">
              <span className={`text-base font-medium cursor-pointer ${!isAnnual ? 'text-base-content' : 'text-base-content/60'}`} onClick={() => setIsAnnual(false)}>
                Monthly
              </span>
              
              <input 
                type="checkbox" 
                className="toggle toggle-primary" 
                checked={isAnnual}
                onChange={() => setIsAnnual(!isAnnual)}
              />
              
              <div className="flex items-center gap-2">
                <span className={`text-base font-medium cursor-pointer ${isAnnual ? 'text-base-content' : 'text-base-content/60'}`} onClick={() => setIsAnnual(true)}>
                  Annually
                </span>
                <span className="badge badge-soft badge-success text-xs font-bold rounded-full">Save 5%</span>
              </div>
            </div>

            {/* Features List */}
            <div className="bg-base-200/50 rounded-xl p-6">
              <ul className="space-y-2 mb-6">
                <FeatureItem text="Free 1 month trial for new user" />
                <FeatureItem text="Cancel anytime you want" />
                <FeatureItem text="30 transfer or direct debit" />
              </ul>
              
              <button className="btn btn-primary w-full">
                Check Out Full Pricing Comparison
              </button>
            </div>
          </div>

          {/* Right Section - Accordion */}
          <div className="space-y-4">
            
            <AccordionItem 
              id="intro"
              title="Intro"
              description="Perfect for individuals and small projects getting started with basic features."
              price={49}
              priceAnnual={39}
              isAnnual={isAnnual}
              isExpanded={activePlan === 'intro'}
              onToggle={() => setActivePlan('intro')}
            />

            <AccordionItem 
              id="base"
              title="Base"
              description="Great for growing startups that need more power and flexibility."
              price={79}
              priceAnnual={59}
              isAnnual={isAnnual}
              isExpanded={activePlan === 'base'}
              onToggle={() => setActivePlan('base')}
            />

            <AccordionItem 
              id="pro"
              title="Pro"
              description="Pro account gives you freedom with uploading HD Videos and can also meet all your business needs."
              price={129}
              priceAnnual={99}
              isAnnual={isAnnual}
              isExpanded={activePlan === 'pro'}
              onToggle={() => setActivePlan('pro')}
              isPopular={true}
            />

            <AccordionItem 
              id="enterprise"
              title="Enterprise"
              description="Solution for big organizations requiring maximum performance and dedicated support."
              price={299}
              priceAnnual={249}
              isAnnual={isAnnual}
              isExpanded={activePlan === 'enterprise'}
              onToggle={() => setActivePlan('enterprise')}
            />

          </div>

        </div>
      </div>
    </section>
  );
}

