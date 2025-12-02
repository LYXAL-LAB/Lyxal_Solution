import React, { useState } from 'react';

// --- Sub-Components ---

const StarIcon = ({ filled = true, half = false }: { filled?: boolean, half?: boolean }) => {
  if (half) {
    return (
      <span className="icon-[tabler--star-half-filled] text-warning size-6 shrink-0">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M8.243 7.34l-6.38 .925l4.613 4.494l-1.088 6.353l5.651 -2.971l5.651 2.971l-1.088 -6.353l4.613 -4.494l-6.38 -.925l-2.855 -5.783z"></path>
        </svg>
      </span>
    );
  }
  return (
    <span className="icon-[tabler--star-filled] text-warning size-6 shrink-0">
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="currentColor" className={filled ? "text-warning" : "text-base-content/20"}>
        <path d="M8.243 7.34l-6.38 .925l4.613 4.494l-1.088 6.353l5.651 -2.971l5.651 2.971l-1.088 -6.353l4.613 -4.494l-6.38 -.925l-2.855 -5.783z"></path>
      </svg>
    </span>
  );
};

const TestimonialVideoCard = ({ 
  name, 
  role, 
  company, 
  image, 
  isActive, 
  onClick 
}: { 
  name: string, 
  role: string, 
  company: string, 
  image: string, 
  isActive: boolean, 
  onClick: () => void 
}) => (
  <div className={`min-w-[292px] max-w-[292px] shrink-0 transition-all duration-500 ${isActive ? 'opacity-100' : 'opacity-40 hover:opacity-100'}`}>
    <div className="group relative h-[400px] rounded-box overflow-hidden cursor-pointer" onClick={onClick}>
      <img src={image} alt={name} className="absolute inset-0 w-full h-full object-cover transition-transform duration-700 group-hover:scale-110" />
      
      {/* Overlay & Play Button */}
      <div className={`absolute inset-0 bg-black/20 flex items-center justify-center transition-opacity duration-300 ${isActive ? 'opacity-100' : 'opacity-0 group-hover:opacity-100'}`}>
        <button className="btn btn-circle btn-lg bg-white/20 backdrop-blur-md border-white/40 text-white hover:bg-white hover:text-primary hover:scale-110 transition-all shadow-xl">
          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="currentColor" className="size-8">
            <path d="M6 4l15 8l-15 8z"></path>
          </svg>
        </button>
      </div>
    </div>
    
    {/* Info */}
    <div className="mt-4 text-center">
      <h4 className={`text-lg font-bold transition-colors ${isActive ? 'text-primary' : 'text-base-content'}`}>{name}</h4>
      <p className="text-base-content/70 text-sm">
        {role} at <span className="font-medium text-base-content">{company}</span>
      </p>
    </div>
  </div>
);

export default function TestimonialVideoSlider() {
  const [activeSlide, setActiveSlide] = useState(1);

  const testimonials = [
    {
      name: "Craig Bator",
      role: "CEO & Co Founder",
      company: "Zendesk",
      image: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/testimonials/testimonials-4.png"
    },
    {
      name: "Martin Dorwart",
      role: "Product manager",
      company: "Orbit",
      image: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/testimonials/testimonials-5.png"
    },
    {
      name: "Alexandra Lee",
      role: "Lead Developer",
      company: "TechNova",
      image: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/testimonials/testimonials-6.png"
    },
    {
      name: "Jason Wu",
      role: "Product Designer",
      company: "InnovateX",
      image: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/testimonials/testimonials-7.png"
    },
    {
      name: "Esther Howard",
      role: "CEO & Co Founder",
      company: "Oracle",
      image: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/testimonials/testimonials-8.png"
    }
  ];

  return (
    <section className="bg-base-100 py-16 lg:py-24 overflow-hidden">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        {/* Header */}
        <div className="mb-16 flex flex-col items-center text-center space-y-4">
          <span className="text-sm font-bold text-primary tracking-widest uppercase">TESTIMONIALS</span>
          <h2 className="text-4xl md:text-5xl font-bold text-base-content">
            Our Valuable <span className="text-primary relative inline-block">
              Clients
              <span className="absolute bottom-1 left-0 -z-10 h-3 w-full bg-warning/20 -rotate-1"></span>
            </span>
          </h2>
          <p className="text-xl text-base-content/80 max-w-2xl">
            ThemeSelection's admin template impresses me with its code structure, quality, and UI design. It's highly customizable.
          </p>

          {/* Rating */}
          <div className="flex gap-1 pt-4">
            {[...Array(5)].map((_, i) => (
              <StarIcon key={i} filled={true} half={i === 4} />
            ))}
          </div>
        </div>

        {/* Video Carousel */}
        <div className="relative w-full overflow-x-auto pb-8 scrollbar-hide">
          <div className="flex gap-6 justify-start lg:justify-center min-w-max px-4">
            {testimonials.map((testimonial, index) => (
              <TestimonialVideoCard 
                key={index}
                {...testimonial}
                isActive={index === activeSlide}
                onClick={() => setActiveSlide(index)}
              />
            ))}
          </div>
        </div>

      </div>
    </section>
  );
}

