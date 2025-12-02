import React from 'react';

// --- Sub-Components ---

const FeatureIcon = ({ icon }: { icon: React.ReactNode }) => (
  <div className="border-primary text-primary size-10 shrink-0 flex items-center justify-center rounded-full border">
    {icon}
  </div>
);

const FeatureItem = ({ icon, title, description }: { icon: React.ReactNode, title: string, description: string }) => (
  <div className="flex items-center gap-4">
    <FeatureIcon icon={icon} />
    <div className="text-base-content">
      <h3 className="text-lg font-medium">{title}</h3>
      <p className="text-base-content/80 text-sm">{description}</p>
    </div>
  </div>
);

export default function PricingLifetime() {
  return (
    <section className="bg-base-100 py-8 sm:py-16 lg:py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        {/* Header */}
        <div className="mb-16 md:space-y-6 flex flex-col items-center text-center">
          <h2 className="text-base-content text-3xl font-semibold md:text-3xl lg:text-4xl">
            Make the best investment
          </h2>
          <p className="text-base-content/80 text-xl max-w-2xl">
            Select from best plans, ensuring a perfect match. Need more or less? Customize your subscription for a seamless fit!
          </p>
        </div>

        {/* Main Content Card */}
        <div className="card border border-base-content/20 shadow-sm">
          <div className="card-body p-0 flex-col sm:flex-row">
            
            {/* Features Grid (Left) */}
            <div className="flex-1 p-8 md:p-12">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-10">
                
                {/* Column 1 */}
                <div className="space-y-8">
                  <FeatureItem 
                    icon={<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M6.657 18c-2.572 2.1 -6.657 2.554 -6.657 -4.2c0 -3.373 3.814 -6 8.514 -6c4.7 0 8.514 2.627 8.514 6c0 6.754 -4.085 10.2 -10.371 10.2c-3.772 0 -6.657 -1.87 -6.657 -4.2"></path><path d="M12 8l0 -5"></path><path d="M12 7a4 4 0 1 1 0 -7.999"></path></svg>}
                    title="Cloud Storage"
                    description="Up to 100GB for works"
                  />
                  <FeatureItem 
                    icon={<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 12l3 3l3 -3l-3 -3z"></path><path d="M15 12l3 3l3 -3l-3 -3z"></path><path d="M9 6l3 3l3 -3l-3 -3z"></path><path d="M9 18l3 3l3 -3l-3 -3z"></path></svg>}
                    title="API Access"
                    description="Create anything you want"
                  />
                  <FeatureItem 
                    icon={<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M8 9h8"></path><path d="M8 13h6"></path><path d="M18 4a3 3 0 0 1 3 3v8a3 3 0 0 1 -3 3h-5l-5 3v-3h-2a3 3 0 0 1 -3 -3v-8a3 3 0 0 1 3 -3h12z"></path></svg>}
                    title="Live Chat"
                    description="Connect with your customers"
                  />
                </div>

                {/* Column 2 */}
                <div className="space-y-8">
                  <FeatureItem 
                    icon={<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M8 7a4 4 0 1 0 8 0a4 4 0 0 0 -8 0"></path><path d="M6 21v-2a4 4 0 0 1 4 -4h4a4 4 0 0 1 4 4v2"></path></svg>}
                    title="Unlimited Accounts"
                    description="We don't limit you to create accounts"
                  />
                  <FeatureItem 
                    icon={<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 17.75l-6.172 3.245l1.179 -6.873l-5 -4.867l6.9 -1l3.086 -6.253l3.086 6.253l6.9 1l-5 4.867l1.179 6.873z"></path></svg>}
                    title="Custom Domain"
                    description="Add your custom domain"
                  />
                  <FeatureItem 
                    icon={<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M8 9h8"></path><path d="M8 13h6"></path><path d="M18 4a3 3 0 0 1 3 3v8a3 3 0 0 1 -3 3h-5l-5 3v-3h-2a3 3 0 0 1 -3 -3v-8a3 3 0 0 1 3 -3h12z"></path><path d="M16 22l5 -5"></path><path d="M21 21.5v-4.5h-4.5"></path></svg>}
                    title="Share Information"
                    description="Easily share your message"
                  />
                </div>

              </div>
            </div>

            {/* Divider */}
            <div className="hidden sm:block w-px bg-base-content/10 my-8"></div>
            <div className="sm:hidden h-px w-full bg-base-content/10"></div>

            {/* Pricing Column (Right) */}
            <div className="sm:w-[22rem] shrink-0 p-8 md:p-12 flex flex-col items-center justify-center text-center bg-base-200/30">
              <h3 className="text-primary text-5xl font-bold mb-2">$99</h3>
              <span className="text-base-content/80 font-medium mb-6 block">Lifetime Account</span>
              <button className="btn btn-primary btn-lg w-full shadow-lg shadow-primary/20 mb-4">Buy Now</button>
              <span className="text-base-content/50 text-sm">30 Days Money back Guarantee</span>
            </div>

          </div>
        </div>

      </div>
    </section>
  );
}

