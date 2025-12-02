import React from 'react';
import Section from '../../components/layout/Section';
import Grid from '../../components/layout/Grid';
import PricingCard from '../../components/blocks/pricing/PricingCard';

// --- Sub-Components ---

const CheckIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-primary size-6 shrink-0">
    <path d="M5 12l5 5l10 -10"></path>
  </svg>
);

// --- Main Section Component ---

export default function PricingSection() {
  return (
    <Section id="pricing-section-wrapper" color="muted" padding="md">
        
      {/* Header */}
      <div id="pricing-header" className="mb-12 flex items-center justify-between gap-6 max-md:flex-wrap sm:mb-16 lg:mb-24">
        <div className="space-y-4">
          <h2 className="text-base-content text-2xl font-semibold md:text-3xl lg:text-4xl">
            Select a Plan That Unlocks the Features You Need
          </h2>
          <p className="text-xl text-base-content/80 w-2/3 mb-6">
            Unlock your website’s potential with a variety of plans that give you the flexibility to choose your design and features.
          </p>

          <nav className="w-fit rounded-field border-base-content/20 overflow-x-auto border p-0.5">
            <button className="btn btn-sm btn-text">Account</button>
            <button className="btn btn-sm btn-text">Billing</button>
            <button className="btn btn-soft btn-primary btn-active btn-sm">Plans</button>
            <button className="btn btn-sm btn-text">References</button>
          </nav>
        </div>

        <div className="shrink-0">
          <div className="flex mb-4 -space-x-5 avatar-group">
              {/* Avatars placeholders */}
              {[1,2,3,4,5].map(i => (
                <div key={i} className="avatar border-2 border-base-100 rounded-full">
                  <div className="w-9 rounded-full">
                    <img src={`https://i.pravatar.cc/150?u=${i}`} alt="Avatar" />
                  </div>
                </div>
              ))}
          </div>
          <div className="mb-0.5 flex items-center gap-3">
            <h5 className="text-xl font-medium">4.5</h5>
            <div className="flex">
                {'★★★★★'.split('').map((s,i) => <span key={i} className="text-warning size-4 shrink-0">★</span>)}
            </div>
          </div>
          <p className="text-sm font-medium text-base-content/70">From 4000+ reviews</p>
        </div>
      </div>

      {/* Pricing Grid */}
      <Grid id="pricing-grid" variant="auto-fit" gap="lg" className="mb-11">
        
        <PricingCard 
          title="Free"
          price="0"
          currency="$"
          frequency="/month"
          description="Ideal For Tracking a Small brand"
          features={["1 User", "Update in every 48h", "AI Sentiments Analysis"]}
          btnText="Get started for free"
        />

        <PricingCard 
          title="Team"
          price="99"
          currency="$"
          frequency="/month"
          description="Ideal for Tracking a Growing Brand"
          features={["2 Users", "Update in every 24h", "Competitive Analysis"]}
          btnText="Purchase Now"
        />

        <PricingCard 
          title="Pro"
          price="399"
          currency="$"
          frequency="/month"
          description="Ideal for Tracking a Large Brand"
          features={["5 Users", "Update in every 12h", "User Satisfaction Survey"]}
          btnText="Purchase Plan"
        />

        <PricingCard 
          title="Custom"
          price="799"
          currency="$"
          frequency="/month"
          description="Ideal for Tracking a Global Brand"
          isPopular={true}
          badgeText="Most Popular"
          btnClass="btn-primary"
          features={["Custom Users", "Sales Growth Forecasts", "Product Usage Analytics"]}
          btnText="Purchase Plan"
        />
      </Grid>

      {/* CTA Bar */}
      <div id="pricing-cta" className="bg-primary/10 rounded-box border-primary mb-11 flex flex-wrap items-center justify-between gap-4 border px-6 py-4">
          <div className="space-y-1.5">
            <h6 className="text-primary text-2xl font-semibold">Compare features by plan</h6>
            <p className="text-base-content/80 text-xl">Easily compare feature across all available plans.</p>
          </div>
          <button className="btn btn-primary gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 4h4l2 5l-2.5 1.5a11 11 0 0 0 5 5l1.5 -2.5l5 2v4a2 2 0 0 1 -2 2a16 16 0 0 1 -15 -15a2 2 0 0 1 2 -2"></path></svg>
            Book a Call
          </button>
      </div>

      {/* Comparison Table */}
      <div id="pricing-table-container" className="overflow-x-auto">
        <table id="pricing-comparison-table" className="table w-full border-base-content/10 border-b">
          <thead>
            <tr className="*:text-xl *:capitalize">
              <th className="pl-0">Feature</th>
              <th>Free</th>
              <th>Team</th>
              <th>Pro</th>
              <th>Custom</th>
            </tr>
          </thead>
          <tbody>
          {/* Users */}
          <tr>
            <td className="pl-0 text-xl">Users</td>
            <td><div className="flex items-center gap-2"><CheckIcon /> 1 User</div></td>
            <td><div className="flex items-center gap-2"><CheckIcon /> 2 Users</div></td>
            <td><div className="flex items-center gap-2"><CheckIcon /> 5 Users</div></td>
            <td className="text-primary font-bold">Customizables</td>
          </tr>
          {/* Update */}
          <tr>
            <td className="pl-0 text-xl">Update</td>
            <td><div className="flex items-center gap-2"><CheckIcon /> 48h</div></td>
            <td><div className="flex items-center gap-2"><CheckIcon /> 24h</div></td>
            <td><div className="flex items-center gap-2"><CheckIcon /> 12h</div></td>
            <td><div className="flex items-center gap-2"><CheckIcon /> 12h</div></td>
          </tr>
            {/* Al Sentiment */}
          <tr>
            <td className="pl-0 text-xl">Al Sentiment</td>
            <td><div className="flex items-center gap-2"><CheckIcon /> Yes</div></td>
            <td><div className="flex items-center gap-2"><CheckIcon /> Yes</div></td>
            <td className="text-primary font-bold">Lifetime</td>
            <td className="text-primary font-bold">Lifetime</td>
          </tr>
            {/* Mentions Volume */}
          <tr>
              <td className="pl-0 text-xl">Mentions Volume</td>
              <td className="text-base-content/50">-</td>
              <td className="text-base-content/50">-</td>
              <td><div className="flex items-center gap-2"><CheckIcon /> Unlimited</div></td>
              <td><div className="flex items-center gap-2"><CheckIcon /> Unlimited</div></td>
          </tr>
          {/* Engagement tracking */}
          <tr>
            <td className="pl-0 text-xl">Engagement tracking</td>
            <td className="text-base-content/50">-</td>
            <td className="text-base-content/50">-</td>
            <td>
              <div className="flex items-center gap-2">
                <CheckIcon />
                <span className="text-base-content">Like , Comment</span>
              </div>
            </td>
            <td>
              <div className="flex items-center gap-2">
                <CheckIcon />
                <span className="text-base-content">Like , Comment</span>
              </div>
            </td>
          </tr>
          {/* Influencer Analysis */}
          <tr>
            <td className="pl-0 text-xl">Influencer Analysis</td>
            <td className="text-base-content/50">-</td>
            <td className="text-base-content/50">-</td>
            <td className="text-base-content/50">-</td>
            <td>
              <div className="flex items-center gap-2">
                <CheckIcon />
                <span className="text-base-content">Yes</span>
              </div>
            </td>
          </tr>
          {/* Presence Score */}
          <tr>
            <td className="pl-0 text-xl">Presence Score</td>
            <td className="text-base-content/50">-</td>
            <td className="text-base-content/50">-</td>
            <td className="text-base-content/50">-</td>
            <td>
              <div className="flex items-center gap-2">
                <CheckIcon />
                <span className="text-base-content">Unlimited Accounts</span>
              </div>
            </td>
          </tr>
          {/* Integrations (Slack) */}
          <tr>
            <td className="pl-0 text-xl">Integrations (Slack)</td>
            <td className="text-base-content/50">-</td>
            <td className="text-base-content/50">-</td>
            <td className="text-base-content/50">-</td>
            <td>
              <div className="flex items-center gap-2">
                <CheckIcon />
                <span className="text-base-content">Yes</span>
              </div>
            </td>
          </tr>
          </tbody>
        </table>
      </div>
    </Section>
  );
}
