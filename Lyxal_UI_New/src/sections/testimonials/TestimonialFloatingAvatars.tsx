import React from 'react';

// --- Sub-Components ---

const StarIcon = ({ filled = true, half = false }: { filled?: boolean, half?: boolean }) => {
  if (half) {
    return (
      <span className="icon-[tabler--star-half-filled] text-warning size-5 shrink-0 rtl:rotate-y-180">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M8.243 7.34l-6.38 .925l4.613 4.494l-1.088 6.353l5.651 -2.971l5.651 2.971l-1.088 -6.353l4.613 -4.494l-6.38 -.925l-2.855 -5.783z"></path>
        </svg>
      </span>
    );
  }
  return (
    <span className="icon-[tabler--star-filled] text-warning size-5 shrink-0">
      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor" className={filled ? "text-warning" : "text-base-content/20"}>
        <path d="M8.243 7.34l-6.38 .925l4.613 4.494l-1.088 6.353l5.651 -2.971l5.651 2.971l-1.088 -6.353l4.613 -4.494l-6.38 -.925l-2.855 -5.783z"></path>
      </svg>
    </span>
  );
};

// Wave Connecting Line SVG
const ConnectingWaves = () => (
  <svg className="absolute top-0 left-1/2 -translate-x-1/2 w-full max-w-4xl h-64 opacity-30 hidden lg:block pointer-events-none" viewBox="0 0 910 256" fill="none">
    <path d="M0.5 128C50.5 128 100.5 50 150.5 50C200.5 50 250.5 206 300.5 206C350.5 206 400.5 50 450.5 50C500.5 50 550.5 206 600.5 206C650.5 206 700.5 50 750.5 50C800.5 50 850.5 128 909.5 128" stroke="url(#paint0_linear)" strokeWidth="1.5" strokeDasharray="4 4"/>
    <defs>
      <linearGradient id="paint0_linear" x1="0.5" y1="128" x2="909.5" y2="128" gradientUnits="userSpaceOnUse">
        <stop stopColor="currentColor" stopOpacity="0"/>
        <stop offset="0.5" stopColor="currentColor"/>
        <stop offset="1" stopColor="currentColor" stopOpacity="0"/>
      </linearGradient>
    </defs>
  </svg>
);

const FloatingAvatar = ({ 
  src, 
  alt, 
  className 
}: { 
  src: string, 
  alt: string, 
  className: string 
}) => (
  <div className={`absolute transform transition-transform hover:scale-110 duration-300 ${className}`}>
    <div className="avatar">
      <div className="size-12 rounded-full ring-4 ring-base-100 ring-offset-2 ring-offset-base-content/5 shadow-lg">
        <img src={src} alt={alt} />
      </div>
    </div>
  </div>
);

const TestimonialCard = ({
  name,
  role,
  company,
  image,
  quote,
  rating = 5
}: {
  name: string,
  role: string,
  company: string,
  image: string,
  quote: string,
  rating?: number
}) => (
  <div className="card bg-base-100 shadow-xl border border-base-content/5 h-full hover:bg-base-200/50 transition-colors duration-300">
    <div className="card-body p-6 gap-4">
      {/* Rating */}
      <div className="flex gap-1">
        {[...Array(5)].map((_, i) => (
          <StarIcon key={i} filled={i < Math.floor(rating)} half={i === Math.floor(rating) && rating % 1 !== 0} />
        ))}
      </div>
      
      {/* Content */}
      <p className="text-base-content/80 text-sm leading-relaxed">
        {quote}
      </p>

      {/* User Info */}
      <div className="flex items-center gap-3 mt-2">
        <div className="avatar">
          <div className="size-10 rounded-full">
            <img src={image} alt={name} />
          </div>
        </div>
        <div>
          <h4 className="text-base-content font-semibold text-sm">{name}</h4>
          <p className="text-xs text-base-content/60">
            {role} at <span className="font-medium text-base-content">{company}</span>
          </p>
        </div>
      </div>
    </div>
  </div>
);

export default function TestimonialFloatingAvatars() {
  const avatars = [
    { src: "https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png", className: "top-[50%] left-[8%] -translate-y-1/2" },
    { src: "https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png", className: "top-[10%] left-[18%] animate-bounce duration-[3000ms]" },
    { src: "https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png", className: "top-[50%] left-[28%] -translate-y-1/2 animate-bounce duration-[4000ms]" },
    { src: "https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png", className: "top-[10%] left-[45%]" },
    { src: "https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png", className: "bottom-0 left-[40%]" },
    { src: "https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png", className: "bottom-0 left-[60%]" },
    { src: "https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png", className: "top-[37%] left-[66%] animate-bounce duration-[3500ms]" },
    { src: "https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png", className: "top-[5%] left-[80%]" },
    { src: "https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png", className: "top-[60%] left-[88%] animate-bounce duration-[4500ms]" }
  ];

  const testimonials = [
    {
      name: "Craig Bator",
      role: "CEO & Co Founder",
      company: "Zendesk",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-17.png",
      quote: "FlyonUI has made designing my web applications effortless. The components are easy to customize and integrate seamlessly!",
      rating: 5
    },
    {
      name: "Martin Dorwart",
      role: "Product manager",
      company: "Orbit",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png",
      quote: "With FlyonUI, I can easily track my investments and see how they're performing in real-time.",
      rating: 4.5
    },
    {
      name: "Alexandra Lee",
      role: "Lead Developer",
      company: "TechNova",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png",
      quote: "FlyonUI's components saved us so much time! The responsive designs and intuitive interface made our development process faster.",
      rating: 5
    }
  ];

  return (
    <section className="relative overflow-hidden bg-base-100 lg:py-24 py-16">
      {/* Background Gradient */}
      <div className="absolute inset-0 -z-10 bg-[url('https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/testimonials/gradient-bg.png')] bg-contain bg-top bg-no-repeat opacity-50"></div>

      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 relative">
        
        {/* Header */}
        <div className="text-center max-w-3xl mx-auto mb-20 relative z-10">
          <span className="text-sm font-bold text-primary tracking-widest uppercase mb-2 block">REAL CUSTOMERS</span>
          <h2 className="text-4xl md:text-5xl font-bold text-base-content mb-6">
            Helping thousands of students <br/>
            <span className="relative inline-block text-primary">
              to succeed with speed
              {/* Underline */}
              <span className="absolute bottom-1 left-0 -z-10 h-3 w-full bg-warning/20 -rotate-1"></span>
            </span>
          </h2>
          <p className="text-xl text-base-content/80 mb-8">
            Find out how our happy clients are raving about us.
          </p>
          <button className="btn btn-primary shadow-lg shadow-primary/20 rounded-full px-8">View All Reviews</button>
        </div>

        {/* Floating Avatars Visualization (Desktop Only) */}
        <div className="relative h-64 w-full mb-12 hidden lg:block text-base-content/20">
          <ConnectingWaves />
          {avatars.map((avatar, index) => (
            <FloatingAvatar key={index} {...avatar} />
          ))}
        </div>

        {/* Testimonial Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 relative z-10">
          {testimonials.map((testimonial, index) => (
            <TestimonialCard key={index} {...testimonial} />
          ))}
        </div>

        {/* Carousel Indicators (Visual Only) */}
        <div className="flex justify-center gap-2 mt-12">
          <button className="w-3 h-3 rounded-full bg-primary/20 hover:bg-primary transition-colors"></button>
          <button className="w-3 h-3 rounded-full bg-primary"></button>
          <button className="w-3 h-3 rounded-full bg-primary/20 hover:bg-primary transition-colors"></button>
        </div>

      </div>
    </section>
  );
}
