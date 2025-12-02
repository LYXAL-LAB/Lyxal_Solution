import React, { useState } from 'react';
import Section from '../../components/layout/Section';
import Grid from '../../components/layout/Grid';
import PricingCard from '../../components/blocks/pricing/PricingCard';

export default function PricingHighlightedCard() {
  const [isAnnual, setIsAnnual] = useState(false);

  const prices = {
    intro: isAnnual ? 69 : 99,
    base: isAnnual ? 99 : 129,
    pro: isAnnual ? 149 : 199,
    enterprise: isAnnual ? 249 : 299
  };

  return (
    <Section color="base" padding="md">
        
      {/* Header */}
      <div className="mb-16 md:space-y-6 flex flex-col items-center text-center">
        <span className="badge badge-outline badge-lg rounded-full px-4 border-base-content/20 text-base-content/80 mb-4">Pricing Details</span>
        <h2 className="text-base-content text-3xl font-semibold md:text-3xl lg:text-4xl relative z-10">
          Choose the right plan for your business
        </h2>
        <p className="text-base-content/80 text-xl max-w-2xl">
          All-inclusive pricing. Shop now and save big!
        </p>
      </div>

      {/* Toggle Count Switch */}
      <div className="flex items-center justify-center gap-4 mb-12">
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
          <span className="badge badge-soft badge-error text-xs font-bold rounded-full">Save 10%</span>
        </div>
      </div>

      {/* Pricing Cards Grid */}
      <Grid variant="auto-fit" gap="md" className="items-center">

        <PricingCard 
          title="Intro"
          price={prices.intro.toString()}
          description="Build-in wallet API for managing your crypto"
          features={[
            "Build-in wallet API",
            "Access to components",
            "Community support",
            "Regular updates",
            "Basic analytics dashboard"
          ]}
          btnText="Choose"
          btnClass="btn-primary btn-outline"
        />

        <PricingCard 
          title="Base"
          price={prices.base.toString()}
          description="Everything in Intro plan plus advanced tools"
          features={[
            "Additional advanced components",
            "Everything in Intro plan",
            "Priority support",
            "Extended documentation",
            "Customizable themes"
          ]}
          btnText="Choose"
          btnClass="btn-primary btn-outline"
        />

        <PricingCard 
          title="Pro"
          price={prices.pro.toString()}
          description="Premium components for enhanced functionality"
          isPopular={true}
          badgeText="Best Value"
          className="scale-105 z-10 shadow-xl border-primary/20 bg-gradient-to-br from-primary/5 to-transparent"
          features={[
            "Premium components",
            "Exclusive access to features",
            "Dedicated support",
            "Early access to updates",
            "Advanced analytics dashboard"
          ]}
          btnText="Try 1 Month"
          btnClass="btn-primary shadow-lg shadow-primary/20"
        />

        <PricingCard 
          title="Enterprise"
          price={prices.enterprise.toString()}
          description="Custom solutions tailored to your business needs"
          features={[
            "Custom solutions",
            "Onboarding assistance",
            "Comprehensive training",
            "Priority feature requests"
          ]}
          btnText="Choose"
          btnClass="btn-primary btn-outline"
        />

      </Grid>
    </Section>
  );
}

