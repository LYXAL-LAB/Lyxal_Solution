import React, { useState } from 'react';
import Section from '../../components/layout/Section';
import Grid from '../../components/layout/Grid';
import PricingCard from '../../components/blocks/pricing/PricingCard';

export default function PricingCardFooter() {
  const [isAnnual, setIsAnnual] = useState(true);

  const prices = {
    starter: isAnnual ? 89 : 99,
    professional: isAnnual ? 179 : 199,
    enterprise: isAnnual ? 269 : 299
  };

  return (
    <Section color="base" padding="md">
      
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

      <div className="space-y-12">
        
        {/* Toggle Switch */}
        <div className="flex items-center justify-center gap-3">
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
            <span className="badge badge-soft badge-error text-xs font-bold rounded-full">10% off</span>
          </div>
        </div>

        {/* Pricing Cards Grid */}
        <Grid variant="auto-fit" gap="lg">

          <PricingCard 
            title="Free"
            price="0"
            description="Perfect for newcomers exploring crypto tools and strategies."
            defaultFeatureIcon="circle"
            btnText="Start 14 Day Trial"
            btnClass="btn-primary btn-outline mb-6" // mb-6 pour espacer des features comme l'original
            features={[
              "1 user account",
              "10 transactions/month",
              "8 altcoin pairs",
              "Basic market analysis tools",
              "Wallet API access (limited)"
            ]}
          />

          <PricingCard 
            title="Starter"
            price={prices.starter.toString()}
            description="Recommended for people with atleast 1 year experience in crypto markets."
            defaultFeatureIcon="circle"
            btnText="Starter"
            btnClass="btn-primary btn-outline mb-6"
            features={[
              "1 user account",
              "24 transaction per month",
              "16 altcoin pairs",
              "Basic AI analysis of markets",
              "Build-in wallet API for managing your crypto"
            ]}
          />

          <PricingCard 
            title="Professional"
            price={prices.professional.toString()}
            description="Best for Large business owners, startups who needs landing page."
            defaultFeatureIcon="circle"
            btnText="Purchase Plan"
            btnClass="btn-primary mb-6 shadow-lg shadow-primary/20"
            // Style spécifique pour le plan populaire
            className="border-2 border-primary shadow-lg"
            features={[
              "1 user account",
              "Unlimited transaction per month",
              "Unlimited altcoin pairs",
              "Advanced AI analysis of markets",
              "Build-in wallet API for managing your crypto"
            ]}
          />

          <PricingCard 
            title="Enterprise"
            price={prices.enterprise.toString()}
            description="Best for Large business owners, startups who needs landing page."
            defaultFeatureIcon="circle"
            btnText="Enterprise"
            btnClass="btn-primary btn-outline mb-6"
            features={[
              "Unlimited users account",
              "Unlimited transactions per month",
              "Unlimited altcoin pairs",
              "Advanced AI analysis of market by expert",
              "Build-in wallet API for managing your crypto"
            ]}
          />

        </Grid>

        {/* Footer Banner */}
        <div className="alert bg-base-100 border border-base-content/20 shadow-sm flex flex-col sm:flex-row items-center justify-between gap-4 p-6 rounded-2xl">
          <div className="flex items-center gap-4">
            <div className="bg-primary/10 p-3 rounded-full text-primary">
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M8 9h8"></path><path d="M8 13h6"></path><path d="M18 4a3 3 0 0 1 3 3v8a3 3 0 0 1 -3 3h-5l-5 3v-3h-2a3 3 0 0 1 -3 -3v-8a3 3 0 0 1 3 -3h12z"></path></svg>
            </div>
            <div className="text-center sm:text-left">
              <h6 className="text-base-content font-bold text-lg">Need Custom plans ?</h6>
              <p className="text-base-content/80 text-sm">Talk to team to customise a plan that suits your needs.</p>
            </div>
          </div>
          <button className="btn btn-outline btn-sm px-6 rounded-full">Contact Sales Team</button>
        </div>

      </div>
    </Section>
  );
}