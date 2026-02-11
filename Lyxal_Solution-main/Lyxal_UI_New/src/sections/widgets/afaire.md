<div class="bg-base-200 flex min-h-screen items-center justify-center p-6">
    <div class="card shadow-base-300/10 w-full max-w-96 shadow-md">
      <div class="card-header flex items-start justify-between gap-2">
        <div>
          <h4 class="card-title text-xl">Sales by Countries</h4>
          <span class="text-base-content/50 text-sm">Monthly Sales Overview</span>
        </div>
        <div class="dropdown relative inline-flex">
          <button
            id="dropdown-sales-by-countries"
            type="button"
            class="dropdown-toggle btn btn-text text-base-content/50 btn-circle btn-sm"
            aria-haspopup="menu"
            aria-expanded="false"
            aria-label="Dropdown"
          >
            <span class="icon-[tabler--dots-vertical] size-5.5"></span>
          </button>
          <ul
            class="dropdown-menu dropdown-open:opacity-100 hidden"
            role="menu"
            aria-orientation="vertical"
            aria-labelledby="dropdown-sales-by-countries"
          >
            <li><a class="dropdown-item" href="#">Last 28 Days</a></li>
            <li><a class="dropdown-item" href="#">Last Month</a></li>
            <li><a class="dropdown-item" href="#">Last Year</a></li>
          </ul>
        </div>
      </div>
      <div class="card-body">
        <ul class="space-y-6">
          <li>
            <div class="flex items-center gap-3">
              <div class="avatar">
                <div class="size-11 rounded-full">
                  <img
                    src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/widgets/united-states.png"
                    alt="united states flag"
                  />
                </div>
              </div>

              <div class="grow">
                <div class="flex items-center gap-2.5">
                  <h6 class="text-base-content font-medium">$8,564k</h6>
                  <div class="text-error flex items-center">
                    <span class="icon-[tabler--chevron-down] size-4"></span>
                    <p class="text-sm">7.0%</p>
                  </div>
                </div>
                <p class="text-base-content/50 text-sm">United States of America</p>
              </div>

              <span class="text-base-content font-medium">452k</span>
            </div>
          </li>

          <li>
            <div class="flex items-center gap-3">
              <div class="avatar">
                <div class="size-11 rounded-full">
                  <img
                    src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/widgets/canada.png"
                    alt="canada flag"
                  />
                </div>
              </div>

              <div class="grow">
                <div class="flex items-center gap-2.5">
                  <h6 class="text-base-content font-medium">$9,120k</h6>
                  <div class="text-success flex items-center">
                    <span class="icon-[tabler--chevron-up] size-4"></span>
                    <p class="text-sm">6.3%</p>
                  </div>
                </div>
                <p class="text-base-content/50 text-sm">Canada</p>
              </div>

              <span class="text-base-content font-medium">320k</span>
            </div>
          </li>

          <li>
            <div class="flex items-center gap-3">
              <div class="avatar">
                <div class="size-11 rounded-full">
                  <img
                    src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/widgets/australia.png"
                    alt="australia flag"
                  />
                </div>
              </div>

              <div class="grow">
                <div class="flex items-center gap-2.5">
                  <h6 class="text-base-content font-medium">$6,800k</h6>
                  <div class="text-success flex items-center">
                    <span class="icon-[tabler--chevron-up] size-4"></span>
                    <p class="text-sm">5.0%</p>
                  </div>
                </div>
                <p class="text-base-content/50 text-sm">Australia</p>
              </div>

              <span class="text-base-content font-medium">215k</span>
            </div>
          </li>

          <li>
            <div class="flex items-center gap-3">
              <div class="avatar">
                <div class="size-11 rounded-full">
                  <img
                    src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/widgets/germany.png"
                    alt="germany flag"
                  />
                </div>
              </div>

              <div class="grow">
                <div class="flex items-center gap-2.5">
                  <h6 class="text-base-content font-medium">$7,450k</h6>
                  <div class="text-success flex items-center">
                    <span class="icon-[tabler--chevron-up] size-4"></span>
                    <p class="text-sm">4.8%</p>
                  </div>
                </div>
                <p class="text-base-content/50 text-sm">Germany</p>
              </div>

              <span class="text-base-content font-medium">120k</span>
            </div>
          </li>

          <li>
            <div class="flex items-center gap-3">
              <div class="avatar">
                <div class="size-11 rounded-full">
                  <img
                    src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/widgets/england.png"
                    alt="england flag"
                  />
                </div>
              </div>

              <div class="grow">
                <div class="flex items-center gap-2.5">
                  <h6 class="text-base-content font-medium">$10,200k</h6>
                  <div class="text-error flex items-center">
                    <span class="icon-[tabler--chevron-down] size-4"></span>
                    <p class="text-sm">6.3%</p>
                  </div>
                </div>
                <p class="text-base-content/50 text-sm">England</p>
              </div>

              <span class="text-base-content font-medium">75k</span>
            </div>
          </li>
        </ul>
      </div>
    </div>
  </div>

<div class="bg-base-200 flex min-h-screen items-center justify-center p-6">
    <div class="card shadow-base-300/10 w-full max-w-96 shadow-md">
      <div class="card-header flex items-center justify-between gap-2">
        <h4 class="card-title text-xl">Popular Instructors</h4>
        <div class="dropdown relative inline-flex">
          <button
            id="dropdown-popular-instructors"
            type="button"
            class="dropdown-toggle btn btn-text text-base-content/50 btn-circle btn-sm"
            aria-haspopup="menu"
            aria-expanded="false"
            aria-label="Dropdown"
          >
            <span class="icon-[tabler--dots-vertical] size-5.5"></span>
          </button>
          <ul
            class="dropdown-menu dropdown-open:opacity-100 hidden"
            role="menu"
            aria-orientation="vertical"
            aria-labelledby="dropdown-popular-instructors"
          >
            <li><a class="dropdown-item" href="#">Last 28 Days</a></li>
            <li><a class="dropdown-item" href="#">Last Month</a></li>
            <li><a class="dropdown-item" href="#">Last Year</a></li>
          </ul>
        </div>
      </div>
      <div class="card-body gap-6">
        <div class="border-base-content/20 -mx-6 flex items-center justify-between border-y px-6 py-3">
          <span class="text-base-content/80 uppercase">Instructors</span>
          <span class="text-base-content/80 uppercase">courses</span>
        </div>
        <ul class="space-y-5">
          <li>
            <div class="flex items-center gap-3">
              <div class="avatar">
                <div class="rounded-field size-11">
                  <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="avatar" />
                </div>
              </div>
              <div class="grow">
                <h6 class="text-base-content font-medium">Maven Analytics</h6>
                <p class="text-base-content/50 text-sm">Business intelligence</p>
              </div>
              <span class="text-base-content font-medium">33</span>
            </div>
          </li>

          <li>
            <div class="flex items-center gap-3">
              <div class="avatar">
                <div class="rounded-field size-11">
                  <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="avatar" />
                </div>
              </div>
              <div class="grow">
                <h6 class="text-base-content font-medium">Bentlee Emblin</h6>
                <p class="text-base-content/50 text-sm">Data exploration</p>
              </div>
              <span class="text-base-content font-medium">28</span>
            </div>
          </li>

          <li>
            <div class="flex items-center gap-3">
              <div class="avatar">
                <div class="rounded-field size-11">
                  <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="avatar" />
                </div>
              </div>
              <div class="grow">
                <h6 class="text-base-content font-medium">Tableau</h6>
                <p class="text-base-content/50 text-sm">UI/UX Designer</p>
              </div>
              <span class="text-base-content font-medium">45</span>
            </div>
          </li>

          <li>
            <div class="flex items-center gap-3">
              <div class="avatar">
                <div class="rounded-field size-11">
                  <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar" />
                </div>
              </div>
              <div class="grow">
                <h6 class="text-base-content font-medium">Alma Gonzalez</h6>
                <p class="text-base-content/50 text-sm">Java Developer</p>
              </div>
              <span class="text-base-content font-medium">50</span>
            </div>
          </li>

          <li>
            <div class="flex items-center gap-3">
              <div class="avatar">
                <div class="rounded-field size-11">
                  <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-14.png" alt="avatar" />
                </div>
              </div>
              <div class="grow">
                <h6 class="text-base-content font-medium">Beverlie Krabbe</h6>
                <p class="text-base-content/50 text-sm">React Native</p>
              </div>
              <span class="text-base-content font-medium">33</span>
            </div>
          </li>
        </ul>
      </div>
    </div>
  </div>

<body data-vh-checked="true">
  <div class="dhabr flex min-h-screen items-center justify-center fbpri">
    <div class="zq390 d50ic w-full bhk4z shadow-md">
      <div class="l7s0y flex items-center justify-between bglhu">
        <h4 class="iqv7o c9rvi">Employee List</h4>
        <div class="dropdown relative inline-flex">
          <button id="dropdown-employee-list" type="button" class="dropdown-toggle btn btn-text text-base-content/50 btn-circle btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
            <span class="icon-[tabler--dots-vertical] girx5"></span>
          </button>
          <ul class="dropdown-menu dropdown-open:opacity-100 hidden" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-employee-list" tabindex="-1">
            <li><a class="dropdown-item" href="#">Last 28 Days</a></li>
            <li><a class="dropdown-item" href="#">Last Month</a></li>
            <li><a class="dropdown-item" href="#">Last Year</a></li>
          </ul>
        </div>
      </div>
      <div class="nqxya">
        <ul class="o63tj">
          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm">
                <div class="rounded-field j4z3m">
                  <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
                </div>
              </div>
              <div class="sxihv">
                <h6 class="text-base-content mb-0.5 font-medium">Alberta</h6>
                <p class="text-base-content/50 text-sm">UI Designer</p>
              </div>
              <div class="flex items-center bglhu">
                <div class="flex items-center rsqkx">
                  <span class="text-base-content font-medium">100h:</span>
                  <span class="text-base-content/80 text-sm">138h</span>
                </div>
                <div class="g77v8 text-success" style="--value:83; --size:2.25rem; --thickness: 4px;" role="progressbar" aria-label="Radial Progress"></div>
              </div>
            </div>
          </li>
          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm">
                <div class="rounded-field j4z3m">
                  <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="avatar">
                </div>
              </div>
              <div class="sxihv">
                <h6 class="text-base-content mb-0.5 font-medium">Quebec</h6>
                <p class="text-base-content/50 text-sm">Graphic Designer</p>
              </div>
              <div class="flex items-center bglhu">
                <div class="flex items-center rsqkx">
                  <span class="text-base-content font-medium">90h:</span>
                  <span class="text-base-content/80 text-sm">130h</span>
                </div>
                <div class="g77v8 vqa8p" style="--value:68; --size:2.25rem; --thickness: 4px;" role="progressbar" aria-label="Radial Progress"></div>
              </div>
            </div>
          </li>
          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm">
                <div class="rounded-field j4z3m">
                  <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="avatar">
                </div>
              </div>
              <div class="sxihv">
                <h6 class="text-base-content mb-0.5 font-medium">British</h6>
                <p class="text-base-content/50 text-sm">UX Researcher</p>
              </div>
              <div class="flex items-center bglhu">
                <div class="flex items-center rsqkx">
                  <span class="text-base-content font-medium">120h:</span>
                  <span class="text-base-content/80 text-sm">150h</span>
                </div>
                <div class="g77v8 text-primary" style="--value:48; --size:2.25rem; --thickness: 4px;" role="progressbar" aria-label="Radial Progress"></div>
              </div>
            </div>
          </li>
          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm">
                <div class="rounded-field j4z3m">
                  <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="avatar">
                </div>
              </div>
              <div class="sxihv">
                <h6 class="text-base-content mb-0.5 font-medium">Nova Scotia</h6>
                <p class="text-base-content/50 text-sm">Web Developer</p>
              </div>
              <div class="flex items-center bglhu">
                <div class="flex items-center rsqkx">
                  <span class="text-base-content font-medium">115h:</span>
                  <span class="text-base-content/80 text-sm">145h</span>
                </div>
                <div class="g77v8 h7b7g" style="--value:36; --size:2.25rem; --thickness: 4px;" role="progressbar" aria-label="Radial Progress"></div>
              </div>
            </div>
          </li>
          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm">
                <div class="rounded-field j4z3m">
                  <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                </div>
              </div>
              <div class="sxihv">
                <h6 class="text-base-content mb-0.5 font-medium">Ontario</h6>
                <p class="text-base-content/50 text-sm">Product Manager</p>
              </div>
              <div class="flex items-center bglhu">
                <div class="flex items-center rsqkx">
                  <span class="text-base-content font-medium">110h:</span>
                  <span class="text-base-content/80 text-sm">160h</span>
                </div>
                <div class="g77v8 text-error" style="--value:12; --size:2.25rem; --thickness: 4px;" role="progressbar" aria-label="Radial Progress"></div>
              </div>
            </div>
          </li>
        </ul>
      </div>
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
  <div class="dhabr flex min-h-screen items-center justify-center fbpri">
    <div class="zq390 d50ic w-full bhk4z shadow-md">
      <div class="l7s0y flex items-center justify-between bglhu">
        <h4 class="iqv7o c9rvi">Transactions</h4>
        <div class="dropdown relative inline-flex">
          <button id="dropdown-transactions" type="button" class="dropdown-toggle btn btn-text text-base-content/50 btn-circle btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
            <span class="icon-[tabler--dots-vertical] girx5"></span>
          </button>
          <ul class="dropdown-menu dropdown-open:opacity-100 hidden" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-transactions" tabindex="-1">
            <li><a class="dropdown-item" href="#">Last 28 Days</a></li>
            <li><a class="dropdown-item" href="#">Last Month</a></li>
            <li><a class="dropdown-item" href="#">Last Year</a></li>
          </ul>
        </div>
      </div>
      <div class="nqxya">
        <ul class="o63tj">
          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="bmbcn text-success rounded-box kqy8v">
                  <span class="icon-[tabler--credit-card] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Credit Card</h6>
                <p class="text-base-content/50 text-sm">Digital Ocean</p>
              </div>
              <div class="flex items-center eovr6">
                <h6 class="text-base-content font-medium">-$2,820</h6>
                <div class="nfjpm rmjll">
                  <div class="xlsc2 text-error lpcq7 rounded-full">
                    <span class="icon-[tabler--arrow-down] size-4"></span>
                  </div>
                </div>
              </div>
            </div>
          </li>

          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="uyq3n text-primary rounded-box kqy8v">
                  <span class="icon-[tabler--brand-paypal] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Paypal</h6>
                <p class="text-base-content/50 text-sm">Received Money</p>
              </div>
              <div class="flex items-center eovr6">
                <h6 class="text-base-content font-medium">+$1,260</h6>
                <div class="nfjpm rmjll">
                  <div class="bmbcn text-success lpcq7 rounded-full">
                    <span class="icon-[tabler--arrow-up] size-4"></span>
                  </div>
                </div>
              </div>
            </div>
          </li>

          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="xlsc2 text-error rounded-box kqy8v">
                  <span class="icon-[tabler--brand-mastercard] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Mastercard</h6>
                <p class="text-base-content/50 text-sm">Netflix</p>
              </div>
              <div class="flex items-center eovr6">
                <h6 class="text-base-content font-medium">-$149</h6>
                <div class="nfjpm rmjll">
                  <div class="xlsc2 text-error lpcq7 rounded-full">
                    <span class="icon-[tabler--arrow-down] size-4"></span>
                  </div>
                </div>
              </div>
            </div>
          </li>

          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="in7kw lz8uj rounded-box kqy8v">
                  <span class="icon-[tabler--wallet] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Wallet</h6>
                <p class="text-base-content/50 text-sm">Mac’D</p>
              </div>
              <div class="flex items-center eovr6">
                <h6 class="text-base-content font-medium">-$49</h6>
                <div class="nfjpm rmjll">
                  <div class="xlsc2 text-error lpcq7 rounded-full">
                    <span class="icon-[tabler--arrow-down] size-4"></span>
                  </div>
                </div>
              </div>
            </div>
          </li>

          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="uyq3n text-primary rounded-box kqy8v">
                  <span class="icon-[tabler--brand-paypal] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">PayPal</h6>
                <p class="text-base-content/50 text-sm">Refund</p>
              </div>
              <div class="flex items-center eovr6">
                <h6 class="text-base-content font-medium">-$12,820</h6>
                <div class="nfjpm rmjll">
                  <div class="bmbcn text-success lpcq7 rounded-full">
                    <span class="icon-[tabler--arrow-up] size-4"></span>
                  </div>
                </div>
              </div>
            </div>
          </li>

          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="xtk84 h7b7g rounded-box kqy8v">
                  <span class="icon-[tabler--brand-stripe] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Stripe</h6>
                <p class="text-base-content/50 text-sm">Buy Apple Watch</p>
              </div>
              <div class="flex items-center eovr6">
                <h6 class="text-base-content font-medium">-$299</h6>
                <div class="nfjpm rmjll">
                  <div class="xlsc2 text-error lpcq7 rounded-full">
                    <span class="icon-[tabler--arrow-down] size-4"></span>
                  </div>
                </div>
              </div>
            </div>
          </li>
        </ul>
      </div>
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
  <div class="dhabr flex min-h-screen items-center justify-center fbpri">
    <div class="zq390 d50ic w-full vibx7 shadow-md">
      <div class="l7s0y flex items-center justify-between bglhu">
        <h4 class="iqv7o c9rvi">Top Courses</h4>
        <div class="dropdown relative inline-flex">
          <button id="dropdown-top-courses" type="button" class="dropdown-toggle btn btn-text text-base-content/50 btn-circle btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
            <span class="icon-[tabler--dots-vertical] girx5"></span>
          </button>
          <ul class="dropdown-menu dropdown-open:opacity-100 hidden" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-top-courses" tabindex="-1">
            <li><a class="dropdown-item" href="#">Last 28 Days</a></li>
            <li><a class="dropdown-item" href="#">Last Month</a></li>
            <li><a class="dropdown-item" href="#">Last Year</a></li>
          </ul>
        </div>
      </div>
      <div class="nqxya">
        <ul class="o63tj">
          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="bmbcn text-success rounded-box kqy8v">
                  <span class="icon-[tabler--video-minus] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content tn6yl font-medium">Basic Design</h6>
                <p class="text-base-content/50 text-sm">Workshop</p>
              </div>
              <span class="ijn5q o1g2m vn3pt bxh1m">1.2k Views</span>
            </div>
          </li>

          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="in7kw lz8uj rounded-box kqy8v">
                  <span class="icon-[tabler--code] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content tn6yl font-medium">Basic Front-end</h6>
                <p class="text-base-content/50 text-sm">Course</p>
              </div>
              <span class="ijn5q o1g2m vn3pt bxh1m">10k Views</span>
            </div>
          </li>

          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="xlsc2 text-error rounded-box kqy8v">
                  <span class="icon-[tabler--credit-card] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content tn6yl font-medium">Advance Of UX</h6>
                <p class="text-base-content/50 text-sm">Workshop</p>
              </div>
              <span class="ijn5q o1g2m vn3pt bxh1m">8.4k Views</span>
            </div>
          </li>

          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="xtk84 h7b7g rounded-box kqy8v">
                  <span class="icon-[tabler--credit-card] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content tn6yl font-medium">Advance Dribble</h6>
                <p class="text-base-content/50 text-sm">Course</p>
              </div>
              <span class="ijn5q o1g2m vn3pt bxh1m">5.2k Views</span>
            </div>
          </li>

          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="rounded-box uyq3n text-primary kqy8v">
                  <span class="icon-[tabler--credit-card] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content tn6yl font-medium">Singing Lesson</h6>
                <p class="text-base-content/50 text-sm">Singing Lesson</p>
              </div>
              <span class="ijn5q o1g2m vn3pt bxh1m">1.6k Views</span>
            </div>
          </li>
        </ul>
      </div>
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
  <div class="dhabr flex min-h-screen items-center justify-center fbpri">
    <div class="zq390 d50ic w-full ubufv shadow-md">
      <div class="l7s0y flex items-center justify-between bglhu">
        <h4 class="iqv7o bk5oo">Total Earning</h4>
        <div class="dropdown relative inline-flex">
          <button id="dropdown-earning" type="button" class="dropdown-toggle btn btn-text text-base-content/50 btn-circle btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
            <span class="icon-[tabler--dots-vertical] girx5"></span>
          </button>
          <ul class="dropdown-menu dropdown-open:opacity-100 hidden" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-earning" tabindex="-1">
            <li><a class="dropdown-item" href="#">Last 28 Days</a></li>
            <li><a class="dropdown-item" href="#">Last Month</a></li>
            <li><a class="dropdown-item" href="#">Last Year</a></li>
          </ul>
        </div>
      </div>
      <div class="nqxya ip6vv">
        <div class="flex items-center justify-between">
          <div class="pqjas">
            <div class="flex items-center rsqkx">
              <h3 class="text-base-content ay6fz t3mfo">$24,650</h3>
              <div class="text-success flex items-center">
                <span class="icon-[tabler--chevron-up] size-6"></span>
                <p>10%</p>
              </div>
            </div>
            <p class="text-base-content/50 text-sm">Compared to $84,325 last yaear</p>
          </div>
        </div>

        <ul class="hrl4t">
          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="dhabr rounded-box ueghp">
                  <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/widgets/zipcar.png" alt="zipcar logo" class="size-6">
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Zipcar</h6>
                <p class="text-base-content/50 text-sm">Vuejs, React &amp; HTML</p>
              </div>
              <div class="flex jz3o6 bglhu">
                <h6 class="text-base-content font-medium">-$24,820.35</h6>
                <div class="progress emav0" role="progressbar" aria-label="Primary Progressbar" aria-valuenow="75" aria-valuemin="0" aria-valuemax="100">
                  <div class="progress-bar progress-primary pf9qp"></div>
                </div>
              </div>
            </div>
          </li>

          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="dhabr rounded-box ueghp">
                  <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/widgets/bitbank.png" alt="bitbank logo" class="size-6">
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Bitbank</h6>
                <p class="text-base-content/50 text-sm">Sketch, Figma &amp; XD</p>
              </div>
              <div class="flex jz3o6 bglhu">
                <h6 class="text-base-content font-medium">-$86,350.10</h6>
                <div class="progress emav0" role="progressbar" aria-label="Info Progressbar" aria-valuenow="50" aria-valuemin="0" aria-valuemax="100">
                  <div class="progress-bar aybci nq7eq"></div>
                </div>
              </div>
            </div>
          </li>

          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="dhabr rounded-box ueghp">
                  <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/widgets/aviato.png" alt="aviato logo" class="size-6">
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Aviato</h6>
                <p class="text-base-content/50 text-sm">HTML &amp; Angular</p>
              </div>
              <div class="flex jz3o6 bglhu">
                <h6 class="text-base-content font-medium">-$55,699.60</h6>
                <div class="progress emav0" role="progressbar" aria-label="Success Progressbar" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">
                  <div class="progress-bar xiqbe hkd2z"></div>
                </div>
              </div>
            </div>
          </li>
        </ul>
      </div>
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
  <div class="dhabr flex min-h-screen items-center justify-center fbpri">
    <div class="zq390 d50ic w-full ubufv shadow-md">
      <div class="l7s0y flex qojvm justify-between bglhu">
        <div>
          <h4 class="iqv7o c9rvi">Order Statistics</h4>
          <span class="text-base-content/80 text-sm">42.82K Total Sales</span>
        </div>
        <div class="dropdown relative inline-flex">
          <button id="dropdown-order-statistics" type="button" class="dropdown-toggle btn btn-text text-base-content/50 btn-circle btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
            <span class="icon-[tabler--dots-vertical] girx5"></span>
          </button>
          <ul class="dropdown-menu dropdown-open:opacity-100 hidden" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-order-statistics" tabindex="-1">
            <li><a class="dropdown-item" href="#">Last 28 Days</a></li>
            <li><a class="dropdown-item" href="#">Last Month</a></li>
            <li><a class="dropdown-item" href="#">Last Year</a></li>
          </ul>
        </div>
      </div>
      <div class="nqxya ip6vv">
        <div class="flex items-center justify-between">
          <div class="pqjas">
            <h3 class="text-base-content pifxk t3mfo">13,478</h3>
            <p class="text-base-content/50 font-medium">Total Orders</p>
          </div>
          <div id="orderStatisticsChart" style="min-height: 118px;"><div id="apexchartsgkmy74e7" class="apexcharts-canvas apexchartsgkmy74e7 apexcharts-theme-light" style="width: 136px; height: 118px;"><svg xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" class="apexcharts-svg" xmlns:data="ApexChartsNS" transform="translate(15, 0)" width="136" height="118"><foreignObject x="0" y="0" width="136" height="118"><style type="text/css">
      .apexcharts-flip-y {
        transform: scaleY(-1) translateY(-100%);
        transform-origin: top;
        transform-box: fill-box;
      }
      .apexcharts-flip-x {
        transform: scaleX(-1);
        transform-origin: center;
        transform-box: fill-box;
      }
      .apexcharts-legend {
        display: flex;
        overflow: auto;
        padding: 0 10px;
      }
      .apexcharts-legend.apexcharts-legend-group-horizontal {
        flex-direction: column;
      }
      .apexcharts-legend-group {
        display: flex;
      }
      .apexcharts-legend-group-vertical {
        flex-direction: column-reverse;
      }
      .apexcharts-legend.apx-legend-position-bottom, .apexcharts-legend.apx-legend-position-top {
        flex-wrap: wrap
      }
      .apexcharts-legend.apx-legend-position-right, .apexcharts-legend.apx-legend-position-left {
        flex-direction: column;
        bottom: 0;
      }
      .apexcharts-legend.apx-legend-position-bottom.apexcharts-align-left, .apexcharts-legend.apx-legend-position-top.apexcharts-align-left, .apexcharts-legend.apx-legend-position-right, .apexcharts-legend.apx-legend-position-left {
        justify-content: flex-start;
        align-items: flex-start;
      }
      .apexcharts-legend.apx-legend-position-bottom.apexcharts-align-center, .apexcharts-legend.apx-legend-position-top.apexcharts-align-center {
        justify-content: center;
        align-items: center;
      }
      .apexcharts-legend.apx-legend-position-bottom.apexcharts-align-right, .apexcharts-legend.apx-legend-position-top.apexcharts-align-right {
        justify-content: flex-end;
        align-items: flex-end;
      }
      .apexcharts-legend-series {
        cursor: pointer;
        line-height: normal;
        display: flex;
        align-items: center;
      }
      .apexcharts-legend-text {
        position: relative;
        font-size: 14px;
      }
      .apexcharts-legend-text *, .apexcharts-legend-marker * {
        pointer-events: none;
      }
      .apexcharts-legend-marker {
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        margin-right: 1px;
      }

      .apexcharts-legend-series.apexcharts-no-click {
        cursor: auto;
      }
      .apexcharts-legend .apexcharts-hidden-zero-series, .apexcharts-legend .apexcharts-hidden-null-series {
        display: none !important;
      }
      .apexcharts-inactive-legend {
        opacity: 0.45;
      }

    </style></foreignObject><g class="apexcharts-inner apexcharts-graphical" transform="translate(0, 0)"><defs><clipPath id="gridRectMaskgkmy74e7"><rect width="130" height="164" x="-4.5" y="-4.5" rx="0" ry="0" opacity="1" stroke-width="0" stroke="none" stroke-dasharray="0" fill="#fff"></rect></clipPath><clipPath id="gridRectBarMaskgkmy74e7"><rect width="130" height="164" x="-4.5" y="-4.5" rx="0" ry="0" opacity="1" stroke-width="0" stroke="none" stroke-dasharray="0" fill="#fff"></rect></clipPath><clipPath id="gridRectMarkerMaskgkmy74e7"><rect width="121" height="155" x="0" y="0" rx="0" ry="0" opacity="1" stroke-width="0" stroke="none" stroke-dasharray="0" fill="#fff"></rect></clipPath><clipPath id="forecastMaskgkmy74e7"></clipPath><clipPath id="nonForecastMaskgkmy74e7"></clipPath></defs><g class="apexcharts-pie"><g transform="translate(0, 0) scale(1)"><circle r="37.518292682926834" cx="60.5" cy="60.5" fill="transparent"></circle><g class="apexcharts-slices"><g class="apexcharts-series apexcharts-pie-series" seriesName="Electronic" rel="1" data:realIndex="0"><path d="M 60.5 10.475609756097555 A 50.024390243902445 50.024390243902445 0 0 1 110.52439024390245 60.5 L 98.01829268292684 60.5 A 37.518292682926834 37.518292682926834 0 0 0 60.5 22.981707317073166 L 60.5 10.475609756097555 z " fill="var(--color-success)" fill-opacity="1" stroke="var(--color-base-100)" stroke-opacity="1" stroke-linecap="butt" stroke-width="5" stroke-dasharray="0" class="apexcharts-pie-area apexcharts-donut-slice-0" index="0" j="0" data:angle="90" data:startAngle="0" data:strokeWidth="5" data:value="50" data:pathOrig="M 60.5 10.475609756097555 A 50.024390243902445 50.024390243902445 0 0 1 110.52439024390245 60.5 L 98.01829268292684 60.5 A 37.518292682926834 37.518292682926834 0 0 0 60.5 22.981707317073166 L 60.5 10.475609756097555 z "></path></g><g class="apexcharts-series apexcharts-pie-series" seriesName="Sports" rel="2" data:realIndex="1"><path d="M 110.52439024390245 60.5 A 50.024390243902445 50.024390243902445 0 0 1 15.92794192413799 83.21059792599539 L 27.07095644310349 77.53294844449654 A 37.518292682926834 37.518292682926834 0 0 0 98.01829268292684 60.5 L 110.52439024390245 60.5 z " fill="var(--color-primary)" fill-opacity="1" stroke="var(--color-base-100)" stroke-opacity="1" stroke-linecap="butt" stroke-width="5" stroke-dasharray="0" class="apexcharts-pie-area apexcharts-donut-slice-1" index="0" j="1" data:angle="153" data:startAngle="90" data:strokeWidth="5" data:value="85" data:pathOrig="M 110.52439024390245 60.5 A 50.024390243902445 50.024390243902445 0 0 1 15.92794192413799 83.21059792599539 L 27.07095644310349 77.53294844449654 A 37.518292682926834 37.518292682926834 0 0 0 98.01829268292684 60.5 L 110.52439024390245 60.5 z "></path></g><g class="apexcharts-series apexcharts-pie-series" seriesName="Decor" rel="3" data:realIndex="2"><path d="M 15.92794192413799 83.21059792599539 A 50.024390243902445 50.024390243902445 0 0 1 12.923977684844871 45.04161328138981 L 24.817983263633657 48.90620996104236 A 37.518292682926834 37.518292682926834 0 0 0 27.07095644310349 77.53294844449654 L 15.92794192413799 83.21059792599539 z " fill="var(--color-secondary)" fill-opacity="1" stroke="var(--color-base-100)" stroke-opacity="1" stroke-linecap="butt" stroke-width="5" stroke-dasharray="0" class="apexcharts-pie-area apexcharts-donut-slice-2" index="0" j="2" data:angle="45" data:startAngle="243" data:strokeWidth="5" data:value="25" data:pathOrig="M 15.92794192413799 83.21059792599539 A 50.024390243902445 50.024390243902445 0 0 1 12.923977684844871 45.04161328138981 L 24.817983263633657 48.90620996104236 A 37.518292682926834 37.518292682926834 0 0 0 27.07095644310349 77.53294844449654 L 15.92794192413799 83.21059792599539 z "></path></g><g class="apexcharts-series apexcharts-pie-series" seriesName="Fashion" rel="4" data:realIndex="3"><path d="M 12.923977684844871 45.04161328138981 A 50.024390243902445 50.024390243902445 0 0 1 60.491269096883734 10.475610518012587 L 60.4934518226628 22.98170788850944 A 37.518292682926834 37.518292682926834 0 0 0 24.817983263633657 48.90620996104236 L 12.923977684844871 45.04161328138981 z " fill="var(--color-info)" fill-opacity="1" stroke="var(--color-base-100)" stroke-opacity="1" stroke-linecap="butt" stroke-width="5" stroke-dasharray="0" class="apexcharts-pie-area apexcharts-donut-slice-3" index="0" j="3" data:angle="72" data:startAngle="288" data:strokeWidth="5" data:value="40" data:pathOrig="M 12.923977684844871 45.04161328138981 A 50.024390243902445 50.024390243902445 0 0 1 60.491269096883734 10.475610518012587 L 60.4934518226628 22.98170788850944 A 37.518292682926834 37.518292682926834 0 0 0 24.817983263633657 48.90620996104236 L 12.923977684844871 45.04161328138981 z "></path></g></g></g><g class="apexcharts-datalabels-group" transform="translate(0, 0) scale(1)"><text x="60.5" y="77.5" text-anchor="middle" dominant-baseline="auto" font-size="14px" font-family="Helvetica, Arial, sans-serif" font-weight="500" fill="color-mix(in oklab, var(--color-base-content) 80%, transparent)" class="apexcharts-text apexcharts-datalabel-label" style="font-family: Helvetica, Arial, sans-serif;">Weekly</text><text x="60.5" y="59.5" text-anchor="middle" dominant-baseline="auto" font-size="1rem" font-family="Helvetica, Arial, sans-serif" font-weight="600" fill="var(--color-base-content)" class="apexcharts-text apexcharts-datalabel-value" style="font-family: Helvetica, Arial, sans-serif;">38%</text></g></g><line x1="0" y1="0" x2="121" y2="0" stroke="#b6b6b6" stroke-dasharray="0" stroke-width="1" stroke-linecap="butt" class="apexcharts-ycrosshairs"></line><line x1="0" y1="0" x2="121" y2="0" stroke="#b6b6b6" stroke-dasharray="0" stroke-width="0" stroke-linecap="butt" class="apexcharts-ycrosshairs-hidden"></line></g><g class="apexcharts-datalabels-group" transform="translate(0, 0) scale(1)"></g></svg><div class="apexcharts-legend"></div><div class="apexcharts-tooltip apexcharts-theme-dark"><div class="apexcharts-tooltip-series-group apexcharts-tooltip-series-group-0" style="order: 1;"><span class="apexcharts-tooltip-marker" shape="circle" style="background-color: var(--color-success);"></span><div class="apexcharts-tooltip-text" style="font-family: Helvetica, Arial, sans-serif; font-size: 12px;"><div class="apexcharts-tooltip-y-group"><span class="apexcharts-tooltip-text-y-label"></span><span class="apexcharts-tooltip-text-y-value"></span></div><div class="apexcharts-tooltip-goals-group"><span class="apexcharts-tooltip-text-goals-label"></span><span class="apexcharts-tooltip-text-goals-value"></span></div><div class="apexcharts-tooltip-z-group"><span class="apexcharts-tooltip-text-z-label"></span><span class="apexcharts-tooltip-text-z-value"></span></div></div></div><div class="apexcharts-tooltip-series-group apexcharts-tooltip-series-group-1" style="order: 2;"><span class="apexcharts-tooltip-marker" shape="circle" style="background-color: var(--color-primary);"></span><div class="apexcharts-tooltip-text" style="font-family: Helvetica, Arial, sans-serif; font-size: 12px;"><div class="apexcharts-tooltip-y-group"><span class="apexcharts-tooltip-text-y-label"></span><span class="apexcharts-tooltip-text-y-value"></span></div><div class="apexcharts-tooltip-goals-group"><span class="apexcharts-tooltip-text-goals-label"></span><span class="apexcharts-tooltip-text-goals-value"></span></div><div class="apexcharts-tooltip-z-group"><span class="apexcharts-tooltip-text-z-label"></span><span class="apexcharts-tooltip-text-z-value"></span></div></div></div><div class="apexcharts-tooltip-series-group apexcharts-tooltip-series-group-2" style="order: 3;"><span class="apexcharts-tooltip-marker" shape="circle" style="background-color: var(--color-secondary);"></span><div class="apexcharts-tooltip-text" style="font-family: Helvetica, Arial, sans-serif; font-size: 12px;"><div class="apexcharts-tooltip-y-group"><span class="apexcharts-tooltip-text-y-label"></span><span class="apexcharts-tooltip-text-y-value"></span></div><div class="apexcharts-tooltip-goals-group"><span class="apexcharts-tooltip-text-goals-label"></span><span class="apexcharts-tooltip-text-goals-value"></span></div><div class="apexcharts-tooltip-z-group"><span class="apexcharts-tooltip-text-z-label"></span><span class="apexcharts-tooltip-text-z-value"></span></div></div></div><div class="apexcharts-tooltip-series-group apexcharts-tooltip-series-group-3" style="order: 4;"><span class="apexcharts-tooltip-marker" shape="circle" style="background-color: var(--color-info);"></span><div class="apexcharts-tooltip-text" style="font-family: Helvetica, Arial, sans-serif; font-size: 12px;"><div class="apexcharts-tooltip-y-group"><span class="apexcharts-tooltip-text-y-label"></span><span class="apexcharts-tooltip-text-y-value"></span></div><div class="apexcharts-tooltip-goals-group"><span class="apexcharts-tooltip-text-goals-label"></span><span class="apexcharts-tooltip-text-goals-value"></span></div><div class="apexcharts-tooltip-z-group"><span class="apexcharts-tooltip-text-z-label"></span><span class="apexcharts-tooltip-text-z-value"></span></div></div></div></div></div></div>
        </div>

        <ul class="o63tj">
          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="in7kw lz8uj rounded-box kqy8v">
                  <span class="icon-[tabler--device-tablet] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Electronic</h6>
                <p class="text-base-content/50 text-sm">Mobile, Earbuds, TV</p>
              </div>
              <h6 class="text-base-content/80 text-sm font-medium">82.5k</h6>
            </div>
          </li>
          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="uyq3n text-primary rounded-box kqy8v">
                  <span class="icon-[tabler--hanger] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Fashion</h6>
                <p class="text-base-content/50 text-sm">Shirts, Jeans, Shoes</p>
              </div>
              <h6 class="text-base-content/80 text-sm font-medium">23.8k</h6>
            </div>
          </li>
          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="xtk84 h7b7g rounded-box kqy8v">
                  <span class="icon-[tabler--home-2] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Total Expenses</h6>
                <p class="text-base-content/50 text-sm">ADVT, Marketing</p>
              </div>
              <h6 class="text-base-content/80 text-sm font-medium">849k</h6>
            </div>
          </li>
          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="xtl4z prnu1 rounded-box kqy8v">
                  <span class="icon-[tabler--ball-basketball] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Sports</h6>
                <p class="text-base-content/50 text-sm">Football, Cricket Kit</p>
              </div>
              <h6 class="text-base-content/80 text-sm font-medium">10.9k</h6>
            </div>
          </li>
        </ul>
      </div>
    </div>
  </div>

  <script src="https://flyonui.becdn.net/pro/libs/apexcharts/dist/apexcharts.min.js"></script>
  <script src="https://flyonui.becdn.net/pro/libs/lodash/lodash.min.js"></script>
  <script src="https://flyonui.becdn.net/pro/libs/flyonui/dist/helper-apexcharts.js"></script>

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

  <script>
    window.addEventListener("load", () => {
      ;(function () {
        // Order Statistics Chart
        buildChart("#orderStatisticsChart", () => ({
          chart: {
            height: 155,
            width: 136,
            type: "donut",
            offsetX: 15
          },
          labels: ["Electronic", "Sports", "Decor", "Fashion"],
          series: [50, 85, 25, 40],
          colors: ["var(--color-success)", "var(--color-primary)", "var(--color-secondary)", "var(--color-info)"],
          stroke: {
            width: 5,
            colors: ["var(--color-base-100)"]
          },
          dataLabels: {
            enabled: false,
            formatter: function (val, opt) {
              return parseInt(val) + "%"
            }
          },
          legend: {
            show: false
          },
          grid: {
            padding: {
              top: 0,
              bottom: 0,
              right: 15
            }
          },
          plotOptions: {
            pie: {
              donut: {
                size: "75%",
                labels: {
                  show: true,
                  value: {
                    fontSize: "1rem",
                    fontWeight: 600,
                    color: "var(--color-base-content)",
                    offsetY: -17,
                    formatter: function (val) {
                      return parseInt(val) + "%"
                    }
                  },
                  name: {
                    offsetY: 17
                  },
                  total: {
                    show: true,
                    fontSize: "14px",
                    fontWeight: 500,
                    color: "color-mix(in oklab, var(--color-base-content) 80%, transparent)",
                    label: "Weekly",
                    formatter: function (w) {
                      return "38%"
                    }
                  }
                }
              }
            }
          },
          states: {
            active: {
              filter: {
                type: "none"
              }
            }
          }
        }))
      })()
    })
  </script>
  

</body>

<body data-vh-checked="true">
  <div class="dhabr flex min-h-screen items-center justify-center fbpri">
    <div class="zq390 d50ic w-full bhk4z shadow-md">
      <div class="l7s0y flex items-center justify-between bglhu">
        <h4 class="iqv7o c9rvi">Vehicles Condition</h4>
        <div class="dropdown relative inline-flex">
          <button id="dropdown-vehicle-condition" type="button" class="dropdown-toggle btn btn-text text-base-content/50 btn-circle btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
            <span class="icon-[tabler--dots-vertical] girx5"></span>
          </button>
          <ul class="dropdown-menu dropdown-open:opacity-100 hidden" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-vehicle-condition" tabindex="-1">
            <li><a class="dropdown-item" href="#">Last 28 Days</a></li>
            <li><a class="dropdown-item" href="#">Last Month</a></li>
            <li><a class="dropdown-item" href="#">Last Year</a></li>
          </ul>
        </div>
      </div>
      <div class="nqxya">
        <ul class="o63tj">
          <li>
            <div class="flex items-center sly4q">
              <div class="g77v8 text-success shrink-0" style="--value:83; --size:3.25rem; --thickness: 4px;" role="progressbar" aria-label="83% Radial Progressbar">
                <span class="text-base-content">83%</span>
              </div>
              <div class="sxihv">
                <h6 class="text-base-content font-medium">Package in transit</h6>
                <p class="text-base-content/80 text-sm">12% increase in this month</p>
              </div>
              <span class="ijn5q bxh1m">+10%</span>
            </div>
          </li>
          <li>
            <div class="flex items-center sly4q">
              <div class="g77v8 vqa8p shrink-0" style="--value:68; --size:3.25rem; --thickness: 4px;" role="progressbar" aria-label="68% Radial Progressbar">
                <span class="text-base-content">68%</span>
              </div>
              <div class="sxihv">
                <h6 class="text-base-content font-medium">Good</h6>
                <p class="text-base-content/80 text-sm">24 Vehicles</p>
              </div>
              <span class="ijn5q bxh1m">+8.1%</span>
            </div>
          </li>
          <li>
            <div class="flex items-center sly4q">
              <div class="g77v8 text-primary shrink-0" style="--value:48; --size:3.25rem; --thickness: 4px;" role="progressbar" aria-label="48% Radial Progressbar">
                <span class="text-base-content">48%</span>
              </div>
              <div class="sxihv">
                <h6 class="text-base-content font-medium">Average</h6>
                <p class="text-base-content/80 text-sm">182 Tasks</p>
              </div>
              <span class="ijn5q bxh1m">-2.5%</span>
            </div>
          </li>
          <li>
            <div class="flex items-center sly4q">
              <div class="g77v8 h7b7g shrink-0" style="--value:36; --size:3.25rem; --thickness: 4px;" role="progressbar" aria-label="36% Radial Progressbar">
                <span class="text-base-content">36%</span>
              </div>
              <div class="sxihv">
                <h6 class="text-base-content font-medium">Bad</h6>
                <p class="text-base-content/80 text-sm">8 Vehicles</p>
              </div>
              <span class="ijn5q bxh1m">-3.4%</span>
            </div>
          </li>
          <li>
            <div class="flex items-center sly4q">
              <div class="g77v8 text-error shrink-0" style="--value:12; --size:3.25rem; --thickness: 4px;" role="progressbar" aria-label="12% Radial Progressbar">
                <span class="text-base-content">12%</span>
              </div>
              <div class="sxihv">
                <h6 class="text-base-content font-medium">Not Working</h6>
                <p class="text-base-content/80 text-sm">4 Vehicles</p>
              </div>
              <span class="ijn5q bxh1m">+12.6%</span>
            </div>
          </li>
        </ul>
      </div>
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
  <div class="dhabr flex min-h-screen items-center justify-center fbpri">
    <div class="zq390 d50ic w-full bhk4z shadow-md">
      <div class="l7s0y flex qojvm justify-between bglhu">
        <div>
          <h4 class="iqv7o c9rvi">Delivery Performance</h4>
          <span class="text-base-content/80 font-medium">12% increase in this month</span>
        </div>
        <div class="dropdown relative inline-flex">
          <button id="dropdown-delivery-performance" type="button" class="dropdown-toggle btn btn-text text-base-content/50 btn-circle btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
            <span class="icon-[tabler--dots-vertical] girx5"></span>
          </button>
          <ul class="dropdown-menu dropdown-open:opacity-100 hidden" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-delivery-performance" tabindex="-1">
            <li><a class="dropdown-item" href="#">Last 28 Days</a></li>
            <li><a class="dropdown-item" href="#">Last Month</a></li>
            <li><a class="dropdown-item" href="#">Last Year</a></li>
          </ul>
        </div>
      </div>
      <div class="nqxya">
        <ul class="o63tj">
          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="bmbcn text-success rounded-box kqy8v">
                  <span class="icon-[tabler--box] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Package in transit</h6>
                <div class="text-success flex items-center eovr6">
                  <span class="icon-[tabler--chevron-up] qmuz4"></span>
                  <p class="text-sm">25.8%</p>
                </div>
              </div>
              <span class="text-base-content/80 text-sm font-medium">10k</span>
            </div>
          </li>

          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="uyq3n text-primary rounded-box kqy8v">
                  <span class="icon-[tabler--truck] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Package out for delivery</h6>
                <div class="text-success flex items-center eovr6">
                  <span class="icon-[tabler--chevron-up] qmuz4"></span>
                  <p class="text-sm">4.3%</p>
                </div>
              </div>
              <span class="text-base-content/80 text-sm font-medium">5k</span>
            </div>
          </li>

          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="xlsc2 text-error rounded-box kqy8v">
                  <span class="icon-[tabler--checkbox] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Package delivered</h6>
                <div class="text-error flex items-center eovr6">
                  <span class="icon-[tabler--chevron-down] qmuz4"></span>
                  <p class="text-sm">12.5%</p>
                </div>
              </div>
              <span class="text-base-content/80 text-sm font-medium">15k</span>
            </div>
          </li>

          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="in7kw lz8uj rounded-box kqy8v">
                  <span class="icon-[tabler--percentage] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Delivery success rate</h6>
                <div class="text-success flex items-center eovr6">
                  <span class="icon-[tabler--chevron-up] qmuz4"></span>
                  <p class="text-sm">34.3%</p>
                </div>
              </div>
              <span class="text-base-content/80 text-sm font-medium">95%</span>
            </div>
          </li>

          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="rounded-box uyq3n text-primary kqy8v">
                  <span class="icon-[tabler--clock] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Average delivery time</h6>
                <div class="text-error flex items-center eovr6">
                  <span class="icon-[tabler--chevron-down] qmuz4"></span>
                  <p class="text-sm">4.6%</p>
                </div>
              </div>
              <span class="text-base-content/80 text-sm font-medium">2.5 Days</span>
            </div>
          </li>

          <li>
            <div class="flex items-center sly4q">
              <div class="nfjpm rmjll">
                <div class="xtk84 h7b7g rounded-box kqy8v">
                  <span class="icon-[tabler--users] size-6"></span>
                </div>
              </div>

              <div class="sxihv">
                <h6 class="text-base-content font-medium">Customer satisfaction</h6>
                <div class="text-success flex items-center eovr6">
                  <span class="icon-[tabler--chevron-up] qmuz4"></span>
                  <p class="text-sm">5.8%</p>
                </div>
              </div>
              <span class="text-base-content/80 text-sm font-medium">4.5/5</span>
            </div>
          </li>
        </ul>
      </div>
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
  <div class="dhabr flex min-h-screen items-center justify-center fbpri">
    <div class="zq390 d50ic w-full bhk4z shadow-md">
      <div class="l7s0y flex qojvm justify-between bglhu">
        <div>
          <h4 class="iqv7o c9rvi">Orders by Countries</h4>
          <span class="text-base-content/80 font-medium">62 deliveries in progress</span>
        </div>
        <div class="dropdown relative inline-flex">
          <button id="dropdown-order-countries" type="button" class="dropdown-toggle btn btn-text text-base-content/50 btn-circle btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
            <span class="icon-[tabler--dots-vertical] girx5"></span>
          </button>
          <ul class="dropdown-menu dropdown-open:opacity-100 hidden" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-order-countries" tabindex="-1">
            <li><a class="dropdown-item" href="#">Last 28 Days</a></li>
            <li><a class="dropdown-item" href="#">Last Month</a></li>
            <li><a class="dropdown-item" href="#">Last Year</a></li>
          </ul>
        </div>
      </div>
      <div class="nqxya ma6fd cbpaz">
        <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist">
          <button type="button" class="vfeps active-tab:tab-active active w-full font-medium" id="new" data-tab="#new-content" aria-controls="new-content" role="tab" aria-selected="true">
            New
          </button>
          <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="preparing" data-tab="#preparing-content" aria-controls="preparing-content" role="tab" aria-selected="false">
            Preparing
          </button>
          <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="shipping" data-tab="#shipping-content" aria-controls="shipping-content" role="tab" aria-selected="false">
            Shipping
          </button>
        </nav>
        <div class="rukzz egd50">
          <div id="new-content" class="hrl4t" role="tabpanel" aria-labelledby="new">
            <ul class="oz2q8 buloa qtuzj d303h w-full">
              <!-- timeline item 1-->
              <li>
                <div class="ruxvk">
                  <span class="icon-[tabler--circle-check] text-success size-5"></span>
                </div>
                <div class="hkbp5 hei78 ms-2 w-full adede">
                  <div class="text-success text-sm font-medium vxiam">Sender</div>
                  <h6 class="text-base-content font-medium">Myrtle Ullrich</h6>
                  <p class="text-base-content/80 text-sm">101 Boulder, California(CA), 95959</p>
                </div>
                <hr>
              </li>
              <!-- /timeline item 1-->

              <!-- timeline item 2-->
              <li>
                <div class="ruxvk">
                  <span class="icon-[tabler--map-pin] text-primary size-5"></span>
                </div>
                <div class="hkbp5 hei78 ms-2 w-full adede">
                  <div class="text-primary text-sm font-medium vxiam">Receiver</div>
                  <h6 class="text-base-content font-medium">Barry Schowalter</h6>
                  <p class="text-base-content/80 text-sm">939 Orange, California(CA), 92118</p>
                </div>
              </li>
            </ul>

            <div class="ck7pw egxbv"></div>

            <ul class="oz2q8 buloa qtuzj d303h w-full">
              <!-- timeline item 1-->
              <li>
                <div class="ruxvk">
                  <span class="icon-[tabler--circle-check] text-success size-5"></span>
                </div>
                <div class="hkbp5 hei78 ms-2 w-full adede">
                  <div class="text-success text-sm font-medium vxiam">Sender</div>
                  <h6 class="text-base-content font-medium">Veronica Herman</h6>
                  <p class="text-base-content/80 text-sm">162 Windsor, California(CA), 95492</p>
                </div>
                <hr>
              </li>
              <!-- /timeline item 1-->

              <!-- timeline item 2-->
              <li>
                <div class="ruxvk">
                  <span class="icon-[tabler--map-pin] text-primary size-5"></span>
                </div>
                <div class="hkbp5 hei78 ms-2 w-full adede">
                  <div class="text-primary text-sm font-medium vxiam">Receiver</div>
                  <h6 class="text-base-content font-medium">Helen Jacobs</h6>
                  <p class="text-base-content/80 text-sm">487 Sunset, California(CA), 94043</p>
                </div>
              </li>
            </ul>
          </div>

          <div id="preparing-content" class="hidden hrl4t" role="tabpanel" aria-labelledby="preparing">
            <ul class="oz2q8 buloa qtuzj d303h w-full">
              <!-- timeline item 1-->
              <li>
                <div class="ruxvk">
                  <span class="icon-[tabler--circle-check] text-success size-5"></span>
                </div>
                <div class="hkbp5 hei78 ms-2 w-full adede">
                  <div class="text-success text-sm font-medium vxiam">Sender</div>
                  <h6 class="text-base-content font-medium">John Mitchell</h6>
                  <p class="text-base-content/80 text-sm">456 Pine Street, Nevada(NV), 89101</p>
                </div>
                <hr>
              </li>
              <!-- /timeline item 1-->

              <!-- timeline item 2-->
              <li>
                <div class="ruxvk">
                  <span class="icon-[tabler--map-pin] text-primary size-5"></span>
                </div>
                <div class="hkbp5 hei78 ms-2 w-full adede">
                  <div class="text-primary text-sm font-medium vxiam">Receiver</div>
                  <h6 class="text-base-content font-medium">Sarah Thompson</h6>
                  <p class="text-base-content/80 text-sm">789 Oak Avenue, Texas(TX), 75201</p>
                </div>
              </li>
            </ul>

            <div class="ck7pw egxbv"></div>

            <ul class="oz2q8 buloa qtuzj d303h w-full">
              <!-- timeline item 1-->
              <li>
                <div class="ruxvk">
                  <span class="icon-[tabler--circle-check] text-success size-5"></span>
                </div>
                <div class="hkbp5 hei78 ms-2 w-full adede">
                  <div class="text-success text-sm font-medium vxiam">Sender</div>
                  <h6 class="text-base-content font-medium">Michael Rodriguez</h6>
                  <p class="text-base-content/80 text-sm">321 Maple Drive, Florida(FL), 33101</p>
                </div>
                <hr>
              </li>
              <!-- /timeline item 1-->

              <!-- timeline item 2-->
              <li>
                <div class="ruxvk">
                  <span class="icon-[tabler--map-pin] text-primary size-5"></span>
                </div>
                <div class="hkbp5 hei78 ms-2 w-full adede">
                  <div class="text-primary text-sm font-medium vxiam">Receiver</div>
                  <h6 class="text-base-content font-medium">Emily Davis</h6>
                  <p class="text-base-content/80 text-sm">654 Cedar Lane, New York(NY), 10001</p>
                </div>
              </li>
            </ul>
          </div>

          <div id="shipping-content" class="hidden hrl4t" role="tabpanel" aria-labelledby="shipping">
            <ul class="oz2q8 buloa qtuzj d303h w-full">
              <!-- timeline item 1-->
              <li>
                <div class="ruxvk">
                  <span class="icon-[tabler--circle-check] text-success size-5"></span>
                </div>
                <div class="hkbp5 hei78 ms-2 w-full adede">
                  <div class="text-success text-sm font-medium vxiam">Sender</div>
                  <h6 class="text-base-content font-medium">David Wilson</h6>
                  <p class="text-base-content/80 text-sm">888 Elm Street, Illinois(IL), 60601</p>
                </div>
                <hr>
              </li>
              <!-- /timeline item 1-->

              <!-- timeline item 2-->
              <li>
                <div class="ruxvk">
                  <span class="icon-[tabler--map-pin] text-primary size-5"></span>
                </div>
                <div class="hkbp5 hei78 ms-2 w-full adede">
                  <div class="text-primary text-sm font-medium vxiam">Receiver</div>
                  <h6 class="text-base-content font-medium">Jessica Brown</h6>
                  <p class="text-base-content/80 text-sm">123 Birch Road, Washington(WA), 98101</p>
                </div>
              </li>
            </ul>

            <div class="ck7pw egxbv"></div>

            <ul class="oz2q8 buloa qtuzj d303h w-full">
              <!-- timeline item 1-->
              <li>
                <div class="ruxvk">
                  <span class="icon-[tabler--circle-check] text-success size-5"></span>
                </div>
                <div class="hkbp5 hei78 ms-2 w-full adede">
                  <div class="text-success text-sm font-medium vxiam">Sender</div>
                  <h6 class="text-base-content font-medium">Robert Anderson</h6>
                  <p class="text-base-content/80 text-sm">567 Willow Avenue, Georgia(GA), 30301</p>
                </div>
                <hr>
              </li>
              <!-- /timeline item 1-->

              <!-- timeline item 2-->
              <li>
                <div class="ruxvk">
                  <span class="icon-[tabler--map-pin] text-primary size-5"></span>
                </div>
                <div class="hkbp5 hei78 ms-2 w-full adede">
                  <div class="text-primary text-sm font-medium vxiam">Receiver</div>
                  <h6 class="text-base-content font-medium">Amanda Garcia</h6>
                  <p class="text-base-content/80 text-sm">890 Spruce Circle, Arizona(AZ), 85001</p>
                </div>
              </li>
            </ul>
          </div>
        </div>
      </div>
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
  <div class="dhabr flex min-h-screen items-center justify-center fbpri">
    <div class="zq390 d50ic w-full bhk4z shadow-md">
      <div class="l7s0y flex items-center justify-between bglhu">
        <h4 class="iqv7o c9rvi">Payment History</h4>
        <div class="dropdown relative inline-flex">
          <button id="dropdown-payment-history" type="button" class="dropdown-toggle btn btn-text text-base-content/50 btn-circle btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
            <span class="icon-[tabler--dots-vertical] girx5"></span>
          </button>
          <ul class="dropdown-menu dropdown-open:opacity-100 hidden" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-payment-history" tabindex="-1">
            <li><a class="dropdown-item" href="#">Last 28 Days</a></li>
            <li><a class="dropdown-item" href="#">Last Month</a></li>
            <li><a class="dropdown-item" href="#">Last Year</a></li>
          </ul>
        </div>
      </div>
      <div class="nqxya ma6fd cbpaz">
        <div class="border-base-content/20 dpzny s345o hpxpx rukzz egd50">
          <h6 class="text-base-content/80 zb007 text-sm">Card</h6>
          <div class="rdi5h text-sm">Date</div>
          <div class="ylaqu text-sm">Spend</div>
        </div>
        <ul class="hqh7v fbpri">
          <li>
            <div class="dpzny s345o items-center">
              <div class="zb007 flex items-center sly4q">
                <div class="dhabr rounded-box flex ym8i9 hrxgs items-center justify-center">
                  <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/widgets/visa.png" alt="visa logo" class="dmmja">
                </div>
                <div>
                  <h6 class="text-base-content text-base font-medium">*4399</h6>
                  <p class="text-base-content/50 text-sm">Credit Card</p>
                </div>
              </div>
              <div class="text-base-content/50 rdi5h text-sm">05/Jan</div>
              <div class="ylaqu">
                <p class="text-base-content font-medium">-$2,820</p>
                <p class="text-base-content/50 text-sm">$10,450</p>
              </div>
            </div>
          </li>

          <li>
            <div class="dpzny s345o items-center">
              <div class="zb007 flex items-center sly4q">
                <div class="dhabr rounded-box flex ym8i9 hrxgs items-center justify-center">
                  <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/widgets/american-express.png" alt="american express logo" class="t6d3t">
                </div>
                <div>
                  <h6 class="text-base-content text-base font-medium">*9860</h6>
                  <p class="text-base-content/50 text-sm">ATM Card</p>
                </div>
              </div>
              <div class="text-base-content/50 rdi5h text-sm">24/Feb</div>
              <div class="ylaqu">
                <p class="text-base-content font-medium">-$1,650</p>
                <p class="text-base-content/50 text-sm">$8,900</p>
              </div>
            </div>
          </li>

          <li>
            <div class="dpzny s345o items-center">
              <div class="zb007 flex items-center sly4q">
                <div class="dhabr rounded-box flex ym8i9 hrxgs items-center justify-center">
                  <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/widgets/visa.png" alt="visa logo" class="dmmja">
                </div>
                <div>
                  <h6 class="text-base-content text-base font-medium">*4300</h6>
                  <p class="text-base-content/50 text-sm">Credit Card</p>
                </div>
              </div>
              <div class="text-base-content/50 rdi5h text-sm">08/Mar</div>
              <div class="ylaqu">
                <p class="text-base-content font-medium">-$3,250</p>
                <p class="text-base-content/50 text-sm">$12,800</p>
              </div>
            </div>
          </li>

          <li>
            <div class="dpzny s345o items-center">
              <div class="zb007 flex items-center sly4q">
                <div class="dhabr rounded-box flex ym8i9 hrxgs items-center justify-center">
                  <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/widgets/master-card.png" alt="mastercard logo" class="dmmja">
                </div>
                <div>
                  <h6 class="text-base-content text-base font-medium">*5545</h6>
                  <p class="text-base-content/50 text-sm">Debit Card</p>
                </div>
              </div>
              <div class="text-base-content/50 rdi5h text-sm">15/Apr</div>
              <div class="ylaqu">
                <p class="text-base-content font-medium">-$890</p>
                <p class="text-base-content/50 text-sm">$5,200</p>
              </div>
            </div>
          </li>

          <li>
            <div class="dpzny s345o items-center">
              <div class="zb007 flex items-center sly4q">
                <div class="dhabr rounded-box flex ym8i9 hrxgs items-center justify-center">
                  <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/widgets/visa.png" alt="visa logo" class="dmmja">
                </div>
                <div>
                  <h6 class="text-base-content text-base font-medium">*4399</h6>
                  <p class="text-base-content/50 text-sm">Credit Card</p>
                </div>
              </div>
              <div class="text-base-content/50 rdi5h text-sm">28/Apr</div>
              <div class="ylaqu">
                <p class="text-base-content font-medium">-$1,980</p>
                <p class="text-base-content/50 text-sm">$7,650</p>
              </div>
            </div>
          </li>
        </ul>
      </div>
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

