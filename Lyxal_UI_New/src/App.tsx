import React from 'react';
import PricingSection from './sections/pricing/PricingSection';
import PricingPlanSelector from './sections/pricing/PricingPlanSelector';
import PricingDetailed from './sections/pricing/PricingDetailed';
import PricingHighlight from './sections/pricing/PricingHighlight';
import PricingCardOverlay from './sections/pricing/PricingCardOverlay';
import PricingFeatureList from './sections/pricing/PricingFeatureList';
import PricingToggle from './sections/pricing/PricingToggle';
import PricingComparisonCards from './sections/pricing/PricingComparisonCards';
import PricingRadioGroups from './sections/pricing/PricingRadioGroups';
import PricingIconCards from './sections/pricing/PricingIconCards';
import PricingTableHighlight from './sections/pricing/PricingTableHighlight';
import PricingCardFooter from './sections/pricing/PricingCardFooter';
import PricingHighlightedCard from './sections/pricing/PricingHighlightedCard';

import PricingCardOverlap from './sections/pricing/PricingCardOverlap';
import PricingDualTheme from './sections/pricing/PricingDualTheme';
import PricingAccordion from './sections/pricing/PricingAccordion';
import PricingList from './sections/pricing/PricingList';
import PricingSplitLayout from './sections/pricing/PricingSplitLayout';
import PricingLifetime from './sections/pricing/PricingLifetime';
import PricingSingleCard from './sections/pricing/PricingSingleCard';

import TestimonialCarousel from './sections/testimonials/TestimonialCarousel';
import TestimonialCarouselBackground from './sections/testimonials/TestimonialCarouselBackground';
import TestimonialCenteredCarousel from './sections/testimonials/TestimonialCenteredCarousel';
import TestimonialFloatingAvatars from './sections/testimonials/TestimonialFloatingAvatars';
import TestimonialGrid from './sections/testimonials/TestimonialGrid';
import TestimonialMarquee from './sections/testimonials/TestimonialMarquee';
import TestimonialMasonry from './sections/testimonials/TestimonialMasonry';
import TestimonialSlider from './sections/testimonials/TestimonialSlider';
import TestimonialStats from './sections/testimonials/TestimonialStats';
import TestimonialVideoSlider from './sections/testimonials/TestimonialVideoSlider';


import Layout from './components/layout/Layout';

// Helper pour le séparateur
const SectionDivider = ({ title }: { title: string }) => (
  <div className="w-full h-24 bg-base-100 border-y border-base-200 my-12 flex items-center justify-center text-base-content/30 font-bold text-xl tracking-widest uppercase">
    {title}
  </div>
);

function App() {
  const Navbar = (
    <div className="navbar bg-base-100 shadow-sm px-8">
      <div className="flex-1">
        <a className="btn btn-ghost text-xl text-primary">Lyxal UI</a>
      </div>
      <div className="flex-none gap-2">
        <select 
          className="select select-bordered select-sm w-full max-w-xs"
          onChange={(e: React.ChangeEvent<HTMLSelectElement>) => {
            const theme = e.target.value;
            if (typeof document !== 'undefined') {
              document.documentElement.setAttribute('data-theme', theme);
            }
          }}
        >
          <option value="light">Light</option>
          <option value="dark">Dark</option>
          <option value="gourmet">Gourmet</option>
          <option value="corporate">Corporate</option>
          <option value="luxury">Luxury</option>
          <option value="soft">Soft</option>
          <option value="pastel">Pastel</option>
          <option value="black">Black</option>
          <option value="claude">Claude</option>
          <option value="ghibli">Ghibli</option>
          <option value="marshmallow">Marshmallow</option>
          <option value="mintlify">Mintlify</option>
          <option value="perplexity">Perplexity</option>
          <option value="shadcn">Shadcn</option>
          <option value="slack">Slack</option>
          <option value="spotify">Spotify</option>
          <option value="valorant">Valorant</option>
          <option value="vscode">VS Code</option>
        </select>
      </div>
    </div>
  );

  return (
    <Layout header={Navbar}>

        <div className="mb-8 text-center">
          <h1 className="text-3xl font-bold mb-2">Lyxal UI Preview</h1>
          <p className="opacity-70">Component Library Showcase</p>
        </div>

        <SectionDivider title="Pricing Section (Standard)" />
        <PricingSection />
        
        <SectionDivider title="Pricing Plan Selector" />
        <PricingPlanSelector />
        
        <SectionDivider title="Pricing Detailed" />
        <PricingDetailed />
        
        <SectionDivider title="Pricing Highlight" />
        <PricingHighlight />
        
        <SectionDivider title="Pricing Card Overlay" />
        <PricingCardOverlay />
        
        <SectionDivider title="Pricing Feature List" />
        <PricingFeatureList />
        
        <SectionDivider title="Pricing Toggle" />
        <PricingToggle />
        
        <SectionDivider title="Pricing Comparison Cards" />
        <PricingComparisonCards />
        
        <SectionDivider title="Pricing Radio Groups" />
        <PricingRadioGroups />
        
        <SectionDivider title="Pricing Icon Cards" />
        <PricingIconCards />
        
        <SectionDivider title="Pricing Table Highlight" />
        <PricingTableHighlight />
        
        <SectionDivider title="Pricing Card Footer" />
        <PricingCardFooter />
        
        <SectionDivider title="Pricing Highlighted Card" />
        <PricingHighlightedCard />
        
        <SectionDivider title="Pricing Card Overlap" />
        <PricingCardOverlap />
        
        <SectionDivider title="Pricing Dual Theme" />
        <PricingDualTheme />
        
        <SectionDivider title="Pricing Accordion" />
        <PricingAccordion />
        
        <SectionDivider title="Pricing List" />
        <PricingList />
        
        <SectionDivider title="Pricing Split Layout" />
        <PricingSplitLayout />
        
        <SectionDivider title="Pricing Lifetime" />
        <PricingLifetime />
        
        <SectionDivider title="Pricing Single Card" />
        <PricingSingleCard />
        
        <div className="divider my-24 text-3xl font-bold">Testimonials</div>
        
        <SectionDivider title="Testimonial Grid" />
        <TestimonialGrid />
        
        <SectionDivider title="Testimonial Masonry" />
        <TestimonialMasonry />
        
        <SectionDivider title="Testimonial Slider" />
        <TestimonialSlider />
        
        <SectionDivider title="Testimonial Stats" />
        <TestimonialStats />
        
        <SectionDivider title="Testimonial Floating Avatars" />
        <TestimonialFloatingAvatars />
        
        <SectionDivider title="Testimonial Marquee" />
        <TestimonialMarquee />
        
        <SectionDivider title="Testimonial Video Slider" />
        <TestimonialVideoSlider />
        
        <SectionDivider title="Testimonial Carousel" />
        <TestimonialCarousel />
        
        <SectionDivider title="Testimonial Carousel Background" />
        <TestimonialCarouselBackground />
        
        <SectionDivider title="Testimonial Centered Carousel" />
        <TestimonialCenteredCarousel />
        
    </Layout>
  );
}

export default App;
