import React from 'react';
import Section from '../../components/layout/Section';
import Grid from '../../components/layout/Grid';
import PricingCard from '../../components/blocks/pricing/PricingCard';

// --- Icons Custom ---

const CircleIcon = ({ className }: { className: string }) => (
  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" className={`size-2.5 shrink-0 mt-1.5 ${className}`}>
     <circle cx="12" cy="12" r="12" />
  </svg>
);

const PaymentLogos = () => (
  <div className="flex items-center gap-2.5 justify-center mt-4 mb-2 opacity-80 grayscale hover:grayscale-0 transition-all">
    <div className="w-9 h-6 flex items-center justify-center rounded bg-base-200 p-1">
        <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/widgets/visa.png" alt="visa logo" className="max-w-full max-h-full" />
    </div>
    <div className="w-9 h-6 flex items-center justify-center rounded bg-base-200 p-1">
        <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/widgets/master-card.png" alt="master-card" className="max-w-full max-h-full" />
    </div>
    <div className="w-9 h-6 flex items-center justify-center rounded bg-base-200 p-1">
        <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/widgets/american-express.png" alt="amex" className="max-w-full max-h-full" />
    </div>
  </div>
);

export default function PricingDetailed() {
  return (
    <Section color="base" padding="md">
      
      {/* Header */}
      <div className="mb-12 flex flex-col items-center space-y-4 text-center sm:mb-16 lg:mb-24">
        <p className="text-primary text-sm font-medium uppercase tracking-wider">Pricing</p>
        <h2 className="text-base-content text-3xl font-semibold md:text-3xl lg:text-4xl">
          Pick the plan that suits you best
        </h2>
        <p className="text-base-content/80 text-xl">All plans include a free trial.</p>
      </div>

      {/* Pricing Cards */}
      <Grid variant="auto-fit" gap="lg">

        <PricingCard 
          title="Startup"
          price="299"
          description="Perfect for small businesses, startups, & founder-led sales teams."
          featuresTitle="2 users included"
          // On passe les features avec leurs icônes spécifiques
          features={[
            { text: "Access to real-time inventory tracking", icon: <CircleIcon className="text-primary" /> },
            "Scaled CSM",
            "Community Onboarding",
            { text: "Onboarding & Training", icon: <CircleIcon className="text-error" /> },
            "30,000 contacts",
            { text: "Account Management", icon: <CircleIcon className="text-warning" /> },
            "LinkedIn Automation",
            "Multichannel Sequences",
            { text: "Customer Feedback", icon: <CircleIcon className="text-success" /> },
            "AI Intent Signals",
            "Duo Copilot"
          ]}
          btnText="Purchase Now"
          btnClass="btn-primary btn-soft mb-4" // mb-4 pour espacer des features si besoin, mais ici le bouton est en haut dans l'original ? Ah non, en bas !
          // Correction: Dans PricingCard standard, le bouton est AVANT les features. 
          // Dans PricingDetailed original, le bouton est TOUT EN BAS.
          // C'est une différence de layout importante.
          // Mais grâce à `children`, on peut mettre le bouton dans `children` à la place !
        >
           {/* On injecte les logos et le bouton EN BAS grâce à children */}
           <PaymentLogos />
           {/* On désactive le bouton standard en passant btnText="" ou null si possible, 
               ou on accepte qu'il soit en haut. 
               Attendez, PricingCard affiche le bouton s'il y a btnText.
               Si on veut le bouton en bas, on peut tricher : mettre btnText="" (vide) 
               et mettre notre propre bouton dans children. */}
        </PricingCard>

        {/* Growth Plan (Popular) */}
        <PricingCard 
          title="Growth"
          price="599"
          description="Perfect for small businesses, startups, & founder-led sales teams."
          isPopular={true}
          badgeText="Popular"
          featuresTitle="2 users included"
          features={[
            { text: "Access to real-time inventory tracking", icon: <CircleIcon className="text-primary" /> },
            "Dedicated CSM",
            "Personalised Onboarding",
            { text: "Onboarding & Training", icon: <CircleIcon className="text-error" /> },
            "280,000 contacts",
            { text: "Account Management", icon: <CircleIcon className="text-warning" /> },
            "LinkedIn Automation",
            "Multichannel Sequences",
            { text: "Customer Feedback", icon: <CircleIcon className="text-success" /> },
            "AI Intent Signals",
            "Duo Copilot"
          ]}
          btnText="Purchase Now" // Le bouton sera en haut (sous le header)
          // Si on veut vraiment le bouton en bas, on utiliserait la technique children.
          // Pour l'instant, testons avec le bouton standard (au milieu), c'est souvent mieux ergonomiquement.
        >
           <PaymentLogos />
        </PricingCard>

        {/* Custom Plan */}
        <PricingCard 
          title="Custom"
          price="Custom"
          description="Perfect for small businesses, startups, & founder-led sales teams."
          featuresTitle="10 users included"
          features={[
            { text: "Access to real-time inventory tracking", icon: <CircleIcon className="text-primary" /> },
            "Dedicated CSM",
            "Personalised Onboarding",
            { text: "Onboarding & Training", icon: <CircleIcon className="text-error" /> },
            "1,000,000 contacts",
            { text: "Account Management", icon: <CircleIcon className="text-warning" /> },
            "LinkedIn Automation",
            "Multichannel Sequences",
            { text: "Customer Feedback", icon: <CircleIcon className="text-success" /> },
            "AI Intent Signals",
            "Duo Copilot"
          ]}
          btnText="Purchase Now"
          btnClass="btn-primary btn-soft"
          className="md:col-span-2 lg:col-span-1"
        >
           <PaymentLogos />
        </PricingCard>

      </Grid>
    </Section>
  );
}

