import React, { useState } from 'react';

// --- Sub-Components ---

const QuoteIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="124" height="106" viewBox="0 0 124 106" fill="none" className="w-full h-full">
    <path fillRule="evenodd" clipRule="evenodd" d="M88.9041 86.7905L64.1279 39.6073C63.8185 39.0181 63.0306 38.8898 62.5503 39.3505L26.167 74.2494C25.937 74.47 25.6157 74.5678 25.3018 74.5127L4.1886 70.8059C3.37343 70.6628 3.07504 69.6479 3.68302 69.0864L67.7095 9.94915C68.1919 9.50351 68.9657 9.63608 69.2723 10.2169L111.095 89.444C111.483 90.1792 110.857 91.0395 110.038 90.8957L89.6165 87.3105C89.3113 87.2569 89.0482 87.0648 88.9041 86.7905ZM58.9547 67.9986L76.3266 98.2246C76.7492 98.9599 76.122 99.8545 75.2866 99.7078L33.4859 92.369C32.674 92.2265 32.3736 91.218 32.9751 90.6543L57.404 67.7671C57.8746 67.3262 58.6333 67.4394 58.9547 67.9986Z" fill="white"></path>
  </svg>
);

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
  <div className="card rounded-box overflow-hidden border border-base-content/10 h-full bg-base-100">
    <div className="grid grid-cols-1 md:grid-cols-5 items-stretch h-full">
      
      {/* Content Section */}
      <div className="md:col-span-3 p-8 md:p-12 flex flex-col justify-center relative z-10">
        <p className="text-base-content/80 text-lg md:text-xl font-medium leading-relaxed mb-8">
          {quote}
        </p>
        <div>
          <h4 className="text-xl font-bold text-base-content">{name}</h4>
          <p className="text-base-content/80 text-sm mt-1">
            {role} at <span className="font-semibold text-base-content">{company}</span>
          </p>
        </div>
      </div>

      {/* Image Section */}
      <div className="relative z-0 flex w-full justify-center items-end bg-base-200/30 md:col-span-2 lg:justify-end overflow-hidden h-64 md:h-auto">
        {/* Background Quote Icon */}
        <div className="absolute bottom-6 left-6 lg:-left-9 z-0 w-32 h-28 opacity-20 text-base-content pointer-events-none">
          <QuoteIcon />
        </div>
        
        {/* Image */}
        <img 
          src={image} 
          alt={name} 
          className="relative z-10 max-h-50 md:max-h-full object-contain object-bottom"
        />
      </div>

    </div>
  </div>
);

export default function TestimonialCarouselBackground() {
  const [activeSlide, setActiveSlide] = useState(0);

  const testimonials = [
    {
      name: "Hanna Bator",
      role: "CEO & Co Founder",
      company: "Oracle",
      image: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/testimonials/testimonials-11.png",
      quote: "I was impressed by the polished UI design. Everything feels modern, intuitive, and perfectly suited for professional dashboards."
    },
    {
      name: "Angel Mango",
      role: "CEO & Co Founder",
      company: "Oracle",
      image: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/testimonials/testimonials-12.png",
      quote: "ThemeSelection’s admin template stands out for its clean code and thoughtful architecture. It’s clearly built with developers in mind."
    }
  ];

  return (
    <section className="bg-base-100 py-16 lg:py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-24 mb-12 lg:mb-20 items-end">
          <div>
            <span className="text-sm font-bold text-primary tracking-widest uppercase block mb-4">TESTIMONIALS</span>
            <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold text-base-content mb-4">
              Some of our valuable customers feedback
            </h2>
            <p className="text-xl text-base-content/80">
              predictive analytics, and recommendations to optimize their processes and better business outcomes.
            </p>
          </div>
          
          <div>
            <button className="btn btn-lg btn-primary btn-soft w-full md:w-auto">More Customer Stories</button>
          </div>
        </div>

        {/* Carousel Container */}
        <div className="relative w-full overflow-hidden">
          <div 
            className="flex transition-transform duration-500 ease-in-out" 
            style={{ transform: `translateX(-${activeSlide * 100}%)` }}
          >
            {testimonials.map((testimonial, index) => (
              <div key={index} className="w-full shrink-0 px-2">
                 <TestimonialCard {...testimonial} />
              </div>
            ))}
          </div>

          {/* Pagination Dots */}
          <div className="flex justify-center gap-2 mt-8">
            {testimonials.map((_, index) => (
              <button 
                key={index}
                onClick={() => setActiveSlide(index)}
                className={`h-3 rounded-full transition-all duration-300 ${index === activeSlide ? 'w-8 bg-primary' : 'w-3 bg-base-content/20 hover:bg-base-content/40'}`}
                aria-label={`Go to slide ${index + 1}`}
              />
            ))}
          </div>

        </div>

      </div>
    </section>
  );
}

