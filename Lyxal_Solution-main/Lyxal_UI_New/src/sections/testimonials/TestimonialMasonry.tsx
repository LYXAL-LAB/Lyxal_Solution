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

const TestimonialCardMasonry = ({ 
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
  <div className="bg-base-100 rounded-box hover:shadow-xl transition-shadow duration-300 p-6 border border-base-content/10 h-full flex flex-col gap-6">
    {/* Rating & Platform */}
    <div className="flex items-center justify-between gap-3">
      <div className="flex gap-1">
        {[...Array(5)].map((_, i) => (
          <StarIcon key={i} filled={i < Math.floor(rating)} half={i === Math.floor(rating) && rating % 1 !== 0} />
        ))}
      </div>
      <div className="flex items-center gap-1.5 justify-end">
        <img src={platformIcon} alt={`${platform} Logo`} className="size-5.5" />
        <span className="text-base-content text-sm font-medium">{platform}</span>
      </div>
    </div>

    {/* Content */}
    <div className="space-y-2 flex-1">
      <h3 className="text-base-content font-semibold text-lg">{title}</h3>
      <p className="text-base-content/80">
        {quote}
      </p>
    </div>

    {/* User Info */}
    <div className="flex items-center gap-3">
      <div className="avatar">
        <div className="size-12 rounded-full">
          <img src={image} alt={name} />
        </div>
      </div>
      <div>
        <h4 className="text-base-content font-medium">{name}</h4>
        <p className="text-base-content/80 text-sm">{role}</p>
      </div>
    </div>
  </div>
);

export default function TestimonialMasonry() {
  // Mock Data
  const reviews = [
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
    },
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
      rating: 4.5
    },
    {
      title: "Effortless Design",
      quote: "FlyonUI has made designing my web applications effortless. The components are easy to customize and integrate seamlessly!",
      name: "Cody Fisher",
      role: "@BerryB777",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png",
      platform: "G2",
      platformIcon: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/g2-logo.png",
      rating: 5
    },
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
      quote: "FlyonUI has truly elevated my projects! The components are not only easy to use but also enhance the overall user experience. Highly recommend for any Tailwind CSS developer!",
      name: "Dianne Russell",
      role: "@mukherjee",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png",
      platform: "Trustpilot",
      platformIcon: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/trustpilot-icon.png",
      rating: 5
    },
    {
      title: "A Must-Have for Tailwind Users",
      quote: "FlyonUI is a must-have for anyone working with Tailwind CSS. The library is well-organized, incredibly user-friendly, and offers outstanding flexibility for customization!",
      name: "Kathryn Murphy",
      role: "@stap",
      image: "https://cdn.flyonui.com/fy-assets/avatar/avatar-15.png",
      platform: "Twitter",
      platformIcon: "https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/twitter-icon.png",
      rating: 4.5
    }
  ];

  return (
    <section className="bg-base-200 py-8 sm:py-16 lg:py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        {/* Header */}
        <div className="mb-16 md:mb-24 flex flex-col items-center text-center space-y-4">
          <h2 className="text-base-content text-3xl font-semibold md:text-3xl lg:text-4xl relative inline-block z-10">
            The Wall of Love
            {/* Underline Gradient */}
            <span className="absolute bottom-0 left-0 -z-10 h-3 w-full bg-gradient-to-r from-primary to-transparent opacity-30 blur-sm" aria-hidden="true"></span>
          </h2>
          <p className="text-base-content/80 text-xl max-w-2xl">
            Insights from those who’ve experienced FlyonUI.
          </p>
        </div>

        {/* Masonry Grid */}
        <div className="columns-1 md:columns-2 lg:columns-3 gap-6 space-y-6">
          {reviews.map((review, index) => (
            <div key={index} className="break-inside-avoid">
              <TestimonialCardMasonry {...review} />
            </div>
          ))}
        </div>

        {/* View All Button */}
        <div className="flex justify-center mt-12">
          <button className="btn btn-primary btn-lg gap-2 shadow-lg shadow-primary/20">
            View All Reviews
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 6h-6a2 2 0 0 0 -2 2v10a2 2 0 0 0 2 2h10a2 2 0 0 0 2 -2v-6"></path><path d="M11 13l9 -9"></path><path d="M15 4h5v5"></path></svg>
          </button>
        </div>

      </div>
    </section>
  );
}

