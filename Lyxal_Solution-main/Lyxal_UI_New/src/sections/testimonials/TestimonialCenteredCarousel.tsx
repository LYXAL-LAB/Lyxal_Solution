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

const TestimonialCard = ({ 
  name, 
  role, 
  company, 
  image, 
  quote 
}: { 
  name: string, 
  role: string, 
  company: string, 
  image: string, 
  quote: string 
}) => (
  <div className="bg-base-100 rounded-box shadow-md lg:rounded-2xl p-8 text-center border border-base-content/5 h-full flex flex-col justify-between">
    <div className="space-y-6">
      {/* Star Rating */}
      <div className="flex justify-center gap-1">
        {[...Array(5)].map((_, i) => (
          <StarIcon key={i} filled={true} half={i === 4} />
        ))}
      </div>

      {/* Testimonial Text */}
      <p className="text-base-content/80 text-lg leading-relaxed">
        {quote}
      </p>

      {/* Customer Info */}
      <div className="flex flex-col items-center gap-3">
        <div className="avatar mb-2">
          <div className="size-10 rounded-full">
            <img src={image} alt={name} />
          </div>
        </div>
        <div className="text-center">
          <h4 className="text-base-content font-medium">{name}</h4>
          <p className="text-base-content/80 text-xs">
            {role} at <span className="font-semibold text-base-content">{company}</span>
          </p>
        </div>
      </div>
    </div>
  </div>
);

export default function TestimonialCenteredCarousel() {
  const [activeSlide, setActiveSlide] = useState(0);

  const testimonials = [
    {
      name: "Marley Calzoni",
      role: "CEO & Co-founder",
      company: "Lemoncompany",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-17.png",
      quote: "Outstanding product—well-crafted, user-friendly, and exactly what I expected. The team went above and beyond to help."
    },
    {
      name: "Martin Dorwart",
      role: "Product manager",
      company: "Orbit",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png",
      quote: "The service exceeded my expectations. The team was responsive, and the product quality was top-notch. Highly recommend!"
    },
    {
      name: "Alexandra Lee",
      role: "Lead Developer",
      company: "TechNova",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png",
      quote: "Exceptional quality and service. The team was attentive to our needs, and the final product was flawless. Will definitely use again!"
    }
  ];

  const brands = [
    { name: "Google", src: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/google-logo-bw.png" },
    { name: "Microsoft", src: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/microsoft-logo-bw.png" },
    { name: "Shopify", src: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/shopify-logo-bw.png" }
  ];

  return (
    <section className="bg-base-100 py-16 lg:py-24 overflow-hidden">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        {/* Background Gradient Effect */}
        <div className="absolute inset-0 bg-gradient-to-b from-base-100 via-transparent to-base-100 pointer-events-none -z-10"></div>

        <div className="relative z-10 bg-base-100/50 rounded-3xl p-8 sm:p-12 lg:p-16 border border-base-content/5 shadow-sm">
          
          {/* Header Section */}
          <div className="mb-16 lg:mb-20 flex flex-col items-center text-center space-y-6">
            <span className="text-primary text-sm font-medium tracking-widest uppercase">TESTIMONIALS</span>
            <h2 className="text-3xl md:text-4xl font-bold text-base-content">
              Don't just take our word for it. <br/>
              <span className="relative inline-block text-primary">
                They found Verified data
                <span className="absolute bottom-1 left-0 -z-10 h-3 w-full bg-warning/20 -rotate-1"></span>
              </span> with enrich.
            </h2>
            <p className="text-xl text-base-content/80 max-w-2xl">
              Discover the enthusiastic feedback from our satisfied clients!
            </p>
            <button className="btn btn-primary btn-soft shadow-md shadow-primary/20 mt-4">More Customer Stories</button>

            {/* Global Rating */}
            <div className="flex items-center justify-center gap-1 pt-2">
              {[...Array(5)].map((_, i) => (
                <StarIcon key={i} filled={true} half={i === 4} />
              ))}
            </div>
          </div>

          {/* Carousel Section */}
          <div className="relative max-w-3xl mx-auto pb-2">
            <div className="overflow-hidden">
              <div 
                className="flex transition-transform duration-500 ease-in-out" 
                style={{ transform: `translateX(-${activeSlide * 100}%)` }}
              >
                {testimonials.map((testimonial, index) => (
                  <div key={index} className="w-full shrink-0 px-4">
                     <TestimonialCard {...testimonial} />
                  </div>
                ))}
              </div>
            </div>
            
            {/* Pagination Dots */}
            <div className="absolute -top-12 right-0 flex gap-2">
              {testimonials.map((_, index) => (
                <button 
                  key={index}
                  onClick={() => setActiveSlide(index)}
                  className={`h-2 rounded-full transition-all duration-300 ${index === activeSlide ? 'w-8 bg-primary' : 'w-2 bg-base-content/20 hover:bg-base-content/40'}`}
                  aria-label={`Go to slide ${index + 1}`}
                />
              ))}
            </div>
          </div>

          {/* Trusted Brands */}
          <div className="mt-16 flex flex-wrap items-center justify-center gap-8 md:gap-16 opacity-50 grayscale hover:grayscale-0 transition-all duration-500">
            {brands.map((brand, index) => (
              <img key={index} src={brand.src} alt={brand.name} className="h-7 w-auto object-contain hover:scale-110 transition-transform duration-300" />
            ))}
          </div>

        </div>

      </div>
    </section>
  );
}

