import React from 'react';
import Section from '../../components/layout/Section';
import Grid from '../../components/layout/Grid';
import PricingCard from '../../components/blocks/pricing/PricingCard';

export default function PricingHighlight() {
  return (
    <Section color="muted" padding="md">
      
      {/* Header */}
      <div className="mb-12 flex flex-col items-center space-y-4 text-center sm:mb-16 lg:mb-24">
        <p className="text-primary text-sm font-medium uppercase tracking-wider">Pricing</p>
        <h2 className="text-base-content text-3xl font-semibold md:text-3xl lg:text-4xl">
          Choose the right plan for you
        </h2>
        <p className="text-base-content/80 text-xl max-w-2xl">
          Find the ideal plan that fits your budget and goals. Make informed choices with ease.
        </p>
      </div>

      {/* Pricing Cards Grid */}
      {/* Note: On force 3 colonnes ici plutôt que auto-fit pour gérer l'effet "collé" spécifiquement */}
      <Grid cols={3} gap="none" className="items-center max-md:grid-cols-1 max-md:gap-6">

        {/* Card 1: Standard (Left) */}
        <PricingCard 
          title="Standard"
          price="99"
          description="Great for startups and personal projects with a clean and simple design."
          features={[
            "2 Logo Variations",
            "3 Revisions",
            "Custom Color Palette",
            "File Formats: AI, PDF SVG, PNG"
          ]}
          btnText="Get started"
          btnClass="btn-outline btn-primary rounded-full"
          // Classes spécifiques pour coller à droite : pas de rayon droit, pas de bordure droite
          className="h-fit md:rounded-r-none md:border-r-0 z-0 bg-base-100"
        />

        {/* Card 2: Professional (Center/Highlight) */}
        <PricingCard 
          title="Professional"
          price="299"
          description="The comprehensive solution for businesses looking for a fully customized logo."
          isPopular={true}
          badgeText="Best Value"
          features={[
            "6 Logo Variations",
            "Unlimited Revisions",
            "Custom Color Palette & Branding",
            "File Formats: .AI, .PDF, .SVG, .PNG",
            "Estimated Delivery Time: 3 Days",
            "Extra assets: Favicon, Social Media Kit"
          ]}
          btnText="Get started"
          btnClass="btn-primary rounded-full bg-white text-primary hover:bg-white/90 border-none"
          // Le centre est mis en avant : scale, ombre, z-index élevé
          className="scale-105 z-10 shadow-xl bg-primary text-primary-content border-none md:rounded-3xl"
        />

        {/* Card 3: Premium (Right) */}
        <PricingCard 
          title="Premium"
          price="199"
          description="For businesses seeking a solid logo with room for refinement."
          features={[
            "4 Logo Variations",
            "4 Revisions",
            "Custom Color Palette",
            "File Formats: AI, PDF SVG, PNG"
          ]}
          btnText="Get started"
          btnClass="btn-outline btn-primary rounded-full"
          // Classes spécifiques pour coller à gauche : pas de rayon gauche, pas de bordure gauche
          className="h-fit md:rounded-l-none md:border-l-0 z-0 bg-base-100"
        />

      </Grid>
    </Section>
  );
}

