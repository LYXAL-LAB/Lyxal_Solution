import React, { useState } from 'react';

// --- Sub-Components ---

const StarIcon = ({ filled = true }: { filled?: boolean }) => (
  <span className={`icon-[tabler--star-filled] text-warning size-6 shrink-0`}>
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="currentColor" className={filled ? "text-warning" : "text-base-content/20"}>
      <path d="M8.243 7.34l-6.38 .925l4.613 4.494l-1.088 6.353l5.651 -2.971l5.651 2.971l-1.088 -6.353l4.613 -4.494l-6.38 -.925l-2.855 -5.783z"></path>
    </svg>
  </span>
);

const TestimonialCard = ({ 
  name, 
  role, 
  image, 
  title,
  quote,
  platform,
  platformIcon 
}: { 
  name: string, 
  role: string, 
  image: string, 
  title: string,
  quote: string,
  platform: string,
  platformIcon: string 
}) => (
  <div className="bg-base-100 rounded-box h-full p-6 flex flex-col gap-6 shadow-sm border border-base-content/5">
    {/* Rating & Platform */}
    <div className="flex items-center justify-between gap-4">
      <div className="flex">
        {[...Array(5)].map((_, i) => (
          <StarIcon key={i} />
        ))}
      </div>
      <div className="flex items-center gap-2">
        <img src={platformIcon} alt={`${platform} Logo`} className="size-5 object-contain" />
        <span className="text-base-content text-sm font-medium">{platform}</span>
      </div>
    </div>

    {/* Content */}
    <div className="space-y-2 flex-1">
      <h3 className="text-base-content font-semibold text-lg">{title}</h3>
      <p className="text-base-content/80 text-sm leading-relaxed">
        {quote}
      </p>
    </div>

    {/* User Info */}
    <div className="flex items-center gap-3 pt-2">
      <div className="avatar">
        <div className="size-10 rounded-full">
          <img src={image} alt={name} />
        </div>
      </div>
      <div>
        <h4 className="text-base-content font-medium text-sm">{name}</h4>
        <p className="text-base-content/80 text-xs">{role}</p>
      </div>
    </div>
  </div>
);

export default function TestimonialSlider() {
  const [activeSlide, setActiveSlide] = useState(0);

  const featuredTestimonials = [
    {
      quote: "Levarage artificial intelligence algorithms to provide users with valuable insights.predictive analytics, and recommendations to optimize their processes and better business outcomes.",
      logo: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/testimonials/logo-1.png",
      alt: "hubstop"
    },
    {
      quote: "Empower business teams to harness cutting-edge technology for exceptional results.predictive solutions, and real-time insights to revolutionize their decision-making process.",
      logo: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/twitter-logo.png",
      alt: "twitter"
    },
    {
      quote: "Transform raw data into powerful business intelligence with smart automation.predictive analysis, and strategic recommendations to drive innovation and market leadership.",
      logo: "https://cdn.flyonui.com/fy-assets/featured/ycombinator.png",
      alt: "ycombinator"
    }
  ];

  // Marquee Cards Data - Duplicated for seamless infinite scroll simulation
  const marqueeCards = [
    {
      title: "Seamless Integration",
      quote: "FlyonUI has made my development process so much easier! The components are intuitive and blend perfectly with Tailwind CSS.",
      name: "Eleanor Pena",
      role: "@BerryB777",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png",
      platform: "G2",
      platformIcon: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/g2-logo.png"
    },
    {
      title: "Incredible Support",
      quote: "The support team behind FlyonUI is fantastic! They helped me with integration issues quickly and efficiently.",
      name: "Darlene Robertson",
      role: "@LatentHQ",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png",
      platform: "Trustpilot",
      platformIcon: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/trustpilot-icon.png"
    },
    {
      title: "Fantastic Component Library",
      quote: "FlyonUI is a fantastic tool for any developer using Tailwind CSS. The components are not only beautiful but also functional!",
      name: "Esther Howard",
      role: "@oxtuggs",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png",
      platform: "Twitter",
      platformIcon: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/twitter-icon.png"
    }
  ];

  return (
    <section className="bg-base-100 relative overflow-hidden pt-16 lg:pt-24">
      
      {/* Background Image & Overlay */}
      <div className="absolute inset-0 bg-[url('https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/team/team-33.png')] bg-cover bg-top bg-no-repeat opacity-30 pointer-events-none"></div>
      
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Top Section: Hero Slider */}
        <div className="mb-16 lg:mb-24 flex flex-col items-start max-w-3xl">
          <h2 className="text-primary text-3xl font-bold md:text-4xl lg:text-5xl mb-9 relative inline-block">
            "Just amazing..."
            <span className="absolute bottom-2 left-0 -z-10 h-3 w-full bg-warning/20 -rotate-1"></span>
          </h2>

          {/* Main Testimonial Slider */}
          <div className="relative w-full">
            <div className="overflow-hidden relative min-h-[200px]">
              {featuredTestimonials.map((item, index) => (
                <div 
                  key={index}
                  className={`transition-opacity duration-500 absolute inset-0 ${index === activeSlide ? 'opacity-100 z-10' : 'opacity-0 z-0'}`}
                >
                  <p className="text-base-content/80 text-xl md:text-2xl font-medium leading-relaxed w-3/4 mb-8">
                    {item.quote}
                  </p>
                  <img src={item.logo} alt={item.alt} className="h-8 w-auto object-contain" />
                </div>
              ))}
            </div>

            {/* Navigation Buttons */}
            <div className="flex gap-4 mt-8">
              <button 
                onClick={() => setActiveSlide((prev) => (prev === 0 ? featuredTestimonials.length - 1 : prev - 1))}
                className="btn btn-circle btn-soft btn-primary hover:btn-primary"
                aria-label="Previous slide"
              >
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12l14 0"></path><path d="M5 12l6 6"></path><path d="M5 12l6 -6"></path></svg>
              </button>
              <button 
                onClick={() => setActiveSlide((prev) => (prev === featuredTestimonials.length - 1 ? 0 : prev + 1))}
                className="btn btn-circle btn-soft btn-primary hover:btn-primary"
                aria-label="Next slide"
              >
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12l14 0"></path><path d="M13 18l6 -6"></path><path d="M13 6l6 6"></path></svg>
              </button>
            </div>
          </div>
        </div>

        {/* Bottom Section: Infinite Marquee Grid (Simulated) */}
        <div className="relative w-full h-[25rem] overflow-hidden mask-image-gradient-to-b">
          {/* Gradient Overlay Top */}
          <div className="absolute top-0 left-0 right-0 h-24 bg-gradient-to-b from-base-100 to-transparent z-20"></div>
          
          {/* Marquee Column 1 (Up) */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 absolute w-full">
            <div className="flex flex-col gap-6 animate-marqueeTop">
              {[...marqueeCards, ...marqueeCards].map((card, idx) => (
                <TestimonialCard key={`col1-${idx}`} {...card} />
              ))}
            </div>
            
            {/* Marquee Column 2 (Down - slower) */}
            <div className="flex flex-col gap-6 animate-marqueeBottom hidden sm:flex">
              {[...marqueeCards, ...marqueeCards].reverse().map((card, idx) => (
                <TestimonialCard key={`col2-${idx}`} {...card} />
              ))}
            </div>

             {/* Marquee Column 3 (Up) */}
             <div className="flex flex-col gap-6 animate-marqueeTop hidden lg:flex">
              {[...marqueeCards, ...marqueeCards].map((card, idx) => (
                <TestimonialCard key={`col3-${idx}`} {...card} />
              ))}
            </div>

             {/* Marquee Column 4 (Down) */}
             <div className="flex flex-col gap-6 animate-marqueeBottom hidden lg:flex">
              {[...marqueeCards, ...marqueeCards].reverse().map((card, idx) => (
                <TestimonialCard key={`col4-${idx}`} {...card} />
              ))}
            </div>
          </div>

          {/* Gradient Overlay Bottom */}
          <div className="absolute bottom-0 left-0 right-0 h-24 bg-gradient-to-t from-base-100 to-transparent z-20"></div>
        </div>

      </div>
    </section>
  );
}
