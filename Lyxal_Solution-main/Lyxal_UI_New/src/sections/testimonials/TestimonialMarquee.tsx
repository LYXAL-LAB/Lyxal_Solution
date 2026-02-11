import React from 'react';

// --- Sub-Components ---

const StarIcon = ({ filled = true, half = false }: { filled?: boolean, half?: boolean }) => {
  if (half) {
    return (
      <span className="icon-[tabler--star-half-filled] text-warning size-6 shrink-0 rtl:rotate-y-180">
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
  image, 
  title,
  quote,
  platform,
  platformIcon,
  rating = 5
}: { 
  name: string, 
  role: string, 
  image: string, 
  title: string,
  quote: string,
  platform: string,
  platformIcon: string,
  rating?: number
}) => (
  <div className="bg-base-100 rounded-box p-6 h-full flex flex-col gap-6 shadow-sm hover:shadow-lg transition-shadow border border-base-content/5">
    {/* Rating & Platform */}
    <div className="flex items-center justify-between gap-4">
      <div className="flex gap-0.5">
        {[...Array(5)].map((_, i) => (
          <StarIcon key={i} filled={i < Math.floor(rating)} half={i === Math.floor(rating) && rating % 1 !== 0} />
        ))}
      </div>
      <div className="flex items-center gap-1.5">
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
    <div className="flex items-center gap-3">
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

export default function TestimonialMarquee() {
  // Column 1 Data
  const col1 = [
    {
      title: "Seamless Integration",
      quote: "FlyonUI has made my development process so much easier! The components are intuitive and blend perfectly with Tailwind CSS.",
      name: "Eleanor Pena",
      role: "@BerryB777",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png",
      platform: "G2",
      platformIcon: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/g2-logo.png",
      rating: 5
    },
    {
      title: "Incredible Support",
      quote: "The support team behind FlyonUI is fantastic! They helped me with integration issues quickly and efficiently, ensuring a smooth development process.",
      name: "Darlene Robertson",
      role: "@LatentHQ",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png",
      platform: "Trustpilot",
      platformIcon: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/trustpilot-icon.png",
      rating: 5
    },
    {
      title: "Fantastic Component Library",
      quote: "FlyonUI is a fantastic tool for any developer using Tailwind CSS. The components are not only beautiful but also functional!",
      name: "Esther Howard",
      role: "@oxtuggs",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png",
      platform: "Twitter",
      platformIcon: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/twitter-icon.png",
      rating: 4.5
    }
  ];

  // Column 2 Data (Different set)
  const col2 = [
    {
      title: "Game Changer for Developers",
      quote: "Using FlyonUI has transformed the way I build applications. The ease of use and flexibility is unmatched!",
      name: "Floyd Miles",
      role: "@Athar",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png",
      platform: "Twitter",
      platformIcon: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/twitter-icon.png",
      rating: 4.5
    },
    {
      title: "Perfect for Rapid Development",
      quote: "FlyonUI has significantly sped up my development process. The pre-built components are perfect for rapid prototyping!",
      name: "Brad Hanna",
      role: "@Marko",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png",
      platform: "Twitter",
      platformIcon: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/twitter-icon.png",
      rating: 5
    },
    {
      title: "Effortless Design",
      quote: "FlyonUI has made designing my web applications effortless. The components are easy to customize and integrate seamlessly!",
      name: "Cody Fisher",
      role: "@BerryB777",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png",
      platform: "G2",
      platformIcon: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/g2-logo.png",
      rating: 5
    }
  ];

   // Column 3 Data (Different set)
   const col3 = [
    {
      title: "Highly Recommended",
      quote: "The attention to detail in FlyonUI's components is impressive. It saves me so much time and effort in my projects!",
      name: "Theresa Webb",
      role: "@inverse_hq",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png",
      platform: "Trustpilot",
      platformIcon: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/trustpilot-icon.png",
      rating: 5
    },
    {
      title: "Exceptional User Experience",
      quote: "FlyonUI has truly elevated my projects! The components are not only easy to use but also enhance the overall user experience.",
      name: "Dianne Russell",
      role: "@mukherjee",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png",
      platform: "Trustpilot",
      platformIcon: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/trustpilot-icon.png",
      rating: 5
    },
    {
      title: "A Must-Have for Tailwind Users",
      quote: "FlyonUI is a must-have for anyone working with Tailwind CSS. The library is well-organized, incredibly user-friendly.",
      name: "Kathryn Murphy",
      role: "@stap",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-15.png",
      platform: "Twitter",
      platformIcon: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/twitter-icon.png",
      rating: 4.5
    }
  ];

  return (
    <section className="bg-base-100 relative overflow-hidden py-16 lg:py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Header */}
        <div className="mb-16 flex flex-col items-center text-center space-y-4">
          <span className="text-sm font-bold text-primary tracking-widest uppercase">TESTIMONIALS</span>
          <h2 className="text-base-content text-3xl font-semibold md:text-4xl">
            What our customers say
          </h2>
          <p className="text-base-content/80 text-xl max-w-2xl">
            Don't just take our word for it. Check out what our customers have to say about their experience with us.
          </p>
        </div>

        {/* Marquee Grid */}
        <div className="relative h-[800px] overflow-hidden mask-image-gradient-to-b">
          {/* Gradient Overlay Top */}
          <div className="absolute top-0 left-0 right-0 h-24 bg-gradient-to-b from-base-100 to-transparent z-20"></div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            
            {/* Column 1 (Up) */}
            <div className="flex flex-col gap-6 animate-marqueeTop">
              {[...col1, ...col1].map((card, idx) => (
                <TestimonialCard key={`col1-${idx}`} {...card} />
              ))}
            </div>

            {/* Column 2 (Down) */}
            <div className="flex flex-col gap-6 animate-marqueeBottom hidden md:flex pt-12">
              {[...col2, ...col2].map((card, idx) => (
                <TestimonialCard key={`col2-${idx}`} {...card} />
              ))}
            </div>

            {/* Column 3 (Up) */}
            <div className="flex flex-col gap-6 animate-marqueeTop hidden lg:flex">
              {[...col3, ...col3].map((card, idx) => (
                <TestimonialCard key={`col3-${idx}`} {...card} />
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

