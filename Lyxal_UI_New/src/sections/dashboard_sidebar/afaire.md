<div class="bg-base-200 flex min-h-screen flex-col">
    <!-- ---------- HEADER ---------- -->
    <div class="bg-base-100 sticky top-0 z-50 flex lg:ps-75">
      <div class="mx-auto w-full max-w-7xl">
        <nav class="navbar h-16">
          <button
            type="button"
            class="btn btn-soft btn-square btn-sm me-2 lg:hidden"
            aria-haspopup="dialog"
            aria-expanded="false"
            aria-controls="layout-toggle"
            data-overlay="#layout-toggle"
          >
            <span class="icon-[tabler--menu-2] size-4.5"></span>
          </button>
        </nav>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside
      id="layout-toggle"
      class="overlay overlay-open:translate-x-0 drawer drawer-start inset-y-0 start-0 hidden h-full [--auto-close:lg] sm:w-75 lg:block lg:translate-x-0 lg:shadow-none"
      aria-label="Sidebar"
      tabindex="-1"
    >
      <div class="drawer-body border-base-content/20 h-full border-e p-0">
        <div class="flex h-full max-h-full flex-col">
          <button
            type="button"
            class="btn btn-text btn-circle btn-sm absolute end-3 top-3 lg:hidden"
            aria-label="Close"
            data-overlay="#layout-toggle"
          >
            <span class="icon-[tabler--x] size-5"></span>
          </button>
          <div class="text-base-content border-base-content/20 flex flex-col items-center gap-4 border-b px-4 py-6">
            <div class="avatar">
              <div class="size-17 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar" />
              </div>
            </div>
            <div class="text-center">
              <h3 class="text-base-content text-lg font-semibold">Mitchell Johnson</h3>
              <p class="text-base-content/80">flyonui@mitchell</p>
            </div>
            <div class="flex gap-3">
              <a href="#" class="link size-4.5" aria-label="Facebook Link">
                <span class="icon-[tabler--brand-facebook] size-4.5"></span>
              </a>
              <a href="#" class="link size-4.5" aria-label="Instagram Link">
                <span class="icon-[tabler--brand-instagram] size-4.5"></span>
              </a>
              <a href="#" class="link size-4.5" aria-label="X Link">
                <span class="icon-[tabler--brand-twitter] size-4.5"></span>
              </a>
              <a href="#" class="link size-4.5" aria-label="Github Link">
                <span class="icon-[tabler--brand-github] size-4.5"></span>
              </a>
            </div>
          </div>
          <div class="h-full overflow-y-auto">
            <ul class="menu menu-sm gap-1 px-4">
              <!-- Dashboard -->
              <li class="mt-2.5">
                <a href="#" class="px-2">
                  <span class="icon-[tabler--dashboard] size-4.5"></span>
                  <span class="grow">Dashboard</span>
                  <span class="badge badge-sm badge-primary rounded-full">2</span>
                </a>
              </li>
              <li class="text-base-content/50 mt-2.5 p-2 text-xs uppercase">Pages</li>
              <!-- Content Performance -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--file-invoice] size-4.5"></span>
                  Content Performance
                </a>
              </li>
              <!-- Audience Insights -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--users] size-4.5"></span>
                  Audience Insights
                </a>
              </li>
              <!-- Engagement Metrics -->
              <li>
                <a href="#" class="menu-active px-2">
                  <span class="icon-[tabler--chart-pie-2] size-4.5"></span>
                  Engagement Metrics
                </a>
              </li>
              <!-- Hashtag Performance -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--hash] size-4.5"></span>
                  <span class="grow">Hashtag Performance</span>
                  <span class="badge badge-sm badge-success rounded-full">3</span>
                </a>
              </li>
              <!-- Competitor Analysis -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--arrows-left-right] size-4.5"></span>
                  Competitor Analysis
                </a>
              </li>
              <!-- Campaign Tracking -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--clock] size-4.5"></span>
                  Campaign Tracking
                </a>
              </li>
              <!-- Sentiment Analysis -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--file-digit] size-4.5"></span>
                  Sentiment Analysis
                </a>
              </li>
              <!-- Influencer -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--crown] size-4.5"></span>
                  Influencer
                </a>
              </li>

              <li class="text-base-content/50 mt-2.5 p-2 text-xs uppercase">Supporting Features</li>
              <!-- Real-Time Monitoring -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--heart-rate-monitor] size-4.5"></span>
                  Real-Time Monitoring
                </a>
              </li>
              <!-- Scheduled Posts & Calendar -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--calendar-stats] size-4.5"></span>
                  Scheduled Posts & Calendar
                </a>
              </li>
              <!-- Reports & Export -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--arrow-back-up] size-4.5"></span>
                  Reports & Export
                </a>
              </li>
              <!-- Settings & Integrations -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--settings] size-4.5"></span>
                  Settings & Integrations
                </a>
              </li>
              <!-- Management -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--users] size-4.5"></span>
                  Management
                </a>
              </li>
            </ul>
          </div>
          <div class="mt-auto flex gap-3 p-4">
            <span class="text-primary">
              <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clip-path="url(#a)">
                  <mask
                    id="b"
                    style="mask-type:luminance"
                    maskUnits="userSpaceOnUse"
                    x="0"
                    y="0"
                    width="32"
                    height="32"
                  >
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="#fff" />
                  </mask>
                  <g mask="url(#b)">
                    <path
                      d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8"
                      fill="currentColor"
                    />
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="url(#c)" />
                    <path
                      fill-rule="evenodd"
                      clip-rule="evenodd"
                      d="m22.258 20.467-5.55-6.839a1 1 0 0 0-1.568.02l-5.023 6.521a1 1 0 0 1-.793.39H7.17a1 1 0 0 1-.78-1.626l8.748-10.919a1 1 0 0 1 1.556-.006l9.125 11.198a1 1 0 0 1-.775 1.631h-2.01a1 1 0 0 1-.776-.37m-5.59-1.484 2.59 2.953c.567.646.108 1.659-.751 1.659h-4.922a1 1 0 0 1-.785-1.62l2.331-2.953a1 1 0 0 1 1.537-.04"
                      fill="url(#d)"
                    />
                  </g>
                  <path
                    d="M24 .666H8A7.333 7.333 0 0 0 .667 8v16A7.333 7.333 0 0 0 8 31.333h16A7.333 7.333 0 0 0 31.334 24V8A7.333 7.333 0 0 0 24 .666Z"
                    stroke="url(#e)"
                    stroke-width="2"
                  />
                </g>
                <defs>
                  <linearGradient id="c" x1="29" y1="2" x2="3" y2="29.5" gradientUnits="userSpaceOnUse">
                    <stop stop-opacity="0" />
                    <stop offset="1" stop-opacity=".38" />
                  </linearGradient>
                  <linearGradient id="d" x1="16.107" y1="7.64" x2="16.107" y2="23.595" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff" />
                    <stop offset="1" stop-color="#fff" stop-opacity=".6" />
                  </linearGradient>
                  <linearGradient id="e" x1="16" y1="0" x2="16" y2="32" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff" stop-opacity=".28" />
                    <stop offset="1" stop-color="#fff" stop-opacity=".04" />
                  </linearGradient>
                  <clipPath id="a">
                    <path fill="#fff" d="M0 0h32v32H0z" />
                  </clipPath>
                </defs>
              </svg>
            </span>
            <div>
              <span class="text-base-content block text-xl font-bold">Social Media</span>
            </div>
          </div>
        </div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->
    <div class="flex grow flex-col lg:ps-75">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="mx-auto w-full max-w-7xl flex-1 p-6">
        <div class="grid grid-cols-1 gap-6">
          <div class="card h-120 w-full">
            <div class="card-body border-base-content/20 rounded-box skeleton-striped m-6 border"></div>
          </div>
          <div class="card h-120 w-full">
            <div class="card-body border-base-content/20 rounded-box skeleton-striped m-6 border"></div>
          </div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="bg-base-100">
        <div class="mx-auto h-14 w-full max-w-7xl px-6"></div>
      </footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>
  </div>

[data-theme="dark"]
  li:not(.menu-title, .menu-disabled)
  > :not(ul, .menu-title, .collapse, .accordion-content, .btn).menu-active {
  background-color: var(--color-primary);
  color: var(--color-primary-content);
}

[data-theme="black"]
  li:not(.menu-title, .menu-disabled)
  > :not(ul, .menu-title, .collapse, .accordion-content, .btn).menu-active {
  background-color: var(--color-primary);
  color: var(--color-primary-content);
}

[data-theme="luxury"]
  li:not(.menu-title, .menu-disabled)
  > :not(ul, .menu-title, .collapse, .accordion-content, .btn).menu-active {
  background-color: var(--color-primary);
  color: var(--color-primary-content);
}



<body data-vh-checked="true" style="">
  <div class="dhabr flex min-h-screen jz3o6">
    <!-- ---------- HEADER ---------- -->
    <div class="bg-base-100 sticky top-0 at1sq flex lg:ps-75">
      <div class="wpaot w-full owca9">
        <nav class="hvzi2 eckwz">
          <button type="button" class="btn btn-soft btn-square btn-sm me-2 lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>
        </nav>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 wjz3b e4bmm n85ea [--auto-close:lg] sm:w-75 lg:block lg:translate-x-0 lg:shadow-none hidden" aria-label="Sidebar" style="">
      <div class="rkt7z border-base-content/20 n85ea jawf4 cbpaz">
        <div class="flex n85ea w8f5g jz3o6">
          <button type="button" class="btn btn-text btn-circle btn-sm absolute c6rnh vv66w lg:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
            <span class="icon-[tabler--x] qmuz4"></span>
          </button>
          <div class="flex items-center sly4q j2be9 zbjyy">
            <span class="text-primary">
              <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clip-path="url(#a)">
                  <mask id="b" style="mask-type:luminance" maskUnits="userSpaceOnUse" x="0" y="0" width="32" height="32">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="#fff"></path>
                  </mask>
                  <g mask="url(#b)">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="currentColor"></path>
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="url(#c)"></path>
                    <path fill-rule="evenodd" clip-rule="evenodd" d="m22.258 20.467-5.55-6.839a1 1 0 0 0-1.568.02l-5.023 6.521a1 1 0 0 1-.793.39H7.17a1 1 0 0 1-.78-1.626l8.748-10.919a1 1 0 0 1 1.556-.006l9.125 11.198a1 1 0 0 1-.775 1.631h-2.01a1 1 0 0 1-.776-.37m-5.59-1.484 2.59 2.953c.567.646.108 1.659-.751 1.659h-4.922a1 1 0 0 1-.785-1.62l2.331-2.953a1 1 0 0 1 1.537-.04" fill="url(#d)"></path>
                  </g>
                  <path d="M24 .666H8A7.333 7.333 0 0 0 .667 8v16A7.333 7.333 0 0 0 8 31.333h16A7.333 7.333 0 0 0 31.334 24V8A7.333 7.333 0 0 0 24 .666Z" stroke="url(#e)" stroke-width="2"></path>
                </g>
                <defs>
                  <linearGradient id="c" x1="29" y1="2" x2="3" y2="29.5" gradientUnits="userSpaceOnUse">
                    <stop stop-opacity="0"></stop>
                    <stop offset="1" stop-opacity=".38"></stop>
                  </linearGradient>
                  <linearGradient id="d" x1="16.107" y1="7.64" x2="16.107" y2="23.595" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".6"></stop>
                  </linearGradient>
                  <linearGradient id="e" x1="16" y1="0" x2="16" y2="32" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff" stop-opacity=".28"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".04"></stop>
                  </linearGradient>
                  <clipPath id="a">
                    <path fill="#fff" d="M0 0h32v32H0z"></path>
                  </clipPath>
                </defs>
              </svg>
            </span>
            <div>
              <span class="text-base-content block bk5oo t3mfo">Food Point</span>
            </div>
          </div>
          <div class="n85ea overflow-y-auto">
            <ul class="x737x v85mw rsqkx nijmi o4xu2 qgzw6">
              <!-- Dashboard -->
              <li>
                <a href="#" class="jspog px-3">
                  <span class="icon-[tabler--dashboard] qmuz4"></span>
                  <span class="sxihv">Dashboard</span>
                </a>
              </li>
              <!-- New Order -->
              <li>
                <a href="#" class="jspog px-3">
                  <span class="icon-[tabler--cup] qmuz4"></span>
                  <span class="sxihv">New Order</span>
                </a>
              </li>
              <!-- Inventory -->
              <li>
                <a href="#" class="jspog px-3">
                  <span class="icon-[tabler--hotel-service] qmuz4"></span>
                  <span class="sxihv">Inventory</span>
                </a>
              </li>
              <!-- Discount -->
              <li>
                <a href="#" class="oeogr jspog px-3">
                  <span class="icon-[tabler--discount] qmuz4"></span>
                  <span class="sxihv">Discount</span>
                  <span class="ijn5q o1g2m pze98 rounded-full">2</span>
                </a>
              </li>
              <!-- Ordering Table -->
              <li>
                <a href="#" class="jspog px-3">
                  <span class="icon-[tabler--table] qmuz4"></span>
                  <span class="sxihv">Ordering Table</span>
                </a>
              </li>
              <!-- Costumers -->
              <li>
                <a href="#" class="jspog px-3">
                  <span class="icon-[tabler--users] qmuz4"></span>
                  <span class="sxihv">Costumers</span>
                </a>
              </li>
              <!-- Order List -->
              <li>
                <a href="#" class="jspog px-3">
                  <span class="icon-[tabler--list-details] qmuz4"></span>
                  <span class="sxihv">Order List</span>
                </a>
              </li>
              <!-- Staff Management -->
              <li>
                <a href="#" class="jspog px-3">
                  <span class="icon-[tabler--settings] qmuz4"></span>
                  <span class="sxihv">Staff Management</span>
                </a>
              </li>
              <li class="text-base-content/50 cwnx3 f1870 text-xs vxiam">Useful Pages</li>
              <!-- Help Center  -->
              <li>
                <a href="#" class="jspog px-3">
                  <span class="icon-[tabler--help] qmuz4"></span>
                  <span class="sxihv">Help Center</span>
                </a>
              </li>
              <!-- Product List -->
              <li>
                <a href="#" class="jspog px-3">
                  <span class="icon-[tabler--list-check] qmuz4"></span>
                  <span class="sxihv">Product List</span>
                </a>
              </li>
              <!-- Customer Management -->
              <li>
                <a href="#" class="jspog px-3">
                  <span class="icon-[tabler--users] qmuz4"></span>
                  <span class="sxihv">Customer Management</span>
                </a>
              </li>
              <!-- Billing & Payment Reports -->
              <li>
                <a href="#" class="jspog px-3">
                  <span class="icon-[tabler--file-invoice] qmuz4"></span>
                  <span class="sxihv">Billing &amp; Payment Reports</span>
                </a>
              </li>
              <!-- Feedback & Reviews -->
              <li>
                <a href="#" class="jspog px-3">
                  <span class="icon-[tabler--star] qmuz4"></span>
                  <span class="sxihv">Feedback &amp; Reviews</span>
                </a>
              </li>
            </ul>
          </div>
          <div class="os8bl p-4">
            <div class="rounded-box border-base-content/20 relative border">
              <!-- BACKGROUND SVG -->
              <svg class="absolute top-0 left-0" xmlns="http://www.w3.org/2000/svg" width="237" height="155" viewBox="0 0 237 155" fill="none">
                <g opacity="0.06" filter="url(#filter0_f_16309_184305)">
                  <ellipse cx="47.5" cy="19.0742" rx="125.5" ry="90" fill="var(--color-primary)"></ellipse>
                </g>
                <defs>
                  <filter id="filter0_f_16309_184305" x="-142" y="-134.926" width="379" height="308" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
                    <feFlood flood-opacity="0" result="BackgroundImageFix"></feFlood>
                    <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"></feBlend>
                    <feGaussianBlur stdDeviation="32" result="effect1_foregroundBlur_16309_184305"></feGaussianBlur>
                  </filter>
                </defs>
              </svg>
              <div class="flex items-center justify-between uzipw">
                <div class="rounded-field bg-base-100 shadow-base-300/20 text-primary flex j4z3m items-center justify-center ycx8a">
                  <span class="icon-[tabler--pizza] size-6"></span>
                </div>
                <button class="btn btn-square btn-text">
                  <span class="icon-[tabler--dots-vertical] size-6 shrink-0"></span>
                </button>
              </div>
              <div class="flex h7vz3 justify-between a7thv k97bj">
                <div>
                  <span class="text-base-content/80 block">Todays Order</span>
                  <span class="text-base-content block bk5oo t3mfo">234</span>
                </div>
                <div>
                  <div class="rp44n kqbqh">
                    <div class="nfjpm">
                      <div class="ao3uo">
                        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
                      </div>
                    </div>
                    <div class="nfjpm">
                      <div class="ao3uo">
                        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                      </div>
                    </div>
                    <div class="nfjpm">
                      <div class="ao3uo">
                        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                      </div>
                    </div>
                    <div class="nfjpm">
                      <div class="ao3uo">
                        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->
    <div class="flex sxihv jz3o6 lg:ps-75">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="wpaot w-full owca9 e6ynr sxihv fbpri">
        <div class="dpzny wfsyj ip6vv md:grid-cols-2">
          <div class="zq390 lynk2 hono0 w-full nwdq3 md:col-span-2">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 lynk2 hono0 w-full nwdq3">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 lynk2 hono0 w-full nwdq3">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="bg-base-100">
        <div class="wpaot hg6f0 w-full owca9 rukzz"></div>
      </footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>
  </div>


    <script src="https://flyonui.becdn.net/pro/libs/flyonui/flyonui.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const url = window.location.href

      // Check if the URL contains the "theme" parameter
      const themeParam = new URLSearchParams(window.location.search).get("theme")
      const dirRTL = new URLSearchParams(window.location.search).get("rtl")

      // If a theme parameter is present, apply it to the document
      if (themeParam) {
        document.documentElement.setAttribute("data-theme", themeParam)
      }
      if (dirRTL === "true") {
        document.documentElement.setAttribute("dir", "rtl")
      }
    })
  </script>
  

</body>


<body data-vh-checked="true">
  <div class="dhabr flex min-h-screen jz3o6">
    <!-- ---------- HEADER ---------- -->
    <div class="sticky top-0 at1sq flex lg:ps-75">
      <div class="wpaot w-full">
        <nav class="hvzi2 dhabr eckwz">
          <button type="button" class="btn btn-soft btn-square btn-sm me-2 lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>
        </nav>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc dhabr klzl7 wjz3b e4bmm hidden n85ea [--auto-close:lg] sm:w-75 lg:block lg:translate-x-0 lg:shadow-none" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z n85ea cbpaz">
        <div class="flex n85ea w8f5g jz3o6">
          <button type="button" class="btn btn-text btn-circle btn-sm absolute c6rnh vv66w lg:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
            <span class="icon-[tabler--x] qmuz4"></span>
          </button>
          <div class="flex items-center sly4q a7thv mwpft">
            <span class="text-primary">
              <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clip-path="url(#a)">
                  <mask id="b" style="mask-type:luminance" maskUnits="userSpaceOnUse" x="0" y="0" width="32" height="32">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="#fff"></path>
                  </mask>
                  <g mask="url(#b)">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="currentColor"></path>
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="url(#c)"></path>
                    <path fill-rule="evenodd" clip-rule="evenodd" d="m22.258 20.467-5.55-6.839a1 1 0 0 0-1.568.02l-5.023 6.521a1 1 0 0 1-.793.39H7.17a1 1 0 0 1-.78-1.626l8.748-10.919a1 1 0 0 1 1.556-.006l9.125 11.198a1 1 0 0 1-.775 1.631h-2.01a1 1 0 0 1-.776-.37m-5.59-1.484 2.59 2.953c.567.646.108 1.659-.751 1.659h-4.922a1 1 0 0 1-.785-1.62l2.331-2.953a1 1 0 0 1 1.537-.04" fill="url(#d)"></path>
                  </g>
                  <path d="M24 .666H8A7.333 7.333 0 0 0 .667 8v16A7.333 7.333 0 0 0 8 31.333h16A7.333 7.333 0 0 0 31.334 24V8A7.333 7.333 0 0 0 24 .666Z" stroke="url(#e)" stroke-width="2"></path>
                </g>
                <defs>
                  <linearGradient id="c" x1="29" y1="2" x2="3" y2="29.5" gradientUnits="userSpaceOnUse">
                    <stop stop-opacity="0"></stop>
                    <stop offset="1" stop-opacity=".38"></stop>
                  </linearGradient>
                  <linearGradient id="d" x1="16.107" y1="7.64" x2="16.107" y2="23.595" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".6"></stop>
                  </linearGradient>
                  <linearGradient id="e" x1="16" y1="0" x2="16" y2="32" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff" stop-opacity=".28"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".04"></stop>
                  </linearGradient>
                  <clipPath id="a">
                    <path fill="#fff" d="M0 0h32v32H0z"></path>
                  </clipPath>
                </defs>
              </svg>
            </span>
            <div>
              <span class="text-base-content block bk5oo t3mfo">Academy</span>
            </div>
          </div>
          <div class="n85ea overflow-y-auto">
            <ul class="x737x v85mw rsqkx p-3 qn5kk">
              <!-- Dashboard -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--dashboard] qmuz4"></span>
                  <span class="sxihv">Dashboard</span>
                  <span class="ijn5q o1g2m pze98 rounded-full">3</span>
                </a>
              </li>
              <li class="text-base-content/50 cwnx3 f1870 text-xs vxiam">Pages</li>
              <!-- Student Profile -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--user] qmuz4"></span>
                  <span class="sxihv">Student Profile</span>
                </a>
              </li>
              <!-- Progress -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--trending-up] qmuz4"></span>
                  <span class="sxihv">Progress</span>
                </a>
              </li>
              <!-- Assignments -->
              <li>
                <a href="#" class="oeogr px-2">
                  <span class="icon-[tabler--pencil] qmuz4"></span>
                  <span class="sxihv">Assignments</span>
                </a>
              </li>
              <!-- Schedule -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--clock] qmuz4"></span>
                  <span class="sxihv">Schedule</span>
                  <span class="ijn5q o1g2m pze98 rounded-full">2</span>
                </a>
              </li>
              <!-- Resources -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--folder] qmuz4"></span>
                  <span class="sxihv">Resources</span>
                </a>
              </li>
              <!-- Reports -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--report-analytics] qmuz4"></span>
                  <span class="sxihv">Reports</span>
                </a>
              </li>
              <!-- Certificates -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--certificate] qmuz4"></span>
                  <span class="sxihv">Certificates</span>
                </a>
              </li>
              <li class="text-base-content/50 cwnx3 f1870 text-xs vxiam">Misc</li>
              <!-- Reviews -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--star] qmuz4"></span>
                  <span class="sxihv">Reviews</span>
                </a>
              </li>
              <!-- FAQ -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--help] qmuz4"></span>
                  <span class="sxihv">FAQ</span>
                </a>
              </li>
              <!-- Settings -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--settings] qmuz4"></span>
                  <span class="sxihv">Settings</span>
                </a>
              </li>
            </ul>
          </div>
          <div class="os8bl j2be9 mrpnf">
            <div class="rounded-box jgsta relative hqh7v uzipw er88f">
              <h6 class="bk5oo t3mfo">Mobile app is available</h6>
              <p>The personal account allows users manage subscription</p>
              <button class="btn btn-primary">Get App</button>
              <img src="https://cdn.flyonui.com/fy-assets/application-shells/image-1.png" alt="brand-logo">
            </div>
          </div>
        </div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->

    <div class="flex sxihv jz3o6 lg:ps-75">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="e6ynr fbpri">
        <div class="dpzny wfsyj ip6vv md:grid-cols-2">
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full md:col-span-2">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="hg6f0 w-full rukzz"></footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>
  </div>


    <script src="https://flyonui.becdn.net/pro/libs/flyonui/flyonui.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const url = window.location.href

      // Check if the URL contains the "theme" parameter
      const themeParam = new URLSearchParams(window.location.search).get("theme")
      const dirRTL = new URLSearchParams(window.location.search).get("rtl")

      // If a theme parameter is present, apply it to the document
      if (themeParam) {
        document.documentElement.setAttribute("data-theme", themeParam)
      }
      if (dirRTL === "true") {
        document.documentElement.setAttribute("dir", "rtl")
      }
    })
  </script>
  

</body>


<body data-vh-checked="true">
  <div class="dhabr flex min-h-screen jz3o6">
    <!-- ---------- HEADER ---------- -->
    <div class="bg-base-100 sticky top-0 at1sq flex lg:ps-75">
      <div class="wpaot w-full owca9">
        <nav class="hvzi2 eckwz">
          <button type="button" class="btn btn-soft btn-square btn-sm me-2 lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>
        </nav>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 wjz3b e4bmm hidden n85ea [--auto-close:lg] sm:w-75 lg:block lg:translate-x-0 lg:shadow-none" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z border-base-content/20 n85ea jawf4 cbpaz">
        <div class="flex n85ea w8f5g jz3o6">
          <button type="button" class="btn btn-text btn-circle btn-sm absolute c6rnh vv66w lg:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
            <span class="icon-[tabler--x] size-5"></span>
          </button>
          <div class="flex items-center sly4q j2be9 mwpft">
            <span class="text-primary">
              <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clip-path="url(#a)">
                  <mask id="b" style="mask-type:luminance" maskUnits="userSpaceOnUse" x="0" y="0" width="32" height="32">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="#fff"></path>
                  </mask>
                  <g mask="url(#b)">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="currentColor"></path>
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="url(#c)"></path>
                    <path fill-rule="evenodd" clip-rule="evenodd" d="m22.258 20.467-5.55-6.839a1 1 0 0 0-1.568.02l-5.023 6.521a1 1 0 0 1-.793.39H7.17a1 1 0 0 1-.78-1.626l8.748-10.919a1 1 0 0 1 1.556-.006l9.125 11.198a1 1 0 0 1-.775 1.631h-2.01a1 1 0 0 1-.776-.37m-5.59-1.484 2.59 2.953c.567.646.108 1.659-.751 1.659h-4.922a1 1 0 0 1-.785-1.62l2.331-2.953a1 1 0 0 1 1.537-.04" fill="url(#d)"></path>
                  </g>
                  <path d="M24 .666H8A7.333 7.333 0 0 0 .667 8v16A7.333 7.333 0 0 0 8 31.333h16A7.333 7.333 0 0 0 31.334 24V8A7.333 7.333 0 0 0 24 .666Z" stroke="url(#e)" stroke-width="2"></path>
                </g>
                <defs>
                  <linearGradient id="c" x1="29" y1="2" x2="3" y2="29.5" gradientUnits="userSpaceOnUse">
                    <stop stop-opacity="0"></stop>
                    <stop offset="1" stop-opacity=".38"></stop>
                  </linearGradient>
                  <linearGradient id="d" x1="16.107" y1="7.64" x2="16.107" y2="23.595" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".6"></stop>
                  </linearGradient>
                  <linearGradient id="e" x1="16" y1="0" x2="16" y2="32" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff" stop-opacity=".28"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".04"></stop>
                  </linearGradient>
                  <clipPath id="a">
                    <path fill="#fff" d="M0 0h32v32H0z"></path>
                  </clipPath>
                </defs>
              </svg>
            </span>
            <div>
              <span class="text-base-content block bk5oo fl9z1">File Manager</span>
            </div>
          </div>
          <div class="p-4 ilff5">
            <div class="ljn0d">
              <span class="icon-[tabler--search] text-base-content/80 q7z0e xn3np size-5 shrink-0"></span>
              <label class="rui3g" for="searchInput">Search</label>
              <input type="text" class="sxihv" placeholder="Search" id="searchInput">
            </div>
          </div>
          <div class="n85ea overflow-y-auto">
            <ul class="accordion x737x v85mw rsqkx j2be9">
              <!-- Dashboard -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--chart-bar] qmuz4"></span>
                  <span class="sxihv">Dashboard</span>
                  <span class="ijn5q o1g2m pze98 rounded-full">2</span>
                </a>
              </li>
              <li class="text-base-content/50 cwnx3 f1870 text-xs vxiam">Pages</li>
              <!-- My Files -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--file-invoice] qmuz4"></span>
                  <span class="sxihv">My Files</span>
                </a>
              </li>
              <!-- Shared with Me -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--users] qmuz4"></span>
                  <span class="sxihv">Shared with Me</span>
                </a>
              </li>
              <!-- Recent Files -->
              <li>
                <a href="#" class="oeogr px-2">
                  <span class="icon-[tabler--chart-pie-2] qmuz4"></span>
                  <span class="sxihv">Recent Files</span>
                </a>
              </li>
              <!-- Starred -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--hash] qmuz4"></span>
                  <span class="sxihv">Starred</span>
                  <span class="ijn5q o1g2m gehqc rounded-full">3</span>
                </a>
              </li>
              <!-- Recycle Bin -->
              <li class="accordion-item" id="recycle">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="recycle-collapse" aria-expanded="true">
                  <span class="icon-[tabler--arrows-right-left] qmuz4"></span>
                  <span class="sxihv">Recycle Bin</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="recycle-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="recycle" role="region">
                  <ul class="kf6hd">
                    <!-- File 1 -->
                    <li>
                      <a href="#" class="px-2">File 1</a>
                    </li>
                    <!-- File 2 -->
                    <li>
                      <a href="#" class="px-2">File 2</a>
                    </li>
                    <!-- File 3 -->
                    <li>
                      <a href="#" class="px-2">File 3</a>
                    </li>
                  </ul>
                </div>
              </li>
              <li class="text-base-content/50 cwnx3 f1870 text-xs vxiam">File Organization</li>
              <!-- Folders -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--heart-rate-monitor] qmuz4"></span>
                  <span class="sxihv">Folders</span>
                </a>
              </li>
              <!-- Storage Management -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--calendar-stats] qmuz4"></span>
                  <span class="sxihv">Storage Management</span>
                </a>
              </li>
              <!-- File Details -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--arrow-back-up] qmuz4"></span>
                  <span class="sxihv">File Details</span>
                </a>
              </li>
              <!-- Workspace -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--settings] qmuz4"></span>
                  <span class="sxihv">Workspace</span>
                </a>
              </li>
              <!-- Activity Logs -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--users] qmuz4"></span>
                  <span class="sxihv">Activity Logs</span>
                </a>
              </li>
            </ul>
          </div>
          <div class="os8bl j2be9 mrpnf">
            <div class="rounded-box border-base-content/20 relative hqh7v border uzipw">
              <div class="flex eovr6">
                <span class="icon-[tabler--folders] size-5 shrink-0"></span>
                <span class="font-medium">Storage</span>
              </div>
              <p>
                <span class="font-medium">10.4GB</span>
                of 15GB
              </p>
              <div class="progress h-2 w-full" role="progressbar" aria-label="Primary Progressbar" aria-valuenow="70" aria-valuemin="0" aria-valuemax="100">
                <div class="progress-bar progress-primary a6x83"></div>
              </div>
              <button class="btn btn-primary rhmi6 btn-sm">Upgrade Now</button>
            </div>
          </div>
        </div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->
    <div class="flex sxihv jz3o6 lg:ps-75">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="wpaot w-full owca9 e6ynr fbpri">
        <div class="dpzny wfsyj ip6vv">
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="bg-base-100">
        <div class="wpaot hg6f0 w-full owca9 rukzz"></div>
      </footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>
  </div>


    <script src="https://flyonui.becdn.net/pro/libs/flyonui/flyonui.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const url = window.location.href

      // Check if the URL contains the "theme" parameter
      const themeParam = new URLSearchParams(window.location.search).get("theme")
      const dirRTL = new URLSearchParams(window.location.search).get("rtl")

      // If a theme parameter is present, apply it to the document
      if (themeParam) {
        document.documentElement.setAttribute("data-theme", themeParam)
      }
      if (dirRTL === "true") {
        document.documentElement.setAttribute("dir", "rtl")
      }
    })
  </script>
  

</body>


<body data-vh-checked="true">
  <div class="dhabr flex min-h-screen jz3o6">
    <!-- ---------- HEADER ---------- -->
    <div class="bg-base-100 sticky top-0 at1sq flex lg:ps-93">
      <div class="wpaot w-full">
        <nav class="hvzi2 eckwz">
          <button type="button" class="btn btn-soft btn-square btn-sm me-2 lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>
        </nav>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 wjz3b e4bmm hidden n85ea [--auto-close:lg] sm:w-93 lg:block lg:translate-x-0 lg:shadow-none" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z flex n85ea cbpaz">
        <div class="n85ea w8f5g plsq6">
          <div class="flex items-center justify-center sly4q a7thv egd50">
            <span class="text-primary">
              <svg width="38" height="38" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clip-path="url(#a)">
                  <mask id="b" style="mask-type:luminance" maskUnits="userSpaceOnUse" x="0" y="0" width="32" height="32">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="#fff"></path>
                  </mask>
                  <g mask="url(#b)">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="currentColor"></path>
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="url(#c)"></path>
                    <path fill-rule="evenodd" clip-rule="evenodd" d="m22.258 20.467-5.55-6.839a1 1 0 0 0-1.568.02l-5.023 6.521a1 1 0 0 1-.793.39H7.17a1 1 0 0 1-.78-1.626l8.748-10.919a1 1 0 0 1 1.556-.006l9.125 11.198a1 1 0 0 1-.775 1.631h-2.01a1 1 0 0 1-.776-.37m-5.59-1.484 2.59 2.953c.567.646.108 1.659-.751 1.659h-4.922a1 1 0 0 1-.785-1.62l2.331-2.953a1 1 0 0 1 1.537-.04" fill="url(#d)"></path>
                  </g>
                  <path d="M24 .666H8A7.333 7.333 0 0 0 .667 8v16A7.333 7.333 0 0 0 8 31.333h16A7.333 7.333 0 0 0 31.334 24V8A7.333 7.333 0 0 0 24 .666Z" stroke="url(#e)" stroke-width="2"></path>
                </g>
                <defs>
                  <linearGradient id="c" x1="29" y1="2" x2="3" y2="29.5" gradientUnits="userSpaceOnUse">
                    <stop stop-opacity="0"></stop>
                    <stop offset="1" stop-opacity=".38"></stop>
                  </linearGradient>
                  <linearGradient id="d" x1="16.107" y1="7.64" x2="16.107" y2="23.595" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".6"></stop>
                  </linearGradient>
                  <linearGradient id="e" x1="16" y1="0" x2="16" y2="32" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff" stop-opacity=".28"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".04"></stop>
                  </linearGradient>
                  <clipPath id="a">
                    <path fill="#fff" d="M0 0h32v32H0z"></path>
                  </clipPath>
                </defs>
              </svg>
            </span>
          </div>
          <ul class="flex jz3o6 sly4q j2be9 egd50">
            <!-- Dashboard -->
            <li class="tooltip rounded-field has-[.link-active]:border-primary has-[.link-active]:bg-primary text-base-content border-base-content/20 hover:bg-neutral/10 j8wvb [--placement:right] has-[.link-active]:text-white">
              <a href="#" class="tooltip-toggle u97gy flex lt1t7 items-center justify-center" aria-label="Home Link">
                <span class="icon-[solar--chart-bold-duotone] girx5"></span>
              </a>
              <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 0px; top: 0px;">
                <span class="tnsaf">Dashboard</span>
              </span>
            </li>
            <!-- Map -->
            <li class="tooltip rounded-field has-[.link-active]:border-primary has-[.link-active]:bg-primary text-base-content border-base-content/20 hover:bg-neutral/10 j8wvb [--placement:right] has-[.link-active]:text-white">
              <a href="#" class="tooltip-toggle flex lt1t7 items-center justify-center" aria-label="Home Link">
                <span class="icon-[solar--map-point-bold-duotone] girx5"></span>
              </a>
              <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 0px; top: 0px;">
                <span class="tnsaf">Map</span>
              </span>
            </li>
            <!-- Fleet -->
            <li class="tooltip rounded-field has-[.link-active]:border-primary has-[.link-active]:bg-primary text-base-content border-base-content/20 hover:bg-neutral/10 j8wvb [--placement:right] has-[.link-active]:text-white">
              <a href="#" class="tooltip-toggle flex lt1t7 items-center justify-center" aria-label="Home Link">
                <span class="icon-[solar--box-minimalistic-bold-duotone] girx5"></span>
              </a>
              <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 0px; top: 0px;">
                <span class="tnsaf">Fleet</span>
              </span>
            </li>
            <!-- Order Management -->
            <li class="tooltip rounded-field has-[.link-active]:border-primary has-[.link-active]:bg-primary text-base-content border-base-content/20 hover:bg-neutral/10 j8wvb [--placement:right] has-[.link-active]:text-white">
              <a href="#" class="tooltip-toggle flex lt1t7 items-center justify-center" aria-label="Home Link">
                <span class="icon-[solar--home-angle-bold-duotone] girx5"></span>
              </a>
              <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 0px; top: 0px;">
                <span class="tnsaf">Order Management</span>
              </span>
            </li>
            <!-- Billing & Payments -->
            <li class="tooltip rounded-field has-[.link-active]:border-primary has-[.link-active]:bg-primary text-base-content border-base-content/20 hover:bg-neutral/10 j8wvb [--placement:right] has-[.link-active]:text-white">
              <a href="#" class="tooltip-toggle flex lt1t7 items-center justify-center" aria-label="Home Link">
                <span class="icon-[solar--bell-off-bold-duotone] girx5"></span>
              </a>
              <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 0px; top: 0px;">
                <span class="tnsaf">Billing &amp; Payments</span>
              </span>
            </li>
            <!-- Billing & Payments -->
            <li class="tooltip rounded-field has-[.link-active]:border-primary has-[.link-active]:bg-primary text-base-content border-base-content/20 hover:bg-neutral/10 j8wvb [--placement:right] has-[.link-active]:text-white">
              <a href="#" class="tooltip-toggle flex lt1t7 items-center justify-center" aria-label="Home Link">
                <span class="icon-[solar--card-bold-duotone] girx5"></span>
              </a>
              <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 0px; top: 0px;">
                <span class="tnsaf">Billing &amp; Payments</span>
              </span>
            </li>
            <!-- Settings & Profile -->
            <li class="tooltip rounded-field has-[.link-active]:border-primary has-[.link-active]:bg-primary text-base-content border-base-content/20 hover:bg-neutral/10 j8wvb [--placement:right] has-[.link-active]:text-white">
              <a href="#" class="tooltip-toggle flex lt1t7 items-center justify-center" aria-label="Home Link">
                <span class="icon-[solar--user-rounded-bold-duotone] girx5"></span>
              </a>
              <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 0px; top: 0px;">
                <span class="tnsaf">Settings &amp; Profile</span>
              </span>
            </li>
          </ul>
        </div>
        <div class="border-base-content/20 w-full s0k3q">
          <button type="button" class="btn btn-text btn-circle btn-sm absolute c6rnh vv66w lg:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
            <span class="icon-[tabler--x] size-5"></span>
          </button>
          <div class="flex n85ea w8f5g jz3o6">
            <!-- Brand Name -->
            <div class="a7thv mwpft">
              <h1 class="text-base-content c9rvi fl9z1">Logistic</h1>
              <p class="text-base-content/50 text-xs">Dashboard App</p>
            </div>
            <div class="flex jz3o6 njdg2 x5704 vcmtr">
              <!-- Budget & Spent -->
              <div class="flex njdg2 b9hof">
                <div class="rounded-box border-base-content/20 flex w-full jz3o6 eovr6 border dkr8s vxemw">
                  <h6 class="text-base-content/50 text-sm">Deliveries</h6>
                  <p class="text-success fyo4u c9rvi t3mfo">23.8k</p>
                </div>
                <div class="rounded-box border-base-content/20 flex w-full jz3o6 eovr6 border dkr8s vxemw">
                  <h6 class="text-base-content/50 text-sm">On the way</h6>
                  <p class="text-primary fyo4u c9rvi t3mfo">1.2k</p>
                </div>
              </div>

              <!-- Goal -->
              <div>
                <h6 class="text-base-content s7x45 font-medium">Delivery Process</h6>
                <div class="progress xxor5 w-full" role="progressbar" aria-label="Primary Progressbar" aria-valuenow="30" aria-valuemin="0" aria-valuemax="100">
                  <div class="progress-bar progress-primary i45nw"></div>
                </div>
                <p class="text-base-content/50 qizc4 text-xs">Reached 30% from target</p>
              </div>
            </div>

            <div class="n85ea overflow-y-auto px-3 egd50">
              <!-- Services -->
              <h6 class="text-base-content s7x45 font-medium">Services</h6>
              <div class="dpzny qoht8 njdg2">
                <a href="#" class="rounded-box dhabr flex jz3o6 items-center justify-center eovr6 px-2 fnetp">
                  <span class="icon-[tabler--user] size-8"></span>
                  <span class="text-base-content text-sm">Driver</span>
                </a>
                <a href="#" class="rounded-box dhabr flex jz3o6 items-center justify-center eovr6 px-2 fnetp">
                  <span class="icon-[tabler--car-crane] size-8"></span>
                  <span class="text-base-content text-sm">Vehicle</span>
                </a>
                <a href="#" class="rounded-box dhabr flex jz3o6 items-center justify-center eovr6 px-2 fnetp">
                  <span class="icon-[tabler--box] size-8"></span>
                  <span class="text-base-content text-sm">Inventory</span>
                </a>
                <a href="#" class="rounded-box dhabr flex jz3o6 items-center justify-center eovr6 px-2 fnetp">
                  <span class="icon-[tabler--map-pin] size-8"></span>
                  <span class="text-base-content text-sm">Tracking</span>
                </a>
                <a href="#" class="rounded-box dhabr flex jz3o6 items-center justify-center eovr6 px-2 fnetp">
                  <span class="icon-[tabler--home] size-8"></span>
                  <span class="text-base-content text-sm">Warehouse</span>
                </a>
                <a href="#" class="rounded-box dhabr flex jz3o6 items-center justify-center eovr6 px-2 fnetp">
                  <span class="icon-[tabler--shopping-cart] size-8"></span>
                  <span class="text-base-content text-sm">Order</span>
                </a>
              </div>
              <ul class="x737x v85mw rsqkx">
                <li class="text-base-content/50 cwnx3 f1870 text-xs vxiam">Settings &amp; Profile</li>
                <!-- User Profile -->
                <li>
                  <a href="#" class="px-2">
                    <span class="icon-[tabler--user] qmuz4"></span>
                    User Profile
                  </a>
                </li>
                <!-- Change Password -->
                <li>
                  <a href="#" class="px-2">
                    <span class="icon-[tabler--lock] qmuz4"></span>
                    Change Password
                  </a>
                </li>
                <!-- Notification Settings -->
                <li>
                  <a href="#" class="px-2">
                    <span class="icon-[tabler--bell] qmuz4"></span>
                    Notification Settings
                  </a>
                </li>
                <!-- App Settings -->
                <li>
                  <a href="#" class="px-2">
                    <span class="icon-[tabler--settings] qmuz4"></span>
                    App Settings
                  </a>
                </li>
                <!-- Create Shipment -->
                <li>
                  <a href="#" class="px-2">
                    <span class="icon-[tabler--ship] qmuz4"></span>
                    Create Shipment
                  </a>
                </li>
                <!-- Fleet Status Overview -->
                <li>
                  <a href="#" class="px-2">
                    <span class="icon-[tabler--map] qmuz4"></span>
                    Fleet Status Overview
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->

    <div class="flex sxihv jz3o6 lg:ps-93">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="e6ynr fbpri">
        <div class="zq390 tjntb w-full">
          <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="bg-base-100 hg6f0 qzwp2 rukzz"></footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>
  </div>


    <script src="https://flyonui.becdn.net/pro/libs/flyonui/flyonui.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const url = window.location.href

      // Check if the URL contains the "theme" parameter
      const themeParam = new URLSearchParams(window.location.search).get("theme")
      const dirRTL = new URLSearchParams(window.location.search).get("rtl")

      // If a theme parameter is present, apply it to the document
      if (themeParam) {
        document.documentElement.setAttribute("data-theme", themeParam)
      }
      if (dirRTL === "true") {
        document.documentElement.setAttribute("dir", "rtl")
      }
    })
  </script>
  

</body>



<body data-vh-checked="true">
  <div class="dhabr flex min-h-screen jz3o6">
    <!-- ---------- HEADER ---------- -->
    <div class="bg-base-100 sticky top-0 at1sq flex lg:ps-75">
      <div class="wpaot w-full owca9">
        <nav class="hvzi2 eckwz">
          <button type="button" class="btn btn-soft btn-square btn-sm me-2 lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>
        </nav>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay jfin8 overlay-open:translate-x-0 vxjzc klzl7 m4hp4 wjz3b e4bmm hidden n85ea [--auto-close:lg] sm:w-75 lg:block lg:translate-x-0 lg:shadow-none" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z n85ea cbpaz">
        <div class="flex n85ea w8f5g jz3o6">
          <button type="button" class="btn btn-text btn-circle btn-sm absolute c6rnh vv66w [--btn-color:#fff] lg:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
            <span class="icon-[tabler--x] qmuz4"></span>
          </button>
          <div class="flex items-center sly4q a7thv zbjyy bk5oo t3mfo lmn89">
            <div class="flex size-8 items-center justify-center rounded-full qr9u1">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M17.6745 16.9224L12.6233 10.378C12.2167 9.85117 11.4185 9.8611 11.0251 10.3979L6.45728 16.631C6.26893 16.888 5.96935 17.0398 5.65069 17.0398H3.79114C2.9635 17.0398 2.49412 16.0919 2.99583 15.4336L11.0224 4.90319C11.4206 4.38084 12.2056 4.37762 12.608 4.89668L20.9829 15.6987C21.4923 16.3558 21.024 17.3114 20.1926 17.3114H18.4661C18.1562 17.3114 17.8638 17.1677 17.6745 16.9224ZM12.5866 15.5924L14.8956 18.3593C15.439 19.0105 14.976 20 14.1278 20H9.74075C8.9164 20 8.4461 19.0586 8.94116 18.3994L11.0192 15.6325C11.4065 15.1169 12.1734 15.0972 12.5866 15.5924Z" fill="var(--color-primary)"></path>
              </svg>
            </div>
            <span>Flyon AI</span>
          </div>
          <div class="n85ea overflow-y-auto">
            <ul class="accordion x737x v85mw rsqkx px-3 qn5kk [--menu-active-bg:white] [--menu-hover-bg:white]/20 [--menu-hover-fg:white]">
              <!-- Dashboard -->
              <li>
                <a href="#" class="rounded-full lmn89">
                  <span class="icon-[tabler--dashboard] qmuz4"></span>
                  <span class="sxihv">Dashboard</span>
                </a>
              </li>
              <!-- API Integration -->
              <li>
                <a href="#" class="oeogr rounded-full lmn89">
                  <span class="icon-[tabler--file-invoice] qmuz4"></span>
                  <span class="sxihv">API Integration</span>
                  <span class="ijn5q o1g2m e6v2p rounded-full">3</span>
                </a>
              </li>
              <!-- Prediction Logs -->
              <li>
                <a href="#" class="rounded-full lmn89">
                  <span class="icon-[tabler--users] qmuz4"></span>
                  <span class="sxihv">Prediction Logs</span>
                </a>
              </li>
              <!-- Explainability -->
              <li>
                <a href="#" class="rounded-full lmn89">
                  <span class="icon-[tabler--chart-pie-2] qmuz4"></span>
                  <span class="sxihv">Explainability</span>
                </a>
              </li>
              <!-- Model Monitoring -->
              <li>
                <a href="#" class="rounded-full lmn89">
                  <span class="icon-[tabler--hash] qmuz4"></span>
                  <span class="sxihv">Model Monitoring</span>
                </a>
              </li>
              <!-- User Management -->
              <li class="accordion-item" id="user">
                <button class="accordion-toggle accordion-item-active:bg-white/20 inline-flex items-center rounded-full ao5al text-sm ejsm2 lmn89" aria-controls="user-collapse" aria-expanded="true">
                  <span class="icon-[tabler--arrows-left-right] qmuz4"></span>
                  <span class="sxihv">User Management</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="user-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="user" role="region">
                  <ul class="kf6hd before:bg-white">
                    <!-- Profile -->
                    <li>
                      <a href="#" class="rounded-full lmn89">Profile</a>
                    </li>
                    <!-- Teams -->
                    <li>
                      <a href="#" class="rounded-full lmn89">Teams</a>
                    </li>
                    <!-- Projects -->
                    <li>
                      <a href="#" class="rounded-full lmn89">Projects</a>
                    </li>
                    <!-- Connection -->
                    <li>
                      <a href="#" class="rounded-full lmn89">Connection</a>
                    </li>
                  </ul>
                </div>
              </li>

              <li class="cwnx3 px-3 py-2 text-xs xef6v vxiam">Pages</li>
              <!-- Audit Logs -->
              <li>
                <a href="#" class="rounded-full lmn89">
                  <span class="icon-[tabler--heart-rate-monitor] qmuz4"></span>
                  <span class="sxihv">Audit Logs</span>
                </a>
              </li>
              <!-- Settings -->
              <li>
                <a href="#" class="rounded-full lmn89">
                  <span class="icon-[tabler--settings] qmuz4"></span>
                  <span class="sxihv">Settings</span>
                </a>
              </li>
              <!-- Billings -->
              <li>
                <a href="#" class="rounded-full lmn89">
                  <span class="icon-[tabler--calendar-stats] qmuz4"></span>
                  <span class="sxihv">Billings</span>
                </a>
              </li>
              <!-- Tokens -->
              <li>
                <a href="#" class="rounded-full lmn89">
                  <span class="icon-[tabler--users] qmuz4"></span>
                  <span class="sxihv">Tokens</span>
                </a>
              </li>
              <li class="cwnx3 px-3 py-2 text-xs m8e7z vxiam">Recent Topics</li>
              <!-- Business -->
              <li>
                <a href="#" class="rounded-full lmn89">
                  <span class="icon-[tabler--businessplan] qmuz4"></span>
                  <span class="sxihv">Business</span>
                </a>
              </li>
              <!-- Project Ideas -->
              <li>
                <a href="#" class="rounded-full lmn89">
                  <span class="icon-[tabler--bulb] qmuz4"></span>
                  <span class="sxihv">Project Ideas</span>
                </a>
              </li>
              <!-- Campaigns -->
              <li>
                <a href="#" class="rounded-full lmn89">
                  <span class="icon-[tabler--arrow-back-up] qmuz4"></span>
                  <span class="sxihv">Campaigns</span>
                </a>
              </li>
              <!-- Image Generator -->
              <li>
                <a href="#" class="rounded-full lmn89">
                  <span class="icon-[tabler--image-in-picture] qmuz4"></span>
                  <span class="sxihv">Image Generator</span>
                </a>
              </li>
            </ul>
          </div>
          <div class="os8bl p-3">
            <div class="rounded-box relative hqh7v qr9u1 uzipw i832r">
              <div class="dropdown relative inline-flex w-full [--placement:top] sm:[--offset:40] sm:[--placement:right-end]">
                <button id="user-dropdown" type="button" class="dropdown-toggle flex w-full items-center sly4q" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="nfjpm">
                    <span class="rounded-field lt1t7">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                    </span>
                  </span>

                  <span class="flex e6ynr jz3o6 ao5al">
                    <span class="t3mfo i832r">Caspian Jude</span>
                    <span class="text-sm mjzd3">Team Lead</span>
                  </span>

                  <span class="icon-[tabler--chevron-right] dropdown-open:-rotate-90 size-5 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden v8qk0 adede" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown" tabindex="-1">
                  <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
                    <div class="nfjpm a3rpr">
                      <div class="burs3 rounded-full">
                        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                      </div>
                    </div>
                    <div>
                      <h6 class="text-base-content mb-0.5 t3mfo">Caspian Jude</h6>
                      <p class="text-base-content/80 font-medium">Team Lead</p>
                    </div>
                  </li>
                  <li>
                    <a class="dropdown-item px-3" href="#">
                      <span class="icon-[tabler--user] qmuz4"></span>
                      My account
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item px-3" href="#">
                      <span class="icon-[tabler--settings] qmuz4"></span>
                      Setting
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item px-3" href="#">
                      <span class="icon-[tabler--credit-card] qmuz4"></span>
                      Billing
                    </a>
                  </li>
                  <li>
                    <hr class="border-base-content/20 mjaal zkwo0">
                  </li>
                  <li>
                    <a class="dropdown-item px-3" href="#">
                      <span class="icon-[tabler--users] qmuz4"></span>
                      Manage team
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item px-3" href="#">
                      <span class="icon-[tabler--edit] qmuz4"></span>
                      Customisation
                    </a>
                  </li>
                  <li class="mb-1">
                    <a class="dropdown-item px-3" href="#">
                      <span class="icon-[tabler--circle-plus] qmuz4"></span>
                      Add team account
                    </a>
                  </li>
                  <li class="u9px6 f1870 dhfwm">
                    <a class="btn btn-text gauh6 rhmi6 lxes6 ib2q4 px-3 ejsm2" href="#">
                      <span class="icon-[tabler--logout] qmuz4"></span>
                      Logout
                    </a>
                  </li>
                </ul>
              </div>
              <div>
                <h6 class="text-base t3mfo">825 Tokens Left</h6>
                <p class="text-sm mjzd3">Invite friends and get 50 more</p>
              </div>
              <button class="btn btn-primary rhmi6 btn-sm">
                Get Tokens
                <span class="icon-[tabler--hexagon] size-4"></span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->
    <div class="flex sxihv jz3o6 lg:ps-75">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="wpaot w-full owca9 e6ynr fbpri">
        <div class="dpzny wfsyj ip6vv">
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="bg-base-100">
        <div class="wpaot hg6f0 w-full owca9 rukzz"></div>
      </footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>
  </div>


    <script src="https://flyonui.becdn.net/pro/libs/flyonui/flyonui.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const url = window.location.href

      // Check if the URL contains the "theme" parameter
      const themeParam = new URLSearchParams(window.location.search).get("theme")
      const dirRTL = new URLSearchParams(window.location.search).get("rtl")

      // If a theme parameter is present, apply it to the document
      if (themeParam) {
        document.documentElement.setAttribute("data-theme", themeParam)
      }
      if (dirRTL === "true") {
        document.documentElement.setAttribute("dir", "rtl")
      }
    })
  </script>
  

</body>


<body data-vh-checked="true">
  <div class="dhabr flex min-h-screen jz3o6">
    <!-- ---------- HEADER ---------- -->
    <div class="bg-base-100 sticky top-0 at1sq flex lg:ps-75">
      <div class="wpaot w-full owca9">
        <nav class="hvzi2 eckwz">
          <button type="button" class="btn btn-soft btn-square btn-sm me-2 lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>
        </nav>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 wjz3b e4bmm hidden n85ea c33d9 [--auto-close:lg] sm:w-75 lg:block lg:translate-x-0 lg:shadow-none" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z n85ea cbpaz">
        <div class="flex n85ea w8f5g jz3o6">
          <button type="button" class="btn btn-text btn-circle btn-sm absolute c6rnh vv66w [--btn-color:#fff] lg:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
            <span class="icon-[tabler--x] size-4.5.5"></span>
          </button>
          <div class="flex items-center sly4q a7thv zbjyy bk5oo t3mfo lmn89">
            <div class="rounded-box flex size-8 items-center justify-center qr9u1">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M17.6745 16.9224L12.6233 10.378C12.2167 9.85117 11.4185 9.8611 11.0251 10.3979L6.45728 16.631C6.26893 16.888 5.96935 17.0398 5.65069 17.0398H3.79114C2.9635 17.0398 2.49412 16.0919 2.99583 15.4336L11.0224 4.90319C11.4206 4.38084 12.2056 4.37762 12.608 4.89668L20.9829 15.6987C21.4923 16.3558 21.024 17.3114 20.1926 17.3114H18.4661C18.1562 17.3114 17.8638 17.1677 17.6745 16.9224ZM12.5866 15.5924L14.8956 18.3593C15.439 19.0105 14.976 20 14.1278 20H9.74075C8.9164 20 8.4461 19.0586 8.94116 18.3994L11.0192 15.6325C11.4065 15.1169 12.1734 15.0972 12.5866 15.5924Z" fill="var(--color-neutral-950)"></path>
              </svg>
            </div>
            <span>Healthcare</span>
          </div>
          <div class="n85ea overflow-y-auto">
            <ul class="x737x v85mw rsqkx p-3 qn5kk [--menu-active-bg:white] [--menu-active-fg:black] [--menu-hover-bg:white]/20 [--menu-hover-fg:white]">
              <!-- Dashboard -->
              <li>
                <a href="#" class="rounded-box lmn89">
                  <span class="icon-[tabler--dashboard] qmuz4"></span>
                  <span class="sxihv">Dashboard</span>
                </a>
              </li>

              <!-- Account Management -->
              <li>
                <a href="#" class="oeogr rounded-box lmn89">
                  <span class="icon-[tabler--user] qmuz4"></span>
                  <span class="sxihv">Account</span>
                  <span class="ijn5q o1g2m e6v2p rounded-box">3</span>
                </a>
              </li>

              <!-- Applications -->
              <li class="cwnx3 px-3 py-2 text-xs xef6v vxiam">Applications</li>

              <!-- Patients -->
              <li class="accordion-item" id="patients">
                <button class="accordion-toggle accordion-item-active:bg-white/20 rounded-box inline-flex items-center ao5al text-sm ejsm2 lmn89" aria-controls="patients-collapse" aria-expanded="true">
                  <span class="icon-[tabler--users] qmuz4"></span>
                  <span class="sxihv">Patients</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="patients-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="patients" role="region">
                  <ul class="kf6hd before:bg-white before:opacity-50">
                    <!-- Add Patient -->
                    <li>
                      <a href="#" class="rounded-box lmn89">Add New Patient</a>
                    </li>
                    <!-- Patient List -->
                    <li>
                      <a href="#" class="rounded-box lmn89">View Patient List</a>
                    </li>
                  </ul>
                </div>
              </li>

              <!-- Doctors -->
              <li class="accordion-item" id="doctors">
                <button class="accordion-toggle accordion-item-active:bg-white/20 rounded-box inline-flex items-center ao5al text-sm ejsm2 lmn89" aria-controls="doctors-collapse" aria-expanded="true">
                  <span class="icon-[tabler--calendar-stats] qmuz4"></span>
                  <span class="sxihv">Doctors</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="doctors-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="doctors" role="region">
                  <ul class="kf6hd before:bg-white">
                    <!-- Add Doctor -->
                    <li>
                      <a href="#" class="rounded-box lmn89">Add New Doctor</a>
                    </li>
                    <!-- Doctor List -->
                    <li>
                      <a href="#" class="rounded-box lmn89">View Doctor List</a>
                    </li>
                  </ul>
                </div>
              </li>

              <!-- Schedule -->
              <li class="accordion-item" id="schedules">
                <button class="accordion-toggle accordion-item-active:bg-white/20 rounded-box inline-flex items-center ao5al text-sm ejsm2 lmn89" aria-controls="schedules-collapse" aria-expanded="true">
                  <span class="icon-[tabler--calendar-time] qmuz4"></span>
                  <span class="sxihv">Schedules</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="schedules-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="schedules" role="region">
                  <ul class="kf6hd before:bg-white">
                    <!-- Add Schedule -->
                    <li>
                      <a href="#" class="rounded-box lmn89">Add New Schedule</a>
                    </li>
                    <!-- Schedule List -->
                    <li>
                      <a href="#" class="rounded-box lmn89">View Schedules</a>
                    </li>
                  </ul>
                </div>
              </li>

              <!-- Appointment Management -->
              <li class="cwnx3 px-3 py-2 text-xs xef6v vxiam">Appointments</li>

              <!-- Appointments Section -->
              <li class="accordion-item" id="appointments">
                <button class="accordion-toggle accordion-item-active:bg-white/20 rounded-box inline-flex items-center ao5al text-sm ejsm2 lmn89" aria-controls="appointments-collapse" aria-expanded="true">
                  <span class="icon-[tabler--clock] qmuz4"></span>
                  <span class="sxihv">Manage Appointments</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="appointments-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="appointments" role="region">
                  <ul class="kf6hd before:bg-white">
                    <!-- Add Appointment -->
                    <li>
                      <a href="#" class="rounded-box lmn89">Add New Appointment</a>
                    </li>
                    <!-- Appointment List -->
                    <li>
                      <a href="#" class="rounded-box lmn89">View Appointments</a>
                    </li>
                  </ul>
                </div>
              </li>

              <!-- Reports -->
              <li>
                <a href="#" class="rounded-box lmn89">
                  <span class="icon-[tabler--file-invoice] qmuz4"></span>
                  <span class="sxihv">Reports</span>
                </a>
              </li>

              <!-- Payments -->
              <li>
                <a href="#" class="rounded-box lmn89">
                  <span class="icon-[tabler--file-dollar] qmuz4"></span>
                  <span class="sxihv">Payments</span>
                </a>
              </li>

              <!-- Notifications -->
              <li>
                <a href="#" class="rounded-box lmn89">
                  <span class="icon-[tabler--bell] qmuz4"></span>
                  <span class="sxihv">Notifications</span>
                </a>
              </li>

              <!-- Email Communication -->
              <li>
                <a href="#" class="rounded-box lmn89">
                  <span class="icon-[tabler--mail] qmuz4"></span>
                  <span class="sxihv">Emails</span>
                </a>
              </li>
            </ul>
          </div>
          <div class="os8bl p-3 xzozm">
            <div class="relative flex xtdx9 jz3o6 items-center edy4p hqh7v rounded-t-[8rem] mgiwd f6hal uzipw">
              <div class="relative">
                <img src="https://cdn.flyonui.com/fy-assets/application-shells/image-2.png" alt="brand-logo" class="tzksz">
                <div class="absolute o4bwf afh3x w-full suada lqfar u85bv"></div>
              </div>
              <div class="rdi5h lmn89">
                <h6 class="bk5oo t3mfo">Dr. James Anderson</h6>
                <p class="text-sm">Neurosurgeon</p>
              </div>
              <button class="btn btn-primary rhmi6">
                Schedules
                <span class="icon-[tabler--calendar] size-5"></span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->
    <div class="flex sxihv jz3o6 lg:ps-75">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="wpaot w-full owca9 e6ynr fbpri">
        <div class="dpzny wfsyj ip6vv">
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="bg-base-100">
        <div class="wpaot hg6f0 w-full owca9 rukzz"></div>
      </footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>
  </div>


    <script src="https://flyonui.becdn.net/pro/libs/flyonui/flyonui.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const url = window.location.href

      // Check if the URL contains the "theme" parameter
      const themeParam = new URLSearchParams(window.location.search).get("theme")
      const dirRTL = new URLSearchParams(window.location.search).get("rtl")

      // If a theme parameter is present, apply it to the document
      if (themeParam) {
        document.documentElement.setAttribute("data-theme", themeParam)
      }
      if (dirRTL === "true") {
        document.documentElement.setAttribute("dir", "rtl")
      }
    })
  </script>
  

</body>


<body data-vh-checked="true">
  <div class="dhabr flex min-h-screen jz3o6">
    <!-- ---------- HEADER ---------- -->
    <div class="supports-[backdrop-filter]:bg-base-200/60 fixed top-0 b3b8l vrjgw w-full mask-[linear-gradient(var(--color-base-200),var(--color-base-200)_18%,transparent_100%)] irmyt nslur"></div>
    <div class="sticky top-0 at1sq flex lg:ps-75">
      <div class="wpaot ndnti w-full owca9 rukzz">
        <nav class="hvzi2 rounded-box d50ic eckwz shadow-md">
          <button type="button" class="btn btn-soft btn-square btn-sm me-2 lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>
        </nav>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 wjz3b e4bmm hidden n85ea [--auto-close:lg] lg:block lg:w-75 lg:translate-x-0 lg:shadow-none" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z n85ea cbpaz">
        <div class="flex n85ea w8f5g jz3o6">
          <div class="p-3">
            <div class="dropdown relative inline-flex w-full [--offset:5] [--placement:bottom]">
              <button id="workshop-dropdown" type="button" class="dropdown-toggle dhabr rounded-box flex w-full items-center njdg2 j2be9 mwpft" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="nfjpm">
                  <span class="lt1t7">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dropdown/icon-15.png" alt="flyonui">
                  </span>
                </span>

                <span class="flex e6ynr jz3o6 ao5al">
                  <span class="text-base-content t3mfo">FlyonUI</span>
                  <span class="text-base-content/80 text-sm">Workspace</span>
                </span>
                <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-6 ciihs duration-300"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 vi1oq" role="menu" aria-orientation="vertical" aria-labelledby="workshop-dropdown" tabindex="-1">
                <!-- FlyonUI -->
                <li>
                  <a class="dropdown-item dropdown-active" href="#">
                    <div class="flex items-center sly4q">
                      <div class="nfjpm">
                        <div class="lt1t7">
                          <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dropdown/icon-15.png" alt="flyonui">
                        </div>
                      </div>
                      <div class="e6ynr ao5al">
                        <h6 class="text-base-content t3mfo">FlyonUI</h6>
                        <p class="text-base-content/80 text-sm">Workspace</p>
                      </div>
                    </div>
                  </a>
                </li>
                <!-- ShadCN Studio -->
                <li>
                  <a class="dropdown-item px-3 py-2" href="#">
                    <div class="flex items-center sly4q">
                      <div class="nfjpm">
                        <div class="lt1t7">
                          <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dropdown/icon-16.png" alt="shadcn-studio">
                        </div>
                      </div>
                      <div class="e6ynr ao5al">
                        <h6 class="text-base-content t3mfo">Shadcn/Studio</h6>
                        <p class="text-base-content/80 text-sm">Workspace</p>
                      </div>
                    </div>
                  </a>
                </li>
                <!-- Themeselection -->
                <li>
                  <a class="dropdown-item px-3 py-2" href="#">
                    <div class="flex items-center sly4q">
                      <div class="nfjpm">
                        <div class="lt1t7">
                          <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dropdown/icon-17.png" alt="themeselection">
                        </div>
                      </div>
                      <div class="e6ynr ao5al">
                        <h6 class="text-base-content t3mfo">Themeselection</h6>
                        <p class="text-base-content/80 text-sm">Workspace</p>
                      </div>
                    </div>
                  </a>
                </li>
                <!-- Pixinvent -->
                <li>
                  <a class="dropdown-item px-3 py-2" href="#">
                    <div class="flex items-center sly4q">
                      <div class="nfjpm">
                        <div class="lt1t7">
                          <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dropdown/icon-18.png" alt="pixinvent">
                        </div>
                      </div>
                      <div class="e6ynr ao5al">
                        <h6 class="text-base-content t3mfo">Pixinvent</h6>
                        <p class="text-base-content/80 text-sm">Workspace</p>
                      </div>
                    </div>
                  </a>
                </li>
                <!-- Add Workspace -->
                <li>
                  <a class="btn btn-primary btn-soft rhmi6" href="#">
                    Add New Workspace
                    <span class="icon-[tabler--plus] size-5"></span>
                  </a>
                </li>
              </ul>
            </div>
          </div>
          <div class="n85ea overflow-y-auto">
            <ul class="x737x v85mw rsqkx px-3 nijmi">
              <!-- Dashboard -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--dashboard] qmuz4"></span>
                  Dashboard
                </a>
              </li>
              <li class="text-base-content/50 cwnx3 f1870 text-xs vxiam">Pages</li>

              <!-- Backlog -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--checkbox] qmuz4"></span>
                  Backlog
                </a>
              </li>

              <!-- Iterations -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--list-details] qmuz4"></span>
                  Iterations
                </a>
              </li>

              <!-- Milestones -->
              <li>
                <a href="#" class="oeogr px-2">
                  <span class="icon-[tabler--crown] qmuz4"></span>
                  Milestones
                </a>
              </li>

              <!-- Bug Tracker -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--bug] qmuz4"></span>
                  Bug Tracker
                </a>
              </li>

              <!-- Design Assets -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--folders] qmuz4"></span>
                  Design Assets
                </a>
              </li>

              <!-- Release Notes -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--note] qmuz4"></span>
                  Release Notes
                </a>
              </li>

              <!-- Campaign Calendar -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--calendar] qmuz4"></span>
                  Campaign Calendar
                </a>
              </li>

              <!-- Ad Performance -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--chart-bar] qmuz4"></span>
                  Ad Performance
                </a>
              </li>
            </ul>
          </div>
          <div class="os8bl p-3">
            <div class="rounded-box border-base-content/20 relative hqh7v border uzipw">
              <h6 class="text-base-content font-medium">Upgrade Your Plan</h6>
              <p class="text-base-content/80 text-sm">
                Your trial plan ends in 12 days. Upgrade your plan and unlock full potential!
              </p>
              <div class="progress h-2 w-full" role="progressbar" aria-label="Primary Progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100">
                <div class="progress-bar progress-primary myoiz"></div>
              </div>
              <button class="btn btn-primary rhmi6 btn-sm">See All Plans</button>
            </div>
          </div>
        </div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->

    <div class="flex sxihv jz3o6 lg:ps-75">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="wpaot w-full owca9 e6ynr sxihv fbpri">
        <div class="dpzny wfsyj ip6vv">
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="wpaot w-full owca9 rukzz">
        <div class="bg-base-100 fwpqz hg6f0"></div>
      </footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>
  </div>


    <script src="https://flyonui.becdn.net/pro/libs/flyonui/flyonui.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const url = window.location.href

      // Check if the URL contains the "theme" parameter
      const themeParam = new URLSearchParams(window.location.search).get("theme")
      const dirRTL = new URLSearchParams(window.location.search).get("rtl")

      // If a theme parameter is present, apply it to the document
      if (themeParam) {
        document.documentElement.setAttribute("data-theme", themeParam)
      }
      if (dirRTL === "true") {
        document.documentElement.setAttribute("dir", "rtl")
      }
    })
  </script>
  

</body>

<body data-vh-checked="true">
  <div class="dhabr flex min-h-screen jz3o6">
    <!-- ---------- HEADER ---------- -->
    <div class="supports-[backdrop-filter]:bg-base-200/60 fixed top-0 b3b8l vrjgw w-full mask-[linear-gradient(var(--color-base-200),var(--color-base-200)_18%,transparent_100%)] irmyt nslur"></div>
    <div class="sticky top-0 at1sq flex lg:ps-81">
      <div class="wpaot ndnti w-full owca9 rukzz">
        <nav class="hvzi2 rounded-box d50ic eckwz shadow-md">
          <button type="button" class="btn btn-soft btn-square btn-sm me-2 lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>
        </nav>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 lg:rounded-box fixed wjz3b e4bmm hidden n85ea [--auto-close:lg] sm:w-75 lg:my-auto lg:block lg:max-h-[calc(100dvh-48px)] lg:translate-x-6 lg:overflow-hidden rtl:lg:-translate-x-6" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z n85ea cbpaz">
        <div class="flex n85ea w8f5g jz3o6">
          <button type="button" class="btn btn-text btn-circle btn-sm absolute c6rnh vv66w lg:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
            <span class="icon-[tabler--x] qmuz4"></span>
          </button>
          <div class="flex items-center sly4q a7thv mwpft">
            <span class="text-primary">
              <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clip-path="url(#a)">
                  <mask id="b" style="mask-type:luminance" maskUnits="userSpaceOnUse" x="0" y="0" width="32" height="32">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="#fff"></path>
                  </mask>
                  <g mask="url(#b)">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="currentColor"></path>
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="url(#c)"></path>
                    <path fill-rule="evenodd" clip-rule="evenodd" d="m22.258 20.467-5.55-6.839a1 1 0 0 0-1.568.02l-5.023 6.521a1 1 0 0 1-.793.39H7.17a1 1 0 0 1-.78-1.626l8.748-10.919a1 1 0 0 1 1.556-.006l9.125 11.198a1 1 0 0 1-.775 1.631h-2.01a1 1 0 0 1-.776-.37m-5.59-1.484 2.59 2.953c.567.646.108 1.659-.751 1.659h-4.922a1 1 0 0 1-.785-1.62l2.331-2.953a1 1 0 0 1 1.537-.04" fill="url(#d)"></path>
                  </g>
                  <path d="M24 .666H8A7.333 7.333 0 0 0 .667 8v16A7.333 7.333 0 0 0 8 31.333h16A7.333 7.333 0 0 0 31.334 24V8A7.333 7.333 0 0 0 24 .666Z" stroke="url(#e)" stroke-width="2"></path>
                </g>
                <defs>
                  <linearGradient id="c" x1="29" y1="2" x2="3" y2="29.5" gradientUnits="userSpaceOnUse">
                    <stop stop-opacity="0"></stop>
                    <stop offset="1" stop-opacity=".38"></stop>
                  </linearGradient>
                  <linearGradient id="d" x1="16.107" y1="7.64" x2="16.107" y2="23.595" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".6"></stop>
                  </linearGradient>
                  <linearGradient id="e" x1="16" y1="0" x2="16" y2="32" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff" stop-opacity=".28"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".04"></stop>
                  </linearGradient>
                  <clipPath id="a">
                    <path fill="#fff" d="M0 0h32v32H0z"></path>
                  </clipPath>
                </defs>
              </svg>
            </span>
            <div>
              <span class="text-base-content block bk5oo fl9z1">Analytics</span>
            </div>
          </div>
          <div class="n85ea overflow-y-auto">
            <ul class="x737x v85mw rsqkx p-3 qn5kk">
              <!-- Dashboard -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--dashboard] qmuz4"></span>
                  <span class="sxihv">Dashboard</span>
                </a>
              </li>
              <li class="text-base-content/50 cwnx3 f1870 text-xs vxiam">Core Pages</li>
              <!-- User Behavior -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--user] qmuz4"></span>
                  <span class="sxihv">User Behavior</span>
                </a>
              </li>
              <!-- Audience -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--users] qmuz4"></span>
                  <span class="sxihv">Audience</span>
                </a>
              </li>
              <!-- Traffic Sources -->
              <li>
                <a href="#" class="oeogr px-2">
                  <span class="icon-[tabler--trending-up] qmuz4"></span>
                  <span class="sxihv">Traffic Sources</span>
                </a>
              </li>
              <!-- Conversion Funnel -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--currency-dollar] qmuz4"></span>
                  <span class="sxihv">Conversion Funnel</span>
                  <span class="ijn5q o1g2m pze98 rounded-full">2</span>
                </a>
              </li>
              <!-- Engagement Metrics -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--chart-bar] qmuz4"></span>
                  <span class="sxihv">Engagement Metrics</span>
                </a>
              </li>
              <!-- Custom Reports -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--report-analytics] qmuz4"></span>
                  <span class="sxihv">Custom Reports</span>
                </a>
              </li>
              <!-- Error Logs -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--alert-triangle] qmuz4"></span>
                  <span class="sxihv">Error Logs</span>
                </a>
              </li>
              <!-- Survey Results -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--checkbox] qmuz4"></span>
                  <span class="sxihv">Survey Results</span>
                </a>
              </li>
              <li class="text-base-content/50 cwnx3 f1870 text-xs vxiam">Core Pages</li>
              <!-- Help Center  -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--help] qmuz4"></span>
                  <span class="sxihv">Help Center</span>
                </a>
              </li>
              <!-- Product List -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--list-check] qmuz4"></span>
                  <span class="sxihv">Product List</span>
                </a>
              </li>
              <!-- Customer Management -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--users] qmuz4"></span>
                  <span class="sxihv">Customer Management</span>
                </a>
              </li>
              <!-- Billing & Payment Reports -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--file-invoice] qmuz4"></span>
                  <span class="sxihv">Billing &amp; Payment Reports</span>
                </a>
              </li>
              <!-- Feedback & Reviews -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--star] qmuz4"></span>
                  <span class="sxihv">Feedback &amp; Reviews</span>
                </a>
              </li>
              <li class="text-base-content/50 cwnx3 f1870 text-xs vxiam">Visualization</li>
              <!-- Data Export -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--external-link] qmuz4"></span>
                  <span class="sxihv">Data Export</span>
                </a>
              </li>
              <!-- Integrations -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--link] qmuz4"></span>
                  <span class="sxihv">Integrations</span>
                </a>
              </li>
            </ul>
          </div>
          <div class="os8bl j2be9 mrpnf">
            <div class="rounded-box jgsta relative hqh7v uzipw">
              <h6 class="bk5oo t3mfo">Go to Premium</h6>
              <p>Explore 600+ course with lifetime membership</p>
              <button class="btn btn-primary">Upgrade</button>
            </div>
          </div>
        </div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->

    <div class="flex sxihv jz3o6 fyl79 lg:ps-81">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="wpaot w-full owca9 e6ynr sxihv fbpri">
        <div class="dpzny wfsyj ip6vv">
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="wpaot w-full owca9 rukzz">
        <div class="bg-base-100 rounded-box d50ic hg6f0 shadow-md"></div>
      </footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>
  </div>


    <script src="https://flyonui.becdn.net/pro/libs/flyonui/flyonui.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const url = window.location.href

      // Check if the URL contains the "theme" parameter
      const themeParam = new URLSearchParams(window.location.search).get("theme")
      const dirRTL = new URLSearchParams(window.location.search).get("rtl")

      // If a theme parameter is present, apply it to the document
      if (themeParam) {
        document.documentElement.setAttribute("data-theme", themeParam)
      }
      if (dirRTL === "true") {
        document.documentElement.setAttribute("dir", "rtl")
      }
    })
  </script>
  

</body>


<body data-vh-checked="true">
  <div class="dhabr flex min-h-screen jz3o6">
    <!-- ---------- HEADER ---------- -->
    <div class="bg-base-100 sticky top-0 at1sq flex sm:ps-17">
      <div class="wpaot w-full">
        <nav class="hvzi2 eckwz">
          <button type="button" class="btn btn-soft btn-square btn-sm me-2 sm:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>
        </nav>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 wjz3b e4bmm hidden n85ea [--auto-close:sm] sm:block sm:w-17 sm:translate-x-0 sm:shadow-none" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z border-base-content/20 n85ea jawf4 cbpaz">
        <div class="flex n85ea w8f5g jz3o6">
          <button type="button" class="btn btn-text btn-circle btn-sm absolute c6rnh vv66w sm:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
            <span class="icon-[tabler--x] size-5"></span>
          </button>
          <div class="flex items-center sly4q j2be9 zbjyy sm:justify-center sm:px-2">
            <span class="text-primary">
              <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clip-path="url(#a)">
                  <mask id="b" style="mask-type:luminance" maskUnits="userSpaceOnUse" x="0" y="0" width="32" height="32">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="#fff"></path>
                  </mask>
                  <g mask="url(#b)">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="currentColor"></path>
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="url(#c)"></path>
                    <path fill-rule="evenodd" clip-rule="evenodd" d="m22.258 20.467-5.55-6.839a1 1 0 0 0-1.568.02l-5.023 6.521a1 1 0 0 1-.793.39H7.17a1 1 0 0 1-.78-1.626l8.748-10.919a1 1 0 0 1 1.556-.006l9.125 11.198a1 1 0 0 1-.775 1.631h-2.01a1 1 0 0 1-.776-.37m-5.59-1.484 2.59 2.953c.567.646.108 1.659-.751 1.659h-4.922a1 1 0 0 1-.785-1.62l2.331-2.953a1 1 0 0 1 1.537-.04" fill="url(#d)"></path>
                  </g>
                  <path d="M24 .666H8A7.333 7.333 0 0 0 .667 8v16A7.333 7.333 0 0 0 8 31.333h16A7.333 7.333 0 0 0 31.334 24V8A7.333 7.333 0 0 0 24 .666Z" stroke="url(#e)" stroke-width="2"></path>
                </g>
                <defs>
                  <linearGradient id="c" x1="29" y1="2" x2="3" y2="29.5" gradientUnits="userSpaceOnUse">
                    <stop stop-opacity="0"></stop>
                    <stop offset="1" stop-opacity=".38"></stop>
                  </linearGradient>
                  <linearGradient id="d" x1="16.107" y1="7.64" x2="16.107" y2="23.595" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".6"></stop>
                  </linearGradient>
                  <linearGradient id="e" x1="16" y1="0" x2="16" y2="32" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff" stop-opacity=".28"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".04"></stop>
                  </linearGradient>
                  <clipPath id="a">
                    <path fill="#fff" d="M0 0h32v32H0z"></path>
                  </clipPath>
                </defs>
              </svg>
            </span>
            <div class="sm:hidden">
              <span class="text-base-content block bk5oo fl9z1">FlyonUI</span>
              <span class="text-base-content/50 block text-xs">Dashboard Template</span>
            </div>
          </div>
          <div class="n85ea overflow-y-auto [scrollbar-width:none]">
            <!-- ---------- Menu for larger screen ---------- -->
            <ul class="x737x v85mw relative rsqkx px-3 egd50 max-sm:hidden">
              <!-- Dashboard -->
              <li class="tooltip [--placement:right]">
                <a href="#" class="tooltip-toggle flex zv497 items-center justify-center cbpaz" aria-label="Dashboard">
                  <span class="icon-[tabler--dashboard] size-6"></span>
                </a>
                <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 54px; top: 79px;">
                  <span class="tnsaf">Dashboard</span>
                </span>
              </li>

              <!-- Booking -->
              <li class="tooltip [--placement:right]">
                <a href="#" class="tooltip-toggle flex zv497 items-center justify-center cbpaz" aria-label="Booking">
                  <span class="icon-[tabler--calendar] size-6"></span>
                </a>
                <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 54px; top: 125px;">
                  <span class="tnsaf">Booking</span>
                </span>
              </li>

              <!-- Search Location -->
              <li class="tooltip [--placement:right]">
                <a href="#" class="tooltip-toggle flex zv497 items-center justify-center cbpaz" aria-label="Search Location">
                  <span class="icon-[tabler--map-pin] size-6"></span>
                </a>
                <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 54px; top: 171px;">
                  <span class="tnsaf">Search Location</span>
                </span>
              </li>
              <li class="ck7pw wpaot lgvb8 t6d3t"></li>

              <li class="tooltip [--placement:right]">
                <a href="#" class="tooltip-toggle flex zv497 items-center justify-center cbpaz" aria-label="Hotel Booking">
                  <span class="icon-[tabler--home] size-6"></span>
                </a>
                <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 54px; top: 266px;">
                  <span class="tnsaf">Hotel Booking</span>
                </span>
              </li>

              <li class="tooltip [--placement:right]">
                <a href="#" class="tooltip-toggle flex zv497 items-center justify-center cbpaz" aria-label="Flight Booking">
                  <span class="icon-[tabler--plane] size-6"></span>
                </a>
                <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 54px; top: 312px;">
                  <span class="tnsaf">Flight Booking</span>
                </span>
              </li>

              <li class="tooltip [--placement:right]">
                <a href="#" class="tooltip-toggle flex zv497 items-center justify-center cbpaz" aria-label="Bus Booking">
                  <span class="icon-[tabler--bus] size-6"></span>
                </a>
                <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 54px; top: 358px;">
                  <span class="tnsaf">Bus Booking</span>
                </span>
              </li>

              <li class="tooltip [--placement:right]">
                <a href="#" class="tooltip-toggle flex zv497 items-center justify-center cbpaz" aria-label="Car Booking">
                  <span class="icon-[tabler--car] size-6"></span>
                </a>
                <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 54px; top: 404px;">
                  <span class="tnsaf">Car Booking</span>
                </span>
              </li>

              <li class="tooltip [--placement:right]">
                <a href="#" class="tooltip-toggle flex zv497 items-center justify-center cbpaz" aria-label="Train Booking">
                  <span class="icon-[tabler--train] size-6"></span>
                </a>
                <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 54px; top: 450px;">
                  <span class="tnsaf">Train Booking</span>
                </span>
              </li>

              <li class="tooltip [--placement:right]">
                <a href="#" class="tooltip-toggle flex zv497 items-center justify-center cbpaz" aria-label="Ship Booking">
                  <span class="icon-[tabler--ship] size-6"></span>
                </a>
                <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 54px; top: 496px;">
                  <span class="tnsaf">Ship Booking</span>
                </span>
              </li>

              <li class="ck7pw wpaot lgvb8 t6d3t"></li>
              <!-- Offers -->
              <li class="tooltip [--placement:right]">
                <a href="#" class="tooltip-toggle flex zv497 items-center justify-center cbpaz" aria-label="Offers">
                  <span class="icon-[tabler--tags] size-6"></span>
                </a>
                <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 54px; top: 591px;">
                  <span class="tnsaf">Offers</span>
                </span>
              </li>

              <!-- User (Dropdown) -->
              <li>
                <div class="dropdown relative inline-flex cbpaz [--auto-close:inside] [--offset:15] [--placement:right-start] [--trigger:hover]">
                  <button id="dropdown-user" type="button" class="dropdown-toggle" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                    <span class="rounded-field transition-color flex zv497 ji7zy items-center justify-center duration-300">
                      <span class="icon-[tabler--users] size-6"></span>
                    </span>
                  </button>
                  <ul class="dropdown-menu d50ic dropdown-open:opacity-100 g8w3k hidden i11xm shadow-lg before:absolute before:-start-4 before:top-0 before:h-full before:w-4 before:bg-transparent" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-user" tabindex="-1">
                    <li><a class="dropdown-item" href="#">User Profile</a></li>
                    <li><a class="dropdown-item" href="#">User Settings</a></li>
                    <li><a class="dropdown-item" href="#">Your Trips</a></li>
                  </ul>
                </div>
              </li>

              <!-- Settings (Tooltip) -->
              <li class="tooltip [--placement:right]">
                <a href="#" class="tooltip-toggle oeogr flex zv497 items-center justify-center cbpaz" aria-label="Settings">
                  <span class="icon-[tabler--settings] size-6"></span>
                </a>
                <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 54px; top: 683px;">
                  <span class="tnsaf">Settings</span>
                </span>
              </li>

              <!-- Wallet (Tooltip) -->
              <li class="tooltip [--placement:right]">
                <a href="#" class="tooltip-toggle flex zv497 items-center justify-center cbpaz" aria-label="Wallet">
                  <span class="icon-[tabler--wallet] size-6"></span>
                </a>
                <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 54px; top: 729px;">
                  <span class="tnsaf">Wallet</span>
                </span>
              </li>
            </ul>
            <!-- ---------- Menu for smaller screen ---------- -->
            <ul class="accordion x737x v85mw rsqkx p-3 sm:hidden">
              <!-- Dashboard -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--dashboard] size-5"></span>
                  Dashboard
                </a>
              </li>
              <!-- Hotel Booking -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--calendar] size-5"></span>
                  Hotel Booking
                </a>
              </li>
              <!-- Search Location -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--map-pin] size-5"></span>
                  Search Location
                </a>
              </li>

              <li class="text-base-content/50 cwnx3 f1870 text-xs vxiam">Modes of Travel</li>

              <!-- Hotel Booking -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--home] size-5"></span>
                  Hotel Booking
                </a>
              </li>

              <!-- Flight Booking -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--plane] size-5"></span>
                  Flight Booking
                </a>
              </li>

              <!-- Bus Booking -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--bus] size-5"></span>
                  Bus Booking
                </a>
              </li>

              <!-- Car Booking -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--car] size-5"></span>
                  Car Booking
                </a>
              </li>

              <!-- Train Booking -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--train] size-5"></span>
                  Train Booking
                </a>
              </li>

              <!-- Ship Booking -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--ship] size-5"></span>
                  Ship Booking
                </a>
              </li>
              <li class="text-base-content/50 cwnx3 f1870 text-xs vxiam">More Options</li>

              <!-- Offer -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--tags] size-5"></span>
                  Offer
                </a>
              </li>

              <!-- User -->
              <li class="accordion-item" id="user">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="user-collapse" aria-expanded="true">
                  <span class="icon-[tabler--user] size-5"></span>
                  <span class="sxihv">User</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 size-5 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="user-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="user" role="region">
                  <ul class="kf6hd">
                    <!-- User Profile -->
                    <li>
                      <a href="#" class="px-2">User Profile</a>
                    </li>
                    <!-- User Settings -->
                    <li>
                      <a href="#" class="px-2">User Settings</a>
                    </li>
                    <!-- Your Trips -->
                    <li>
                      <a href="#" class="px-2">Your Trips</a>
                    </li>
                  </ul>
                </div>
              </li>

              <!-- Settings -->
              <li>
                <a href="#" class="oeogr px-2">
                  <span class="icon-[tabler--settings] size-5"></span>
                  Settings
                </a>
              </li>
              <!-- wallet -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--wallet] size-5"></span>
                  wallet
                </a>
              </li>
            </ul>
          </div>
          <div class="os8bl flex items-center justify-center px-3 egd50 sm:h-50">
            <button class="btn btn-primary max-sm:btn-block sm:origin-center sm:-rotate-90">Book Now</button>
          </div>
        </div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->

    <div class="flex sxihv jz3o6 sm:ps-17">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="e6ynr fbpri">
        <div class="dpzny wfsyj ip6vv md:grid-cols-2">
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="bg-base-100 hg6f0 qzwp2 rukzz"></footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>
  </div>


    <script src="https://flyonui.becdn.net/pro/libs/flyonui/flyonui.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const url = window.location.href

      // Check if the URL contains the "theme" parameter
      const themeParam = new URLSearchParams(window.location.search).get("theme")
      const dirRTL = new URLSearchParams(window.location.search).get("rtl")

      // If a theme parameter is present, apply it to the document
      if (themeParam) {
        document.documentElement.setAttribute("data-theme", themeParam)
      }
      if (dirRTL === "true") {
        document.documentElement.setAttribute("dir", "rtl")
      }
    })
  </script>
  

</body>


<body data-vh-checked="true">
  <div class="dhabr flex min-h-screen jz3o6">
    <!-- ---------- HEADER ---------- -->
    <div class="bg-base-100 sticky top-0 at1sq flex lg:ps-87">
      <div class="wpaot w-full">
        <nav class="hvzi2 eckwz">
          <button type="button" class="btn btn-soft btn-square btn-sm me-2 lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>
        </nav>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 wjz3b e4bmm hidden n85ea [--auto-close:lg] sm:w-87 lg:block lg:translate-x-0 lg:shadow-none" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z flex n85ea cbpaz">
        <!-- MINI SIDEBAR -->
        <div class="n85ea w8f5g oun33 c33d9">
          <div class="flex items-center justify-center sly4q px-2 zbjyy">
            <span class="text-primary">
              <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clip-path="url(#a)">
                  <mask id="b" style="mask-type:luminance" maskUnits="userSpaceOnUse" x="0" y="0" width="32" height="32">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="#fff"></path>
                  </mask>
                  <g mask="url(#b)">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="currentColor"></path>
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="url(#c)"></path>
                    <path fill-rule="evenodd" clip-rule="evenodd" d="m22.258 20.467-5.55-6.839a1 1 0 0 0-1.568.02l-5.023 6.521a1 1 0 0 1-.793.39H7.17a1 1 0 0 1-.78-1.626l8.748-10.919a1 1 0 0 1 1.556-.006l9.125 11.198a1 1 0 0 1-.775 1.631h-2.01a1 1 0 0 1-.776-.37m-5.59-1.484 2.59 2.953c.567.646.108 1.659-.751 1.659h-4.922a1 1 0 0 1-.785-1.62l2.331-2.953a1 1 0 0 1 1.537-.04" fill="url(#d)"></path>
                  </g>
                  <path d="M24 .666H8A7.333 7.333 0 0 0 .667 8v16A7.333 7.333 0 0 0 8 31.333h16A7.333 7.333 0 0 0 31.334 24V8A7.333 7.333 0 0 0 24 .666Z" stroke="url(#e)" stroke-width="2"></path>
                </g>
                <defs>
                  <linearGradient id="c" x1="29" y1="2" x2="3" y2="29.5" gradientUnits="userSpaceOnUse">
                    <stop stop-opacity="0"></stop>
                    <stop offset="1" stop-opacity=".38"></stop>
                  </linearGradient>
                  <linearGradient id="d" x1="16.107" y1="7.64" x2="16.107" y2="23.595" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".6"></stop>
                  </linearGradient>
                  <linearGradient id="e" x1="16" y1="0" x2="16" y2="32" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff" stop-opacity=".28"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".04"></stop>
                  </linearGradient>
                  <clipPath id="a">
                    <path fill="#fff" d="M0 0h32v32H0z"></path>
                  </clipPath>
                </defs>
              </svg>
            </span>
          </div>
          <ul class="flex jz3o6 items-center sly4q p-4">
            <!-- Dashboard -->
            <li class="tooltip rounded-field has-[.link-active]:border-primary has-[.link-active]:bg-primary j8wvb qu24g lmn89 [--placement:right] hover:bg-neutral-700">
              <a href="#" class="tooltip-toggle flex lt1t7 items-center justify-center" aria-label="Home Link">
                <span class="icon-[solar--pie-chart-2-bold-duotone] girx5"></span>
              </a>
              <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 0px; top: 0px;">
                <span class="tnsaf">dashboard</span>
              </span>
            </li>
            <!-- Projects -->
            <li class="tooltip rounded-field has-[.link-active]:border-primary has-[.link-active]:bg-primary j8wvb qu24g lmn89 [--placement:right] hover:bg-neutral-700">
              <a href="#" class="tooltip-toggle u97gy flex lt1t7 items-center justify-center" aria-label="Home Link">
                <span class="icon-[solar--card-bold-duotone] girx5"></span>
              </a>
              <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 0px; top: 0px;">
                <span class="tnsaf">Projects</span>
              </span>
            </li>
            <!-- Task Board -->
            <li class="tooltip rounded-field has-[.link-active]:border-primary has-[.link-active]:bg-primary j8wvb qu24g lmn89 [--placement:right] hover:bg-neutral-700">
              <a href="#" class="tooltip-toggle flex lt1t7 items-center justify-center" aria-label="Home Link">
                <span class="icon-[solar--clipboard-check-bold-duotone] girx5"></span>
              </a>
              <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 0px; top: 0px;">
                <span class="tnsaf">Task Board</span>
              </span>
            </li>
            <!-- Calendar -->
            <li class="tooltip rounded-field has-[.link-active]:border-primary has-[.link-active]:bg-primary j8wvb qu24g lmn89 [--placement:right] hover:bg-neutral-700">
              <a href="#" class="tooltip-toggle flex lt1t7 items-center justify-center" aria-label="Home Link">
                <span class="icon-[solar--calendar-bold-duotone] girx5"></span>
              </a>
              <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 0px; top: 0px;">
                <span class="tnsaf">Calendar</span>
              </span>
            </li>
            <!-- Team Members -->
            <li class="tooltip rounded-field has-[.link-active]:border-primary has-[.link-active]:bg-primary j8wvb qu24g lmn89 [--placement:right] hover:bg-neutral-700">
              <a href="#" class="tooltip-toggle flex lt1t7 items-center justify-center" aria-label="Home Link">
                <span class="icon-[solar--users-group-two-rounded-bold-duotone] girx5"></span>
              </a>
              <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 0px; top: 0px;">
                <span class="tnsaf">Team Members</span>
              </span>
            </li>
            <!-- Files & Documents -->
            <li class="tooltip rounded-field has-[.link-active]:border-primary has-[.link-active]:bg-primary j8wvb qu24g lmn89 [--placement:right] hover:bg-neutral-700">
              <a href="#" class="tooltip-toggle flex lt1t7 items-center justify-center" aria-label="Home Link">
                <span class="icon-[solar--folder-2-bold-duotone] girx5"></span>
              </a>
              <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible gvrdp" role="tooltip" style="position: fixed; left: 0px; top: 0px;">
                <span class="tnsaf">Files &amp; Documents</span>
              </span>
            </li>
          </ul>
        </div>
        <!-- SECONDARY SIDEBAR -->
        <div class="border-base-content/20 w-full jawf4">
          <button type="button" class="btn btn-text btn-circle btn-sm absolute c6rnh vv66w lg:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
            <span class="icon-[tabler--x] qmuz4"></span>
          </button>
          <div class="flex n85ea w8f5g jz3o6">
            <div class="text-base-content rukzz zbjyy bk5oo t3mfo">Projects</div>
            <div class="n85ea overflow-y-auto">
              <ul class="accordion x737x v85mw rsqkx j2be9 nijmi">
                <!-- Dashboard -->
                <li class="cwnx3">
                  <a href="#" class="px-2">
                    <span class="icon-[tabler--chart-bar] qmuz4"></span>
                    Dashboard
                  </a>
                </li>
                <li class="text-base-content/50 cwnx3 f1870 text-xs vxiam">Pages</li>
                <!-- Content Performance -->
                <li>
                  <a href="#" class="px-2">
                    <span class="icon-[tabler--trending-up] qmuz4"></span>
                    Project progress
                  </a>
                </li>
                <!-- Key milestones -->
                <li>
                  <a href="#" class="px-2">
                    <span class="icon-[tabler--checkbox] qmuz4"></span>
                    Key milestones
                  </a>
                </li>
                <!-- Overdue tasks -->
                <li>
                  <a href="#" class="oeogr px-2">
                    <span class="icon-[tabler--alert-triangle] qmuz4"></span>
                    Overdue tasks
                  </a>
                </li>
                <!-- Team list with roles -->
                <li>
                  <a href="#" class="px-2">
                    <span class="icon-[tabler--users] qmuz4"></span>
                    Team list with roles
                  </a>
                </li>
                <!-- File manager -->
                <li>
                  <a href="#" class="px-2">
                    <span class="icon-[tabler--folders] qmuz4"></span>
                    File manager
                  </a>
                </li>
                <!-- Recent updates -->
                <li>
                  <a href="#" class="px-2">
                    <span class="icon-[tabler--notification] qmuz4"></span>
                    <span class="sxihv">Recent updates</span>
                    <span class="ijn5q o1g2m pze98 rounded-full">3</span>
                  </a>
                </li>
                <!-- Milestones -->
                <li>
                  <a href="#" class="px-2">
                    <span class="icon-[tabler--list-check] qmuz4"></span>
                    Milestones
                  </a>
                </li>
                <!-- Deadlines -->
                <li>
                  <a href="#" class="px-2">
                    <span class="icon-[tabler--alert-octagon] qmuz4"></span>
                    Deadlines
                  </a>
                </li>
                <li class="text-base-content/50 cwnx3 f1870 text-xs vxiam">Completed Projects</li>
                <!-- Website Redesign for Z Corp -->
                <li>
                  <a href="#" class="dh3pr px-2">
                    <span class="icon-[tabler--circle-filled] text-base-content/50 y3l6l"></span>
                    Website Redesign for Z Corp
                  </a>
                </li>
                <!-- Mobile App Launch – TaskPro -->
                <li>
                  <a href="#" class="dh3pr px-2">
                    <span class="icon-[tabler--circle-filled] text-base-content/50 group-[.menu-active]:text-primary y3l6l"></span>
                    Mobile App Launch – TaskPro
                  </a>
                </li>
                <!-- Internal Tool for HRMS -->
                <li>
                  <a href="#" class="dh3pr px-2">
                    <span class="icon-[tabler--circle-filled] text-base-content/50 group-[.menu-active]:text-primary y3l6l"></span>
                    Internal Tool for HRMS
                  </a>
                </li>
                <!-- Marketing Campaign -->
                <li>
                  <a href="#" class="dh3pr px-2">
                    <span class="icon-[tabler--circle-filled] text-base-content/50 group-[.menu-active]:text-primary y3l6l"></span>
                    Marketing Campaign
                  </a>
                </li>
                <!-- Feedback System Integration -->
                <li>
                  <a href="#" class="dh3pr px-2">
                    <span class="icon-[tabler--circle-filled] text-base-content/50 group-[.menu-active]:text-primary y3l6l"></span>
                    Feedback System Integration
                  </a>
                </li>
                <!-- Cybersecurity Audit -->
                <li>
                  <a href="#" class="dh3pr px-2">
                    <span class="icon-[tabler--circle-filled] text-base-content/50 group-[.menu-active]:text-primary y3l6l"></span>
                    Cybersecurity Audit
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->

    <div class="flex sxihv jz3o6 lg:ps-87">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="e6ynr fbpri">
        <div class="dpzny wfsyj ip6vv md:grid-cols-2">
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full md:col-span-2">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="bg-base-100 hg6f0 qzwp2 rukzz"></footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>
  </div>


    <script src="https://flyonui.becdn.net/pro/libs/flyonui/flyonui.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const url = window.location.href

      // Check if the URL contains the "theme" parameter
      const themeParam = new URLSearchParams(window.location.search).get("theme")
      const dirRTL = new URLSearchParams(window.location.search).get("rtl")

      // If a theme parameter is present, apply it to the document
      if (themeParam) {
        document.documentElement.setAttribute("data-theme", themeParam)
      }
      if (dirRTL === "true") {
        document.documentElement.setAttribute("dir", "rtl")
      }
    })
  </script>
  

</body>


<body data-vh-checked="true">
  <div class="dhabr flex min-h-screen jz3o6">
    <!-- ---------- HEADER ---------- -->
    <div class="supports-[backdrop-filter]:bg-base-200/60 fixed top-0 b3b8l vrjgw w-full mask-[linear-gradient(var(--color-base-200),var(--color-base-200)_18%,transparent_100%)] irmyt nslur"></div>
    <div class="sticky top-0 at1sq flex lg:ps-65">
      <div class="wpaot ndnti w-full owca9 rukzz">
        <nav class="hvzi2 rounded-box d50ic eckwz shadow-md">
          <button type="button" class="btn btn-soft btn-square btn-sm me-2 lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>
        </nav>
      </div>
    </div>

    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 wjz3b e4bmm hidden n85ea [--auto-close:lg] sm:w-65 lg:z-50 lg:block lg:translate-x-0" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z n85ea cbpaz">
        <div class="flex n85ea w8f5g jz3o6">
          <button type="button" class="btn btn-text btn-circle btn-sm absolute c6rnh vv66w lg:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
            <span class="icon-[tabler--x] qmuz4"></span>
          </button>
          <div class="flex items-center sly4q j2be9 py-2">
            <span class="text-primary">
              <svg width="34" height="34" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clip-path="url(#a)">
                  <mask id="b" style="mask-type:luminance" maskUnits="userSpaceOnUse" x="0" y="0" width="32" height="32">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="#fff"></path>
                  </mask>
                  <g mask="url(#b)">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="currentColor"></path>
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="url(#c)"></path>
                    <path fill-rule="evenodd" clip-rule="evenodd" d="m22.258 20.467-5.55-6.839a1 1 0 0 0-1.568.02l-5.023 6.521a1 1 0 0 1-.793.39H7.17a1 1 0 0 1-.78-1.626l8.748-10.919a1 1 0 0 1 1.556-.006l9.125 11.198a1 1 0 0 1-.775 1.631h-2.01a1 1 0 0 1-.776-.37m-5.59-1.484 2.59 2.953c.567.646.108 1.659-.751 1.659h-4.922a1 1 0 0 1-.785-1.62l2.331-2.953a1 1 0 0 1 1.537-.04" fill="url(#d)"></path>
                  </g>
                  <path d="M24 .666H8A7.333 7.333 0 0 0 .667 8v16A7.333 7.333 0 0 0 8 31.333h16A7.333 7.333 0 0 0 31.334 24V8A7.333 7.333 0 0 0 24 .666Z" stroke="url(#e)" stroke-width="2"></path>
                </g>
                <defs>
                  <linearGradient id="c" x1="29" y1="2" x2="3" y2="29.5" gradientUnits="userSpaceOnUse">
                    <stop stop-opacity="0"></stop>
                    <stop offset="1" stop-opacity=".38"></stop>
                  </linearGradient>
                  <linearGradient id="d" x1="16.107" y1="7.64" x2="16.107" y2="23.595" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".6"></stop>
                  </linearGradient>
                  <linearGradient id="e" x1="16" y1="0" x2="16" y2="32" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff" stop-opacity=".28"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".04"></stop>
                  </linearGradient>
                  <clipPath id="a">
                    <path fill="#fff" d="M0 0h32v32H0z"></path>
                  </clipPath>
                </defs>
              </svg>
            </span>
            <div class="flex sxihv jz3o6">
              <span class="text-base-content c9rvi t3mfo">FlyonUI</span>
              <span class="text-base-content/50 text-xs">Dashboard Template</span>
            </div>
          </div>
          <div class="n85ea overflow-y-auto">
            <ul class="accordion x737x v85mw rsqkx p-3">
              <!-- Dashboard -->
              <li class="cwnx3">
                <a href="#" class="px-2">
                  <span class="icon-[tabler--dashboard] qmuz4"></span>
                  <span class="sxihv">Dashboard</span>
                  <span class="ijn5q o1g2m pze98 rounded-full">5</span>
                </a>
              </li>
              <li class="text-base-content/50 before:bg-base-content/20 hgzwk f1870 text-xs vxiam before:absolute before:-start-3 before:top-1/2 before:h-0.5 before:w-2.5">
                Pages
              </li>
              <!-- User Profile -->
              <li class="accordion-item" id="user">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="user-collapse" aria-expanded="true">
                  <span class="icon-[tabler--user] qmuz4"></span>
                  <span class="sxihv">User Profile</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="user-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="user" role="region">
                  <ul class="kf6hd">
                    <!-- Profile -->
                    <li>
                      <a href="#" class="px-2">Profile</a>
                    </li>
                    <!-- Teams -->
                    <li>
                      <a href="#" class="px-2">Teams</a>
                    </li>
                    <!-- Projects -->
                    <li>
                      <a href="#" class="px-2">Projects</a>
                    </li>
                    <!-- Connection -->
                    <li>
                      <a href="#" class="px-2">Connection</a>
                    </li>
                  </ul>
                </div>
              </li>
              <!-- Account Settings -->
              <li class="accordion-item" id="account">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="account-collapse" aria-expanded="true">
                  <span class="icon-[tabler--settings] qmuz4"></span>
                  <span class="sxihv">Account Setting</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="account-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="account" role="region">
                  <ul class="kf6hd">
                    <!-- Change Password -->
                    <li>
                      <a href="#" class="px-2">Change Password</a>
                    </li>
                    <!-- Privacy Settings -->
                    <li>
                      <a href="#" class="px-2">Privacy Settings</a>
                    </li>
                    <!-- Subscription & Billing -->
                    <li>
                      <a href="#" class="px-2">Subscription &amp; Billing</a>
                    </li>
                    <!-- Account Deactivation/Deletion -->
                    <li>
                      <a href="#" class="px-2">Account Deactivation</a>
                    </li>
                  </ul>
                </div>
              </li>
              <!-- FAQ -->
              <li>
                <a href="#" class="oeogr px-2">
                  <span class="icon-[tabler--help] qmuz4"></span>
                  FAQ
                </a>
              </li>
              <!-- Pricing -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--currency-dollar] qmuz4"></span>
                  <span class="sxihv">Pricing</span>
                  <span class="ijn5q o1g2m gehqc rounded-full">3</span>
                </a>
              </li>
              <!-- Misc -->
              <li class="accordion-item" id="misc">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="misc-collapse" aria-expanded="true">
                  <span class="icon-[tabler--layout-grid] qmuz4"></span>
                  <span class="sxihv">Misc</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="misc-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="misc" role="region">
                  <ul class="kf6hd">
                    <!-- Error -->
                    <li>
                      <a href="#" class="px-2">Error</a>
                    </li>
                    <!-- Coming Soon -->
                    <li>
                      <a href="#" class="px-2">Coming Soon</a>
                    </li>
                    <!-- Not Authorized -->
                    <li>
                      <a href="#" class="px-2">Not Authorized</a>
                    </li>
                    <!-- Under Maintenance -->
                    <li>
                      <a href="#" class="px-2">Under Maintenance</a>
                    </li>
                  </ul>
                </div>
              </li>
              <!-- Authentication -->
              <li class="accordion-item" id="authentications">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="authentications-collapse" aria-expanded="true">
                  <span class="icon-[tabler--lock] qmuz4"></span>
                  <span class="sxihv">Authentications</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="authentications-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="authentications" role="region">
                  <ul class="kf6hd">
                    <!-- Login -->
                    <li>
                      <a href="#" class="px-2">Login</a>
                    </li>
                    <!-- Register -->
                    <li>
                      <a href="#" class="px-2">Register</a>
                    </li>
                    <!-- Verify Email -->
                    <li>
                      <a href="#" class="px-2">Verify Email</a>
                    </li>
                    <!-- Reset Password -->
                    <li>
                      <a href="#" class="px-2">Reset Password</a>
                    </li>
                    <!-- Forgot Password -->
                    <li>
                      <a href="#" class="px-2">Forgot Password</a>
                    </li>
                    <!-- Two Steps -->
                    <li>
                      <a href="#" class="px-2">Two Steps</a>
                    </li>
                  </ul>
                </div>
              </li>
              <!-- Wizard Examples -->
              <li class="accordion-item" id="wizard">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="wizard-collapse" aria-expanded="true">
                  <span class="icon-[tabler--list-details] qmuz4"></span>
                  <span class="sxihv">Wizard Examples</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="wizard-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="wizard" role="region">
                  <ul class="kf6hd">
                    <!-- Checkout -->
                    <li>
                      <a href="#" class="px-2">Checkout</a>
                    </li>
                    <!-- Property Listing -->
                    <li>
                      <a href="#" class="px-2">Property Listing</a>
                    </li>
                    <!-- Create Deal -->
                    <li>
                      <a href="#" class="px-2">Create Deal</a>
                    </li>
                  </ul>
                </div>
              </li>
              <!-- Modal Examples -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--copy] qmuz4"></span>
                  Modal Examples
                </a>
              </li>
              <!-- Charts & Maps -->
              <li class="text-base-content/50 before:bg-base-content/20 hgzwk f1870 text-xs vxiam before:absolute before:-start-3 before:top-1/2 before:h-0.5 before:w-2.5">
                Charts &amp; Maps
              </li>
              <!-- Charts -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--chart-bar] qmuz4"></span>
                  Charts
                </a>
              </li>
              <!-- Maps -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--map-pin] qmuz4"></span>
                  Maps
                </a>
              </li>

              <!-- Applications -->
              <li class="text-base-content/50 before:bg-base-content/20 hgzwk f1870 text-xs vxiam before:absolute before:-start-3 before:top-1/2 before:h-0.5 before:w-2.5">
                Applications
              </li>
              <!-- Email -->
              <li>
                <a href="#" class="dh3pr px-2">
                  <div class="nfjpm rmjll">
                    <div class="dxw29 rgf08 rounded-field lpcq7">
                      <span class="icon-[tabler--mail] qmuz4"></span>
                    </div>
                  </div>
                  Email
                </a>
              </li>
              <!-- User -->
              <li class="accordion-item" id="app-user">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="app-user-collapse" aria-expanded="true">
                  <span class="alim4 rounded-field flex size-6 items-center justify-center">
                    <span class="icon-[tabler--user] qmuz4"></span>
                  </span>
                  <span class="sxihv">User</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="app-user-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="app-user" role="region">
                  <ul class="accordion kf6hd">
                    <!-- List -->
                    <li>
                      <a href="#" class="px-2">List</a>
                    </li>
                    <li class="accordion-item" id="view">
                      <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="view-collapse" aria-expanded="true">
                        <span class="sxihv">View</span>
                        <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                      </button>
                      <div id="view-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="view" role="region">
                        <ul class="kf6hd">
                          <!-- Account -->
                          <li>
                            <a href="#" class="px-2">Account</a>
                          </li>
                          <!-- Security -->
                          <li>
                            <a href="#" class="px-2">Security</a>
                          </li>
                          <!-- Billing & Plans -->
                          <li>
                            <a href="#" class="px-2">Billing &amp; Plans</a>
                          </li>
                          <!-- Notifications -->
                          <li>
                            <a href="#" class="px-2">Notifications</a>
                          </li>
                        </ul>
                      </div>
                    </li>
                  </ul>
                </div>
              </li>
              <!-- Roles & Permissions -->
              <li class="accordion-item" id="roles-permissions">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="roles-permissions-collapse" aria-expanded="true">
                  <span class="alim4 rounded-field flex size-6 items-center justify-center">
                    <span class="icon-[tabler--shield-check] qmuz4"></span>
                  </span>
                  <span class="sxihv">Roles &amp; Permissions</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="roles-permissions-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="roles-permissions" role="region">
                  <ul class="kf6hd">
                    <!-- Roles -->
                    <li>
                      <a href="#" class="px-2">Roles</a>
                    </li>
                    <!-- Permission -->
                    <li>
                      <a href="#" class="px-2">Permission</a>
                    </li>
                  </ul>
                </div>
              </li>
              <!-- Chat -->
              <li>
                <a href="#" class="dh3pr px-2">
                  <div class="nfjpm rmjll">
                    <div class="dxw29 rgf08 rounded-field lpcq7">
                      <span class="icon-[tabler--message-2] qmuz4"></span>
                    </div>
                  </div>
                  Chat
                </a>
              </li>
              <!-- Calendar -->
              <li>
                <a href="#" class="dh3pr px-2">
                  <div class="nfjpm rmjll">
                    <div class="dxw29 rgf08 rounded-field lpcq7">
                      <span class="icon-[tabler--calendar] qmuz4"></span>
                    </div>
                  </div>
                  Calendar
                </a>
              </li>
              <!-- File manager -->
              <li class="accordion-item" id="file-manager">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="file-manager-collapse" aria-expanded="true">
                  <span class="alim4 rounded-field flex size-6 items-center justify-center">
                    <span class="icon-[tabler--folder] qmuz4"></span>
                  </span>
                  <span class="sxihv">File manager</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="file-manager-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="file-manager" role="region">
                  <ul class="kf6hd">
                    <!-- My Files -->
                    <li>
                      <a href="#" class="px-2">My Files</a>
                    </li>
                    <!-- My Files -->
                    <li>
                      <a href="#" class="px-2">My Files</a>
                    </li>
                  </ul>
                </div>
              </li>
              <!-- Kanban -->
              <li>
                <a href="#" class="dh3pr px-2">
                  <div class="nfjpm rmjll">
                    <div class="dxw29 rgf08 rounded-field lpcq7">
                      <span class="icon-[tabler--layout-grid] qmuz4"></span>
                    </div>
                  </div>
                  Kanban
                </a>
              </li>
              <!-- Point of Sale -->
              <li class="accordion-item" id="point-of-sale">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="point-of-sale-collapse" aria-expanded="true">
                  <span class="alim4 rounded-field flex size-6 items-center justify-center">
                    <span class="icon-[tabler--trending-up] qmuz4"></span>
                  </span>
                  <span class="sxihv">Point of Sale</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="point-of-sale-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="point-of-sale" role="region">
                  <ul class="kf6hd">
                    <!-- New Order -->
                    <li>
                      <a href="#" class="px-2">New Order</a>
                    </li>
                    <!-- Order List -->
                    <li>
                      <a href="#" class="px-2">Order List</a>
                    </li>
                    <!-- Costumers -->
                    <li>
                      <a href="#" class="px-2">Costumers</a>
                    </li>
                  </ul>
                </div>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->

    <div class="flex sxihv jz3o6 lg:ps-65">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="wpaot w-full owca9 e6ynr sxihv fbpri">
        <div class="dpzny wfsyj ip6vv">
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="wpaot w-full owca9 rukzz">
        <div class="bg-base-100 fwpqz hg6f0"></div>
      </footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>
  </div>


    <script src="https://flyonui.becdn.net/pro/libs/flyonui/flyonui.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const url = window.location.href

      // Check if the URL contains the "theme" parameter
      const themeParam = new URLSearchParams(window.location.search).get("theme")
      const dirRTL = new URLSearchParams(window.location.search).get("rtl")

      // If a theme parameter is present, apply it to the document
      if (themeParam) {
        document.documentElement.setAttribute("data-theme", themeParam)
      }
      if (dirRTL === "true") {
        document.documentElement.setAttribute("dir", "rtl")
      }
    })
  </script>
  

</body>


<body data-vh-checked="true">
  <div class="dhabr flex min-h-screen jz3o6">
    <!-- ---------- HEADER ---------- -->
    <div class="bg-base-100 sticky top-0 at1sq flex sm:ps-17">
      <div class="wpaot w-full">
        <nav class="hvzi2 eckwz">
          <button type="button" class="btn btn-soft btn-square btn-sm me-2 sm:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>
        </nav>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 wjz3b e4bmm hidden n85ea oun33 [--auto-close:sm] sm:block sm:translate-x-0 sm:shadow-none" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z border-base-content/20 n85ea jawf4 cbpaz">
        <div class="flex n85ea w8f5g jz3o6">
          <div class="flex items-center justify-center sly4q px-3 zbjyy">
            <span class="text-primary">
              <svg width="38" height="38" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clip-path="url(#a)">
                  <mask id="b" style="mask-type:luminance" maskUnits="userSpaceOnUse" x="0" y="0" width="32" height="32">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="#fff"></path>
                  </mask>
                  <g mask="url(#b)">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="currentColor"></path>
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="url(#c)"></path>
                    <path fill-rule="evenodd" clip-rule="evenodd" d="m22.258 20.467-5.55-6.839a1 1 0 0 0-1.568.02l-5.023 6.521a1 1 0 0 1-.793.39H7.17a1 1 0 0 1-.78-1.626l8.748-10.919a1 1 0 0 1 1.556-.006l9.125 11.198a1 1 0 0 1-.775 1.631h-2.01a1 1 0 0 1-.776-.37m-5.59-1.484 2.59 2.953c.567.646.108 1.659-.751 1.659h-4.922a1 1 0 0 1-.785-1.62l2.331-2.953a1 1 0 0 1 1.537-.04" fill="url(#d)"></path>
                  </g>
                  <path d="M24 .666H8A7.333 7.333 0 0 0 .667 8v16A7.333 7.333 0 0 0 8 31.333h16A7.333 7.333 0 0 0 31.334 24V8A7.333 7.333 0 0 0 24 .666Z" stroke="url(#e)" stroke-width="2"></path>
                </g>
                <defs>
                  <linearGradient id="c" x1="29" y1="2" x2="3" y2="29.5" gradientUnits="userSpaceOnUse">
                    <stop stop-opacity="0"></stop>
                    <stop offset="1" stop-opacity=".38"></stop>
                  </linearGradient>
                  <linearGradient id="d" x1="16.107" y1="7.64" x2="16.107" y2="23.595" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".6"></stop>
                  </linearGradient>
                  <linearGradient id="e" x1="16" y1="0" x2="16" y2="32" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff" stop-opacity=".28"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".04"></stop>
                  </linearGradient>
                  <clipPath id="a">
                    <path fill="#fff" d="M0 0h32v32H0z"></path>
                  </clipPath>
                </defs>
              </svg>
            </span>
          </div>
          <div class="n85ea overflow-y-auto [scrollbar-width:none]">
            <ul class="flex jz3o6 bglhu q5rzg egd50">
              <!-- Home -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot">
                  <div class="nfjpm rmjll">
                    <div class="group-hover:bg-neutral/10 text-base-content rounded-field transition-color group-[.item-active]:text-bg-neutral lt1t7 ji7zy duration-300">
                      <span class="icon-[tabler--smart-home] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Home</span>
                </a>
              </li>
              <li class="ck7pw wpaot lgvb8 t6d3t"></li>
              <!-- Portfolio -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot">
                  <div class="nfjpm rmjll">
                    <div class="group-hover:bg-neutral/10 text-base-content rounded-field transition-color group-[.item-active]:text-bg-neutral lt1t7 ji7zy duration-300">
                      <span class="icon-[tabler--chart-bar] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Portfolio</span>
                </a>
              </li>
              <!-- Market -->
              <li>
                <a href="#" class="dh3pr q7011 flex jz3o6 items-center justify-center xk2ot">
                  <div class="nfjpm rmjll">
                    <div class="group-hover:bg-neutral/10 text-base-content rounded-field transition-color group-[.item-active]:text-bg-neutral lt1t7 ji7zy duration-300">
                      <span class="icon-[tabler--layout-grid-add] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Market</span>
                </a>
              </li>
              <!-- Trading -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot">
                  <div class="nfjpm rmjll">
                    <div class="group-hover:bg-neutral/10 text-base-content rounded-field transition-color group-[.item-active]:text-bg-neutral lt1t7 ji7zy duration-300">
                      <span class="icon-[tabler--trending-up] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Trading</span>
                </a>
              </li>
              <li class="ck7pw wpaot lgvb8 t6d3t"></li>
              <!-- Stocks -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot">
                  <div class="nfjpm rmjll">
                    <div class="group-hover:bg-neutral/10 text-base-content rounded-field transition-color group-[.item-active]:text-bg-neutral lt1t7 ji7zy duration-300">
                      <span class="icon-[tabler--list-details] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Stocks</span>
                </a>
              </li>
              <!-- Scanner -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot">
                  <div class="nfjpm rmjll">
                    <div class="group-hover:bg-neutral/10 text-base-content rounded-field transition-color group-[.item-active]:text-bg-neutral lt1t7 ji7zy duration-300">
                      <span class="icon-[tabler--dashboard] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Scanner</span>
                </a>
              </li>
              <!-- Analytics -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot">
                  <div class="nfjpm rmjll">
                    <div class="group-hover:bg-neutral/10 text-base-content rounded-field transition-color group-[.item-active]:text-bg-neutral lt1t7 ji7zy duration-300">
                      <span class="icon-[tabler--chart-donut-3] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Analytics</span>
                </a>
              </li>
              <li class="ck7pw wpaot lgvb8 t6d3t"></li>
              <!-- Setting -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot">
                  <div class="nfjpm rmjll">
                    <div class="group-hover:bg-neutral/10 text-base-content rounded-field transition-color group-[.item-active]:text-bg-neutral lt1t7 ji7zy duration-300">
                      <span class="icon-[tabler--settings] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Setting</span>
                </a>
              </li>
              <!-- Invite -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot">
                  <div class="nfjpm rmjll">
                    <div class="group-hover:bg-neutral/10 text-base-content rounded-field transition-color group-[.item-active]:text-bg-neutral lt1t7 ji7zy duration-300">
                      <span class="icon-[tabler--link] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Invite</span>
                </a>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->

    <div class="flex sxihv jz3o6 sm:ps-17">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="e6ynr fbpri">
        <div class="dpzny wfsyj ip6vv">
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="bg-base-100 hg6f0 qzwp2 rukzz"></footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>
  </div>


    <script src="https://flyonui.becdn.net/pro/libs/flyonui/flyonui.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const url = window.location.href

      // Check if the URL contains the "theme" parameter
      const themeParam = new URLSearchParams(window.location.search).get("theme")
      const dirRTL = new URLSearchParams(window.location.search).get("rtl")

      // If a theme parameter is present, apply it to the document
      if (themeParam) {
        document.documentElement.setAttribute("data-theme", themeParam)
      }
      if (dirRTL === "true") {
        document.documentElement.setAttribute("dir", "rtl")
      }
    })
  </script>
  

</body>

<body data-vh-checked="true">
  <div class="dhabr flex min-h-screen jz3o6">
    <!-- ---------- HEADER ---------- -->
    <div class="bg-base-100 sticky top-0 at1sq flex sm:ps-17">
      <div class="wpaot w-full">
        <nav class="hvzi2 eckwz">
          <button type="button" class="btn btn-soft btn-square btn-sm me-2 sm:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>
        </nav>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 wjz3b e4bmm hidden n85ea oun33 [--auto-close:sm] sm:block sm:translate-x-0 sm:shadow-none" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z n85ea c33d9 cbpaz">
        <div class="flex n85ea w8f5g jz3o6">
          <div class="flex items-center justify-center sly4q px-3 zbjyy">
            <span class="text-primary">
              <svg width="36" height="36" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clip-path="url(#a)">
                  <mask id="b" style="mask-type:luminance" maskUnits="userSpaceOnUse" x="0" y="0" width="32" height="32">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="#fff"></path>
                  </mask>
                  <g mask="url(#b)">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="currentColor"></path>
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="url(#c)"></path>
                    <path fill-rule="evenodd" clip-rule="evenodd" d="m22.258 20.467-5.55-6.839a1 1 0 0 0-1.568.02l-5.023 6.521a1 1 0 0 1-.793.39H7.17a1 1 0 0 1-.78-1.626l8.748-10.919a1 1 0 0 1 1.556-.006l9.125 11.198a1 1 0 0 1-.775 1.631h-2.01a1 1 0 0 1-.776-.37m-5.59-1.484 2.59 2.953c.567.646.108 1.659-.751 1.659h-4.922a1 1 0 0 1-.785-1.62l2.331-2.953a1 1 0 0 1 1.537-.04" fill="url(#d)"></path>
                  </g>
                  <path d="M24 .666H8A7.333 7.333 0 0 0 .667 8v16A7.333 7.333 0 0 0 8 31.333h16A7.333 7.333 0 0 0 31.334 24V8A7.333 7.333 0 0 0 24 .666Z" stroke="url(#e)" stroke-width="2"></path>
                </g>
                <defs>
                  <linearGradient id="c" x1="29" y1="2" x2="3" y2="29.5" gradientUnits="userSpaceOnUse">
                    <stop stop-opacity="0"></stop>
                    <stop offset="1" stop-opacity=".38"></stop>
                  </linearGradient>
                  <linearGradient id="d" x1="16.107" y1="7.64" x2="16.107" y2="23.595" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".6"></stop>
                  </linearGradient>
                  <linearGradient id="e" x1="16" y1="0" x2="16" y2="32" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff" stop-opacity=".28"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".04"></stop>
                  </linearGradient>
                  <clipPath id="a">
                    <path fill="#fff" d="M0 0h32v32H0z"></path>
                  </clipPath>
                </defs>
              </svg>
            </span>
          </div>
          <div class="n85ea overflow-y-auto [scrollbar-width:none]">
            <ul class="flex jz3o6 bglhu q5rzg egd50">
              <!-- Home -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot lmn89">
                  <div class="nfjpm rmjll">
                    <div class="rounded-field transition-color group-[.link-active]:text-bg-primary lt1t7 ji7zy duration-300 group-hover:bg-neutral-700">
                      <span class="icon-[tabler--dashboard] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Home</span>
                </a>
              </li>
              <li class="ck7pw wpaot lgvb8 t6d3t qr9u1"></li>
              <!-- Leads -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot lmn89">
                  <div class="nfjpm rmjll">
                    <div class="rounded-field transition-color group-[.link-active]:text-bg-primary lt1t7 ji7zy duration-300 group-hover:bg-neutral-700">
                      <span class="icon-[tabler--chart-bar] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Leads</span>
                </a>
              </li>
              <!-- Client -->
              <li>
                <a href="#" class="dh3pr u97gy flex jz3o6 items-center justify-center xk2ot lmn89">
                  <div class="nfjpm rmjll">
                    <div class="rounded-field transition-color group-[.link-active]:text-bg-primary lt1t7 ji7zy duration-300 group-hover:bg-neutral-700">
                      <span class="icon-[tabler--user] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Client</span>
                </a>
              </li>
              <!-- Calendar -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot lmn89">
                  <div class="nfjpm rmjll">
                    <div class="rounded-field transition-color group-[.link-active]:text-bg-primary lt1t7 ji7zy duration-300 group-hover:bg-neutral-700">
                      <span class="icon-[tabler--calendar] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Calendar</span>
                </a>
              </li>
              <!-- Tasks -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot lmn89">
                  <div class="nfjpm rmjll">
                    <div class="rounded-field transition-color group-[.link-active]:text-bg-primary lt1t7 ji7zy duration-300 group-hover:bg-neutral-700">
                      <span class="icon-[tabler--calendar] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Tasks</span>
                </a>
              </li>
              <!-- Deals -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot lmn89">
                  <div class="nfjpm rmjll">
                    <div class="rounded-field transition-color group-[.link-active]:text-bg-primary lt1t7 ji7zy duration-300 group-hover:bg-neutral-700">
                      <span class="icon-[tabler--percentage] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Deals</span>
                </a>
              </li>
              <li class="ck7pw wpaot lgvb8 t6d3t qr9u1"></li>
              <!-- Team -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot lmn89">
                  <div class="nfjpm rmjll">
                    <div class="rounded-field transition-color group-[.link-active]:text-bg-primary lt1t7 ji7zy duration-300 group-hover:bg-neutral-700">
                      <span class="icon-[tabler--users] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Team</span>
                </a>
              </li>
              <!-- Revenue -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot lmn89">
                  <div class="nfjpm rmjll">
                    <div class="rounded-field transition-color group-[.link-active]:text-bg-primary lt1t7 ji7zy duration-300 group-hover:bg-neutral-700">
                      <span class="icon-[tabler--currency-dollar] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Revenue</span>
                </a>
              </li>
              <!-- Leads -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot lmn89">
                  <div class="nfjpm rmjll">
                    <div class="rounded-field transition-color group-[.link-active]:text-bg-primary lt1t7 ji7zy duration-300 group-hover:bg-neutral-700">
                      <span class="icon-[tabler--activity] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Leads</span>
                </a>
              </li>
              <li class="ck7pw wpaot lgvb8 t6d3t qr9u1"></li>
              <!-- Support -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot lmn89">
                  <div class="nfjpm rmjll">
                    <div class="rounded-field transition-color group-[.link-active]:text-bg-primary lt1t7 ji7zy duration-300 group-hover:bg-neutral-700">
                      <span class="icon-[tabler--help] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Support</span>
                </a>
              </li>
              <!-- Doc -->
              <li>
                <a href="#" class="dh3pr flex jz3o6 items-center justify-center xk2ot lmn89">
                  <div class="nfjpm rmjll">
                    <div class="rounded-field transition-color group-[.link-active]:text-bg-primary lt1t7 ji7zy duration-300 group-hover:bg-neutral-700">
                      <span class="icon-[tabler--file-invoice] girx5"></span>
                    </div>
                  </div>
                  <span class="text-xs">Reports</span>
                </a>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->

    <div class="flex sxihv jz3o6 sm:ps-17">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="e6ynr fbpri">
        <div class="dpzny wfsyj ip6vv">
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="bg-base-100 hg6f0 qzwp2 rukzz"></footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>
  </div>


    <script src="https://flyonui.becdn.net/pro/libs/flyonui/flyonui.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const url = window.location.href

      // Check if the URL contains the "theme" parameter
      const themeParam = new URLSearchParams(window.location.search).get("theme")
      const dirRTL = new URLSearchParams(window.location.search).get("rtl")

      // If a theme parameter is present, apply it to the document
      if (themeParam) {
        document.documentElement.setAttribute("data-theme", themeParam)
      }
      if (dirRTL === "true") {
        document.documentElement.setAttribute("dir", "rtl")
      }
    })
  </script>
  

</body>


<body data-vh-checked="true">
  <div class="dhabr relative flex min-h-screen jz3o6 before:fixed before:h-105 before:w-full before:bg-neutral-950">
    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 lg:rounded-box wjz3b e4bmm hidden n85ea [--auto-close:lg] sm:w-75 lg:my-auto lg:block lg:max-h-[calc(100dvh-48px)] lg:translate-x-6 rtl:lg:-translate-x-6" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z n85ea cbpaz">
        <div class="flex n85ea w8f5g jz3o6">
          <button type="button" class="btn btn-text btn-circle btn-sm absolute c6rnh vv66w lg:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
            <span class="icon-[tabler--x] qmuz4"></span>
          </button>
          <div class="flex items-center sly4q j2be9 zbjyy">
            <span class="text-primary">
              <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clip-path="url(#a)">
                  <mask id="b" style="mask-type:luminance" maskUnits="userSpaceOnUse" x="0" y="0" width="32" height="32">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="#fff"></path>
                  </mask>
                  <g mask="url(#b)">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="currentColor"></path>
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="url(#c)"></path>
                    <path fill-rule="evenodd" clip-rule="evenodd" d="m22.258 20.467-5.55-6.839a1 1 0 0 0-1.568.02l-5.023 6.521a1 1 0 0 1-.793.39H7.17a1 1 0 0 1-.78-1.626l8.748-10.919a1 1 0 0 1 1.556-.006l9.125 11.198a1 1 0 0 1-.775 1.631h-2.01a1 1 0 0 1-.776-.37m-5.59-1.484 2.59 2.953c.567.646.108 1.659-.751 1.659h-4.922a1 1 0 0 1-.785-1.62l2.331-2.953a1 1 0 0 1 1.537-.04" fill="url(#d)"></path>
                  </g>
                  <path d="M24 .666H8A7.333 7.333 0 0 0 .667 8v16A7.333 7.333 0 0 0 8 31.333h16A7.333 7.333 0 0 0 31.334 24V8A7.333 7.333 0 0 0 24 .666Z" stroke="url(#e)" stroke-width="2"></path>
                </g>
                <defs>
                  <linearGradient id="c" x1="29" y1="2" x2="3" y2="29.5" gradientUnits="userSpaceOnUse">
                    <stop stop-opacity="0"></stop>
                    <stop offset="1" stop-opacity=".38"></stop>
                  </linearGradient>
                  <linearGradient id="d" x1="16.107" y1="7.64" x2="16.107" y2="23.595" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".6"></stop>
                  </linearGradient>
                  <linearGradient id="e" x1="16" y1="0" x2="16" y2="32" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff" stop-opacity=".28"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".04"></stop>
                  </linearGradient>
                  <clipPath id="a">
                    <path fill="#fff" d="M0 0h32v32H0z"></path>
                  </clipPath>
                </defs>
              </svg>
            </span>
            <div>
              <span class="text-base-content block bk5oo fl9z1">Payment</span>
            </div>
          </div>
          <div class="n85ea overflow-y-auto">
            <ul class="accordion x737x v85mw rsqkx overflow-y-auto p-3">
              <!-- Dashboard -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--smart-home] qmuz4"></span>
                  <span class="sxihv">Dashboard</span>
                </a>
              </li>
              <!-- Wallet Management -->
              <li class="accordion-item active" id="wallet">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="wallet-collapse" aria-expanded="true">
                  <span class="icon-[tabler--wallet] qmuz4"></span>
                  <span class="sxihv">Wallet Management</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="wallet-collapse" class="accordion-content su75o w-full overflow-hidden transition-[height] duration-300" aria-labelledby="wallet" role="region">
                  <ul class="kf6hd">
                    <!-- Overview -->
                    <li>
                      <a href="#" class="oeogr px-2">Account Overview</a>
                    </li>
                    <!-- Available Funds -->
                    <li>
                      <a href="#" class="px-2">Available Funds</a>
                    </li>
                    <!-- Transaction History -->
                    <li>
                      <a href="#" class="px-2">Transaction History</a>
                    </li>
                  </ul>
                </div>
              </li>

              <!-- Money Transfers -->
              <li class="accordion-item" id="money-transfers">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="money-transfers-collapse" aria-expanded="true">
                  <span class="icon-[tabler--arrows-left-right] qmuz4"></span>
                  <span class="sxihv">Money Transfers</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="money-transfers-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="money-transfers" role="region">
                  <ul class="kf6hd">
                    <!-- Transfer Overview -->
                    <li>
                      <a href="#" class="px-2">Transfer Overview</a>
                    </li>
                    <!-- Transfer Method -->
                    <li>
                      <a href="#" class="px-2">Transfer Methods</a>
                    </li>
                  </ul>
                </div>
              </li>

              <!-- Deposit Funds -->
              <li class="accordion-item" id="deposit-funds">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="deposit-funds-collapse" aria-expanded="true">
                  <span class="icon-[tabler--circle-plus] qmuz4"></span>
                  <span class="sxihv">Deposit Funds</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="deposit-funds-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="deposit-funds" role="region">
                  <ul class="kf6hd">
                    <!-- Amount to Deposit -->
                    <li>
                      <a href="#" class="px-2">Deposit Amount</a>
                    </li>
                    <!-- Payment Method -->
                    <li>
                      <a href="#" class="px-2">Payment Method</a>
                    </li>
                    <!-- Confirmation -->
                    <li>
                      <a href="#" class="px-2">Confirmation</a>
                    </li>
                  </ul>
                </div>
              </li>

              <!-- Request Funds -->
              <li class="accordion-item" id="request-funds">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="request-funds-collapse" aria-expanded="true">
                  <span class="icon-[tabler--arrow-down-left] qmuz4"></span>
                  <span class="sxihv">Request Funds</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="request-funds-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="request-funds" role="region">
                  <ul class="kf6hd">
                    <!-- Request Details -->
                    <li>
                      <a href="#" class="px-2">Request Details</a>
                    </li>
                    <!-- Amount to Request -->
                    <li>
                      <a href="#" class="px-2">Amount to Request</a>
                    </li>
                    <!-- Share Request -->
                    <li>
                      <a href="#" class="px-2">Share Request</a>
                    </li>
                  </ul>
                </div>
              </li>

              <!-- Payment Requests -->
              <li class="accordion-item" id="payment-requests">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="payment-requests-collapse" aria-expanded="true">
                  <span class="icon-[tabler--currency-dollar] qmuz4"></span>
                  <span class="sxihv">Payment Requests</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="payment-requests-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="payment-requests" role="region">
                  <ul class="kf6hd">
                    <!-- Requested Overview -->
                    <li>
                      <a href="#" class="px-2">Requested Overview</a>
                    </li>
                    <!-- Payment Details -->
                    <li>
                      <a href="#" class="px-2">Payment Details</a>
                    </li>
                  </ul>
                </div>
              </li>

              <!-- Order Management -->
              <li class="accordion-item" id="order-management">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="order-management-collapse" aria-expanded="true">
                  <span class="icon-[tabler--credit-card] qmuz4"></span>
                  <span class="sxihv">Order Management</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="order-management-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="order-management" role="region">
                  <ul class="kf6hd">
                    <!-- Order Overview -->
                    <li>
                      <a href="#" class="px-2">Order Overview</a>
                    </li>
                    <!-- Add New Order -->
                    <li>
                      <a href="#" class="px-2">Add New Order</a>
                    </li>
                    <!-- View Orders -->
                    <li>
                      <a href="#" class="px-2">View Orders</a>
                    </li>
                  </ul>
                </div>
              </li>

              <!-- User Management -->
              <li class="accordion-item" id="user-management">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-sm ejsm2" aria-controls="user-management-collapse" aria-expanded="true">
                  <span class="icon-[tabler--users] qmuz4"></span>
                  <span class="sxihv">User Management</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 qmuz4 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="user-management-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="user-management" role="region">
                  <ul class="kf6hd">
                    <!-- Users Overview -->
                    <li>
                      <a href="#" class="px-2">Users Overview</a>
                    </li>
                    <!-- Active Users -->
                    <li>
                      <a href="#" class="px-2">Active Users</a>
                    </li>
                  </ul>
                </div>
              </li>

              <!-- Recipients Section -->
              <li class="text-base-content/50 cwnx3 f1870 text-xs vxiam">Recipients</li>
              <!-- Liam Anderson -->
              <li>
                <a href="#" class="px-2">
                  <div class="nfjpm">
                    <div class="rounded-field size-6">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
                    </div>
                  </div>
                  <span class="sxihv">Liam Anderson</span>
                </a>
              </li>
              <!-- Emma Davis -->
              <li>
                <a href="#" class="px-2">
                  <div class="nfjpm">
                    <div class="rounded-field size-6">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="avatar">
                    </div>
                  </div>
                  <span class="sxihv">Emma Davis</span>
                </a>
              </li>
              <!-- Ethan Bennett -->
              <li>
                <a href="#" class="px-2">
                  <div class="nfjpm">
                    <div class="rounded-field size-6">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                    </div>
                  </div>
                  <span class="sxihv">Ethan Bennett</span>
                </a>
              </li>
              <!-- Olivia Morgan -->
              <li>
                <a href="#" class="px-2">
                  <div class="nfjpm">
                    <div class="rounded-field size-6">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                    </div>
                  </div>
                  <span class="sxihv">Olivia Morgan</span>
                </a>
              </li>
              <!-- Noah Carter -->
              <li>
                <a href="#" class="px-2">
                  <div class="nfjpm">
                    <div class="rounded-field size-6">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="avatar">
                    </div>
                  </div>
                  <span class="sxihv">Noah Carter</span>
                </a>
              </li>
              <!-- Ava Thompson -->
              <li>
                <a href="#" class="px-2">
                  <div class="nfjpm">
                    <div class="rounded-field size-6">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="avatar">
                    </div>
                  </div>
                  <span class="sxihv">Ava Thompson</span>
                </a>
              </li>
            </ul>
          </div>
          <div class="os8bl p-3">
            <div class="dropdown relative inline-flex w-full [--offset:20] [--placement:top-start] sm:[--placement:right-end]">
              <button id="user-dropdown" type="button" class="dropdown-toggle dhabr rounded-field flex w-full items-center sly4q px-2 qbqme" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="nfjpm">
                  <span class="rounded-field lt1t7">
                    <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                  </span>
                </span>

                <span class="e6ynr ao5al">
                  <span class="text-base-content text-sm t3mfo">Sophia Reynolds</span>
                  <span class="text-base-content/80 text-xs">Administrator</span>
                </span>
                <span class="icon-[tabler--chevron-right] dropdown-open:-rotate-90 qmuz4 ciihs duration-300"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden b2g8f adede" role="menu" aria-orientation="vertical" tabindex="-1">
                <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
                  <div class="nfjpm a3rpr">
                    <div class="burs3 rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                    </div>
                  </div>
                  <div>
                    <h6 class="text-base-content mb-0.5 t3mfo">Sophia Reynolds</h6>
                    <p class="text-base-content/80 font-medium">Administrator</p>
                  </div>
                </li>
                <li>
                  <a class="dropdown-item px-3" href="#">
                    <span class="icon-[tabler--user] size-5"></span>
                    My account
                  </a>
                </li>
                <li>
                  <a class="dropdown-item px-3" href="#">
                    <span class="icon-[tabler--settings] size-5"></span>
                    Setting
                  </a>
                </li>
                <li>
                  <a class="dropdown-item px-3" href="#">
                    <span class="icon-[tabler--credit-card] size-5"></span>
                    Billing
                  </a>
                </li>
                <li>
                  <a class="dropdown-item px-3" href="#">
                    <span class="icon-[tabler--users] size-5"></span>
                    Manage team
                  </a>
                </li>
                <li>
                  <a class="dropdown-item px-3" href="#">
                    <span class="icon-[tabler--edit] size-5"></span>
                    Customisation
                  </a>
                </li>
                <li class="mb-1">
                  <a class="dropdown-item px-3" href="#">
                    <span class="icon-[tabler--circle-plus] size-5"></span>
                    Add team account
                  </a>
                </li>
                <li class="u9px6 f1870 dhfwm">
                  <a class="btn btn-text gauh6 rhmi6 lxes6 ib2q4 px-3 ejsm2" href="#">
                    <span class="icon-[tabler--logout] size-5"></span>
                    Logout
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->

    <div class="z-1 flex jz3o6 justify-between o63tj fbpri lg:ms-81">
      <!-- ---------- HEADER ---------- -->
      <nav class="hvzi2 rounded-box shadow-base-300/20 z-1 eckwz shadow-md">
        <button type="button" class="btn btn-soft btn-square me-2 lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
          <span class="icon-[tabler--menu-2] size-5"></span>
        </button>
      </nav>
      <!-- ---------- END HEADER ---------- -->

      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="e6ynr">
        <div class="dpzny wfsyj ip6vv md:grid-cols-2">
          <div class="zq390 d6do8 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 d6do8 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 d6do8 w-full md:col-span-2">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="bg-base-100 rounded-box shadow-base-300/20 eckwz shadow-md"></footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>
  </div>


    <script src="https://flyonui.becdn.net/pro/libs/flyonui/flyonui.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const url = window.location.href

      // Check if the URL contains the "theme" parameter
      const themeParam = new URLSearchParams(window.location.search).get("theme")
      const dirRTL = new URLSearchParams(window.location.search).get("rtl")

      // If a theme parameter is present, apply it to the document
      if (themeParam) {
        document.documentElement.setAttribute("data-theme", themeParam)
      }
      if (dirRTL === "true") {
        document.documentElement.setAttribute("dir", "rtl")
      }
    })
  </script>
  

</body>


<body data-vh-checked="true">
  <div class="dhabr flex min-h-screen jz3o6" dir="rtl">
    <!-- ---------- HEADER ---------- -->
    <div class="supports-[backdrop-filter]:bg-base-200/60 fixed top-0 b3b8l vrjgw w-full mask-[linear-gradient(var(--color-base-200),var(--color-base-200)_18%,transparent_100%)] irmyt nslur"></div>
    <div class="sticky top-0 at1sq flex lg:ps-81">
      <div class="wpaot ndnti w-full owca9 rukzz">
        <nav class="hvzi2 rounded-box d50ic eckwz shadow-md">
          <button type="button" class="btn btn-soft btn-square btn-sm me-2 lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>
        </nav>
      </div>
    </div>

    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 lg:rounded-box wjz3b e4bmm hidden n85ea [--auto-close:lg] sm:w-75 lg:my-auto lg:block lg:max-h-[calc(100dvh-48px)] lg:translate-x-6 lg:overflow-hidden rtl:lg:-translate-x-6" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z n85ea cbpaz">
        <div class="flex n85ea w8f5g jz3o6">
          <button type="button" class="btn btn-text btn-circle btn-sm absolute c6rnh vv66w lg:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
            <span class="icon-[tabler--x] size-5"></span>
          </button>
          <div class="text-base-content flex items-center sly4q a7thv zbjyy bk5oo fl9z1">
            <span class="text-primary">
              <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clip-path="url(#a)">
                  <mask id="b" style="mask-type:luminance" maskUnits="userSpaceOnUse" x="0" y="0" width="32" height="32">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="#fff"></path>
                  </mask>
                  <g mask="url(#b)">
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="currentColor"></path>
                    <path d="M24 0H8a8 8 0 0 0-8 8v16a8 8 0 0 0 8 8h16a8 8 0 0 0 8-8V8a8 8 0 0 0-8-8" fill="url(#c)"></path>
                    <path fill-rule="evenodd" clip-rule="evenodd" d="m22.258 20.467-5.55-6.839a1 1 0 0 0-1.568.02l-5.023 6.521a1 1 0 0 1-.793.39H7.17a1 1 0 0 1-.78-1.626l8.748-10.919a1 1 0 0 1 1.556-.006l9.125 11.198a1 1 0 0 1-.775 1.631h-2.01a1 1 0 0 1-.776-.37m-5.59-1.484 2.59 2.953c.567.646.108 1.659-.751 1.659h-4.922a1 1 0 0 1-.785-1.62l2.331-2.953a1 1 0 0 1 1.537-.04" fill="url(#d)"></path>
                  </g>
                  <path d="M24 .666H8A7.333 7.333 0 0 0 .667 8v16A7.333 7.333 0 0 0 8 31.333h16A7.333 7.333 0 0 0 31.334 24V8A7.333 7.333 0 0 0 24 .666Z" stroke="url(#e)" stroke-width="2"></path>
                </g>
                <defs>
                  <linearGradient id="c" x1="29" y1="2" x2="3" y2="29.5" gradientUnits="userSpaceOnUse">
                    <stop stop-opacity="0"></stop>
                    <stop offset="1" stop-opacity=".38"></stop>
                  </linearGradient>
                  <linearGradient id="d" x1="16.107" y1="7.64" x2="16.107" y2="23.595" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".6"></stop>
                  </linearGradient>
                  <linearGradient id="e" x1="16" y1="0" x2="16" y2="32" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#fff" stop-opacity=".28"></stop>
                    <stop offset="1" stop-color="#fff" stop-opacity=".04"></stop>
                  </linearGradient>
                  <clipPath id="a">
                    <path fill="#fff" d="M0 0h32v32H0z"></path>
                  </clipPath>
                </defs>
              </svg>
            </span>
            <span>فلايون يو آي</span>
          </div>
          <div class="n85ea overflow-y-auto">
            <ul class="accordion x737x rsqkx px-3 egd50">
              <!-- لوحة القيادة -->
              <li>
                <a href="#" class="px-3">
                  <span class="icon-[tabler--dashboard] size-5"></span>
                  لوحة القيادة
                </a>
              </li>
              <li class="text-base-content/50 cwnx3 f1870 text-sm">الإعدادات</li>
              <!-- الإعدادات العامة -->
              <li class="accordion-item" id="app-setting">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-base ejsm2" aria-controls="app-setting-collapse" aria-expanded="true">
                  <span class="icon-[tabler--settings] size-6"></span>
                  <span class="sxihv">الإعدادات العامة</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 size-5 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="app-setting-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="app-setting" role="region">
                  <ul class="kf6hd">
                    <!-- المستخدم -->
                    <li>
                      <a href="#" class="px-3">المستخدم</a>
                    </li>
                    <!-- الحساب -->
                    <li>
                      <a href="#" class="px-3">الحساب</a>
                    </li>
                  </ul>
                </div>
              </li>
              <!-- إعدادات المزود -->
              <li>
                <a href="#" class="px-3">
                  <span class="icon-[tabler--user-circle] size-5"></span>
                  إعدادات المزود
                </a>
              </li>
              <!-- صور -->
              <li>
                <a href="#" class="px-3">
                  <span class="icon-[tabler--photo] size-5"></span>
                  صور
                </a>
              </li>
              <li class="text-base-content/50 cwnx3 f1870 text-sm">الأدوار والإذونات</li>
              <!-- المستخدمين -->
              <li class="accordion-item" id="user">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-base ejsm2" aria-controls="user-collapse" aria-expanded="true">
                  <span class="icon-[tabler--users] size-6"></span>
                  <span class="sxihv">المستخدمين</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 size-5 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="user-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="user" role="region">
                  <ul class="kf6hd">
                    <!-- الملف الشخصي -->
                    <li>
                      <a href="#" class="px-3">الملف الشخصي</a>
                    </li>
                    <!-- الفرق -->
                    <li>
                      <a href="#" class="px-3">الفرق</a>
                    </li>
                    <!-- المشاريع -->
                    <li>
                      <a href="#" class="px-3">المشاريع</a>
                    </li>
                    <!-- الاتصال -->
                    <li>
                      <a href="#" class="px-3">الاتصال</a>
                    </li>
                  </ul>
                </div>
              </li>
              <!-- الإذونات -->
              <li>
                <a href="#" class="oeogr flex items-center justify-between px-2">
                  <span class="flex items-center bglhu">
                    <span class="icon-[tabler--lock] size-5"></span>
                    الإذونات
                  </span>
                  <span class="ijn5q o1g2m pze98 rounded-full">12</span>
                </a>
              </li>
              <!-- الأدوار -->
              <li>
                <a href="#" class="px-3">
                  <span class="icon-[tabler--crown] size-5"></span>
                  الأدوار
                </a>
              </li>
              <li class="text-base-content/50 cwnx3 f1870 text-sm">المدونة</li>
              <!-- الفئات -->
              <li>
                <a href="#" class="px-3">
                  <span class="icon-[tabler--layout-grid-add] size-5"></span>
                  الفئات
                </a>
              </li>
              <!-- العلامات -->
              <li>
                <a href="#" class="px-3">
                  <span class="icon-[tabler--tags] size-5"></span>
                  العلامات
                </a>
              </li>
              <!-- المنشورات -->
              <li>
                <a href="#" class="flex items-center justify-between px-2">
                  <span class="flex items-center bglhu">
                    <span class="icon-[tabler--file-text] size-5"></span>
                    المنشورات
                  </span>
                  <span class="ijn5q o1g2m eq2ma rounded-full">20</span>
                </a>
              </li>
              <!-- التفاصيل -->
              <li>
                <a href="#" class="px-3">
                  <span class="icon-[tabler--chart-dots] size-5"></span>
                  التفاصيل
                </a>
              </li>

              <!-- التعليقات -->
              <li class="accordion-item" id="user-comments">
                <button class="accordion-toggle accordion-item-active:bg-neutral/10 inline-flex items-center f1870 ao5al text-base ejsm2" aria-controls="user-comments-collapse" aria-expanded="true">
                  <span class="icon-[tabler--message-circle] size-6"></span>
                  <span class="sxihv">التعليقات</span>
                  <span class="icon-[tabler--chevron-right] accordion-item-active:rotate-90 size-5 shrink-0 ciihs duration-300 rtl:rotate-180"></span>
                </button>
                <div id="user-comments-collapse" class="accordion-content su75o hidden w-full overflow-hidden transition-[height] duration-300" aria-labelledby="user-comments" role="region">
                  <ul class="kf6hd">
                    <!-- موافق -->
                    <li>
                      <a href="#" class="px-3">موافق</a>
                    </li>
                    <!-- في الانتظار -->
                    <li>
                      <a href="#" class="px-3">في الانتظار</a>
                    </li>
                  </ul>
                </div>
              </li>

              <!-- مشاركة الأكواد -->
              <li>
                <a href="#" class="px-3">
                  <span class="icon-[tabler--share] size-5"></span>
                  مشاركة الأكواد
                </a>
              </li>
              <!-- إعدادات المدونة -->
              <li>
                <a href="#" class="px-3">
                  <span class="icon-[tabler--settings] size-5"></span>
                  الإعدادات
                </a>
              </li>
              <li class="text-base-content/50 cwnx3 f1870 text-sm">النشرة الإخبارية</li>
              <!-- النشرات الإخبارية -->
              <li>
                <a href="#" class="px-3">
                  <span class="icon-[tabler--mail] size-5"></span>
                  النشرات الإخبارية
                </a>
              </li>
              <li class="text-base-content/50 cwnx3 f1870 text-sm">خارطة الطريق</li>
              <!-- خارطة الطريق -->
              <li>
                <a href="#" class="px-3">
                  <span class="icon-[tabler--map] size-5"></span>
                  خارطة الطريق
                </a>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->

    <div class="flex sxihv jz3o6 fyl79 lg:ps-81">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="wpaot w-full owca9 e6ynr sxihv fbpri">
        <div class="dpzny wfsyj ip6vv">
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="wpaot w-full owca9 rukzz">
        <div class="bg-base-100 rounded-box d50ic hg6f0 zw50f"></div>
      </footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>
  </div>


    <script src="https://flyonui.becdn.net/pro/libs/flyonui/flyonui.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const url = window.location.href

      // Check if the URL contains the "theme" parameter
      const themeParam = new URLSearchParams(window.location.search).get("theme")
      const dirRTL = new URLSearchParams(window.location.search).get("rtl")

      // If a theme parameter is present, apply it to the document
      if (themeParam) {
        document.documentElement.setAttribute("data-theme", themeParam)
      }
      if (dirRTL === "true") {
        document.documentElement.setAttribute("dir", "rtl")
      }
    })
  </script>
  

</body>


