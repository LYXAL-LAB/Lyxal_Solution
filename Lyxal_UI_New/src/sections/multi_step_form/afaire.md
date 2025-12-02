<body data-vh-checked="true">
  <div class="bg-base-100 relative dpzny min-h-screen lg:grid-cols-12">
    <!-- Logo -->
    <div class="absolute zo392 uv49u z-1 flex items-center sly4q">
      <img src="https://cdn.flyonui.com/fy-assets/logo/logo.png" class="size-8" alt="brand-logo">
      <h3 class="text-base-content bk5oo t3mfo">FlyonUI</h3>
    </div>

    <div class="dhabr relative n85ea w-full overflow-hidden p-4 max-lg:hidden lg:col-span-4">
      <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/multi-steps/image-1.png" alt="Illustration" class="absolute obwa1 ud1b5 z-1 u0hev q867d t6fgm rtl:translate-x-1/2">

      <div class="gljfd absolute zg361 zz28e b7fjw rounded-full"></div>
    </div>

    <!-- Stepper -->
    <div class="flex justify-center o9xn4 lg:col-span-8">
      <div data-stepper="" class="flex w-full jz3o6 justify-center k6gdi gmr9z sm:gap-12 lg:max-w-200">
        <!-- Stepper Nav -->
        <ul class="relative flex ip6vv overflow-x-auto max-md:flex-col md:gap-2">
          <li class="dh3pr flex e6ynr gy7oi a5p47 items-center gap-x-2 active" data-stepper-nav-item="{ &quot;index&quot;: 1 }">
            <div class="flex items-center bglhu">
              <div class="nfjpm rmjll">
                <div class="stepper-active:text-bg-primary stepper-success:text-bg-primary stepper-completed:text-bg-success f436r lt1t7 rounded-full">
                  <span class="icon-[tabler--home] size-5 shrink-0"></span>
                </div>
              </div>
              <div class="shrink-0">
                <h6 class="text-base-content mb-0.5">Account Details</h6>
                <p class="text-base-content/50 text-sm">Account Details</p>
              </div>
            </div>
            <span class="stepper-success:bg-primary stepper-completed:bg-success text-base-content icon-[tabler--chevron-right] size-4 e6ynr group-last:hidden max-md:hidden rtl:rotate-180"></span>
          </li>
          <li class="dh3pr flex e6ynr gy7oi a5p47 items-center gap-x-2" data-stepper-nav-item="{ &quot;index&quot;: 2 }">
            <div class="flex items-center bglhu">
              <div class="nfjpm rmjll">
                <div class="stepper-active:text-bg-primary stepper-success:text-bg-primary stepper-error:text-bg-error stepper-completed:text-bg-success f436r lt1t7 rounded-full">
                  <span class="icon-[tabler--user] size-5 shrink-0"></span>
                </div>
              </div>
              <div class="shrink-0">
                <h6 class="text-base-content mb-0.5">Personal Info</h6>
                <p class="text-base-content/50 text-sm">Add Personal Info</p>
              </div>
            </div>
            <span class="stepper-success:bg-primary stepper-completed:bg-success text-base-content icon-[tabler--chevron-right] size-4 e6ynr group-last:hidden max-md:hidden rtl:rotate-180"></span>
          </li>
          <li class="dh3pr flex e6ynr gy7oi a5p47 items-center gap-x-2" data-stepper-nav-item="{ &quot;index&quot;: 3 }">
            <div class="flex items-center bglhu">
              <div class="nfjpm rmjll">
                <div class="stepper-active:text-bg-primary stepper-success:text-bg-primary stepper-error:text-bg-error stepper-completed:text-bg-success f436r lt1t7 rounded-full">
                  <span class="icon-[tabler--credit-card-pay] size-5 shrink-0"></span>
                </div>
              </div>
              <div class="shrink-0">
                <h6 class="text-base-content mb-0.5">Billing</h6>
                <p class="text-base-content/50 text-sm">Payment Details</p>
              </div>
            </div>
            <span class="stepper-success:bg-primary stepper-completed:bg-success text-base-content icon-[tabler--chevron-right] size-4 e6ynr group-last:hidden rtl:rotate-180"></span>
          </li>
          <!-- End Item -->
        </ul>
        <!-- End Stepper Nav -->
        <div>
          <!-- First Content -->
          <div data-stepper-content-item="{ &quot;index&quot;: 1 }">
            <div class="hqh7v">
              <h2 class="text-base-content waiii t3mfo">Account Details</h2>
              <p class="text-base-content/80">Setup Account Details</p>
              <div class="dpzny wfsyj u7ssa ikjxw sm:grid-cols-2">
                <!-- Username -->
                <div>
                  <label class="wqwbi" for="username">Username</label>
                  <input type="text" placeholder="johndoe" class="ljn0d" id="username" required="">
                </div>
                <!-- Email -->
                <div>
                  <label class="wqwbi" for="email">Email</label>
                  <input type="email" placeholder="john@example.com" class="ljn0d" id="email" required="">
                </div>
                <!-- Password -->
                <div>
                  <label class="wqwbi" for="password">Password</label>
                  <div class="ljn0d">
                    <input id="password" type="password" placeholder="Enter password" required="">
                    <button type="button" data-toggle-password="{ &quot;target&quot;: &quot;#password&quot; }" class="block lx78o" aria-label="password toggle">
                      <span class="icon-[tabler--eye] text-base-content/80 password-active:block hidden size-5 shrink-0"></span>
                      <span class="icon-[tabler--eye-off] text-base-content/80 password-active:hidden block size-5 shrink-0"></span>
                    </button>
                  </div>
                </div>
                <!-- Confirm Password -->
                <div>
                  <label class="wqwbi" for="confirmPassword">Confirm Password</label>
                  <div class="ljn0d">
                    <input id="confirmPassword" type="password" placeholder="Enter confirm password" required="">
                    <button type="button" data-toggle-password="{ &quot;target&quot;: &quot;#confirmPassword&quot; }" class="block lx78o" aria-label="password toggle">
                      <span class="icon-[tabler--eye] text-base-content/80 password-active:block hidden size-5 shrink-0"></span>
                      <span class="icon-[tabler--eye-off] text-base-content/80 password-active:hidden block size-5 shrink-0"></span>
                    </button>
                  </div>
                </div>
                <!-- Profile Link -->
                <div class="md:col-span-2">
                  <label class="wqwbi" for="profileLink">Profile Link</label>
                  <input type="text" placeholder="johndoe/profile" class="ljn0d" id="profileLink">
                </div>
              </div>
            </div>
          </div>
          <!-- End First Content -->
          <!-- Second Content -->
          <div data-stepper-content-item="{ &quot;index&quot;: 2 }" style="display: none;">
            <div class="hqh7v">
              <div>
                <h2 class="text-base-content mb-2 bk5oo t3mfo">Personal Information</h2>
                <p class="yphpr zqxh1">Enter Your Personal Information</p>
              </div>
              <div class="dpzny wfsyj u7ssa ikjxw sm:grid-cols-2">
                <!-- First Name -->
                <div>
                  <label class="wqwbi" for="firstName">First Name</label>
                  <input type="text" placeholder="John" class="ljn0d" id="firstName" required="">
                </div>
                <!-- Last Name -->
                <div>
                  <label class="wqwbi" for="lastName">Last Name</label>
                  <input type="text" placeholder="Doe" class="ljn0d" id="lastName" required="">
                </div>
                <!-- Mobile -->
                <div>
                  <label class="wqwbi" for="mobile">Mobile</label>
                  <input type="tel" placeholder="202 5698 1444" class="ljn0d" id="mobile" required="">
                </div>
                <!-- Pincode -->
                <div>
                  <label class="wqwbi" for="pincode">Pincode</label>
                  <input type="text" placeholder="Postal code" class="ljn0d" id="pincode" required="">
                </div>
                <!-- Address -->
                <div class="md:col-span-2">
                  <label class="wqwbi" for="address">Address</label>
                  <input type="text" placeholder="Address" class="ljn0d" id="address" required="">
                </div>
                <!-- Landmark -->
                <div class="md:col-span-2">
                  <label class="wqwbi" for="landmark">Landmark</label>
                  <input type="text" placeholder="Landmark/Area" class="ljn0d" id="landmark">
                </div>
                <!-- City -->
                <div>
                  <label class="wqwbi" for="city">City</label>
                  <input type="text" placeholder="Jackson" class="ljn0d" id="city" required="">
                </div>
                <!-- State -->
                <div>
                  <label class="wqwbi" for="state">State</label>
                  <select class="select" id="state" required="">
                    <option value="">Select any country</option>
                    <option value="alabama">Alabama</option>
                    <option value="alaska">Alaska</option>
                    <option value="arizona">Arizona</option>
                    <option value="arkansas">Arkansas</option>
                    <option value="california">California</option>
                    <option value="colorado">Colorado</option>
                    <option value="connecticut">Connecticut</option>
                    <option value="delaware">Delaware</option>
                    <option value="florida">Florida</option>
                    <option value="georgia">Georgia</option>
                  </select>
                </div>
              </div>
            </div>
          </div>
          <!-- End Second Content -->
          <!-- Third Content -->
          <div data-stepper-content-item="{ &quot;index&quot;: 3 }" style="display: none;">
            <div class="hqh7v">
              <!-- Select Plan Section -->
              <div>
                <h2 class="text-base-content waiii t3mfo">Select Plan</h2>
                <p class="text-base-content/80">Select plan as per your requirement</p>
              </div>

              <div class="dpzny wfsyj ip6vv sm:grid-cols-3">
                <!-- Basic Plan -->
                <label class="w6ln6 flex jz3o6 items-center sly4q rdi5h">
                  <span class="wqwbi flex jz3o6">
                    <span class="mb-1 text-base font-medium">Basic</span>
                    <span class="text-base-content/80">Get 1 project with 1 teams members.</span>
                    <span class="j6xh2 flex justify-center xk2ot">
                      <span class="text-base-content/80 lpq02 text-sm font-medium">$</span>
                      <span class="text-primary ay6fz fl9z1">0</span>
                      <span class="text-base-content/50 j6xh2 font-medium">/month</span>
                    </span>
                  </span>
                  <input type="radio" name="radio-19" class="d6aiv bmjz1 zwsg8 saa4z">
                </label>
                <!-- Pro Plan -->
                <label class="w6ln6 flex jz3o6 items-center sly4q rdi5h">
                  <span class="wqwbi flex jz3o6">
                    <span class="mb-1 text-base font-medium">Pro</span>
                    <span class="text-base-content/80">Get 2 project with 2 teams members.</span>
                    <span class="j6xh2 flex justify-center xk2ot">
                      <span class="text-base-content/80 lpq02 text-sm font-medium">$</span>
                      <span class="text-primary ay6fz fl9z1">99</span>
                      <span class="text-base-content/50 j6xh2 font-medium">/month</span>
                    </span>
                  </span>
                  <input type="radio" name="radio-19" class="d6aiv bmjz1 zwsg8 saa4z" checked="">
                </label>
                <!-- Elite Plan -->
                <label class="w6ln6 flex jz3o6 items-center sly4q rdi5h">
                  <span class="wqwbi flex jz3o6">
                    <span class="mb-1 text-base font-medium">Elite</span>
                    <span class="text-base-content/80">Get 10 project with 10 teams members.</span>
                    <span class="j6xh2 flex justify-center xk2ot">
                      <span class="text-base-content/80 lpq02 text-sm font-medium">$</span>
                      <span class="text-primary ay6fz fl9z1">299</span>
                      <span class="text-base-content/50 j6xh2 font-medium">/month</span>
                    </span>
                  </span>
                  <input type="radio" name="radio-19" class="d6aiv bmjz1 zwsg8 saa4z">
                </label>
              </div>

              <!-- Payment Information Section -->
              <div>
                <h2 class="text-base-content waiii t3mfo">Payment Information</h2>
                <p class="text-base-content/80">Enter your card information</p>
              </div>
              <div class="dpzny wfsyj u7ssa ikjxw md:grid-cols-5">
                <!-- Card Number -->
                <div class="md:col-span-5">
                  <label class="wqwbi" for="cardNumber">Card Number</label>
                  <input type="text" class="ljn0d" id="cardNumber" placeholder="1458 5222 02585">
                </div>
                <!-- Name on Card -->
                <div class="md:col-span-3">
                  <label class="wqwbi" for="cardName">Name on Card</label>
                  <input type="text" class="ljn0d" id="cardName" placeholder="John Doe">
                </div>
                <!-- Expiry Date -->
                <div>
                  <label class="wqwbi" for="expiryDate">Expiry Date</label>
                  <input type="text" class="ljn0d" id="expiryDate" placeholder="MM/YY">
                </div>
                <!-- CVV Code -->
                <div>
                  <label class="wqwbi" for="cvvCode">CVV Code</label>
                  <input type="text" class="ljn0d" id="cvvCode" placeholder="635">
                </div>
              </div>
            </div>
          </div>
          <!-- End Third Content -->
          <!-- Final Content -->
          <div data-stepper-content-item="{ &quot;isFinal&quot;: true }" style="display: none;">
            <div class="border-base-content/40 oj4x6 flex u0gwo items-center justify-center rpj8y border dkr8s p-4">
              <h3 class="text-base-content/50 waiii">Register Successfully</h3>
            </div>
          </div>
          <!-- End Final Content -->
          <!-- Button Group -->
          <div class="otbdu flex items-center justify-between gap-x-2">
            <button type="button" class="btn btn-soft disabled" data-stepper-back-btn="" disabled="disabled">
              <span class="icon-[tabler--arrow-left] size-5 rtl:rotate-180"></span>
              Previous
            </button>
            <button type="button" class="btn btn-primary" data-stepper-next-btn="">
              Next
              <span class="icon-[tabler--arrow-right] siqxi size-5 rtl:rotate-180"></span>
            </button>
            <button type="button" class="btn mxpqt" data-stepper-finish-btn="" style="display: none;">
              Submit
              <span class="icon-[tabler--check] size-5 rtl:rotate-180"></span>
            </button>
            <button type="reset" class="btn btn-primary" data-stepper-reset-btn="" style="display: none;">Reset</button>
          </div>
          <!-- End Button Group -->
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
  <div class="dhabr i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 fbpri">
      <div class="zq390">
        <div class="nqxya cbpaz">
          <div class="dpzny md:max-lg:grid-cols-5 lg:grid-cols-4" data-stepper="">
            <!-- Stepper Nav -->
            <div class="border-base-content/20 fbpri max-md:border-b md:border-e md:max-lg:col-span-2">
              <ul class="relative o63tj">
                <li class="flex e6ynr gy7oi a5p47 items-center dcvi3 active" data-stepper-nav-item="{ &quot;index&quot;: 1 }">
                  <div class="nfjpm rmjll">
                    <div class="stepper-active:text-bg-primary stepper-success:text-bg-primary stepper-completed:text-bg-success f436r lt1t7 rounded-full">
                      <span class="icon-[tabler--tag] size-5 shrink-0"></span>
                    </div>
                  </div>
                  <div>
                    <h6 class="text-base-content mb-0.5">Deal Type</h6>
                    <p class="text-base-content/50 text-sm">Choose type of deal</p>
                  </div>
                </li>
                <li class="flex e6ynr gy7oi a5p47 items-center dcvi3" data-stepper-nav-item="{ &quot;index&quot;: 2 }">
                  <div class="nfjpm rmjll">
                    <div class="stepper-active:text-bg-primary stepper-success:text-bg-primary stepper-completed:text-bg-success f436r lt1t7 rounded-full">
                      <span class="icon-[tabler--file-text] size-5 shrink-0"></span>
                    </div>
                  </div>
                  <div>
                    <h6 class="text-base-content mb-0.5">Deal Details</h6>
                    <p class="text-base-content/50 text-sm">Provide deal details</p>
                  </div>
                </li>
                <li class="flex e6ynr gy7oi a5p47 items-center dcvi3" data-stepper-nav-item="{ &quot;index&quot;: 3 }">
                  <div class="nfjpm rmjll">
                    <div class="stepper-active:text-bg-primary stepper-success:text-bg-primary stepper-completed:text-bg-success f436r lt1t7 rounded-full">
                      <span class="icon-[tabler--credit-card] size-5 shrink-0"></span>
                    </div>
                  </div>
                  <div>
                    <h6 class="text-base-content mb-0.5">Deal Usage</h6>
                    <p class="text-base-content/50 text-sm">Limitations &amp; Offers</p>
                  </div>
                </li>
                <li class="flex e6ynr gy7oi a5p47 items-center dcvi3" data-stepper-nav-item="{ &quot;index&quot;: 4 }">
                  <div class="nfjpm rmjll">
                    <div class="stepper-active:text-bg-primary stepper-success:text-bg-primary stepper-completed:text-bg-success f436r lt1t7 rounded-full">
                      <span class="icon-[tabler--rocket] size-5 shrink-0"></span>
                    </div>
                  </div>
                  <div>
                    <h6 class="text-base-content mb-0.5">Review &amp; Complete</h6>
                    <p class="text-base-content/50 text-sm">Launch a deal!</p>
                  </div>
                </li>
              </ul>
            </div>
            <!-- End Stepper Nav -->

            <!-- Stepper Content -->
            <div class="fbpri md:col-span-3">
              <!-- First Content -->
              <div data-stepper-content-item="{ &quot;index&quot;: 1 }">
                <div class="flex jz3o6 ip6vv">
                  <div class="border-base-content/20 rounded-box relative xjub5 w-full overflow-hidden border">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/multi-steps/image-2.png" alt="Left block image" class="absolute e4bmm o4bwf otaty sm:h-46">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/multi-steps/image-3.png" alt="Right block image" class="absolute end-0 top-0 otaty sm:h-46">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/multi-steps/image-4.png" alt="Illustration" class="absolute o4bwf k2hpy n85ea z1w5i t6fgm">
                  </div>
                  <div class="dpzny ip6vv sm:grid-cols-3 md:max-lg:grid-cols-1">
                    <label class="w6ln6 has-checked:text-primary flex jz3o6 items-center sly4q rdi5h">
                      <span class="icon-[tabler--tag] j4z3m"></span>
                      <span class="wqwbi flex jz3o6">
                        <span class="mb-1 text-base font-medium">Percentage</span>
                        <span class="text-base-content/80">
                          Create a deal which offer uses some % off (i.e 5% OFF) on total
                        </span>
                      </span>
                      <input type="radio" name="radio-19" class="d6aiv bmjz1 zwsg8 saa4z" checked="">
                    </label>
                    <label class="w6ln6 has-checked:text-primary flex jz3o6 items-center sly4q rdi5h">
                      <span class="icon-[tabler--currency-dollar] j4z3m"></span>
                      <span class="wqwbi flex jz3o6">
                        <span class="mb-1 text-base font-medium">Flat Amount</span>
                        <span class="text-base-content/80">
                          Create a deal which offer uses flat $5 OFF on the total
                        </span>
                      </span>
                      <input type="radio" name="radio-19" class="d6aiv bmjz1 zwsg8 saa4z">
                    </label>
                    <label class="w6ln6 has-checked:text-primary flex jz3o6 items-center sly4q rdi5h">
                      <span class="icon-[tabler--user] j4z3m"></span>
                      <span class="wqwbi flex jz3o6">
                        <span class="mb-1 text-base font-medium">Prime Member</span>
                        <span class="text-base-content/80">Create prime member only deal to encourage the members</span>
                      </span>
                      <input type="radio" name="radio-19" class="d6aiv bmjz1 zwsg8 saa4z">
                    </label>
                  </div>
                  <div class="dpzny ip6vv sm:grid-cols-2 md:max-lg:grid-cols-1">
                    <!-- Discount -->
                    <div>
                      <label class="wqwbi" for="labelAndHelperText">Discount</label>
                      <input type="number" placeholder="10" class="ljn0d" id="labelAndHelperText">
                      <span class="u6ljx">Enter the discount percentage. 10 = 10%</span>
                    </div>

                    <!-- Region -->
                    <div>
                      <label class="wqwbi" for="region">Region</label>
                      <select class="select" id="region" required="">
                        <option value="">Select Region</option>
                        <option value="north-america">North America</option>
                        <option value="europe">Europe</option>
                        <option value="asia-pacific">Asia Pacific</option>
                        <option value="south-america">South America</option>
                        <option value="africa">Africa</option>
                        <option value="middle-east">Middle East</option>
                      </select>
                      <span class="u6ljx">Select application regions for the deal.</span>
                    </div>
                  </div>
                </div>
              </div>
              <!-- End First Content -->
              <!-- Second Content -->
              <div data-stepper-content-item="{ &quot;index&quot;: 2 }" style="display: none;">
                <div class="dpzny ip6vv sm:grid-cols-2 md:max-lg:grid-cols-1">
                  <!-- Deal Title -->
                  <div>
                    <label class="wqwbi" for="deal-title">Deal Title</label>
                    <input type="text" placeholder="Black friday sale, 25% off" class="ljn0d" id="deal-title" required="">
                  </div>

                  <!-- Deal Code -->
                  <div>
                    <label class="wqwbi" for="deal-code">Deal Code</label>
                    <input type="text" placeholder="25PEROFF" class="ljn0d" id="deal-code" required="">
                  </div>

                  <!-- Deal Description -->
                  <div>
                    <label class="wqwbi" for="deal-description">Deal Description</label>
                    <textarea class="ystrl" id="deal-description" rows="5" placeholder="To sell or distribute something as a business deal." required=""></textarea>
                  </div>

                  <!-- Offered Items & Card Condition -->
                  <div class="o63tj">
                    <div>
                      <label class="wqwbi" for="offered-items">Offered Items</label>
                      <select class="select" id="offered-items" required="">
                        <option value="">Offered Items</option>
                        <option value="electronics">Electronics</option>
                        <option value="clothing">Clothing</option>
                        <option value="home-garden">Home &amp; Garden</option>
                        <option value="books">Books</option>
                        <option value="sports">Sports &amp; Outdoors</option>
                        <option value="toys">Toys &amp; Games</option>
                      </select>
                    </div>

                    <div>
                      <label class="wqwbi" for="card-condition">Card Condition</label>
                      <select class="select" id="card-condition" required="">
                        <option value="">Select Card Condition</option>
                        <option value="new">New</option>
                        <option value="like-new">Like New</option>
                        <option value="good">Good</option>
                        <option value="fair">Fair</option>
                        <option value="poor">Poor</option>
                      </select>
                    </div>
                  </div>

                  <!-- Deal Duration -->
                  <div>
                    <label class="wqwbi" for="deal-duration">Deal Duration</label>
                    <input type="text" placeholder="YYYY-MM-DD to YYYY-MM-DD" class="ljn0d" id="deal-duration" required="">
                  </div>

                  <!-- Region -->
                  <div>
                    <span class="wqwbi mb-1">Region</span>
                    <div class="nbone">
                      <!-- Checkboxes for notification preferences -->
                      <div class="flex mnhlk u7ssa vm5rl">
                        <div class="flex items-center">
                          <input type="checkbox" class="d5jfq v1498 dlggn" id="email-notification">
                          <label class="wqwbi" for="email-notification">Email</label>
                        </div>

                        <div class="flex items-center">
                          <input type="checkbox" class="d5jfq v1498 dlggn" id="sms-notification">
                          <label class="wqwbi" for="sms-notification">SMS</label>
                        </div>

                        <div class="flex items-center">
                          <input type="checkbox" class="d5jfq v1498 dlggn" id="push-notification">
                          <label class="wqwbi" for="push-notification">Push Notification</label>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <!-- End Second Content -->
              <!-- Third Content -->
              <div data-stepper-content-item="{ &quot;index&quot;: 3 }" style="display: none;">
                <div class="dpzny ip6vv sm:grid-cols-2 md:max-lg:grid-cols-1">
                  <!-- User Type -->
                  <div>
                    <label class="wqwbi" for="user-type">User Type</label>
                    <select class="select" id="user-type" required="">
                      <option value="">Choose user type</option>
                      <option value="customer">Customer</option>
                      <option value="member">Member</option>
                      <option value="vip">VIP</option>
                    </select>
                  </div>

                  <!-- Max Users -->
                  <div>
                    <label class="wqwbi" for="max-users">Max Users</label>
                    <input type="number" placeholder="Enter max users" class="ljn0d" id="max-users" required="">
                  </div>

                  <!-- Minimum Cart Amount -->
                  <div>
                    <label class="wqwbi" for="min-cart-amount">Minimum Cart Amount</label>
                    <div class="ljn0d">
                      <span class="icon-[tabler--currency-dollar] text-base-content/80 q7z0e xn3np size-5 shrink-0"></span>
                      <input type="number" placeholder="0.00" class="sxihv" id="min-cart-amount" step="0.01">
                    </div>
                  </div>

                  <!-- Promotional Fee -->
                  <div>
                    <label class="wqwbi" for="promotional-fee">Promotional Fee</label>
                    <div class="ljn0d">
                      <span class="icon-[tabler--currency-dollar] text-base-content/80 q7z0e xn3np size-5 shrink-0"></span>
                      <input type="number" placeholder="0.00" class="sxihv" id="promotional-fee" step="0.01">
                    </div>
                  </div>

                  <!-- Payment Method -->
                  <div>
                    <label class="wqwbi" for="payment-method">Payment Method</label>
                    <select class="select" id="payment-method" required="">
                      <option value="">Select payment method</option>
                      <option value="credit-card">Credit Card</option>
                      <option value="debit-card">Debit Card</option>
                      <option value="paypal">PayPal</option>
                      <option value="bank-transfer">Bank Transfer</option>
                    </select>
                  </div>

                  <!-- Deal Status -->
                  <div>
                    <label class="wqwbi" for="deal-status">Deal Status</label>
                    <select class="select" id="deal-status" required="">
                      <option value="">Select status</option>
                      <option value="active">Active</option>
                      <option value="inactive">Inactive</option>
                      <option value="pending">Pending</option>
                      <option value="expired">Expired</option>
                    </select>
                  </div>

                  <!-- Single-use Discount Checkbox -->
                  <div class="flex items-center bglhu">
                    <input type="checkbox" class="q0yur bqy1f" id="single-use-discount">
                    <label class="wqwbi text-base" for="single-use-discount">
                      Limit this discount to a single-use per customer?
                    </label>
                  </div>
                </div>
              </div>
              <!-- End Third Content -->
              <!-- Fourth Content -->
              <div data-stepper-content-item="{ &quot;index&quot;: 4 }" style="display: none;">
                <div class="dpzny ip6vv md:max-lg:grid-cols-1 lg:grid-cols-2">
                  <div class="hqh7v">
                    <h6 class="text-base-content waiii t3mfo">Almost done! 🚀</h6>
                    <p class="text-base-content/80">Confirm your deal details information and submit to create it.</p>
                    <div class="nbone">
                      <div class="flex items-center justify-between sly4q">
                        <span class="text-base-content/80 c9rvi font-medium">Deal Type</span>
                        <span class="text-base-content/80">Percentage</span>
                      </div>
                      <div class="flex items-center justify-between sly4q">
                        <span class="text-base-content/80 c9rvi font-medium">Amount</span>
                        <span class="text-base-content/80">25%</span>
                      </div>
                      <div class="flex items-center justify-between sly4q">
                        <span class="text-base-content/80 c9rvi font-medium">Deal Code</span>
                        <span class="ijn5q ctq8s bxh1m">25PEROFF</span>
                      </div>
                      <div class="flex items-center justify-between sly4q">
                        <span class="text-base-content/80 c9rvi font-medium">Deal Title</span>
                        <span class="text-base-content/80">Black friday sale, 25% OFF</span>
                      </div>
                      <div class="flex items-center justify-between sly4q">
                        <span class="text-base-content/80 c9rvi font-medium">Deal Duration</span>
                        <span class="text-base-content/80">2021-07-14 to 2021-07-30</span>
                      </div>
                      <div class="flex items-center bglhu">
                        <input type="checkbox" class="q0yur bqy1f" id="confirm-details">
                        <label class="wqwbi text-base" for="confirm-details">
                          I have confirmed the deal details.
                        </label>
                      </div>
                    </div>
                  </div>
                  <div class="flex h7vz3 justify-center">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/multi-steps/image-5.png" alt="Illustration" class="gvwu7 g6mu4">
                  </div>
                </div>
              </div>
              <!-- End Fourth Content -->
              <!-- Final Content -->
              <div data-stepper-content-item="{ &quot;isFinal&quot;: true }" style="display: none;">
                <div class="border-base-content/20 rounded-box dhabr flex u0gwo items-center justify-center border dkr8s p-4">
                  <h3 class="text-base-content waiii">Form Submitted..!!</h3>
                </div>
              </div>
              <!-- End Final Content -->
              <!-- Button Group -->
              <div class="gdsae flex items-center justify-between gap-x-2">
                <button type="button" class="btn gnw6d disabled" data-stepper-back-btn="" disabled="disabled">
                  <span class="icon-[tabler--arrow-left] rtl:rotate-180"></span>
                  Previous
                </button>
                <button type="button" class="btn btn-primary" data-stepper-next-btn="">
                  Next
                  <span class="icon-[tabler--arrow-right] rtl:rotate-180"></span>
                </button>
                <button type="submit" class="btn mxpqt" data-stepper-finish-btn="" style="display: none;">
                  Submit
                </button>
                <button type="reset" class="btn btn-primary ms-auto" data-stepper-reset-btn="" style="display: none;">
                  Reset
                </button>
              </div>
              <!-- End Button Group -->
            </div>
            <!-- End Stepper Content -->
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
  <div class="dhabr i3xre sm:py-16 lg:py-24">
    <div class="rounded-box bg-base-100 wpaot owca9 fbpri">
      <div data-stepper="" class="w-full">
        <ul class="relative flex justify-center q0hx4 td0ee w6hsy max-md:gap-x-6 max-sm:flex-col">
          <li class="dh3pr flex gy7oi a5p47 items-center q0hx4 max-md:gap-x-6 active" data-stepper-nav-item="{ &quot;index&quot;: 1}">
            <span class="stepper-active:text-primary stepper-success:text-primary text-base-content/80 flex items-center x1pg6 sm:flex-col">
              <svg width="57" height="56" viewBox="0 0 57 56" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clip-path="url(#clip0_10187_19380)">
                  <path d="M56.5 38.9155V14.2375H47.9576C47.4327 14.2375 47.0085 14.6618 47.0085 15.1866C47.0085 15.7115 47.4327 16.1358 47.9576 16.1358H54.6017V37.0171H10.9407V16.1358H17.5847C18.1096 16.1358 18.5339 15.7115 18.5339 15.1866C18.5339 14.6618 18.1096 14.2375 17.5847 14.2375H10.9407V6.64427C10.9407 6.11938 10.5164 5.69511 9.99153 5.69511H7.95844C7.53417 4.06257 6.06108 2.84766 4.29661 2.84766C2.20278 2.84766 0.5 4.55044 0.5 6.64427C0.5 8.7381 2.20278 10.4409 4.29661 10.4409C6.06108 10.4409 7.53417 9.22596 7.95844 7.59342H9.04237V14.2375V15.1866V37.9663V38.9155V44.6104C9.04237 45.1352 9.46664 45.5595 9.99153 45.5595H16.665C15.5023 46.4251 14.7373 47.7986 14.7373 49.3561C14.7373 51.9729 16.8662 54.1019 19.4831 54.1019C22.0999 54.1019 24.2288 51.9729 24.2288 49.3561C24.2288 47.7986 23.4638 46.4251 22.3011 45.5595H39.4447C38.282 46.4251 37.5169 47.7986 37.5169 49.3561C37.5169 51.9729 39.6459 54.1019 42.2627 54.1019C44.8795 54.1019 47.0085 51.9729 47.0085 49.3561C47.0085 47.7986 46.2435 46.4251 45.0807 45.5595H50.8051C51.33 45.5595 51.7542 45.1352 51.7542 44.6104C51.7542 44.0855 51.33 43.6612 50.8051 43.6612H10.9407V38.9155H56.5ZM4.29661 8.54257C3.24969 8.54257 2.39831 7.69118 2.39831 6.64427C2.39831 5.59735 3.24969 4.74596 4.29661 4.74596C4.99614 4.74596 5.6017 5.13037 5.93105 5.69511H5.24576C4.72088 5.69511 4.29661 6.11938 4.29661 6.64427C4.29661 7.16915 4.72088 7.59342 5.24576 7.59342H5.93105C5.6017 8.15816 4.99614 8.54257 4.29661 8.54257ZM19.4831 52.2036C17.9132 52.2036 16.6356 50.926 16.6356 49.3561C16.6356 47.7862 17.9132 46.5087 19.4831 46.5087C21.0529 46.5087 22.3305 47.7862 22.3305 49.3561C22.3305 50.926 21.0529 52.2036 19.4831 52.2036ZM42.2627 52.2036C40.6928 52.2036 39.4153 50.926 39.4153 49.3561C39.4153 47.7862 40.6928 46.5087 42.2627 46.5087C43.8326 46.5087 45.1102 47.7862 45.1102 49.3561C45.1102 50.926 43.8326 52.2036 42.2627 52.2036Z" fill="currentColor"></path>
                  <path d="M32.7715 28.4747C40.099 28.4747 46.0597 22.514 46.0597 15.1866C46.0597 7.85912 40.099 1.89844 32.7715 1.89844C25.4441 1.89844 19.4834 7.85912 19.4834 15.1866C19.4834 22.514 25.4441 28.4747 32.7715 28.4747ZM32.7715 3.79674C39.0521 3.79674 44.1614 8.90603 44.1614 15.1866C44.1614 21.4671 39.0521 26.5764 32.7715 26.5764C26.491 26.5764 21.3817 21.4671 21.3817 15.1866C21.3817 8.90603 26.491 3.79674 32.7715 3.79674Z" fill="currentColor"></path>
                  <path d="M31.2133 20.6623C31.275 20.7126 31.3442 20.743 31.4135 20.7762C31.442 20.7904 31.4676 20.8132 31.4971 20.8237C31.6015 20.8616 31.7116 20.8816 31.8207 20.8816C31.9536 20.8816 32.0865 20.8521 32.2089 20.7971C32.2554 20.7762 32.2905 20.7344 32.3342 20.706C32.4016 20.6614 32.4737 20.6262 32.5297 20.5626L32.5478 20.5418C32.5478 20.5418 32.5487 20.5408 32.5497 20.5408C32.5497 20.5408 32.5506 20.5399 32.5506 20.5389L40.122 12.0203C40.4703 11.6292 40.4352 11.0284 40.0432 10.681C39.6512 10.3317 39.0514 10.3668 38.704 10.7598L31.722 18.615L26.7333 14.4577C26.328 14.1226 25.7319 14.1767 25.3959 14.5792C25.0599 14.9826 25.1149 15.5815 25.5174 15.9165L31.2133 20.6623Z" fill="currentColor"></path>
                </g>
                <defs>
                  <clipPath id="clip0_10187_19380">
                    <rect width="56" height="56" fill="white" transform="translate(0.5)"></rect>
                  </clipPath>
                </defs>
              </svg>
              <span class="bk5oo font-medium">Cart</span>
            </span>
            <div class="stepper-success:text-primary stepper-completed:text-success group-last:hidden max-sm:hidden">
              <span class="icon-[tabler--chevron-right] qmuz4 rtl:rotate-180"></span>
            </div>
          </li>
          <li class="dh3pr flex gy7oi a5p47 items-center q0hx4 max-md:gap-x-6" data-stepper-nav-item="{ &quot;index&quot;: 2}">
            <span class="stepper-active:text-primary stepper-success:text-primary text-base-content/80 flex items-center x1pg6 sm:flex-col">
              <svg width="56" height="56" viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clip-path="url(#clip0_14459_22734)">
                  <path d="M56 7.46667V0H0V7.46667H1.86667V44.8H0.933333C0.418133 44.8 0 45.2172 0 45.7333C0 46.2495 0.418133 46.6667 0.933333 46.6667H1.86667H27.0667V48.5333C27.0667 48.5772 27.0863 48.6155 27.0919 48.6584C25.4735 49.0663 24.2667 50.5223 24.2667 52.2667C24.2667 54.3256 25.9411 56 28 56C30.0589 56 31.7333 54.3256 31.7333 52.2667C31.7333 50.5223 30.5265 49.0663 28.9081 48.6584C28.9137 48.6155 28.9333 48.5772 28.9333 48.5333V46.6667H54.1333H55.0667C55.5819 46.6667 56 46.2495 56 45.7333C56 45.2172 55.5819 44.8 55.0667 44.8H54.1333V7.46667H56ZM29.8667 52.2667C29.8667 53.2961 29.0295 54.1333 28 54.1333C26.9705 54.1333 26.1333 53.2961 26.1333 52.2667C26.1333 51.2372 26.9705 50.4 28 50.4C29.0295 50.4 29.8667 51.2372 29.8667 52.2667ZM1.86667 1.86667H54.1333V5.6H1.86667V1.86667ZM52.2667 44.8H3.73333V7.46667H52.2667V44.8Z" fill="currentColor"></path>
                  <path d="M46.6667 38.2666H32.6667C32.1515 38.2666 31.7334 38.6838 31.7334 39.1999C31.7334 39.7161 32.1515 40.1333 32.6667 40.1333H46.6667C47.1819 40.1333 47.6001 39.7161 47.6001 39.1999C47.6001 38.6838 47.1819 38.2666 46.6667 38.2666Z" fill="currentColor"></path>
                  <path d="M9.33372 33.6001H18.6671C19.1823 33.6001 19.6004 33.1829 19.6004 32.6667C19.6004 32.1506 19.1823 31.7334 18.6671 31.7334H9.33372C8.81852 31.7334 8.40039 32.1506 8.40039 32.6667C8.40039 33.1829 8.81852 33.6001 9.33372 33.6001Z" fill="currentColor"></path>
                  <path d="M27.9997 33.6001H41.9997C42.5149 33.6001 42.9331 33.1829 42.9331 32.6667C42.9331 32.1506 42.5149 31.7334 41.9997 31.7334H27.9997C27.4845 31.7334 27.0664 32.1506 27.0664 32.6667C27.0664 33.1829 27.4845 33.6001 27.9997 33.6001Z" fill="currentColor"></path>
                  <path d="M22.6711 32.0041C22.5031 32.1805 22.4004 32.4138 22.4004 32.6668C22.4004 32.9094 22.5031 33.1521 22.6711 33.3294C22.8484 33.4974 23.0911 33.6001 23.3337 33.6001C23.5764 33.6001 23.8191 33.4974 23.9964 33.3294C24.1644 33.1521 24.2671 32.9094 24.2671 32.6668C24.2671 32.4241 24.1644 32.1805 23.9964 32.0041C23.6511 31.6588 23.0164 31.6588 22.6711 32.0041Z" fill="currentColor"></path>
                  <path d="M27.9997 38.2666H13.9997C13.4845 38.2666 13.0664 38.6838 13.0664 39.1999C13.0664 39.7161 13.4845 40.1333 13.9997 40.1333H27.9997C28.5149 40.1333 28.9331 39.7161 28.9331 39.1999C28.9331 38.6838 28.5149 38.2666 27.9997 38.2666Z" fill="currentColor"></path>
                  <path d="M9.33372 40.1331C9.57639 40.1331 9.81906 40.0305 9.99639 39.8625C10.1644 39.6851 10.2671 39.4425 10.2671 39.1998C10.2671 38.9571 10.1644 38.7135 9.99639 38.5465C9.65106 38.1918 9.02572 38.1918 8.67106 38.5371C8.50306 38.7135 8.40039 38.9571 8.40039 39.1998C8.40039 39.4425 8.50306 39.6851 8.67106 39.8625C8.84839 40.0305 9.09106 40.1331 9.33372 40.1331Z" fill="currentColor"></path>
                  <path d="M46.0041 32.0041C45.8361 32.1805 45.7334 32.4138 45.7334 32.6668C45.7334 32.9094 45.8361 33.1521 46.0041 33.3294C46.1814 33.4974 46.4241 33.6001 46.6667 33.6001C46.9094 33.6001 47.1521 33.4974 47.3294 33.3294C47.4974 33.1521 47.6001 32.9094 47.6001 32.6668C47.6001 32.4241 47.4974 32.1805 47.3294 32.0041C46.9841 31.6588 46.3587 31.6588 46.0041 32.0041Z" fill="currentColor"></path>
                  <path d="M46.6667 18.6665H32.6667C32.1515 18.6665 31.7334 19.0837 31.7334 19.5998C31.7334 20.116 32.1515 20.5332 32.6667 20.5332H46.6667C47.1819 20.5332 47.6001 20.116 47.6001 19.5998C47.6001 19.0837 47.1819 18.6665 46.6667 18.6665Z" fill="currentColor"></path>
                  <path d="M46.6671 25.2002H37.3337C36.8185 25.2002 36.4004 25.6174 36.4004 26.1335C36.4004 26.6497 36.8185 27.0669 37.3337 27.0669H46.6671C47.1823 27.0669 47.6004 26.6497 47.6004 26.1335C47.6004 25.6174 47.1823 25.2002 46.6671 25.2002Z" fill="currentColor"></path>
                  <path d="M27.9997 27.0669H29.8664C30.3816 27.0669 30.7997 26.6497 30.7997 26.1335C30.7997 25.6174 30.3816 25.2002 29.8664 25.2002H27.9997C27.4845 25.2002 27.0664 25.6174 27.0664 26.1335C27.0664 26.6497 27.4845 27.0669 27.9997 27.0669Z" fill="currentColor"></path>
                  <path d="M27.9997 14H41.9997C42.5149 14 42.9331 13.5828 42.9331 13.0666C42.9331 12.5505 42.5149 12.1333 41.9997 12.1333H27.9997C27.4845 12.1333 27.0664 12.5505 27.0664 13.0666C27.0664 13.5828 27.4845 14 27.9997 14Z" fill="currentColor"></path>
                  <path d="M46.6667 14C46.9094 14 47.1521 13.8974 47.3294 13.7294C47.5067 13.552 47.6001 13.3094 47.6001 13.0667C47.6001 12.824 47.5067 12.5804 47.3294 12.404C46.9747 12.0587 46.3494 12.0587 46.0041 12.404C45.8361 12.5804 45.7334 12.824 45.7334 13.0667C45.7334 13.3094 45.8361 13.552 46.0041 13.7294C46.1814 13.8974 46.4241 14 46.6667 14Z" fill="currentColor"></path>
                  <path d="M28.2707 18.9372C28.1027 19.1136 28 19.347 28 19.5999C28 19.8426 28.1027 20.0852 28.2707 20.2626C28.448 20.4306 28.6907 20.5332 28.9333 20.5332C29.176 20.5332 29.4187 20.4306 29.596 20.2626C29.764 20.0852 29.8667 19.8426 29.8667 19.5999C29.8667 19.347 29.764 19.1136 29.596 18.9372C29.2413 18.5919 28.6253 18.5919 28.2707 18.9372Z" fill="currentColor"></path>
                  <path d="M32.9377 25.4704C32.7697 25.6468 32.667 25.8904 32.667 26.1331C32.667 26.3758 32.7697 26.6184 32.9377 26.7958C33.115 26.9638 33.3577 27.0664 33.6003 27.0664C33.843 27.0664 34.0857 26.9638 34.263 26.7958C34.431 26.6184 34.5337 26.3758 34.5337 26.1331C34.5337 25.8904 34.431 25.6468 34.263 25.4704C33.9177 25.1251 33.283 25.1251 32.9377 25.4704Z" fill="currentColor"></path>
                  <path d="M23.3337 12.1333H8.40039V27.0666H23.3337V12.1333ZM21.4671 25.2H10.2671V14H21.4671V25.2Z" fill="currentColor"></path>
                </g>
                <defs>
                  <clipPath id="clip0_14459_22734">
                    <rect width="56" height="56" fill="white"></rect>
                  </clipPath>
                </defs>
              </svg>

              <span class="bk5oo font-medium">Address</span>
            </span>
            <div class="stepper-success:text-primary stepper-completed:text-success group-last:hidden max-sm:hidden">
              <span class="icon-[tabler--chevron-right] qmuz4 rtl:rotate-180"></span>
            </div>
          </li>
          <li class="dh3pr flex gy7oi a5p47 items-center q0hx4 max-md:gap-x-6" data-stepper-nav-item="{ &quot;index&quot;: 3}">
            <span class="stepper-active:text-primary stepper-success:text-primary text-base-content/80 flex items-center x1pg6 sm:flex-col">
              <svg width="57" height="56" viewBox="0 0 57 56" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g id="Icon" clip-path="url(#clip0_14459_22757)">
                  <g id="Group">
                    <path id="Vector" d="M8.90039 24.2669H16.3671V14.9336H8.90039V24.2669ZM10.7671 16.8003H14.5004V22.4003H10.7671V16.8003Z" fill="currentColor"></path>
                    <path id="Vector_2" d="M8.90039 35.4666H16.3671V26.1333H8.90039V35.4666ZM10.7671 28H14.5004V33.6H10.7671V28Z" fill="currentColor"></path>
                    <path id="Vector_3" d="M8.90039 46.6668H16.3671V37.3335H8.90039V46.6668ZM10.7671 39.2002H14.5004V44.8002H10.7671V39.2002Z" fill="currentColor"></path>
                    <path id="Vector_4" d="M34.1003 23.3335C33.5842 23.3335 33.167 23.7507 33.167 24.2668V32.6668C33.167 33.183 33.5842 33.6002 34.1003 33.6002C34.6165 33.6002 35.0337 33.183 35.0337 32.6668V24.2668C35.0337 23.7507 34.6165 23.3335 34.1003 23.3335Z" fill="currentColor"></path>
                    <path id="Vector_5" d="M34.1003 35.4668C33.5842 35.4668 33.167 35.884 33.167 36.4001V44.8001C33.167 45.3163 33.5842 45.7335 34.1003 45.7335C34.6165 45.7335 35.0337 45.3163 35.0337 44.8001V36.4001C35.0337 35.884 34.6165 35.4668 34.1003 35.4668Z" fill="currentColor"></path>
                    <path id="Vector_6" d="M29.4333 23.3335C28.9172 23.3335 28.5 23.7507 28.5 24.2668V25.2002C28.5 25.7163 28.9172 26.1335 29.4333 26.1335C29.9495 26.1335 30.3667 25.7163 30.3667 25.2002V24.2668C30.3667 23.7507 29.9495 23.3335 29.4333 23.3335Z" fill="currentColor"></path>
                    <path id="Vector_7" d="M29.4333 28C28.9172 28 28.5 28.4172 28.5 28.9333V30.8C28.5 31.3161 28.9172 31.7333 29.4333 31.7333C29.9495 31.7333 30.3667 31.3161 30.3667 30.8V28.9333C30.3667 28.4172 29.9495 28 29.4333 28Z" fill="currentColor"></path>
                    <path id="Vector_8" d="M29.4333 33.6001C28.9172 33.6001 28.5 34.0173 28.5 34.5334V35.4668C28.5 35.9829 28.9172 36.4001 29.4333 36.4001C29.9495 36.4001 30.3667 35.9829 30.3667 35.4668V34.5334C30.3667 34.0173 29.9495 33.6001 29.4333 33.6001Z" fill="currentColor"></path>
                    <path id="Vector_9" d="M29.4333 38.2666C28.9172 38.2666 28.5 38.6838 28.5 39.1999V41.0666C28.5 41.5827 28.9172 41.9999 29.4333 41.9999C29.9495 41.9999 30.3667 41.5827 30.3667 41.0666V39.1999C30.3667 38.6838 29.9495 38.2666 29.4333 38.2666Z" fill="currentColor"></path>
                    <path id="Vector_10" d="M28.7707 44.1375C28.6017 44.3139 28.5 44.5575 28.5 44.8002C28.5 45.0522 28.6017 45.2855 28.7707 45.4628C28.9471 45.6308 29.1907 45.7335 29.4333 45.7335C29.676 45.7335 29.9187 45.6308 30.096 45.4628C30.264 45.2855 30.3667 45.0522 30.3667 44.8002C30.3667 44.5575 30.264 44.3139 30.096 44.1375C29.7413 43.7922 29.1347 43.7828 28.7707 44.1375Z" fill="currentColor"></path>
                    <path id="Vector_11" d="M45.3 1.8667H0.5V8.40003H3.3V50.1975C3.3 52.3675 5.06587 54.1334 7.23587 54.1334H38.5641C40.7341 54.1334 42.5 52.3675 42.5 50.1975V8.40003H45.3V1.8667ZM40.6333 50.1975C40.6333 51.339 39.7056 52.2667 38.5641 52.2667H7.23587C6.0944 52.2667 5.16667 51.339 5.16667 50.1975V6.53337H8.9V13.0667H16.3667V6.53337H24.7667V10.5047V11.8954V17.4954C24.7667 18.6555 25.7112 19.6 26.8713 19.6H34.338H35.7287C36.8888 19.6 37.8333 18.6555 37.8333 17.4954V10.5047V6.53337H40.6333V50.1975ZM10.7667 6.53337H14.5V11.2H10.7667V6.53337ZM32.2333 6.53337V8.40003H30.3667V6.53337H32.2333ZM35.9667 6.53337V8.4243C35.8873 8.41497 35.8099 8.40003 35.7287 8.40003H34.1V6.53337H35.9667ZM26.8713 17.7334C26.7397 17.7334 26.6333 17.627 26.6333 17.4954V13.9758C26.7127 13.9851 26.7901 14 26.8713 14H28.5V17.7334H26.8713ZM30.3667 14H31.9953C32.1269 14 32.2333 14.1064 32.2333 14.238V17.4954C32.2333 17.5766 32.2483 17.654 32.2576 17.7334H30.3667V14ZM34.1 17.4954V14.238C34.1 13.0779 33.1555 12.1334 31.9953 12.1334H26.8713C26.7397 12.1334 26.6333 12.027 26.6333 11.8954V10.5047C26.6333 10.3731 26.7397 10.2667 26.8713 10.2667H35.7287C35.8603 10.2667 35.9667 10.3731 35.9667 10.5047V17.4954C35.9667 17.627 35.8603 17.7334 35.7287 17.7334H34.338C34.2064 17.7334 34.1 17.627 34.1 17.4954ZM28.5 8.40003H26.8713C26.7901 8.40003 26.7127 8.41497 26.6333 8.4243V6.53337H28.5V8.40003ZM43.4333 6.53337H42.5V4.6667H37.8333H24.7667H16.3667H8.9H3.3V6.53337H2.36667V3.73337H43.4333V6.53337Z" fill="currentColor"></path>
                    <path id="Vector_12" d="M56.2261 32.0071L50.627 26.408C50.5411 26.3212 50.4375 26.2531 50.3227 26.2055C50.095 26.1112 49.8383 26.1112 49.6097 26.2055C49.4949 26.2531 49.3913 26.3221 49.3054 26.408L43.7063 32.0071C43.3414 32.372 43.3414 32.9619 43.7063 33.3268C43.8883 33.5088 44.1273 33.6003 44.3662 33.6003C44.6051 33.6003 44.8441 33.5088 45.0261 33.3268L49.0329 29.32V53.2003C49.0329 53.7164 49.4501 54.1336 49.9662 54.1336C50.4823 54.1336 50.8995 53.7164 50.8995 53.2003V29.32L54.9063 33.3268C55.0883 33.5088 55.3273 33.6003 55.5662 33.6003C55.8051 33.6003 56.0441 33.5088 56.2261 33.3268C56.591 32.9619 56.591 32.372 56.2261 32.0071Z" fill="currentColor"></path>
                  </g>
                </g>
                <defs>
                  <clipPath id="clip0_14459_22757">
                    <rect width="56" height="56" fill="white" transform="translate(0.5)"></rect>
                  </clipPath>
                </defs>
              </svg>
              <span class="bk5oo font-medium">Payment</span>
            </span>
            <div class="stepper-success:text-primary stepper-completed:text-success group-last:hidden max-sm:hidden">
              <span class="icon-[tabler--chevron-right] qmuz4 rtl:rotate-180"></span>
            </div>
          </li>
          <li class="dh3pr flex gy7oi a5p47 items-center q0hx4 max-md:gap-x-6" data-stepper-nav-item="{ &quot;index&quot;: 4}">
            <span class="stepper-active:text-primary stepper-success:text-primary text-base-content/80 flex items-center x1pg6 sm:flex-col">
              <svg width="57" height="56" viewBox="0 0 57 56" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g id="Icon2" clip-path="url(#clip0_14459_22776)">
                  <g id="Group2">
                    <path id="Vector2" d="M7.96654 14.9336H21.9665C22.4817 14.9336 22.8999 14.5164 22.8999 14.0002C22.8999 13.4841 22.4817 13.0669 21.9665 13.0669H7.96654C7.45134 13.0669 7.0332 13.4841 7.0332 14.0002C7.0332 14.5164 7.45134 14.9336 7.96654 14.9336Z" fill="currentColor"></path>
                    <path id="Vector2_2" d="M7.96654 12.1333H16.3665C16.8817 12.1333 17.2999 11.7161 17.2999 11.1999C17.2999 10.6838 16.8817 10.2666 16.3665 10.2666H7.96654C7.45134 10.2666 7.0332 10.6838 7.0332 11.1999C7.0332 11.7161 7.45134 12.1333 7.96654 12.1333Z" fill="currentColor"></path>
                    <path id="Vector2_3" d="M22.8999 16.8C22.8999 16.2839 22.4817 15.8667 21.9665 15.8667H7.96654C7.45134 15.8667 7.0332 16.2839 7.0332 16.8C7.0332 17.3162 7.45134 17.7334 7.96654 17.7334H21.9665C22.4817 17.7334 22.8999 17.3162 22.8999 16.8Z" fill="currentColor"></path>
                    <path id="Vector2_4" d="M56.5 3.73333H29.4333V0.933333C29.4333 0.4172 29.0152 0 28.5 0C27.9848 0 27.5667 0.4172 27.5667 0.933333V3.73333H0.5V42.9333H26.2469L14.7735 54.4068C14.4085 54.7717 14.4085 55.3616 14.7735 55.7265C14.9555 55.9085 15.1944 56 15.4333 56C15.6723 56 15.9112 55.9085 16.0932 55.7265L27.5667 44.2531V53.2C27.5667 53.7161 27.9848 54.1333 28.5 54.1333C29.0152 54.1333 29.4333 53.7161 29.4333 53.2V44.2531L40.9068 55.7265C41.0888 55.9085 41.3277 56 41.5667 56C41.8056 56 42.0445 55.9085 42.2265 55.7265C42.5915 55.3616 42.5915 54.7717 42.2265 54.4068L30.7531 42.9333H56.5V3.73333ZM54.6333 41.0667H2.36667V5.6H54.6333V41.0667Z" fill="currentColor"></path>
                    <path id="Vector2_5" d="M38.7668 18.6665H43.0471L31.8602 29.8534L24.12 22.1133C23.7551 21.7483 23.1652 21.7483 22.8003 22.1133L11.0403 33.8733C10.6754 34.2382 10.6754 34.8281 11.0403 35.193C11.2223 35.375 11.4612 35.4665 11.7002 35.4665C11.9391 35.4665 12.178 35.375 12.36 35.193L23.4602 24.0929L31.2003 31.833C31.3823 32.015 31.6212 32.1065 31.8602 32.1065C32.0991 32.1065 32.338 32.015 32.52 31.833L44.3668 19.9862V24.2665C44.3668 24.7826 44.784 25.1998 45.3002 25.1998C45.8163 25.1998 46.2335 24.7826 46.2335 24.2665V17.7331C46.2335 17.6118 46.2092 17.4905 46.1616 17.3766C46.0674 17.1479 45.8854 16.9659 45.6567 16.8717C45.5428 16.8241 45.4215 16.7998 45.3002 16.7998H38.7668C38.2516 16.7998 37.8335 17.217 37.8335 17.7331C37.8335 18.2493 38.2516 18.6665 38.7668 18.6665Z" fill="currentColor"></path>
                  </g>
                </g>
                <defs>
                  <clipPath id="clip0_14459_22776">
                    <rect width="56" height="56" fill="white" transform="translate(0.5)"></rect>
                  </clipPath>
                </defs>
              </svg>

              <span class="bk5oo font-medium">Confirmation</span>
            </span>
            <div class="stepper-success:text-primary stepper-completed:text-success group-last:hidden max-sm:hidden">
              <span class="icon-[tabler--chevron-right] qmuz4 rtl:rotate-180"></span>
            </div>
          </li>
        </ul>

        <div class="ck7pw bhs4g"></div>

        <div>
          <!-- Cart Content -->
          <div data-stepper-content-item="{ &quot;index&quot;: 1 }">
            <div class="dpzny wfsyj ip6vv lg:grid-cols-3">
              <!-- Cart left -->
              <div class="flex jz3o6 ip6vv lg:col-span-2">
                <!-- Offer alert -->
                <div class="soitm qymct q67o1 removing:translate-x-5 removing:opacity-0 flex njdg2 transition duration-300 a6lvc" role="alert" id="offer-alert">
                  <span class="icon-[tabler--checks] size-6 shrink-0"></span>
                  <div class="flex jz3o6 rsqkx">
                    <h5 class="c9rvi t3mfo">Available Offers</h5>
                    <ul class="qizc4">
                      <li>- 10% Instant Discount on Bank of America Corp Bank Debit and Credit cards</li>
                      <li>- 25% Cashback Voucher of up to $60 on first ever PayPal transaction. TCA</li>
                    </ul>
                  </div>
                  <button class="ms-auto lx78o lpq02 ufkdd" data-remove-element="#offer-alert" aria-label="Close Button">
                    <span class="icon-[tabler--x] size-5"></span>
                  </button>
                </div>

                <!-- Shopping bag -->
                <h5 class="text-base-content c9rvi font-medium">My Shopping Bag (2 Items)</h5>

                <div class="rounded-box border-base-content/20 ai7oq o63tj i0lqh border fbpri">
                  <div class="removing:translate-x-5 removing:opacity-0 relative flex ip6vv fyl79 transition-all duration-300 a6lvc max-sm:flex-col" id="iphone-16">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/ecommerce/checkout/checkout-7.png" alt="Iphone 16 pro max" class="xbygq v78of c7ys3">
                    <div class="flex kz0is jz3o6 sly4q">
                      <span class="text-base-content c9rvi font-medium">iPhone 16 Pro Max</span>
                      <div class="flex kz0is items-center eovr6">
                        <p class="text-base-content/80 font-medium">Sold by:</p>
                        <p class="text-base-content c9rvi t3mfo">Apple</p>
                        <span class="ijn5q bxh1m gehqc">In stock</span>
                      </div>
                      <div class="flex items-center c1jfo">
                        <span class="icon-[tabler--star-filled] h7b7g size-6 shrink-0"></span>
                        <span class="icon-[tabler--star-filled] h7b7g size-6 shrink-0"></span>
                        <span class="icon-[tabler--star-filled] h7b7g size-6 shrink-0"></span>
                        <span class="icon-[tabler--star-filled] h7b7g size-6 shrink-0"></span>
                        <span class="icon-[tabler--star-half-filled] h7b7g size-6 shrink-0 rtl:rotate-y-180"></span>
                      </div>
                      <div class="rucf7" data-input-number="">
                        <div class="ljn0d items-center">
                          <button type="button" class="btn btn-primary btn-soft girx5 o53tu keg19 cbpaz" aria-label="Decrement button" data-input-number-decrement="">
                            <span class="icon-[tabler--minus] ue1bl shrink-0"></span>
                          </button>
                          <input class="rdi5h" type="text" value="1" aria-label="Mini stacked buttons" data-input-number-input="" id="quantity-input">
                          <button type="button" class="btn btn-primary btn-soft girx5 o53tu keg19 cbpaz" aria-label="Increment button" data-input-number-increment="">
                            <span class="icon-[tabler--plus] ue1bl shrink-0"></span>
                          </button>
                        </div>
                      </div>
                    </div>
                    <div class="flex jz3o6 x1pg6 lg:mt-10.5 lg:items-end">
                      <div class="flex items-center eovr6">
                        <span class="text-primary c9rvi t3mfo">$299/</span>
                        <span class="text-base-content/80 c9rvi t3mfo aho6k">$359</span>
                      </div>
                      <span class="btn btn-soft btn-primary btn-sm">Move to wishlist</span>
                    </div>
                    <div class="absolute end-0 top-0">
                      <button class="btn btn-circle btn-text btn-sm" data-remove-element="#iphone-16" aria-label="Close Button">
                        <span class="icon-[tabler--x] size-5 shrink-0"></span>
                      </button>
                    </div>
                  </div>

                  <div class="removing:translate-x-5 removing:opacity-0 relative flex ip6vv transition-all duration-300 a6lvc max-sm:flex-col" id="home-pod">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/ecommerce/checkout/checkout-8.png" alt="HomePod" class="bvwr5 jlyho c7ys3">
                    <div class="flex kz0is jz3o6 sly4q">
                      <span class="text-base-content c9rvi font-medium">HomePod</span>
                      <div class="flex kz0is items-center eovr6">
                        <p class="text-base-content/80 font-medium">Sold by:</p>
                        <p class="text-base-content c9rvi t3mfo">Apple</p>
                        <span class="ijn5q bxh1m gehqc">In stock</span>
                      </div>
                      <div class="flex items-center c1jfo">
                        <span class="icon-[tabler--star-filled] h7b7g size-6 shrink-0"></span>
                        <span class="icon-[tabler--star-filled] h7b7g size-6 shrink-0"></span>
                        <span class="icon-[tabler--star-filled] h7b7g size-6 shrink-0"></span>
                        <span class="icon-[tabler--star-filled] h7b7g size-6 shrink-0"></span>
                        <span class="icon-[tabler--star-half-filled] h7b7g size-6 shrink-0 rtl:rotate-y-180"></span>
                      </div>
                      <div class="rucf7" data-input-number="">
                        <div class="ljn0d items-center">
                          <button type="button" class="btn btn-primary btn-soft girx5 o53tu keg19 cbpaz" aria-label="Decrement button" data-input-number-decrement="">
                            <span class="icon-[tabler--minus] ue1bl shrink-0"></span>
                          </button>
                          <input class="rdi5h" type="text" value="1" aria-label="Mini stacked buttons" data-input-number-input="" id="quantity-input1">
                          <button type="button" class="btn btn-primary btn-soft girx5 o53tu keg19 cbpaz" aria-label="Increment button" data-input-number-increment="">
                            <span class="icon-[tabler--plus] ue1bl shrink-0"></span>
                          </button>
                        </div>
                      </div>
                    </div>
                    <div class="flex jz3o6 x1pg6 lg:mt-10.5 lg:items-end">
                      <div class="flex items-center eovr6">
                        <span class="text-primary c9rvi t3mfo">$299/</span>
                        <span class="text-base-content/80 c9rvi t3mfo aho6k">$359</span>
                      </div>
                      <span class="btn btn-soft btn-primary btn-sm">Move to wishlist</span>
                    </div>
                    <div class="absolute end-0 top-0">
                      <button class="btn btn-circle btn-text btn-sm" data-remove-element="#home-pod" aria-label="Close Button">
                        <span class="icon-[tabler--x] size-5 shrink-0"></span>
                      </button>
                    </div>
                  </div>
                </div>

                <!-- Wishlist -->
                <div class="list-group">
                  <a href="#" class="text-primary rounded-field border-primary flex w-full items-center justify-between bglhu border j2be9 py-2 font-medium">
                    <span>Add more products from wishlist</span>
                    <span class="icon-[tabler--arrow-right] size-5 rtl:rotate-180"></span>
                  </a>
                </div>
              </div>

              <!-- Cart right -->
              <div>
                <div class="rounded-box border-base-content/20 flex jz3o6 k6gdi border fbpri">
                  <!-- Offer -->
                  <div>
                    <h6 class="text-base-content mb-2 c9rvi t3mfo">Offer</h6>
                    <div class="flex sly4q">
                      <input type="text" placeholder="Add discount code" class="ljn0d ka2aa">
                      <button class="btn btn-primary">Apply</button>
                    </div>
                  </div>

                  <!-- Gift wrap -->
                  <div class="dhabr rounded-box nbone xvq4q p-3">
                    <h6 class="text-base-content t3mfo">Buying gift for a loved one?</h6>
                    <p class="text-base-content/80">Gift wrap and personalized message on card, Only for $2.</p>
                    <a href="#" class="text-primary t3mfo">Add a gift wrap 🎁</a>
                  </div>

                  <div class="ck7pw"></div>

                  <!-- Price Details -->
                  <div>
                    <h6 class="text-base-content mb-2 c9rvi t3mfo">Price Details</h6>
                    <div class="nbone">
                      <div class="flex items-center justify-between sly4q">
                        <span class="text-base-content/50">Price</span>
                        <span class="text-base-content t3mfo">$599,00</span>
                      </div>
                      <div class="flex items-center justify-between sly4q">
                        <span class="text-base-content/50">Discount size</span>
                        <span class="text-base-content t3mfo">-$50.00</span>
                      </div>
                      <div class="flex items-center justify-between sly4q">
                        <span class="text-base-content/50">Delivery Charges</span>
                        <span class="text-base-content t3mfo">Free Delivery</span>
                      </div>
                      <div class="ck7pw"></div>
                      <div class="flex items-center justify-between sly4q">
                        <span class="text-base-content c9rvi t3mfo">Order Details</span>
                        <span class="text-base-content c9rvi t3mfo">$549.00</span>
                      </div>
                    </div>
                  </div>
                </div>
                <button class="btn btn-primary rhmi6 next-step ndnti">Place order</button>
              </div>
            </div>
          </div>

          <!-- Address Content -->
          <div data-stepper-content-item="{ &quot;index&quot;: 2 }" style="display: none;">
            <div class="dpzny wfsyj ip6vv lg:grid-cols-3">
              <!-- Address left -->
              <div class="flex jz3o6 ip6vv lg:col-span-2">
                <h5 class="text-base-content t3mfo">Select your preferable address</h5>

                <div class="flex w-full mnhlk qojvm ip6vv sm:flex-nowrap">
                  <label class="w6ln6 flex a4n2b qojvm sly4q">
                    <input type="radio" name="radio-16" class="d6aiv bmjz1 saa4z zwsg8 hgzwk" checked="">
                    <span class="wqwbi flex w-full jz3o6 mdi3z ao5al">
                      <span class="flex justify-between">
                        <span class="text-base font-medium">Joh Doe (Default)</span>
                        <span class="ijn5q pze98 bxh1m">Home</span>
                      </span>
                      <span class="text-base-content/80 text-sm">
                        4135 parkway street, Los Angeles,90017. Mobile: 1234567890 Card/Cash on delivery available
                      </span>
                      <span class="ck7pw"></span>
                      <span class="flex items-center x1pg6">
                        <a href="#" class="text-primary text-base t3mfo">Edit</a>
                        <a href="#" class="text-primary text-base t3mfo">Remove</a>
                      </span>
                    </span>
                  </label>

                  <label class="w6ln6 flex a4n2b qojvm sly4q">
                    <input type="radio" name="radio-16" class="d6aiv bmjz1 saa4z zwsg8 hgzwk">
                    <span class="wqwbi flex w-full jz3o6 mdi3z ao5al">
                      <span class="flex justify-between">
                        <span class="text-base font-medium">ACME Inc.</span>
                        <span class="ijn5q gehqc bxh1m">Office</span>
                      </span>
                      <span class="text-base-content/80 text-sm">
                        87 hoffman avenue, new york, NY, 10016 Mobile: 1234567890 Card/Cash on delivery Available
                      </span>
                      <span class="ck7pw"></span>
                      <span class="flex items-center x1pg6">
                        <a href="#" class="text-primary text-base t3mfo">Edit</a>
                        <a href="#" class="text-primary text-base t3mfo">Remove</a>
                      </span>
                    </span>
                  </label>
                </div>

                <!-- Add new address -->
                <div><button class="btn btn-primary btn-soft">Add new address</button></div>

                <h5 class="text-base-content t3mfo">Choose Delivery Speed</h5>

                <div class="flex w-full mnhlk qojvm ip6vv sm:flex-nowrap">
                  <label class="w6ln6 has-checked:text-primary relative flex jz3o6 items-center sly4q rdi5h">
                    <span class="icon-[tabler--user] j4z3m"></span>
                    <span class="wqwbi flex jz3o6 cbpaz">
                      <span class="mb-1 text-base t3mfo">Standard</span>
                      <span class="text-base-content/80">Get your product in 1 week</span>
                    </span>
                    <input type="radio" name="radio-19" class="d6aiv bmjz1 saa4z zwsg8" checked="">
                    <span class="absolute w3z1y lfgun"><span class="ijn5q gehqc bxh1m">Free</span></span>
                  </label>

                  <label class="w6ln6 has-checked:text-primary relative flex jz3o6 items-center sly4q rdi5h">
                    <span class="icon-[tabler--star] j4z3m"></span>
                    <span class="wqwbi flex jz3o6 cbpaz">
                      <span class="mb-1 text-base t3mfo">Express</span>
                      <span class="text-base-content/80">Get your product in 3-4 days.</span>
                    </span>
                    <input type="radio" name="radio-19" class="d6aiv bmjz1 saa4z zwsg8">
                    <span class="absolute w3z1y lfgun"><span class="ijn5q elj2w bxh1m">$10</span></span>
                  </label>

                  <label class="w6ln6 has-checked:text-primary relative flex jz3o6 items-center sly4q rdi5h">
                    <span class="icon-[tabler--crown] j4z3m"></span>
                    <span class="wqwbi flex jz3o6 cbpaz">
                      <span class="mb-1 text-base t3mfo">Overnight</span>
                      <span class="text-base-content/80">Get your product in 0-1 days.</span>
                    </span>
                    <input type="radio" name="radio-19" class="d6aiv bmjz1 saa4z zwsg8">
                    <span class="absolute w3z1y lfgun"><span class="ijn5q elj2w bxh1m">$15</span></span>
                  </label>
                </div>
              </div>

              <!-- Address right -->
              <div>
                <div class="rounded-box border-base-content/20 flex jz3o6 ip6vv border fbpri">
                  <!-- Offer -->
                  <h6 class="text-base-content t3mfo">Estimated Delivery Date</h6>

                  <!-- Item 1 -->
                  <div class="flex items-center ip6vv">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/ecommerce/checkout/checkout-7.png" alt="Iphone" class="mpsop oun33 c7ys3">
                    <div class="flex jz3o6 eovr6">
                      <span class="text-base-content/80 font-medium">iPhone 16 Pro Max</span>
                      <span class="text-base-content/80 font-medium">18th Nov 2024</span>
                    </div>
                  </div>

                  <!-- Item 2 -->
                  <div class="flex items-center ip6vv">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/ecommerce/checkout/checkout-8.png" alt="HomePod" class="mpsop azix8 c7ys3">
                    <div class="flex jz3o6 eovr6">
                      <span class="text-base-content/80 font-medium">HomePod</span>
                      <span class="text-base-content/80 font-medium">18th Nov 2024</span>
                    </div>
                  </div>

                  <div class="ck7pw"></div>

                  <!-- Price Details -->
                  <div>
                    <h6 class="text-base-content oobh7 c9rvi t3mfo">Price Details</h6>
                    <div class="hqh7v">
                      <div class="flex items-center justify-between sly4q">
                        <span class="text-base-content/50">Order Total</span>
                        <span class="text-base-content t3mfo">$1198.00</span>
                      </div>
                      <div class="flex items-center justify-between sly4q">
                        <span class="text-base-content/50">Delivery Charges</span>
                        <div class="flex items-center sly4q">
                          <span class="ijn5q bxh1m gehqc o1g2m vxiam">Free</span>
                          <span class="text-base-content t3mfo aho6k">$5.00</span>
                        </div>
                      </div>
                      <div class="ck7pw zqxh1"></div>
                      <div class="flex items-center justify-between sly4q">
                        <span class="text-base-content c9rvi t3mfo">Order Details</span>
                        <span class="text-base-content c9rvi t3mfo">$549.00</span>
                      </div>
                    </div>
                  </div>
                </div>
                <button class="btn btn-primary rhmi6 next-step ndnti">Place order</button>
              </div>
            </div>
          </div>

          <!-- Payment Content -->
          <div data-stepper-content-item="{ &quot;index&quot;: 3 }" style="display: none;">
            <div class="dpzny wfsyj ip6vv lg:grid-cols-3">
              <!-- Payment left -->
              <div class="flex jz3o6 ip6vv lg:col-span-2">
                <div class="soitm qymct q67o1 removing:translate-x-5 removing:opacity-0 flex njdg2 transition duration-300 a6lvc" role="alert" id="offer-alert2">
                  <span class="icon-[tabler--checks] size-6 shrink-0"></span>
                  <div class="flex jz3o6 rsqkx">
                    <h5 class="c9rvi t3mfo">Available Offers</h5>
                    <ul class="qizc4">
                      <li>- 10% Instant Discount on Bank of America Corp Bank Debit and Credit cards</li>
                      <li>- 25% Cashback Voucher of up to $60 on first ever PayPal transaction. TCA</li>
                    </ul>
                  </div>
                  <button class="ms-auto lx78o lpq02 ufkdd" data-remove-element="#offer-alert2" aria-label="Close Button">
                    <span class="icon-[tabler--x] size-5"></span>
                  </button>
                </div>

                <!-- Payment method -->
                <div>
                  <nav class="hhn76 hckb4 overflow-x-auto" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                    <button type="button" class="btn btn-text active-tab:gradient-bg active-tab:gradient-bg-primary active-tab:text-white hover:text-primary active hover:bg-primary/20" id="tabs-pill-item-1" data-tab="#tabs-pill-1" aria-controls="tabs-pill-1" role="tab">
                      Card
                    </button>
                    <button type="button" class="btn btn-text active-tab:gradient-bg active-tab:gradient-bg-primary active-tab:text-white hover:text-primary hover:bg-primary/20" id="tabs-pill-item-2" data-tab="#tabs-pill-2" aria-controls="tabs-pill-2" role="tab">
                      Cash on Delivery
                    </button>
                    <button type="button" class="btn btn-text active-tab:gradient-bg active-tab:gradient-bg-primary active-tab:text-white hover:text-primary hover:bg-primary/20" id="tabs-pill-item-3" data-tab="#tabs-pill-3" aria-controls="tabs-pill-3" role="tab">
                      Gift Card
                    </button>
                  </nav>
                  <div class="ndnti gma8g">
                    <!-- Card -->
                    <div id="tabs-pill-1" role="tabpanel" aria-labelledby="tabs-pill-item-1">
                      <div class="dpzny ip6vv sm:grid-cols-4">
                        <div class="sm:col-span-4">
                          <label class="wqwbi j5f89 text-base font-medium" for="card-number">Card Number</label>
                          <input type="number" placeholder="xxxx xxxx xxxx xxxx" class="ljn0d" id="card-number">
                        </div>
                        <div class="sm:col-span-2">
                          <label class="wqwbi j5f89 text-base font-medium" for="card-number">Card Name</label>
                          <input type="text" placeholder="John Doe" class="ljn0d" id="card-name">
                        </div>
                        <div>
                          <label class="wqwbi j5f89 text-base font-medium" for="card-expiration">Exp. Date</label>
                          <input type="text" class="ljn0d flatpickr-input" placeholder="MM/YY" id="card-expiration" readonly="readonly">
                        </div>
                        <div>
                          <label class="wqwbi j5f89 text-base font-medium" for="card-cvv">CVV Code</label>
                          <input type="number" placeholder="654" class="ljn0d" id="card-cvv">
                        </div>
                      </div>
                      <div class="otbdu flex items-center rsqkx">
                        <input type="checkbox" class="q0yur bqy1f" id="future-billing">
                        <label class="wqwbi text-base" for="future-billing">Save Card for future billing?</label>
                      </div>
                      <div class="otbdu flex items-center ip6vv">
                        <button class="btn btn-primary next-step">Save Changes</button>
                        <button class="btn">Reset</button>
                      </div>
                    </div>

                    <!-- Cash on Delivery -->
                    <div id="tabs-pill-2" class="hidden" role="tabpanel" aria-labelledby="tabs-pill-item-2">
                      <p class="text-base-content/80 zqxh1">
                        Cash on Delivery is a type of payment method where the recipient make payment for the order at
                        the time of delivery rather than in advance.
                      </p>
                      <button class="btn btn-primary next-step">Pay on delivery</button>
                    </div>

                    <!-- Gift Card -->
                    <div id="tabs-pill-3" class="hidden" role="tabpanel" aria-labelledby="tabs-pill-item-3">
                      <div class="o63tj">
                        <h6 class="text-base-content t3mfo">Enter Gift Card Details</h6>
                        <div>
                          <label class="wqwbi text-base font-medium" for="gift-card-number">
                            Gift card number
                          </label>
                          <input type="number" placeholder="Gift card number" class="ljn0d" id="gift-card-number">
                        </div>
                        <div>
                          <label class="wqwbi text-base font-medium" for="gift-card-pin">Gift card pin</label>
                          <input type="number" placeholder="Gift card pin" class="ljn0d" id="gift-card-pin">
                        </div>
                        <button class="btn btn-primary next-step">Reddem Gift Card</button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Payment right -->
              <div>
                <div class="rounded-box border-base-content/20 flex jz3o6 mdi3z border fbpri">
                  <!-- Price Details -->
                  <div class="hqh7v">
                    <h6 class="text-base-content c9rvi t3mfo">Price Details</h6>
                    <div class="flex items-center justify-between sly4q">
                      <span class="text-base-content font-medium">Order Total</span>
                      <span class="text-base-content t3mfo">$1198.00</span>
                    </div>
                    <div class="flex items-center justify-between sly4q">
                      <span class="text-base-content font-medium">Delivery Charges</span>
                      <div class="flex items-center sly4q">
                        <span class="ijn5q bxh1m gehqc o1g2m vxiam">Free</span>
                        <span class="text-base-content t3mfo aho6k">$5.00</span>
                      </div>
                    </div>
                  </div>
                  <div class="ck7pw"></div>

                  <div class="pqjas">
                    <div class="flex items-center justify-between sly4q">
                      <span class="text-base-content font-medium">Total</span>
                      <span class="text-base-content t3mfo">$1198.00</span>
                    </div>
                    <div class="flex items-center justify-between sly4q">
                      <span class="text-base-content font-medium">Deliver To:</span>
                      <span class="ijn5q bxh1m gehqc">Home</span>
                    </div>
                  </div>

                  <p class="text-base-content/80 qyxjd">
                    <span class="text-base-content">John Doe (default)</span>
                    , 4135 Parkway street, los Angeles, CA, 90017. Mobile: +1 1234567890
                  </p>

                  <a href="#" class="text-primary text-base t3mfo">Change address</a>
                </div>
              </div>
            </div>
          </div>

          <!-- Confirmation Content -->
          <div data-stepper-content-item="{ &quot;index&quot;: 4 }" style="display: none;">
            <div class="wpaot zqxh1 ifqfr hrl4t rdi5h">
              <h4 class="waiii font-medium">Thank You! 😇</h4>
              <p class="text-base-content/80 font-medium">
                Your order
                <span class="text-base-content">#1536548131</span>
                has been placed!
              </p>
              <p class="text-base-content/80 font-medium">
                We sent an email to
                <a href="mailto:john.doe@example.com" class="text-base-content">john.doe@example.com</a>
                with your order confirmation and receipt. If the email hasn't arrived within two minutes, please check
                your spam folder to see if the email was routed there.
              </p>
              <div class="text-base-content/80 flex items-center justify-center bglhu font-medium">
                <span class="icon-[tabler--clock] text-base-content size-4"></span>
                <span>Time placed:&nbsp; 25/05/2020 13:35pm</span>
              </div>
            </div>

            <div class="ai7oq border-base-content/20 rounded-box zqxh1 dpzny wfsyj border max-md:divide-y md:grid-cols-3 md:divide-x">
              <div class="o63tj fbpri">
                <div class="flex items-center dcvi3">
                  <span class="icon-[tabler--current-location] text-base-content size-6"></span>
                  <span class="text-base-content bk5oo font-medium">Shipping</span>
                </div>
                <p class="text-base-content/80 font-medium">
                  <span class="text-base-content">John Doe (default)</span>
                  ,
                  <br>
                  4135 Parkway street,
                  <br>
                  los Angeles, CA, 90017.
                </p>
                <p class="text-base-content/80 font-medium">+1 1234567890</p>
              </div>

              <div class="o63tj fbpri">
                <div class="flex items-center dcvi3">
                  <span class="icon-[tabler--credit-card] text-base-content size-6"></span>
                  <span class="text-base-content bk5oo font-medium">Billing Address</span>
                </div>
                <p class="text-base-content/80 font-medium">
                  <span class="text-base-content">John Doe (default)</span>
                  ,
                  <br>
                  4135 Parkway street,
                  <br>
                  los Angeles, CA, 90017.
                </p>
                <p class="text-base-content/80 font-medium">+1 1234567890</p>
              </div>

              <div class="o63tj fbpri">
                <div class="flex items-center dcvi3">
                  <span class="icon-[tabler--sailboat] text-base-content size-6"></span>
                  <span class="text-base-content bk5oo font-medium">Shipping Method</span>
                </div>
                <p class="text-base-content/80 font-medium">
                  <span class="text-base-content">John Doe (default)</span>
                  ,
                  <br>
                  4135 Parkway street,
                  <br>
                  los Angeles, CA, 90017.
                </p>
                <p class="text-base-content/80 font-medium">+1 1234567890</p>
              </div>
            </div>

            <div class="dpzny wfsyj ip6vv lg:grid-cols-3">
              <div class="border-base-content/20 rounded-box ai7oq i0lqh border lg:col-span-2">
                <div class="flex ip6vv x5704 max-sm:flex-col">
                  <img src="https://cdn.flyonui.com/fy-assets/blocks/ecommerce/checkout/checkout-7.png" alt="Iphone 16 pro max" class="mpsop v78of c7ys3">
                  <div class="flex kz0is jz3o6 sly4q">
                    <span class="text-base-content c9rvi font-medium">iPhone 16 Pro Max</span>
                    <div class="flex items-center eovr6">
                      <p class="text-base-content/80 font-medium">Sold by:</p>
                      <p class="text-base-content c9rvi t3mfo">Apple</p>
                    </div>
                  </div>
                  <div class="flex eovr6">
                    <span class="text-primary c9rvi t3mfo">$299/</span>
                    <span class="text-base-content/80 c9rvi t3mfo aho6k">$359</span>
                  </div>
                </div>
                <div class="flex ip6vv x5704 max-sm:flex-col">
                  <img src="https://cdn.flyonui.com/fy-assets/blocks/ecommerce/checkout/checkout-8.png" alt="Homepod" class="mpsop i2vrq c7ys3">
                  <div class="flex kz0is jz3o6 sly4q">
                    <span class="text-base-content c9rvi font-medium">HomePod</span>
                    <div class="flex items-center eovr6">
                      <p class="text-base-content/80 font-medium">Sold by:</p>
                      <p class="text-base-content c9rvi t3mfo">Apple</p>
                    </div>
                  </div>
                  <div class="flex eovr6">
                    <span class="text-primary c9rvi t3mfo">$125/</span>
                    <span class="text-base-content/80 c9rvi t3mfo aho6k">$230</span>
                  </div>
                </div>
              </div>

              <div>
                <div class="rounded-box border-base-content/20 border">
                  <div class="hqh7v fbpri">
                    <h6 class="text-base-content c9rvi t3mfo">Price Details</h6>
                    <div class="flex items-center justify-between sly4q">
                      <span class="text-base-content font-medium">Original price</span>
                      <span class="text-base-content t3mfo">$1198.00</span>
                    </div>
                    <div class="flex items-center justify-between sly4q">
                      <span class="text-base-content font-medium">Delivery Charges</span>
                      <div class="flex items-center sly4q">
                        <span class="ijn5q bxh1m gehqc o1g2m">Free</span>
                        <span class="text-base-content t3mfo aho6k">$5.00</span>
                      </div>
                    </div>
                  </div>
                  <div class="ck7pw"></div>
                  <div class="flex items-center justify-between sly4q fbpri">
                    <span class="text-base-content font-medium">Total</span>
                    <span class="text-base-content t3mfo">$1198.00</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <!-- Button Group -->
        <div class="zqqzo flex items-center justify-between gap-x-2">
          <button type="button" class="btn btn-primary hidden disabled" data-stepper-back-btn="" disabled="disabled">
            <span class="icon-[tabler--chevron-left] siqxi rtl:rotate-180"></span>
            Back
          </button>
        </div>
      </div>
    </div>
  </div>

  <script src="https://flyonui.becdn.net/pro/libs/flatpickr/dist/flatpickr.js"></script>

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
    window.addEventListener("load", function () {
      // Basic
      flatpickr("#card-expiration", {
        dateFormat: "m/Y"
      })
    })

    const nextStepButtons = document.querySelectorAll(".next-step")

    nextStepButtons.forEach(button => {
      const stepperContainer = button.closest("[data-stepper]")

      if (stepperContainer) {
        button.addEventListener("click", e => {
          e.preventDefault()

          // Get stepper instance
          const stepperInstance = HSStepper.getInstance(stepperContainer)

          if (stepperInstance) {
            // Go to next step
            stepperInstance.goToNext()
          }
        })
      }
    })
  </script>
  

<div class="flatpickr-calendar animate" tabindex="-1"><div class="flatpickr-months"><span class="flatpickr-prev-month"><svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 17 17"><g></g><path d="M5.207 8.471l7.146 7.147-0.707 0.707-7.853-7.854 7.854-7.853 0.707 0.707-7.147 7.146z"></path></svg></span><div class="flatpickr-month"><div class="flatpickr-current-month"><select class="flatpickr-monthDropdown-months" aria-label="Month" tabindex="-1"><option class="flatpickr-monthDropdown-month" value="0" tabindex="-1">January</option><option class="flatpickr-monthDropdown-month" value="1" tabindex="-1">February</option><option class="flatpickr-monthDropdown-month" value="2" tabindex="-1">March</option><option class="flatpickr-monthDropdown-month" value="3" tabindex="-1">April</option><option class="flatpickr-monthDropdown-month" value="4" tabindex="-1">May</option><option class="flatpickr-monthDropdown-month" value="5" tabindex="-1">June</option><option class="flatpickr-monthDropdown-month" value="6" tabindex="-1">July</option><option class="flatpickr-monthDropdown-month" value="7" tabindex="-1">August</option><option class="flatpickr-monthDropdown-month" value="8" tabindex="-1">September</option><option class="flatpickr-monthDropdown-month" value="9" tabindex="-1">October</option><option class="flatpickr-monthDropdown-month" value="10" tabindex="-1">November</option><option class="flatpickr-monthDropdown-month" value="11" tabindex="-1">December</option></select><div class="numInputWrapper"><input class="numInput cur-year" type="number" tabindex="-1" aria-label="Year"><span class="arrowUp"></span><span class="arrowDown"></span></div></div></div><span class="flatpickr-next-month"><svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 17 17"><g></g><path d="M13.207 8.472l-7.854 7.854-0.707-0.707 7.146-7.146-7.146-7.148 0.707-0.707 7.854 7.854z"></path></svg></span></div><div class="flatpickr-innerContainer"><div class="flatpickr-rContainer"><div class="flatpickr-weekdays"><div class="flatpickr-weekdaycontainer">
      <span class="flatpickr-weekday">
        Sun</span><span class="flatpickr-weekday">Mon</span><span class="flatpickr-weekday">Tue</span><span class="flatpickr-weekday">Wed</span><span class="flatpickr-weekday">Thu</span><span class="flatpickr-weekday">Fri</span><span class="flatpickr-weekday">Sat
      </span>
      </div></div><div class="flatpickr-days" tabindex="-1"><div class="dayContainer"><span class="flatpickr-day prevMonthDay" aria-label="October 26, 2025" tabindex="-1">26</span><span class="flatpickr-day prevMonthDay" aria-label="October 27, 2025" tabindex="-1">27</span><span class="flatpickr-day prevMonthDay" aria-label="October 28, 2025" tabindex="-1">28</span><span class="flatpickr-day prevMonthDay" aria-label="October 29, 2025" tabindex="-1">29</span><span class="flatpickr-day prevMonthDay" aria-label="October 30, 2025" tabindex="-1">30</span><span class="flatpickr-day prevMonthDay" aria-label="October 31, 2025" tabindex="-1">31</span><span class="flatpickr-day" aria-label="November 1, 2025" tabindex="-1">1</span><span class="flatpickr-day" aria-label="November 2, 2025" tabindex="-1">2</span><span class="flatpickr-day" aria-label="November 3, 2025" tabindex="-1">3</span><span class="flatpickr-day" aria-label="November 4, 2025" tabindex="-1">4</span><span class="flatpickr-day" aria-label="November 5, 2025" tabindex="-1">5</span><span class="flatpickr-day" aria-label="November 6, 2025" tabindex="-1">6</span><span class="flatpickr-day" aria-label="November 7, 2025" tabindex="-1">7</span><span class="flatpickr-day" aria-label="November 8, 2025" tabindex="-1">8</span><span class="flatpickr-day" aria-label="November 9, 2025" tabindex="-1">9</span><span class="flatpickr-day" aria-label="November 10, 2025" tabindex="-1">10</span><span class="flatpickr-day" aria-label="November 11, 2025" tabindex="-1">11</span><span class="flatpickr-day" aria-label="November 12, 2025" tabindex="-1">12</span><span class="flatpickr-day" aria-label="November 13, 2025" tabindex="-1">13</span><span class="flatpickr-day" aria-label="November 14, 2025" tabindex="-1">14</span><span class="flatpickr-day" aria-label="November 15, 2025" tabindex="-1">15</span><span class="flatpickr-day" aria-label="November 16, 2025" tabindex="-1">16</span><span class="flatpickr-day" aria-label="November 17, 2025" tabindex="-1">17</span><span class="flatpickr-day" aria-label="November 18, 2025" tabindex="-1">18</span><span class="flatpickr-day" aria-label="November 19, 2025" tabindex="-1">19</span><span class="flatpickr-day" aria-label="November 20, 2025" tabindex="-1">20</span><span class="flatpickr-day" aria-label="November 21, 2025" tabindex="-1">21</span><span class="flatpickr-day" aria-label="November 22, 2025" tabindex="-1">22</span><span class="flatpickr-day" aria-label="November 23, 2025" tabindex="-1">23</span><span class="flatpickr-day" aria-label="November 24, 2025" tabindex="-1">24</span><span class="flatpickr-day" aria-label="November 25, 2025" tabindex="-1">25</span><span class="flatpickr-day today" aria-label="November 26, 2025" aria-current="date" tabindex="-1">26</span><span class="flatpickr-day" aria-label="November 27, 2025" tabindex="-1">27</span><span class="flatpickr-day" aria-label="November 28, 2025" tabindex="-1">28</span><span class="flatpickr-day" aria-label="November 29, 2025" tabindex="-1">29</span><span class="flatpickr-day" aria-label="November 30, 2025" tabindex="-1">30</span><span class="flatpickr-day nextMonthDay" aria-label="December 1, 2025" tabindex="-1">1</span><span class="flatpickr-day nextMonthDay" aria-label="December 2, 2025" tabindex="-1">2</span><span class="flatpickr-day nextMonthDay" aria-label="December 3, 2025" tabindex="-1">3</span><span class="flatpickr-day nextMonthDay" aria-label="December 4, 2025" tabindex="-1">4</span><span class="flatpickr-day nextMonthDay" aria-label="December 5, 2025" tabindex="-1">5</span><span class="flatpickr-day nextMonthDay" aria-label="December 6, 2025" tabindex="-1">6</span></div></div></div></div></div></body>

