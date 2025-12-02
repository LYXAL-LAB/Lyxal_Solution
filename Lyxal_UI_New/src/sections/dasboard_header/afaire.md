<div class="bg-base-200 flex min-h-screen flex-col">
    <!-- ---------- HEADER ---------- -->
    <div class="bg-base-100 border-base-content/20 sticky top-0 z-50 flex border-b lg:ps-75">
      <div class="mx-auto w-full max-w-7xl">
        <nav class="navbar py-2">
          <div class="navbar-start gap-2">
            <button
              type="button"
              class="btn btn-soft btn-square btn-sm lg:hidden"
              aria-haspopup="dialog"
              aria-expanded="false"
              aria-controls="layout-toggle"
              data-overlay="#layout-toggle"
            >
              <span class="icon-[tabler--menu-2] size-4.5"></span>
            </button>

            <!-- Search  -->
            <button
              type="button"
              class="max-sm:btn max-sm:btn-text max-sm:btn-sm max-sm:btn-square flex items-center gap-2 text-sm"
              aria-haspopup="dialog"
              aria-expanded="false"
              aria-controls="search-modal"
              data-overlay="#search-modal"
            >
              <span class="icon-[tabler--search] text-base-content size-5"></span>
              <span class="text-base-content/50 max-sm:hidden">Type to search...</span>
            </button>
          </div>

          <div class="navbar-end gap-6">
            <div class="flex items-center">
              <!-- Theme Dropdown  -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button
                  id="dropdown-theme"
                  type="button"
                  class="dropdown-toggle btn btn-sm btn-square btn-text"
                  aria-haspopup="menu"
                  aria-expanded="false"
                  aria-label="Dropdown"
                >
                  <span class="icon-[tabler--sun] size-4.5"></span>
                </button>
                <ul
                  class="dropdown-menu dropdown-open:opacity-100 hidden w-full max-w-50"
                  role="menu"
                  aria-orientation="vertical"
                  aria-labelledby="dropdown-theme"
                >
                  <li>
                    <input
                      type="radio"
                      name="theme-dropdown"
                      class="theme-controller btn btn-text w-full justify-start"
                      aria-label="Light"
                      value="light"
                    />
                  </li>
                  <li>
                    <input
                      type="radio"
                      name="theme-dropdown"
                      class="theme-controller btn btn-text w-full justify-start"
                      aria-label="Dark"
                      value="dark"
                    />
                  </li>
                  <li>
                    <input
                      type="radio"
                      name="theme-dropdown"
                      class="theme-controller btn btn-text w-full justify-start"
                      aria-label="System"
                      value="default"
                    />
                  </li>
                </ul>
              </div>

              <!-- Language Dropdown -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button
                  id="language-dropdown"
                  type="button"
                  class="dropdown-toggle btn btn-sm btn-square btn-text"
                  aria-haspopup="menu"
                  aria-expanded="false"
                  aria-label="Dropdown"
                >
                  <span class="icon-[tabler--language] size-4.5"></span>
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

              <!-- Activity Dropdown -->
              <button
                type="button"
                class="btn btn-sm btn-text btn-square"
                aria-haspopup="dialog"
                aria-expanded="false"
                aria-controls="activity-drawer"
                data-overlay="#activity-drawer"
              >
                <span class="icon-[tabler--activity] size-4.5"></span>
              </button>

              <!-- Notification Dropdown -->
              <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:24]">
                <button
                  id="notification-dropdown"
                  type="button"
                  class="dropdown-toggle btn btn-text btn-square btn-sm"
                  aria-haspopup="menu"
                  aria-expanded="false"
                  aria-label="Dropdown"
                >
                  <span class="indicator">
                    <span class="indicator-item bg-error size-2 rounded-full"></span>
                    <span class="icon-[tabler--bell] size-4.5"></span>
                  </span>
                </button>
                <div
                  class="dropdown-menu dropdown-open:opacity-100 hidden w-full max-w-122 space-y-0.5 px-3"
                  role="menu"
                  aria-orientation="vertical"
                  aria-labelledby="notification-dropdown"
                >
                  <div class="mb-0 flex w-full items-center justify-between gap-4 py-2.5">
                    <h6 class="text-base-content/50 text-sm uppercase">Notification</h6>
                    <span class="badge badge-soft badge-sm badge-primary rounded-full">8 New</span>
                  </div>
                  <div class="flex items-center justify-between">
                    <nav class="tabs tabs-bordered" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                      <button
                        type="button"
                        class="tab active-tab:tab-active active font-medium"
                        id="tabs-basic-item-1"
                        data-tab="#tabs-basic-1"
                        aria-controls="tabs-basic-1"
                        role="tab"
                        aria-selected="true"
                      >
                        4 Inbox
                      </button>
                      <button
                        type="button"
                        class="tab active-tab:tab-active font-medium"
                        id="tabs-basic-item-2"
                        data-tab="#tabs-basic-2"
                        aria-controls="tabs-basic-2"
                        role="tab"
                        aria-selected="false"
                      >
                        General
                      </button>
                    </nav>
                    <div class="dropdown relative inline-flex [--auto-close:inside]">
                      <button
                        id="notification-settings"
                        type="button"
                        class="dropdown-toggle btn btn-text btn-sm btn-square"
                        aria-haspopup="menu"
                        aria-expanded="false"
                        aria-label="Dropdown"
                      >
                        <span class="icon-[tabler--settings] size-5"></span>
                      </button>
                      <div
                        class="dropdown-menu dropdown-open:opacity-100 hidden min-w-30"
                        role="menu"
                        aria-orientation="vertical"
                        aria-labelledby="notification-settings"
                      >
                        <div class="dropdown-item items-center justify-between gap-2 px-2 py-1">
                          <label class="label-text text-base" for="settings1">Notification</label>
                          <input type="checkbox" class="switch switch-primary switch-sm" id="settings1" checked />
                        </div>
                        <div class="dropdown-item items-center justify-between gap-2 px-2 py-1">
                          <label class="label-text text-base" for="settings2">Location</label>
                          <input type="checkbox" class="switch switch-primary switch-sm" id="settings2" />
                        </div>
                      </div>
                    </div>
                  </div>
                  <hr class="border-base-content/20 -mx-3 -mt-1 border-1" />
                  <div>
                    <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1">
                      <ul>
                        <li>
                          <div class="flex w-full items-center gap-3 py-3">
                            <div class="avatar">
                              <div class="size-10 rounded-full">
                                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar" />
                              </div>
                            </div>
                            <div class="flex-1">
                              <h6 class="text-base-content mb-0.5 font-medium">Cristofer Torff</h6>
                              <div class="flex items-center gap-x-2.5">
                                <p class="text-base-content/50 text-sm">12 Minutes ago</p>
                                <span class="bg-neutral/20 size-1.5 rounded-full"></span>
                                <p class="text-base-content/50 text-sm">New post</p>
                              </div>
                            </div>
                            <div class="flex flex-col items-center gap-3">
                              <button class="btn btn-xs btn-circle btn-text">
                                <span class="icon-[tabler--x] text-base-content/80 size-4"></span>
                              </button>
                              <div class="bg-primary size-1.5 rounded-full"></div>
                            </div>
                          </div>
                        </li>
                        <li>
                          <hr class="border-base-content/20 -mx-3 my-1.5" />
                        </li>
                        <li>
                          <div class="flex w-full items-center gap-3 py-3">
                            <div class="avatar">
                              <div class="size-10 rounded-full">
                                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="avatar" />
                              </div>
                            </div>
                            <div class="flex-1">
                              <h6 class="text-base-content mb-0.5 font-medium">Deni Arison</h6>
                              <div class="flex items-center gap-x-2.5">
                                <p class="text-base-content/50 text-sm">27 Minutes ago</p>
                                <span class="bg-neutral/20 size-1.5 rounded-full"></span>
                                <p class="text-base-content/50 text-sm">New comment</p>
                              </div>
                            </div>
                            <div class="flex flex-col items-center gap-3">
                              <button class="btn btn-xs btn-circle btn-text">
                                <span class="icon-[tabler--x] text-base-content/80 size-4"></span>
                              </button>
                              <div class="bg-primary size-1.5 rounded-full"></div>
                            </div>
                          </div>
                        </li>
                        <li>
                          <hr class="border-base-content/20 -mx-3 my-1.5" />
                        </li>
                        <li>
                          <div class="flex w-full gap-3 py-3">
                            <div class="avatar">
                              <div class="size-10 rounded-full">
                                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="avatar" />
                              </div>
                            </div>
                            <div class="flex-1">
                              <h6 class="text-base-content mb-0.5 font-medium text-wrap">
                                Anna has applied to create an ad for your campaign
                              </h6>
                              <div class="mb-3 flex items-center gap-2.5">
                                <p class="text-base-content/50 text-sm">2 hours ago</p>
                                <span class="bg-neutral/20 size-1.5 rounded-full"></span>
                                <p class="text-base-content/50 text-sm">New request for campaign</p>
                              </div>
                              <div class="flex gap-4">
                                <button class="btn btn-sm">Decline</button>
                                <button class="btn btn-sm btn-primary">Accept</button>
                              </div>
                            </div>
                          </div>
                        </li>
                        <li>
                          <hr class="border-base-content/20 -mx-3 my-1.5" />
                        </li>
                        <li>
                          <div class="flex w-full gap-3 py-3">
                            <div class="avatar">
                              <div class="size-10 rounded-full">
                                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="avatar" />
                              </div>
                            </div>
                            <div class="flex-1">
                              <h6 class="text-base-content mb-0.5 line-clamp-1 font-medium">Jason attached the file</h6>
                              <div class="mb-3 flex items-center gap-2.5">
                                <p class="text-base-content/50 text-sm">6 hours ago</p>
                                <span class="bg-neutral/20 size-1.5 rounded-full"></span>
                                <p class="text-base-content/50 text-sm">Attached files</p>
                              </div>
                              <div class="flex items-center gap-2 py-1">
                                <span class="icon-[tabler--link] size-4"></span>
                                <p class="link link-hover">Work examples.com</p>
                              </div>
                            </div>
                          </div>
                        </li>
                      </ul>
                    </div>
                    <div id="tabs-basic-2" class="hidden" role="tabpanel" aria-labelledby="tabs-basic-item-2">
                      <ul class="space-y-0.5">
                        <li>
                          <div class="flex w-full items-center gap-3 py-3">
                            <div class="avatar">
                              <div class="w-10 rounded-full">
                                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar" />
                              </div>
                            </div>
                            <div class="flex-1">
                              <h6 class="text-base-content mb-0.5 font-medium">New Update Available</h6>
                              <div class="flex items-center gap-2.5">
                                <p class="text-base-content/50 text-sm">1 hour ago</p>
                                <span class="bg-neutral/20 size-1.5 rounded-full"></span>
                                <p class="text-base-content/50 text-sm">Click to update</p>
                              </div>
                            </div>
                            <div class="flex flex-col items-center gap-3">
                              <button class="btn btn-xs btn-circle btn-text">
                                <span class="icon-[tabler--x] text-base-content/80 size-4"></span>
                              </button>
                              <div class="bg-primary size-1.5 rounded-full"></div>
                            </div>
                          </div>
                        </li>
                        <li>
                          <hr class="border-base-content/20 -mx-3 my-1.5" />
                        </li>
                        <li>
                          <div class="flex w-full items-center gap-3 py-3">
                            <div class="avatar">
                              <div class="w-10 rounded-full">
                                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar" />
                              </div>
                            </div>
                            <div class="flex-1">
                              <h6 class="text-base-content mb-0.5 font-medium">Privacy Policy Update</h6>
                              <div class="flex items-center gap-2.5">
                                <p class="text-base-content/50 text-sm">3 hours ago</p>
                                <span class="bg-neutral/20 size-1.5 rounded-full"></span>
                                <p class="text-base-content/50 text-sm">Review terms</p>
                              </div>
                            </div>
                            <div class="flex flex-col items-center gap-3">
                              <button class="btn btn-xs btn-circle btn-text">
                                <span class="icon-[tabler--x] text-base-content/80 size-4"></span>
                              </button>
                              <div class="bg-primary size-1.5 rounded-full"></div>
                            </div>
                          </div>
                        </li>
                        <li>
                          <hr class="border-base-content/20 -mx-3 my-1.5" />
                        </li>
                        <li>
                          <div class="flex w-full items-center gap-3 py-3">
                            <div class="avatar">
                              <div class="w-10 rounded-full">
                                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar" />
                              </div>
                            </div>
                            <div class="flex-1">
                              <h6 class="text-base-content mb-0.5 font-medium">Account Security Alert</h6>
                              <div class="flex items-center gap-2.5">
                                <p class="text-base-content/50 text-sm">5 hours ago</p>
                                <span class="bg-neutral/20 size-1.5 rounded-full"></span>
                                <p class="text-base-content/50 text-sm">Check activity</p>
                              </div>
                            </div>
                            <div class="flex flex-col items-center gap-3">
                              <button class="btn btn-xs btn-circle btn-text">
                                <span class="icon-[tabler--x] text-base-content/80 size-4"></span>
                              </button>
                              <div class="bg-primary size-1.5 rounded-full"></div>
                            </div>
                          </div>
                        </li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Profile Dropdown -->
            <div class="dropdown relative inline-flex [--offset:21]">
              <button
                id="profile-dropdown"
                type="button"
                class="dropdown-toggle avatar"
                aria-haspopup="menu"
                aria-expanded="false"
                aria-label="Dropdown"
              >
                <span class="rounded-field size-9.5">
                  <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="User Avatar" />
                </span>
              </button>
              <ul
                class="dropdown-menu dropdown-open:opacity-100 hidden w-full max-w-75 space-y-0.5"
                role="menu"
                aria-orientation="vertical"
                aria-labelledby="profile-dropdown"
              >
                <li class="dropdown-header mb-1 gap-4 px-5 pt-4.5 pb-3.5">
                  <div class="avatar avatar-online-top">
                    <div class="w-10 rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="avatar" />
                    </div>
                  </div>
                  <div>
                    <h6 class="text-base-content mb-0.5 font-semibold">Charlotte Anne</h6>
                    <p class="text-base-content/80 font-medium">Influencer</p>
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
                  <hr class="border-base-content/20 -mx-2 my-1" />
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
                <li class="dropdown-footer p-2 pt-1">
                  <a class="btn btn-text btn-error btn-block h-11 justify-start px-3 font-normal" href="#">
                    <span class="icon-[tabler--logout] size-5"></span>
                    Logout
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </nav>
      </div>
    </div>

    <!-- Search Dropdown Content  -->
    <div
      id="search-modal"
      class="overlay modal overlay-open:opacity-100 overlay-open:duration-300 modal-middle hidden"
      role="dialog"
      tabindex="-1"
    >
      <div class="modal-dialog w-full max-w-145">
        <div class="modal-content overflow-auto shadow-none">
          <!-- SearchBox -->
          <div class="modal-header border-base-content/20 border-b-1 px-3 py-2">
            <div class="input no-focus border-0 px-0">
              <span class="icon-[tabler--search] text-base-content/80 my-auto me-2 size-5 shrink-0"></span>
              <input type="search" class="grow" placeholder="Search here..." id="kbdInput" />
              <label class="sr-only" for="kbdInput">Search</label>
            </div>
          </div>

          <nav class="tabs tabs-bordered py-2" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
            <button
              type="button"
              class="tab active-tab:tab-active active w-full font-medium"
              id="search-tabs-item-1"
              data-tab="#search-tabs-1"
              aria-controls="search-tabs-1"
              role="tab"
              aria-selected="true"
            >
              All
            </button>
            <button
              type="button"
              class="tab active-tab:tab-active w-full font-medium"
              id="search-tabs-item-2"
              data-tab="#search-tabs-2"
              aria-controls="search-tabs-2"
              role="tab"
              aria-selected="false"
            >
              Pages
            </button>
            <button
              type="button"
              class="tab active-tab:tab-active w-full font-medium"
              id="search-tabs-item-3"
              data-tab="#search-tabs-3"
              aria-controls="search-tabs-3"
              role="tab"
              aria-selected="false"
            >
              Integration
            </button>
            <button
              type="button"
              class="tab active-tab:tab-active w-full font-medium"
              id="search-tabs-item-4"
              data-tab="#search-tabs-4"
              aria-controls="search-tabs-4"
              role="tab"
              aria-selected="false"
            >
              Users
            </button>
          </nav>
          <!-- SearchBox Modal Body -->
          <div class="max-h-90 overflow-y-auto lg:max-h-121">
            <!-- SearchBox All Modal Body -->
            <div id="search-tabs-1" role="tabpanel" aria-labelledby="search-tabs-item-1">
              <!-- Pages Section -->
              <div class="modal-body">
                <div class="text-base-content/50 mb-1.5 text-sm uppercase">Pages</div>
                <ul class="space-y-1.5">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center gap-2 px-1 py-1.5" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center gap-2 px-1 py-1.5" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center gap-2 px-1 py-1.5" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="divider"></div>
              <!-- Interaction Section -->
              <div class="modal-body">
                <div class="text-base-content/50 mb-1.5 text-sm uppercase">Interaction</div>
                <ul class="space-y-1.5">
                  <li>
                    <a
                      class="hover:bg-base-200 rounded-field flex justify-between gap-2 px-1 py-1.5 max-sm:flex-col sm:items-center"
                      href="#"
                    >
                      <div class="flex items-center gap-3">
                        <div class="avatar avatar-placeholder">
                          <div class="bg-base-200 size-9.5 rounded-full">
                            <img
                              src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png"
                              alt="jira"
                              class="size-6"
                            />
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="avatar-group -space-x-3">
                        <div class="avatar">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar" />
                          </div>
                        </div>
                        <div class="avatar">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar" />
                          </div>
                        </div>
                        <div class="avatar">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar" />
                          </div>
                        </div>
                        <div class="avatar avatar-placeholder">
                          <div class="bg-neutral text-neutral-content size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a
                      class="hover:bg-base-200 rounded-field flex justify-between gap-2 px-1 py-1.5 max-sm:flex-col sm:items-center"
                      href="#"
                    >
                      <div class="flex items-center gap-3">
                        <div class="avatar avatar-placeholder">
                          <div class="bg-base-200 size-9.5 rounded-full">
                            <img
                              src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png"
                              alt="inferno"
                              class="size-6"
                            />
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="avatar-group -space-x-3">
                        <div class="avatar">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar" />
                          </div>
                        </div>
                        <div class="avatar">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar" />
                          </div>
                        </div>
                        <div class="avatar">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar" />
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="divider"></div>
              <!-- User Section -->
              <div class="modal-body">
                <div class="text-base-content/50 mb-1.5 text-sm uppercase">User</div>
                <ul class="space-y-1.5">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between gap-2 px-1 py-1.5">
                      <a href="#" class="flex grow items-center gap-3">
                        <div class="avatar">
                          <div class="size-9.5 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent" />
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center gap-2 max-sm:hidden">
                        <span class="badge badge-success badge-soft rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button
                            id="user-dropdown1"
                            type="button"
                            class="dropdown-toggle btn btn-text text-base-content btn-circle btn-xs"
                            aria-haspopup="menu"
                            aria-expanded="false"
                            aria-label="Dropdown"
                          >
                            <span class="icon-[tabler--dots-vertical] size-4.5"></span>
                          </button>
                          <ul
                            class="dropdown-menu dropdown-open:opacity-100 menu-sm hidden p-1"
                            role="menu"
                            aria-orientation="vertical"
                            aria-labelledby="user-dropdown1"
                          >
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between gap-2 px-1 py-1.5">
                      <a href="#" class="flex grow items-center gap-3">
                        <div class="avatar">
                          <div class="size-9.5 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin" />
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center gap-2 max-sm:hidden">
                        <span class="badge badge-error badge-soft rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button
                            id="user-dropdown2"
                            type="button"
                            class="dropdown-toggle btn btn-text text-base-content btn-circle btn-xs"
                            aria-haspopup="menu"
                            aria-expanded="false"
                            aria-label="Dropdown"
                          >
                            <span class="icon-[tabler--dots-vertical] size-4.5"></span>
                          </button>
                          <ul
                            class="dropdown-menu dropdown-open:opacity-100 menu-sm hidden p-1"
                            role="menu"
                            aria-orientation="vertical"
                            aria-labelledby="user-dropdown2"
                          >
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Pages Modal Body -->
            <div id="search-tabs-2" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-2">
              <div class="modal-body">
                <ul class="space-y-1.5">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center gap-2 px-1 py-1.5" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center gap-2 px-1 py-1.5" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center gap-2 px-1 py-1.5" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Integration Modal Body -->
            <div id="search-tabs-3" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-3">
              <div class="modal-body">
                <ul class="space-y-1.5">
                  <li>
                    <a
                      class="hover:bg-base-200 rounded-field flex justify-between gap-2 px-1 py-1.5 max-sm:flex-col sm:items-center"
                      href="#"
                    >
                      <div class="flex items-center gap-3">
                        <div class="avatar avatar-placeholder">
                          <div class="bg-base-200 size-9.5 rounded-full">
                            <img
                              src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png"
                              alt="jira"
                              class="size-6"
                            />
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="avatar-group -space-x-3">
                        <div class="avatar">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar" />
                          </div>
                        </div>
                        <div class="avatar">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar" />
                          </div>
                        </div>
                        <div class="avatar">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar" />
                          </div>
                        </div>
                        <div class="avatar avatar-placeholder">
                          <div class="bg-neutral text-neutral-content size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a
                      class="hover:bg-base-200 rounded-field flex justify-between gap-2 px-1 py-1.5 max-sm:flex-col sm:items-center"
                      href="#"
                    >
                      <div class="flex items-center gap-3">
                        <div class="avatar avatar-placeholder">
                          <div class="bg-base-200 size-9.5 rounded-full">
                            <img
                              src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png"
                              alt="inferno"
                              class="size-6"
                            />
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="avatar-group -space-x-3">
                        <div class="avatar">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar" />
                          </div>
                        </div>
                        <div class="avatar">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar" />
                          </div>
                        </div>
                        <div class="avatar">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar" />
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Users Modal Body -->
            <div id="search-tabs-4" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-4">
              <div class="modal-body">
                <ul class="space-y-1.5">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between gap-2 px-1 py-1.5">
                      <a href="#" class="flex items-center gap-3">
                        <div class="avatar">
                          <div class="size-9.5 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent" />
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center gap-2">
                        <span class="badge badge-success badge-soft rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button
                            id="user-dropdown3"
                            type="button"
                            class="dropdown-toggle btn btn-text text-base-content btn-circle btn-xs"
                            aria-haspopup="menu"
                            aria-expanded="false"
                            aria-label="Dropdown"
                          >
                            <span class="icon-[tabler--dots-vertical] size-4.5"></span>
                          </button>
                          <ul
                            class="dropdown-menu dropdown-open:opacity-100 menu-sm hidden p-1"
                            role="menu"
                            aria-orientation="vertical"
                            aria-labelledby="user-dropdown3"
                          >
                            <li><button class="dropdown-item px-2">View More</button></li>
                            <li><button class="dropdown-item px-2">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between gap-2 px-1 py-1.5">
                      <a href="#" class="flex items-center gap-3">
                        <div class="avatar">
                          <div class="size-9.5 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin" />
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center gap-2">
                        <span class="badge badge-error badge-soft rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button
                            id="user-dropdown4"
                            type="button"
                            class="dropdown-toggle btn btn-text text-base-content btn-circle btn-xs"
                            aria-haspopup="menu"
                            aria-expanded="false"
                            aria-label="Dropdown"
                          >
                            <span class="icon-[tabler--dots-vertical] size-4.5"></span>
                          </button>
                          <ul
                            class="dropdown-menu dropdown-open:opacity-100 menu-sm hidden p-1"
                            role="menu"
                            aria-orientation="vertical"
                            aria-labelledby="user-dropdown4"
                          >
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>
          </div>
          <!-- Footer Commands -->
          <div class="modal-footer border-base-content/20 text-base-content/50 gap-4 border-t-1 py-4 max-sm:hidden">
            <div class="flex grow items-center gap-2 text-sm">
              <kbd class="kbd kbd-sm">esc</kbd>
              <span>To close</span>
            </div>
            <div class="flex items-center gap-2 text-sm">
              <kbd class="kbd kbd-sm p-0"><span class="icon-[tabler--arrow-back] size-4"></span></kbd>
              <span>To Select</span>
            </div>
            <div class="flex items-center gap-2 text-sm">
              <kbd class="kbd kbd-sm p-0"><span class="icon-[tabler--arrow-up] size-4"></span></kbd>
              <kbd class="kbd kbd-sm p-0"><span class="icon-[tabler--arrow-down] size-4"></span></kbd>
              <span>To Navigate</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Activity Drawer Content  -->
    <div
      id="activity-drawer"
      class="overlay overlay-open:translate-x-0 drawer drawer-end hidden sm:max-w-104"
      role="dialog"
      tabindex="-1"
    >
      <div class="drawer-header border-base-content/20 border-b p-4">
        <h3 class="drawer-title text-base font-semibold">Activity</h3>
        <button type="button" class="btn btn-text btn-circle btn-xs" aria-label="Close" data-overlay="#activity-drawer">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
      </div>
      <div class="drawer-body p-0">
        <ul class="space-y-0">
          <!-- Joe Lincoln Activity -->
          <li class="flex items-start gap-4 p-4">
            <div class="avatar">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar" />
              </div>
            </div>
            <div class="flex-1">
              <div class="mb-1">
                <span class="text-base-content font-semibold">joe Lincoln</span>
                <span class="text-base-content text-sm">mentioned you in last trends topic</span>
              </div>
              <p class="text-base-content/50 mb-3 text-sm">18 Mins ago</p>

              <div class="bg-base-200 rounded-box border-base-content/20 border px-4 py-2.5">
                <p class="text-base-content mb-4 text-sm font-medium">
                  @Flyonui For an expert opinion, check out what Mike has to say on this topic!
                </p>
                <div class="input input-sm">
                  <input type="text" class="grow" placeholder="Reply" id="flyonuiReply" />
                  <span class="icon-[tabler--photo] text-base-content/80 my-auto ms-2 size-4 shrink-0"></span>
                </div>
              </div>
            </div>
          </li>

          <li><div class="divider"></div></li>

          <!-- Sofia -->
          <li class="flex items-start gap-4 p-4">
            <div class="avatar">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Sofia" />
              </div>
            </div>
            <div class="flex-1">
              <div class="mb-1">
                <span class="text-base-content font-semibold">Sofia</span>
                <span class="text-base-content text-sm">requested feedback on her design.</span>
              </div>
              <p class="text-base-content/50 text-sm">1 Hour ago</p>
            </div>
          </li>

          <li><div class="divider"></div></li>

          <!-- Jane Perez File Review -->
          <li class="flex items-start gap-4 p-4">
            <div class="avatar">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jane Perez" />
              </div>
            </div>
            <div class="flex-1">
              <div class="mb-1">
                <span class="text-base-content font-semibold">Jane Perez</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 mb-2.5 text-sm">3 Hours ago</p>
              <span class="badge badge-soft badge-lg">
                <span class="icon-[tabler--file-type-pdf] text-error"></span>
                invoices.pdf
              </span>
            </div>
          </li>

          <li><div class="divider"></div></li>

          <!-- Liam -->
          <li class="flex items-start gap-4 p-4">
            <div class="avatar">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Liam" />
              </div>
            </div>
            <div class="flex-1">
              <div class="mb-1">
                <span class="text-base-content font-semibold">Liam</span>
                <span class="text-base-content text-sm">has shared a project update.</span>
              </div>
              <p class="text-base-content/50 text-sm">5 Hours ago</p>
            </div>
          </li>

          <li><div class="divider"></div></li>

          <!-- Tyler Hero Design Project -->
          <li class="flex items-start gap-4 p-4">
            <div class="avatar">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="Tyler Hero" />
              </div>
            </div>
            <div class="flex-1">
              <div class="mb-1">
                <span class="text-base-content font-semibold">Tyler Hero</span>
                <span class="text-base-content text-sm">wants to view your design project</span>
              </div>
              <p class="text-base-content/50 mb-3 text-sm">18 Mins ago</p>

              <div class="bg-base-200 rounded-box border-base-content/20 flex items-center gap-4 border px-4 py-2.5">
                <div class="avatar avatar-placeholder">
                  <div class="bg-base-100 text-primary rounded-box size-8 p-2">
                    <img
                      src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/figma-icon.png"
                      alt="avatar"
                    />
                  </div>
                </div>
                <span class="text-sm font-medium">Launcher-UIkit.fig</span>
              </div>
            </div>
          </li>

          <li><div class="divider"></div></li>

          <!-- Denial Invite -->
          <li class="flex items-start gap-4 p-4">
            <div class="avatar">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Denial" />
              </div>
            </div>
            <div class="flex-1">
              <div class="mb-1">
                <span class="text-base-content font-semibold">Denial</span>
                <span class="text-base-content text-sm">Invite from invite link</span>
              </div>
              <p class="text-base-content/50 text-sm">3 Hours ago</p>
            </div>
          </li>

          <li><div class="divider"></div></li>

          <!-- Leslie Alexander Tags -->
          <li class="flex items-start gap-4 p-4">
            <div class="avatar">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Leslie Alexander" />
              </div>
            </div>
            <div class="flex-1">
              <div class="mb-1">
                <span class="text-base-content font-semibold">Leslie Alexander</span>
                <span class="text-base-content text-sm">new tags to Web Redesign</span>
              </div>
              <p class="text-base-content/50 mb-3 text-sm">18 Mins ago</p>

              <div class="flex gap-2.5">
                <span class="badge badge-soft badge-primary badge-sm">Client - Request</span>
                <span class="badge badge-soft badge-warning badge-sm">Figma</span>
                <span class="badge badge-soft badge-info badge-sm">Redesign</span>
              </div>
            </div>
          </li>

          <li><div class="divider"></div></li>

          <!-- Miya File Review -->
          <li class="flex items-start gap-4 p-4">
            <div class="avatar">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Miya" />
              </div>
            </div>
            <div class="flex-1">
              <div class="mb-1">
                <span class="text-base-content font-semibold">Miya</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 text-sm">10 Hours ago</p>
            </div>
          </li>
        </ul>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside
      id="layout-toggle"
      class="overlay overlay-open:translate-x-0 drawer drawer-start inset-y-0 start-0 hidden h-full [--auto-close:lg] sm:w-75 lg:z-50 lg:block lg:translate-x-0 lg:shadow-none"
      aria-label="Sidebar"
      tabindex="-1"
    >
      <div class="drawer-body border-base-content/20 h-full border-e p-6">
        <button
          type="button"
          class="btn btn-text btn-square btn-xs absolute end-1 top-1 sm:hidden"
          aria-label="Close"
          data-overlay="#layout-toggle"
        >
          <span class="icon-[tabler--x] size-4"></span>
        </button>
        <div class="border-base-content/20 rounded-box skeleton-striped h-full border"></div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->
    <div class="flex grow flex-col lg:ps-75">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="mx-auto w-full max-w-7xl flex-1 p-6">
        <div class="grid grid-cols-1 gap-6">
          <div class="card h-240 w-full">
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

<body data-vh-checked="true">
  <div class="dhabr flex min-h-screen jz3o6">
    <!-- ---------- HEADER ---------- -->
    <div class="supports-[backdrop-filter]:bg-base-200/60 fixed top-0 b3b8l vbjpl w-full mask-[linear-gradient(var(--color-base-200),var(--color-base-200)_18%,transparent_100%)] irmyt nslur"></div>
    <div class="sticky top-0 at1sq flex lg:ps-65">
      <div class="wpaot ndnti w-full owca9 rukzz">
        <nav class="hvzi2 rounded-field d50ic mwpft zw50f">
          <div class="szonh bglhu">
            <button type="button" class="btn btn-soft btn-square btn-sm lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
              <span class="icon-[tabler--menu-2] qmuz4"></span>
            </button>

            <!-- Search  -->
            <button type="button" class="max-sm:btn max-sm:btn-text max-sm:btn-sm max-sm:btn-square flex items-center bglhu text-sm" aria-haspopup="dialog" aria-expanded="false" aria-controls="search-modal" data-overlay="#search-modal">
              <span class="icon-[tabler--search] text-base-content qmuz4 sm:size-5"></span>
              <span class="text-base-content/50 max-sm:hidden">Type to search...</span>
            </button>
          </div>

          <div class="ktglt njdg2">
            <div class="flex items-center">
              <!-- Theme Dropdown -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button id="dropdown-theme" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--sun] qmuz4"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-theme" tabindex="-1">
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Light" value="light">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Dark" value="dark">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="System" value="default">
                  </li>
                </ul>
              </div>

              <!-- Language Dropdown -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button id="language-dropdown" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--language] qmuz4"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 adede" role="menu" aria-orientation="vertical" aria-labelledby="language-dropdown" tabindex="-1">
                  <li><a class="dropdown-item px-3" href="#">English</a></li>
                  <li><a class="dropdown-item dropdown-active px-3" href="#">Deutsch</a></li>
                  <li><a class="dropdown-item px-3" href="#">한국인</a></li>
                  <li><a class="dropdown-item px-3" href="#">Española</a></li>
                  <li><a class="dropdown-item px-3" href="#">Português</a></li>
                </ul>
              </div>

              <!-- Activity Dropdown -->
              <button type="button" class="btn btn-sm btn-text btn-square" aria-haspopup="dialog" aria-expanded="false" aria-controls="activity-drawer" data-overlay="#activity-drawer">
                <span class="icon-[tabler--activity] qmuz4"></span>
              </button>

              <!-- Notification Dropdown -->
              <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:24]">
                <button id="notification-dropdown" type="button" class="dropdown-toggle btn btn-text btn-square btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="hpjlt">
                    <span class="pykeo kn3q0 j6kj2 rounded-full"></span>
                    <span class="icon-[tabler--bell] qmuz4"></span>
                  </span>
                </button>
                <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full kzmwn adede px-3" role="menu" aria-orientation="vertical" aria-labelledby="notification-dropdown" tabindex="-1">
                  <div class="b6erz flex w-full items-center justify-between njdg2 mwpft">
                    <h6 class="text-base-content/50 text-sm vxiam">Notification</h6>
                    <span class="ijn5q bxh1m o1g2m pze98 rounded-full">8 New</span>
                  </div>
                  <div class="flex items-center justify-between">
                    <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                      <button type="button" class="vfeps active-tab:tab-active active font-medium" id="tabs-basic-item-1" data-tab="#tabs-basic-1" aria-controls="tabs-basic-1" role="tab" aria-selected="true">
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
                    <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1">
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

            <!-- Profile Dropdown -->
            <div class="dropdown relative inline-flex [--offset:21]">
              <button id="profile-dropdown" type="button" class="dropdown-toggle burs3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="User Avatar" class="rounded-box">
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1">
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
        </nav>
      </div>
    </div>

    <!-- Search Dropdown Content  -->
    <div id="search-modal" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 hidden" role="dialog" tabindex="-1">
      <div class="dthlq w-full zr8jv">
        <div class="pbhw6 j5lbz nwdq3">
          <!-- SearchBox -->
          <div class="m1ukj border-base-content/20 abnz9 px-3 py-2">
            <div class="ljn0d o22n0 pelb3 eghwv">
              <span class="icon-[tabler--search] text-base-content/80 q7z0e me-2 size-5 shrink-0"></span>
              <input type="search" class="sxihv" placeholder="Search here..." id="kbdInput">
              <label class="rui3g" for="kbdInput">Search</label>
            </div>
          </div>

          <nav class="hhn76 vt6q1 py-2" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
            <button type="button" class="vfeps active-tab:tab-active active w-full font-medium" id="search-tabs-item-1" data-tab="#search-tabs-1" aria-controls="search-tabs-1" role="tab" aria-selected="true">
              All
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-2" data-tab="#search-tabs-2" aria-controls="search-tabs-2" role="tab" aria-selected="false">
              Pages
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-3" data-tab="#search-tabs-3" aria-controls="search-tabs-3" role="tab" aria-selected="false">
              Integration
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-4" data-tab="#search-tabs-4" aria-controls="search-tabs-4" role="tab" aria-selected="false">
              Users
            </button>
          </nav>
          <!-- SearchBox Modal Body -->
          <div class="fpegk overflow-y-auto lg:max-h-121">
            <!-- SearchBox All Modal Body -->
            <div id="search-tabs-1" role="tabpanel" aria-labelledby="search-tabs-item-1">
              <!-- Pages Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Pages</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- Interaction Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Interaction</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- User Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">User</div>
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown1" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown1" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown2" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown2" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Pages Modal Body -->
            <div id="search-tabs-2" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-2">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Integration Modal Body -->
            <div id="search-tabs-3" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-3">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Users Modal Body -->
            <div id="search-tabs-4" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-4">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown3" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown3" tabindex="-1">
                            <li><button class="dropdown-item px-2">View More</button></li>
                            <li><button class="dropdown-item px-2">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown4" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown4" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>
          </div>
          <!-- Footer Commands -->
          <div class="w3jfd border-base-content/20 text-base-content/50 njdg2 ia8ws egd50 max-sm:hidden">
            <div class="flex sxihv items-center bglhu text-sm">
              <kbd class="b2fu4 an53u">esc</kbd>
              <span>To close</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-back] size-4"></span></kbd>
              <span>To Select</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-up] size-4"></span></kbd>
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-down] size-4"></span></kbd>
              <span>To Navigate</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Activity Drawer Content  -->
    <div id="activity-drawer" class="overlay overlay-open:translate-x-0 vxjzc jbh7e hidden sm:max-w-104" role="dialog" tabindex="-1">
      <div class="a5p6s border-base-content/20 w2qmy p-4">
        <h3 class="eul36 text-base t3mfo">Activity</h3>
        <button type="button" class="btn btn-text btn-circle geut3" aria-label="Close" data-overlay="#activity-drawer" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
      </div>
      <div class="rkt7z cbpaz">
        <ul class="if1r0">
          <!-- Joe Lincoln Activity -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">joe Lincoln</span>
                <span class="text-base-content text-sm">mentioned you in last trends topic</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 border j2be9 mwpft">
                <p class="text-base-content w3dp6 text-sm font-medium">
                  @Flyonui For an expert opinion, check out what Mike has to say on this topic!
                </p>
                <div class="ljn0d e1ers">
                  <input type="text" class="sxihv" placeholder="Reply" id="flyonuiReply">
                  <span class="icon-[tabler--photo] text-base-content/80 q7z0e ms-2 size-4 shrink-0"></span>
                </div>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Sofia -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Sofia">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Sofia</span>
                <span class="text-base-content text-sm">requested feedback on her design.</span>
              </div>
              <p class="text-base-content/50 text-sm">1 Hour ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Jane Perez File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jane Perez">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Jane Perez</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 s7x45 text-sm">3 Hours ago</p>
              <span class="ijn5q bxh1m vnwjt">
                <span class="icon-[tabler--file-type-pdf] text-error"></span>
                invoices.pdf
              </span>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Liam -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Liam">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Liam</span>
                <span class="text-base-content text-sm">has shared a project update.</span>
              </div>
              <p class="text-base-content/50 text-sm">5 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Tyler Hero Design Project -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="Tyler Hero">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Tyler Hero</span>
                <span class="text-base-content text-sm">wants to view your design project</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 flex items-center njdg2 border j2be9 mwpft">
                <div class="nfjpm rmjll">
                  <div class="bg-base-100 text-primary rounded-box size-8 f1870">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/figma-icon.png" alt="avatar">
                  </div>
                </div>
                <span class="text-sm font-medium">Launcher-UIkit.fig</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Denial Invite -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Denial">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Denial</span>
                <span class="text-base-content text-sm">Invite from invite link</span>
              </div>
              <p class="text-base-content/50 text-sm">3 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Leslie Alexander Tags -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Leslie Alexander">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Leslie Alexander</span>
                <span class="text-base-content text-sm">new tags to Web Redesign</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="flex dcvi3">
                <span class="ijn5q bxh1m pze98 o1g2m">Client - Request</span>
                <span class="ijn5q bxh1m ctq8s o1g2m">Figma</span>
                <span class="ijn5q bxh1m vn3pt o1g2m">Redesign</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Miya File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Miya">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Miya</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 text-sm">10 Hours ago</p>
            </div>
          </li>
        </ul>
      </div>
    </div>

    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 wjz3b e4bmm hidden n85ea [--auto-close:lg] sm:w-65 lg:z-50 lg:block lg:translate-x-0 lg:transition-none" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z border-base-content/20 n85ea jawf4 fbpri">
        <button type="button" class="btn btn-text btn-square geut3 absolute koirh s7loe sm:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
        <div class="border-base-content/20 rounded-box cy2ft n85ea border"></div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->

    <div class="flex sxihv jz3o6 lg:ps-65">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="wpaot w-full owca9 e6ynr sxihv fbpri">
        <div class="dpzny ip6vv sm:grid-cols-2">
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 hono0 w-full sm:col-span-2">
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
    <div class="bg-base-100 sticky top-0 at1sq flex lg:ps-75">
      <div class="wpaot w-full owca9">
        <nav class="hvzi2 justify-between njdg2">
          <div class="flex items-center bglhu">
            <button type="button" class="btn btn-soft btn-square btn-sm lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
              <span class="icon-[tabler--menu-2] qmuz4"></span>
            </button>

            <!-- Logo -->
            <div class="flex items-center sly4q">
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
              <h3 class="text-base-content bk5oo fl9z1 max-sm:hidden">FlyonUI</h3>
            </div>
          </div>

          <!-- Search -->
          <button type="button" class="flex items-center bglhu text-sm max-md:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="search-modal" data-overlay="#search-modal">
            <span class="icon-[tabler--search] text-base-content size-5"></span>
            <span class="text-base-content/50">Type to Search...</span>
          </button>

          <div class="flex items-center ip6vv">
            <div class="flex items-center">
              <!-- Search -->
              <button type="button" class="btn btn-text btn-sm btn-square md:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="search-modal" data-overlay="#search-modal">
                <span class="icon-[tabler--search] text-base-content qmuz4"></span>
              </button>

              <!-- Theme Dropdown  -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button id="dropdown-theme" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--sun] qmuz4"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-theme" tabindex="-1">
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Light" value="light">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Dark" value="dark">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="System" value="default">
                  </li>
                </ul>
              </div>

              <!-- Language Dropdown -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button id="language-dropdown" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--language] qmuz4"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 adede" role="menu" aria-orientation="vertical" aria-labelledby="language-dropdown" tabindex="-1">
                  <li><a class="dropdown-item px-3" href="#">English</a></li>
                  <li><a class="dropdown-item dropdown-active px-3" href="#">Deutsch</a></li>
                  <li><a class="dropdown-item px-3" href="#">한국인</a></li>
                  <li><a class="dropdown-item px-3" href="#">Española</a></li>
                  <li><a class="dropdown-item px-3" href="#">Português</a></li>
                </ul>
              </div>

              <!-- Activity Dropdown -->
              <button type="button" class="btn btn-sm btn-text btn-square" aria-haspopup="dialog" aria-expanded="false" aria-controls="activity-drawer" data-overlay="#activity-drawer">
                <span class="icon-[tabler--activity] qmuz4"></span>
              </button>

              <!-- Notification Dropdown -->
              <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:24]">
                <button id="notification-dropdown" type="button" class="dropdown-toggle btn btn-text btn-square btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="hpjlt">
                    <span class="pykeo kn3q0 j6kj2 rounded-full"></span>
                    <span class="icon-[tabler--bell] qmuz4"></span>
                  </span>
                </button>
                <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full kzmwn adede px-3" role="menu" aria-orientation="vertical" aria-labelledby="notification-dropdown" tabindex="-1">
                  <div class="b6erz flex w-full items-center justify-between njdg2 mwpft">
                    <h6 class="text-base-content/50 text-sm vxiam">Notification</h6>
                    <span class="ijn5q bxh1m o1g2m pze98 rounded-full">8 New</span>
                  </div>
                  <div class="flex items-center justify-between">
                    <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                      <button type="button" class="vfeps active-tab:tab-active active font-medium" id="tabs-basic-item-1" data-tab="#tabs-basic-1" aria-controls="tabs-basic-1" role="tab" aria-selected="true">
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
                    <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1">
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

            <!-- Profile Dropdown -->
            <div class="dropdown relative inline-flex [--offset:21]">
              <button id="profile-dropdown" type="button" class="dropdown-toggle flex items-center sly4q" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="nfjpm">
                  <span class="rounded-field lt1t7">
                    <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="User Avatar">
                  </span>
                </span>
                <span class="flex jz3o6 qojvm max-sm:hidden">
                  <span class="text-base-content t3mfo whitespace-nowrap">Charlotte Anne</span>
                  <span class="text-base-content/50 text-sm">Influencer</span>
                </span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1">
                <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
                  <div class="nfjpm a3rpr">
                    <div class="kqy8v rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="avatar">
                    </div>
                  </div>
                  <div>
                    <h6 class="text-base-content mb-0.5 t3mfo">Charlotte Anne</h6>
                    <p class="text-base-content/80 font-medium">Influencer</p>
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
        </nav>
      </div>
    </div>

    <!-- Search Dropdown Content  -->
    <div id="search-modal" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 hidden" role="dialog" tabindex="-1">
      <div class="dthlq w-full zr8jv">
        <div class="pbhw6 j5lbz nwdq3">
          <!-- SearchBox -->
          <div class="m1ukj border-base-content/20 abnz9 px-3 py-2">
            <div class="ljn0d o22n0 pelb3 eghwv">
              <span class="icon-[tabler--search] text-base-content/80 q7z0e me-2 size-5 shrink-0"></span>
              <input type="search" class="sxihv" placeholder="Search here..." id="kbdInput">
              <label class="rui3g" for="kbdInput">Search</label>
            </div>
          </div>

          <nav class="hhn76 vt6q1 py-2" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
            <button type="button" class="vfeps active-tab:tab-active active w-full font-medium" id="search-tabs-item-1" data-tab="#search-tabs-1" aria-controls="search-tabs-1" role="tab" aria-selected="true">
              All
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-2" data-tab="#search-tabs-2" aria-controls="search-tabs-2" role="tab" aria-selected="false">
              Pages
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-3" data-tab="#search-tabs-3" aria-controls="search-tabs-3" role="tab" aria-selected="false">
              Integration
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-4" data-tab="#search-tabs-4" aria-controls="search-tabs-4" role="tab" aria-selected="false">
              Users
            </button>
          </nav>
          <!-- SearchBox Modal Body -->
          <div class="fpegk overflow-y-auto lg:max-h-121">
            <!-- SearchBox All Modal Body -->
            <div id="search-tabs-1" role="tabpanel" aria-labelledby="search-tabs-item-1">
              <!-- Pages Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Pages</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- Interaction Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Interaction</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- User Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">User</div>
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown1" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown1" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown2" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown2" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Pages Modal Body -->
            <div id="search-tabs-2" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-2">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Integration Modal Body -->
            <div id="search-tabs-3" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-3">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Users Modal Body -->
            <div id="search-tabs-4" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-4">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown3" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown3" tabindex="-1">
                            <li><button class="dropdown-item px-2">View More</button></li>
                            <li><button class="dropdown-item px-2">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown4" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown4" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>
          </div>
          <!-- Footer Commands -->
          <div class="w3jfd border-base-content/20 text-base-content/50 njdg2 ia8ws egd50 max-sm:hidden">
            <div class="flex sxihv items-center bglhu text-sm">
              <kbd class="b2fu4 an53u">esc</kbd>
              <span>To close</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-back] size-4"></span></kbd>
              <span>To Select</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-up] size-4"></span></kbd>
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-down] size-4"></span></kbd>
              <span>To Navigate</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Activity Drawer Content  -->
    <div id="activity-drawer" class="overlay overlay-open:translate-x-0 vxjzc jbh7e hidden sm:max-w-104" role="dialog" tabindex="-1">
      <div class="a5p6s border-base-content/20 w2qmy p-4">
        <h3 class="eul36 text-base t3mfo">Activity</h3>
        <button type="button" class="btn btn-text btn-circle geut3" aria-label="Close" data-overlay="#activity-drawer" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
      </div>
      <div class="rkt7z cbpaz">
        <ul class="if1r0">
          <!-- Joe Lincoln Activity -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">joe Lincoln</span>
                <span class="text-base-content text-sm">mentioned you in last trends topic</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 border j2be9 mwpft">
                <p class="text-base-content w3dp6 text-sm font-medium">
                  @Flyonui For an expert opinion, check out what Mike has to say on this topic!
                </p>
                <div class="ljn0d e1ers">
                  <input type="text" class="sxihv" placeholder="Reply" id="flyonuiReply">
                  <span class="icon-[tabler--photo] text-base-content/80 q7z0e ms-2 size-4 shrink-0"></span>
                </div>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Sofia -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Sofia">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Sofia</span>
                <span class="text-base-content text-sm">requested feedback on her design.</span>
              </div>
              <p class="text-base-content/50 text-sm">1 Hour ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Jane Perez File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jane Perez">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Jane Perez</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 s7x45 text-sm">3 Hours ago</p>
              <span class="ijn5q bxh1m vnwjt">
                <span class="icon-[tabler--file-type-pdf] text-error"></span>
                invoices.pdf
              </span>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Liam -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Liam">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Liam</span>
                <span class="text-base-content text-sm">has shared a project update.</span>
              </div>
              <p class="text-base-content/50 text-sm">5 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Tyler Hero Design Project -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="Tyler Hero">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Tyler Hero</span>
                <span class="text-base-content text-sm">wants to view your design project</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 flex items-center njdg2 border j2be9 mwpft">
                <div class="nfjpm rmjll">
                  <div class="bg-base-100 text-primary rounded-box size-8 f1870">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/figma-icon.png" alt="avatar">
                  </div>
                </div>
                <span class="text-sm font-medium">Launcher-UIkit.fig</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Denial Invite -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Denial">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Denial</span>
                <span class="text-base-content text-sm">Invite from invite link</span>
              </div>
              <p class="text-base-content/50 text-sm">3 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Leslie Alexander Tags -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Leslie Alexander">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Leslie Alexander</span>
                <span class="text-base-content text-sm">new tags to Web Redesign</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="flex dcvi3">
                <span class="ijn5q bxh1m pze98 o1g2m">Client - Request</span>
                <span class="ijn5q bxh1m ctq8s o1g2m">Figma</span>
                <span class="ijn5q bxh1m vn3pt o1g2m">Redesign</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Miya File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Miya">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Miya</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 text-sm">10 Hours ago</p>
            </div>
          </li>
        </ul>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 wjz3b e4bmm hidden n85ea [--auto-close:lg] sm:w-75 lg:z-50 lg:block lg:translate-x-0 lg:shadow-none" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z border-base-content/20 n85ea jawf4 fbpri">
        <button type="button" class="btn btn-text btn-square geut3 absolute koirh s7loe sm:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
        <div class="border-base-content/20 rounded-box cy2ft n85ea border"></div>
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
        <nav class="hvzi2 justify-between njdg2">
          <div class="flex items-center bglhu">
            <button type="button" class="btn btn-soft btn-square btn-sm lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
              <span class="icon-[tabler--menu-2] qmuz4"></span>
            </button>

            <!-- Logo -->
            <div class="flex jz3o6 max-[550px]:hidden">
              <h3 class="text-base-content c9rvi t3mfo">Hello John!</h3>
              <p class="text-base-content/50 text-sm">Welcome back to dashboard</p>
            </div>
          </div>

          <!-- Search -->
          <button type="button" class="rounded-field border-base-content/40 flex io745 r2qpi items-center bglhu border ee2rm text-sm max-md:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="search-modal" data-overlay="#search-modal">
            <span class="icon-[tabler--search] text-base-content size-4"></span>
            <span class="text-base-content/50">Search Clients</span>
          </button>

          <div class="flex items-center ip6vv">
            <div class="flex items-center">
              <!-- Search Btn For Small Screen  -->
              <button type="button" class="btn btn-text btn-sm btn-square md:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="search-modal" data-overlay="#search-modal">
                <span class="icon-[tabler--search] text-base-content qmuz4"></span>
              </button>

              <!-- Theme Dropdown  -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button id="dropdown-theme" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--sun] qmuz4"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-theme" tabindex="-1">
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Light" value="light">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Dark" value="dark">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="System" value="default">
                  </li>
                </ul>
              </div>

              <!-- Language Dropdown -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button id="language-dropdown" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--language] qmuz4"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 adede" role="menu" aria-orientation="vertical" aria-labelledby="language-dropdown" tabindex="-1">
                  <li><a class="dropdown-item px-3" href="#">English</a></li>
                  <li><a class="dropdown-item dropdown-active px-3" href="#">Deutsch</a></li>
                  <li><a class="dropdown-item px-3" href="#">한국인</a></li>
                  <li><a class="dropdown-item px-3" href="#">Española</a></li>
                  <li><a class="dropdown-item px-3" href="#">Português</a></li>
                </ul>
              </div>

              <!-- Activity Dropdown -->
              <button type="button" class="btn btn-sm btn-text btn-square" aria-haspopup="dialog" aria-expanded="false" aria-controls="activity-drawer" data-overlay="#activity-drawer">
                <span class="icon-[tabler--activity] qmuz4"></span>
              </button>

              <!-- Notification Dropdown -->
              <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:24]">
                <button id="notification-dropdown" type="button" class="dropdown-toggle btn btn-text btn-square btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="hpjlt">
                    <span class="pykeo kn3q0 j6kj2 rounded-full"></span>
                    <span class="icon-[tabler--bell] qmuz4"></span>
                  </span>
                </button>
                <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full kzmwn adede px-3" role="menu" aria-orientation="vertical" aria-labelledby="notification-dropdown" tabindex="-1">
                  <div class="b6erz flex w-full items-center justify-between njdg2 mwpft">
                    <h6 class="text-base-content/50 text-sm vxiam">Notification</h6>
                    <span class="ijn5q bxh1m o1g2m pze98 rounded-full">8 New</span>
                  </div>
                  <div class="flex items-center justify-between">
                    <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                      <button type="button" class="vfeps active-tab:tab-active active font-medium" id="tabs-basic-item-1" data-tab="#tabs-basic-1" aria-controls="tabs-basic-1" role="tab" aria-selected="true">
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
                    <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1">
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

            <!-- Profile Dropdown -->
            <div class="dropdown relative inline-flex [--offset:21]">
              <button id="profile-dropdown" type="button" class="dropdown-toggle burs3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="User Avatar" class="rounded-box">
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1">
                <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
                  <div class="nfjpm a3rpr">
                    <div class="kqy8v rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="avatar">
                    </div>
                  </div>
                  <div>
                    <h6 class="text-base-content mb-0.5 t3mfo">Charlotte Anne</h6>
                    <p class="text-base-content/80 font-medium">Influencer</p>
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
        </nav>
      </div>
    </div>

    <!-- Search Dropdown Content  -->
    <div id="search-modal" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 hidden" role="dialog" tabindex="-1">
      <div class="dthlq w-full zr8jv">
        <div class="pbhw6 j5lbz nwdq3">
          <!-- SearchBox -->
          <div class="m1ukj border-base-content/20 abnz9 px-3 py-2">
            <div class="ljn0d o22n0 pelb3 eghwv">
              <span class="icon-[tabler--search] text-base-content/80 q7z0e me-2 size-5 shrink-0"></span>
              <input type="search" class="sxihv" placeholder="Search here..." id="kbdInput">
              <label class="rui3g" for="kbdInput">Search</label>
            </div>
          </div>

          <nav class="hhn76 vt6q1 py-2" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
            <button type="button" class="vfeps active-tab:tab-active active w-full font-medium" id="search-tabs-item-1" data-tab="#search-tabs-1" aria-controls="search-tabs-1" role="tab" aria-selected="true">
              All
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-2" data-tab="#search-tabs-2" aria-controls="search-tabs-2" role="tab" aria-selected="false">
              Pages
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-3" data-tab="#search-tabs-3" aria-controls="search-tabs-3" role="tab" aria-selected="false">
              Integration
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-4" data-tab="#search-tabs-4" aria-controls="search-tabs-4" role="tab" aria-selected="false">
              Users
            </button>
          </nav>
          <!-- SearchBox Modal Body -->
          <div class="fpegk overflow-y-auto lg:max-h-121">
            <!-- SearchBox All Modal Body -->
            <div id="search-tabs-1" role="tabpanel" aria-labelledby="search-tabs-item-1">
              <!-- Pages Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Pages</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- Interaction Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Interaction</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- User Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">User</div>
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown1" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown1" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown2" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown2" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Pages Modal Body -->
            <div id="search-tabs-2" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-2">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Integration Modal Body -->
            <div id="search-tabs-3" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-3">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Users Modal Body -->
            <div id="search-tabs-4" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-4">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown3" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown3" tabindex="-1">
                            <li><button class="dropdown-item px-2">View More</button></li>
                            <li><button class="dropdown-item px-2">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown4" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown4" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>
          </div>
          <!-- Footer Commands -->
          <div class="w3jfd border-base-content/20 text-base-content/50 njdg2 ia8ws egd50 max-sm:hidden">
            <div class="flex sxihv items-center bglhu text-sm">
              <kbd class="b2fu4 an53u">esc</kbd>
              <span>To close</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-back] size-4"></span></kbd>
              <span>To Select</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-up] size-4"></span></kbd>
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-down] size-4"></span></kbd>
              <span>To Navigate</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Activity Drawer Content  -->
    <div id="activity-drawer" class="overlay overlay-open:translate-x-0 vxjzc jbh7e hidden sm:max-w-104" role="dialog" tabindex="-1">
      <div class="a5p6s border-base-content/20 w2qmy p-4">
        <h3 class="eul36 text-base t3mfo">Activity</h3>
        <button type="button" class="btn btn-text btn-circle geut3" aria-label="Close" data-overlay="#activity-drawer" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
      </div>
      <div class="rkt7z cbpaz">
        <ul class="if1r0">
          <!-- Joe Lincoln Activity -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">joe Lincoln</span>
                <span class="text-base-content text-sm">mentioned you in last trends topic</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 border j2be9 mwpft">
                <p class="text-base-content w3dp6 text-sm font-medium">
                  @Flyonui For an expert opinion, check out what Mike has to say on this topic!
                </p>
                <div class="ljn0d e1ers">
                  <input type="text" class="sxihv" placeholder="Reply" id="flyonuiReply">
                  <span class="icon-[tabler--photo] text-base-content/80 q7z0e ms-2 size-4 shrink-0"></span>
                </div>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Sofia -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Sofia">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Sofia</span>
                <span class="text-base-content text-sm">requested feedback on her design.</span>
              </div>
              <p class="text-base-content/50 text-sm">1 Hour ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Jane Perez File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jane Perez">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Jane Perez</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 s7x45 text-sm">3 Hours ago</p>
              <span class="ijn5q bxh1m vnwjt">
                <span class="icon-[tabler--file-type-pdf] text-error"></span>
                invoices.pdf
              </span>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Liam -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Liam">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Liam</span>
                <span class="text-base-content text-sm">has shared a project update.</span>
              </div>
              <p class="text-base-content/50 text-sm">5 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Tyler Hero Design Project -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="Tyler Hero">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Tyler Hero</span>
                <span class="text-base-content text-sm">wants to view your design project</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 flex items-center njdg2 border j2be9 mwpft">
                <div class="nfjpm rmjll">
                  <div class="bg-base-100 text-primary rounded-box size-8 f1870">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/figma-icon.png" alt="avatar">
                  </div>
                </div>
                <span class="text-sm font-medium">Launcher-UIkit.fig</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Denial Invite -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Denial">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Denial</span>
                <span class="text-base-content text-sm">Invite from invite link</span>
              </div>
              <p class="text-base-content/50 text-sm">3 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Leslie Alexander Tags -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Leslie Alexander">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Leslie Alexander</span>
                <span class="text-base-content text-sm">new tags to Web Redesign</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="flex dcvi3">
                <span class="ijn5q bxh1m pze98 o1g2m">Client - Request</span>
                <span class="ijn5q bxh1m ctq8s o1g2m">Figma</span>
                <span class="ijn5q bxh1m vn3pt o1g2m">Redesign</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Miya File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Miya">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Miya</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 text-sm">10 Hours ago</p>
            </div>
          </li>
        </ul>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 wjz3b e4bmm hidden n85ea [--auto-close:lg] sm:w-75 lg:z-50 lg:block lg:translate-x-0 lg:shadow-none" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z border-base-content/20 n85ea jawf4 fbpri">
        <button type="button" class="btn btn-text btn-square geut3 absolute koirh s7loe sm:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
        <div class="border-base-content/20 rounded-box cy2ft n85ea border"></div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->
    <div class="flex sxihv jz3o6 lg:ps-75">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="wpaot w-full owca9 e6ynr fbpri">
        <div class="dpzny ip6vv sm:grid-cols-2">
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
      <div class="wpaot w-full">
        <nav class="hvzi2 justify-between njdg2">
          <div class="szonh bglhu">
            <button type="button" class="btn btn-soft btn-square btn-sm lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
              <span class="icon-[tabler--menu-2] qmuz4"></span>
            </button>

            <!-- Quick Links  -->
            <div class="flex x1pg6 max-lg:hidden">
              <a href="#" class="mnco6 kwr8s ejsm2 before:-bottom-1.5 before:h-0.5">Home</a>
              <a href="#" class="mnco6 kwr8s o85nv ejsm2 before:-bottom-1.5 before:h-0.5">
                Products
              </a>
              <a href="#" class="mnco6 kwr8s ejsm2 before:-bottom-1.5 before:h-0.5">About Us</a>
              <a href="#" class="mnco6 kwr8s ejsm2 before:-bottom-1.5 before:h-0.5">Pricing</a>
            </div>
          </div>

          <div class="ktglt ip6vv lg:max-xl:gap-3">
            <div class="flex items-center sly4q">
              <!-- Theme Dropdown  -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button id="dropdown-theme" type="button" class="dropdown-toggle btn btn-square g2v48 border-base-content/20" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--sun] girx5"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-theme" tabindex="-1">
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Light" value="light">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Dark" value="dark">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="System" value="default">
                  </li>
                </ul>
              </div>

              <!-- Language Dropdown -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button id="language-dropdown" type="button" class="dropdown-toggle btn btn-square g2v48 border-base-content/20" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--language] girx5"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 adede" role="menu" aria-orientation="vertical" aria-labelledby="language-dropdown" tabindex="-1">
                  <li><a class="dropdown-item px-3" href="#">English</a></li>
                  <li><a class="dropdown-item dropdown-active px-3" href="#">Deutsch</a></li>
                  <li><a class="dropdown-item px-3" href="#">한국인</a></li>
                  <li><a class="dropdown-item px-3" href="#">Española</a></li>
                  <li><a class="dropdown-item px-3" href="#">Português</a></li>
                </ul>
              </div>

              <!-- Activity Dropdown -->
              <button type="button" class="btn btn-square g2v48 border-base-content/20" aria-haspopup="dialog" aria-expanded="false" aria-controls="activity-drawer" data-overlay="#activity-drawer">
                <span class="icon-[tabler--activity] girx5"></span>
              </button>

              <!-- Notification Dropdown -->
              <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:24]">
                <button id="notification-dropdown" type="button" class="dropdown-toggle hpjlt" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="pykeo kn3q0 j6kj2 rounded-full"></span>
                  <span class="btn g2v48 btn-square border-base-content/20">
                    <span class="icon-[tabler--bell] girx5"></span>
                  </span>
                </button>
                <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full kzmwn adede px-3" role="menu" aria-orientation="vertical" aria-labelledby="notification-dropdown" tabindex="-1">
                  <div class="b6erz flex w-full items-center justify-between njdg2 mwpft">
                    <h6 class="text-base-content/50 text-sm vxiam">Notification</h6>
                    <span class="ijn5q bxh1m o1g2m pze98 rounded-full">8 New</span>
                  </div>
                  <div class="flex items-center justify-between">
                    <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                      <button type="button" class="vfeps active-tab:tab-active active font-medium" id="tabs-basic-item-1" data-tab="#tabs-basic-1" aria-controls="tabs-basic-1" role="tab" aria-selected="true">
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
                    <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1">
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

            <!-- Profile Dropdown -->
            <div class="dropdown relative inline-flex [--offset:21]">
              <button id="profile-dropdown" type="button" class="dropdown-toggle flex items-center sly4q" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="nfjpm">
                  <span class="rounded-field lt1t7">
                    <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="User Avatar">
                  </span>
                </span>
                <span class="flex jz3o6 qojvm max-sm:hidden">
                  <span class="text-base-content t3mfo whitespace-nowrap">Charlotte Anne</span>
                  <span class="text-base-content/50 text-sm">Influencer</span>
                </span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1">
                <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
                  <div class="nfjpm a3rpr">
                    <div class="kqy8v rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="avatar">
                    </div>
                  </div>
                  <div>
                    <h6 class="text-base-content mb-0.5 t3mfo">Charlotte Anne</h6>
                    <p class="text-base-content/80 font-medium">Influencer</p>
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
        </nav>
      </div>
    </div>

    <!-- Activity Drawer Content  -->
    <div id="activity-drawer" class="overlay overlay-open:translate-x-0 vxjzc jbh7e hidden sm:max-w-104" role="dialog" tabindex="-1">
      <div class="a5p6s border-base-content/20 w2qmy p-4">
        <h3 class="eul36 text-base t3mfo">Activity</h3>
        <button type="button" class="btn btn-text btn-circle geut3" aria-label="Close" data-overlay="#activity-drawer" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
      </div>
      <div class="rkt7z cbpaz">
        <ul class="if1r0">
          <!-- Joe Lincoln Activity -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">joe Lincoln</span>
                <span class="text-base-content text-sm">mentioned you in last trends topic</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 border j2be9 mwpft">
                <p class="text-base-content w3dp6 text-sm font-medium">
                  @Flyonui For an expert opinion, check out what Mike has to say on this topic!
                </p>
                <div class="ljn0d e1ers">
                  <input type="text" class="sxihv" placeholder="Reply" id="flyonuiReply">
                  <span class="icon-[tabler--photo] text-base-content/80 q7z0e ms-2 size-4 shrink-0"></span>
                </div>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Sofia -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Sofia">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Sofia</span>
                <span class="text-base-content text-sm">requested feedback on her design.</span>
              </div>
              <p class="text-base-content/50 text-sm">1 Hour ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Jane Perez File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jane Perez">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Jane Perez</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 s7x45 text-sm">3 Hours ago</p>
              <span class="ijn5q bxh1m vnwjt">
                <span class="icon-[tabler--file-type-pdf] text-error"></span>
                invoices.pdf
              </span>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Liam -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Liam">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Liam</span>
                <span class="text-base-content text-sm">has shared a project update.</span>
              </div>
              <p class="text-base-content/50 text-sm">5 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Tyler Hero Design Project -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="Tyler Hero">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Tyler Hero</span>
                <span class="text-base-content text-sm">wants to view your design project</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 flex items-center njdg2 border j2be9 mwpft">
                <div class="nfjpm rmjll">
                  <div class="bg-base-100 text-primary rounded-box size-8 f1870">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/figma-icon.png" alt="avatar">
                  </div>
                </div>
                <span class="text-sm font-medium">Launcher-UIkit.fig</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Denial Invite -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Denial">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Denial</span>
                <span class="text-base-content text-sm">Invite from invite link</span>
              </div>
              <p class="text-base-content/50 text-sm">3 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Leslie Alexander Tags -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Leslie Alexander">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Leslie Alexander</span>
                <span class="text-base-content text-sm">new tags to Web Redesign</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="flex dcvi3">
                <span class="ijn5q bxh1m pze98 o1g2m">Client - Request</span>
                <span class="ijn5q bxh1m ctq8s o1g2m">Figma</span>
                <span class="ijn5q bxh1m vn3pt o1g2m">Redesign</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Miya File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Miya">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Miya</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 text-sm">10 Hours ago</p>
            </div>
          </li>
        </ul>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 wjz3b e4bmm hidden n85ea [--auto-close:lg] sm:w-75 lg:z-50 lg:block lg:translate-x-0 lg:shadow-none" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z border-base-content/20 n85ea jawf4 fbpri">
        <button type="button" class="btn btn-text btn-square geut3 absolute koirh s7loe sm:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
        <div class="border-base-content/20 rounded-box cy2ft n85ea border"></div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->

    <div class="flex sxihv jz3o6 justify-between lg:ps-75">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="e6ynr fbpri">
        <div class="dpzny ip6vv">
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
    <div class="bg-base-100 d50ic sticky top-0 r1xta zw50f">
      <div class="c33d9">
        <nav class="hvzi2 wpaot qzwp2 owca9 justify-between m233p">
          <div class="flex items-center bglhu">
            <button type="button" class="collapse-toggle btn btn-soft btn-square btn-sm lg:hidden" id="navbar-collapse" aria-expanded="false" aria-controls="navbar-collapse-heading" data-collapse="#navbar-collapse-heading">
              <span class="icon-[tabler--menu-2] qmuz4"></span>
            </button>
            <!-- Logo -->
            <div class="flex items-center sly4q">
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
              <h3 class="bk5oo t3mfo lmn89 max-sm:hidden">Job Management</h3>
            </div>
          </div>

          <!-- Search -->
          <button type="button" class="rounded-field flex io745 fyijd items-center rsqkx border qu24g f6hal px-3 text-sm max-lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="search-modal" data-overlay="#search-modal">
            <span class="icon-[tabler--user] size-4 lmn89"></span>
            <span class="lmn89">Search</span>
          </button>

          <div class="flex items-center ip6vv">
            <div class="flex items-center">
              <!-- Search Btn For Small Screen  -->
              <button type="button" class="btn btn-text btn-sm btn-square [--btn-color:#fff] lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="search-modal" data-overlay="#search-modal">
                <span class="icon-[tabler--search] qmuz4"></span>
              </button>

              <!-- Theme Dropdown  -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button id="dropdown-theme" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text [--btn-color:#fff]" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--sun] qmuz4"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-theme" tabindex="-1">
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Light" value="light">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Dark" value="dark">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="System" value="default">
                  </li>
                </ul>
              </div>

              <!-- Language Dropdown -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button id="language-dropdown" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text [--btn-color:#fff]" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--language] qmuz4"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 adede" role="menu" aria-orientation="vertical" aria-labelledby="language-dropdown" tabindex="-1">
                  <li><a class="dropdown-item px-3" href="#">English</a></li>
                  <li><a class="dropdown-item dropdown-active px-3" href="#">Deutsch</a></li>
                  <li><a class="dropdown-item px-3" href="#">한국인</a></li>
                  <li><a class="dropdown-item px-3" href="#">Española</a></li>
                  <li><a class="dropdown-item px-3" href="#">Português</a></li>
                </ul>
              </div>

              <!-- Activity Dropdown -->
              <button type="button" class="btn btn-sm btn-text btn-square [--btn-color:#fff]" aria-haspopup="dialog" aria-expanded="false" aria-controls="activity-drawer" data-overlay="#activity-drawer">
                <span class="icon-[tabler--activity] qmuz4"></span>
              </button>

              <!-- Notification Dropdown -->
              <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:24]">
                <button id="notification-dropdown" type="button" class="dropdown-toggle btn btn-text btn-square btn-sm [--btn-color:#fff]" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="hpjlt">
                    <span class="pykeo kn3q0 j6kj2 rounded-full"></span>
                    <span class="icon-[tabler--bell] qmuz4"></span>
                  </span>
                </button>
                <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full kzmwn adede px-3" role="menu" aria-orientation="vertical" aria-labelledby="notification-dropdown" tabindex="-1">
                  <div class="b6erz flex w-full items-center justify-between njdg2 mwpft">
                    <h6 class="text-base-content/50 text-sm vxiam">Notification</h6>
                    <span class="ijn5q bxh1m o1g2m pze98 rounded-full">8 New</span>
                  </div>
                  <div class="flex items-center justify-between">
                    <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                      <button type="button" class="vfeps active-tab:tab-active active font-medium" id="tabs-basic-item-1" data-tab="#tabs-basic-1" aria-controls="tabs-basic-1" role="tab" aria-selected="true">
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
                    <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1">
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

            <!-- Profile Dropdown -->
            <div class="dropdown relative inline-flex [--offset:21]">
              <button id="profile-dropdown" type="button" class="dropdown-toggle burs3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="User Avatar" class="rounded-box">
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1">
                <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
                  <div class="nfjpm a3rpr">
                    <div class="kqy8v rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                    </div>
                  </div>
                  <div>
                    <h6 class="text-base-content mb-0.5 t3mfo">Charlotte Anne</h6>
                    <p class="text-base-content/80 font-medium">Influencer</p>
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
        </nav>
      </div>

      <nav class="hvzi2 wpaot qzwp2 owca9 justify-between max-lg:p-0">
        <div class="collapse hidden w-full overflow-hidden transition-[height] duration-300 max-lg:px-6 lg:block" id="navbar-collapse-heading" aria-labelledby="navbar-collapse">
          <div class="flex w-full justify-between ikjxw max-lg:flex-col max-lg:py-2.5 lg:items-center">
            <ul class="x737x v85mw lg:menu-horizontal rsqkx cbpaz">
              <!--  Job List -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-job-list" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 px-2" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--list-numbers] qmuz4"></span>
                  Job List
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 qmuz4 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-job-list" tabindex="-1">
                  <li>
                    <a class="dropdown-item oeogr" href="#">All Jobs</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Active Jobs</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Completed Jobs</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Archived Jobs</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Job Categories</a>
                  </li>
                </ul>
              </li>

              <!-- Create Job -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-create-job" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 px-2" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--file-plus] qmuz4"></span>
                  Create Job
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 qmuz4 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-create-job" tabindex="-1">
                  <li>
                    <a class="dropdown-item" href="#">New Job</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Job Template</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Schedule Job</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Assign to Team</a>
                  </li>
                </ul>
              </li>

              <!-- Task Management -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-task" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 px-2" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--checkbox] qmuz4"></span>
                  Task Management
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 qmuz4 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-task" tabindex="-1">
                  <li>
                    <a class="dropdown-item" href="#">Task Board</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Task Calendar</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">My Tasks</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Assigned Tasks</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Recurring Tasks</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Task Priorities</a>
                  </li>
                </ul>
              </li>

              <!-- Client -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-client" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 px-2" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--users] qmuz4"></span>
                  Client
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 qmuz4 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-client" tabindex="-1">
                  <li>
                    <a class="dropdown-item" href="#">All Clients</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Add New Client</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Client Groups</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Client Contacts</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Client Feedback</a>
                  </li>
                </ul>
              </li>

              <!-- Settings -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--settings] qmuz4"></span>
                  Settings
                </a>
              </li>

              <!-- Billing & Invoicing -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--currency-dollar] qmuz4"></span>
                  Billing &amp; Invoicing
                </a>
              </li>
            </ul>
            <div class="shrink-0">
              <a href="#" class="btn btn-sm btn-primary max-md:btn-block">Apply Now</a>
            </div>
          </div>
        </div>
      </nav>
    </div>

    <!-- Search Dropdown Content  -->
    <div id="search-modal" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 hidden" role="dialog" tabindex="-1">
      <div class="dthlq w-full zr8jv">
        <div class="pbhw6 j5lbz nwdq3">
          <!-- SearchBox -->
          <div class="m1ukj border-base-content/20 abnz9 px-3 py-2">
            <div class="ljn0d o22n0 pelb3 eghwv">
              <span class="icon-[tabler--search] text-base-content/80 q7z0e me-2 size-5 shrink-0"></span>
              <input type="search" class="sxihv" placeholder="Search here..." id="kbdInput">
              <label class="rui3g" for="kbdInput">Search</label>
            </div>
          </div>

          <nav class="hhn76 vt6q1 py-2" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
            <button type="button" class="vfeps active-tab:tab-active active w-full font-medium" id="search-tabs-item-1" data-tab="#search-tabs-1" aria-controls="search-tabs-1" role="tab" aria-selected="true">
              All
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-2" data-tab="#search-tabs-2" aria-controls="search-tabs-2" role="tab" aria-selected="false">
              Pages
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-3" data-tab="#search-tabs-3" aria-controls="search-tabs-3" role="tab" aria-selected="false">
              Integration
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-4" data-tab="#search-tabs-4" aria-controls="search-tabs-4" role="tab" aria-selected="false">
              Users
            </button>
          </nav>
          <!-- SearchBox Modal Body -->
          <div class="fpegk overflow-y-auto lg:max-h-121">
            <!-- SearchBox All Modal Body -->
            <div id="search-tabs-1" role="tabpanel" aria-labelledby="search-tabs-item-1">
              <!-- Pages Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Pages</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- Interaction Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Interaction</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- User Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">User</div>
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown1" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown1" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown2" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown2" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Pages Modal Body -->
            <div id="search-tabs-2" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-2">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Integration Modal Body -->
            <div id="search-tabs-3" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-3">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Users Modal Body -->
            <div id="search-tabs-4" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-4">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown3" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown3" tabindex="-1">
                            <li><button class="dropdown-item px-2">View More</button></li>
                            <li><button class="dropdown-item px-2">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown4" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown4" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>
          </div>
          <!-- Footer Commands -->
          <div class="w3jfd border-base-content/20 text-base-content/50 njdg2 ia8ws egd50 max-sm:hidden">
            <div class="flex sxihv items-center bglhu text-sm">
              <kbd class="b2fu4 an53u">esc</kbd>
              <span>To close</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-back] size-4"></span></kbd>
              <span>To Select</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-up] size-4"></span></kbd>
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-down] size-4"></span></kbd>
              <span>To Navigate</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Activity Drawer Content  -->
    <div id="activity-drawer" class="overlay overlay-open:translate-x-0 vxjzc jbh7e hidden sm:max-w-104" role="dialog" tabindex="-1">
      <div class="a5p6s border-base-content/20 w2qmy p-4">
        <h3 class="eul36 text-base t3mfo">Activity</h3>
        <button type="button" class="btn btn-text btn-circle geut3" aria-label="Close" data-overlay="#activity-drawer" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
      </div>
      <div class="rkt7z cbpaz">
        <ul class="if1r0">
          <!-- Joe Lincoln Activity -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">joe Lincoln</span>
                <span class="text-base-content text-sm">mentioned you in last trends topic</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 border j2be9 mwpft">
                <p class="text-base-content w3dp6 text-sm font-medium">
                  @Flyonui For an expert opinion, check out what Mike has to say on this topic!
                </p>
                <div class="ljn0d e1ers">
                  <input type="text" class="sxihv" placeholder="Reply" id="flyonuiReply">
                  <span class="icon-[tabler--photo] text-base-content/80 q7z0e ms-2 size-4 shrink-0"></span>
                </div>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Sofia -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Sofia">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Sofia</span>
                <span class="text-base-content text-sm">requested feedback on her design.</span>
              </div>
              <p class="text-base-content/50 text-sm">1 Hour ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Jane Perez File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jane Perez">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Jane Perez</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 s7x45 text-sm">3 Hours ago</p>
              <span class="ijn5q bxh1m vnwjt">
                <span class="icon-[tabler--file-type-pdf] text-error"></span>
                invoices.pdf
              </span>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Liam -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Liam">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Liam</span>
                <span class="text-base-content text-sm">has shared a project update.</span>
              </div>
              <p class="text-base-content/50 text-sm">5 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Tyler Hero Design Project -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="Tyler Hero">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Tyler Hero</span>
                <span class="text-base-content text-sm">wants to view your design project</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 flex items-center njdg2 border j2be9 mwpft">
                <div class="nfjpm rmjll">
                  <div class="bg-base-100 text-primary rounded-box size-8 f1870">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/figma-icon.png" alt="avatar">
                  </div>
                </div>
                <span class="text-sm font-medium">Launcher-UIkit.fig</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Denial Invite -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Denial">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Denial</span>
                <span class="text-base-content text-sm">Invite from invite link</span>
              </div>
              <p class="text-base-content/50 text-sm">3 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Leslie Alexander Tags -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Leslie Alexander">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Leslie Alexander</span>
                <span class="text-base-content text-sm">new tags to Web Redesign</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="flex dcvi3">
                <span class="ijn5q bxh1m pze98 o1g2m">Client - Request</span>
                <span class="ijn5q bxh1m ctq8s o1g2m">Figma</span>
                <span class="ijn5q bxh1m vn3pt o1g2m">Redesign</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Miya File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Miya">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Miya</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 text-sm">10 Hours ago</p>
            </div>
          </li>
        </ul>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN CONTENT ---------- -->
    <main class="wpaot w-full owca9 sxihv fbpri">
      <div class="dpzny ip6vv">
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
    <div class="bg-base-100">
      <footer class="wpaot hg6f0 w-full owca9 rukzz egd50"></footer>
    </div>
    <!-- ---------- END FOOTER CONTENT ---------- -->
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
    <div class="bg-base-100 d50ic sticky top-0 r1xta zw50f">
      <div class="bg-primary">
        <nav class="hvzi2 wpaot qzwp2 owca9 justify-between m233p">
          <div class="flex items-center bglhu">
            <button type="button" class="collapse-toggle btn btn-soft btn-square btn-sm lg:hidden" id="navbar-collapse" aria-expanded="false" aria-controls="navbar-collapse-heading" data-collapse="#navbar-collapse-heading">
              <span class="icon-[tabler--menu-2] qmuz4"></span>
            </button>
            <!-- Logo -->
            <div class="flex items-center sly4q">
              <div class="rounded-field flex size-8 items-center justify-center qr9u1">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path fill-rule="evenodd" clip-rule="evenodd" d="M17.6745 16.9224L12.6233 10.378C12.2167 9.85117 11.4185 9.8611 11.0251 10.3979L6.45728 16.631C6.26893 16.888 5.96935 17.0398 5.65069 17.0398H3.79114C2.9635 17.0398 2.49412 16.0919 2.99583 15.4336L11.0224 4.90319C11.4206 4.38084 12.2056 4.37762 12.608 4.89668L20.9829 15.6987C21.4923 16.3558 21.024 17.3114 20.1926 17.3114H18.4661C18.1562 17.3114 17.8638 17.1677 17.6745 16.9224ZM12.5866 15.5924L14.8956 18.3593C15.439 19.0105 14.976 20 14.1278 20H9.74075C8.9164 20 8.4461 19.0586 8.94116 18.3994L11.0192 15.6325C11.4065 15.1169 12.1734 15.0972 12.5866 15.5924Z" fill="var(--color-primary)"></path>
                </svg>
              </div>
              <h3 class="bk5oo t3mfo lmn89 max-sm:hidden">Game Platform</h3>
            </div>
          </div>

          <div class="flex items-center ip6vv">
            <div class="flex items-center">
              <!-- Theme Dropdown  -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button id="dropdown-theme" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text [--btn-color:#fff]" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--sun] qmuz4"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-theme" tabindex="-1">
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Light" value="light">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Dark" value="dark">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="System" value="default">
                  </li>
                </ul>
              </div>

              <!-- Language Dropdown -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button id="language-dropdown" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text [--btn-color:#fff]" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--language] qmuz4"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 adede" role="menu" aria-orientation="vertical" aria-labelledby="language-dropdown" tabindex="-1">
                  <li><a class="dropdown-item px-3" href="#">English</a></li>
                  <li><a class="dropdown-item dropdown-active px-3" href="#">Deutsch</a></li>
                  <li><a class="dropdown-item px-3" href="#">한국인</a></li>
                  <li><a class="dropdown-item px-3" href="#">Española</a></li>
                  <li><a class="dropdown-item px-3" href="#">Português</a></li>
                </ul>
              </div>

              <!-- Activity Dropdown -->
              <button type="button" class="btn btn-sm btn-text btn-square [--btn-color:#fff]" aria-haspopup="dialog" aria-expanded="false" aria-controls="activity-drawer" data-overlay="#activity-drawer">
                <span class="icon-[tabler--activity] qmuz4"></span>
              </button>

              <!-- Notification Dropdown -->
              <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:24]">
                <button id="notification-dropdown" type="button" class="dropdown-toggle btn btn-text btn-square btn-sm [--btn-color:#fff]" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="hpjlt">
                    <span class="pykeo kn3q0 j6kj2 rounded-full"></span>
                    <span class="icon-[tabler--bell] qmuz4"></span>
                  </span>
                </button>
                <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full kzmwn adede px-3" role="menu" aria-orientation="vertical" aria-labelledby="notification-dropdown" tabindex="-1">
                  <div class="b6erz flex w-full items-center justify-between njdg2 mwpft">
                    <h6 class="text-base-content/50 text-sm vxiam">Notification</h6>
                    <span class="ijn5q bxh1m o1g2m pze98 rounded-full">8 New</span>
                  </div>
                  <div class="flex items-center justify-between">
                    <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                      <button type="button" class="vfeps active-tab:tab-active active font-medium" id="tabs-basic-item-1" data-tab="#tabs-basic-1" aria-controls="tabs-basic-1" role="tab" aria-selected="true">
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
                    <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1">
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
            <!-- Profile Dropdown -->
            <div class="dropdown relative inline-flex [--offset:21]">
              <button id="profile-dropdown" type="button" class="dropdown-toggle burs3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="User Avatar" class="rounded-box">
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1">
                <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
                  <div class="nfjpm a3rpr">
                    <div class="kqy8v rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                    </div>
                  </div>
                  <div>
                    <h6 class="text-base-content mb-0.5 t3mfo">Charlotte Anne</h6>
                    <p class="text-base-content/80 font-medium">Influencer</p>
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
        </nav>
      </div>

      <nav class="hvzi2 wpaot qzwp2 owca9 justify-between max-lg:p-0">
        <div class="collapse hidden w-full overflow-hidden transition-[height] duration-300 max-lg:px-6 lg:block" id="navbar-collapse-heading" aria-labelledby="navbar-collapse">
          <div class="flex w-full justify-between ikjxw max-lg:flex-col max-lg:py-2.5 lg:items-center">
            <ul class="x737x v85mw lg:menu-horizontal rsqkx cbpaz">
              <!-- Dashboard -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--chart-bar] qmuz4"></span>
                  Dashboard
                </a>
              </li>
              <!--  Games Library -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-game" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 px-2" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--device-gamepad] qmuz4"></span>
                  Games Library
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 qmuz4 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-game" tabindex="-1">
                  <li>
                    <a class="dropdown-item oeogr" href="#">All Games</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">My Games</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Trending Games</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">New Releases</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Top Rated</a>
                  </li>
                </ul>
              </li>
              <!-- Leaderboard -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-leaderboard" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 px-2" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--user] qmuz4"></span>
                  Leaderboard
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 qmuz4 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-leaderboard" tabindex="-1">
                  <li>
                    <a class="dropdown-item" href="#">Global Rankings</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Friends' Rankings</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Monthly Leaders</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Recent Performers</a>
                  </li>
                </ul>
              </li>
              <!-- Achievements -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--star] qmuz4"></span>
                  Achievements
                </a>
              </li>
              <!-- Settings -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--settings] qmuz4"></span>
                  Settings
                </a>
              </li>
              <!-- Support -->
              <li>
                <a href="#" class="px-2">
                  <span class="icon-[tabler--help] qmuz4"></span>
                  Support
                </a>
              </li>
            </ul>
            <div class="flex gy7oi items-center sly4q qbqme">
              <div class="w-full lg:max-w-70">
                <label class="wqwbi rui3g" for="search-input">Find Games</label>
                <input type="text" id="search-input" class="ljn0d" placeholder="Find Games">
              </div>
              <button type="button" class="btn btn-primary btn-square">
                <span class="icon-[tabler--search] girx5"></span>
              </button>
            </div>
          </div>
        </div>
      </nav>
    </div>

    <!-- Activity Drawer Content  -->
    <div id="activity-drawer" class="overlay overlay-open:translate-x-0 vxjzc jbh7e hidden sm:max-w-104" role="dialog" tabindex="-1">
      <div class="a5p6s border-base-content/20 w2qmy p-4">
        <h3 class="eul36 text-base t3mfo">Activity</h3>
        <button type="button" class="btn btn-text btn-circle geut3" aria-label="Close" data-overlay="#activity-drawer" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
      </div>
      <div class="rkt7z cbpaz">
        <ul class="if1r0">
          <!-- Joe Lincoln Activity -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">joe Lincoln</span>
                <span class="text-base-content text-sm">mentioned you in last trends topic</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 border j2be9 mwpft">
                <p class="text-base-content w3dp6 text-sm font-medium">
                  @Flyonui For an expert opinion, check out what Mike has to say on this topic!
                </p>
                <div class="ljn0d e1ers">
                  <input type="text" class="sxihv" placeholder="Reply" id="flyonuiReply">
                  <span class="icon-[tabler--photo] text-base-content/80 q7z0e ms-2 size-4 shrink-0"></span>
                </div>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Sofia -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Sofia">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Sofia</span>
                <span class="text-base-content text-sm">requested feedback on her design.</span>
              </div>
              <p class="text-base-content/50 text-sm">1 Hour ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Jane Perez File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jane Perez">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Jane Perez</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 s7x45 text-sm">3 Hours ago</p>
              <span class="ijn5q bxh1m vnwjt">
                <span class="icon-[tabler--file-type-pdf] text-error"></span>
                invoices.pdf
              </span>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Liam -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Liam">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Liam</span>
                <span class="text-base-content text-sm">has shared a project update.</span>
              </div>
              <p class="text-base-content/50 text-sm">5 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Tyler Hero Design Project -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="Tyler Hero">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Tyler Hero</span>
                <span class="text-base-content text-sm">wants to view your design project</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 flex items-center njdg2 border j2be9 mwpft">
                <div class="nfjpm rmjll">
                  <div class="bg-base-100 text-primary rounded-box size-8 f1870">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/figma-icon.png" alt="avatar">
                  </div>
                </div>
                <span class="text-sm font-medium">Launcher-UIkit.fig</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Denial Invite -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Denial">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Denial</span>
                <span class="text-base-content text-sm">Invite from invite link</span>
              </div>
              <p class="text-base-content/50 text-sm">3 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Leslie Alexander Tags -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Leslie Alexander">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Leslie Alexander</span>
                <span class="text-base-content text-sm">new tags to Web Redesign</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="flex dcvi3">
                <span class="ijn5q bxh1m pze98 o1g2m">Client - Request</span>
                <span class="ijn5q bxh1m ctq8s o1g2m">Figma</span>
                <span class="ijn5q bxh1m vn3pt o1g2m">Redesign</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Miya File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Miya">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Miya</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 text-sm">10 Hours ago</p>
            </div>
          </li>
        </ul>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN CONTENT ---------- -->
    <main class="wpaot w-full owca9 sxihv fbpri">
      <div class="dpzny ip6vv">
        <div class="zq390 tgy6u w-full">
          <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
        </div>
      </div>
    </main>
    <!-- ---------- END MAIN CONTENT ---------- -->
    <!-- ---------- FOOTER CONTENT ---------- -->
    <div class="bg-base-100">
      <footer class="wpaot hg6f0 w-full owca9 rukzz egd50"></footer>
    </div>
    <!-- ---------- END FOOTER CONTENT ---------- -->
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
    <div class="bg-base-100 sticky top-0 r1xta">
      <nav class="hvzi2 wpaot qzwp2 pb833 items-center zvd9e vm5rl max-lg:flex-wrap xl:gap-x-8">
        <div class="flex shrink-0 bglhu lg:order-1">
          <button type="button" class="collapse-toggle btn btn-soft btn-square btn-sm lg:hidden" id="navbar-collapse" aria-expanded="false" aria-controls="navbar-collapse-heading" data-collapse="#navbar-collapse-heading">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>

          <!-- Logo -->
          <div class="flex items-center sly4q">
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
            <h3 class="text-base-content bk5oo fl9z1 max-sm:hidden">eCommerce</h3>
          </div>
        </div>

        <div class="ms-auto flex shrink-0 items-center edy4p njdg2 lg:order-4">
          <div class="flex items-center">
            <!-- Theme Dropdown  -->
            <div class="dropdown relative inline-flex [--offset:24]">
              <button id="dropdown-theme" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--sun] qmuz4"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-theme" tabindex="-1">
                <li>
                  <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Light" value="light">
                </li>
                <li>
                  <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Dark" value="dark">
                </li>
                <li>
                  <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="System" value="default">
                </li>
              </ul>
            </div>

            <!-- Favorite  -->
            <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:24]">
              <button id="fav-dropdown" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--heart] qmuz4"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full zy3u1 nbone ee2rm" role="menu" aria-orientation="vertical" aria-labelledby="fav-dropdown" tabindex="-1">
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

            <!-- Cart  -->
            <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:24]">
              <button id="cart-dropdown" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--shopping-cart] qmuz4"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full xt4vn k9l65 px-3" role="menu" aria-orientation="vertical" aria-labelledby="cart-dropdown" tabindex="-1">
                <li class="flex justify-between b9hof">
                  <h6 class="text-base-content/50 text-sm vxiam">My Cart(3)</h6>
                  <a href="#" class="text-primary font-medium">View All</a>
                </li>
                <li class="removing:translate-x-5 removing:opacity-0 transition duration-300 a6lvc" id="cartItem1">
                  <div class="border-base-content/20 rounded-field border px-3 mwpft">
                    <div class="flex items-center njdg2">
                      <img src="https://cdn.flyonui.com/fy-assets/components/dropdown/image-11.png" class="rounded-box size-8 shrink-0 rs1s9" alt="Nike">
                      <p class="text-base-content e6ynr t3mfo">Nike</p>

                      <div class="flex bglhu">
                        <span class="ijn5q bxh1m gehqc o1g2m">
                          <span class="icon-[tabler--truck]"></span>
                          Free Shipping
                        </span>
                        <span class="ijn5q bxh1m ctq8s o1g2m">Dic 5%</span>
                      </div>
                    </div>
                    <hr class="border-base-content/20 l9qqe">
                    <div class="flex njdg2">
                      <img src="https://cdn.flyonui.com/fy-assets/components/dropdown/image-3-1.png" class="rounded-box ub483 shrink-0 rs1s9" alt="jacket">
                      <div class="flex e6ynr jz3o6 justify-between bglhu">
                        <div class="kf6hd">
                          <h5 class="text-base-content font-medium">Regular Fit Jacket</h5>
                          <div class="flex items-center dcvi3">
                            <span class="text-base-content/80 text-sm aho6k">$130.00</span>
                            <span class="text-base-content font-medium">$99.00</span>
                          </div>
                          <div class="flex items-center dcvi3">
                            <p class="text-base-content/80">White : M</p>
                            <div class="flex items-center rsqkx">
                              <span class="icon-[tabler--star-filled] h7b7g"></span>
                              <p class="text-base-content/50 t3mfo">4.5</p>
                            </div>
                          </div>
                          <select class="select e4d1s gk701 ml7ky m233p" aria-label="select">
                            <option>1</option>
                            <option>2</option>
                            <option>3</option>
                            <option>4</option>
                            <option>5</option>
                          </select>
                        </div>
                      </div>
                      <div class="flex jz3o6 dcvi3">
                        <button class="btn geut3 g2v48 gnw6d btn-square">
                          <span class="icon-[tabler--heart] size-4"></span>
                        </button>
                        <button class="btn geut3 g2v48 gnw6d btn-square" data-remove-element="#cartItem1" aria-label="Delete Item">
                          <span class="icon-[tabler--trash] size-4"></span>
                        </button>
                      </div>
                    </div>
                  </div>
                </li>
                <li class="removing:translate-x-5 removing:opacity-0 transition duration-300 a6lvc" id="cartItem2">
                  <div class="border-base-content/20 rounded-field border px-3 mwpft">
                    <div class="flex items-center njdg2">
                      <img src="https://cdn.flyonui.com/fy-assets/components/dropdown/image-12.png" class="rounded-box size-8 shrink-0 rs1s9" alt="Puma">
                      <p class="text-base-content e6ynr t3mfo">Puma</p>

                      <div class="flex bglhu">
                        <span class="ijn5q bxh1m gehqc o1g2m">
                          <span class="icon-[tabler--truck]"></span>
                          Free Shipping
                        </span>
                        <span class="ijn5q bxh1m ctq8s o1g2m">Dic 15%</span>
                      </div>
                    </div>
                    <hr class="border-base-content/20 l9qqe">
                    <div class="flex njdg2">
                      <img src="https://cdn.flyonui.com/fy-assets/components/dropdown/image-2.png" class="rounded-box ub483 shrink-0 rs1s9" alt="Track Jacket">
                      <div class="flex e6ynr jz3o6 justify-between bglhu">
                        <div class="kf6hd">
                          <h5 class="text-base-content font-medium">Men's Track Jacket</h5>
                          <div class="flex items-center dcvi3">
                            <span class="text-base-content/80 text-sm aho6k">$98.00</span>
                            <span class="text-base-content font-medium">$89.00</span>
                          </div>
                          <div class="flex items-center dcvi3">
                            <p class="text-base-content/80">White : M</p>
                            <div class="flex items-center rsqkx">
                              <span class="icon-[tabler--star-filled] h7b7g"></span>
                              <p class="text-base-content/50 t3mfo">4.0</p>
                            </div>
                          </div>
                          <select class="select e4d1s gk701 ml7ky m233p" aria-label="select">
                            <option>1</option>
                            <option>2</option>
                            <option>3</option>
                            <option>4</option>
                            <option>5</option>
                          </select>
                        </div>
                      </div>
                      <div class="flex jz3o6 dcvi3">
                        <button class="btn geut3 g2v48 gnw6d btn-square">
                          <span class="icon-[tabler--heart] size-4"></span>
                        </button>
                        <button class="btn geut3 g2v48 gnw6d btn-square" data-remove-element="#cartItem2" aria-label="Delete Item">
                          <span class="icon-[tabler--trash] size-4"></span>
                        </button>
                      </div>
                    </div>
                  </div>
                </li>
                <li class="removing:translate-x-5 removing:opacity-0 transition duration-300 a6lvc" id="cartItem3">
                  <div class="border-base-content/20 rounded-field border px-3 mwpft">
                    <div class="flex items-center njdg2">
                      <img src="https://cdn.flyonui.com/fy-assets/components/dropdown/image-12.png" class="rounded-box size-8 shrink-0 rs1s9" alt="Puma">
                      <p class="text-base-content e6ynr t3mfo">Puma</p>

                      <div class="flex bglhu">
                        <span class="ijn5q bxh1m gehqc o1g2m">
                          <span class="icon-[tabler--truck]"></span>
                          Free Shipping
                        </span>
                        <span class="ijn5q bxh1m ctq8s o1g2m">Dic 10%</span>
                      </div>
                    </div>
                    <hr class="border-base-content/20 l9qqe">
                    <div class="flex njdg2">
                      <img src="https://cdn.flyonui.com/fy-assets/components/dropdown/image-1.png" class="rounded-box ub483 shrink-0 rs1s9" alt="Cap">
                      <div class="flex e6ynr jz3o6 justify-between bglhu">
                        <div class="kf6hd">
                          <h5 class="text-base-content font-medium">Ferrari Motorsport Cap</h5>
                          <div class="flex items-center dcvi3">
                            <span class="text-base-content/80 text-sm aho6k">$70.00</span>
                            <span class="text-base-content font-medium">$59.00</span>
                          </div>
                          <div class="flex items-center dcvi3">
                            <p class="text-base-content/80">Red : S</p>
                            <div class="flex items-center rsqkx">
                              <span class="icon-[tabler--star-filled] h7b7g"></span>
                              <p class="text-base-content/50 t3mfo">4.5</p>
                            </div>
                          </div>
                          <select class="select e4d1s gk701 ml7ky m233p" aria-label="select">
                            <option>1</option>
                            <option>2</option>
                            <option>3</option>
                            <option>4</option>
                            <option>5</option>
                          </select>
                        </div>
                      </div>
                      <div class="flex jz3o6 dcvi3">
                        <button class="btn geut3 g2v48 gnw6d btn-square">
                          <span class="icon-[tabler--heart] size-4"></span>
                        </button>
                        <button class="btn geut3 g2v48 gnw6d btn-square" data-remove-element="#cartItem3" aria-label="Delete Item">
                          <span class="icon-[tabler--trash] size-4"></span>
                        </button>
                      </div>
                    </div>
                  </div>
                </li>

                <li class="dpzny qoht8 njdg2">
                  <a class="btn g2v48" href="#">Add To Wish List</a>
                  <a class="btn" href="#">Buy Now</a>
                </li>
              </ul>
            </div>
          </div>

          <!-- Profile Dropdown -->
          <div class="dropdown relative inline-flex [--offset:21]">
            <button id="profile-dropdown" type="button" class="dropdown-toggle shrink-0" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
              <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="User Avatar" class="rounded-box lt1t7">
            </button>
            <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1">
              <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
                <div class="nfjpm a3rpr">
                  <div class="kqy8v rounded-full">
                    <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="avatar">
                  </div>
                </div>
                <div>
                  <h6 class="text-base-content mb-0.5 t3mfo">Phil Ohme</h6>
                  <p class="text-base-content/80 font-medium">Influencer</p>
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

        <div class="collapse hidden gy7oi overflow-hidden overflow-x-auto transition-[height] duration-300 [scrollbar-width:thin] max-lg:w-full lg:order-3 lg:block lg:basis-auto" id="navbar-collapse-heading" aria-labelledby="navbar-collapse">
          <ul class="x737x v85mw lg:menu-horizontal rsqkx cbpaz">
            <!-- Dashboard -->
            <li>
              <a href="#" class="px-2">
                <span class="icon-[tabler--chart-bar] qmuz4"></span>
                Dashboard
              </a>
            </li>

            <!-- Products Dropdown -->
            <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
              <button id="dropdown-products" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 dropdown-open:text-base-content px-2" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--box] qmuz4"></span>
                Products
                <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 qmuz4 ciihs duration-300"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-products" tabindex="-1">
                <li><a class="dropdown-item oeogr" href="#">All Products</a></li>
                <li><a class="dropdown-item" href="#">New Product</a></li>
                <li><a class="dropdown-item" href="#">Categories</a></li>
                <li><a class="dropdown-item" href="#">Inventory</a></li>
                <li><a class="dropdown-item" href="#">Tags</a></li>
                <li><a class="dropdown-item" href="#">Product Settings</a></li>
              </ul>
            </li>

            <!-- Orders -->
            <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
              <button id="dropdown-orders" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 dropdown-open:text-base-content px-2" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--receipt] qmuz4"></span>
                Orders
                <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 qmuz4 ciihs duration-300"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-orders" tabindex="-1">
                <li><a class="dropdown-item" href="#">All Orders</a></li>
                <li><a class="dropdown-item" href="#">Pending</a></li>
                <li><a class="dropdown-item" href="#">Completed</a></li>
                <li><a class="dropdown-item" href="#">Cancelled</a></li>
                <li><a class="dropdown-item" href="#">Order Settings</a></li>
              </ul>
            </li>

            <!-- Customers -->
            <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
              <button id="dropdown-customers" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 dropdown-open:text-base-content px-2" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--users] qmuz4"></span>
                Customers
                <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 qmuz4 ciihs duration-300"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-customers" tabindex="-1">
                <li><a class="dropdown-item" href="#">Customer List</a></li>
                <li><a class="dropdown-item" href="#">Segments</a></li>
                <li><a class="dropdown-item" href="#">Loyalty Program</a></li>
                <li><a class="dropdown-item" href="#">Customer Feedback</a></li>
                <li><a class="dropdown-item" href="#">Customer Settings</a></li>
              </ul>
            </li>

            <!-- Reviews -->
            <li>
              <a href="#" class="px-2">
                <span class="icon-[tabler--star] qmuz4"></span>
                Reviews
              </a>
            </li>

            <!-- Referrals -->
            <li>
              <a href="#" class="px-2">
                <span class="icon-[tabler--affiliate] qmuz4"></span>
                Referrals
              </a>
            </li>

            <!-- Settings Dropdown -->
            <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
              <button id="dropdown-settings" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 dropdown-open:text-base-content px-2" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--settings] qmuz4"></span>
                Settings
                <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 qmuz4 ciihs duration-300"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-settings" tabindex="-1">
                <li><a class="dropdown-item" href="#">General Settings</a></li>
                <li><a class="dropdown-item" href="#">Shipping</a></li>
                <li><a class="dropdown-item" href="#">Payments</a></li>
                <li><a class="dropdown-item" href="#">Notifications</a></li>
                <li><a class="dropdown-item" href="#">Advanced</a></li>
              </ul>
            </li>
          </ul>
        </div>
      </nav>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN CONTENT ---------- -->
    <main class="before:bg-primary relative z-1 w-full sxihv before:absolute before:top-0 before:-z-1 before:h-105 before:w-full">
      <div class="wpaot pb833 fbpri vj77y">
        <div class="ntokn">
          <ul class="egd50">
            <li>
              <a href="#" class="siqxi hover:text-white">
                <span class="icon-[tabler--smart-home] size-5"></span>
              </a>
            </li>
            <li class="hmm07 rtl:rotate-180">
              <span class="icon-[tabler--chevron-right] siqxi ue1bl"></span>
            </li>
            <li>
              <a href="#" class="siqxi text-sm hover:text-white">Dashboard</a>
            </li>
            <li class="hmm07 rtl:rotate-180">
              <span class="icon-[tabler--chevron-right] siqxi ue1bl"></span>
            </li>
            <li>
              <a href="#" class="siqxi text-sm hover:text-white">eCommerce</a>
            </li>
            <li class="hmm07 rtl:rotate-180">
              <span class="icon-[tabler--chevron-right] siqxi ue1bl"></span>
            </li>
            <li aria-current="page" class="siqxi text-sm">Product Details</li>
          </ul>
        </div>

        <hr class="cxqv4">

        <div class="flex mnhlk justify-between njdg2 fnetp">
          <div class="flex items-center njdg2">
            <div class="nfjpm rmjll">
              <div class="text-primary rounded-box ps193 qr9u1">
                <span class="icon-[tabler--chart-pie] q31t4"></span>
              </div>
            </div>
            <div class="flex jz3o6 xk2ot">
              <span class="siqxi bk5oo t3mfo">eCommerce Dashboard</span>
              <span class="siqxi">Earning Reports</span>
            </div>
          </div>

          <div class="flex items-center njdg2 sm:gap-9">
            <div class="adede rdi5h">
              <h3 class="siqxi bk5oo t3mfo">$23k</h3>
              <p class="siqxi rdi5h">Sales</p>
            </div>

            <div class="adede rdi5h">
              <h3 class="siqxi bk5oo t3mfo">8.51k</h3>
              <p class="siqxi rdi5h">Customers</p>
            </div>

            <div class="adede rdi5h">
              <h3 class="siqxi bk5oo t3mfo">2.5k</h3>
              <p class="siqxi rdi5h">Products</p>
            </div>

            <div class="adede rdi5h">
              <h3 class="siqxi bk5oo t3mfo">$1.2k</h3>
              <p class="siqxi rdi5h">Revenue</p>
            </div>
          </div>
        </div>

        <div class="dpzny ip6vv">
          <div class="zq390 tgy6u w-full tnh37">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
      </div>
    </main>
    <!-- ---------- END MAIN CONTENT ---------- -->

    <!-- ---------- FOOTER CONTENT ---------- -->
    <div class="bg-base-100">
      <footer class="wpaot hg6f0 w-full pb833 rukzz egd50"></footer>
    </div>
    <!-- ---------- END FOOTER CONTENT ---------- -->
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
      <div class="wpaot w-full">
        <nav class="hvzi2 justify-between njdg2">
          <div class="szonh items-center bglhu">
            <button type="button" class="btn btn-soft btn-square lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
              <span class="icon-[tabler--menu-2] size-5"></span>
            </button>

            <!-- Quick Links -->
            <div class="flex items-center njdg2">
              <div class="dropdown relative inline-flex [--offset:20]">
                <button id="dropdown-flyonui" type="button" class="dropdown-toggle flex items-center eovr6 max-sm:hidden" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--settings] size-5 md:hidden"></span>
                  <span class="font-medium max-md:hidden">Flyonui</span>
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 girx5 ciihs duration-300 max-md:hidden"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-flyonui" tabindex="-1">
                  <li><a class="dropdown-item" href="#">Account</a></li>
                  <li><a class="dropdown-item" href="#">Preferences</a></li>
                  <li><a class="dropdown-item" href="#">Billing</a></li>
                  <li><a class="dropdown-item" href="#">Help Center</a></li>
                </ul>
              </div>
              <div class="dropdown relative inline-flex [--offset:20]">
                <button id="dropdown-projects" type="button" class="dropdown-toggle flex items-center eovr6 max-sm:hidden" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--file] size-5 md:hidden"></span>
                  <span class="font-medium max-md:hidden">Projects</span>
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 girx5 ciihs duration-300 max-md:hidden"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-projects" tabindex="-1">
                  <li><a class="dropdown-item" href="#">Create Project</a></li>
                  <li><a class="dropdown-item" href="#">View Projects</a></li>
                  <li><a class="dropdown-item" href="#">Project Templates</a></li>
                </ul>
              </div>
              <div class="dropdown relative inline-flex [--offset:20]">
                <button id="dropdown-resources" type="button" class="dropdown-toggle flex items-center eovr6 max-sm:hidden" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--folders] size-5 md:hidden"></span>
                  <span class="font-medium max-md:hidden">Resources</span>
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 girx5 ciihs duration-300 max-md:hidden"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-resources" tabindex="-1">
                  <li><a class="dropdown-item" href="#">Documentation</a></li>
                  <li><a class="dropdown-item" href="#">Tutorials</a></li>
                  <li><a class="dropdown-item" href="#">Support</a></li>
                  <li><a class="dropdown-item" href="#">References</a></li>
                </ul>
              </div>
            </div>
          </div>

          <div class="ktglt items-center ip6vv max-xl:gap-3">
            <div class="flex items-center sly4q">
              <!-- Theme Dropdown -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button id="dropdown-theme" type="button" class="dropdown-toggle btn btn-square g2v48 border-base-content/20" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--sun] girx5"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-theme" tabindex="-1">
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Light" value="light">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Dark" value="dark">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="System" value="default">
                  </li>
                </ul>
              </div>

              <!-- Activity Dropdown -->
              <button type="button" class="btn btn-square g2v48 border-base-content/20" aria-haspopup="dialog" aria-expanded="false" aria-controls="activity-drawer" data-overlay="#activity-drawer">
                <span class="icon-[tabler--activity] girx5"></span>
              </button>

              <!-- Notification Dropdown -->
              <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:24]">
                <button id="notification-dropdown" type="button" class="dropdown-toggle hpjlt" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="pykeo kn3q0 j6kj2 rounded-full"></span>
                  <span class="btn g2v48 btn-square border-base-content/20">
                    <span class="icon-[tabler--bell] girx5"></span>
                  </span>
                </button>
                <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full kzmwn adede px-3" role="menu" aria-orientation="vertical" aria-labelledby="notification-dropdown" tabindex="-1">
                  <div class="b6erz flex w-full items-center justify-between njdg2 mwpft">
                    <h6 class="text-base-content/50 text-sm vxiam">Notification</h6>
                    <span class="ijn5q bxh1m o1g2m pze98 rounded-full">8 New</span>
                  </div>
                  <div class="flex items-center justify-between">
                    <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                      <button type="button" class="vfeps active-tab:tab-active active font-medium" id="tabs-basic-item-1" data-tab="#tabs-basic-1" aria-controls="tabs-basic-1" role="tab" aria-selected="true">
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
                    <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1">
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

            <!-- Language Dropdown -->
            <div class="dropdown relative inline-flex [--offset:24]">
              <button id="language-dropdown" type="button" class="dropdown-toggle btn g2v48 border-base-content/20 max-xl:btn-square" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--language] girx5 xl:hidden"></span>
                <span class="max-xl:hidden">English</span>
                <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-5 max-xl:hidden"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 adede" role="menu" aria-orientation="vertical" aria-labelledby="language-dropdown" tabindex="-1">
                <li><a class="dropdown-item dropdown-active px-3" href="#">English</a></li>
                <li><a class="dropdown-item px-3" href="#">Deutsch</a></li>
                <li><a class="dropdown-item px-3" href="#">한국인</a></li>
                <li><a class="dropdown-item px-3" href="#">Española</a></li>
                <li><a class="dropdown-item px-3" href="#">Português</a></li>
              </ul>
            </div>

            <!-- Profile Dropdown -->
            <div class="dropdown relative inline-flex [--offset:21]">
              <button id="profile-dropdown" type="button" class="dropdown-toggle" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="nfjpm">
                  <span class="zv497 rounded-full">
                    <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="User Avatar">
                  </span>
                </span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1">
                <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
                  <div class="nfjpm a3rpr">
                    <div class="kqy8v rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                    </div>
                  </div>
                  <div>
                    <h6 class="text-base-content mb-0.5 t3mfo">John Doe</h6>
                    <p class="text-base-content/80 font-medium">UI/UX Designer</p>
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
        </nav>
      </div>
    </div>

    <!-- Activity Drawer Content  -->
    <div id="activity-drawer" class="overlay overlay-open:translate-x-0 vxjzc jbh7e hidden sm:max-w-104" role="dialog" tabindex="-1">
      <div class="a5p6s border-base-content/20 w2qmy p-4">
        <h3 class="eul36 text-base t3mfo">Activity</h3>
        <button type="button" class="btn btn-text btn-circle geut3" aria-label="Close" data-overlay="#activity-drawer" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
      </div>
      <div class="rkt7z cbpaz">
        <ul class="if1r0">
          <!-- Joe Lincoln Activity -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">joe Lincoln</span>
                <span class="text-base-content text-sm">mentioned you in last trends topic</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 border j2be9 mwpft">
                <p class="text-base-content w3dp6 text-sm font-medium">
                  @Flyonui For an expert opinion, check out what Mike has to say on this topic!
                </p>
                <div class="ljn0d e1ers">
                  <input type="text" class="sxihv" placeholder="Reply" id="flyonuiReply">
                  <span class="icon-[tabler--photo] text-base-content/80 q7z0e ms-2 size-4 shrink-0"></span>
                </div>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Sofia -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Sofia">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Sofia</span>
                <span class="text-base-content text-sm">requested feedback on her design.</span>
              </div>
              <p class="text-base-content/50 text-sm">1 Hour ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Jane Perez File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jane Perez">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Jane Perez</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 s7x45 text-sm">3 Hours ago</p>
              <span class="ijn5q bxh1m vnwjt">
                <span class="icon-[tabler--file-type-pdf] text-error"></span>
                invoices.pdf
              </span>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Liam -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Liam">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Liam</span>
                <span class="text-base-content text-sm">has shared a project update.</span>
              </div>
              <p class="text-base-content/50 text-sm">5 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Tyler Hero Design Project -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="Tyler Hero">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Tyler Hero</span>
                <span class="text-base-content text-sm">wants to view your design project</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 flex items-center njdg2 border j2be9 mwpft">
                <div class="nfjpm rmjll">
                  <div class="bg-base-100 text-primary rounded-box size-8 f1870">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/figma-icon.png" alt="avatar">
                  </div>
                </div>
                <span class="text-sm font-medium">Launcher-UIkit.fig</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Denial Invite -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Denial">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Denial</span>
                <span class="text-base-content text-sm">Invite from invite link</span>
              </div>
              <p class="text-base-content/50 text-sm">3 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Leslie Alexander Tags -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Leslie Alexander">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Leslie Alexander</span>
                <span class="text-base-content text-sm">new tags to Web Redesign</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="flex dcvi3">
                <span class="ijn5q bxh1m pze98 o1g2m">Client - Request</span>
                <span class="ijn5q bxh1m ctq8s o1g2m">Figma</span>
                <span class="ijn5q bxh1m vn3pt o1g2m">Redesign</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Miya File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Miya">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Miya</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 text-sm">10 Hours ago</p>
            </div>
          </li>
        </ul>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 wjz3b e4bmm hidden n85ea [--auto-close:lg] sm:w-75 lg:z-50 lg:block lg:translate-x-0 lg:shadow-none" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z border-base-content/20 n85ea jawf4 fbpri">
        <button type="button" class="btn btn-text btn-square geut3 absolute koirh s7loe sm:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
        <div class="border-base-content/20 rounded-box cy2ft n85ea border"></div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->

    <div class="flex sxihv jz3o6 justify-between lg:ps-75">
      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="e6ynr fbpri">
        <div class="dpzny ip6vv">
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
    <div class="bg-base-100 sticky top-0 at1sq">
      <div class="wpaot w-full owca9">
        <nav class="hvzi2 justify-between njdg2 mrpnf">
          <!-- Logo -->
          <div class="flex items-center sly4q">
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
            <h3 class="text-base-content bk5oo fl9z1 max-sm:hidden">FlyonUI</h3>
          </div>

          <!-- Search -->
          <button type="button" class="rounded-field border-base-content/40 flex tqks9 r2qpi items-center eovr6 border ee2rm max-md:hidden xl:w-67" aria-haspopup="dialog" aria-expanded="false" aria-controls="search-modal" data-overlay="#search-modal">
            <span class="icon-[tabler--search] text-base-content size-5"></span>
            <span class="text-base-content/50">Search here...</span>
          </button>

          <div class="flex items-center njdg2">
            <div class="flex items-center">
              <!-- Search Btn For Small Screen  -->
              <button type="button" class="btn btn-text btn-square md:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="search-modal" data-overlay="#search-modal">
                <span class="icon-[tabler--search] text-base-content girx5"></span>
              </button>

              <!-- Theme Dropdown  -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button id="dropdown-theme" type="button" class="dropdown-toggle btn btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--sun] girx5"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-theme" tabindex="-1">
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Light" value="light">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Dark" value="dark">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="System" value="default">
                  </li>
                </ul>
              </div>
              <!-- Language Dropdown -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button id="language-dropdown" type="button" class="dropdown-toggle btn btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--language] girx5"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 adede" role="menu" aria-orientation="vertical" aria-labelledby="language-dropdown" tabindex="-1">
                  <li><a class="dropdown-item px-3" href="#">English</a></li>
                  <li><a class="dropdown-item dropdown-active px-3" href="#">Deutsch</a></li>
                  <li><a class="dropdown-item px-3" href="#">한국인</a></li>
                  <li><a class="dropdown-item px-3" href="#">Española</a></li>
                  <li><a class="dropdown-item px-3" href="#">Português</a></li>
                </ul>
              </div>
              <!-- Activity Dropdown -->
              <button type="button" class="btn btn-text btn-square" aria-haspopup="dialog" aria-expanded="false" aria-controls="activity-drawer" data-overlay="#activity-drawer">
                <span class="icon-[tabler--activity] girx5"></span>
              </button>
              <!-- Notification Dropdown -->
              <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:24]">
                <button id="notification-dropdown" type="button" class="dropdown-toggle btn btn-text btn-square btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="hpjlt">
                    <span class="pykeo kn3q0 j6kj2 rounded-full"></span>
                    <span class="icon-[tabler--bell] girx5"></span>
                  </span>
                </button>
                <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full kzmwn adede px-3" role="menu" aria-orientation="vertical" aria-labelledby="notification-dropdown" tabindex="-1">
                  <div class="b6erz flex w-full items-center justify-between njdg2 mwpft">
                    <h6 class="text-base-content/50 text-sm vxiam">Notification</h6>
                    <span class="ijn5q bxh1m o1g2m pze98 rounded-full">8 New</span>
                  </div>
                  <div class="flex items-center justify-between">
                    <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                      <button type="button" class="vfeps active-tab:tab-active active font-medium" id="tabs-basic-item-1" data-tab="#tabs-basic-1" aria-controls="tabs-basic-1" role="tab" aria-selected="true">
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
                    <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1">
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
            <!-- Profile Dropdown -->
            <div class="dropdown relative inline-flex [--offset:21]">
              <button id="profile-dropdown" type="button" class="dropdown-toggle burs3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="User Avatar" class="rounded-box">
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1">
                <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
                  <div class="nfjpm a3rpr">
                    <div class="kqy8v rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="avatar">
                    </div>
                  </div>
                  <div>
                    <h6 class="text-base-content mb-0.5 t3mfo">Charlotte Anne</h6>
                    <p class="text-base-content/80 font-medium">Influencer</p>
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
        </nav>
      </div>
    </div>

    <!-- Search Dropdown Content  -->
    <div id="search-modal" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 hidden" role="dialog" tabindex="-1">
      <div class="dthlq w-full zr8jv">
        <div class="pbhw6 j5lbz nwdq3">
          <!-- SearchBox -->
          <div class="m1ukj border-base-content/20 abnz9 px-3 py-2">
            <div class="ljn0d o22n0 pelb3 eghwv">
              <span class="icon-[tabler--search] text-base-content/80 q7z0e me-2 size-5 shrink-0"></span>
              <input type="search" class="sxihv" placeholder="Search here..." id="kbdInput">
              <label class="rui3g" for="kbdInput">Search</label>
            </div>
          </div>

          <nav class="hhn76 vt6q1 py-2" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
            <button type="button" class="vfeps active-tab:tab-active active w-full font-medium" id="search-tabs-item-1" data-tab="#search-tabs-1" aria-controls="search-tabs-1" role="tab" aria-selected="true">
              All
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-2" data-tab="#search-tabs-2" aria-controls="search-tabs-2" role="tab" aria-selected="false">
              Pages
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-3" data-tab="#search-tabs-3" aria-controls="search-tabs-3" role="tab" aria-selected="false">
              Integration
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-4" data-tab="#search-tabs-4" aria-controls="search-tabs-4" role="tab" aria-selected="false">
              Users
            </button>
          </nav>
          <!-- SearchBox Modal Body -->
          <div class="fpegk overflow-y-auto lg:max-h-121">
            <!-- SearchBox All Modal Body -->
            <div id="search-tabs-1" role="tabpanel" aria-labelledby="search-tabs-item-1">
              <!-- Pages Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Pages</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- Interaction Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Interaction</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- User Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">User</div>
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown1" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown1" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown2" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown2" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Pages Modal Body -->
            <div id="search-tabs-2" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-2">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Integration Modal Body -->
            <div id="search-tabs-3" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-3">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Users Modal Body -->
            <div id="search-tabs-4" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-4">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown3" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown3" tabindex="-1">
                            <li><button class="dropdown-item px-2">View More</button></li>
                            <li><button class="dropdown-item px-2">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown4" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown4" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>
          </div>
          <!-- Footer Commands -->
          <div class="w3jfd border-base-content/20 text-base-content/50 njdg2 ia8ws egd50 max-sm:hidden">
            <div class="flex sxihv items-center bglhu text-sm">
              <kbd class="b2fu4 an53u">esc</kbd>
              <span>To close</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-back] size-4"></span></kbd>
              <span>To Select</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-up] size-4"></span></kbd>
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-down] size-4"></span></kbd>
              <span>To Navigate</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Activity Drawer Content  -->
    <div id="activity-drawer" class="overlay overlay-open:translate-x-0 vxjzc jbh7e hidden sm:max-w-104" role="dialog" tabindex="-1">
      <div class="a5p6s border-base-content/20 w2qmy p-4">
        <h3 class="eul36 text-base t3mfo">Activity</h3>
        <button type="button" class="btn btn-text btn-circle geut3" aria-label="Close" data-overlay="#activity-drawer" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
      </div>
      <div class="rkt7z cbpaz">
        <ul class="if1r0">
          <!-- Joe Lincoln Activity -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">joe Lincoln</span>
                <span class="text-base-content text-sm">mentioned you in last trends topic</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 border j2be9 mwpft">
                <p class="text-base-content w3dp6 text-sm font-medium">
                  @Flyonui For an expert opinion, check out what Mike has to say on this topic!
                </p>
                <div class="ljn0d e1ers">
                  <input type="text" class="sxihv" placeholder="Reply" id="flyonuiReply">
                  <span class="icon-[tabler--photo] text-base-content/80 q7z0e ms-2 size-4 shrink-0"></span>
                </div>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Sofia -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Sofia">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Sofia</span>
                <span class="text-base-content text-sm">requested feedback on her design.</span>
              </div>
              <p class="text-base-content/50 text-sm">1 Hour ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Jane Perez File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jane Perez">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Jane Perez</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 s7x45 text-sm">3 Hours ago</p>
              <span class="ijn5q bxh1m vnwjt">
                <span class="icon-[tabler--file-type-pdf] text-error"></span>
                invoices.pdf
              </span>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Liam -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Liam">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Liam</span>
                <span class="text-base-content text-sm">has shared a project update.</span>
              </div>
              <p class="text-base-content/50 text-sm">5 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Tyler Hero Design Project -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="Tyler Hero">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Tyler Hero</span>
                <span class="text-base-content text-sm">wants to view your design project</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 flex items-center njdg2 border j2be9 mwpft">
                <div class="nfjpm rmjll">
                  <div class="bg-base-100 text-primary rounded-box size-8 f1870">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/figma-icon.png" alt="avatar">
                  </div>
                </div>
                <span class="text-sm font-medium">Launcher-UIkit.fig</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Denial Invite -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Denial">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Denial</span>
                <span class="text-base-content text-sm">Invite from invite link</span>
              </div>
              <p class="text-base-content/50 text-sm">3 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Leslie Alexander Tags -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Leslie Alexander">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Leslie Alexander</span>
                <span class="text-base-content text-sm">new tags to Web Redesign</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="flex dcvi3">
                <span class="ijn5q bxh1m pze98 o1g2m">Client - Request</span>
                <span class="ijn5q bxh1m ctq8s o1g2m">Figma</span>
                <span class="ijn5q bxh1m vn3pt o1g2m">Redesign</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Miya File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Miya">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Miya</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 text-sm">10 Hours ago</p>
            </div>
          </li>
        </ul>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN CONTENT ---------- -->
    <main class="wpaot w-full owca9 sxihv fbpri">
      <div class="dpzny ip6vv sm:grid-cols-2">
        <div class="zq390 hono0 w-full sm:col-span-2">
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
    <div class="bg-base-100">
      <footer class="wpaot hg6f0 w-full owca9 rukzz egd50"></footer>
    </div>
    <!-- ---------- END FOOTER CONTENT ---------- -->
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
    <div class="bg-base-100 sticky top-0 at1sq">
      <div class="wpaot w-full owca9">
        <nav class="hvzi2 mnhlk justify-between vu1rt ikjxw mrpnf">
          <div class="flex bglhu lg:order-1">
            <button type="button" class="collapse-toggle btn btn-soft btn-square btn-sm lg:hidden" id="navbar-collapse" aria-expanded="false" aria-controls="navbar-collapse-heading" data-collapse="#navbar-collapse-heading">
              <span class="icon-[tabler--menu-2] size-5"></span>
            </button>

            <!-- Logo -->
            <div class="flex items-center sly4q">
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
              <h3 class="text-base-content bk5oo fl9z1 max-sm:hidden">FlyonUI</h3>
            </div>
          </div>

          <div class="flex sxihv items-center edy4p sly4q lg:order-4 lg:gap-6">
            <div class="flex items-center sly4q">
              <!-- Theme Dropdown  -->
              <div class="dropdown relative inline-flex [--offset:24]">
                <button id="dropdown-theme" type="button" class="dropdown-toggle btn btn-square g2v48 border-base-content/20" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--sun] girx5"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-theme" tabindex="-1">
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Light" value="light">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Dark" value="dark">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="System" value="default">
                  </li>
                </ul>
              </div>

              <!-- Activity Dropdown -->
              <button type="button" class="btn btn-square g2v48 border-base-content/20 max-sm:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="activity-drawer" data-overlay="#activity-drawer">
                <span class="icon-[tabler--activity] girx5"></span>
              </button>

              <!-- Notification Dropdown -->
              <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:24]">
                <button id="notification-dropdown" type="button" class="dropdown-toggle hpjlt" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="pykeo kn3q0 j6kj2 rounded-full"></span>
                  <span class="btn g2v48 btn-square border-base-content/20">
                    <span class="icon-[tabler--bell] girx5"></span>
                  </span>
                </button>
                <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full kzmwn adede px-3" role="menu" aria-orientation="vertical" aria-labelledby="notification-dropdown" tabindex="-1">
                  <div class="b6erz flex w-full items-center justify-between njdg2 mwpft">
                    <h6 class="text-base-content/50 text-sm vxiam">Notification</h6>
                    <span class="ijn5q bxh1m o1g2m pze98 rounded-full">8 New</span>
                  </div>
                  <div class="flex items-center justify-between">
                    <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                      <button type="button" class="vfeps active-tab:tab-active active font-medium" id="tabs-basic-item-1" data-tab="#tabs-basic-1" aria-controls="tabs-basic-1" role="tab" aria-selected="true">
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
                    <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1">
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

            <!-- Language Dropdown -->
            <div class="dropdown relative inline-flex [--offset:24]">
              <button id="language-dropdown" type="button" class="dropdown-toggle btn g2v48 border-base-content/20 max-lg:btn-square" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--language] girx5 lg:hidden"></span>
                <span class="max-lg:hidden">English</span>
                <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-5 max-lg:hidden"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 adede" role="menu" aria-orientation="vertical" aria-labelledby="language-dropdown" tabindex="-1">
                <li><a class="dropdown-item dropdown-active px-3" href="#">English</a></li>
                <li><a class="dropdown-item px-3" href="#">Deutsch</a></li>
                <li><a class="dropdown-item px-3" href="#">한국인</a></li>
                <li><a class="dropdown-item px-3" href="#">Española</a></li>
                <li><a class="dropdown-item px-3" href="#">Português</a></li>
              </ul>
            </div>

            <!-- Profile Dropdown -->
            <div class="dropdown relative inline-flex [--offset:21]">
              <button id="profile-dropdown" type="button" class="dropdown-toggle" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="nfjpm">
                  <span class="zv497 rounded-full">
                    <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="User Avatar">
                  </span>
                </span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1">
                <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
                  <div class="nfjpm a3rpr">
                    <div class="kqy8v rounded-full">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                    </div>
                  </div>
                  <div>
                    <h6 class="text-base-content mb-0.5 t3mfo">John Doe</h6>
                    <p class="text-base-content/80 font-medium">UI/UX Designer</p>
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

          <div class="collapse hidden w-full sxihv overflow-hidden transition-[height] duration-300 lg:order-3 lg:block lg:w-fit lg:basis-auto" id="navbar-collapse-heading" aria-labelledby="navbar-collapse">
            <ul class="x737x v85mw lg:menu-horizontal rsqkx cbpaz">
              <!-- Flyonui -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-flyonui" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 dropdown-open:text-base-content f7zrf" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--settings] size-5 lg:hidden"></span>
                  Flyonui
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-5 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-flyonui" tabindex="-1">
                  <li>
                    <a class="dropdown-item oeogr" href="#">Account</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Preferences</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Billing</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Help Center</a>
                  </li>
                </ul>
              </li>

              <!--  Projects -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-projects" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 dropdown-open:text-base-content f7zrf" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--file] size-5 lg:hidden"></span>
                  Projects
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-5 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-projects" tabindex="-1">
                  <li><a class="dropdown-item" href="#">Create Project</a></li>
                  <li><a class="dropdown-item" href="#">View Projects</a></li>
                  <li><a class="dropdown-item" href="#">Project Templates</a></li>
                </ul>
              </li>

              <!-- Resources -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-resources" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 dropdown-open:text-base-content f7zrf" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--folders] size-5 lg:hidden"></span>
                  Resources
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-5 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-resources" tabindex="-1">
                  <li><a class="dropdown-item" href="#">Documentation</a></li>
                  <li><a class="dropdown-item" href="#">Tutorials</a></li>
                  <li><a class="dropdown-item" href="#">Support</a></li>
                  <li><a class="dropdown-item" href="#">References</a></li>
                </ul>
              </li>
            </ul>
          </div>
        </nav>
      </div>
    </div>

    <!-- Activity Drawer Content  -->
    <div id="activity-drawer" class="overlay overlay-open:translate-x-0 vxjzc jbh7e hidden sm:max-w-104" role="dialog" tabindex="-1">
      <div class="a5p6s border-base-content/20 w2qmy p-4">
        <h3 class="eul36 text-base t3mfo">Activity</h3>
        <button type="button" class="btn btn-text btn-circle geut3" aria-label="Close" data-overlay="#activity-drawer" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
      </div>
      <div class="rkt7z cbpaz">
        <ul class="if1r0">
          <!-- Joe Lincoln Activity -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">joe Lincoln</span>
                <span class="text-base-content text-sm">mentioned you in last trends topic</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 border j2be9 mwpft">
                <p class="text-base-content w3dp6 text-sm font-medium">
                  @Flyonui For an expert opinion, check out what Mike has to say on this topic!
                </p>
                <div class="ljn0d e1ers">
                  <input type="text" class="sxihv" placeholder="Reply" id="flyonuiReply">
                  <span class="icon-[tabler--photo] text-base-content/80 q7z0e ms-2 size-4 shrink-0"></span>
                </div>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Sofia -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Sofia">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Sofia</span>
                <span class="text-base-content text-sm">requested feedback on her design.</span>
              </div>
              <p class="text-base-content/50 text-sm">1 Hour ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Jane Perez File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jane Perez">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Jane Perez</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 s7x45 text-sm">3 Hours ago</p>
              <span class="ijn5q bxh1m vnwjt">
                <span class="icon-[tabler--file-type-pdf] text-error"></span>
                invoices.pdf
              </span>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Liam -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Liam">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Liam</span>
                <span class="text-base-content text-sm">has shared a project update.</span>
              </div>
              <p class="text-base-content/50 text-sm">5 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Tyler Hero Design Project -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="Tyler Hero">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Tyler Hero</span>
                <span class="text-base-content text-sm">wants to view your design project</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 flex items-center njdg2 border j2be9 mwpft">
                <div class="nfjpm rmjll">
                  <div class="bg-base-100 text-primary rounded-box size-8 f1870">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/figma-icon.png" alt="avatar">
                  </div>
                </div>
                <span class="text-sm font-medium">Launcher-UIkit.fig</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Denial Invite -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Denial">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Denial</span>
                <span class="text-base-content text-sm">Invite from invite link</span>
              </div>
              <p class="text-base-content/50 text-sm">3 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Leslie Alexander Tags -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Leslie Alexander">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Leslie Alexander</span>
                <span class="text-base-content text-sm">new tags to Web Redesign</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="flex dcvi3">
                <span class="ijn5q bxh1m pze98 o1g2m">Client - Request</span>
                <span class="ijn5q bxh1m ctq8s o1g2m">Figma</span>
                <span class="ijn5q bxh1m vn3pt o1g2m">Redesign</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Miya File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Miya">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Miya</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 text-sm">10 Hours ago</p>
            </div>
          </li>
        </ul>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN CONTENT ---------- -->
    <main class="wpaot w-full owca9 sxihv fbpri">
      <div class="dpzny ip6vv sm:grid-cols-2">
        <div class="zq390 v0llt w-full sm:col-span-2">
          <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
        </div>
        <div class="zq390 v0llt w-full sm:col-span-2">
          <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
        </div>
        <div class="zq390 v0llt w-full">
          <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
        </div>
        <div class="zq390 v0llt w-full">
          <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
        </div>
      </div>
    </main>
    <!-- ---------- END MAIN CONTENT ---------- -->
    <!-- ---------- FOOTER CONTENT ---------- -->
    <div class="bg-base-100">
      <footer class="wpaot hg6f0 w-full owca9 rukzz egd50"></footer>
    </div>
    <!-- ---------- END FOOTER CONTENT ---------- -->
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
    <div class="bg-base-100 sticky top-0 at1sq">
      <div class="wpaot w-full owca9">
        <nav class="hvzi2 mnhlk justify-between njdg2 mrpnf">
          <div class="flex bglhu lg:order-1">
            <button type="button" class="collapse-toggle btn btn-soft btn-square btn-sm lg:hidden" id="navbar-collapse" aria-expanded="false" aria-controls="navbar-collapse-heading" data-collapse="#navbar-collapse-heading">
              <span class="icon-[tabler--menu-2] size-5"></span>
            </button>

            <!-- Logo -->
            <div class="flex items-center sly4q">
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
              <h3 class="text-base-content bk5oo fl9z1 max-sm:hidden">FlyonUI</h3>
            </div>
          </div>

          <div class="flex items-center edy4p sly4q lg:order-4 lg:gap-6">
            <div class="flex items-center">
              <!-- Theme Dropdown  -->
              <div class="dropdown relative inline-flex [--offset:10]">
                <button id="dropdown-theme" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--sun] qmuz4"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-theme" tabindex="-1">
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Light" value="light">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Dark" value="dark">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="System" value="default">
                  </li>
                </ul>
              </div>

              <!-- Share Dropdown  -->
              <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:10]">
                <button id="share-dropdown" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--share] qmuz4"></span>
                </button>
                <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full z668w adede j2be9" role="menu" aria-orientation="vertical" aria-labelledby="share-dropdown" tabindex="-1">
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

              <!-- Language Dropdown -->
              <div class="dropdown relative inline-flex [--offset:10]">
                <button id="language-dropdown" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--language] qmuz4"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 adede" role="menu" aria-orientation="vertical" aria-labelledby="language-dropdown" tabindex="-1">
                  <li><a class="dropdown-item px-3" href="#">English</a></li>
                  <li><a class="dropdown-item dropdown-active px-3" href="#">Deutsch</a></li>
                  <li><a class="dropdown-item px-3" href="#">한국인</a></li>
                  <li><a class="dropdown-item px-3" href="#">Española</a></li>
                  <li><a class="dropdown-item px-3" href="#">Português</a></li>
                </ul>
              </div>

              <!-- Activity Dropdown -->
              <button type="button" class="btn btn-sm btn-text btn-square" aria-haspopup="dialog" aria-expanded="false" aria-controls="activity-drawer" data-overlay="#activity-drawer">
                <span class="icon-[tabler--activity] qmuz4"></span>
              </button>

              <!-- Notification Dropdown -->
              <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:10]">
                <button id="notification-dropdown" type="button" class="dropdown-toggle btn btn-text btn-square btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="hpjlt">
                    <span class="pykeo kn3q0 j6kj2 rounded-full"></span>
                    <span class="icon-[tabler--bell] qmuz4"></span>
                  </span>
                </button>
                <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full kzmwn adede px-3" role="menu" aria-orientation="vertical" aria-labelledby="notification-dropdown" tabindex="-1">
                  <div class="b6erz flex w-full items-center justify-between njdg2 mwpft">
                    <h6 class="text-base-content/50 text-sm vxiam">Notification</h6>
                    <span class="ijn5q bxh1m o1g2m pze98 rounded-full">8 New</span>
                  </div>
                  <div class="flex items-center justify-between">
                    <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                      <button type="button" class="vfeps active-tab:tab-active active font-medium" id="tabs-basic-item-1" data-tab="#tabs-basic-1" aria-controls="tabs-basic-1" role="tab" aria-selected="true">
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
                    <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1">
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

            <!-- Profile Dropdown -->
            <div class="dropdown relative inline-flex [--offset:7]">
              <button id="profile-dropdown" type="button" class="dropdown-toggle burs3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="User Avatar" class="rounded-box">
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1">
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

          <div class="collapse hidden w-full overflow-hidden transition-[height] duration-300 lg:order-3 lg:block lg:w-auto" id="navbar-collapse-heading" aria-labelledby="navbar-collapse">
            <ul class="x737x v85mw lg:menu-horizontal rsqkx cbpaz">
              <!-- Flyonui -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-flyonui" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 dropdown-open:text-base-content f7zrf" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--settings] size-5 lg:hidden"></span>
                  Flyonui
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 qmuz4 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-flyonui" tabindex="-1">
                  <li>
                    <a class="dropdown-item oeogr" href="#">Account</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Preferences</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Billing</a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">Help Center</a>
                  </li>
                </ul>
              </li>

              <!--  Projects -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-projects" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 dropdown-open:text-base-content f7zrf" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--file] size-5 lg:hidden"></span>
                  Projects
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 qmuz4 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-projects" tabindex="-1">
                  <li><a class="dropdown-item" href="#">Create Project</a></li>
                  <li><a class="dropdown-item" href="#">View Projects</a></li>
                  <li><a class="dropdown-item" href="#">Project Templates</a></li>
                </ul>
              </li>

              <!-- Resources -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-resources" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 dropdown-open:text-base-content f7zrf" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--folders] size-5 lg:hidden"></span>
                  Resources
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 qmuz4 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-resources" tabindex="-1">
                  <li><a class="dropdown-item" href="#">Documentation</a></li>
                  <li><a class="dropdown-item" href="#">Tutorials</a></li>
                  <li><a class="dropdown-item" href="#">Support</a></li>
                  <li><a class="dropdown-item" href="#">References</a></li>
                </ul>
              </li>
            </ul>
          </div>
        </nav>
      </div>
    </div>

    <!-- Activity Drawer Content  -->
    <div id="activity-drawer" class="overlay overlay-open:translate-x-0 vxjzc jbh7e hidden sm:max-w-104" role="dialog" tabindex="-1">
      <div class="a5p6s border-base-content/20 w2qmy p-4">
        <h3 class="eul36 text-base t3mfo">Activity</h3>
        <button type="button" class="btn btn-text btn-circle geut3" aria-label="Close" data-overlay="#activity-drawer" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
      </div>
      <div class="rkt7z cbpaz">
        <ul class="if1r0">
          <!-- Joe Lincoln Activity -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">joe Lincoln</span>
                <span class="text-base-content text-sm">mentioned you in last trends topic</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 border j2be9 mwpft">
                <p class="text-base-content w3dp6 text-sm font-medium">
                  @Flyonui For an expert opinion, check out what Mike has to say on this topic!
                </p>
                <div class="ljn0d e1ers">
                  <input type="text" class="sxihv" placeholder="Reply" id="flyonuiReply">
                  <span class="icon-[tabler--photo] text-base-content/80 q7z0e ms-2 size-4 shrink-0"></span>
                </div>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Sofia -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Sofia">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Sofia</span>
                <span class="text-base-content text-sm">requested feedback on her design.</span>
              </div>
              <p class="text-base-content/50 text-sm">1 Hour ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Jane Perez File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jane Perez">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Jane Perez</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 s7x45 text-sm">3 Hours ago</p>
              <span class="ijn5q bxh1m vnwjt">
                <span class="icon-[tabler--file-type-pdf] text-error"></span>
                invoices.pdf
              </span>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Liam -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Liam">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Liam</span>
                <span class="text-base-content text-sm">has shared a project update.</span>
              </div>
              <p class="text-base-content/50 text-sm">5 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Tyler Hero Design Project -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="Tyler Hero">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Tyler Hero</span>
                <span class="text-base-content text-sm">wants to view your design project</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 flex items-center njdg2 border j2be9 mwpft">
                <div class="nfjpm rmjll">
                  <div class="bg-base-100 text-primary rounded-box size-8 f1870">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/figma-icon.png" alt="avatar">
                  </div>
                </div>
                <span class="text-sm font-medium">Launcher-UIkit.fig</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Denial Invite -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Denial">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Denial</span>
                <span class="text-base-content text-sm">Invite from invite link</span>
              </div>
              <p class="text-base-content/50 text-sm">3 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Leslie Alexander Tags -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Leslie Alexander">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Leslie Alexander</span>
                <span class="text-base-content text-sm">new tags to Web Redesign</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="flex dcvi3">
                <span class="ijn5q bxh1m pze98 o1g2m">Client - Request</span>
                <span class="ijn5q bxh1m ctq8s o1g2m">Figma</span>
                <span class="ijn5q bxh1m vn3pt o1g2m">Redesign</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Miya File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Miya">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Miya</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 text-sm">10 Hours ago</p>
            </div>
          </li>
        </ul>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN CONTENT ---------- -->
    <main class="wpaot w-full owca9 sxihv fbpri">
      <div class="dpzny ip6vv sm:grid-cols-2">
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
    <div class="bg-base-100">
      <footer class="wpaot hg6f0 w-full owca9 rukzz egd50"></footer>
    </div>
    <!-- ---------- END FOOTER CONTENT ---------- -->
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
    <div class="bg-base-100 sticky top-0 at1sq">
      <nav class="hvzi2 wpaot w-full owca9">
        <div class="szonh bglhu">
          <button type="button" class="collapse-toggle btn btn-soft btn-sm btn-square lg:hidden" id="navbar-collapse" aria-expanded="false" aria-controls="navbar-collapse-heading" data-collapse="#navbar-collapse-heading">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>

          <!-- Logo -->
          <div class="flex items-center sly4q">
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
            <h3 class="text-base-content bk5oo fl9z1 max-sm:hidden">FlyonUI</h3>
          </div>
        </div>

        <div class="ktglt items-center ip6vv">
          <div class="flex items-center">
            <!-- Theme Dropdown  -->
            <div class="dropdown relative inline-flex [--offset:24]">
              <button id="dropdown-theme" type="button" class="dropdown-toggle btn btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--sun] girx5"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-theme" tabindex="-1">
                <li>
                  <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Light" value="light">
                </li>
                <li>
                  <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Dark" value="dark">
                </li>
                <li>
                  <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="System" value="default">
                </li>
              </ul>
            </div>

            <!-- Language Dropdown -->
            <div class="dropdown relative inline-flex [--offset:24]">
              <button id="language-dropdown" type="button" class="dropdown-toggle btn btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--language] girx5"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 adede" role="menu" aria-orientation="vertical" aria-labelledby="language-dropdown" tabindex="-1">
                <li><a class="dropdown-item px-3" href="#">English</a></li>
                <li><a class="dropdown-item dropdown-active px-3" href="#">Deutsch</a></li>
                <li><a class="dropdown-item px-3" href="#">한국인</a></li>
                <li><a class="dropdown-item px-3" href="#">Española</a></li>
                <li><a class="dropdown-item px-3" href="#">Português</a></li>
              </ul>
            </div>

            <!-- Activity Dropdown -->
            <button type="button" class="btn btn-text btn-square" aria-haspopup="dialog" aria-expanded="false" aria-controls="activity-drawer" data-overlay="#activity-drawer">
              <span class="icon-[tabler--activity] girx5"></span>
            </button>

            <!-- Notification Dropdown -->
            <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:24]">
              <button id="notification-dropdown" type="button" class="dropdown-toggle btn btn-text btn-square" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="hpjlt">
                  <span class="pykeo kn3q0 j6kj2 rounded-full"></span>
                  <span class="icon-[tabler--bell] girx5"></span>
                </span>
              </button>
              <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full kzmwn adede px-3" role="menu" aria-orientation="vertical" aria-labelledby="notification-dropdown" tabindex="-1">
                <div class="b6erz flex w-full items-center justify-between njdg2 mwpft">
                  <h6 class="text-base-content/50 text-sm vxiam">Notification</h6>
                  <span class="ijn5q bxh1m o1g2m pze98 rounded-full">8 New</span>
                </div>
                <div class="flex items-center justify-between">
                  <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                    <button type="button" class="vfeps active-tab:tab-active active font-medium" id="tabs-basic-item-1" data-tab="#tabs-basic-1" aria-controls="tabs-basic-1" role="tab" aria-selected="true">
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
                  <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1">
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
          <!-- Profile Dropdown -->
          <div class="dropdown relative inline-flex [--offset:21]">
            <button id="profile-dropdown" type="button" class="dropdown-toggle f64fg" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
              <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="User Avatar" class="rounded-full">
            </button>
            <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1">
              <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
                <div class="nfjpm a3rpr">
                  <div class="kqy8v rounded-full">
                    <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="avatar">
                  </div>
                </div>
                <div>
                  <h6 class="text-base-content mb-0.5 t3mfo">Charlotte Anne</h6>
                  <p class="text-base-content/80 font-medium">Influencer</p>
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
      </nav>
      <hr class="border-base-content/20">

      <nav class="hvzi2 wpaot qzwp2 owca9 justify-between max-lg:p-0">
        <div class="collapse hidden w-full overflow-hidden transition-[height] duration-300 max-lg:px-6 max-lg:py-2.5 lg:block" id="navbar-collapse-heading" aria-labelledby="navbar-collapse">
          <div class="flex w-full justify-between ikjxw max-lg:flex-col lg:items-center">
            <ul class="x737x max-lg:menu-sm lg:menu-horizontal rsqkx cbpaz">
              <!-- Dashboard -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-dashboard" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 dropdown-open:text-base-content py-2 font-medium" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--chart-bar] size-5"></span>
                  Dashboard
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-5 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-dashboard" tabindex="-1">
                  <li>
                    <a class="dropdown-item oeogr" href="#">
                      <span class="icon-[tabler--chart-pie] size-5 max-lg:size-4"></span>
                      Analytics
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--shape] size-5 max-lg:size-4"></span>
                      CRM
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--shopping-cart] size-5 max-lg:size-4"></span>
                      eCommerce
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--car] size-5 max-lg:size-4"></span>
                      Logistics
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--book] size-5 max-lg:size-4"></span>
                      Academy
                    </a>
                  </li>
                </ul>
              </li>

              <!-- Tables -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-tables" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 dropdown-open:text-base-content py-2 font-medium" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--table] size-5"></span>
                  Tables
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-5 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-tables" tabindex="-1">
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--layout-grid] size-5 max-lg:size-4"></span>
                      Tables
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--table-row] size-5 max-lg:size-4"></span>
                      DataTables
                    </a>
                  </li>
                </ul>
              </li>

              <!-- Layouts -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-layouts" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 dropdown-open:text-base-content py-2 font-medium" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--layout-sidebar-right] size-5"></span>
                  Layouts
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-5 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-layouts" tabindex="-1">
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--menu-2] size-5 max-lg:size-4"></span>
                      Without menu
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--wand] size-5 max-lg:size-4"></span>
                      Vertical
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--aspect-ratio] size-5 max-lg:size-4"></span>
                      Fluid
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--layout-align-center] size-5 max-lg:size-4"></span>
                      Container
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--square] size-5 max-lg:size-4"></span>
                      Blank
                    </a>
                  </li>
                </ul>
              </li>

              <!-- Pages -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-pages" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 dropdown-open:text-base-content py-2 font-medium" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--file-invoice] size-5"></span>
                  Pages
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-5 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-pages" tabindex="-1">
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--home] size-5 max-lg:size-4"></span>
                      Front Pages
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--user] size-5 max-lg:size-4"></span>
                      User Profile
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--help] size-5 max-lg:size-4"></span>
                      FAQ
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--currency-dollar] size-5 max-lg:size-4"></span>
                      Pricing
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--dots] size-5 max-lg:size-4"></span>
                      Misc
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--lock] size-5 max-lg:size-4"></span>
                      Authentications
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--wand] size-5 max-lg:size-4"></span>
                      Wizard Examples
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--square] size-5 max-lg:size-4"></span>
                      Modal Examples
                    </a>
                  </li>
                </ul>
              </li>

              <!-- Applications -->
              <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
                <button id="dropdown-apps" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 dropdown-open:text-base-content py-2 font-medium" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--smart-home] size-5"></span>
                  Applications
                  <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-5 ciihs duration-300"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-apps" tabindex="-1">
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--mail] size-5 max-lg:size-4"></span>
                      Email
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--message-circle] size-5 max-lg:size-4"></span>
                      Chat
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--calendar-event] size-5 max-lg:size-4"></span>
                      Calendar
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--layout-kanban] size-5 max-lg:size-4"></span>
                      Kanban
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--shopping-cart] size-5 max-lg:size-4"></span>
                      eCommerce
                    </a>
                  </li>
                  <li>
                    <a class="dropdown-item" href="#">
                      <span class="icon-[tabler--book] size-5 max-lg:size-4"></span>
                      Academy
                    </a>
                  </li>
                </ul>
              </li>
            </ul>
            <div class="flex gy7oi items-center sly4q pcdpe">
              <div class="w-full lg:max-w-70">
                <label class="wqwbi rui3g" for="search-input">Find anything</label>
                <input type="text" id="search-input" class="ljn0d" placeholder="Find anything">
              </div>
              <button type="button" class="btn btn-primary btn-square">
                <span class="icon-[tabler--search] girx5"></span>
              </button>
            </div>
          </div>
        </div>
      </nav>
    </div>

    <!-- Activity Drawer Content  -->
    <div id="activity-drawer" class="overlay overlay-open:translate-x-0 vxjzc jbh7e hidden sm:max-w-104" role="dialog" tabindex="-1">
      <div class="a5p6s border-base-content/20 w2qmy p-4">
        <h3 class="eul36 text-base t3mfo">Activity</h3>
        <button type="button" class="btn btn-text btn-circle geut3" aria-label="Close" data-overlay="#activity-drawer" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
      </div>
      <div class="rkt7z cbpaz">
        <ul class="if1r0">
          <!-- Joe Lincoln Activity -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">joe Lincoln</span>
                <span class="text-base-content text-sm">mentioned you in last trends topic</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 border j2be9 mwpft">
                <p class="text-base-content w3dp6 text-sm font-medium">
                  @Flyonui For an expert opinion, check out what Mike has to say on this topic!
                </p>
                <div class="ljn0d e1ers">
                  <input type="text" class="sxihv" placeholder="Reply" id="flyonuiReply">
                  <span class="icon-[tabler--photo] text-base-content/80 q7z0e ms-2 size-4 shrink-0"></span>
                </div>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Sofia -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Sofia">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Sofia</span>
                <span class="text-base-content text-sm">requested feedback on her design.</span>
              </div>
              <p class="text-base-content/50 text-sm">1 Hour ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Jane Perez File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jane Perez">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Jane Perez</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 s7x45 text-sm">3 Hours ago</p>
              <span class="ijn5q bxh1m vnwjt">
                <span class="icon-[tabler--file-type-pdf] text-error"></span>
                invoices.pdf
              </span>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Liam -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Liam">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Liam</span>
                <span class="text-base-content text-sm">has shared a project update.</span>
              </div>
              <p class="text-base-content/50 text-sm">5 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Tyler Hero Design Project -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="Tyler Hero">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Tyler Hero</span>
                <span class="text-base-content text-sm">wants to view your design project</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 flex items-center njdg2 border j2be9 mwpft">
                <div class="nfjpm rmjll">
                  <div class="bg-base-100 text-primary rounded-box size-8 f1870">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/figma-icon.png" alt="avatar">
                  </div>
                </div>
                <span class="text-sm font-medium">Launcher-UIkit.fig</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Denial Invite -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Denial">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Denial</span>
                <span class="text-base-content text-sm">Invite from invite link</span>
              </div>
              <p class="text-base-content/50 text-sm">3 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Leslie Alexander Tags -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Leslie Alexander">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Leslie Alexander</span>
                <span class="text-base-content text-sm">new tags to Web Redesign</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="flex dcvi3">
                <span class="ijn5q bxh1m pze98 o1g2m">Client - Request</span>
                <span class="ijn5q bxh1m ctq8s o1g2m">Figma</span>
                <span class="ijn5q bxh1m vn3pt o1g2m">Redesign</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Miya File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Miya">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Miya</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 text-sm">10 Hours ago</p>
            </div>
          </li>
        </ul>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN CONTENT ---------- -->
    <main class="wpaot w-full owca9 sxihv fbpri">
      <div class="dpzny ip6vv sm:grid-cols-2">
        <div class="zq390 hono0 w-full sm:col-span-2">
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
    <div class="bg-base-100">
      <footer class="wpaot hg6f0 w-full owca9 rukzz egd50"></footer>
    </div>
    <!-- ---------- END FOOTER CONTENT ---------- -->
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
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc klzl7 lg:rounded-box wjz3b e4bmm hidden n85ea [--auto-close:lg] sm:w-75 lg:z-10 lg:my-auto lg:block lg:max-h-[calc(100dvh-48px)] lg:translate-x-6 rtl:lg:-translate-x-6" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z n85ea fbpri">
        <button type="button" class="btn btn-text btn-square geut3 absolute koirh s7loe sm:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
        <div class="border-base-content/20 rounded-box cy2ft n85ea border"></div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->

    <div class="z-1 flex jz3o6 justify-between o63tj fbpri lg:ms-81">
      <!-- ---------- HEADER ---------- -->
      <nav class="hvzi2 justify-between bglhu m233p eghwv vj77y i7h5k">
        <div class="flex items-center bglhu">
          <button type="button" class="btn btn-soft btn-square btn-sm lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>

          <!-- Logo -->
          <div class="flex jz3o6 max-sm:hidden">
            <h3 class="c9rvi t3mfo lmn89">Hello John!</h3>
            <p class="text-sm u7qxt">Welcome back to dashboard</p>
          </div>
        </div>

        <!-- Search -->
        <button type="button" class="rounded-field flex tqks9 bkm03 items-center eovr6 f6hal px-3 max-md:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="search-modal" data-overlay="#search-modal">
          <span class="icon-[tabler--search] size-5 lmn89"></span>
          <span class="lmn89">Search here...</span>
        </button>

        <div class="flex items-center ip6vv">
          <div class="flex items-center">
            <!-- Search Btn For Small Screen  -->
            <button type="button" class="btn btn-text btn-sm btn-square [--btn-color:#fff] md:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="search-modal" data-overlay="#search-modal">
              <span class="icon-[tabler--search] qmuz4"></span>
            </button>

            <!-- Theme Dropdown  -->
            <div class="dropdown relative inline-flex [--offset:24]">
              <button id="dropdown-theme" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text [--btn-color:#fff]" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--sun] qmuz4"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-theme" tabindex="-1">
                <li>
                  <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Light" value="light">
                </li>
                <li>
                  <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Dark" value="dark">
                </li>
                <li>
                  <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="System" value="default">
                </li>
              </ul>
            </div>

            <!-- Language Dropdown -->
            <div class="dropdown relative inline-flex [--offset:24]">
              <button id="language-dropdown" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text [--btn-color:#fff]" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--language] qmuz4"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 adede" role="menu" aria-orientation="vertical" aria-labelledby="language-dropdown" tabindex="-1">
                <li><a class="dropdown-item px-3" href="#">English</a></li>
                <li><a class="dropdown-item dropdown-active px-3" href="#">Deutsch</a></li>
                <li><a class="dropdown-item px-3" href="#">한국인</a></li>
                <li><a class="dropdown-item px-3" href="#">Española</a></li>
                <li><a class="dropdown-item px-3" href="#">Português</a></li>
              </ul>
            </div>

            <!-- Activity Dropdown -->
            <button type="button" class="btn btn-sm btn-text btn-square [--btn-color:#fff]" aria-haspopup="dialog" aria-expanded="false" aria-controls="activity-drawer" data-overlay="#activity-drawer">
              <span class="icon-[tabler--activity] qmuz4"></span>
            </button>

            <!-- Notification Dropdown -->
            <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:24]">
              <button id="notification-dropdown" type="button" class="dropdown-toggle btn btn-text btn-square btn-sm [--btn-color:#fff]" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="hpjlt">
                  <span class="pykeo kn3q0 j6kj2 rounded-full"></span>
                  <span class="icon-[tabler--bell] qmuz4"></span>
                </span>
              </button>
              <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full kzmwn adede px-3" role="menu" aria-orientation="vertical" aria-labelledby="notification-dropdown" tabindex="-1">
                <div class="b6erz flex w-full items-center justify-between njdg2 mwpft">
                  <h6 class="text-base-content/50 text-sm vxiam">Notification</h6>
                  <span class="ijn5q bxh1m o1g2m pze98 rounded-full">8 New</span>
                </div>
                <div class="flex items-center justify-between">
                  <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                    <button type="button" class="vfeps active-tab:tab-active active font-medium" id="tabs-basic-item-1" data-tab="#tabs-basic-1" aria-controls="tabs-basic-1" role="tab" aria-selected="true">
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
                  <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1">
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

          <!-- Profile Dropdown -->
          <div class="dropdown relative inline-flex [--offset:21]">
            <button id="profile-dropdown" type="button" class="dropdown-toggle burs3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
              <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="User Avatar" class="rounded-box">
            </button>
            <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1">
              <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
                <div class="nfjpm a3rpr">
                  <div class="kqy8v rounded-full">
                    <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                  </div>
                </div>
                <div>
                  <h6 class="text-base-content mb-0.5 t3mfo">Charlotte Anne</h6>
                  <p class="text-base-content/80 font-medium">Influencer</p>
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
      </nav>
      <!-- ---------- END HEADER ---------- -->

      <!-- ---------- MAIN CONTENT ---------- -->
      <main class="e6ynr">
        <div class="zqxh1 dpzny wfsyj ip6vv md:grid-cols-3">
          <div class="zq390 xbygq w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 xbygq w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
          <div class="zq390 xbygq w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
        <div class="dpzny wfsyj ip6vv">
          <div class="zq390 tgy6u w-full">
            <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
          </div>
        </div>
      </main>
      <!-- ---------- END MAIN CONTENT ---------- -->

      <!-- ---------- FOOTER CONTENT ---------- -->
      <footer class="bg-base-100 rounded-box d50ic eckwz shadow-md"></footer>
      <!-- ---------- END FOOTER CONTENT ---------- -->
    </div>

    <!-- Search Dropdown Content  -->
    <div id="search-modal" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 hidden" role="dialog" tabindex="-1">
      <div class="dthlq w-full zr8jv">
        <div class="pbhw6 j5lbz nwdq3">
          <!-- SearchBox -->
          <div class="m1ukj border-base-content/20 abnz9 px-3 py-2">
            <div class="ljn0d o22n0 pelb3 eghwv">
              <span class="icon-[tabler--search] text-base-content/80 q7z0e me-2 size-5 shrink-0"></span>
              <input type="search" class="sxihv" placeholder="Search here..." id="kbdInput">
              <label class="rui3g" for="kbdInput">Search</label>
            </div>
          </div>

          <nav class="hhn76 vt6q1 py-2" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
            <button type="button" class="vfeps active-tab:tab-active active w-full font-medium" id="search-tabs-item-1" data-tab="#search-tabs-1" aria-controls="search-tabs-1" role="tab" aria-selected="true">
              All
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-2" data-tab="#search-tabs-2" aria-controls="search-tabs-2" role="tab" aria-selected="false">
              Pages
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-3" data-tab="#search-tabs-3" aria-controls="search-tabs-3" role="tab" aria-selected="false">
              Integration
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-4" data-tab="#search-tabs-4" aria-controls="search-tabs-4" role="tab" aria-selected="false">
              Users
            </button>
          </nav>
          <!-- SearchBox Modal Body -->
          <div class="fpegk overflow-y-auto lg:max-h-121">
            <!-- SearchBox All Modal Body -->
            <div id="search-tabs-1" role="tabpanel" aria-labelledby="search-tabs-item-1">
              <!-- Pages Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Pages</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- Interaction Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Interaction</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- User Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">User</div>
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown1" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown1" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown2" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown2" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Pages Modal Body -->
            <div id="search-tabs-2" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-2">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Integration Modal Body -->
            <div id="search-tabs-3" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-3">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Users Modal Body -->
            <div id="search-tabs-4" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-4">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown3" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown3" tabindex="-1">
                            <li><button class="dropdown-item px-2">View More</button></li>
                            <li><button class="dropdown-item px-2">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown4" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown4" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>
          </div>
          <!-- Footer Commands -->
          <div class="w3jfd border-base-content/20 text-base-content/50 njdg2 ia8ws egd50 max-sm:hidden">
            <div class="flex sxihv items-center bglhu text-sm">
              <kbd class="b2fu4 an53u">esc</kbd>
              <span>To close</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-back] size-4"></span></kbd>
              <span>To Select</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-up] size-4"></span></kbd>
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-down] size-4"></span></kbd>
              <span>To Navigate</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Activity Drawer Content  -->
    <div id="activity-drawer" class="overlay overlay-open:translate-x-0 vxjzc jbh7e hidden sm:max-w-104" role="dialog" tabindex="-1">
      <div class="a5p6s border-base-content/20 w2qmy p-4">
        <h3 class="eul36 text-base t3mfo">Activity</h3>
        <button type="button" class="btn btn-text btn-circle geut3" aria-label="Close" data-overlay="#activity-drawer" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
      </div>
      <div class="rkt7z cbpaz">
        <ul class="if1r0">
          <!-- Joe Lincoln Activity -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">joe Lincoln</span>
                <span class="text-base-content text-sm">mentioned you in last trends topic</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 border j2be9 mwpft">
                <p class="text-base-content w3dp6 text-sm font-medium">
                  @Flyonui For an expert opinion, check out what Mike has to say on this topic!
                </p>
                <div class="ljn0d e1ers">
                  <input type="text" class="sxihv" placeholder="Reply" id="flyonuiReply">
                  <span class="icon-[tabler--photo] text-base-content/80 q7z0e ms-2 size-4 shrink-0"></span>
                </div>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Sofia -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Sofia">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Sofia</span>
                <span class="text-base-content text-sm">requested feedback on her design.</span>
              </div>
              <p class="text-base-content/50 text-sm">1 Hour ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Jane Perez File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jane Perez">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Jane Perez</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 s7x45 text-sm">3 Hours ago</p>
              <span class="ijn5q bxh1m vnwjt">
                <span class="icon-[tabler--file-type-pdf] text-error"></span>
                invoices.pdf
              </span>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Liam -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Liam">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Liam</span>
                <span class="text-base-content text-sm">has shared a project update.</span>
              </div>
              <p class="text-base-content/50 text-sm">5 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Tyler Hero Design Project -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="Tyler Hero">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Tyler Hero</span>
                <span class="text-base-content text-sm">wants to view your design project</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 flex items-center njdg2 border j2be9 mwpft">
                <div class="nfjpm rmjll">
                  <div class="bg-base-100 text-primary rounded-box size-8 f1870">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/figma-icon.png" alt="avatar">
                  </div>
                </div>
                <span class="text-sm font-medium">Launcher-UIkit.fig</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Denial Invite -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Denial">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Denial</span>
                <span class="text-base-content text-sm">Invite from invite link</span>
              </div>
              <p class="text-base-content/50 text-sm">3 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Leslie Alexander Tags -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Leslie Alexander">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Leslie Alexander</span>
                <span class="text-base-content text-sm">new tags to Web Redesign</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="flex dcvi3">
                <span class="ijn5q bxh1m pze98 o1g2m">Client - Request</span>
                <span class="ijn5q bxh1m ctq8s o1g2m">Figma</span>
                <span class="ijn5q bxh1m vn3pt o1g2m">Redesign</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Miya File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Miya">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Miya</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 text-sm">10 Hours ago</p>
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
  <div class="dhabr flex min-h-screen jz3o6">
    <!-- ---------- HEADER ---------- -->
    <div class="bg-base-100 sticky top-0 r1xta">
      <nav class="hvzi2 wpaot qzwp2 owca9 mnhlk items-center zvd9e nt63s xl:gap-x-10">
        <div class="flex bglhu lg:order-1">
          <button type="button" class="collapse-toggle btn btn-soft btn-square btn-sm lg:hidden" id="navbar-collapse" aria-expanded="false" aria-controls="navbar-collapse-heading" data-collapse="#navbar-collapse-heading">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>

          <!-- Logo -->
          <div class="flex items-center sly4q">
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
            <h3 class="text-base-content bk5oo fl9z1 max-sm:hidden">File Manager</h3>
          </div>
        </div>

        <div class="flex sxihv items-center edy4p ip6vv lg:order-4">
          <div class="flex items-center">
            <!-- Search Button  -->
            <button type="button" class="btn btn-text btn-sm btn-square" aria-haspopup="dialog" aria-expanded="false" aria-controls="search-modal" data-overlay="#search-modal">
              <span class="icon-[tabler--search] qmuz4"></span>
            </button>

            <!-- Theme Dropdown  -->
            <div class="dropdown relative inline-flex [--offset:24]">
              <button id="dropdown-theme" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--sun] qmuz4"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-theme" tabindex="-1">
                <li>
                  <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Light" value="light">
                </li>
                <li>
                  <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Dark" value="dark">
                </li>
                <li>
                  <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="System" value="default">
                </li>
              </ul>
            </div>

            <!-- Language Dropdown -->
            <div class="dropdown relative inline-flex [--offset:24]">
              <button id="language-dropdown" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--language] qmuz4"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 adede" role="menu" aria-orientation="vertical" aria-labelledby="language-dropdown" tabindex="-1">
                <li><a class="dropdown-item px-3" href="#">English</a></li>
                <li><a class="dropdown-item dropdown-active px-3" href="#">Deutsch</a></li>
                <li><a class="dropdown-item px-3" href="#">한국인</a></li>
                <li><a class="dropdown-item px-3" href="#">Española</a></li>
                <li><a class="dropdown-item px-3" href="#">Português</a></li>
              </ul>
            </div>

            <!-- Activity Dropdown -->
            <button type="button" class="btn btn-sm btn-text btn-square" aria-haspopup="dialog" aria-expanded="false" aria-controls="activity-drawer" data-overlay="#activity-drawer">
              <span class="icon-[tabler--activity] qmuz4"></span>
            </button>

            <!-- Notification Dropdown -->
            <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:24]">
              <button id="notification-dropdown" type="button" class="dropdown-toggle btn btn-text btn-square btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="hpjlt">
                  <span class="pykeo kn3q0 j6kj2 rounded-full"></span>
                  <span class="icon-[tabler--bell] qmuz4"></span>
                </span>
              </button>
              <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full kzmwn adede px-3" role="menu" aria-orientation="vertical" aria-labelledby="notification-dropdown" tabindex="-1">
                <div class="b6erz flex w-full items-center justify-between njdg2 mwpft">
                  <h6 class="text-base-content/50 text-sm vxiam">Notification</h6>
                  <span class="ijn5q bxh1m o1g2m pze98 rounded-full">8 New</span>
                </div>
                <div class="flex items-center justify-between">
                  <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                    <button type="button" class="vfeps active-tab:tab-active active font-medium" id="tabs-basic-item-1" data-tab="#tabs-basic-1" aria-controls="tabs-basic-1" role="tab" aria-selected="true">
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
                  <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1">
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

          <!-- Profile Dropdown -->
          <div class="dropdown relative inline-flex [--offset:21]">
            <button id="profile-dropdown" type="button" class="dropdown-toggle flex items-center sly4q" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
              <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="User Avatar" class="rounded-box lt1t7">
              <span class="flex jz3o6 ao5al max-sm:hidden">
                <span class="t3mfo">Phil Ohme</span>
                <span class="text-base-content/50 text-sm">ID 34790</span>
              </span>
            </button>
            <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1">
              <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
                <div class="nfjpm a3rpr">
                  <div class="kqy8v rounded-full">
                    <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                  </div>
                </div>
                <div>
                  <h6 class="text-base-content mb-0.5 t3mfo">Phil Ohme</h6>
                  <p class="text-base-content/80 font-medium">Influencer</p>
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

        <div class="collapse hidden w-full sxihv overflow-hidden transition-[height] duration-300 lg:order-3 lg:block lg:w-fit lg:basis-auto" id="navbar-collapse-heading" aria-labelledby="navbar-collapse">
          <ul class="x737x lg:menu-horizontal rsqkx cbpaz">
            <!-- Files -->
            <li>
              <a href="#" class="py-2">
                <span class="icon-[tabler--chart-bar] size-5"></span>
                Dashboard
              </a>
            </li>

            <!--  File Manager -->
            <li class="dropdown relative inline-flex [--adaptive:none] [--offset:15] max-lg:[--strategy:static] lg:inline-block lg:[--adaptive:adaptive] lg:[--trigger:hover]">
              <button id="dropdown-file" type="button" class="dropdown-toggle dropdown-open:bg-base-content/10 dropdown-open:text-base-content py-2" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--file-invoice] size-5"></span>
                File Manager
                <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-5 ciihs duration-300"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 max-lg:before:bg-base-content/10 hidden before:absolute before:start-0 before:top-3 before:w-px max-lg:ms-4 max-lg:mt-1 max-lg:p-0 max-lg:ps-2 max-lg:shadow-none max-lg:duration-100 max-lg:before:bottom-3 lg:before:-top-4 lg:before:h-5 lg:before:w-full" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-file" tabindex="-1">
                <li>
                  <a class="dropdown-item oeogr" href="#">My Files</a>
                </li>
                <li>
                  <a class="dropdown-item" href="#">Recent Uploads</a>
                </li>
                <li>
                  <a class="dropdown-item" href="#">Starred</a>
                </li>
                <li>
                  <a class="dropdown-item" href="#">Recent Activity</a>
                </li>
                <li>
                  <a class="dropdown-item" href="#">Trash</a>
                </li>
                <li>
                  <a class="dropdown-item" href="#">File Settings</a>
                </li>
              </ul>
            </li>

            <!-- Storage -->
            <li>
              <a href="#" class="py-2">
                <span class="icon-[tabler--folder] size-5"></span>
                Storage
              </a>
            </li>
          </ul>
        </div>
      </nav>

      <hr class="border-base-content/20">

      <nav class="hvzi2 wpaot qzwp2 owca9 mnhlk justify-between zvd9e nt63s">
        <div class="ntokn">
          <ul class="rxznq text-sm">
            <li>
              <a href="#"><span class="icon-[tabler--home] qmuz4 shrink-0"></span></a>
            </li>
            <li class="hmm07 rtl:-rotate-[40deg]">/</li>
            <li>
              <a href="#">File Manager</a>
            </li>
            <li class="hmm07 rtl:-rotate-[40deg]">/</li>
            <li aria-current="page">My Files</li>
          </ul>
        </div>

        <div class="flex items-center dcvi3">
          <label class="btn btn-soft btn-sm has-checked:btn-primary">
            <input type="radio" name="radio-15" class="d6aiv hidden">
            Year
          </label>
          <label class="btn btn-soft btn-sm has-checked:btn-primary">
            <input type="radio" name="radio-15" class="d6aiv hidden" checked="">
            Month
          </label>
          <label class="btn btn-soft btn-sm has-checked:btn-primary">
            <input type="radio" name="radio-15" class="d6aiv hidden">
            Day
          </label>
          <label class="btn btn-soft btn-sm has-checked:btn-primary">
            <input type="radio" name="radio-15" class="d6aiv hidden">
            Today
          </label>
        </div>
      </nav>
    </div>

    <!-- Search Dropdown Content  -->
    <div id="search-modal" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 hidden" role="dialog" tabindex="-1">
      <div class="dthlq w-full zr8jv">
        <div class="pbhw6 j5lbz nwdq3">
          <!-- SearchBox -->
          <div class="m1ukj border-base-content/20 abnz9 px-3 py-2">
            <div class="ljn0d o22n0 pelb3 eghwv">
              <span class="icon-[tabler--search] text-base-content/80 q7z0e me-2 size-5 shrink-0"></span>
              <input type="search" class="sxihv" placeholder="Search here..." id="kbdInput">
              <label class="rui3g" for="kbdInput">Search</label>
            </div>
          </div>

          <nav class="hhn76 vt6q1 py-2" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
            <button type="button" class="vfeps active-tab:tab-active active w-full font-medium" id="search-tabs-item-1" data-tab="#search-tabs-1" aria-controls="search-tabs-1" role="tab" aria-selected="true">
              All
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-2" data-tab="#search-tabs-2" aria-controls="search-tabs-2" role="tab" aria-selected="false">
              Pages
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-3" data-tab="#search-tabs-3" aria-controls="search-tabs-3" role="tab" aria-selected="false">
              Integration
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-4" data-tab="#search-tabs-4" aria-controls="search-tabs-4" role="tab" aria-selected="false">
              Users
            </button>
          </nav>
          <!-- SearchBox Modal Body -->
          <div class="fpegk overflow-y-auto lg:max-h-121">
            <!-- SearchBox All Modal Body -->
            <div id="search-tabs-1" role="tabpanel" aria-labelledby="search-tabs-item-1">
              <!-- Pages Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Pages</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- Interaction Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Interaction</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- User Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">User</div>
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown1" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown1" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown2" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown2" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Pages Modal Body -->
            <div id="search-tabs-2" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-2">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Integration Modal Body -->
            <div id="search-tabs-3" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-3">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Users Modal Body -->
            <div id="search-tabs-4" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-4">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown3" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown3" tabindex="-1">
                            <li><button class="dropdown-item px-2">View More</button></li>
                            <li><button class="dropdown-item px-2">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown4" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown4" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>
          </div>
          <!-- Footer Commands -->
          <div class="w3jfd border-base-content/20 text-base-content/50 njdg2 ia8ws egd50 max-sm:hidden">
            <div class="flex sxihv items-center bglhu text-sm">
              <kbd class="b2fu4 an53u">esc</kbd>
              <span>To close</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-back] size-4"></span></kbd>
              <span>To Select</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-up] size-4"></span></kbd>
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-down] size-4"></span></kbd>
              <span>To Navigate</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Activity Drawer Content  -->
    <div id="activity-drawer" class="overlay overlay-open:translate-x-0 vxjzc jbh7e hidden sm:max-w-104" role="dialog" tabindex="-1">
      <div class="a5p6s border-base-content/20 w2qmy p-4">
        <h3 class="eul36 text-base t3mfo">Activity</h3>
        <button type="button" class="btn btn-text btn-circle geut3" aria-label="Close" data-overlay="#activity-drawer" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
      </div>
      <div class="rkt7z cbpaz">
        <ul class="if1r0">
          <!-- Joe Lincoln Activity -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">joe Lincoln</span>
                <span class="text-base-content text-sm">mentioned you in last trends topic</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 border j2be9 mwpft">
                <p class="text-base-content w3dp6 text-sm font-medium">
                  @Flyonui For an expert opinion, check out what Mike has to say on this topic!
                </p>
                <div class="ljn0d e1ers">
                  <input type="text" class="sxihv" placeholder="Reply" id="flyonuiReply">
                  <span class="icon-[tabler--photo] text-base-content/80 q7z0e ms-2 size-4 shrink-0"></span>
                </div>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Sofia -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Sofia">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Sofia</span>
                <span class="text-base-content text-sm">requested feedback on her design.</span>
              </div>
              <p class="text-base-content/50 text-sm">1 Hour ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Jane Perez File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jane Perez">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Jane Perez</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 s7x45 text-sm">3 Hours ago</p>
              <span class="ijn5q bxh1m vnwjt">
                <span class="icon-[tabler--file-type-pdf] text-error"></span>
                invoices.pdf
              </span>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Liam -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Liam">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Liam</span>
                <span class="text-base-content text-sm">has shared a project update.</span>
              </div>
              <p class="text-base-content/50 text-sm">5 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Tyler Hero Design Project -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="Tyler Hero">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Tyler Hero</span>
                <span class="text-base-content text-sm">wants to view your design project</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 flex items-center njdg2 border j2be9 mwpft">
                <div class="nfjpm rmjll">
                  <div class="bg-base-100 text-primary rounded-box size-8 f1870">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/figma-icon.png" alt="avatar">
                  </div>
                </div>
                <span class="text-sm font-medium">Launcher-UIkit.fig</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Denial Invite -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Denial">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Denial</span>
                <span class="text-base-content text-sm">Invite from invite link</span>
              </div>
              <p class="text-base-content/50 text-sm">3 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Leslie Alexander Tags -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Leslie Alexander">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Leslie Alexander</span>
                <span class="text-base-content text-sm">new tags to Web Redesign</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="flex dcvi3">
                <span class="ijn5q bxh1m pze98 o1g2m">Client - Request</span>
                <span class="ijn5q bxh1m ctq8s o1g2m">Figma</span>
                <span class="ijn5q bxh1m vn3pt o1g2m">Redesign</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Miya File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Miya">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Miya</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 text-sm">10 Hours ago</p>
            </div>
          </li>
        </ul>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN CONTENT ---------- -->
    <main class="wpaot w-full owca9 sxihv fbpri">
      <div class="dpzny ip6vv">
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
    <div class="bg-base-100">
      <footer class="wpaot hg6f0 w-full owca9 rukzz egd50"></footer>
    </div>
    <!-- ---------- END FOOTER CONTENT ---------- -->
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
    <div class="bg-base-100 d50ic sticky top-0 at1sq zw50f">
      <nav class="hvzi2 wpaot qzwp2 owca9 justify-between py-2">
        <div class="flex items-center bglhu">
          <button type="button" class="collapse-toggle btn btn-soft btn-square btn-sm lg:hidden" id="navbar-collapse" aria-expanded="false" aria-controls="navbar-collapse-heading" data-collapse="#navbar-collapse-heading">
            <span class="icon-[tabler--menu-2] qmuz4"></span>
          </button>
          <!-- Logo -->
          <div class="flex items-center sly4q">
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
            <h3 class="text-base-content bk5oo t3mfo max-sm:hidden">Automobile</h3>
          </div>
        </div>

        <!-- Search -->
        <button type="button" class="rounded-field border-base-content/40 flex io745 fyijd items-center rsqkx border ee2rm text-sm max-lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="search-modal" data-overlay="#search-modal">
          <span class="icon-[tabler--search] text-base-content size-4"></span>
          <span class="text-base-content/50">Search services</span>
        </button>

        <div class="flex items-center ip6vv">
          <div class="flex items-center">
            <!-- Search Btn For Small Screen  -->
            <button type="button" class="btn btn-text btn-sm btn-square lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="search-modal" data-overlay="#search-modal">
              <span class="icon-[tabler--search] qmuz4"></span>
            </button>

            <!-- Theme Dropdown  -->
            <div class="dropdown relative inline-flex [--offset:24]">
              <button id="dropdown-theme" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--sun] qmuz4"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-theme" tabindex="-1">
                <li>
                  <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Light" value="light">
                </li>
                <li>
                  <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Dark" value="dark">
                </li>
                <li>
                  <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="System" value="default">
                </li>
              </ul>
            </div>

            <!-- Language Dropdown -->
            <div class="dropdown relative inline-flex [--offset:24]">
              <button id="language-dropdown" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="icon-[tabler--language] qmuz4"></span>
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 adede" role="menu" aria-orientation="vertical" aria-labelledby="language-dropdown" tabindex="-1">
                <li><a class="dropdown-item px-3" href="#">English</a></li>
                <li><a class="dropdown-item dropdown-active px-3" href="#">Deutsch</a></li>
                <li><a class="dropdown-item px-3" href="#">한국인</a></li>
                <li><a class="dropdown-item px-3" href="#">Española</a></li>
                <li><a class="dropdown-item px-3" href="#">Português</a></li>
              </ul>
            </div>

            <!-- Activity Dropdown -->
            <button type="button" class="btn btn-sm btn-text btn-square" aria-haspopup="dialog" aria-expanded="false" aria-controls="activity-drawer" data-overlay="#activity-drawer">
              <span class="icon-[tabler--activity] qmuz4"></span>
            </button>

            <!-- Notification Dropdown -->
            <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:24]">
              <button id="notification-dropdown" type="button" class="dropdown-toggle btn btn-text btn-square btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <span class="hpjlt">
                  <span class="pykeo kn3q0 j6kj2 rounded-full"></span>
                  <span class="icon-[tabler--bell] qmuz4"></span>
                </span>
              </button>
              <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full kzmwn adede px-3" role="menu" aria-orientation="vertical" aria-labelledby="notification-dropdown" tabindex="-1">
                <div class="b6erz flex w-full items-center justify-between njdg2 mwpft">
                  <h6 class="text-base-content/50 text-sm vxiam">Notification</h6>
                  <span class="ijn5q bxh1m o1g2m pze98 rounded-full">8 New</span>
                </div>
                <div class="flex items-center justify-between">
                  <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                    <button type="button" class="vfeps active-tab:tab-active active font-medium" id="tabs-basic-item-1" data-tab="#tabs-basic-1" aria-controls="tabs-basic-1" role="tab" aria-selected="true">
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
                  <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1">
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

          <!-- Profile Dropdown -->
          <div class="dropdown relative inline-flex [--offset:21]">
            <button id="profile-dropdown" type="button" class="dropdown-toggle flex items-center sly4q" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
              <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="User Avatar" class="rounded-box lt1t7">
              <span class="flex jz3o6 ao5al max-sm:hidden">
                <span class="t3mfo">Phil Ohme</span>
                <span class="text-base-content/50 text-sm">ID 34790</span>
              </span>
            </button>
            <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1">
              <li class="m67xf mb-1 njdg2 a7thv iq08s j5f89">
                <div class="nfjpm a3rpr">
                  <div class="kqy8v rounded-full">
                    <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                  </div>
                </div>
                <div>
                  <h6 class="text-base-content mb-0.5 t3mfo">Phil Ohme</h6>
                  <p class="text-base-content/80 font-medium">Influencer</p>
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
      </nav>

      <hr class="border-base-content/20 max-lg:hidden">

      <nav class="hvzi2 wpaot qzwp2 owca9 justify-between py-2 max-lg:p-0">
        <div class="collapse hidden h8emw overflow-hidden transition-[height] duration-300 max-lg:w-full max-lg:px-6 max-lg:py-2.5 lg:block" id="navbar-collapse-heading" aria-labelledby="navbar-collapse">
          <ul class="x737x v85mw lg:menu-horizontal rsqkx cbpaz">
            <!-- Dashboard -->
            <li>
              <a href="#" class="px-2">
                <span class="icon-[tabler--chart-bar] qmuz4"></span>
                Dashboard
              </a>
            </li>

            <!-- Booking -->
            <li>
              <a href="#" class="px-2">
                <span class="icon-[tabler--calendar-stats] qmuz4"></span>
                Booking
              </a>
            </li>

            <!-- Sell Cars -->
            <li>
              <a href="#" class="oeogr px-2">
                <span class="icon-[tabler--car] qmuz4"></span>
                Sell Cars
              </a>
            </li>

            <!-- Buy Cars -->
            <li>
              <a href="#" class="px-2">
                <span class="icon-[tabler--car] qmuz4"></span>
                Buy Cars
              </a>
            </li>

            <!-- Services -->
            <li>
              <a href="#" class="px-2">
                <span class="icon-[tabler--tool] qmuz4"></span>
                Services
              </a>
            </li>

            <!-- Settings -->
            <li>
              <a href="#" class="px-2">
                <span class="icon-[tabler--settings] qmuz4"></span>
                Settings
              </a>
            </li>
          </ul>
        </div>
      </nav>

      <hr class="border-base-content/20">

      <nav class="hvzi2 wpaot qzwp2 owca9 mnhlk justify-between bglhu py-2">
        <div class="ntokn">
          <ul class="rxznq text-sm">
            <li>
              <a href="#">Home</a>
            </li>
            <li class="hmm07 rtl:rotate-180">
              <span class="icon-[tabler--chevron-right] size-4"></span>
            </li>
            <li>
              <a href="#">Sell Car</a>
            </li>
            <li class="hmm07 rtl:rotate-180">
              <span class="icon-[tabler--chevron-right] size-4"></span>
            </li>
            <li aria-current="page">List</li>
          </ul>
        </div>

        <div class="flex shrink-0 njdg2">
          <a href="#" class="btn btn-sm btn-primary">
            <span>Buy Cars</span>
            <span class="icon-[tabler--car] size-4"></span>
          </a>
          <a href="#" class="btn btn-sm sq4op">
            <span>Book Appointment</span>
            <span class="icon-[tabler--calendar-time] size-4"></span>
          </a>
        </div>
      </nav>
    </div>

    <!-- Search Dropdown Content  -->
    <div id="search-modal" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 hidden" role="dialog" tabindex="-1">
      <div class="dthlq w-full zr8jv">
        <div class="pbhw6 j5lbz nwdq3">
          <!-- SearchBox -->
          <div class="m1ukj border-base-content/20 abnz9 px-3 py-2">
            <div class="ljn0d o22n0 pelb3 eghwv">
              <span class="icon-[tabler--search] text-base-content/80 q7z0e me-2 size-5 shrink-0"></span>
              <input type="search" class="sxihv" placeholder="Search here..." id="kbdInput">
              <label class="rui3g" for="kbdInput">Search</label>
            </div>
          </div>

          <nav class="hhn76 vt6q1 py-2" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
            <button type="button" class="vfeps active-tab:tab-active active w-full font-medium" id="search-tabs-item-1" data-tab="#search-tabs-1" aria-controls="search-tabs-1" role="tab" aria-selected="true">
              All
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-2" data-tab="#search-tabs-2" aria-controls="search-tabs-2" role="tab" aria-selected="false">
              Pages
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-3" data-tab="#search-tabs-3" aria-controls="search-tabs-3" role="tab" aria-selected="false">
              Integration
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-4" data-tab="#search-tabs-4" aria-controls="search-tabs-4" role="tab" aria-selected="false">
              Users
            </button>
          </nav>
          <!-- SearchBox Modal Body -->
          <div class="fpegk overflow-y-auto lg:max-h-121">
            <!-- SearchBox All Modal Body -->
            <div id="search-tabs-1" role="tabpanel" aria-labelledby="search-tabs-item-1">
              <!-- Pages Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Pages</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- Interaction Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Interaction</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- User Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">User</div>
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown1" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown1" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown2" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown2" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Pages Modal Body -->
            <div id="search-tabs-2" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-2">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Integration Modal Body -->
            <div id="search-tabs-3" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-3">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Users Modal Body -->
            <div id="search-tabs-4" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-4">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown3" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown3" tabindex="-1">
                            <li><button class="dropdown-item px-2">View More</button></li>
                            <li><button class="dropdown-item px-2">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown4" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown4" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>
          </div>
          <!-- Footer Commands -->
          <div class="w3jfd border-base-content/20 text-base-content/50 njdg2 ia8ws egd50 max-sm:hidden">
            <div class="flex sxihv items-center bglhu text-sm">
              <kbd class="b2fu4 an53u">esc</kbd>
              <span>To close</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-back] size-4"></span></kbd>
              <span>To Select</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-up] size-4"></span></kbd>
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-down] size-4"></span></kbd>
              <span>To Navigate</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Activity Drawer Content  -->
    <div id="activity-drawer" class="overlay overlay-open:translate-x-0 vxjzc jbh7e hidden sm:max-w-104" role="dialog" tabindex="-1">
      <div class="a5p6s border-base-content/20 w2qmy p-4">
        <h3 class="eul36 text-base t3mfo">Activity</h3>
        <button type="button" class="btn btn-text btn-circle geut3" aria-label="Close" data-overlay="#activity-drawer" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
      </div>
      <div class="rkt7z cbpaz">
        <ul class="if1r0">
          <!-- Joe Lincoln Activity -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">joe Lincoln</span>
                <span class="text-base-content text-sm">mentioned you in last trends topic</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 border j2be9 mwpft">
                <p class="text-base-content w3dp6 text-sm font-medium">
                  @Flyonui For an expert opinion, check out what Mike has to say on this topic!
                </p>
                <div class="ljn0d e1ers">
                  <input type="text" class="sxihv" placeholder="Reply" id="flyonuiReply">
                  <span class="icon-[tabler--photo] text-base-content/80 q7z0e ms-2 size-4 shrink-0"></span>
                </div>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Sofia -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Sofia">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Sofia</span>
                <span class="text-base-content text-sm">requested feedback on her design.</span>
              </div>
              <p class="text-base-content/50 text-sm">1 Hour ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Jane Perez File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jane Perez">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Jane Perez</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 s7x45 text-sm">3 Hours ago</p>
              <span class="ijn5q bxh1m vnwjt">
                <span class="icon-[tabler--file-type-pdf] text-error"></span>
                invoices.pdf
              </span>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Liam -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Liam">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Liam</span>
                <span class="text-base-content text-sm">has shared a project update.</span>
              </div>
              <p class="text-base-content/50 text-sm">5 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Tyler Hero Design Project -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="Tyler Hero">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Tyler Hero</span>
                <span class="text-base-content text-sm">wants to view your design project</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 flex items-center njdg2 border j2be9 mwpft">
                <div class="nfjpm rmjll">
                  <div class="bg-base-100 text-primary rounded-box size-8 f1870">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/figma-icon.png" alt="avatar">
                  </div>
                </div>
                <span class="text-sm font-medium">Launcher-UIkit.fig</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Denial Invite -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Denial">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Denial</span>
                <span class="text-base-content text-sm">Invite from invite link</span>
              </div>
              <p class="text-base-content/50 text-sm">3 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Leslie Alexander Tags -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Leslie Alexander">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Leslie Alexander</span>
                <span class="text-base-content text-sm">new tags to Web Redesign</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="flex dcvi3">
                <span class="ijn5q bxh1m pze98 o1g2m">Client - Request</span>
                <span class="ijn5q bxh1m ctq8s o1g2m">Figma</span>
                <span class="ijn5q bxh1m vn3pt o1g2m">Redesign</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Miya File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Miya">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Miya</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 text-sm">10 Hours ago</p>
            </div>
          </li>
        </ul>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN CONTENT ---------- -->
    <main class="wpaot w-full owca9 sxihv fbpri">
      <div class="dpzny ip6vv sm:grid-cols-2">
        <div class="zq390 hono0 w-full">
          <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
        </div>
        <div class="zq390 hono0 w-full">
          <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
        </div>
        <div class="zq390 hono0 w-full sm:col-span-2">
          <div class="nqxya border-base-content/20 rounded-box cy2ft ke1x9 border"></div>
        </div>
      </div>
    </main>
    <!-- ---------- END MAIN CONTENT ---------- -->
    <!-- ---------- FOOTER CONTENT ---------- -->
    <div class="bg-base-100">
      <footer class="wpaot hg6f0 w-full owca9 rukzz egd50"></footer>
    </div>
    <!-- ---------- END FOOTER CONTENT ---------- -->
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
        <nav class="hvzi2 dhabr py-2">
          <div class="szonh bglhu">
            <button type="button" class="btn btn-soft btn-square btn-sm lg:hidden" aria-haspopup="dialog" aria-expanded="false" aria-controls="layout-toggle" data-overlay="#layout-toggle">
              <span class="icon-[tabler--menu-2] qmuz4"></span>
            </button>
            <!-- Search  -->
            <button type="button" class="max-sm:btn max-sm:btn-text max-sm:btn-sm max-sm:btn-square flex items-center bglhu text-sm" aria-haspopup="dialog" aria-expanded="false" aria-controls="search-modal" data-overlay="#search-modal">
              <span class="icon-[tabler--search] text-base-content size-5"></span>
              <span class="text-base-content/50 max-sm:hidden">Type to search...</span>
            </button>
          </div>

          <div class="ktglt ip6vv">
            <div class="flex items-center">
              <!-- Theme Dropdown  -->
              <div class="dropdown relative inline-flex [--offset:10]">
                <button id="dropdown-theme" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--sun] qmuz4"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full u4qiz" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-theme" tabindex="-1">
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Light" value="light">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="Dark" value="dark">
                  </li>
                  <li>
                    <input type="radio" name="theme-dropdown" class="theme-controller btn btn-text w-full ib2q4" aria-label="System" value="default">
                  </li>
                </ul>
              </div>

              <!-- Share Dropdown  -->
              <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:10]">
                <button id="share-dropdown" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--share] qmuz4"></span>
                </button>
                <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full z668w adede j2be9" role="menu" aria-orientation="vertical" aria-labelledby="share-dropdown" tabindex="-1">
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

              <!-- Language Dropdown -->
              <div class="dropdown relative inline-flex [--offset:10]">
                <button id="language-dropdown" type="button" class="dropdown-toggle btn btn-sm btn-square btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="icon-[tabler--language] qmuz4"></span>
                </button>
                <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full iv1t3 adede" role="menu" aria-orientation="vertical" aria-labelledby="language-dropdown" tabindex="-1">
                  <li><a class="dropdown-item px-3" href="#">English</a></li>
                  <li><a class="dropdown-item dropdown-active px-3" href="#">Deutsch</a></li>
                  <li><a class="dropdown-item px-3" href="#">한국인</a></li>
                  <li><a class="dropdown-item px-3" href="#">Española</a></li>
                  <li><a class="dropdown-item px-3" href="#">Português</a></li>
                </ul>
              </div>

              <!-- Activity Dropdown -->
              <button type="button" class="btn btn-sm btn-text btn-square" aria-haspopup="dialog" aria-expanded="false" aria-controls="activity-drawer" data-overlay="#activity-drawer">
                <span class="icon-[tabler--activity] qmuz4"></span>
              </button>

              <!-- Notification Dropdown -->
              <div class="dropdown relative inline-flex [--auto-close:inside] [--offset:10]">
                <button id="notification-dropdown" type="button" class="dropdown-toggle btn btn-text btn-square btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                  <span class="hpjlt">
                    <span class="pykeo kn3q0 j6kj2 rounded-full"></span>
                    <span class="icon-[tabler--bell] qmuz4"></span>
                  </span>
                </button>
                <div class="dropdown-menu dropdown-open:opacity-100 hidden w-full kzmwn adede px-3" role="menu" aria-orientation="vertical" aria-labelledby="notification-dropdown" tabindex="-1">
                  <div class="b6erz flex w-full items-center justify-between njdg2 mwpft">
                    <h6 class="text-base-content/50 text-sm vxiam">Notification</h6>
                    <span class="ijn5q bxh1m o1g2m pze98 rounded-full">8 New</span>
                  </div>
                  <div class="flex items-center justify-between">
                    <nav class="hhn76 vt6q1" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
                      <button type="button" class="vfeps active-tab:tab-active active font-medium" id="tabs-basic-item-1" data-tab="#tabs-basic-1" aria-controls="tabs-basic-1" role="tab" aria-selected="true">
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
                    <div id="tabs-basic-1" role="tabpanel" aria-labelledby="tabs-basic-item-1">
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

            <!-- Profile Dropdown -->
            <div class="dropdown relative inline-flex [--offset:7]">
              <button id="profile-dropdown" type="button" class="dropdown-toggle burs3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="User Avatar" class="rounded-box">
              </button>
              <ul class="dropdown-menu dropdown-open:opacity-100 hidden w-full w30ex adede" role="menu" aria-orientation="vertical" aria-labelledby="profile-dropdown" tabindex="-1">
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
        </nav>
      </div>
    </div>

    <!-- Search Dropdown Content  -->
    <div id="search-modal" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 hidden" role="dialog" tabindex="-1">
      <div class="dthlq w-full zr8jv">
        <div class="pbhw6 j5lbz nwdq3">
          <!-- SearchBox -->
          <div class="m1ukj border-base-content/20 abnz9 px-3 py-2">
            <div class="ljn0d o22n0 pelb3 eghwv">
              <span class="icon-[tabler--search] text-base-content/80 q7z0e me-2 size-5 shrink-0"></span>
              <input type="search" class="sxihv" placeholder="Search here..." id="kbdInput">
              <label class="rui3g" for="kbdInput">Search</label>
            </div>
          </div>

          <nav class="hhn76 vt6q1 py-2" aria-label="Tabs" role="tablist" aria-orientation="horizontal">
            <button type="button" class="vfeps active-tab:tab-active active w-full font-medium" id="search-tabs-item-1" data-tab="#search-tabs-1" aria-controls="search-tabs-1" role="tab" aria-selected="true">
              All
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-2" data-tab="#search-tabs-2" aria-controls="search-tabs-2" role="tab" aria-selected="false">
              Pages
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-3" data-tab="#search-tabs-3" aria-controls="search-tabs-3" role="tab" aria-selected="false">
              Integration
            </button>
            <button type="button" class="vfeps active-tab:tab-active w-full font-medium" id="search-tabs-item-4" data-tab="#search-tabs-4" aria-controls="search-tabs-4" role="tab" aria-selected="false">
              Users
            </button>
          </nav>
          <!-- SearchBox Modal Body -->
          <div class="fpegk overflow-y-auto lg:max-h-121">
            <!-- SearchBox All Modal Body -->
            <div id="search-tabs-1" role="tabpanel" aria-labelledby="search-tabs-item-1">
              <!-- Pages Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Pages</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- Interaction Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">Interaction</div>
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
              <div class="ck7pw"></div>
              <!-- User Section -->
              <div class="js11s">
                <div class="text-base-content/50 axeut text-sm vxiam">User</div>
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown1" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown1" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex sxihv items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu max-sm:hidden">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end]">
                          <button id="user-dropdown2" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown2" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Pages Modal Body -->
            <div id="search-tabs-2" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-2">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--users] size-6 shrink-0"></span>
                      <h6 class="font-medium">Marketing UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                      <h6 class="font-medium">e-commerce UI Page</h6>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex items-center bglhu k29kn b9hof" href="#">
                      <span class="icon-[tabler--device-desktop-analytics] size-6 shrink-0"></span>
                      <h6 class="font-medium">Dashboard UI Page</h6>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Integration Modal Body -->
            <div id="search-tabs-3" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-3">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/jira.png" alt="jira" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Jira</h6>
                          <p class="text-base-content/50 text-sm">Project management</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-10.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-12.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm rmjll">
                          <div class="dxw29 rgf08 size-8">
                            <span>+3</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                  <li>
                    <a class="hover:bg-base-200 rounded-field flex justify-between bglhu k29kn b9hof max-sm:flex-col sm:items-center" href="#">
                      <div class="flex items-center sly4q">
                        <div class="nfjpm rmjll">
                          <div class="dhabr lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/inferno.png" alt="inferno" class="size-6">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Inferno</h6>
                          <p class="text-base-content/50 text-sm">Real-time photo sharing app</p>
                        </div>
                      </div>
                      <div class="rp44n f6bsn">
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-13.png" alt="avatar">
                          </div>
                        </div>
                        <div class="nfjpm">
                          <div class="size-8">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="avatar">
                          </div>
                        </div>
                      </div>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <!-- SearchBox Users Modal Body -->
            <div id="search-tabs-4" class="hidden" role="tabpanel" aria-labelledby="search-tabs-item-4">
              <div class="js11s">
                <ul class="pqjas">
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Amelle Laurent">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Amelle Laurent</h6>
                          <p class="text-base-content/50 text-sm">Amelle@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q gehqc bxh1m rounded-full">In office</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown3" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown3" tabindex="-1">
                            <li><button class="dropdown-item px-2">View More</button></li>
                            <li><button class="dropdown-item px-2">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li>
                    <div class="hover:bg-base-200 rounded-field flex items-center justify-between bglhu k29kn b9hof">
                      <a href="#" class="flex items-center sly4q">
                        <div class="nfjpm">
                          <div class="lt1t7 rounded-full">
                            <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Maria Donin">
                          </div>
                        </div>
                        <div>
                          <h6 class="font-medium">Maria Donin</h6>
                          <p class="text-base-content/50 text-sm">Maria@hotmail.com</p>
                        </div>
                      </a>
                      <div class="flex items-center bglhu">
                        <span class="ijn5q e6v2p bxh1m rounded-full">On leave</span>
                        <div class="dropdown relative inline-flex [--placement:bottom-end] max-sm:hidden">
                          <button id="user-dropdown4" type="button" class="dropdown-toggle btn btn-text text-base-content btn-circle geut3" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                            <span class="icon-[tabler--dots-vertical] qmuz4"></span>
                          </button>
                          <ul class="dropdown-menu dropdown-open:opacity-100 v85mw hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="user-dropdown4" tabindex="-1">
                            <li><button class="dropdown-item px-2" type="button">View More</button></li>
                            <li><button class="dropdown-item px-2" type="button">Delete</button></li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>
          </div>
          <!-- Footer Commands -->
          <div class="w3jfd border-base-content/20 text-base-content/50 njdg2 ia8ws egd50 max-sm:hidden">
            <div class="flex sxihv items-center bglhu text-sm">
              <kbd class="b2fu4 an53u">esc</kbd>
              <span>To close</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-back] size-4"></span></kbd>
              <span>To Select</span>
            </div>
            <div class="flex items-center bglhu text-sm">
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-up] size-4"></span></kbd>
              <kbd class="b2fu4 an53u cbpaz"><span class="icon-[tabler--arrow-down] size-4"></span></kbd>
              <span>To Navigate</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Activity Drawer Content  -->
    <div id="activity-drawer" class="overlay overlay-open:translate-x-0 vxjzc jbh7e hidden sm:max-w-104" role="dialog" tabindex="-1">
      <div class="a5p6s border-base-content/20 w2qmy p-4">
        <h3 class="eul36 text-base t3mfo">Activity</h3>
        <button type="button" class="btn btn-text btn-circle geut3" aria-label="Close" data-overlay="#activity-drawer" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
      </div>
      <div class="rkt7z cbpaz">
        <ul class="if1r0">
          <!-- Joe Lincoln Activity -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="avatar">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">joe Lincoln</span>
                <span class="text-base-content text-sm">mentioned you in last trends topic</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 border j2be9 mwpft">
                <p class="text-base-content w3dp6 text-sm font-medium">
                  @Flyonui For an expert opinion, check out what Mike has to say on this topic!
                </p>
                <div class="ljn0d e1ers">
                  <input type="text" class="sxihv" placeholder="Reply" id="flyonuiReply">
                  <span class="icon-[tabler--photo] text-base-content/80 q7z0e ms-2 size-4 shrink-0"></span>
                </div>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Sofia -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Sofia">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Sofia</span>
                <span class="text-base-content text-sm">requested feedback on her design.</span>
              </div>
              <p class="text-base-content/50 text-sm">1 Hour ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Jane Perez File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jane Perez">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Jane Perez</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 s7x45 text-sm">3 Hours ago</p>
              <span class="ijn5q bxh1m vnwjt">
                <span class="icon-[tabler--file-type-pdf] text-error"></span>
                invoices.pdf
              </span>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Liam -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-11.png" alt="Liam">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Liam</span>
                <span class="text-base-content text-sm">has shared a project update.</span>
              </div>
              <p class="text-base-content/50 text-sm">5 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Tyler Hero Design Project -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-9.png" alt="Tyler Hero">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Tyler Hero</span>
                <span class="text-base-content text-sm">wants to view your design project</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="dhabr rounded-box border-base-content/20 flex items-center njdg2 border j2be9 mwpft">
                <div class="nfjpm rmjll">
                  <div class="bg-base-100 text-primary rounded-box size-8 f1870">
                    <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/figma-icon.png" alt="avatar">
                  </div>
                </div>
                <span class="text-sm font-medium">Launcher-UIkit.fig</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Denial Invite -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Denial">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Denial</span>
                <span class="text-base-content text-sm">Invite from invite link</span>
              </div>
              <p class="text-base-content/50 text-sm">3 Hours ago</p>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Leslie Alexander Tags -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Leslie Alexander">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Leslie Alexander</span>
                <span class="text-base-content text-sm">new tags to Web Redesign</span>
              </div>
              <p class="text-base-content/50 oobh7 text-sm">18 Mins ago</p>

              <div class="flex dcvi3">
                <span class="ijn5q bxh1m pze98 o1g2m">Client - Request</span>
                <span class="ijn5q bxh1m ctq8s o1g2m">Figma</span>
                <span class="ijn5q bxh1m vn3pt o1g2m">Redesign</span>
              </div>
            </div>
          </li>

          <li><div class="ck7pw"></div></li>

          <!-- Miya File Review -->
          <li class="flex qojvm njdg2 p-4">
            <div class="nfjpm">
              <div class="size-8 rounded-full">
                <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Miya">
              </div>
            </div>
            <div class="e6ynr">
              <div class="mb-1">
                <span class="text-base-content t3mfo">Miya</span>
                <span class="text-base-content text-sm">invites you to review a file.</span>
              </div>
              <p class="text-base-content/50 text-sm">10 Hours ago</p>
            </div>
          </li>
        </ul>
      </div>
    </div>
    <!-- ---------- END HEADER ---------- -->

    <!-- ---------- MAIN SIDEBAR ---------- -->
    <aside id="layout-toggle" class="overlay overlay-open:translate-x-0 vxjzc dhabr klzl7 wjz3b e4bmm hidden n85ea [--auto-close:lg] sm:w-75 lg:z-50 lg:block lg:translate-x-0 lg:shadow-none" aria-label="Sidebar" tabindex="-1">
      <div class="rkt7z n85ea fbpri">
        <button type="button" class="btn btn-text btn-square geut3 absolute koirh s7loe sm:hidden" aria-label="Close" data-overlay="#layout-toggle" aria-expanded="false">
          <span class="icon-[tabler--x] size-4"></span>
        </button>
        <div class="rounded-box cy2ft n85ea"></div>
      </div>
    </aside>
    <!-- ---------- END MAIN SIDEBAR ---------- -->

    <div class="flex sxihv jz3o6 lg:ps-75">
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
      <footer class="wpaot hg6f0 w-full rukzz"></footer>
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

