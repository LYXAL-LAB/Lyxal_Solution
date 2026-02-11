import React, { useState } from 'react';

// --- Sub-Components ---

const QuoteIcon = () => (
  <span className="text-primary absolute left-1/2 top-0 -translate-x-1/2 -translate-y-1/2 z-10 flex w-10 h-10 items-center justify-center bg-base-100 rounded-full border border-base-content/10">
    <svg width="20" height="16" viewBox="0 0 21 16" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M0.302557 16V11.3977C0.302557 10.0909 0.558239 8.75568 1.0696 7.39204C1.58097 6.02841 2.25568 4.7429 3.09375 3.53551C3.93182 2.32812 4.84091 1.3196 5.82102 0.509943L9.82671 2.875C9.03125 4.125 8.37784 5.43182 7.86648 6.79545C7.36932 8.15909 7.12074 9.67898 7.12074 11.3551V16H0.302557ZM11.0625 16V11.3977C11.0625 10.0909 11.3182 8.75568 11.8295 7.39204C12.3409 6.02841 13.0156 4.7429 13.8537 3.53551C14.6918 2.32812 15.6009 1.3196 16.581 0.509943L20.5866 2.875C19.7912 4.125 19.1378 5.43182 18.6264 6.79545C18.1293 8.15909 17.8807 9.67898 17.8807 11.3551V16H11.0625Z" fill="currentColor"></path>
    </svg>
  </span>
);

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

const TestimonialCarouselCard = ({ 
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
  <div className="card border border-base-content/10 hover:border-primary transition-colors duration-300 h-full bg-base-100 overflow-hidden">
    <div className="grid grid-cols-1 lg:grid-cols-5 items-center h-full">
      
      {/* Content Section */}
      <div className="lg:col-span-3 p-8 lg:p-10 relative flex flex-col justify-center h-full">
        <QuoteIcon />
        
        <blockquote className="text-base-content/80 text-lg lg:text-xl font-medium text-center lg:text-left mb-8 relative z-0 mt-6 lg:mt-0">
          "{quote}"
        </blockquote>
        
        <div className="text-center lg:text-left">
          <h4 className="text-xl font-bold text-base-content">{name}</h4>
          <p className="text-base-content/80 text-sm mt-1">
            {role} at <span className="font-semibold text-base-content">{company}</span>
          </p>
        </div>
      </div>

      {/* Image Section */}
      <div className="lg:col-span-2 h-64 lg:h-full relative bg-base-200">
        <img 
          src={image} 
          alt={name} 
          className="absolute inset-0 w-full h-full object-cover"
        />
        {/* Gradient Overlay for mobile text readability if needed, or style effect */}
        <div className="absolute inset-0 bg-gradient-to-t from-base-100/50 to-transparent lg:hidden"></div>
      </div>

    </div>
  </div>
);

export default function TestimonialCarousel() {
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

  const nextSlide = () => setActiveSlide((prev) => (prev === testimonials.length - 1 ? 0 : prev + 1));
  const prevSlide = () => setActiveSlide((prev) => (prev === 0 ? testimonials.length - 1 : prev - 1));

  return (
    <section className="bg-base-100 py-16 lg:py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        {/* Header */}
        <div className="mb-16 md:mb-20 flex flex-col items-center text-center space-y-4">
          <span className="text-sm font-bold text-primary tracking-widest uppercase">TESTIMONIALS</span>
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold text-base-content">
            Some of our valuable customers feedback
          </h2>
          <p className="text-xl text-base-content/80 max-w-2xl">
            Predictive analytics, and recommendations to optimize their processes and better business outcomes.
          </p>
          
          {/* 5 Star Rating */}
          <div className="flex gap-1 mt-2">
            {[...Array(5)].map((_, i) => (
              <StarIcon key={i} filled={true} half={i === 4} />
            ))}
          </div>
        </div>

        {/* Carousel Container */}
        <div className="relative w-full max-w-5xl mx-auto">
          
          <div className="overflow-hidden rounded-3xl shadow-lg bg-base-100">
            <div 
              className="flex transition-transform duration-500 ease-in-out" 
              style={{ transform: `translateX(-${activeSlide * 100}%)` }}
            >
              {testimonials.map((testimonial, index) => (
                <div key={index} className="w-full shrink-0">
                   <TestimonialCarouselCard {...testimonial} />
                </div>
              ))}
            </div>
          </div>

          {/* Navigation Buttons (Outside) */}
          <button 
            onClick={prevSlide}
            className="absolute left-0 top-1/2 -translate-y-1/2 -translate-x-4 lg:-translate-x-12 btn btn-circle btn-primary btn-sm lg:btn-md shadow-lg opacity-0 lg:opacity-100 transition-opacity group-hover:opacity-100 z-10"
            aria-label="Previous slide"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M15 6l-6 6l6 6"></path></svg>
          </button>
          <button 
            onClick={nextSlide}
            className="absolute right-0 top-1/2 -translate-y-1/2 translate-x-4 lg:translate-x-12 btn btn-circle btn-primary btn-sm lg:btn-md shadow-lg opacity-0 lg:opacity-100 transition-opacity group-hover:opacity-100 z-10"
            aria-label="Next slide"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M9 6l6 6l-6 6"></path></svg>
          </button>

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

