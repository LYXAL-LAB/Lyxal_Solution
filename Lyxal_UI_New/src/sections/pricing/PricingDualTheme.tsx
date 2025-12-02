import React from 'react';
import Section from '../../components/layout/Section';
import Grid from '../../components/layout/Grid';
import PricingCard from '../../components/blocks/pricing/PricingCard';

// --- Icons Custom ---
const CheckIcon = ({ className = "" }: { className?: string }) => (
  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className={`shrink-0 ${className}`}>
    <path d="M5 12l5 5l10 -10"></path>
  </svg>
);

export default function PricingDualTheme() {
  return (
    <Section color="base" padding="md" className="relative overflow-visible">
      
      {/* Background Elements (Abstract Shapes) - Maintien du design original */}
      <div className="absolute -left-[15rem] -bottom-[15rem] -rotate-12 opacity-50 pointer-events-none z-0">
        <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/pricing/image-01.png" alt="gradient" className="w-[37.5rem] h-[37.5rem] object-contain" />
      </div>
      <div className="absolute -right-[16rem] -top-[15rem] -rotate-[72deg] opacity-50 pointer-events-none z-0">
        <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/pricing/image-03.png" alt="gradient" className="w-[37.5rem] h-[37.5rem] object-contain" />
      </div>

      <div className="relative z-10">
        {/* Header */}
        <div className="mb-16 md:space-y-6 flex flex-col items-center text-center">
          <p className="text-primary text-sm font-medium uppercase tracking-wider">Pricing</p>
          <h2 className="text-base-content text-3xl font-semibold md:text-3xl lg:text-4xl">
            Choose the best option for your logistic company
          </h2>
          <p className="text-base-content/80 text-xl max-w-2xl">
            A Comprehensive Breakdown of Our Pricing Plans to Help You Make the Best Choice!
          </p>
        </div>

        {/* Pricing Cards Grid */}
        {/* Utilisation de max-w-5xl pour centrer le bloc de 2 cartes */}
        <Grid cols={2} gap="none" className="max-w-5xl mx-auto items-center max-md:grid-cols-1 max-md:gap-6">

          {/* Free Plan (Light Theme) */}
          <PricingCard 
            title="Free Plan"
            price="0"
            description="Recommended for people with atleast 1 year experience in crypto markets."
            defaultFeatureIcon={<CheckIcon className="text-primary" />}
            features={[
              "Basic Portfolio Tracking",
              "Access to Crypto News",
              "Standard Customer Support",
              "Educational Resources",
              "Advanced Analytics Tools"
            ]}
            btnText="Get started for free"
            btnClass="btn-primary btn-outline rounded-full"
            // Customisation : Pas de bord droit sur desktop pour coller
            className="md:rounded-r-none bg-base-100 shadow-none border-base-content/20"
          />

          {/* Enterprise Plan (Dark Theme) */}
          <PricingCard 
            title="Enterprise Plan"
            price="99"
            description="Recommended for people with atleast 1 year experience in crypto markets."
            // Icônes blanches pour le thème sombre
            defaultFeatureIcon={<CheckIcon className="text-white" />}
            features={[
              "Dedicated account manager",
              "24/7 real-time market analysis",
              "Personalised portfolio reviews",
              "Invitations to premium webinars",
              "Access to exclusive industry reports"
            ]}
            btnText="Get started"
            // Bouton blanc sur fond noir
            btnClass="bg-white text-black hover:bg-white/90 border-none rounded-full w-full"
            // Customisation : Fond noir, texte blanc, scale, ombre
            className="bg-[#0F0F0F] text-white border-white/10 md:scale-105 z-10 shadow-2xl md:rounded-3xl min-h-[36rem]"
          />

        </Grid>
      </div>
    </Section>
  );
}

