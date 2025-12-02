import React from 'react';

// --- Sub-Components ---

const CheckIcon = ({ className = "text-white" }: { className?: string }) => (
  <span className={`icon-[tabler--check] size-5 shrink-0 ${className}`}>
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M5 12l5 5l10 -10"></path>
    </svg>
  </span>
);

const FeatureItem = ({ text }: { text: string }) => (
  <li className="flex items-start gap-2 py-1 text-white">
    <CheckIcon className="mt-0.5" />
    <span>{text}</span>
  </li>
);

// Background Glow Effect
const GlowEffect = () => (
  <div className="absolute left-2 bottom-[-3.75rem] z-0">
    <svg xmlns="http://www.w3.org/2000/svg" width="48" height="16" viewBox="0 0 48 16" fill="none">
      <g opacity="0.82" filter="url(#filter0_f_16269_222925)">
        <ellipse cx="17" cy="7" rx="17" ry="7" transform="matrix(-1 0 0 1 41 7)" fill="white"></ellipse>
      </g>
      <defs>
        <filter id="filter0_f_16269_222925" x="0" y="0" width="48" height="28" filterUnits="userSpaceOnUse" colorInterpolationFilters="sRGB">
          <feFlood floodOpacity="0" result="BackgroundImageFix"></feFlood>
          <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"></feBlend>
          <feGaussianBlur stdDeviation="3.5" result="effect1_foregroundBlur_16269_222925"></feGaussianBlur>
        </filter>
      </defs>
    </svg>
  </div>
);

export default function PricingCardOverlay() {
  return (
    <section className="relative py-16 lg:py-24 overflow-hidden">
      {/* Background Image */}
      <div className="absolute inset-0 -z-10 size-full">
        <img 
          src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/pricing/image-04.png" 
          alt="bg image" 
          className="size-full object-cover" 
        />
        {/* Optional: Dark overlay to ensure text readability if image fails or is too bright */}
        <div className="absolute inset-0 bg-black/40"></div> 
      </div>

      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Header */}
        <div className="mb-16 lg:mb-24 flex flex-col items-center space-y-4 text-center text-white">
          <span className="badge badge-outline badge-lg border-white text-white rounded-full px-4">Pricing</span>
          <h2 className="text-3xl md:text-4xl font-semibold">
            Choose the best option for your logistic company
          </h2>
          <p className="text-white/80 text-xl max-w-2xl">
            A Comprehensive Breakdown of Our Pricing Plans to Help You Make the Best Choice!
          </p>
        </div>

        {/* Pricing Cards */}
        <div className="flex flex-col md:flex-row items-center justify-center gap-6">

          {/* Basic Plan */}
          <div className="card w-full max-w-md rounded-[2rem] border border-white/30 bg-white/15 backdrop-blur-xl shadow-none">
            <div className="card-body p-8 gap-8">
              <div className="space-y-4">
                
                {/* Icon with Glow */}
                <div className="relative overflow-hidden w-12 h-12 flex items-center justify-center rounded-2xl border border-white/30 bg-white/15 backdrop-blur-xl text-white mb-6">
                  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="size-6 relative z-10">
                    <path d="M18.816 13.58c2.292 2.138 3.546 4.03 3.184 5.42c-.69 2.666 -5.5 3.266 -10 3c-4.5 .266 -9.31 -3.334 -10 -6c-.362 -1.39 .892 -3.282 3.184 -5.42"></path>
                    <path d="M11 9l-3 -3l-3 3l3 3l3 -3"></path>
                    <path d="M11 9l4 3"></path>
                    <path d="M11 9l-3 8"></path>
                  </svg>
                  <GlowEffect />
                </div>

                <h3 className="text-white text-3xl font-semibold">Basic</h3>

                <div className="flex items-baseline gap-1 text-white">
                  <span className="text-lg font-medium">$</span>
                  <span className="text-4xl font-bold">0</span>
                  <span className="text-sm">/month</span>
                </div>

                <p className="text-white/80">
                  Recommended for those new to the crypto market or looking for a simple and easy-to-use platform.
                </p>
              </div>

              <ul className="space-y-1">
                <FeatureItem text="Basic Portfolio Tracking" />
                <FeatureItem text="Access to Crypto News" />
                <FeatureItem text="Standard Customer Support" />
                <FeatureItem text="Educational Resources" />
                <FeatureItem text="Advanced Analytics Tools" />
              </ul>

              <button className="btn bg-white text-black hover:bg-white/90 w-full border-none text-lg">Get started</button>
            </div>
          </div>

          {/* Enterprise Plan */}
          <div className="card w-full max-w-md rounded-[2rem] border border-white/30 bg-white/15 backdrop-blur-xl shadow-none">
            <div className="card-body p-8 gap-8">
              <div className="space-y-4">
                
                {/* Icon with Glow */}
                <div className="relative overflow-hidden w-12 h-12 flex items-center justify-center rounded-2xl border border-white/30 bg-white/15 backdrop-blur-xl text-white mb-6">
                  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="size-6 relative z-10">
                    <path d="M7 17m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0"></path>
                    <path d="M17 17m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0"></path>
                    <path d="M7 14v-8a5 5 0 0 1 10 0v8"></path>
                    <path d="M6 21v-13a3 3 0 0 1 3 -3h.5"></path>
                    <path d="M18 21v-13a3 3 0 0 0 -3 -3h-.5"></path>
                  </svg>
                  <GlowEffect />
                </div>

                <h3 className="text-white text-3xl font-semibold">Enterprise</h3>

                <div className="flex items-baseline gap-1 text-white">
                  <span className="text-lg font-medium">$</span>
                  <span className="text-4xl font-bold">99</span>
                  <span className="text-sm">/month</span>
                </div>

                <p className="text-white/80">
                  Recommended for people with at least 1 year of experience in crypto markets.
                </p>
              </div>

              <ul className="space-y-1">
                <FeatureItem text="Dedicated Account Manager" />
                <FeatureItem text="24/7 Real-Time Market Analysis" />
                <FeatureItem text="Personalized Portfolio Reviews" />
                <FeatureItem text="Invitations to Premium Webinars" />
                <FeatureItem text="Access to Exclusive Industry Reports" />
              </ul>

              <button className="btn bg-white text-black hover:bg-white/90 w-full border-none text-lg">Get started</button>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}

