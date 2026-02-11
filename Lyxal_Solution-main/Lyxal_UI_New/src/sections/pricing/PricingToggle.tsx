import React, { useState } from 'react';
import Section from '../../components/layout/Section';
import Grid from '../../components/layout/Grid';
import PricingCard from '../../components/blocks/pricing/PricingCard';

export default function PricingToggle() {
  const [isAnnual, setIsAnnual] = useState(true);

  return (
    <Section color="base" padding="lg" className="relative overflow-hidden">
      
        {/* Hero/Header Section with Black Background */}
        <div className="relative flex flex-col items-center overflow-hidden rounded-3xl bg-black text-white shadow-lg pt-16 lg:pt-24 pb-48 lg:pb-60 isolate">
          
          {/* Background Abstract Shape */}
          <div className="absolute top-0 -right-60 z-0 h-[23rem] w-[105rem] -rotate-[19deg] shrink-0 rounded-[100%] bg-gradient-to-br from-primary via-black to-black blur-[92px] opacity-50"></div>

          <div className="relative z-10 flex flex-col items-center text-center max-w-3xl mx-auto space-y-4 px-4">
            <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold text-white">
              <span className="relative inline-block">
                Pricing Details
                {/* Underline Gradient */}
                <span className="absolute bottom-0 left-0 -z-10 h-2 w-full bg-gradient-to-r from-warning to-transparent opacity-50 blur-sm" aria-hidden="true"></span>
              </span>
            </h2>
            <p className="text-white/80 text-lg md:text-xl max-w-2xl">
              Select from best plans, ensuring a perfect match. Need more or less? Customize your subscription for a seamless fit!
            </p>
          </div>

          {/* Toggle Switch */}
          <div className="relative mt-10 flex items-center justify-center">
            <div className="flex items-center rounded-full border border-white/20 p-1 bg-white/10 backdrop-blur-sm">
              <button 
                onClick={() => setIsAnnual(false)}
                className={`btn btn-sm rounded-full border-none px-6 transition-all ${!isAnnual ? 'bg-white text-black hover:bg-white' : 'bg-transparent text-white hover:bg-white/10'}`}
              >
                Monthly
              </button>
              <button 
                onClick={() => setIsAnnual(true)}
                className={`btn btn-sm rounded-full border-none px-6 transition-all ${isAnnual ? 'bg-white text-black hover:bg-white' : 'bg-transparent text-white hover:bg-white/10'}`}
              >
                Yearly
              </button>
            </div>

            {/* Save 10% Badge with Arrow */}
            <div className="absolute left-[105%] top-1/2 -translate-y-1/2 flex items-center">
              <div className="relative">
                <div className="absolute -left-12 -top-6 w-12 h-12 text-white">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 45 14" fill="currentColor" className="w-full h-full">
                    <path d="M43.6096 7.63949C44.0909 7.36868 44.2616 6.75895 43.9908 6.27762C43.72 5.79628 43.1102 5.62562 42.6289 5.89642L43.6096 7.63949ZM1.0941 2.40237C0.549028 2.49131 0.179254 3.00528 0.26819 3.55035L1.71751 12.4329C1.80645 12.978 2.32041 13.3477 2.86549 13.2588C3.41057 13.1699 3.78034 12.6559 3.6914 12.1108L2.40312 4.21523L10.2987 2.92695C10.8438 2.83801 11.2136 2.32404 11.1246 1.77897C11.0357 1.23389 10.5217 0.864116 9.97664 0.953052L1.0941 2.40237ZM43.1192 6.76795L42.6289 5.89642C30.7701 12.5684 21.5868 12.3994 14.919 10.3011C8.17493 8.17872 3.95418 4.09922 1.83915 2.57757L1.25514 3.38932L0.67113 4.20107C2.54588 5.54985 7.1711 9.95952 14.3186 12.2088C21.5424 14.4821 31.2962 14.5672 43.6096 7.63949L43.1192 6.76795Z" fillOpacity="1"></path>
                  </svg>
                </div>
                <span className="badge badge-warning badge-lg rounded-full px-3 font-bold text-xs uppercase tracking-wider shadow-lg transform rotate-6">Save 10%</span>
              </div>
            </div>
          </div>
        </div>

        {/* Cards Container - Negative Margin to Overlap */}
        <Grid variant="auto-fit" gap="md" className="items-center relative z-20 -mt-32 px-4">

          <PricingCard 
            title="Premium Plus"
            price={isAnnual ? '299' : '349'}
            description="Perfect for startups looking to get started quickly with advanced features."
            btnText="Subscribe Now"
            btnClass="btn-primary btn-soft"
            defaultFeatureIcon="circle-check"
            featuresTitle="Features Included"
            features={[
              "2 dedicated account managers",
              "24/7 support with faster response times",
              "Customizable analytics tools",
              "Monthly strategy sessions with experts"
            ]}
          />

          <PricingCard 
            title="Elite Access"
            price={isAnnual ? '399' : '499'}
            description="Designed for growing teams who need advanced tools and more integrations."
            btnText="Subscribe Now"
            btnClass="btn-primary shadow-lg shadow-primary/30"
            isPopular={true}
            badgeText="Popular"
            className="lg:scale-110 z-30 shadow-2xl border-2 border-primary"
            defaultFeatureIcon="circle-check"
            featuresTitle="Features Included"
            features={[
              "5 dedicated account managers",
              "Customized onboarding process",
              "VIP customer support assistance",
              "Exclusive beta features before release",
              "Weekly strategy sessions with experts"
            ]}
          />

          <PricingCard 
            title="Elite Plus"
            price={isAnnual ? '499' : '699'}
            description="The ideal solution for enterprises needing full customisation and dedicated support."
            btnText="Subscribe Now"
            btnClass="btn-primary btn-soft"
            defaultFeatureIcon="circle-check"
            featuresTitle="Features Included"
            features={[
              "Unlimited Dedicated account manager",
              "Advanced risk management tools",
              "1-on-1 business mentorship",
              "Everyday strategy sessions with experts"
            ]}
          />

        </Grid>
    </Section>
  );
}

