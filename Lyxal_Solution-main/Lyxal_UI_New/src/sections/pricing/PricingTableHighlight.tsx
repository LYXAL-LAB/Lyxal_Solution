import React from 'react';

// --- Sub-Components ---

const CheckIcon = () => (
  <div className="flex justify-center">
    <span className="icon-[tabler--circle-check] size-6 shrink-0 text-success">
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0"></path>
        <path d="M9 12l2 2l4 -4"></path>
      </svg>
    </span>
  </div>
);

const DashIcon = () => (
  <div className="text-base-content/50 text-center">-</div>
);

export default function PricingTableHighlight() {
  return (
    <section className="bg-base-100 py-8 sm:py-16 lg:py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        {/* Header */}
        <div className="mb-16 md:space-y-6 flex flex-col items-center text-center">
          <h2 className="text-base-content text-3xl font-semibold md:text-3xl lg:text-4xl">
            Choose your right plan!
          </h2>
          <p className="text-base-content/80 text-xl max-w-2xl">
            Explore Our Plans and Choose the One That Best Fits Your Needs and Budget !
          </p>
        </div>

        {/* Pricing Table */}
        <div className="overflow-x-auto border border-base-content/10 rounded-3xl shadow-sm">
          <table className="w-full min-w-[800px]">
            
            {/* Header Row */}
            <thead>
              <tr>
                <th className="p-6 text-left w-1/4"></th>
                
                <th className="p-6 text-center border-b border-base-content/10">
                  <div className="text-primary text-xl font-bold mb-2">Basic</div>
                  <div className="text-3xl font-bold text-base-content mb-1">$149</div>
                  <div className="text-base-content/50 text-sm font-normal">Per month</div>
                </th>
                
                <th className="p-6 text-center border-b border-base-content/10">
                  <div className="text-primary text-xl font-bold mb-2">Standard</div>
                  <div className="text-3xl font-bold text-base-content mb-1">$149</div>
                  <div className="text-base-content/50 text-sm font-normal">Per month</div>
                </th>
                
                <th className="bg-primary text-primary-content p-6 text-center rounded-t-2xl relative overflow-hidden">
                  <div className="text-xl font-bold mb-2">Popular</div>
                  <div className="text-3xl font-bold mb-1">$249</div>
                  <div className="text-primary-content/80 text-sm font-normal">Per month</div>
                </th>
                
                <th className="p-6 text-center border-b border-base-content/10">
                  <div className="text-primary text-xl font-bold mb-2">Premium</div>
                  <div className="text-3xl font-bold text-base-content mb-1">$249</div>
                  <div className="text-base-content/50 text-sm font-normal">Per month</div>
                </th>
              </tr>
            </thead>

            <tbody className="text-base-content text-sm lg:text-base font-medium">
              
              {/* Website number */}
              <tr className="border-b border-base-content/10 hover:bg-base-200/50 transition-colors">
                <td className="p-6 font-semibold">Website number</td>
                <td className="p-6 text-center">10</td>
                <td className="p-6 text-center">50</td>
                <td className="p-6 text-center bg-primary/10 text-primary font-bold">Unlimited</td>
                <td className="p-6 text-center">Unlimited</td>
              </tr>

              {/* Premium Support */}
              <tr className="border-b border-base-content/10 hover:bg-base-200/50 transition-colors">
                <td className="p-6 font-semibold">Premium Support</td>
                <td className="p-6 text-center">12 Months</td>
                <td className="p-6 text-center">12 Months</td>
                <td className="p-6 text-center bg-primary/10 text-primary font-bold">Lifetime</td>
                <td className="p-6 text-center">Lifetime</td>
              </tr>

              {/* Database */}
              <tr className="border-b border-base-content/10 hover:bg-base-200/50 transition-colors">
                <td className="p-6 font-semibold">Database</td>
                <td className="p-6"><CheckIcon /></td>
                <td className="p-6"><CheckIcon /></td>
                <td className="p-6 bg-primary/10"><CheckIcon /></td>
                <td className="p-6"><CheckIcon /></td>
              </tr>

              {/* Unmetered Bandwidth */}
              <tr className="border-b border-base-content/10 hover:bg-base-200/50 transition-colors">
                <td className="p-6 font-semibold">Unmetered Bandwidth</td>
                <td className="p-6"><CheckIcon /></td>
                <td className="p-6"><CheckIcon /></td>
                <td className="p-6 bg-primary/10"><CheckIcon /></td>
                <td className="p-6"><CheckIcon /></td>
              </tr>

              {/* SSD disk */}
              <tr className="border-b border-base-content/10 hover:bg-base-200/50 transition-colors">
                <td className="p-6 font-semibold">SSD disk</td>
                <td className="p-6"><CheckIcon /></td>
                <td className="p-6"><CheckIcon /></td>
                <td className="p-6 bg-primary/10"><CheckIcon /></td>
                <td className="p-6"><CheckIcon /></td>
              </tr>

              {/* Email Support */}
              <tr className="border-b border-base-content/10 hover:bg-base-200/50 transition-colors">
                <td className="p-6 font-semibold">Email Support</td>
                <td className="p-6"><CheckIcon /></td>
                <td className="p-6"><CheckIcon /></td>
                <td className="p-6 bg-primary/10"><CheckIcon /></td>
                <td className="p-6"><CheckIcon /></td>
              </tr>

              {/* WordPress Install */}
              <tr className="border-b border-base-content/10 hover:bg-base-200/50 transition-colors">
                <td className="p-6 font-semibold">WordPress Install</td>
                <td className="p-6"><DashIcon /></td>
                <td className="p-6"><DashIcon /></td>
                <td className="p-6 bg-primary/10"><CheckIcon /></td>
                <td className="p-6"><CheckIcon /></td>
              </tr>

              {/* Backup Frequently */}
              <tr className="border-b border-base-content/10 hover:bg-base-200/50 transition-colors">
                <td className="p-6 font-semibold">Backup Frequently</td>
                <td className="p-6"><DashIcon /></td>
                <td className="p-6"><DashIcon /></td>
                <td className="p-6 bg-primary/10"><CheckIcon /></td>
                <td className="p-6"><CheckIcon /></td>
              </tr>

              {/* Custom Domain */}
              <tr className="border-b border-base-content/10 hover:bg-base-200/50 transition-colors">
                <td className="p-6 font-semibold">Custom Domain</td>
                <td className="p-6"><DashIcon /></td>
                <td className="p-6"><DashIcon /></td>
                <td className="p-6 bg-primary/10"><CheckIcon /></td>
                <td className="p-6"><CheckIcon /></td>
              </tr>

              {/* CTA Buttons */}
              <tr className="hover:bg-base-200/50 transition-colors">
                <td className="p-6 font-semibold"></td>
                <td className="p-6">
                  <a className="btn btn-outline border-base-content/20 hover:border-primary hover:bg-primary hover:text-primary-content w-full rounded-full" href="#">
                    Get Started
                  </a>
                </td>
                <td className="p-6">
                  <a className="btn btn-outline border-base-content/20 hover:border-primary hover:bg-primary hover:text-primary-content w-full rounded-full" href="#">
                    Get Started
                  </a>
                </td>
                <td className="p-6 bg-primary/10 rounded-b-2xl">
                  <a className="btn btn-primary w-full rounded-full shadow-lg" href="#">
                    Get Started
                  </a>
                </td>
                <td className="p-6">
                  <a className="btn btn-outline border-base-content/20 hover:border-primary hover:bg-primary hover:text-primary-content w-full rounded-full" href="#">
                    Get Started
                  </a>
                </td>
              </tr>

            </tbody>
          </table>
        </div>

      </div>
    </section>
  );
}

