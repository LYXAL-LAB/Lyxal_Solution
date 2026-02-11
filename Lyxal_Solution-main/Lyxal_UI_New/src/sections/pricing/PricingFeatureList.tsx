import React from 'react';
import Section from '../../components/layout/Section';
import Grid from '../../components/layout/Grid';
import PricingCard from '../../components/blocks/pricing/PricingCard';

export default function PricingFeatureList() {
  return (
    <Section color="base" padding="md">
      
      {/* Header */}
      <div className="mb-12 flex flex-col items-center space-y-4 text-center sm:mb-16 lg:mb-24">
        <span className="badge badge-neutral badge-lg rounded-full px-4 border-none">Pricing</span>
        <h2 className="text-base-content text-3xl font-semibold md:text-3xl lg:text-4xl">
          Choose the best option for your logistic company
        </h2>
        <p className="text-base-content/80 text-xl max-w-2xl">
          A Comprehensive Breakdown of Our Pricing Plans to Help You Make the Best Choice!
        </p>
      </div>

      {/* Pricing Cards Grid */}
      <Grid variant="auto-fit" gap="lg">

        <PricingCard 
          title="Free"
          price="0"
          description="Recommended for people with atleast 1 year experience in crypto markets."
          featuresTitle="Features"
          defaultFeatureIcon="circle" // Utilisation des cercles !
          features={[
            "Access to real-time inventory tracking",
            "Integration with Digital Marketing email",
            "Basic analytics and email support",
            "Custom dashboards and Phone support",
            "Real-time data tracking and 24/7 support"
          ]}
          btnText="Free plan"
          btnClass="btn-primary btn-soft"
        />

        <PricingCard 
          title="Premium"
          price="99"
          description="Everything in the Basic Plan plus advanced search, better analytics.."
          featuresTitle="Features"
          defaultFeatureIcon="circle"
          features={[
            "All Premium Plan features",
            "Advanced data filtering search capabilities",
            "Custom branding options",
            "Extended API access for integrations",
            "Real-time data tracking and 24/7 support",
            "Dedicated account manager"
          ]}
          btnText="Purchase Plan"
          btnClass="btn-primary border-2"
          className="border-primary border-2"
        />

        <PricingCard 
          title="Enterprise"
          price="299"
          description="Includes all Professional Plan features plus full logistics automation etc."
          featuresTitle="Features"
          defaultFeatureIcon="circle"
          features={[
            "Custom onboarding process",
            "Priority support response",
            "Access to exclusive webinars",
            "Monthly performance reviews",
            "Real-time data tracking and 24/7 support",
            "Dedicated account manager",
            "Tailored training sessions and resources"
          ]}
          btnText="Purchase Plan"
          btnClass="btn-primary btn-soft"
          className="md:col-span-2 xl:col-span-1"
        />

      </Grid>
    </Section>
  );
}