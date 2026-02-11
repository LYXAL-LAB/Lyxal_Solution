import React from 'react';

// --- Sub-Components ---

// Mapped SVG for the large stat card icon
const ChartIcon = () => (
  <svg width="21" height="16" viewBox="0 0 21 16" fill="currentColor" className="shrink-0">
    <path d="M0.302557 16V11.3977C0.302557 10.0909 0.558239 8.75568 1.0696 7.39204C1.58097 6.02841 2.25568 4.7429 3.09375 3.53551C3.93182 2.32812 4.84091 1.3196 5.82102 0.509943L9.82671 2.875C9.03125 4.125 8.37784 5.43182 7.86648 6.79545C7.36932 8.15909 7.12074 9.67898 7.12074 11.3551V16H0.302557ZM11.0625 16V11.3977C11.0625 10.0909 11.3182 8.75568 11.8295 7.39204C12.3409 6.02841 13.0156 4.7429 13.8537 3.53551C14.6918 2.32812 15.6009 1.3196 16.581 0.509943L20.5866 2.875C19.7912 4.125 19.1378 5.43182 18.6264 6.79545C18.1293 8.15909 17.8807 9.67898 17.8807 11.3551V16H11.0625Z" />
  </svg>
);

const LargeStatCard = ({ 
  stat, 
  label, 
  quote, 
  name, 
  role, 
  avatar, 
  logo,
  logoAlt 
}: { 
  stat: string, 
  label: string, 
  quote: string, 
  name: string, 
  role: string, 
  avatar: string, 
  logo: string,
  logoAlt: string
}) => (
  <div className="bg-base-100 rounded-3xl p-8 shadow-lg h-full flex flex-col justify-between gap-8 border border-base-content/5">
    <div className="space-y-6">
      <div>
        <div className="text-6xl font-bold text-base-content mb-2">{stat}</div>
        <p className="text-base-content/80 font-medium text-lg">{label}</p>
      </div>
      
      <div className="text-primary">
        <ChartIcon />
      </div>

      <p className="text-base-content/80 text-lg leading-relaxed">
        {quote}
      </p>
    </div>

    <div className="flex items-center justify-between pt-4 border-t border-base-content/10">
      <div className="flex items-center gap-3">
        <div className="avatar">
          <div className="size-12 rounded-full">
            <img src={avatar} alt={name} />
          </div>
        </div>
        <div>
          <h4 className="text-base-content font-medium">{name}</h4>
          <p className="text-base-content/80 text-sm">{role}</p>
        </div>
      </div>
      <div className="avatar">
        <div className="w-8 h-8 rounded-full opacity-80">
          <img src={logo} alt={logoAlt} className="grayscale hover:grayscale-0 transition-all" />
        </div>
      </div>
    </div>
  </div>
);

const SmallStatCard = ({ 
  stat, 
  label, 
  quote, 
  name, 
  role, 
  avatar, 
  logo,
  logoAlt 
}: { 
  stat: string, 
  label: string, 
  quote: string, 
  name: string, 
  role: string, 
  avatar: string, 
  logo: string,
  logoAlt: string
}) => (
  <div className="bg-base-100 rounded-3xl p-8 shadow-lg border border-base-content/5">
    <div className="mb-8">
      <div className="text-3xl font-bold text-base-content mb-1">{stat}</div>
      <p className="text-base-content/80 font-medium">{label}</p>
    </div>

    <div className="flex items-center justify-between mb-6">
      <div className="flex items-center gap-3">
        <div className="avatar">
          <div className="size-10 rounded-full">
            <img src={avatar} alt={name} />
          </div>
        </div>
        <div>
          <h4 className="text-base-content font-medium text-sm">{name}</h4>
          <p className="text-base-content/80 text-xs">{role}</p>
        </div>
      </div>
      <div className="avatar">
        <div className="w-6 h-6 rounded-full opacity-80">
          <img src={logo} alt={logoAlt} className="grayscale hover:grayscale-0 transition-all" />
        </div>
      </div>
    </div>

    <div className="text-primary mb-3">
      <ChartIcon />
    </div>
    <p className="text-base-content/80 text-sm leading-relaxed">
      {quote}
    </p>
  </div>
);

const SmallQuoteCard = ({ 
  quote, 
  name, 
  role, 
  avatar 
}: { 
  quote: string, 
  name: string, 
  role: string, 
  avatar: string 
}) => (
  <div className="bg-base-100 rounded-3xl p-8 shadow-lg border border-base-content/5 flex flex-col justify-between">
    <div>
      <div className="text-primary mb-4">
        <ChartIcon />
      </div>
      <p className="text-base-content/80 text-lg leading-relaxed mb-8">
        {quote}
      </p>
    </div>

    <div className="flex items-center gap-3">
      <div className="avatar">
        <div className="size-10 rounded-full">
          <img src={avatar} alt={name} />
        </div>
      </div>
      <div>
        <h4 className="text-base-content font-medium text-sm">{name}</h4>
        <p className="text-base-content/80 text-xs">{role}</p>
      </div>
    </div>
  </div>
);

export default function TestimonialStats() {
  return (
    <section className="relative bg-base-200 py-16 lg:py-24 overflow-hidden">
      {/* Background Pattern (Optional) */}
      <div className="absolute inset-0 bg-[url('https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/testimonials/gradient-bg.png')] bg-cover bg-center opacity-30 pointer-events-none"></div>

      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Header */}
        <div className="mb-16 lg:mb-24 flex flex-col items-center text-center space-y-4">
          <h2 className="text-base-content text-3xl font-semibold md:text-3xl lg:text-4xl relative inline-block">
            Results that speaks Real <span className="text-primary">stories</span>
            {/* Underline Decoration */}
            <span className="absolute bottom-1 left-0 -z-10 h-3 w-full bg-warning/20 -rotate-1"></span>
          </h2>
          <p className="text-base-content/80 text-xl max-w-2xl">
            Find out how our happy clients are raving about us.
          </p>
          <button className="btn btn-primary btn-soft mt-4">View All Reviews</button>
        </div>

        {/* Grid Layout */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 lg:gap-8">
          
          {/* Left Column - Large Stat Card */}
          <div>
            <LargeStatCard 
              stat="8x"
              label="Increase in Conversion Rate"
              quote="hours that were previously spent on repetitive design adjustments. The ability to easily tailor each component to meet our specific project needs has not only enhanced our creativity but also fostered greater collaboration among team members. Additionally, the user-friendly nature of Clarify has significantly reduced onboarding time for new designers."
              name="Anika Franci"
              role="CEO at Spotify"
              avatar="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png"
              logo="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/spotify-icon.png"
              logoAlt="Spotify"
            />
          </div>

          {/* Right Column - Grid of Smaller Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            
            {/* 2x Stat Card - Spanning 2 columns on MD */}
            <div className="md:col-span-2">
              <SmallStatCard 
                stat="2x"
                label="Increase in Conversion Rate"
                quote="hours that were previously spent on repetitive design adjustments. The ability to easily tailor each component to meet our specific project needs has not only enhanced our creativity but also fostered greater collaboration among team"
                name="Anika Franci"
                role="CEO & Co Founder at Google"
                avatar="https://cdn.flyonui.com/fy-assets/avatar/avatar-14.png"
                logo="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/google-icon.png"
                logoAlt="Google"
              />
            </div>

            {/* Bottom Quote Card 1 */}
            <SmallQuoteCard 
              quote="This product is amazing—super high quality and easy to use!"
              name="Anika Franci"
              role="CEO & Co Founder at Zendesk"
              avatar="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png"
            />

            {/* Bottom Quote Card 2 */}
            <SmallQuoteCard 
              quote="This product is amazing—super high quality and easy to use!"
              name="Anika Franci"
              role="CEO & Co Founder at Zendesk"
              avatar="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png"
            />

          </div>

        </div>

      </div>
    </section>
  );
}

