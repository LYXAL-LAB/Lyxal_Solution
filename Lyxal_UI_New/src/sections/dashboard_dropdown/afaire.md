<div class="bg-base-200 flex h-82 flex-col items-center p-6">
    <div class="dropdown relative inline-flex [--placement:bottom]">
      <button
        id="language-dropdown"
        type="button"
        class="dropdown-toggle btn btn-square btn-soft"
        aria-haspopup="menu"
        aria-expanded="false"
        aria-label="Dropdown"
      >
        <span class="icon-[tabler--language] size-5.5"></span>
      </button>
      <ul
        class="dropdown-menu dropdown-open:opacity-100 hidden w-full max-w-60 space-y-0.5"
        role="menu"
        aria-orientation="vertical"
        aria-labelledby="language-dropdown"
      >
        <li><a class="dropdown-item px-3" href="#">English</a></li>
        <li><a class="dropdown-item dropdown-active px-3" href="#">Deutsch</a></li>
        <li><a class="dropdown-item px-3" href="#">한국인</a></li>
        <li><a class="dropdown-item px-3" href="#">Española</a></li>
        <li><a class="dropdown-item px-3" href="#">Português</a></li>
      </ul>
    </div>
  </div>

<div class="bg-base-200 flex h-83 flex-col items-center p-6">
    <div class="dropdown relative inline-flex [--placement:bottom]">
      <button
        id="status-dropdown"
        type="button"
        class="dropdown-toggle"
        aria-haspopup="menu"
        aria-expanded="false"
        aria-label="Dropdown"
      >
        <span class="avatar avatar-online-top">
          <span class="rounded-box w-10">
            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar" />
          </span>
        </span>
      </button>
      <ul
        class="dropdown-menu dropdown-open:opacity-100 hidden w-full max-w-75 space-y-0.5"
        role="menu"
        aria-orientation="vertical"
        aria-labelledby="status-dropdown"
      >
        <li>
          <a class="dropdown-item dropdown-active group gap-3 px-3" href="#">
            <span class="bg-primary/40 group-[.dropdown-active]:bg-primary size-2.5 rounded-full"></span>
            Pending
          </a>
        </li>
        <li>
          <a class="dropdown-item group gap-3 px-3" href="#">
            <span class="bg-error/40 group-[.dropdown-active]:bg-error size-2.5 rounded-full"></span>
            In Progress
          </a>
        </li>
        <li>
          <a class="dropdown-item group gap-3 px-3" href="#">
            <span class="bg-success/40 group-[.dropdown-active]:bg-success size-2.5 rounded-full"></span>
            In Review
          </a>
        </li>
        <li>
          <a class="dropdown-item group gap-3 px-3" href="#">
            <span class="bg-warning/40 group-[.dropdown-active]:bg-warning size-2.5 rounded-full"></span>
            Complete
          </a>
        </li>
        <li>
          <a class="dropdown-item group gap-3 px-3" href="#">
            <span class="bg-secondary/40 group-[.dropdown-active]:bg-secondary size-2.5 rounded-full"></span>
            Archived
          </a>
        </li>
      </ul>
    </div>
  </div>

<div class="bg-base-200 flex h-64 flex-col items-center p-6">
    <div class="dropdown relative inline-flex [--placement:bottom]">
      <button
        id="download-dropdown"
        type="button"
        class="dropdown-toggle btn btn-primary"
        aria-haspopup="menu"
        aria-expanded="false"
        aria-label="Dropdown"
      >
        Balance
      </button>
      <div
        class="dropdown-menu dropdown-open:opacity-100 hidden w-full max-w-75"
        role="menu"
        aria-orientation="vertical"
        aria-labelledby="download-dropdown"
      >
        <h6 class="text-base-content/50 mb-0.5 text-sm">Your balance</h6>
        <ul class="space-y-0.5">
          <li>
            <a class="dropdown-item px-3" href="#">
              <span class="icon-[tabler--cash] size-5"></span>
              Deposit
            </a>
          </li>
          <li>
            <a class="dropdown-item px-3" href="#">
              <span class="icon-[tabler--report-money] size-5"></span>
              Withdraw
            </a>
          </li>
          <li>
            <a class="dropdown-item px-3" href="#">
              <span class="icon-[tabler--receipt-2] size-5"></span>
              Payment info
            </a>
          </li>
        </ul>
      </div>
    </div>
  </div>

<div class="bg-base-200 flex h-120 flex-col items-center p-6">
    <div class="dropdown relative inline-flex [--placement:bottom]">
      <button
        id="more-dropdown"
        type="button"
        class="dropdown-toggle btn btn-square btn-primary"
        aria-haspopup="menu"
        aria-expanded="false"
        aria-label="Dropdown"
      >
        <span class="icon-[tabler--dots] size-5.5"></span>
      </button>
      <ul
        class="dropdown-menu dropdown-open:opacity-100 hidden w-full max-w-81 space-y-0.5"
        role="menu"
        aria-orientation="vertical"
        aria-labelledby="more-dropdown"
      >
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--arrow-forward] size-5"></span>
            Reply
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--pinned] size-5"></span>
            Pin
          </a>
        </li>
        <li>
          <hr class="border-base-content/20 -mx-2 my-1.5" />
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--bookmark] size-5"></span>
            Save this message
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--star] size-5"></span>
            Mark as unread
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--mail] size-5"></span>
            Share via email
          </a>
        </li>
        <li>
          <hr class="border-base-content/20 -mx-2 my-1.5" />
        </li>
        <li
          class="dropdown relative [--adaptive:none] [--strategy:static] md:[--strategy:absolute] md:[--trigger:hover]"
        >
          <button
            id="nested-dropdown-2"
            class="dropdown-toggle dropdown-item justify-between px-3"
            aria-haspopup="menu"
            aria-expanded="false"
            aria-label="Dropdown"
          >
            More actions
            <span class="icon-[tabler--chevron-right] size-5 max-md:rotate-90 rtl:rotate-180"></span>
          </button>
          <ul
            class="dropdown-menu dropdown-open:opacity-100 inset-x-full top-0 hidden w-full max-w-60 duration-[0.1ms] max-md:m-0 max-md:p-0 max-md:shadow-none md:!ms-4 md:before:absolute md:before:-start-5 md:before:top-0 md:before:h-full md:before:w-5"
            role="menu"
            aria-orientation="vertical"
            aria-labelledby="nested-dropdown-2"
          >
            <li>
              <a class="dropdown-item px-3" href="#">
                <span class="icon-[tabler--copy] size-5"></span>
                Copy Message
              </a>
            </li>
            <li>
              <a class="dropdown-item px-3" href="#">
                <span class="icon-[tabler--send] size-5"></span>
                Forward Message
              </a>
            </li>
          </ul>
        </li>
      </ul>
    </div>
  </div>

<body data-vh-checked="true">
  <div class="dhabr flex tnkf1 jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--auto-close:inside] [--placement:bottom]">
      <button id="fav-dropdown" type="button" class="dropdown-toggle btn btn-soft btn-square kqeru" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
        <span class="icon-[tabler--heart] mhx2u"></span>
      </button>
      <ul class="dropdown-menu dropdown-open:opacity-100 w-full zy3u1 nbone ee2rm hidden" role="menu" aria-orientation="vertical" aria-labelledby="fav-dropdown" tabindex="-1" style="transform: translate3d(295px, 76px, 0px);" data-placement="bottom">
        <li>
          <h6 class="text-base-content/50 text-sm vxiam">Favourites</h6>
        </li>
        <li class="removing:translate-x-5 removing:opacity-0 transition duration-300 a6lvc" id="favItem1">
          <div class="flex bglhu">
            <img src="https://cdn.flyonui.com/fy-assets/components/dropdown/image-5.png" class="rounded-field hlrpg shrink-0 rs1s9" alt="T-Shirt">
            <div class="flex e6ynr jz3o6 justify-between bglhu f1870">
              <div>
                <div class="text-base-content font-medium">Black T-Shirt</div>
                <div class="text-base-content/50 text-sm">Liverpool F.C.</div>
              </div>
              <div class="flex bglhu">
                <span class="text-base-content bk5oo t3mfo">$149</span>
                <span class="text-base-content/50 aho6k">$600</span>
              </div>
            </div>
            <button class="btn btn-sm btn-soft gauh6 btn-square" data-remove-element="#favItem1" aria-label="Delete Item">
              <span class="icon-[tabler--trash] qmuz4"></span>
            </button>
          </div>
        </li>
        <li class="removing:translate-x-5 removing:opacity-0 transition duration-300 a6lvc" id="favItem2">
          <div class="flex bglhu">
            <img src="https://cdn.flyonui.com/fy-assets/components/dropdown/image-4.png" class="rounded-field hlrpg shrink-0 rs1s9" alt="Nike">
            <div class="flex e6ynr jz3o6 justify-between bglhu f1870">
              <div>
                <div class="text-base-content font-medium">My orders</div>
                <div class="text-base-content/50 text-sm">Nike</div>
              </div>
              <div class="flex bglhu">
                <span class="text-base-content bk5oo t3mfo">$329.00</span>
                <span class="text-base-content/50 aho6k">$699</span>
              </div>
            </div>
            <button class="btn btn-sm btn-soft gauh6 btn-square" data-remove-element="#favItem2" aria-label="Delete Item">
              <span class="icon-[tabler--trash] qmuz4"></span>
            </button>
          </div>
        </li>
        <li class="removing:translate-x-5 removing:opacity-0 transition duration-300 a6lvc" id="favItem3">
          <div class="flex bglhu">
            <img src="https://cdn.flyonui.com/fy-assets/components/dropdown/image-3.png" class="rounded-field hlrpg shrink-0 rs1s9" alt="Apple Watch">
            <div class="flex e6ynr jz3o6 justify-between bglhu f1870">
              <div>
                <div class="text-base-content font-medium">Apple Watch 9</div>
                <div class="text-base-content/50 text-sm">Apple</div>
              </div>
              <div class="flex bglhu">
                <span class="text-base-content bk5oo t3mfo">$499</span>
                <span class="text-base-content/50 aho6k">$549</span>
              </div>
            </div>
            <button class="btn btn-sm btn-soft gauh6 btn-square" data-remove-element="#favItem3" aria-label="Delete Item">
              <span class="icon-[tabler--trash] qmuz4"></span>
            </button>
          </div>
        </li>
        <li>
          <a class="btn btn-primary rhmi6" href="#">View All Favourites</a>
        </li>
      </ul>
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
  <div class="dhabr flex psga6 jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--auto-close:inside] [--placement:bottom]">
      <button id="share-dropdown" type="button" class="dropdown-toggle btn btn-primary" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
        Share
      </button>
      <div class="dropdown-menu dropdown-open:opacity-100 w-full z668w adede j2be9 hidden" role="menu" aria-orientation="vertical" aria-labelledby="share-dropdown" tabindex="-1" style="transform: translate3d(221px, 68px, 0px);" data-placement="bottom">
        <div>
          <h6 class="text-base-content/50 qbqme text-sm vxiam">Share read-only link</h6>
        </div>
        <hr class="border-base-content/20 wxf93 l9qqe">
        <div class="flex dcvi3">
          <input type="text" placeholder="Add names of emails" class="ljn0d e1ers">
          <button class="btn btn-sm btn-primary">Send</button>
        </div>
        <h6 class="text-base-content bcvet text-sm font-medium">Team members</h6>
        <ul class="nbone">
          <li class="dropdown-item bglhu px-3 qbqme sm:gap-4">
            <div class="nfjpm">
              <div class="kqy8v rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="User Avatar">
              </div>
            </div>
            <div class="e6ynr">
              <h6 class="text-base-content mb-0.5 t3mfo">john Torff</h6>
              <p class="text-base-content/80 font-medium">john@example.com</p>
            </div>
            <div class="dropdown relative inline-flex [--placement:bottom-end]">
              <button id="dropdown1" type="button" class="dropdown-toggle btn gnw6d btn-text btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                Admin
                <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-4"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown1" tabindex="-1">
                <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can view</a></li>
                <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can edit</a></li>
                <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Owner</a></li>
              </ul>
            </div>
          </li>
          <li class="dropdown-item bglhu px-3 qbqme sm:gap-4">
            <div class="nfjpm rmjll">
              <div class="dxw29 rgf08 kqy8v rounded-full">
                <span class="text-md vxiam">lp</span>
              </div>
            </div>
            <div class="e6ynr">
              <h6 class="text-base-content mb-0.5 t3mfo">Laura Perez</h6>
              <p class="text-base-content/80 font-medium">la@example.com</p>
            </div>
            <div class="dropdown relative inline-flex [--placement:bottom-end]">
              <button id="dropdown2" type="button" class="dropdown-toggle btn gnw6d btn-text btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                Can view
                <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-4"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown2" tabindex="-1">
                <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Admin</a></li>
                <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can edit</a></li>
                <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Owner</a></li>
              </ul>
            </div>
          </li>
          <li class="dropdown-item bglhu px-3 qbqme sm:gap-4">
            <div class="nfjpm">
              <div class="kqy8v rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="User Avatar">
              </div>
            </div>
            <div class="e6ynr">
              <h6 class="text-base-content mb-0.5 t3mfo">Cristofer Torff</h6>
              <p class="text-base-content/80 font-medium">torff@example.com</p>
            </div>
            <div class="dropdown relative inline-flex [--placement:bottom-end]">
              <button id="dropdown3" type="button" class="dropdown-toggle btn gnw6d btn-text btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                Admin
                <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-4"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown3" tabindex="-1">
                <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can view</a></li>
                <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can edit</a></li>
                <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Owner</a></li>
              </ul>
            </div>
          </li>
          <li class="dropdown-item bglhu px-3 qbqme sm:gap-4">
            <div class="nfjpm">
              <div class="kqy8v rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="User Avatar">
              </div>
            </div>
            <div class="e6ynr">
              <h6 class="text-base-content mb-0.5 t3mfo">Sofiya Cerry</h6>
              <p class="text-base-content/80 font-medium">sofi@example.com</p>
            </div>
            <div class="dropdown relative inline-flex [--placement:bottom-end]">
              <button id="dropdown4" type="button" class="dropdown-toggle btn gnw6d btn-text btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                Can edit
                <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-4"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown4" tabindex="-1">
                <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can view</a></li>
                <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Admin</a></li>
                <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Owner</a></li>
              </ul>
            </div>
          </li>
          <li class="dropdown-item bglhu px-3 qbqme sm:gap-4">
            <div class="rp44n f6bsn">
              <div class="nfjpm">
                <div class="t89s2">
                  <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
                </div>
              </div>
              <div class="nfjpm">
                <div class="t89s2">
                  <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                </div>
              </div>
            </div>
            <div class="e6ynr">
              <p class="text-base-content/80 font-medium">2 more people</p>
            </div>
            <div class="dropdown relative inline-flex">
              <button id="dropdown5" type="button" class="dropdown-toggle btn btn-text geut3 btn-square" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--dots] dropdown-open:rotate-180 size-4"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown5" tabindex="-1">
                <li><a class="dropdown-item px-2 b9hof text-sm" href="#">View</a></li>
                <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Delete</a></li>
              </ul>
            </div>
          </li>
        </ul>
        <hr class="border-base-content/20 wxf93 l9qqe">
        <div class="flex items-center justify-between qbqme">
          <div class="text-base-content/50 flex items-center bglhu text-sm font-medium">
            <span class="icon-[tabler--circle-plus] size-4"></span>
            Read more about share
          </div>
          <button class="btn btn-primary btn-sm btn-text">
            <span class="icon-[tabler--link]"></span>
            Copy Link
          </button>
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
  <div class="dhabr flex iyb7f jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--auto-close:inside] [--placement:bottom]">
      <button id="notification-dropdown" type="button" class="dropdown-toggle btn btn-soft btn-square kqeru" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
        <span class="hpjlt">
          <span class="pykeo kn3q0 tdit1 rounded-full"></span>
          <span class="icon-[tabler--bell] text-base-content mhx2u"></span>
        </span>
      </button>
      <div class="dropdown-menu dropdown-open:opacity-100 w-full kzmwn adede px-3 hidden" role="menu" aria-orientation="vertical" aria-labelledby="notification-dropdown" tabindex="-1" style="transform: translate3d(211px, 76px, 0px);" data-placement="bottom">
        <div class="b6erz flex w-full items-center justify-between njdg2 mwpft">
          <h6 class="text-base-content/50 text-sm vxiam">Notification</h6>
          <span class="ijn5q bxh1m o1g2m pze98 rounded-full">8 New</span>
        </div>
        <div class="flex items-center justify-between">
          <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
            <button type="button" class="vfeps active-tab:tab-active font-medium active" id="tabs-basic-item-1" data-tab="#tabs-basic-1" aria-controls="tabs-basic-1" role="tab" aria-selected="true">
              4 Inbox
            </button>
            <button type="button" class="vfeps active-tab:tab-active font-medium" id="tabs-basic-item-2" data-tab="#tabs-basic-2" aria-controls="tabs-basic-2" role="tab" aria-selected="false">
              General
            </button>
          </nav>
          <div class="dropdown relative inline-flex [--auto-close:inside]">
            <button id="notification-settings" type="button" class="dropdown-toggle btn btn-text btn-sm btn-square" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
              <span class="icon-[tabler--settings] size-5"></span>
            </button>
            <div class="dropdown-menu dropdown-open:opacity-100 hidden rq2jn" role="menu" aria-orientation="vertical" aria-labelledby="notification-settings" tabindex="-1">
              <div class="dropdown-item items-center justify-between bglhu px-2 qbqme">
                <label class="wqwbi text-base" for="settings1">Notification</label>
                <input type="checkbox" class="q0yur bqy1f ji544" id="settings1" checked="">
              </div>
              <div class="dropdown-item items-center justify-between bglhu px-2 qbqme">
                <label class="wqwbi text-base" for="settings2">Location</label>
                <input type="checkbox" class="q0yur bqy1f ji544" id="settings2">
              </div>
            </div>
          </div>
        </div>
        <hr class="border-base-content/20 ltzhj pn693 j8wvb">
        <div>
          <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1" class="">
            <ul>
              <li>
                <div class="flex w-full items-center sly4q mrpnf">
                  <div class="nfjpm">
                    <div class="j4z3m rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
                    </div>
                  </div>
                  <div class="e6ynr">
                    <h6 class="text-base-content mb-0.5 font-medium">Cristofer Torff</h6>
                    <div class="flex items-center rcoa6">
                      <p class="text-base-content/50 text-sm">12 Minutes ago</p>
                      <span class="os56h nc4mv rounded-full"></span>
                      <p class="text-base-content/50 text-sm">New post</p>
                    </div>
                  </div>
                  <div class="flex jz3o6 items-center sly4q">
                    <button class="btn geut3 btn-circle btn-text">
                      <span class="icon-[tabler--x] text-base-content/80 size-4"></span>
                    </button>
                    <div class="bg-primary nc4mv rounded-full"></div>
                  </div>
                </div>
              </li>
              <li>
                <hr class="border-base-content/20 ltzhj aa5ss">
              </li>
              <li>
                <div class="flex w-full items-center sly4q mrpnf">
                  <div class="nfjpm">
                    <div class="j4z3m rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="avatar">
                    </div>
                  </div>
                  <div class="e6ynr">
                    <h6 class="text-base-content mb-0.5 font-medium">Deni Arison</h6>
                    <div class="flex items-center rcoa6">
                      <p class="text-base-content/50 text-sm">27 Minutes ago</p>
                      <span class="os56h nc4mv rounded-full"></span>
                      <p class="text-base-content/50 text-sm">New comment</p>
                    </div>
                  </div>
                  <div class="flex jz3o6 items-center sly4q">
                    <button class="btn geut3 btn-circle btn-text">
                      <span class="icon-[tabler--x] text-base-content/80 size-4"></span>
                    </button>
                    <div class="bg-primary nc4mv rounded-full"></div>
                  </div>
                </div>
              </li>
              <li>
                <hr class="border-base-content/20 ltzhj aa5ss">
              </li>
              <li>
                <div class="flex w-full sly4q mrpnf">
                  <div class="nfjpm">
                    <div class="j4z3m rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="avatar">
                    </div>
                  </div>
                  <div class="e6ynr">
                    <h6 class="text-base-content mb-0.5 font-medium z6s37">
                      Anna has applied to create an ad for your campaign
                    </h6>
                    <div class="oobh7 flex items-center dcvi3">
                      <p class="text-base-content/50 text-sm">2 hours ago</p>
                      <span class="os56h nc4mv rounded-full"></span>
                      <p class="text-base-content/50 text-sm">New request for campaign</p>
                    </div>
                    <div class="flex njdg2">
                      <button class="btn btn-sm">Decline</button>
                      <button class="btn btn-sm btn-primary">Accept</button>
                    </div>
                  </div>
                </div>
              </li>
              <li>
                <hr class="border-base-content/20 ltzhj aa5ss">
              </li>
              <li>
                <div class="flex w-full sly4q mrpnf">
                  <div class="nfjpm">
                    <div class="j4z3m rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="avatar">
                    </div>
                  </div>
                  <div class="e6ynr">
                    <h6 class="text-base-content mb-0.5 wtjfs font-medium">Jason attached the file</h6>
                    <div class="oobh7 flex items-center dcvi3">
                      <p class="text-base-content/50 text-sm">6 hours ago</p>
                      <span class="os56h nc4mv rounded-full"></span>
                      <p class="text-base-content/50 text-sm">Attached files</p>
                    </div>
                    <div class="flex items-center bglhu qbqme">
                      <span class="icon-[tabler--link] size-4"></span>
                      <p class="mnco6 lv50x">Work examples.com</p>
                    </div>
                  </div>
                </div>
              </li>
            </ul>
          </div>
          <div id="tabs-basic-2" class="hidden" role="tabpanel" aria-labelledby="tabs-basic-item-2">
            <ul class="adede">
              <li>
                <div class="flex w-full items-center sly4q mrpnf">
                  <div class="nfjpm">
                    <div class="kqy8v rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                    </div>
                  </div>
                  <div class="e6ynr">
                    <h6 class="text-base-content mb-0.5 font-medium">New Update Available</h6>
                    <div class="flex items-center dcvi3">
                      <p class="text-base-content/50 text-sm">1 hour ago</p>
                      <span class="os56h nc4mv rounded-full"></span>
                      <p class="text-base-content/50 text-sm">Click to update</p>
                    </div>
                  </div>
                  <div class="flex jz3o6 items-center sly4q">
                    <button class="btn geut3 btn-circle btn-text">
                      <span class="icon-[tabler--x] text-base-content/80 size-4"></span>
                    </button>
                    <div class="bg-primary nc4mv rounded-full"></div>
                  </div>
                </div>
              </li>
              <li>
                <hr class="border-base-content/20 ltzhj aa5ss">
              </li>
              <li>
                <div class="flex w-full items-center sly4q mrpnf">
                  <div class="nfjpm">
                    <div class="kqy8v rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                    </div>
                  </div>
                  <div class="e6ynr">
                    <h6 class="text-base-content mb-0.5 font-medium">Privacy Policy Update</h6>
                    <div class="flex items-center dcvi3">
                      <p class="text-base-content/50 text-sm">3 hours ago</p>
                      <span class="os56h nc4mv rounded-full"></span>
                      <p class="text-base-content/50 text-sm">Review terms</p>
                    </div>
                  </div>
                  <div class="flex jz3o6 items-center sly4q">
                    <button class="btn geut3 btn-circle btn-text">
                      <span class="icon-[tabler--x] text-base-content/80 size-4"></span>
                    </button>
                    <div class="bg-primary nc4mv rounded-full"></div>
                  </div>
                </div>
              </li>
              <li>
                <hr class="border-base-content/20 ltzhj aa5ss">
              </li>
              <li>
                <div class="flex w-full items-center sly4q mrpnf">
                  <div class="nfjpm">
                    <div class="kqy8v rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                    </div>
                  </div>
                  <div class="e6ynr">
                    <h6 class="text-base-content mb-0.5 font-medium">Account Security Alert</h6>
                    <div class="flex items-center dcvi3">
                      <p class="text-base-content/50 text-sm">5 hours ago</p>
                      <span class="os56h nc4mv rounded-full"></span>
                      <p class="text-base-content/50 text-sm">Check activity</p>
                    </div>
                  </div>
                  <div class="flex jz3o6 items-center sly4q">
                    <button class="btn geut3 btn-circle btn-text">
                      <span class="icon-[tabler--x] text-base-content/80 size-4"></span>
                    </button>
                    <div class="bg-primary nc4mv rounded-full"></div>
                  </div>
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
  <div class="dhabr flex i5kri jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--placement:bottom]">
      <button id="profile-dropdown" type="button" class="dropdown-toggle kqy8v" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="User Avatar" class="rounded-box">
      </button>
      <ul class="dropdown-menu dropdown-open:opacity-100 w-full w30ex adede hidden" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1" style="transform: translate3d(305px, 70px, 0px);" data-placement="bottom">
        <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
          <div class="nfjpm a3rpr">
            <div class="kqy8v rounded-full">
              <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
            </div>
          </div>
          <div>
            <h6 class="text-base-content mb-0.5 t3mfo">Cristofer Torff</h6>
            <p class="text-base-content/80 font-medium">info@example.com</p>
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
          <hr class="border-base-content/20 mjaal zkwo0">
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
  <div class="dhabr flex hono0 jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--placement:bottom]">
      <button id="simple-profile-dropdown" type="button" class="dropdown-toggle kqy8v rounded-full" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="User Avatar" class="rounded-field">
      </button>
      <ul class="dropdown-menu dropdown-open:opacity-100 w-full w30ex adede hidden" role="menu" aria-orientation="vertical" aria-labelledby="simple-profile-dropdown" tabindex="-1" style="transform: translate3d(305px, 70px, 0px);" data-placement="bottom">
        <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
          <div class="nfjpm">
            <div class="kqy8v rounded-full">
              <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="User Avatar">
            </div>
          </div>
          <div>
            <h6 class="text-base-content mb-0.5 t3mfo">Cerry John</h6>
            <p class="text-base-content/80 font-medium">Cerry@example.com</p>
          </div>
        </li>
        <li class="b9hof">
          <ul class="oln2j rounded-field flex w-full border p-0.5 *:w-full">
            <li>
              <label class="has-checked:bg-neutral/10 rounded-field flex lx78o jz3o6 items-center j2be9 py-2">
                <input type="radio" name="radioFont" class="theme-controller d6aiv bmjz1 iduv5 hidden" value="light">
                <span class="icon-[tabler--sun] size-5"></span>
              </label>
            </li>
            <li>
              <label class="has-checked:bg-neutral/10 rounded-field flex lx78o jz3o6 items-center j2be9 py-2">
                <input type="radio" name="radioFont" class="theme-controller d6aiv bmjz1 iduv5 hidden" value="dark">
                <span class="icon-[tabler--moon] size-5"></span>
              </label>
            </li>
            <li>
              <label class="has-checked:bg-neutral/10 rounded-field flex lx78o jz3o6 items-center j2be9 py-2">
                <input type="radio" name="radioFont" class="theme-controller d6aiv bmjz1 iduv5 hidden" value="default" checked="">
                <span class="icon-[tabler--device-laptop] size-5"></span>
              </label>
            </li>
          </ul>
        </li>
        <li>
          <hr class="border-base-content/20 mjaal zkwo0">
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--building-store] size-5"></span>
            Your Shop
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--book-2] size-5"></span>
            Documentation
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--replace] size-5"></span>
            Affiliate
          </a>
        </li>
        <li class="mb-1">
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--settings] size-5"></span>
            Settings
          </a>
        </li>
        <li class="u9px6 f1870 dhfwm">
          <a class="btn btn-text gauh6 rhmi6 lxes6 ib2q4 px-3 ejsm2" href="#">
            <span class="icon-[tabler--logout] size-5"></span>
            Log out
          </a>
        </li>
      </ul>
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
  <div class="bg-base-100 flex c3es3 jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex w-full brf1a [--offset:5] [--placement:bottom] open">
      <button id="workshop-dropdown" type="button" class="dropdown-toggle dhabr rounded-box flex w-full items-center njdg2 j2be9 mwpft" aria-haspopup="menu" aria-expanded="true" aria-label="Dropdown">
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
      <ul class="dropdown-menu dropdown-open:opacity-100 w-full w30ex vi1oq block" role="menu" aria-orientation="vertical" aria-labelledby="workshop-dropdown" tabindex="-1" style="position: fixed; inset: 0px auto auto 0px; margin: 0px; transform: translate3d(305px, 93px, 0px);" data-placement="bottom">
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
  <div class="dhabr flex qcm9b jz3o6 items-center fbpri">
    <div class="xijwk">
      <!-- Select -->
      <div class="advance-select relative"><select multiple="" data-select="{&quot;placeholder&quot;:&quot;Select multiple options...&quot;,&quot;toggleTag&quot;:&quot;&lt;button type=\&quot;button\&quot; aria-expanded=\&quot;false\&quot;&gt;&lt;/button&gt;&quot;,&quot;toggleClasses&quot;:&quot;ayy45 select-disabled:pointer-events-none select-disabled:opacity-40&quot;,&quot;dropdownClasses&quot;:&quot;rpouc&quot;,&quot;optionClasses&quot;:&quot;advance-select-option px-3 selected:select-active&quot;,&quot;optionTemplate&quot;:&quot;&lt;div class=\&quot;flex justify-between items-center w-full\&quot;&gt;&lt;div class=\&quot;me-2\&quot; data-icon&gt;&lt;/div&gt;&lt;div&gt;&lt;div class=\&quot;text-base-content \&quot; data-title&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=\&quot;ms-auto\&quot;&gt;&lt;span class=\&quot;icon-[tabler--check] shrink-0 size-4 text-primary hidden selected:block \&quot;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&quot;,&quot;extraMarkup&quot;:&quot;&lt;span class=\&quot;icon-[tabler--caret-up-down] shrink-0 size-4 text-base-content absolute top-1/2 c6rnh a4kns \&quot;&gt;&lt;/span&gt;&quot;}" class="hidden" style="display: none;">
        
        
        
        
        
        
      <option value="">Choose</option><option selected="" value="1" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;shrink-0 size-8 rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png\&quot; alt=\&quot;Ethan Caldwell\&quot; /&gt;&quot;}">
          Ethan Caldwell
        </option><option value="2" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;shrink-0 size-8 rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png\&quot; alt=\&quot;Isabella Martinez\&quot; /&gt;&quot;}">
          Isabella Martinez
        </option><option value="3" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;shrink-0 size-8 rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png\&quot; alt=\&quot;Ava Thompson\&quot; /&gt;&quot;}">
          Ava Thompson
        </option><option value="4" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;shrink-0 size-8 rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png\&quot; alt=\&quot;Isabella Martinez\&quot; /&gt;&quot;}">
          Emma Wright
        </option><option value="5" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;shrink-0 size-8 rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png\&quot; alt=\&quot;Ava Thompson\&quot; /&gt;&quot;}">
          Laura Perez
        </option></select><button type="button" aria-expanded="false" class="ayy45 select-disabled:pointer-events-none select-disabled:opacity-40"><span class="truncate">
          Ethan Caldwell
        </span></button><div data-select-dropdown="" class="absolute rpouc hidden" role="listbox" tabindex="-1" aria-orientation="vertical" style=""><div data-value="1" data-title-value="
          Ethan Caldwell
        " tabindex="0" class="cursor-pointer selected advance-select-option px-3 selected:select-active" data-id="0"><div class="flex justify-between items-center w-full"><div class="me-2" data-icon=""><img class="shrink-0 size-8 rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Ethan Caldwell"></div><div><div class="text-base-content " data-title="">
          Ethan Caldwell
        </div></div><div class="ms-auto"><span class="icon-[tabler--check] shrink-0 size-4 text-primary hidden selected:block "></span></div></div></div><div data-value="2" data-title-value="
          Isabella Martinez
        " tabindex="1" class="cursor-pointer advance-select-option px-3 selected:select-active" data-id="1"><div class="flex justify-between items-center w-full"><div class="me-2" data-icon=""><img class="shrink-0 size-8 rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Isabella Martinez"></div><div><div class="text-base-content " data-title="">
          Isabella Martinez
        </div></div><div class="ms-auto"><span class="icon-[tabler--check] shrink-0 size-4 text-primary hidden selected:block "></span></div></div></div><div data-value="3" data-title-value="
          Ava Thompson
        " tabindex="2" class="cursor-pointer advance-select-option px-3 selected:select-active" data-id="2"><div class="flex justify-between items-center w-full"><div class="me-2" data-icon=""><img class="shrink-0 size-8 rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="Ava Thompson"></div><div><div class="text-base-content " data-title="">
          Ava Thompson
        </div></div><div class="ms-auto"><span class="icon-[tabler--check] shrink-0 size-4 text-primary hidden selected:block "></span></div></div></div><div data-value="4" data-title-value="
          Emma Wright
        " tabindex="3" class="cursor-pointer advance-select-option px-3 selected:select-active" data-id="3"><div class="flex justify-between items-center w-full"><div class="me-2" data-icon=""><img class="shrink-0 size-8 rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="Isabella Martinez"></div><div><div class="text-base-content " data-title="">
          Emma Wright
        </div></div><div class="ms-auto"><span class="icon-[tabler--check] shrink-0 size-4 text-primary hidden selected:block "></span></div></div></div><div data-value="5" data-title-value="
          Laura Perez
        " tabindex="4" class="cursor-pointer advance-select-option px-3 selected:select-active" data-id="4"><div class="flex justify-between items-center w-full"><div class="me-2" data-icon=""><img class="shrink-0 size-8 rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Ava Thompson"></div><div><div class="text-base-content " data-title="">
          Laura Perez
        </div></div><div class="ms-auto"><span class="icon-[tabler--check] shrink-0 size-4 text-primary hidden selected:block "></span></div></div></div></div><span class="icon-[tabler--caret-up-down] shrink-0 size-4 text-base-content absolute top-1/2 c6rnh a4kns "></span></div>
      <!-- End Select -->
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
  <div class="dhabr flex qcm9b jz3o6 items-center fbpri">
    <div class="xijwk">
      <!-- Select -->
      <div class="advance-select relative"><select multiple="" data-select="{&quot;placeholder&quot;:&quot;Select multiple options...&quot;,&quot;toggleTag&quot;:&quot;&lt;button type=\&quot;button\&quot; aria-expanded=\&quot;false\&quot;&gt;&lt;/button&gt;&quot;,&quot;toggleClasses&quot;:&quot;ayy45 select-disabled:pointer-events-none select-disabled:opacity-40&quot;,&quot;dropdownClasses&quot;:&quot;rpouc&quot;,&quot;optionClasses&quot;:&quot;advance-select-option px-3 selected:select-active&quot;,&quot;optionTemplate&quot;:&quot;&lt;div class=\&quot;flex justify-between items-center w-full\&quot;&gt;&lt;div class=\&quot;me-2\&quot; data-icon&gt;&lt;/div&gt;&lt;div&gt;&lt;div class=\&quot;text-base-content \&quot; data-title&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=\&quot;ms-auto\&quot;&gt;&lt;span class=\&quot;icon-[tabler--check] shrink-0 size-4 text-primary hidden selected:block \&quot;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&quot;,&quot;extraMarkup&quot;:&quot;&lt;span class=\&quot;icon-[tabler--caret-up-down] shrink-0 size-4 text-base-content absolute top-1/2 c6rnh a4kns \&quot;&gt;&lt;/span&gt;&quot;}" class="hidden" style="display: none;">
        
        
        
        
        
        
      <option value="">Choose</option><option selected="" value="1" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;shrink-0 size-8 rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png\&quot; alt=\&quot;Ethan Caldwell\&quot; /&gt;&quot;}">
          Ethan Caldwell
        </option><option value="2" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;shrink-0 size-8 rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png\&quot; alt=\&quot;Isabella Martinez\&quot; /&gt;&quot;}">
          Isabella Martinez
        </option><option value="3" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;shrink-0 size-8 rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png\&quot; alt=\&quot;Ava Thompson\&quot; /&gt;&quot;}">
          Ava Thompson
        </option><option value="4" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;shrink-0 size-8 rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png\&quot; alt=\&quot;Isabella Martinez\&quot; /&gt;&quot;}">
          Emma Wright
        </option><option value="5" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;shrink-0 size-8 rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png\&quot; alt=\&quot;Ava Thompson\&quot; /&gt;&quot;}">
          Laura Perez
        </option></select><button type="button" aria-expanded="false" class="ayy45 select-disabled:pointer-events-none select-disabled:opacity-40"><span class="truncate">
          Ethan Caldwell
        </span></button><div data-select-dropdown="" class="absolute rpouc hidden" role="listbox" tabindex="-1" aria-orientation="vertical" style=""><div data-value="1" data-title-value="
          Ethan Caldwell
        " tabindex="0" class="cursor-pointer selected advance-select-option px-3 selected:select-active" data-id="0"><div class="flex justify-between items-center w-full"><div class="me-2" data-icon=""><img class="shrink-0 size-8 rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Ethan Caldwell"></div><div><div class="text-base-content " data-title="">
          Ethan Caldwell
        </div></div><div class="ms-auto"><span class="icon-[tabler--check] shrink-0 size-4 text-primary hidden selected:block "></span></div></div></div><div data-value="2" data-title-value="
          Isabella Martinez
        " tabindex="1" class="cursor-pointer advance-select-option px-3 selected:select-active" data-id="1"><div class="flex justify-between items-center w-full"><div class="me-2" data-icon=""><img class="shrink-0 size-8 rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Isabella Martinez"></div><div><div class="text-base-content " data-title="">
          Isabella Martinez
        </div></div><div class="ms-auto"><span class="icon-[tabler--check] shrink-0 size-4 text-primary hidden selected:block "></span></div></div></div><div data-value="3" data-title-value="
          Ava Thompson
        " tabindex="2" class="cursor-pointer advance-select-option px-3 selected:select-active" data-id="2"><div class="flex justify-between items-center w-full"><div class="me-2" data-icon=""><img class="shrink-0 size-8 rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="Ava Thompson"></div><div><div class="text-base-content " data-title="">
          Ava Thompson
        </div></div><div class="ms-auto"><span class="icon-[tabler--check] shrink-0 size-4 text-primary hidden selected:block "></span></div></div></div><div data-value="4" data-title-value="
          Emma Wright
        " tabindex="3" class="cursor-pointer advance-select-option px-3 selected:select-active" data-id="3"><div class="flex justify-between items-center w-full"><div class="me-2" data-icon=""><img class="shrink-0 size-8 rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="Isabella Martinez"></div><div><div class="text-base-content " data-title="">
          Emma Wright
        </div></div><div class="ms-auto"><span class="icon-[tabler--check] shrink-0 size-4 text-primary hidden selected:block "></span></div></div></div><div data-value="5" data-title-value="
          Laura Perez
        " tabindex="4" class="cursor-pointer advance-select-option px-3 selected:select-active" data-id="4"><div class="flex justify-between items-center w-full"><div class="me-2" data-icon=""><img class="shrink-0 size-8 rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Ava Thompson"></div><div><div class="text-base-content " data-title="">
          Laura Perez
        </div></div><div class="ms-auto"><span class="icon-[tabler--check] shrink-0 size-4 text-primary hidden selected:block "></span></div></div></div></div><span class="icon-[tabler--caret-up-down] shrink-0 size-4 text-base-content absolute top-1/2 c6rnh a4kns "></span></div>
      <!-- End Select -->
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
  <div class="dhabr flex bo43t jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--placement:bottom]">
      <button id="apps-dropdown" type="button" class="dropdown-toggle btn btn-soft btn-square kqeru" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
        <span class="icon-[tabler--apps] mhx2u"></span>
      </button>
      <div class="dropdown-menu dropdown-open:opacity-100 w-full w30ex tnh37 hidden" role="menu" aria-orientation="vertical" aria-labelledby="apps-dropdown" tabindex="-1" style="transform: translate3d(305px, 76px, 0px);" data-placement="bottom">
        <div class="dhabr dpzny dbbf7 gap-x-2 yebw5 tnh37 fbpri">
          <a href="#" class="flex jz3o6 items-center bglhu">
            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dropdown/icon-1.png" class="rounded-box ao3uo shrink-0 rs1s9" alt="Search">
            <span class="text-base-content/80 text-sm font-medium">Search</span>
          </a>
          <a href="#" class="flex jz3o6 items-center bglhu">
            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dropdown/icon-2.png" class="rounded-box ao3uo shrink-0 rs1s9" alt="YouTube">
            <span class="text-base-content/80 text-sm font-medium">YouTube</span>
          </a>
          <a href="#" class="flex jz3o6 items-center bglhu">
            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dropdown/icon-3.png" class="rounded-box ao3uo shrink-0 rs1s9" alt="Maps">
            <span class="text-base-content/80 text-sm font-medium">Maps</span>
          </a>
          <a href="#" class="flex jz3o6 items-center bglhu">
            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dropdown/icon-4.png" class="rounded-box ao3uo shrink-0 rs1s9" alt="Gmail">
            <span class="text-base-content/80 text-sm font-medium">Gmail</span>
          </a>
          <a href="#" class="flex jz3o6 items-center bglhu">
            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dropdown/icon-5.png" class="rounded-box ao3uo shrink-0 rs1s9" alt="Drive">
            <span class="text-base-content/80 text-sm font-medium">Drive</span>
          </a>
          <a href="#" class="flex jz3o6 items-center bglhu">
            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dropdown/icon-6.png" class="rounded-box ao3uo shrink-0 rs1s9" alt="Play">
            <span class="text-base-content/80 text-sm font-medium">Play</span>
          </a>
          <a href="#" class="flex jz3o6 items-center bglhu">
            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dropdown/icon-7.png" class="rounded-box ao3uo shrink-0 rs1s9" alt="Calendar">
            <span class="text-base-content/80 text-sm font-medium">Calendar</span>
          </a>
          <a href="#" class="flex jz3o6 items-center bglhu">
            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dropdown/icon-8.png" class="rounded-box ao3uo shrink-0 rs1s9" alt="News">
            <span class="text-base-content/80 text-sm font-medium">News</span>
          </a>
          <a href="#" class="flex jz3o6 items-center bglhu">
            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dropdown/icon-9.png" class="rounded-box ao3uo shrink-0 rs1s9" alt="Meet">
            <span class="text-base-content/80 text-sm font-medium">Meet</span>
          </a>
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
  <div class="dhabr flex v5eqe jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--auto-close:inside] [--placement:bottom]">
      <button id="user-dropdown" type="button" class="dropdown-toggle kqy8v rounded-full" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="User Avatar" class="rounded-full">
      </button>
      <ul class="dropdown-menu dropdown-open:opacity-100 w-full tey33 adede hidden" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown" tabindex="-1" style="transform: translate3d(293px, 70px, 0px);" data-placement="bottom">
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--user] size-5"></span>
            My profile
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--settings] size-5"></span>
            Account setting
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--device-mobile] size-5"></span>
            Device management
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--logout] size-5"></span>
            Sign out
          </a>
        </li>
        <li>
          <hr class="border-base-content/20 mjaal aa5ss">
        </li>
        <li class="px-3">
          <p class="text-base-content/80 text-sm vxiam">switch account</p>
        </li>
        <li class="dropdown-item px-3">
          <label class="flex w-full lx78o items-center njdg2">
            <span class="nfjpm">
              <span class="kqy8v rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="User Avatar">
              </span>
            </span>
            <span class="flex e6ynr jz3o6">
              <span class="text-base-content mb-0.5 t3mfo">Mia de Silva</span>
              <span class="text-base-content/80 font-medium">Mia@example.com</span>
            </span>
            <input type="radio" name="radio-3" class="d6aiv saa4z bmjz1 zwsg8" id="radioType4" checked="">
          </label>
        </li>
        <li class="dropdown-item px-3">
          <label class="flex w-full lx78o items-center njdg2">
            <span class="nfjpm">
              <span class="kqy8v rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="User Avatar">
              </span>
            </span>
            <span class="flex e6ynr jz3o6">
              <span class="text-base-content mb-0.5 t3mfo">Caitlyn King</span>
              <span class="text-base-content/80 font-medium">King@example.com</span>
            </span>
            <input type="radio" name="radio-3" class="d6aiv saa4z bmjz1 zwsg8" checked="">
          </label>
        </li>
        <li>
          <button class="btn btn-primary rhmi6">
            <span class="icon-[tabler--logout] size-5"></span>
            Sign Out of all account
          </button>
        </li>
      </ul>
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
  <div class="dhabr flex p6ajn jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--auto-close:inside] [--placement:bottom] open">
      <button id="theme-dropdown" type="button" class="dropdown-toggle btn btn-square btn-primary" aria-haspopup="menu" aria-expanded="true" aria-label="Dropdown">
        <span class="icon-[tabler--color-swatch] girx5"></span>
      </button>
      <ul class="dropdown-menu dropdown-open:opacity-100 w-full tey33 adede block" role="menu" aria-orientation="vertical" aria-labelledby="theme-dropdown" tabindex="-1" style="position: fixed; inset: 0px auto auto 0px; margin: 0px; transform: translate3d(293px, 68px, 0px);" data-placement="bottom">
        <li>
          <ul class="oln2j z1hm0 rounded-field flex w-full buh4n border *:w-full">
            <li>
              <label class="has-checked:bg-neutral/10 u19e6 flex lx78o jz3o6 items-center mp7ep py-2">
                <input type="radio" name="radioFont" class="d6aiv bmjz1 iduv5 hidden" checked="">
                <span class="c9rvi font-medium">Ag</span>
                <span class="text-xs">Default</span>
              </label>
            </li>
            <li>
              <label class="has-checked:bg-neutral/10 flex lx78o jz3o6 items-center mp7ep py-2">
                <input type="radio" name="radioFont" class="d6aiv bmjz1 iduv5 hidden">
                <span class="c9rvi font-medium">Ag</span>
                <span class="text-xs">Serif</span>
              </label>
            </li>
            <li>
              <label class="has-checked:bg-neutral/10 n7umq flex lx78o jz3o6 items-center mp7ep py-2">
                <input type="radio" name="radioFont" class="d6aiv bmjz1 iduv5 hidden">
                <span class="c9rvi font-medium">Ag</span>
                <span class="text-xs">Mono</span>
              </label>
            </li>
          </ul>
        </li>
        <li>
          <div class="dropdown-item px-3">
            <span class="icon-[tabler--maximize] size-5"></span>
            <span class="e6ynr">Full width</span>
            <input type="checkbox" class="q0yur ji544 bqy1f">
          </div>
        </li>
        <li>
          <div class="dropdown-item px-3">
            <span class="icon-[tabler--stars] size-5"></span>
            <span>AI suggestions</span>
            <div class="e6ynr"><span class="ijn5q bxh1m o1g2m pze98">Alpha</span></div>
            <input type="checkbox" class="q0yur ji544 bqy1f">
          </div>
        </li>
        <li>
          <hr class="border-base-content/20 mjaal aa5ss">
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--microphone] size-5"></span>
            Dictate
          </a>
        </li>
        <li>
          <hr class="border-base-content/20 mjaal aa5ss">
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--copy] size-5"></span>
            Copy link
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--arrow-forward-up] size-5"></span>
            Move to.....
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--trash] size-5"></span>
            Move to trash
          </a>
        </li>
        <li>
          <hr class="border-base-content/20 mjaal aa5ss">
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--world] size-5"></span>
            Public
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--printer] size-5"></span>
            Print
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--history] size-5"></span>
            Version History
          </a>
        </li>
      </ul>
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
  <div class="dhabr flex p6ajn jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--auto-close:inside] [--placement:bottom] open">
      <button id="theme-dropdown" type="button" class="dropdown-toggle btn btn-square btn-primary" aria-haspopup="menu" aria-expanded="true" aria-label="Dropdown">
        <span class="icon-[tabler--color-swatch] girx5"></span>
      </button>
      <ul class="dropdown-menu dropdown-open:opacity-100 w-full tey33 adede block" role="menu" aria-orientation="vertical" aria-labelledby="theme-dropdown" tabindex="-1" style="position: fixed; inset: 0px auto auto 0px; margin: 0px; transform: translate3d(293px, 68px, 0px);" data-placement="bottom">
        <li>
          <ul class="oln2j z1hm0 rounded-field flex w-full buh4n border *:w-full">
            <li>
              <label class="has-checked:bg-neutral/10 u19e6 flex lx78o jz3o6 items-center mp7ep py-2">
                <input type="radio" name="radioFont" class="d6aiv bmjz1 iduv5 hidden" checked="">
                <span class="c9rvi font-medium">Ag</span>
                <span class="text-xs">Default</span>
              </label>
            </li>
            <li>
              <label class="has-checked:bg-neutral/10 flex lx78o jz3o6 items-center mp7ep py-2">
                <input type="radio" name="radioFont" class="d6aiv bmjz1 iduv5 hidden">
                <span class="c9rvi font-medium">Ag</span>
                <span class="text-xs">Serif</span>
              </label>
            </li>
            <li>
              <label class="has-checked:bg-neutral/10 n7umq flex lx78o jz3o6 items-center mp7ep py-2">
                <input type="radio" name="radioFont" class="d6aiv bmjz1 iduv5 hidden">
                <span class="c9rvi font-medium">Ag</span>
                <span class="text-xs">Mono</span>
              </label>
            </li>
          </ul>
        </li>
        <li>
          <div class="dropdown-item px-3">
            <span class="icon-[tabler--maximize] size-5"></span>
            <span class="e6ynr">Full width</span>
            <input type="checkbox" class="q0yur ji544 bqy1f">
          </div>
        </li>
        <li>
          <div class="dropdown-item px-3">
            <span class="icon-[tabler--stars] size-5"></span>
            <span>AI suggestions</span>
            <div class="e6ynr"><span class="ijn5q bxh1m o1g2m pze98">Alpha</span></div>
            <input type="checkbox" class="q0yur ji544 bqy1f">
          </div>
        </li>
        <li>
          <hr class="border-base-content/20 mjaal aa5ss">
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--microphone] size-5"></span>
            Dictate
          </a>
        </li>
        <li>
          <hr class="border-base-content/20 mjaal aa5ss">
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--copy] size-5"></span>
            Copy link
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--arrow-forward-up] size-5"></span>
            Move to.....
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--trash] size-5"></span>
            Move to trash
          </a>
        </li>
        <li>
          <hr class="border-base-content/20 mjaal aa5ss">
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--world] size-5"></span>
            Public
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--printer] size-5"></span>
            Print
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--history] size-5"></span>
            Version History
          </a>
        </li>
      </ul>
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
  <div class="dhabr flex xdxvn jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--auto-close:inside] [--placement:bottom]">
      <button id="dropdown-drag" type="button" class="dropdown-toggle btn btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
        <span class="icon-[tabler--layout-columns] size-6"></span>
        Dropdown
        <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-4"></span>
      </button>
      <div class="dropdown-menu dropdown-open:opacity-100 w-full w30ex adede hidden" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-drag" tabindex="-1" style="transform: translate3d(304.992px, 68px, 0px);" data-placement="bottom">
        <div class="px-3 mwpft">
          <h6 class="text-base-content/50">Select Columns</h6>
        </div>
        <ul id="drag-dropdown" class="adede">
          <li class="dropdown-item px-3">
            <label class="wqwbi flex w-full lx78o items-center bglhu cbpaz" for="columns2">
              <input type="checkbox" class="d5jfq dlggn v1498" id="columns2">
              <span class="text-base-content e6ynr text-base">2 Columns</span>
              <span class="icon-[tabler--grip-vertical] text-base-content/50 handle xbs1l size-6 shrink-0 tnme4"></span>
            </label>
          </li>
          <li class="dropdown-item px-3">
            <label class="wqwbi flex w-full lx78o items-center bglhu cbpaz" for="columns4">
              <input type="checkbox" class="d5jfq dlggn v1498" id="columns4">
              <span class="text-base-content e6ynr text-base">4 Columns</span>
              <span class="icon-[tabler--grip-vertical] text-base-content/50 handle xbs1l size-6 shrink-0 tnme4"></span>
            </label>
          </li>
          <li class="dropdown-item px-3">
            <label class="wqwbi flex w-full lx78o items-center bglhu cbpaz" for="columns6">
              <input type="checkbox" class="d5jfq dlggn v1498" id="columns6">
              <span class="text-base-content e6ynr text-base">6 Columns</span>
              <span class="icon-[tabler--grip-vertical] text-base-content/50 handle xbs1l size-6 shrink-0 tnme4"></span>
            </label>
          </li>
          <li class="dropdown-item px-3">
            <label class="wqwbi flex w-full lx78o items-center bglhu cbpaz" for="columns8">
              <input type="checkbox" class="d5jfq dlggn v1498" id="columns8">
              <span class="text-base-content e6ynr text-base">8 Columns</span>
              <span class="icon-[tabler--grip-vertical] text-base-content/50 handle xbs1l size-6 shrink-0 tnme4"></span>
            </label>
          </li>
        </ul>
      </div>
    </div>
  </div>

  <script src="https://flyonui.becdn.net/pro/libs/sortablejs/Sortable.min.js"></script>

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
        // Handle example
        const handleExample = document.querySelector("#drag-dropdown")

        if (handleExample) {
          Sortable.create(handleExample, {
            animation: 150,
            dragClass: "!border-0",
            handle: ".handle" // handle's class
          })
        }
      })()
    })
  </script>
  

</body>


<body data-vh-checked="true">
  <div class="dhabr flex p6ajn jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--placement:bottom]">
      <button id="more-details-dropdown" type="button" class="dropdown-toggle btn btn-square btn-soft kqeru" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
        <span class="icon-[tabler--dots-vertical] mhx2u"></span>
      </button>
      <ul class="dropdown-menu dropdown-open:opacity-100 w-full iv1t3 adede hidden" role="menu" aria-orientation="vertical" aria-labelledby="more-details-dropdown" tabindex="-1" style="transform: translate3d(335px, 76px, 0px);" data-placement="bottom">
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--settings] size-5"></span>
            Settings
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--unlink] size-5"></span>
            Copy link
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--folders] size-5"></span>
            Move to a Folder
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--copy] size-5"></span>
            Duplicate
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--trash] size-5"></span>
            Move to Trash
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--arrow-back] size-5"></span>
            Undo
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--arrow-bar-up] size-5"></span>
            Export
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--brand-google-analytics] size-5"></span>
            Updates &amp; Analytics
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--versions] size-5"></span>
            Version History
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--alert-circle] size-5"></span>
            Report
          </a>
        </li>
      </ul>
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
  <div class="dhabr flex oypx8 jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--placement:bottom] open">
      <button id="dropdown-user" type="button" class="dropdown-toggle kqy8v rounded-full" aria-haspopup="menu" aria-expanded="true" aria-label="Dropdown">
        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="User Avatar" class="rounded-full">
      </button>
      <ul class="dropdown-menu dropdown-open:opacity-100 w-full w30ex adede block" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-user" tabindex="-1" style="position: fixed; inset: 0px auto auto 0px; margin: 0px; transform: translate3d(305px, 70px, 0px);" data-placement="bottom">
        <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
          <div class="nfjpm">
            <div class="kqy8v rounded-full">
              <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="User Avatar">
            </div>
          </div>
          <div>
            <h6 class="text-base-content mb-0.5 t3mfo">Cristofer Torff</h6>
            <p class="text-base-content/80 font-medium">info@example.com</p>
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
            <span class="icon-[tabler--layout-grid] size-5"></span>
            Feed
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--settings] size-5"></span>
            Account Settings
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--chart-infographic] size-5"></span>
            Analytics
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--book-2] size-5"></span>
            Guide
          </a>
        </li>
        <li>
          <a class="dropdown-item px-3" href="#">
            <span class="icon-[tabler--alert-circle] size-5"></span>
            Help Center
          </a>
        </li>
        <li>
          <div class="dropdown-item px-3">
            <span class="e6ynr">Theme</span>
            <div class="z1gph">
              <label class="btn-square g39h6 btn btn-soft geut3 rounded-s-full" for="light-theme">
                <span class="icon-[tabler--sun] size-4"></span>
              </label>
              <input class="g39h6 btn btn-soft geut3 theme-controller hidden" value="light" type="radio" id="light-theme" name="radio-15" aria-label="Radio 1">
              <input class="g39h6 btn btn-soft geut3 theme-controller hidden" value="dark" id="dark-theme" type="radio" name="radio-15" aria-label="Radio 2">
              <label class="btn-square g39h6 btn btn-soft geut3" for="dark-theme">
                <span class="icon-[tabler--moon] size-4"></span>
              </label>
              <input class="g39h6 btn btn-soft geut3 theme-controller hidden" id="default-theme" value="default" type="radio" name="radio-15" aria-label="Radio 3" checked="">
              <label class="btn-square g39h6 btn btn-soft geut3 jspog" for="default-theme">
                <span class="icon-[tabler--device-laptop] size-4"></span>
              </label>
            </div>
          </div>
        </li>
        <li>
          <hr class="border-base-content/20 mjaal zkwo0">
        </li>
        <li class="dropdown-item mb-1 px-3">
          <div class="flex w-full items-center justify-between bglhu">
            <div>
              <p class="text-base-content mb-0.5">Free Plan</p>
              <p class="text-base-content/80">13200 Views</p>
            </div>
            <a href="#" class="btn btn-primary btn-sm btn-soft">Upgrade</a>
          </div>
        </li>
        <li class="u9px6 f1870 dhfwm">
          <a class="btn btn-text gauh6 rhmi6 lxes6 ib2q4 px-3 ejsm2" href="#">
            <span class="icon-[tabler--logout] size-5"></span>
            Sign out
          </a>
        </li>
      </ul>
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
  <div class="dhabr flex ulhja jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--auto-close:inside] [--placement:bottom]">
      <button id="assign-dropdown" type="button" class="dropdown-toggle border-base-content/20 rounded-field flex items-center bglhu border px-2 b9hof" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
        <span class="nfjpm">
          <span class="xb3dd rounded-full">
            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-14.png" alt="avatar">
          </span>
        </span>
        <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-5"></span>
      </button>
      <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 adede" role="menu" aria-orientation="vertical" aria-labelledby="assign-dropdown" tabindex="-1">
        <li class="m67xf s7x45 justify-between a7thv iq08s j5f89">
          <h6 class="text-base-content t3mfo">Assign</h6>
          <button class="btn btn-text geut3 btn-circle"><span class="icon-[tabler--plus] size-5"></span></button>
        </li>

        <li>
          <div class="ljn0d">
            <span class="icon-[tabler--search] text-base-content/80 q7z0e me-2 size-5 shrink-0"></span>
            <label class="rui3g" for="seachbar">Search</label>
            <input type="text" class="sxihv" placeholder="Search" id="seachbar">
          </div>
        </li>
        <li>
          <a class="dropdown-item dh3pr px-3" href="#">
            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="avatar" class="size-5 rounded-full">
            <span class="e6ynr">Sophia Williams</span>
            <span class="icon-[tabler--check] hidden size-6 group-[.dropdown-active]:block"></span>
          </a>
        </li>
        <li>
          <a class="dropdown-item dropdown-active dh3pr px-3" href="#">
            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-14.png" alt="avatar" class="size-5 rounded-full">
            <span class="e6ynr">Moris Tom</span>
            <span class="icon-[tabler--check] hidden size-6 group-[.dropdown-active]:block"></span>
          </a>
        </li>
        <li>
          <a class="dropdown-item dh3pr px-3" href="#">
            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="avatar" class="size-5 rounded-full">
            <span class="e6ynr">Emma Wright</span>
            <span class="icon-[tabler--check] hidden size-6 group-[.dropdown-active]:block"></span>
          </a>
        </li>
      </ul>
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
  <div class="dhabr flex k1aow jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--auto-close:inside] [--placement:bottom]">
      <button id="invite-dropdown" type="button" class="dropdown-toggle btn btn-primary" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
        Invite
      </button>
      <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full i2w3z o63tj fnetp" role="menu" aria-orientation="vertical" aria-labelledby="invite-dropdown" tabindex="-1">
        <div class="zqxh1 flex jz3o6 items-center sly4q">
          <div class="nfjpm rmjll">
            <div class="jgsta kymho rounded-full">
              <span class="icon-[tabler--share] lpbrp"></span>
            </div>
          </div>
          <div class="rdi5h">
            <h4 class="text-base-content font-medium">Invite new members</h4>
            <p class="text-base-content/50 text-sm">Send invitation Likes to team members</p>
          </div>
        </div>
        <ul class="nbone px-3">
          <li>
            <div class="removing:translate-x-5 removing:opacity-0 flex items-center sly4q transition duration-300 a6lvc" id="member1">
              <div class="ljn0d ka2aa">
                <input type="text" class="sxihv" placeholder="demo@example.com" value="Adam@example.com" id="memberId1">
                <label class="rui3g" for="memberId1">Email</label>
                <span class="icon-[tabler--check] text-success q7z0e iduv5 size-5 shrink-0"></span>
              </div>
              <div class="dropdown relative inline-flex">
                <button id="dropdown-item1" type="button" class="dropdown-toggle btn gnw6d g2v48 border-base-content/40" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  Designer
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-4"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-item1" tabindex="-1">
                  <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can view</a></li>
                  <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can edit</a></li>
                  <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Owner</a></li>
                </ul>
              </div>

              <button class="icon-[tabler--circle-x-filled] size-6 shrink-0 lx78o c3pbw" data-remove-element="#member1" aria-label="Remove access"></button>
            </div>
          </li>
          <li>
            <div class="removing:translate-x-5 removing:opacity-0 flex items-center sly4q transition duration-300 a6lvc" id="member2">
              <div class="ljn0d ka2aa">
                <input type="text" class="sxihv" placeholder="demo@example.com" value="Tim@example.com" id="memberId2">
                <label class="rui3g" for="memberId2">Email</label>
                <span class="icon-[tabler--check] text-success q7z0e iduv5 size-5 shrink-0"></span>
              </div>
              <div class="dropdown relative inline-flex">
                <button id="dropdown-item2" type="button" class="dropdown-toggle btn gnw6d g2v48 border-base-content/40" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  Designer
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-4"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-item2" tabindex="-1">
                  <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can view</a></li>
                  <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can edit</a></li>
                  <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Owner</a></li>
                </ul>
              </div>

              <button class="icon-[tabler--circle-x-filled] size-6 shrink-0 lx78o c3pbw" data-remove-element="#member2" aria-label="Remove access"></button>
            </div>
          </li>
        </ul>
        <div class="flex items-center justify-between j2be9">
          <button class="btn btn-text gnw6d btn-sm">
            <span class="icon-[tabler--circle-plus] size-4"></span>
            Add another project
          </button>
          <button class="btn btn-primary btn-sm">
            Invite
            <span class="icon-[tabler--share]"></span>
          </button>
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
  <div class="dhabr flex xf7fd jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--auto-close:inside] [--placement:bottom]">
      <button id="loginDropdown" type="button" class="dropdown-toggle j4z3m" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="User Avatar" class="rounded-field">
      </button>
      <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="loginDropdown" tabindex="-1">
        <div class="justify flex jz3o6 items-center xk2ot px-3 mwpft rdi5h">
          <div class="nfjpm">
            <div class="n14me rounded-full">
              <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
            </div>
          </div>
          <h6 class="text-base-content t3mfo">Emma Wright</h6>
        </div>
        <div class="dhabr rounded-box e07xu oobh7 flex jz3o6">
          <div class="border-base-content/20 flex items-center justify-between w2qmy p-3">
            <p class="text-base-content t3mfo">Statistics</p>
            <p class="text-base-content/80 t3mfo">Last 90 days</p>
          </div>
          <div>
            <div id="customerRatingsChart" style="min-height: 160px;"><div id="apexcharts6gkzfuhg" class="apexcharts-canvas apexcharts6gkzfuhg" style="width: 0px; height: 145px;"><svg xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" class="apexcharts-svg" xmlns:data="ApexChartsNS" transform="translate(0, 0)" width="0" height="145"><foreignObject x="0" y="0" width="0" height="145"></foreignObject><g class="apexcharts-inner apexcharts-graphical"><defs></defs></g></svg><div class="apexcharts-legend"></div></div></div>
          </div>
        </div>
        <ul class="adede">
          <li>
            <a class="dropdown-item px-3" href="#">Work Preferences</a>
          </li>
          <li>
            <a class="dropdown-item px-3" href="#">Projects overview</a>
          </li>
          <li class="axeut">
            <a class="dropdown-item px-3" href="#">Setting</a>
          </li>
          <li class="u9px6 f1870 imp9n">
            <a class="btn btn-text rhmi6 ym8i9 ib2q4 px-3 ejsm2" href="#">Sign Out</a>
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
        buildChart("#customerRatingsChart", () => ({
          chart: {
            height: 145,
            type: "line",
            toolbar: { show: false },
            zoom: { enabled: false },
            dropShadow: {
              enabled: true,
              top: 10,
              left: 0,
              blur: 4,
              color: "#000",
              opacity: 0.08
            }
          },
          series: [
            {
              name: "Performance",
              data: [20, 32, 22, 65, 40, 46, 34, 70, 75]
            }
          ],
          stroke: {
            curve: "smooth",
            width: 4
          },
          legend: { show: false },
          colors: ["var(--color-primary)"],
          grid: { show: false },
          tooltip: {
            custom: function (props) {
              const { categories } = props.ctx.opts.xaxis
              const { dataPointIndex } = props
              return buildTooltip(props, {
                title: categories[dataPointIndex],
                valuePrefix: "",
                hasTextLabel: true,
                labelDivider: ":",
                seriesExtClasses: "gap-2"
              })
            }
          },
          markers: {
            size: 6,
            colors: "transparent",
            strokeColors: "transparent",
            strokeWidth: 5,
            hover: { size: 6 },
            discrete: [
              {
                fillColor: "#fff",
                seriesIndex: 0,
                dataPointIndex: 3, // Highlight a specific point
                strokeColor: "#000",
                size: 6
              }
            ]
          },
          xaxis: {
            labels: {
              style: {
                colors: "color-mix(in oklab, var(--color-base-content) 80%, transparent)",
                fontSize: "13px"
              },
              show: false
            },
            axisTicks: { show: false },
            axisBorder: { show: false },
            categories: [" ", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul"]
          },
          yaxis: { show: false }
        }))
      })()
    })
  </script>
  

</body>


<body data-vh-checked="true">
  <div class="dhabr flex v5eqe jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--auto-close:inside] [--placement:bottom]">
      <button id="tag-dropdown" type="button" class="dropdown-toggle btn btn-square btn-primary" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
        <span class="icon-[tabler--tag] girx5"></span>
      </button>
      <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="tag-dropdown" tabindex="-1">
        <div class="m67xf mb-0.5 jz3o6 xk2ot pelb3 f1870 er88f">
          <div class="flex w-full items-center justify-between px-3 mwpft">
            <h6 class="text-base-content t3mfo">Tags</h6>
            <button class="btn btn-text geut3 btn-circle"><span class="icon-[tabler--plus] size-5"></span></button>
          </div>
          <div class="ljn0d">
            <span class="icon-[tabler--search] text-base-content/80 q7z0e me-2 size-5 shrink-0"></span>
            <label class="rui3g" for="seachbar">Search</label>
            <input type="text" class="sxihv" placeholder="Search" id="seachbar">
          </div>
        </div>
        <div class="dropdown-item px-3">
          <label class="wqwbi flex w-full lx78o items-center bglhu cbpaz" for="checkboxBug">
            <span class="bg-primary y3l6l rounded-full"></span>
            <span class="text-base-content e6ynr text-base">Bug</span>
            <input type="checkbox" class="d5jfq dlggn v1498" id="checkboxBug" checked="">
          </label>
        </div>
        <div class="dropdown-item px-3">
          <label class="wqwbi flex w-full lx78o items-center bglhu cbpaz" for="checkboxClosed">
            <span class="fqx4e y3l6l rounded-full"></span>
            <span class="text-base-content e6ynr text-base">Closed</span>
            <input type="checkbox" class="d5jfq dlggn v1498" id="checkboxClosed">
          </label>
        </div>
        <div class="dropdown-item px-3">
          <label class="wqwbi flex w-full lx78o items-center bglhu cbpaz" for="checkboxReviews">
            <span class="xrxte y3l6l rounded-full"></span>
            <span class="text-base-content e6ynr text-base">Reviews</span>
            <input type="checkbox" class="d5jfq dlggn v1498" id="checkboxReviews">
          </label>
        </div>
        <div class="dropdown-item px-3">
          <label class="wqwbi flex w-full lx78o items-center bglhu cbpaz" for="checkboxFeedback">
            <span class="kn3q0 y3l6l rounded-full"></span>
            <span class="text-base-content e6ynr text-base">Feedback</span>
            <input type="checkbox" class="d5jfq dlggn v1498" id="checkboxFeedback" checked="">
          </label>
        </div>
        <div class="dropdown-item px-3">
          <label class="wqwbi flex w-full lx78o items-center bglhu cbpaz" for="checkboxGeneric">
            <span class="e55a4 y3l6l rounded-full"></span>
            <span class="text-base-content e6ynr text-base">Generic</span>
            <input type="checkbox" class="d5jfq dlggn v1498" id="checkboxGeneric">
          </label>
        </div>
        <div class="dropdown-item px-3">
          <label class="wqwbi flex w-full lx78o items-center bglhu cbpaz" for="checkboxAccount">
            <span class="rti20 y3l6l rounded-full"></span>
            <span class="text-base-content e6ynr text-base">Account</span>
            <input type="checkbox" class="d5jfq dlggn v1498" id="checkboxAccount">
          </label>
        </div>
        <div class="dropdown-item px-3">
          <label class="wqwbi flex w-full lx78o items-center bglhu cbpaz" for="checkboxFAQ">
            <span class="bg-primary y3l6l rounded-full"></span>
            <span class="text-base-content e6ynr text-base">FAQ</span>
            <input type="checkbox" class="d5jfq dlggn v1498" id="checkboxFAQ">
          </label>
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



