import React from 'react';

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
    <span className={`icon-[tabler--star-filled] text-warning size-6 shrink-0`}>
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
  rating = 5, 
  quote 
}: { 
  name: string, 
  role: string, 
  company: string, 
  image: string, 
  rating?: number, 
  quote: string 
}) => (
  <div className="card border border-base-content/10 hover:border-primary transition-colors duration-300 h-full shadow-none bg-base-100">
    <div className="card-body gap-5 p-6">
      {/* User Info */}
      <div className="flex items-center gap-3">
        <div className="avatar">
          <div className="size-10 rounded-full">
            <img src={image} alt={name} />
          </div>
        </div>
        <div>
          <h4 className="text-base-content font-medium">{name}</h4>
          <p className="text-base-content/80 text-sm">
            {role} at <span className="text-base-content font-semibold">{company}</span>
          </p>
        </div>
      </div>

      {/* Rating */}
      <div className="flex gap-1">
        {[...Array(5)].map((_, i) => (
          <StarIcon key={i} filled={i < Math.floor(rating)} half={i === Math.floor(rating) && rating % 1 !== 0} />
        ))}
      </div>

      {/* Content */}
      <p className="text-base-content/80">
        {quote}
      </p>
    </div>
  </div>
);

export default function TestimonialsGrid() {
  // Static data for the grid (simulating the carousel content)
  const testimonials = [
    {
      name: "Craig Bator",
      role: "CEO & Co Founder",
      company: "Zendesk",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-17.png",
      rating: 5,
      quote: "FlyonUI has made designing my web applications effortless. The components are easy to customize and integrate seamlessly!"
    },
    {
      name: "Martin Dorwart",
      role: "Product manager",
      company: "Orbit",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png",
      rating: 4.5,
      quote: "With FlyonUI, I can easily track my investments and see how they're performing in real-time."
    },
    {
      name: "Alexandra Lee",
      role: "Lead Developer",
      company: "TechNova",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png",
      rating: 5,
      quote: "FlyonUI's components saved us so much time! The responsive designs and intuitive interface made our development process faster and more efficient."
    },
    {
      name: "Jason Wu",
      role: "Product Designer",
      company: "InnovateX",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png",
      rating: 5,
      quote: "FlyonUI’s design library helped us scale our UI design efforts while maintaining a consistent, professional look. Couldn’t have asked for a better tool!"
    }
  ];

  return (
    <section className="bg-base-100 py-8 sm:py-16 lg:py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        <div className="flex flex-col lg:flex-row gap-12 lg:gap-24 lg:items-center">
          
          {/* Left Content */}
          <div className="lg:w-1/3 space-y-8">
            <div className="space-y-4">
              <p className="text-primary text-sm font-medium uppercase tracking-wider">Real Customers</p>
              <h2 className="text-base-content text-3xl font-semibold md:text-4xl">Customers Feedback</h2>
              <p className="text-base-content/80 text-xl">From career changes to dream jobs, here's how FlyonUI helped.</p>
            </div>

            <div className="flex gap-4">
              <button className="btn btn-square btn-primary btn-outline rounded-lg hover:text-white">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12l14 0"></path><path d="M5 12l6 6"></path><path d="M5 12l6 -6"></path></svg>
              </button>
              <button className="btn btn-square btn-primary rounded-lg text-white">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12l14 0"></path><path d="M13 18l6 -6"></path><path d="M13 6l6 6"></path></svg>
              </button>
            </div>
          </div>

          {/* Right Grid (Carousel Simulation) */}
          <div className="lg:w-2/3">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {testimonials.slice(0, 2).map((t, i) => (
                <TestimonialCard key={i} {...t} />
              ))}
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}

