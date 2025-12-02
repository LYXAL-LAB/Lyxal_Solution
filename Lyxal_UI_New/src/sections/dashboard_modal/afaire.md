<div class="h-dvh py-8 sm:py-16 lg:py-24">
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button
          type="button"
          class="btn btn-primary"
          aria-haspopup="dialog"
          aria-expanded="false"
          aria-controls="select-plan"
          data-overlay="#select-plan"
        >
          Open modal
        </button>
      </div>

      <div
        id="select-plan"
        class="overlay modal overlay-open:opacity-100 overlay-open:duration-300 modal-middle hidden"
        role="dialog"
        tabindex="-1"
      >
        <div class="modal-dialog w-full max-w-155">
          <div class="modal-content overflow-auto">
            <div class="relative">
              <form class="flex flex-col gap-6 p-6">
                <div class="flex items-center gap-4">
                  <div class="avatar avatar-placeholder max-sm:hidden">
                    <div class="border-base-content/20 rounded-box w-13 border-1">
                      <span class="icon-[tabler--currency-dollar] size-8"></span>
                    </div>
                  </div>
                  <div class="space-y-1">
                    <h3 class="text-base-content text-2xl font-semibold">Select Plan</h3>
                    <p class="text-base-content/80">Simple and flexible per-user pricing</p>
                  </div>
                </div>

                <div class="flex w-full flex-wrap items-start gap-6 sm:flex-nowrap">
                  <label for="basic-plan" class="custom-option border-base-content/20 relative px-5 py-6 sm:w-1/2">
                    <input
                      type="radio"
                      name="radio-plan"
                      class="radio radio-primary radio-inset radio-xs absolute end-2 top-2 mt-2"
                      id="basic-plan"
                      checked
                    />
                    <span class="mb-4 flex w-full flex-col space-y-1 text-start">
                      <span class="font-medium">Basic Plan</span>
                      <span class="text-primary text-2xl font-semibold">$10/user</span>
                      <span class="text-base-content/80 text-sm">Includes 20GB individual data.</span>
                    </span>
                    <span class="space-y-2.5">
                      <span class="text-base-content/80 flex items-center gap-1.5 text-sm">
                        <span class="icon-[tabler--circle-check] size-5 shrink-0 rtl:rotate-y-180"></span>
                        <span>32+ integrations</span>
                      </span>
                      <span class="text-base-content/80 flex items-center gap-1.5 text-sm">
                        <span
                          class="icon-[tabler--circle-check] text-base-content/80 size-5 shrink-0 rtl:rotate-y-180"
                        ></span>
                        <span>Basic reporting</span>
                      </span>
                      <span class="text-base-content/80 flex items-center gap-1.5 text-sm">
                        <span
                          class="icon-[tabler--circle-check] text-base-content/80 size-5 shrink-0 rtl:rotate-y-180"
                        ></span>
                        <span>20GB individual data</span>
                      </span>
                      <span class="text-base-content/80 flex items-center gap-1.5 text-sm">
                        <span
                          class="icon-[tabler--circle-check] text-base-content/80 size-5 shrink-0 rtl:rotate-y-180"
                        ></span>
                        <span>Basic support</span>
                      </span>
                    </span>
                  </label>

                  <label for="starter-plan" class="custom-option border-base-content/20 relative px-5 py-6 sm:w-1/2">
                    <input
                      type="radio"
                      name="radio-plan"
                      class="radio radio-primary radio-inset radio-xs absolute end-2 top-2 mt-2"
                      id="starter-plan"
                    />
                    <span class="mb-4 flex w-full flex-col space-y-1 text-start">
                      <span class="font-medium">Starter Package</span>
                      <span class="text-primary text-2xl font-semibold">$12/user</span>
                      <span class="text-base-content/80 text-sm">Comes with 512GB personal data.</span>
                    </span>
                    <span class="space-y-2.5">
                      <span class="text-base-content/80 flex items-center gap-1.5 text-sm">
                        <span class="icon-[tabler--circle-check] size-5 shrink-0 rtl:rotate-y-180"></span>
                        <span>35+ integrations available</span>
                      </span>
                      <span class="text-base-content/80 flex items-center gap-1.5 text-sm">
                        <span
                          class="icon-[tabler--circle-check] text-base-content/80 size-5 shrink-0 rtl:rotate-y-180"
                        ></span>
                        <span>Essential reporting features</span>
                      </span>
                      <span class="text-base-content/80 flex items-center gap-1.5 text-sm">
                        <span
                          class="icon-[tabler--circle-check] text-base-content/80 size-5 shrink-0 rtl:rotate-y-180"
                        ></span>
                        <span>512GB personal data included</span>
                      </span>
                      <span class="text-base-content/80 flex items-center gap-1.5 text-sm">
                        <span
                          class="icon-[tabler--circle-check] text-base-content/80 size-5 shrink-0 rtl:rotate-y-180"
                        ></span>
                        <span>Standard support services</span>
                      </span>
                    </span>
                  </label>
                </div>

                <div class="flex items-center justify-between sm:justify-end sm:gap-4">
                  <button type="button" class="btn btn-soft btn-accent sm:me-auto">
                    <span class="icon-[tabler--message-2] size-5"></span>
                    Chat with us
                  </button>
                  <button type="button" class="btn btn-outline btn-secondary max-sm:hidden" data-overlay="#select-plan">
                    Cancel
                  </button>
                  <button type="submit" class="btn btn-primary">Purchase Now</button>
                </div>
              </form>
              <button
                class="btn btn-circle btn-sm btn-text absolute end-4 top-4"
                aria-label="Close"
                data-overlay="#select-plan"
              >
                <span class="icon-[tabler--x] text-base-content size-4"></span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

<script>
    window.addEventListener("load", () => {
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#select-plan")
      })
    })
  </script>


<div class="bg-base-200 h-dvh py-8 sm:py-16 lg:py-24">
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button
          type="button"
          class="btn btn-primary"
          aria-haspopup="dialog"
          aria-expanded="false"
          aria-controls="modal-congratulations"
          data-overlay="#modal-congratulations"
        >
          Open modal
        </button>
      </div>

      <div
        id="modal-congratulations"
        class="overlay modal overlay-open:opacity-100 overlay-open:duration-300 modal-middle hidden"
        role="dialog"
        tabindex="-1"
      >
        <div class="modal-dialog w-full max-w-145">
          <div class="modal-content">
            <div class="modal-body relative">
              <div class="flex flex-col gap-6">
                <!-- Success Icon -->
                <div class="flex justify-center">
                  <div class="avatar avatar-placeholder border-primary/30 rounded-full border p-2.5">
                    <div class="gradient-bg gradient-bg-primary flex size-12 items-center justify-center rounded-full">
                      <span class="icon-[tabler--check] size-8 text-white"></span>
                    </div>
                  </div>
                </div>

                <!-- Header -->
                <div class="space-y-4 text-center">
                  <h3 class="text-base-content text-2xl font-semibold">Congratulations!</h3>
                  <p class="text-base-content/80">
                    You have successfully subscribed 🎉
                    <br />
                    You will never miss our updates, latest news, and exclusive offers.
                  </p>
                </div>

                <!-- Thank you message -->
                <p class="text-base-content text-center font-medium">Thank you for joining our community!</p>

                <!-- Action Button -->
                <div class="flex justify-center">
                  <button type="button" class="btn btn-gradient btn-primary btn-lg">Subscribe</button>
                </div>
              </div>
              <button
                class="btn btn-circle btn-sm btn-text absolute end-4 top-4"
                aria-label="Close"
                data-overlay="#modal-congratulations"
              >
                <span class="icon-[tabler--x] text-base-content size-4"></span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

<script>
    window.addEventListener("load", () => {
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#modal-congratulations")
      })
    })
  </script>

<body data-vh-checked="true" style="">
  <div class="dhabr h-dvh i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 j2be9 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button type="button" class="btn btn-primary" aria-haspopup="dialog" aria-expanded="false" aria-controls="upload-file" data-overlay="#upload-file">
          Open modal
        </button>
      </div>

      <div id="upload-file" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 hidden" role="dialog" style="">
        <div class="dthlq w-full edp49">
          <div class="pbhw6">
            <!-- Header -->
            <div class="m1ukj">
              <h3 class="text-base-content waiii t3mfo">Upload File</h3>
              <button type="button" class="btn btn-text btn-circle btn-sm absolute c6rnh vv66w" aria-label="Close" data-overlay="#upload-file" aria-expanded="false">
                <span class="icon-[tabler--x] size-4"></span>
              </button>
            </div>
            <div class="js11s">
              <form class="flex jz3o6 ip6vv">
                <!-- File Upload Area -->
                <div id="modal-file-upload" data-file-upload="{
                    &quot;url&quot;: &quot;/upload&quot;,
                    &quot;maxFilesize&quot;: 1,
                    &quot;extensions&quot;: {
                      &quot;csv&quot;: {
                        &quot;icon&quot;: &quot;&lt;svg xmlns=\&quot;http://www.w3.org/2000/svg\&quot; width=\&quot;24\&quot; height=\&quot;24\&quot; viewBox=\&quot;0 0 24 24\&quot; fill=\&quot;none\&quot; stroke=\&quot;currentColor\&quot; stroke-width=\&quot;2\&quot; stroke-linecap=\&quot;round\&quot; stroke-linejoin=\&quot;round\&quot;&gt;&lt;path d=\&quot;M4 22h14a2 2 0 0 0 2-2V7l-5-5H6a2 2 0 0 0-2 2v4\&quot;/&gt;&lt;path d=\&quot;M14 2v4a2 2 0 0 0 2 2h4\&quot;/&gt;&lt;path d=\&quot;m5 12-3 3 3 3\&quot;/&gt;&lt;path d=\&quot;m9 18 3-3-3-3\&quot;/&gt;&lt;/svg&gt;&quot;,
                        &quot;class&quot;: &quot;shrink-0 size-5&quot;
                      }
                    }
                  }">
                  <template data-file-upload-preview="">
                    <div class="pr3hj rounded-box p-3">
                      <div class="oobh7 flex justify-between md:items-center">
                        <div class="items-center sly4q md:flex">
                          <span class="text-base-content/80 border-base-content/20 rounded-box flex size-8 items-center justify-center border p-0.5" data-file-upload-file-icon="">
                            <img class="rounded-field hidden" data-dz-thumbnail="">
                          </span>
                          <div>
                            <p class="text-base-content/80 text-sm font-medium">
                              <span data-file-upload-file-name=""></span>
                              .
                              <span data-file-upload-file-ext=""></span>
                            </p>
                            <p class="text-base-content text-xs" data-file-upload-file-size="" data-file-upload-file-success=""></p>
                            <p class="text-error text-xs" style="display: none" data-file-upload-file-error="">
                              File exceeds size limit.
                            </p>
                          </div>
                        </div>
                        <div class="ms-auto flex md:items-center">
                          <div class="tooltip [--placement:top]" style="display: none" data-file-upload-file-error="">
                            <button type="button" class="tooltip-toggle btn btn-sm btn-circle btn-text gauh6">
                              <span class="icon-[tabler--alert-circle] size-4 shrink-0"></span>
                            </button>
                            <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible" role="tooltip">
                              <span class="tnsaf">Please try to upload a file smaller than 1MB.</span>
                            </span>
                          </div>
                          <button type="button" class="btn btn-sm btn-circle btn-text" data-file-upload-reload="">
                            <span class="icon-[tabler--refresh] size-4 shrink-0"></span>
                          </button>
                          <button type="button" class="btn btn-sm btn-circle btn-text" data-file-upload-remove="">
                            <span class="icon-[tabler--trash] size-4 shrink-0"></span>
                          </button>
                        </div>
                      </div>
                      <div class="flex items-center gap-x-3 whitespace-nowrap">
                        <div class="progress h-2" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" data-file-upload-progress-bar="">
                          <div class="progress-bar progress-primary file-upload-complete:progress-success transition-all duration-500" style="width: 0" data-file-upload-progress-bar-pane=""></div>
                        </div>
                        <span class="text-base-content mb-0.5 text-sm">
                          <span data-file-upload-progress-bar-value="">0</span>
                          %
                        </span>
                      </div>
                    </div>
                  </template>

                  <div class="border-base-content/20 rounded-box flex cb40p lx78o items-center justify-center vpx91 dkr8s fbpri dz-clickable" data-file-upload-trigger="">
                    <div class="hqh7v rdi5h">
                      <span class="icon-[tabler--upload] text-base-content j4z3m"></span>
                      <h4 class="text-base-content t3mfo">Drag &amp; Drop or Choose file to upload</h4>
                      <p class="text-base-content/50 text-sm font-medium">CSV or PDF</p>
                    </div>
                  </div>
                  <div class="ndnti vi1oq empty:mt-0" data-file-upload-previews=""></div>
                </div>

                <div class="ck7pw">or</div>

                <!-- Import from URL -->
                <div>
                  <label for="import-url" class="text-base-content mb-2 block">Import from URL</label>
                  <div class="ljn0d fo8mv">
                    <input type="url" class="sxihv" placeholder="Add file URL" id="import-url" required="">
                    <span class="icon-[tabler--link] text-primary q7z0e iduv5 girx5 shrink-0"></span>
                  </div>
                </div>

                <!-- Footer Actions -->
                <div class="flex items-center edy4p njdg2">
                  <div class="text-base-content tooltip xwi7f flex items-center bglhu font-medium">
                    <span class="icon-[tabler--help] tooltip-toggle size-5 shrink-0" aria-label="Tooltip"></span>
                    <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible" role="tooltip" style="position: fixed; left: 0px; top: 0px;">
                      <span class="tnsaf">Update file Help Center</span>
                    </span>
                    Help Center
                  </div>
                  <button type="button" class="btn g2v48 gnw6d" data-overlay="#upload-file" aria-expanded="false">
                    Cancel
                  </button>
                  <button type="submit" class="btn btn-primary">Import</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script src="https://flyonui.becdn.net/pro/libs/lodash/lodash.min.js"></script>
  <script src="https://flyonui.becdn.net/pro/libs/dropzone/dist/dropzone-min.js"></script>

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
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#upload-file")
      })
      ;(function () {
        const { element } = HSFileUpload.getInstance("#modal-file-upload", true)

        element.dropzone.on("error", (file, response) => {
          if (file.size > element.concatOptions.maxFilesize * 1024 * 1024) {
            const filePreview = file.previewElement

            const successEls = filePreview.querySelectorAll("[data-file-upload-file-success]")
            const errorEls = filePreview.querySelectorAll("[data-file-upload-file-error]")
            if (successEls) successEls.forEach(el => (el.style.display = "none"))
            errorEls.forEach(el => (el.style.display = ""))
            HSStaticMethods.autoInit(["tooltip"])
          }
        })
      })()
    })
  </script>
  

<input type="file" multiple="multiple" class="dz-hidden-input" tabindex="-1" style="visibility: hidden; position: absolute; top: 0px; left: 0px; height: 0px; width: 0px;"></body>


<body data-vh-checked="true" style="overflow: hidden;">
  <div class="dhabr h-dvh i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 j2be9 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button type="button" class="btn btn-primary" aria-haspopup="dialog" aria-expanded="true" aria-controls="add-event-details" data-overlay="#add-event-details">
          Open modal
        </button>
      </div>

      <div id="add-event-details" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 open opened" role="dialog" tabindex="-1" aria-overlay="true" style="outline: none;">
        <div class="dthlq w-full m9sab">
          <div class="pbhw6">
            <div class="m1ukj">
              <!-- Header -->
              <div class="kf6hd">
                <h3 class="text-base-content waiii t3mfo">Create New Schedule</h3>
                <p class="text-base-content/80">You can create meeting, event and task</p>
              </div>
              <button type="button" class="btn btn-text btn-circle btn-sm absolute c6rnh vv66w" aria-label="Close" data-overlay="#add-event-details" aria-expanded="true">
                <span class="icon-[tabler--x] size-4"></span>
              </button>
            </div>
            <div class="js11s">
              <form class="flex jz3o6 ip6vv">
                <!-- Form Fields -->
                <div class="hqh7v y9l1c">
                  <!-- Schedule Title -->
                  <input type="text" placeholder="Add a Title" class="ljn0d" id="schedule-title" required="">

                  <!-- What are you working on? -->
                  <p class="text-base-content">What are you working on ?</p>
                  <div>
                    <div class="flex sly4q">
                      <label class="w6ln6 e6ynr lx78o px-3 py-2">
                        <input type="radio" name="work-type" class="d6aiv hidden" value="meeting" checked="">
                        <span>Meeting call</span>
                      </label>
                      <label class="w6ln6 e6ynr lx78o px-3 py-2">
                        <input type="radio" name="work-type" class="d6aiv hidden" value="calendar">
                        <span>Calendar</span>
                      </label>
                      <label class="w6ln6 e6ynr lx78o px-3 py-2">
                        <input type="radio" name="work-type" class="d6aiv hidden" value="task">
                        <span>Task</span>
                      </label>
                    </div>
                  </div>

                  <!-- Repeat on -->
                  <div class="flex items-center justify-between bglhu">
                    <div>
                      <label class="wqwbi">Repeat on</label>
                      <div class="flex mnhlk items-center bglhu">
                        <label class="nfjpm rmjll dh3pr lx78o">
                          <input type="checkbox" class="d5jfq hidden">
                          <span class="dhabr text-base-content group-has-checked:text-bg-primary size-8 rounded-full">
                            <span class="text-xs font-medium vxiam">M</span>
                          </span>
                        </label>
                        <label class="nfjpm rmjll dh3pr lx78o">
                          <input type="checkbox" class="d5jfq hidden">
                          <span class="dhabr text-base-content group-has-checked:text-bg-primary size-8 rounded-full">
                            <span class="text-xs font-medium vxiam">T</span>
                          </span>
                        </label>
                        <label class="nfjpm rmjll dh3pr lx78o">
                          <input type="checkbox" class="d5jfq hidden" checked="">
                          <span class="dhabr text-base-content group-has-checked:text-bg-primary size-8 rounded-full">
                            <span class="text-xs font-medium vxiam">W</span>
                          </span>
                        </label>
                        <label class="nfjpm rmjll dh3pr lx78o">
                          <input type="checkbox" class="d5jfq hidden">
                          <span class="dhabr text-base-content group-has-checked:text-bg-primary size-8 rounded-full">
                            <span class="text-xs font-medium vxiam">T</span>
                          </span>
                        </label>
                        <label class="nfjpm rmjll dh3pr lx78o">
                          <input type="checkbox" class="d5jfq hidden">
                          <span class="dhabr text-base-content group-has-checked:text-bg-primary size-8 rounded-full">
                            <span class="text-xs font-medium vxiam">F</span>
                          </span>
                        </label>
                        <label class="nfjpm rmjll dh3pr lx78o">
                          <input type="checkbox" class="d5jfq hidden">
                          <span class="dhabr text-base-content group-has-checked:text-bg-primary size-8 rounded-full">
                            <span class="text-xs font-medium vxiam">S</span>
                          </span>
                        </label>
                        <label class="nfjpm rmjll dh3pr lx78o">
                          <input type="checkbox" class="d5jfq hidden">
                          <span class="dhabr text-base-content group-has-checked:text-bg-primary size-8 rounded-full">
                            <span class="text-xs font-medium vxiam">S</span>
                          </span>
                        </label>
                      </div>
                    </div>

                    <!-- Repeat every -->
                    <div>
                      <label class="wqwbi" for="repeat-every">Repeat every</label>
                      <select class="select o8mk1 loa97 pelb3 njy33 jv1g6" id="repeat-every">
                        <option disabled="">Choose</option>
                        <option value="week" selected="">Week</option>
                        <option value="month">Month</option>
                        <option value="year">Year</option>
                      </select>
                    </div>
                  </div>

                  <!-- Date, Time Row -->
                  <div class="dpzny wfsyj njdg2 md:grid-cols-2">
                    <!-- Date input -->
                    <div>
                      <label for="event-date" class="wqwbi">Date input</label>
                      <div class="ljn0d">
                        <input type="text" class="sxihv flatpickr-input" placeholder="May 15, 2024" id="event-date" required="" readonly="readonly">
                        <span class="icon-[tabler--calendar] text-base-content/80 q7z0e iduv5 size-5 shrink-0"></span>
                      </div>
                    </div>

                    <!-- Time input -->
                    <div>
                      <label for="event-time" class="wqwbi">Time input</label>
                      <div class="ljn0d">
                        <input type="text" class="sxihv flatpickr-input" placeholder="02:00 PM" id="event-time" required="" readonly="readonly">
                        <span class="icon-[tabler--clock] text-base-content/80 q7z0e iduv5 size-5 shrink-0"></span>
                      </div>
                    </div>
                  </div>

                  <!-- Description -->
                  <div>
                    <label class="wqwbi" for="schedule-description">Description</label>
                    <textarea class="ystrl" placeholder="Write text........" id="schedule-description"></textarea>
                  </div>

                  <div class="dpzny wfsyj njdg2 md:grid-cols-2">
                    <!-- Attendance -->
                    <div>
                      <label for="attendance-date" class="wqwbi">Attendance</label>
                      <select class="select" id="attendance-date">
                        <option disabled="">Choose an option</option>
                        <option value="10+" selected="">10+ Meeting attendance</option>
                        <option value="5-10">5-10 Meeting attendance</option>
                        <option value="1-5">1-5 Meeting attendance</option>
                      </select>
                    </div>

                    <!-- Dropdown - Single Selection -->
                    <div>
                      <label for="dropdown-single" class="wqwbi">Dropdown - Single Selection</label>
                      <select class="select" id="dropdown-single">
                        <option disabled="">Choose an option</option>
                        <option value="zoomMeetingApp" selected="">Zoom Meeting App</option>
                        <option value="googleMeetApp">Google Meet App</option>
                        <option value="microsoftTeamsApp">Microsoft Teams App</option>
                        <option value="slackApp">Slack App</option>
                        <option value="skypeApp">Skype App</option>
                      </select>
                    </div>
                  </div>
                </div>

                <!-- Upload Attachments -->
                <div>
                  <label class="wqwbi">Upload attachments</label>

                  <!-- File Preview -->
                  <div class="pr3hj rpj8y p-4" id="file-upload-attachments" data-file-upload="{
                  &quot;url&quot;: &quot;/upload&quot;,
                  &quot;maxFilesize&quot;: 1,
                  &quot;extensions&quot;: {
                    &quot;csv&quot;: {
                      &quot;icon&quot;: &quot;&lt;svg xmlns=\&quot;http://www.w3.org/2000/svg\&quot; width=\&quot;24\&quot; height=\&quot;24\&quot; viewBox=\&quot;0 0 24 24\&quot; fill=\&quot;none\&quot; stroke=\&quot;currentColor\&quot; stroke-width=\&quot;2\&quot; stroke-linecap=\&quot;round\&quot; stroke-linejoin=\&quot;round\&quot;&gt;&lt;path d=\&quot;M4 22h14a2 2 0 0 0 2-2V7l-5-5H6a2 2 0 0 0-2 2v4\&quot;/&gt;&lt;path d=\&quot;M14 2v4a2 2 0 0 0 2 2h4\&quot;/&gt;&lt;path d=\&quot;m5 12-3 3 3 3\&quot;/&gt;&lt;path d=\&quot;m9 18 3-3-3-3\&quot;/&gt;&lt;/svg&gt;&quot;,
                      &quot;class&quot;: &quot;shrink-0 size-5&quot;
                    }
                  }
                }">
                    <template data-file-upload-preview="">
                      <div class="flex mnhlk items-center bglhu">
                        <span class="icon-[tabler--circle-check] text-primary size-4" data-file-upload-file-success=""></span>
                        <div class="tooltip [--placement:top]" style="display: none" data-file-upload-file-error="">
                          <span class="icon-[tabler--alert-circle] text-error size-4 shrink-0"></span>
                          <span class="tooltip-content tooltip-shown:opacity-100 tooltip-shown:visible" role="tooltip">
                            <span class="tnsaf">Please try to upload a file smaller than 1MB.</span>
                          </span>
                        </div>
                        <h6 class="text-base-content text-sm">
                          <span class="t3mfo" data-file-upload-file-name=""></span>
                          .
                          <span data-file-upload-file-ext=""></span>
                          <p class="text-error text-xs" style="display: none" data-file-upload-file-error="">
                            File exceeds size limit.
                          </p>
                        </h6>
                        <span class="ijn5q bxh1m rounded-full" data-file-upload-file-size="" data-file-upload-file-success=""></span>
                        <button type="button" class="btn btn-circle btn-text gnw6d ms-auto" data-file-upload-remove="">
                          <span class="icon-[tabler--trash] size-6"></span>
                        </button>
                      </div>
                    </template>

                    <button class="btn btn-soft btn-primary w-full ft3qj dz-clickable" data-file-upload-trigger="">
                      Select Files
                      <span class="icon-[tabler--upload] size-5 shrink-0"></span>
                    </button>
                    <div class="ck7pw qcy2t"></div>
                    <div data-file-upload-previews=""></div>
                  </div>
                </div>

                <!-- Footer Actions -->
                <div class="flex mnhlk items-center edy4p njdg2">
                  <button type="button" class="btn g2v48 gnw6d" data-overlay="#add-event-details" aria-expanded="true">
                    Cancel
                  </button>
                  <button type="submit" class="btn btn-primary">Create Event</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script src="https://flyonui.becdn.net/pro/libs/lodash/lodash.min.js"></script>
  <script src="https://flyonui.becdn.net/pro/libs/dropzone/dist/dropzone-min.js"></script>
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
    window.addEventListener("load", () => {
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#add-event-details")
      })
      ;(function () {
        const { element } = HSFileUpload.getInstance("#file-upload-attachments", true)

        element.dropzone.on("error", (file, response) => {
          if (file.size > element.concatOptions.maxFilesize * 1024 * 1024) {
            const filePreview = file.previewElement

            const successEls = filePreview.querySelectorAll("[data-file-upload-file-success]")
            const errorEls = filePreview.querySelectorAll("[data-file-upload-file-error]")
            if (successEls) successEls.forEach(el => (el.style.display = "none"))
            errorEls.forEach(el => (el.style.display = ""))
            HSStaticMethods.autoInit(["tooltip"])
          }
        })
      })()

      flatpickr("#event-date", {
        monthSelectorType: "static"
      })
      // Time
      flatpickr("#event-time", {
        enableTime: true,
        noCalendar: true,
        dateFormat: "H:i"
      })
    })
  </script>
  

<input type="file" multiple="multiple" class="dz-hidden-input" tabindex="-1" style="visibility: hidden; position: absolute; top: 0px; left: 0px; height: 0px; width: 0px;"><div class="flatpickr-calendar animate" tabindex="-1"><div class="flatpickr-months"><span class="flatpickr-prev-month"><svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 17 17"><g></g><path d="M5.207 8.471l7.146 7.147-0.707 0.707-7.853-7.854 7.854-7.853 0.707 0.707-7.147 7.146z"></path></svg></span><div class="flatpickr-month"><div class="flatpickr-current-month"><span class="cur-month">November </span><div class="numInputWrapper"><input class="numInput cur-year" type="number" tabindex="-1" aria-label="Year"><span class="arrowUp"></span><span class="arrowDown"></span></div></div></div><span class="flatpickr-next-month"><svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 17 17"><g></g><path d="M13.207 8.472l-7.854 7.854-0.707-0.707 7.146-7.146-7.146-7.148 0.707-0.707 7.854 7.854z"></path></svg></span></div><div class="flatpickr-innerContainer"><div class="flatpickr-rContainer"><div class="flatpickr-weekdays"><div class="flatpickr-weekdaycontainer">
      <span class="flatpickr-weekday">
        Sun</span><span class="flatpickr-weekday">Mon</span><span class="flatpickr-weekday">Tue</span><span class="flatpickr-weekday">Wed</span><span class="flatpickr-weekday">Thu</span><span class="flatpickr-weekday">Fri</span><span class="flatpickr-weekday">Sat
      </span>
      </div></div><div class="flatpickr-days" tabindex="-1"><div class="dayContainer"><span class="flatpickr-day prevMonthDay" aria-label="October 26, 2025" tabindex="-1">26</span><span class="flatpickr-day prevMonthDay" aria-label="October 27, 2025" tabindex="-1">27</span><span class="flatpickr-day prevMonthDay" aria-label="October 28, 2025" tabindex="-1">28</span><span class="flatpickr-day prevMonthDay" aria-label="October 29, 2025" tabindex="-1">29</span><span class="flatpickr-day prevMonthDay" aria-label="October 30, 2025" tabindex="-1">30</span><span class="flatpickr-day prevMonthDay" aria-label="October 31, 2025" tabindex="-1">31</span><span class="flatpickr-day" aria-label="November 1, 2025" tabindex="-1">1</span><span class="flatpickr-day" aria-label="November 2, 2025" tabindex="-1">2</span><span class="flatpickr-day" aria-label="November 3, 2025" tabindex="-1">3</span><span class="flatpickr-day" aria-label="November 4, 2025" tabindex="-1">4</span><span class="flatpickr-day" aria-label="November 5, 2025" tabindex="-1">5</span><span class="flatpickr-day" aria-label="November 6, 2025" tabindex="-1">6</span><span class="flatpickr-day" aria-label="November 7, 2025" tabindex="-1">7</span><span class="flatpickr-day" aria-label="November 8, 2025" tabindex="-1">8</span><span class="flatpickr-day" aria-label="November 9, 2025" tabindex="-1">9</span><span class="flatpickr-day" aria-label="November 10, 2025" tabindex="-1">10</span><span class="flatpickr-day" aria-label="November 11, 2025" tabindex="-1">11</span><span class="flatpickr-day" aria-label="November 12, 2025" tabindex="-1">12</span><span class="flatpickr-day" aria-label="November 13, 2025" tabindex="-1">13</span><span class="flatpickr-day" aria-label="November 14, 2025" tabindex="-1">14</span><span class="flatpickr-day" aria-label="November 15, 2025" tabindex="-1">15</span><span class="flatpickr-day" aria-label="November 16, 2025" tabindex="-1">16</span><span class="flatpickr-day" aria-label="November 17, 2025" tabindex="-1">17</span><span class="flatpickr-day" aria-label="November 18, 2025" tabindex="-1">18</span><span class="flatpickr-day" aria-label="November 19, 2025" tabindex="-1">19</span><span class="flatpickr-day" aria-label="November 20, 2025" tabindex="-1">20</span><span class="flatpickr-day" aria-label="November 21, 2025" tabindex="-1">21</span><span class="flatpickr-day" aria-label="November 22, 2025" tabindex="-1">22</span><span class="flatpickr-day" aria-label="November 23, 2025" tabindex="-1">23</span><span class="flatpickr-day" aria-label="November 24, 2025" tabindex="-1">24</span><span class="flatpickr-day" aria-label="November 25, 2025" tabindex="-1">25</span><span class="flatpickr-day today" aria-label="November 26, 2025" aria-current="date" tabindex="-1">26</span><span class="flatpickr-day" aria-label="November 27, 2025" tabindex="-1">27</span><span class="flatpickr-day" aria-label="November 28, 2025" tabindex="-1">28</span><span class="flatpickr-day" aria-label="November 29, 2025" tabindex="-1">29</span><span class="flatpickr-day" aria-label="November 30, 2025" tabindex="-1">30</span><span class="flatpickr-day nextMonthDay" aria-label="December 1, 2025" tabindex="-1">1</span><span class="flatpickr-day nextMonthDay" aria-label="December 2, 2025" tabindex="-1">2</span><span class="flatpickr-day nextMonthDay" aria-label="December 3, 2025" tabindex="-1">3</span><span class="flatpickr-day nextMonthDay" aria-label="December 4, 2025" tabindex="-1">4</span><span class="flatpickr-day nextMonthDay" aria-label="December 5, 2025" tabindex="-1">5</span><span class="flatpickr-day nextMonthDay" aria-label="December 6, 2025" tabindex="-1">6</span></div></div></div></div></div><div class="flatpickr-calendar hasTime noCalendar animate" tabindex="-1"><div class="flatpickr-time" tabindex="-1"><div class="numInputWrapper"><input class="numInput flatpickr-hour" type="number" aria-label="Hour" tabindex="-1" step="1" min="1" max="12" maxlength="2"><span class="arrowUp"></span><span class="arrowDown"></span></div><span class="flatpickr-time-separator">:</span><div class="numInputWrapper"><input class="numInput flatpickr-minute" type="number" aria-label="Minute" tabindex="-1" step="5" min="0" max="59" maxlength="2"><span class="arrowUp"></span><span class="arrowDown"></span></div><span class="flatpickr-am-pm" title="Click to toggle" tabindex="-1">PM</span></div></div><div id="add-event-details-backdrop" data-overlay-backdrop-template="" style="z-index: 79;" class="overlay-backdrop transition duration-300 fixed inset-0 bg-base-300/60 overflow-y-auto "></div></body>

<body data-vh-checked="true" style="overflow: hidden;">
  <div class="dhabr h-dvh i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 j2be9 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button type="button" class="btn btn-primary" aria-haspopup="dialog" aria-expanded="true" aria-controls="connect-workspace" data-overlay="#connect-workspace">
          Open modal
        </button>
      </div>

      <div id="connect-workspace" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 open opened" role="dialog" tabindex="-1" aria-overlay="true" style="outline: none;">
        <div class="dthlq w-full pxnxg">
          <div class="pbhw6 j5lbz">
            <div class="js11s relative">
              <div class="flex jz3o6 ip6vv">
                <!-- Illustration -->
                <div>
                  <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/image-2.png" alt="Connect Workspace Illustration" class="rounded-box w-full">
                </div>

                <!-- Header -->
                <div>
                  <h3 class="text-base-content axeut waiii t3mfo">Connect Workspace</h3>
                  <p class="text-base-content/80">
                    Send a connection request to another workspace to share content, sessions, and community spaces.
                  </p>
                </div>

                <!-- Form Fields -->
                <div>
                  <label for="workspace-url" class="text-base-content mb-1 block text-sm">Workspace URL</label>
                  <div class="ljn0d">
                    <input type="text" class="sxihv" placeholder="github.flyonui.com" id="workspace-url" value="github.flyonui.com" required="">
                    <span class="icon-[tabler--check] text-success q7z0e iduv5 size-5 shrink-0"></span>
                  </div>
                </div>

                <!-- Footer Actions -->
                <div class="dpzny njdg2 sm:grid-cols-2">
                  <button type="button" class="btn g2v48 gnw6d" data-overlay="#connect-workspace" aria-expanded="true">
                    Cancel
                  </button>
                  <button type="button" class="btn btn-primary">Send Request</button>
                </div>
              </div>
              <button class="btn btn-circle btn-sm btn-soft absolute w3z1y psag3" aria-label="Close" data-overlay="#connect-workspace" aria-expanded="true">
                <span class="icon-[tabler--x] text-base-content size-4"></span>
              </button>
            </div>
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

  <script>
    window.addEventListener("load", () => {
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#connect-workspace")
      })
    })
  </script>
  

<div id="connect-workspace-backdrop" data-overlay-backdrop-template="" style="z-index: 79;" class="overlay-backdrop transition duration-300 fixed inset-0 bg-base-300/60 overflow-y-auto "></div></body>

<body data-vh-checked="true" style="overflow: hidden;">
  <div class="dhabr h-dvh i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 j2be9 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button type="button" class="btn btn-primary" aria-haspopup="dialog" aria-expanded="true" aria-controls="twoFactorAuth" data-overlay="#twoFactorAuth">
          Open modal
        </button>
      </div>

      <!-- Step 1: Enable One Time Password Modal -->
      <div id="twoFactorAuth" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 open opened" role="dialog" tabindex="-1" aria-overlay="true" style="outline: none;">
        <div class="dthlq w-full rez5c">
          <div class="pbhw6">
            <div class="js11s relative md:p-12">
              <div class="flex jz3o6 ip6vv md:gap-9">
                <!-- Header -->
                <div class="kf6hd rdi5h">
                  <h3 class="text-base-content waiii t3mfo">Enable One Time Password</h3>
                  <p class="text-base-content/80">Verify Your Mobile Number for SMS</p>
                </div>

                <!-- Authentication Options -->
                <label class="w6ln6 flex lx78o a4n2b qojvm sly4q ao5al">
                  <input type="radio" name="authMethod" class="d6aiv bmjz1 saa4z zwsg8" value="authenticator" aria-controls="authenticatorApp" data-overlay="#authenticatorApp" aria-expanded="false">
                  <span class="kf6hd">
                    <span class="text-base-content mb-1 flex items-center bglhu text-base font-medium">
                      <span class="icon-[tabler--settings] size-5"></span>
                      Authenticator Apps
                    </span>
                    <span class="text-base-content/80 text-sm">
                      Get code from an app like Google Authenticator or Microsoft Authenticator.
                    </span>
                  </span>
                </label>

                <label class="w6ln6 flex lx78o a4n2b qojvm sly4q ao5al">
                  <input type="radio" name="authMethod" class="d6aiv bmjz1 saa4z zwsg8" value="sms" aria-controls="smsSetup" data-overlay="#smsSetup" aria-expanded="false">
                  <span class="kf6hd">
                    <span class="text-base-content mb-1 flex items-center bglhu text-base font-medium">
                      <span class="icon-[tabler--message-2] size-5"></span>
                      SMS
                    </span>
                    <span class="text-base-content/80 text-sm">
                      We will send a code via SMS if you need to use your backup login method.
                    </span>
                  </span>
                </label>
              </div>
              <button class="btn btn-circle btn-sm btn-text absolute w3z1y psag3" aria-label="Close" data-overlay="#twoFactorAuth" aria-expanded="true">
                <span class="icon-[tabler--x] text-base-content size-4"></span>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Step 2: Add Authenticator App with QR Code -->
      <div id="authenticatorApp" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 hidden" role="dialog" tabindex="-1">
        <div class="dthlq w-full y1run">
          <div class="pbhw6">
            <div class="js11s relative md:p-12">
              <div class="flex jz3o6 ip6vv">
                <!-- Header -->
                <div class="kf6hd rdi5h">
                  <h3 class="text-base-content waiii t3mfo">Add Authenticator App</h3>
                </div>

                <!-- Description -->
                <div>
                  <h6 class="text-base-content mb-1 c9rvi font-medium">Authenticator Apps</h6>
                  <p class="text-base-content/80">
                    Using an authenticator app like Google Authenticator, Microsoft Authenticator, Authy, or 1Password,
                    scan the QR code. It will generate a 6-digit code for you to enter below.
                  </p>
                </div>

                <!-- QR Code Section -->
                <div class="flex w-full items-center justify-center">
                  <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/image-7.png" alt="QR Code" class="mwkor c7ys3">
                </div>

                <!-- Manual Entry Alternative -->
                <div class="xtk84 h7b7g rounded-box p-4">
                  <h6 class="mb-1 c9rvi font-medium b3of7">ASDLKNASDDA9AHS678dGhASD78AB</h6>
                  <p>If you're having trouble using the QR code, select manual entry on your app</p>
                </div>

                <!-- Authentication Code Input -->
                <div>
                  <label class="wqwbi" for="auth-code">Enter Authentication Code</label>
                  <input type="text" placeholder="1234 567" class="ljn0d" id="auth-code" maxlength="7" required="">
                </div>

                <!-- Action Buttons -->
                <div class="flex mnhlk items-center edy4p njdg2">
                  <button type="button" class="btn gnw6d" aria-controls="twoFactorAuth" data-overlay="#twoFactorAuth" aria-expanded="true">
                    Cancel
                  </button>
                  <button type="button" class="btn mxpqt" data-overlay="#authenticatorApp" aria-expanded="false">Submit</button>
                </div>
              </div>
              <button class="btn btn-circle btn-sm btn-text absolute w3z1y psag3" aria-label="Close" data-overlay="#authenticatorApp" aria-expanded="false">
                <span class="icon-[tabler--x] text-base-content size-4"></span>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Step 3: SMS Setup -->
      <div id="smsSetup" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 hidden" role="dialog" tabindex="-1">
        <div class="dthlq w-full y1run">
          <div class="pbhw6">
            <div class="js11s relative md:p-12">
              <div class="flex jz3o6 ip6vv">
                <!-- Header -->
                <div class="kf6hd">
                  <h3 class="text-base-content waiii t3mfo">Add Authenticator App</h3>
                  <p class="text-base-content/80">
                    Enter your mobile phone number with country code, and we will send you a verification code.
                  </p>
                </div>

                <!-- Phone Number Input -->
                <div>
                  <label class="wqwbi" for="phone-number">Phone number</label>
                  <input type="tel" placeholder="202 555 231" class="ljn0d" id="phone-number" required="">
                </div>

                <!-- Action Buttons -->
                <div class="flex mnhlk items-center edy4p njdg2">
                  <button type="button" class="btn gnw6d" aria-controls="twoFactorAuth" data-overlay="#twoFactorAuth" aria-expanded="true">
                    Cancel
                  </button>
                  <button type="button" class="btn mxpqt" data-overlay="#smsSetup" aria-expanded="false">Submit</button>
                </div>
              </div>
              <button class="btn btn-circle btn-sm btn-text absolute w3z1y psag3" aria-label="Close" data-overlay="#smsSetup" aria-expanded="false">
                <span class="icon-[tabler--x] text-base-content size-4"></span>
              </button>
            </div>
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

  <script>
    window.addEventListener("load", () => {
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#twoFactorAuth")
      })
    })
  </script>
  

<div id="twoFactorAuth-backdrop" data-overlay-backdrop-template="" style="z-index: 79;" class="overlay-backdrop transition duration-300 fixed inset-0 bg-base-300/60 overflow-y-auto "></div></body>

<body data-vh-checked="true" style="overflow: hidden;">
  <div class="dhabr h-dvh i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 j2be9 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button type="button" class="btn btn-primary" aria-haspopup="dialog" aria-expanded="true" aria-controls="payment-methods" data-overlay="#payment-methods">
          Open modal
        </button>
      </div>

      <div id="payment-methods" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 open opened" role="dialog" tabindex="-1" aria-overlay="true" style="outline: none;">
        <div class="dthlq w-full rez5c">
          <div class="pbhw6">
            <div class="js11s relative md:p-12">
              <div class="flex jz3o6 s5o5a">
                <!-- Header -->
                <div class="kf6hd rdi5h">
                  <h3 class="text-base-content waiii t3mfo">Select payment methods</h3>
                  <p class="text-base-content/80">Supported payment methods</p>
                </div>

                <div class="hqh7v">
                  <!-- Visa Credit Card -->
                  <label class="su23o dh3pr flex lx78o a4n2b items-center justify-between njdg2 m233p">
                    <span class="flex e6ynr items-center njdg2">
                      <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/image-8.png" alt="Visa" class="kymho">
                      <span class="flex e6ynr justify-between max-md:flex-col min-md:items-center">
                        <span class="group-has-checked:text-primary text-base-content text-base font-medium">Visa</span>
                        <span class="group-has-checked:text-primary w0v5f text-sm">Credit Card</span>
                      </span>
                    </span>
                    <input type="radio" name="paymentMethods" class="d6aiv bmjz1 saa4z zwsg8" value="visa">
                  </label>

                  <!-- Mastercard Debit Card -->
                  <label class="su23o dh3pr flex lx78o a4n2b items-center justify-between njdg2 m233p">
                    <span class="flex e6ynr items-center njdg2">
                      <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/image-9.png" alt="Mastercard" class="kymho">
                      <span class="flex e6ynr justify-between max-md:flex-col min-md:items-center">
                        <span class="group-has-checked:text-primary text-base-content text-base font-medium">
                          Mastercard
                        </span>
                        <span class="group-has-checked:text-primary w0v5f text-sm">Debit Card</span>
                      </span>
                    </span>
                    <input type="radio" name="paymentMethods" class="d6aiv bmjz1 saa4z zwsg8" value="mastercard">
                  </label>

                  <!-- American Express Credit Card -->
                  <label class="su23o dh3pr flex lx78o a4n2b items-center justify-between njdg2 m233p">
                    <span class="flex e6ynr items-center njdg2">
                      <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/image-10.png" alt="American Express" class="kymho">
                      <span class="flex e6ynr justify-between max-md:flex-col min-md:items-center">
                        <span class="group-has-checked:text-primary text-base-content text-base font-medium">
                          American Express
                        </span>
                        <span class="group-has-checked:text-primary w0v5f text-sm">Credit Card</span>
                      </span>
                    </span>
                    <input type="radio" name="paymentMethods" class="d6aiv bmjz1 saa4z zwsg8" value="amex" checked="">
                  </label>

                  <!-- JCB Debit Card -->
                  <label class="su23o dh3pr flex lx78o a4n2b items-center justify-between njdg2 m233p">
                    <span class="flex e6ynr items-center njdg2">
                      <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/image-11.png" alt="JCB" class="kymho">
                      <span class="flex e6ynr justify-between max-md:flex-col min-md:items-center">
                        <span class="group-has-checked:text-primary text-base-content text-base font-medium">JCB</span>
                        <span class="group-has-checked:text-primary w0v5f text-sm">Debit Card</span>
                      </span>
                    </span>
                    <input type="radio" name="paymentMethods" class="d6aiv bmjz1 saa4z zwsg8" value="jcb">
                  </label>

                  <!-- Diners Club Credit Card -->
                  <label class="su23o dh3pr flex lx78o a4n2b items-center justify-between njdg2 m233p">
                    <span class="flex e6ynr items-center njdg2">
                      <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/image-12.png" alt="Diners Club" class="kymho">
                      <span class="flex e6ynr justify-between max-md:flex-col min-md:items-center">
                        <span class="group-has-checked:text-primary text-base-content text-base font-medium">
                          Diners Club
                        </span>
                        <span class="group-has-checked:text-primary w0v5f text-sm">Credit Card</span>
                      </span>
                    </span>
                    <input type="radio" name="paymentMethods" class="d6aiv bmjz1 saa4z zwsg8" value="diners">
                  </label>
                </div>
              </div>
              <button class="btn btn-circle btn-sm btn-text absolute w3z1y psag3" aria-label="Close" data-overlay="#payment-methods" aria-expanded="true">
                <span class="icon-[tabler--x] text-base-content size-4"></span>
              </button>
            </div>
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

  <script>
    window.addEventListener("load", () => {
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#payment-methods")
      })
    })
  </script>
  

<div id="payment-methods-backdrop" data-overlay-backdrop-template="" style="z-index: 79;" class="overlay-backdrop transition duration-300 fixed inset-0 bg-base-300/60 overflow-y-auto "></div></body>


<body data-vh-checked="true" style="overflow: hidden;">
  <div class="dhabr flex min-h-screen jz3o6 items-center fbpri">
    <div class="dropdown relative inline-flex [--auto-close:inside] [--placement:bottom]">
      <button type="button" class="btn btn-soft btn-square kqeru" aria-haspopup="dialog" aria-expanded="true" aria-controls="activity-drawer" data-overlay="#activity-drawer">
        <span class="icon-[tabler--activity] mhx2u"></span>
      </button>
      <!-- Activity Drawer Content  -->
      <div id="activity-drawer" class="overlay overlay-open:translate-x-0 vxjzc jbh7e sm:max-w-104 open opened" role="dialog" tabindex="-1" aria-overlay="true" style="outline: none;">
        <div class="a5p6s border-base-content/20 w2qmy p-4">
          <h3 class="eul36 text-base t3mfo">Activity</h3>
          <button type="button" class="btn btn-text btn-circle geut3" aria-label="Close" data-overlay="#activity-drawer" aria-expanded="true">
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

  <script>
    window.addEventListener("load", () => {
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#activity-drawer")
      })
    })
  </script>
  

<div id="activity-drawer-backdrop" data-overlay-backdrop-template="" style="z-index: 79;" class="overlay-backdrop transition duration-300 fixed inset-0 bg-base-300/60 overflow-y-auto "></div></body>


<body data-vh-checked="true" style="overflow: hidden;">
  <div class="dhabr h-dvh i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 j2be9 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button type="button" class="btn btn-primary" aria-haspopup="dialog" aria-expanded="true" aria-controls="update-product" data-overlay="#update-product">
          Open modal
        </button>
      </div>

      <div id="update-product" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 open opened" role="dialog" tabindex="-1" aria-overlay="true" style="outline: none;">
        <div class="dthlq w-full m9sab">
          <div class="pbhw6">
            <!-- Header -->
            <div class="m1ukj">
              <h3 class="text-base-content waiii t3mfo">Update Product</h3>
              <button type="button" class="btn btn-text btn-circle btn-sm absolute c6rnh vv66w" aria-label="Close" data-overlay="#update-product" aria-expanded="true">
                <span class="icon-[tabler--x] size-4"></span>
              </button>
            </div>
            <div class="js11s">
              <form class="flex jz3o6 ip6vv">
                <!-- Form Fields -->
                <div class="hqh7v">
                  <!-- Product Name and Category Row -->
                  <div class="dpzny wfsyj njdg2 md:grid-cols-2">
                    <div>
                      <label class="wqwbi" for="product-name">Product Name</label>
                      <input type="text" value="Apple iMac 4" class="ljn0d fo8mv" id="product-name" required="">
                    </div>
                    <div>
                      <label for="product-category" class="wqwbi">Category</label>
                      <select class="select" id="product-category" required="">
                        <option value="">Select category</option>
                        <option value="electronics" selected="">Electronics</option>
                        <option value="computers">Computers</option>
                        <option value="accessories">Accessories</option>
                      </select>
                    </div>
                  </div>

                  <!-- Brand and Price Row -->
                  <div class="dpzny wfsyj njdg2 md:grid-cols-2">
                    <div>
                      <label class="wqwbi" for="product-brand">Brand</label>
                      <input type="text" value="Apple" class="ljn0d fo8mv" id="product-brand" required="">
                    </div>
                    <div>
                      <label class="wqwbi" for="product-price">Price</label>
                      <input type="text" value="$1299" class="ljn0d fo8mv" id="product-price" required="">
                    </div>
                  </div>

                  <!-- Specifications Row -->
                  <div class="dpzny wfsyj njdg2 md:grid-cols-4">
                    <div>
                      <label for="product-weight" class="wqwbi">Weight (kg)</label>
                      <input type="text" value="1.2" class="ljn0d fo8mv" id="product-weight" required="">
                    </div>
                    <div>
                      <label for="product-length" class="wqwbi">Length (cm)</label>
                      <input type="text" value="126" class="ljn0d fo8mv" id="product-length" required="">
                    </div>
                    <div>
                      <label for="product-breadth" class="wqwbi">Breadth (cm)</label>
                      <input type="text" value="121" class="ljn0d fo8mv" id="product-breadth" required="">
                    </div>
                    <div>
                      <label for="product-width" class="wqwbi">Width (cm)</label>
                      <input type="text" value="95.5" class="ljn0d fo8mv" id="product-width" required="">
                    </div>
                  </div>

                  <!-- Description -->
                  <div>
                    <label class="wqwbi" for="product-description">Description</label>
                    <textarea class="ystrl" id="product-description" rows="3" placeholder="Type here" required=""></textarea>
                  </div>
                </div>

                <!-- Store Type Radio Buttons -->
                <div class="flex mnhlk ip6vv">
                  <div class="flex items-center">
                    <input type="radio" name="store-type" class="d6aiv zwsg8 bmjz1" id="online-store">
                    <label class="wqwbi lx78o" for="online-store">Online Store</label>
                  </div>
                  <div class="flex items-center">
                    <input type="radio" name="store-type" class="d6aiv zwsg8 bmjz1" id="both-store" checked="">
                    <label class="wqwbi lx78o" for="both-store">Both in-store and online</label>
                  </div>
                  <div class="flex items-center">
                    <input type="radio" name="store-type" class="d6aiv zwsg8 bmjz1" id="offline-store">
                    <label class="wqwbi lx78o" for="offline-store">Offline Store</label>
                  </div>
                </div>

                <!-- File Upload Area -->
                <div>
                  <div class="zqxh1">
                    <div class="dpzny qoht8 njdg2 md:grid-cols-4">
                      <!-- Product Image 1 -->
                      <div class="dh3pr relative" id="update-product-item-image-1">
                        <div class="rounded-box gkimh overflow-hidden aezmk">
                          <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/image-3.png" alt="Product image 1" class="size-full c7ys3">
                        </div>
                        <button type="button" class="btn btn-circle geut3 gauh6 absolute k2sgp vow90 opacity-0 os7ww group-hover:opacity-100" data-remove-element="#update-product-item-image-1">
                          <span class="icon-[tabler--x] tdit1"></span>
                        </button>
                      </div>

                      <!-- Product Image 2 -->
                      <div class="dh3pr relative" id="update-product-item-image-2">
                        <div class="rounded-box gkimh overflow-hidden aezmk">
                          <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/image-4.png" alt="Product image 2" class="size-full c7ys3">
                        </div>
                        <button type="button" class="btn btn-circle geut3 gauh6 absolute k2sgp vow90 opacity-0 os7ww group-hover:opacity-100" data-remove-element="#update-product-item-image-2">
                          <span class="icon-[tabler--x] tdit1"></span>
                        </button>
                      </div>

                      <!-- Product Image 3 -->
                      <div class="dh3pr relative" id="update-product-item-image-3">
                        <div class="rounded-box gkimh overflow-hidden aezmk">
                          <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/image-5.png" alt="Product image 3" class="size-full c7ys3">
                        </div>
                        <button type="button" class="btn btn-circle geut3 gauh6 absolute k2sgp vow90 opacity-0 os7ww group-hover:opacity-100" data-remove-element="#update-product-item-image-3">
                          <span class="icon-[tabler--x] tdit1"></span>
                        </button>
                      </div>

                      <!-- Product Image 4 -->
                      <div class="dh3pr relative" id="update-product-item-image-4">
                        <div class="rounded-box gkimh overflow-hidden aezmk">
                          <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/image-6.png" alt="Product image 4" class="size-full c7ys3">
                        </div>
                        <button type="button" class="btn btn-circle geut3 gauh6 absolute k2sgp vow90 opacity-0 os7ww group-hover:opacity-100" data-remove-element="#update-product-item-image-4">
                          <span class="icon-[tabler--x] tdit1"></span>
                        </button>
                      </div>
                    </div>
                  </div>
                  <div data-file-upload="{
                        &quot;url&quot;: &quot;/upload&quot;,
                        &quot;acceptedFiles&quot;: &quot;image/*&quot;,
                        &quot;autoHideTrigger&quot;: false,
                        &quot;extensions&quot;: {
                          &quot;jpg&quot;: {
                            &quot;icon&quot;: &quot;&lt;svg xmlns=\&quot;http://www.w3.org/2000/svg\&quot; width=\&quot;24\&quot; height=\&quot;24\&quot; viewBox=\&quot;0 0 24 24\&quot; fill=\&quot;none\&quot; stroke=\&quot;currentColor\&quot; stroke-width=\&quot;2\&quot; stroke-linecap=\&quot;round\&quot; stroke-linejoin=\&quot;round\&quot;&gt;&lt;rect width=\&quot;18\&quot; height=\&quot;18\&quot; x=\&quot;3\&quot; y=\&quot;3\&quot; rx=\&quot;2\&quot; ry=\&quot;2\&quot;/&gt;&lt;circle cx=\&quot;9\&quot; cy=\&quot;9\&quot; r=\&quot;2\&quot;/&gt;&lt;path d=\&quot;m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21\&quot;/&gt;&lt;/svg&gt;&quot;,
                            &quot;class&quot;: &quot;shrink-0 size-5&quot;
                          },
                          &quot;png&quot;: {
                            &quot;icon&quot;: &quot;&lt;svg xmlns=\&quot;http://www.w3.org/2000/svg\&quot; width=\&quot;24\&quot; height=\&quot;24\&quot; viewBox=\&quot;0 0 24 24\&quot; fill=\&quot;none\&quot; stroke=\&quot;currentColor\&quot; stroke-width=\&quot;2\&quot; stroke-linecap=\&quot;round\&quot; stroke-linejoin=\&quot;round\&quot;&gt;&lt;rect width=\&quot;18\&quot; height=\&quot;18\&quot; x=\&quot;3\&quot; y=\&quot;3\&quot; rx=\&quot;2\&quot; ry=\&quot;2\&quot;/&gt;&lt;circle cx=\&quot;9\&quot; cy=\&quot;9\&quot; r=\&quot;2\&quot;/&gt;&lt;path d=\&quot;m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21\&quot;/&gt;&lt;/svg&gt;&quot;,
                            &quot;class&quot;: &quot;shrink-0 size-5&quot;
                          }
                        }
                      }">
                    <template data-file-upload-preview="">
                      <div class="rounded-box dhabr dh3pr relative gkimh p-4">
                        <img class="rounded-box w-full c7ys3" data-dz-thumbnail="">
                        <button type="button" class="btn btn-circle geut3 gauh6 absolute k2sgp vow90 opacity-0 os7ww group-hover:opacity-100" data-file-upload-remove="">
                          <span class="icon-[tabler--x] tdit1"></span>
                        </button>
                      </div>
                    </template>
                    <div class="bhs4g dpzny qoht8 njdg2 empty:my-0 md:grid-cols-4" data-file-upload-previews=""></div>
                    <div class="border-base-content/20 rounded-box flex cb40p lx78o items-center justify-center vpx91 dkr8s fbpri dz-clickable" data-file-upload-trigger="">
                      <div class="hqh7v rdi5h">
                        <span class="icon-[tabler--upload] text-base-content j4z3m"></span>
                        <h4 class="text-base-content t3mfo">Drag &amp; Drop or Choose file to upload</h4>
                        <p class="text-base-content/50 text-sm t3mfo">JPEG or PNG</p>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Footer Actions -->
                <div class="flex mnhlk items-center edy4p njdg2">
                  <button type="submit" class="btn btn-primary">Update Product</button>
                  <button type="button" class="btn g2v48 gauh6" data-overlay="#update-product" aria-expanded="true">Delete</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script src="https://flyonui.becdn.net/pro/libs/lodash/lodash.min.js"></script>
  <script src="https://flyonui.becdn.net/pro/libs/dropzone/dist/dropzone-min.js"></script>

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
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#update-product")
      })
    })
  </script>
  

<input type="file" multiple="multiple" class="dz-hidden-input" accept="image/*" tabindex="-1" style="visibility: hidden; position: absolute; top: 0px; left: 0px; height: 0px; width: 0px;"><div id="update-product-backdrop" data-overlay-backdrop-template="" style="z-index: 79;" class="overlay-backdrop transition duration-300 fixed inset-0 bg-base-300/60 overflow-y-auto "></div></body>

<body data-vh-checked="true" style="overflow: hidden;">
  <div class="dhabr h-dvh i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 j2be9 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button type="button" class="btn btn-primary" aria-haspopup="dialog" aria-expanded="true" aria-controls="add-new-card" data-overlay="#add-new-card">
          Open modal
        </button>
      </div>

      <div id="add-new-card" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 open opened" role="dialog" tabindex="-1" aria-overlay="true" style="outline: none;">
        <div class="dthlq w-full kv2oj">
          <div class="pbhw6">
            <div class="js11s relative yyuvw">
              <form class="flex w-full jz3o6 ip6vv">
                <!-- Header -->
                <div class="kf6hd rdi5h">
                  <h3 class="text-base-content waiii t3mfo">Add New Card</h3>
                  <p class="text-base-content/80">Add new card to complete payment</p>
                </div>

                <!-- Form Fields -->
                <div class="o63tj">
                  <!-- Card Number -->
                  <div>
                    <label class="wqwbi" for="card-number">Card Number</label>
                    <div class="ljn0d">
                      <span class="icon-[tabler--credit-card] text-base-content/80 q7z0e xn3np size-5 shrink-0"></span>
                      <input type="text" placeholder="1234 1234 1234 1234" class="sxihv" id="card-number" required="">
                    </div>
                  </div>

                  <!-- Name, Expiration Date, CVV Row -->
                  <div class="dpzny wfsyj ip6vv sm:grid-cols-2 lg:grid-cols-4">
                    <!-- Name -->
                    <div class="sm:col-span-2">
                      <label for="cardholder-name" class="wqwbi">Name</label>
                      <input type="text" placeholder="John doe" class="ljn0d" id="cardholder-name" required="">
                    </div>

                    <!-- Expiration Date -->
                    <div>
                      <label for="expiration-date" class="wqwbi">Expiration Date</label>
                      <div class="ljn0d">
                        <span class="icon-[tabler--calendar] text-base-content/80 q7z0e xn3np size-5 shrink-0"></span>
                        <input type="text" placeholder="12/25" class="sxihv" id="expiration-date" required="">
                      </div>
                    </div>

                    <!-- CVV -->
                    <div>
                      <label for="cvv" class="wqwbi">CVV</label>
                      <div class="ljn0d">
                        <span class="icon-[tabler--lock] text-base-content/80 q7z0e xn3np size-5 shrink-0"></span>
                        <input type="text" placeholder="123" class="sxihv" id="cvv" required="" maxlength="4">
                      </div>
                    </div>
                  </div>

                  <!-- Save Card Checkbox -->
                  <div class="flex items-center rsqkx">
                    <input type="checkbox" class="q0yur bqy1f" id="save-card">
                    <label class="wqwbi text-base" for="save-card">Save card for future billing?</label>
                  </div>
                </div>

                <!-- Footer Actions -->
                <div class="flex mnhlk items-center justify-center njdg2">
                  <button type="submit" class="btn btn-primary">Submit</button>
                  <button type="button" class="btn gnw6d" data-overlay="#add-new-card" aria-expanded="true">Cancel</button>
                </div>
              </form>
              <button class="btn btn-circle btn-sm btn-text absolute w3z1y psag3" aria-label="Close" data-overlay="#add-new-card" aria-expanded="true">
                <span class="icon-[tabler--x] text-base-content size-4"></span>
              </button>
            </div>
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

  <script>
    window.addEventListener("load", () => {
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#add-new-card")
      })
    })
  </script>
  

<div id="add-new-card-backdrop" data-overlay-backdrop-template="" style="z-index: 79;" class="overlay-backdrop transition duration-300 fixed inset-0 bg-base-300/60 overflow-y-auto "></div></body>

<body data-vh-checked="true" style="overflow: hidden;">
  <div class="dhabr h-dvh i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 j2be9 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button type="button" class="btn btn-primary" aria-haspopup="dialog" aria-expanded="true" aria-controls="add-new-address" data-overlay="#add-new-address">
          Open modal
        </button>
      </div>

      <div id="add-new-address" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 open opened" role="dialog" tabindex="-1" aria-overlay="true" style="outline: none;">
        <div class="dthlq w-full edp49">
          <div class="pbhw6">
            <div class="js11s relative yyuvw">
              <form class="flex jz3o6 ip6vv">
                <!-- Header -->
                <div class="kf6hd rdi5h">
                  <h3 class="text-base-content waiii t3mfo">Add New Address</h3>
                  <p class="text-base-content/80">Add new address for express delivery</p>
                </div>

                <!-- Form Fields -->
                <div class="o63tj">
                  <!-- Delivery Options -->
                  <div class="flex w-full qojvm ip6vv max-sm:flex-wrap">
                    <label class="w6ln6 flex jz3o6 items-center sly4q rdi5h sm:w-1/2">
                      <span class="icon-[tabler--home] j4z3m"></span>
                      <span class="wqwbi flex jz3o6">
                        <span class="mb-1 text-base font-medium">Home</span>
                        <span class="text-base-content/80">Delivery time (9am - 9pm)</span>
                      </span>
                      <input type="radio" name="delivery-type" class="d6aiv saa4z bmjz1 zwsg8">
                    </label>
                    <label class="w6ln6 flex jz3o6 items-center sly4q rdi5h sm:w-1/2">
                      <span class="icon-[tabler--crown] j4z3m"></span>
                      <span class="wqwbi flex jz3o6">
                        <span class="mb-1 text-base font-medium">Office</span>
                        <span class="text-base-content/80">Delivery time (9am - 5pm)</span>
                      </span>
                      <input type="radio" name="delivery-type" class="d6aiv saa4z bmjz1 zwsg8" checked="">
                    </label>
                  </div>

                  <!-- First Name and Last Name Row -->
                  <div class="dpzny wfsyj ip6vv sm:grid-cols-2">
                    <div>
                      <label class="wqwbi" for="first-name">First Name</label>
                      <input type="text" placeholder="John" class="ljn0d" id="first-name" required="">
                    </div>
                    <div>
                      <label class="wqwbi" for="last-name">Last Name</label>
                      <input type="text" placeholder="" class="ljn0d" id="last-name" required="">
                    </div>
                  </div>

                  <!-- Country -->
                  <div>
                    <label class="wqwbi" for="country">Country</label>
                    <select class="select" id="country" required="">
                      <option value="">Select Country</option>
                      <option value="us" selected="">United States</option>
                      <option value="ca">Canada</option>
                      <option value="uk">United Kingdom</option>
                      <option value="au">Australia</option>
                    </select>
                  </div>

                  <!-- Address Line 1 -->
                  <div>
                    <label class="wqwbi" for="address-line-1">Address Line 1</label>
                    <input type="text" placeholder="12 business road" class="ljn0d" id="address-line-1" required="">
                  </div>

                  <!-- Address Line 2 -->
                  <div>
                    <label class="wqwbi" for="address-line-2">Address Line 2</label>
                    <input type="text" placeholder="Mall Road" class="ljn0d" id="address-line-2">
                  </div>

                  <!-- Landmark, City, Zip Code Row -->
                  <div class="dpzny wfsyj ip6vv sm:grid-cols-2">
                    <div>
                      <label class="wqwbi" for="landmark">Landmark</label>
                      <input type="text" placeholder="Ni-alit in one mall" class="ljn0d" id="landmark">
                    </div>
                    <div>
                      <label class="wqwbi" for="city">City</label>
                      <input type="text" placeholder="Los Angeles" class="ljn0d" id="city" required="">
                    </div>
                    <div>
                      <label class="wqwbi" for="state">State</label>
                      <select class="select" id="state" required="">
                        <option value="">Select State</option>
                        <option value="ca" selected="">California</option>
                        <option value="ny">New York</option>
                        <option value="tx">Texas</option>
                        <option value="fl">Florida</option>
                      </select>
                    </div>
                    <div>
                      <label class="wqwbi" for="zip-code">Zip Code</label>
                      <input type="text" placeholder="000000" class="ljn0d" id="zip-code" required="">
                    </div>
                  </div>

                  <!-- Use as billing address checkbox -->
                  <div class="flex items-center bglhu">
                    <input type="checkbox" class="q0yur bqy1f" id="billing-address">
                    <label class="text-base-content lx78o" for="billing-address">
                      Use as a billing address?
                    </label>
                  </div>
                </div>

                <!-- Footer Actions -->
                <div class="flex mnhlk items-center justify-center njdg2">
                  <button type="submit" class="btn btn-primary">Submit</button>
                  <button type="button" class="btn gnw6d" data-overlay="#add-new-address" aria-expanded="true">Cancel</button>
                </div>
              </form>
              <button class="btn btn-circle geut3 btn-text absolute c6rnh vv66w" aria-label="Close" data-overlay="#add-new-address" aria-expanded="true">
                <span class="icon-[tabler--x] text-base-content size-4"></span>
              </button>
            </div>
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

  <script>
    window.addEventListener("load", () => {
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#add-new-address")
      })
    })
  </script>
  

<div id="add-new-address-backdrop" data-overlay-backdrop-template="" style="z-index: 79;" class="overlay-backdrop transition duration-300 fixed inset-0 bg-base-300/60 overflow-y-auto "></div></body>

<body data-vh-checked="true" style="overflow: hidden;">
  <div class="dhabr h-dvh i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 j2be9 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button type="button" class="btn btn-primary" aria-haspopup="dialog" aria-expanded="true" aria-controls="refer-earn" data-overlay="#refer-earn">
          Open modal
        </button>
      </div>

      <div id="refer-earn" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 open opened" role="dialog" tabindex="-1" aria-overlay="true" style="outline: none;">
        <div class="dthlq w-full ghuo1">
          <div class="pbhw6">
            <div class="js11s relative yyuvw">
              <div class="flex jz3o6 k6gdi">
                <!-- Header -->
                <div class="kf6hd rdi5h">
                  <h3 class="text-base-content waiii t3mfo">Refer &amp; Earn</h3>
                  <p class="text-base-content/80">Invite a friend to Flyon and you'll both get 30 days free!</p>
                </div>

                <!-- Steps -->
                <div class="dpzny wfsyj ip6vv md:grid-cols-3">
                  <!-- Step 1: Send Invitation -->
                  <div class="rdi5h">
                    <div class="nfjpm rmjll s7x45">
                      <div class="uyq3n text-primary rounded-field tdv60">
                        <span class="icon-[tabler--send] size-8"></span>
                      </div>
                    </div>
                    <h4 class="text-base-content axeut c9rvi font-medium">Send Invitation</h4>
                    <p class="text-base-content/80">Send your referral link to your friend</p>
                  </div>

                  <!-- Step 2: Registration -->
                  <div class="rdi5h">
                    <div class="nfjpm rmjll s7x45">
                      <div class="uyq3n text-primary rounded-field tdv60">
                        <span class="icon-[tabler--external-link] size-8"></span>
                      </div>
                    </div>
                    <h4 class="text-base-content axeut c9rvi font-medium">Registration</h4>
                    <p class="text-base-content/80">Let them register to our platform</p>
                  </div>

                  <!-- Step 3: Free Trial -->
                  <div class="rdi5h">
                    <div class="nfjpm rmjll s7x45">
                      <div class="uyq3n text-primary rounded-field tdv60">
                        <span class="icon-[tabler--gift] size-8"></span>
                      </div>
                    </div>
                    <h4 class="text-base-content axeut c9rvi font-medium">Free Trial</h4>
                    <p class="text-base-content/80">Your friend will get 30 days free trial</p>
                  </div>
                </div>

                <div class="ck7pw"></div>

                <!-- Invite Your Friends Section -->
                <div>
                  <h4 class="text-base-content oobh7 c9rvi font-medium">Invite your friends</h4>
                  <p class="wqwbi">Enter your friend's email address and invite them to join Flyon 😊</p>

                  <div class="flex ip6vv">
                    <input type="email" placeholder="Example@gmail.com" class="ljn0d e6ynr" id="friend-email">
                    <button type="button" class="btn btn-primary">Send</button>
                  </div>
                </div>

                <!-- Share Referral Link Section -->
                <div>
                  <h4 class="text-base-content oobh7 c9rvi font-medium">Share the referral link</h4>
                  <p class="wqwbi">You can also copy and send it or share it on your social media 🤝</p>

                  <div class="flex items-center ip6vv">
                    <label class="ljn0d flex sxihv ip6vv">
                      <input id="clipboard-input-group" type="text" class="sxihv" value="https://themeselection.com">
                      <button type="button" class="js-clipboard q7z0e size-5" aria-label="Copy text to clipboard" data-clipboard-target="#clipboard-input-group" data-clipboard-action="copy">
                        <span class="js-clipboard-default icon-[tabler--copy] size-5 transition"></span>
                        <span class="js-clipboard-success icon-[tabler--copy] text-primary hidden size-5"></span>
                      </button>
                    </label>
                    <div class="flex items-center sly4q">
                      <a href="#" class="btn btn-square g2v48 vg9pg f1870" aria-label="Outline Icon Button">
                        <img src="https://cdn.flyonui.com/fy-assets/pro/platforms/x.png" class="y3ekz rounded-full" alt="Outline Icon Button">
                      </a>
                      <a href="#" class="btn btn-square g2v48 vg9pg f1870" aria-label="Outline Icon Button">
                        <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/facebook-icon.png" class="y3ekz rounded-full" alt="Outline Icon Button">
                      </a>
                      <a href="#" class="btn btn-square g2v48 vg9pg f1870" aria-label="Outline Icon Button">
                        <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/github-icon.png" class="y3ekz rounded-full" alt="Outline Icon Button">
                      </a>
                    </div>
                  </div>
                </div>
              </div>
              <button class="btn btn-circle btn-sm btn-text absolute w3z1y psag3" aria-label="Close" data-overlay="#refer-earn" aria-expanded="true">
                <span class="icon-[tabler--x] text-base-content size-4"></span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script src="https://flyonui.becdn.net/pro/libs/clipboard/dist/clipboard.min.js"></script>
  <script src="https://flyonui.becdn.net/pro/libs/flyonui/dist/helper-clipboard.js"></script>

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
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#refer-earn")
      })
    })
  </script>
  

<div id="refer-earn-backdrop" data-overlay-backdrop-template="" style="z-index: 79;" class="overlay-backdrop transition duration-300 fixed inset-0 bg-base-300/60 overflow-y-auto "></div></body>


<body data-vh-checked="true" style="overflow: hidden;">
  <div class="dhabr h-dvh i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 j2be9 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button type="button" class="btn btn-primary" aria-haspopup="dialog" aria-expanded="true" aria-controls="share-project" data-overlay="#share-project">
          Open modal
        </button>
      </div>

      <!-- Share Project Modal -->
      <div id="share-project" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 open opened" role="dialog" tabindex="-1" aria-overlay="true" style="outline: none;">
        <div class="dthlq w-full jnv8g">
          <div class="pbhw6">
            <div class="m1ukj">
              <div class="w-full kf6hd rdi5h">
                <h3 class="text-base-content waiii t3mfo">Share Project</h3>
                <p class="text-base-content/80">Share project with a team member</p>
              </div>
              <button type="button" class="btn btn-text btn-circle btn-sm absolute c6rnh vv66w" aria-label="Close" data-overlay="#share-project" aria-expanded="true">
                <span class="icon-[tabler--x] size-4"></span>
              </button>
            </div>

            <div class="js11s o63tj">
              <!-- Add Members Section -->
              <div>
                <label for="members" class="text-base-content mb-2 block">Add Members</label>
                <div class="advance-select relative"><select data-select="{&quot;placeholder&quot;:&quot;Select option...&quot;,&quot;toggleTag&quot;:&quot;&lt;button type=\&quot;button\&quot; aria-expanded=\&quot;false\&quot;&gt;&lt;span class=\&quot;pbo9w xn3np\&quot; data-icon&gt;&lt;/span&gt;&lt;span class=\&quot;text-base-content font-medium text-base\&quot; data-title&gt;&lt;/span&gt;&lt;/button&gt;&quot;,&quot;toggleClasses&quot;:&quot;ayy45 wvgmz items-center&quot;,&quot;dropdownClasses&quot;:&quot;rpouc hqoaq overflow-y-auto&quot;,&quot;optionClasses&quot;:&quot;advance-select-option selected:select-active&quot;,&quot;optionTemplate&quot;:&quot;&lt;div class=\&quot;flex qojvm\&quot;&gt; &lt;div class=\&quot;pbo9w xn3np\&quot; data-icon&gt;&lt;/div&gt; &lt;div&gt; &lt;div class=\&quot;text-base-content font-medium text-base\&quot; data-title&gt;&lt;/div&gt;&lt;div&gt;&lt;/div&gt;&quot;,&quot;extraMarkup&quot;:&quot;&lt;span class=\&quot;icon-[tabler--chevron-down] shrink-0 size-5 text-base-content absolute top-1/2 c6rnh a4kns \&quot;&gt;&lt;/span&gt;&quot;}" class="hidden" id="members" style="display: none;">
                  
                  
                  
                  
                  
                  
                  
                  
                  
                <option value="">Choose</option><option selected="" value="1" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png\&quot; alt=\&quot;Mark Gilbert\&quot; /&gt;&quot;}">
                    Mark Gilbert
                  </option><option value="2" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png\&quot; alt=\&quot;Eugenia Parsons\&quot; /&gt;&quot;}">
                    Eugenia Parsons
                  </option><option value="3" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png\&quot; alt=\&quot;Francis Byrd\&quot; /&gt;&quot;}">
                    Francis Byrd
                  </option><option value="4" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png\&quot; alt=\&quot;Jayden Rogers\&quot; /&gt;&quot;}">
                    Jayden Rogers
                  </option><option value="5" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png\&quot; alt=\&quot;Liam J. Smith\&quot; /&gt;&quot;}">
                    Liam J. Smith
                  </option><option value="6" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png\&quot; alt=\&quot;Sophia A. Chen\&quot; /&gt;&quot;}">
                    Sophia A. Chen
                  </option><option value="7" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png\&quot; alt=\&quot;Rachel S. Johnson\&quot; /&gt;&quot;}">
                    Rachel S. Johnson
                  </option><option value="8" data-select-option="{ &quot;icon&quot;: &quot;&lt;img class=\&quot;rounded-full\&quot; src=\&quot;https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png\&quot; alt=\&quot;Phillip Ekstrom Bothman\&quot; /&gt;&quot;}">
                    Phillip Ekstrom Bothman
                  </option></select><button type="button" aria-expanded="false" class="ayy45 wvgmz items-center"><span class="pbo9w xn3np" data-icon=""><img class="rounded-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="Mark Gilbert"></span><span class="text-base-content font-medium text-base truncate" data-title="">
                    Mark Gilbert
                  </span></button><div data-select-dropdown="" class="absolute top-full hidden rpouc hqoaq overflow-y-auto" role="listbox" tabindex="-1" aria-orientation="vertical"><div data-value="1" data-title-value="
                    Mark Gilbert
                  " tabindex="0" class="cursor-pointer selected advance-select-option selected:select-active" data-id="0"><div class="flex qojvm"> <div class="pbo9w xn3np" data-icon=""><img class="rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="Mark Gilbert"></div> <div> <div class="text-base-content font-medium text-base" data-title="">
                    Mark Gilbert
                  </div><div></div></div></div></div><div data-value="2" data-title-value="
                    Eugenia Parsons
                  " tabindex="1" class="cursor-pointer advance-select-option selected:select-active" data-id="1"><div class="flex qojvm"> <div class="pbo9w xn3np" data-icon=""><img class="rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Eugenia Parsons"></div> <div> <div class="text-base-content font-medium text-base" data-title="">
                    Eugenia Parsons
                  </div><div></div></div></div></div><div data-value="3" data-title-value="
                    Francis Byrd
                  " tabindex="2" class="cursor-pointer advance-select-option selected:select-active" data-id="2"><div class="flex qojvm"> <div class="pbo9w xn3np" data-icon=""><img class="rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="Francis Byrd"></div> <div> <div class="text-base-content font-medium text-base" data-title="">
                    Francis Byrd
                  </div><div></div></div></div></div><div data-value="4" data-title-value="
                    Jayden Rogers
                  " tabindex="3" class="cursor-pointer advance-select-option selected:select-active" data-id="3"><div class="flex qojvm"> <div class="pbo9w xn3np" data-icon=""><img class="rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Jayden Rogers"></div> <div> <div class="text-base-content font-medium text-base" data-title="">
                    Jayden Rogers
                  </div><div></div></div></div></div><div data-value="5" data-title-value="
                    Liam J. Smith
                  " tabindex="4" class="cursor-pointer advance-select-option selected:select-active" data-id="4"><div class="flex qojvm"> <div class="pbo9w xn3np" data-icon=""><img class="rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Liam J. Smith"></div> <div> <div class="text-base-content font-medium text-base" data-title="">
                    Liam J. Smith
                  </div><div></div></div></div></div><div data-value="6" data-title-value="
                    Sophia A. Chen
                  " tabindex="5" class="cursor-pointer advance-select-option selected:select-active" data-id="5"><div class="flex qojvm"> <div class="pbo9w xn3np" data-icon=""><img class="rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Sophia A. Chen"></div> <div> <div class="text-base-content font-medium text-base" data-title="">
                    Sophia A. Chen
                  </div><div></div></div></div></div><div data-value="7" data-title-value="
                    Rachel S. Johnson
                  " tabindex="6" class="cursor-pointer advance-select-option selected:select-active" data-id="6"><div class="flex qojvm"> <div class="pbo9w xn3np" data-icon=""><img class="rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="Rachel S. Johnson"></div> <div> <div class="text-base-content font-medium text-base" data-title="">
                    Rachel S. Johnson
                  </div><div></div></div></div></div><div data-value="8" data-title-value="
                    Phillip Ekstrom Bothman
                  " tabindex="7" class="cursor-pointer advance-select-option selected:select-active" data-id="7"><div class="flex qojvm"> <div class="pbo9w xn3np" data-icon=""><img class="rounded-full max-w-full" src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Phillip Ekstrom Bothman"></div> <div> <div class="text-base-content font-medium text-base" data-title="">
                    Phillip Ekstrom Bothman
                  </div><div></div></div></div></div></div><span class="icon-[tabler--chevron-down] shrink-0 size-5 text-base-content absolute top-1/2 c6rnh a4kns "></span></div>
              </div>

              <!-- Members List Section -->
              <div>
                <h4 class="text-base-content w3dp6 c9rvi font-medium">8 Members</h4>
                <ul class="*:hover:bg-neutral/10 *:rounded-box hqh7v *:flex *:items-center *:gap-3 *:p-1">
                  <li>
                    <div class="nfjpm">
                      <div class="kqy8v rounded-full">
                        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-1.png" alt="User Avatar">
                      </div>
                    </div>
                    <div class="e6ynr">
                      <h6 class="text-base-content font-medium">john Torff</h6>
                      <p class="text-base-content/50 text-sm">john@example.com</p>
                    </div>
                    <div class="dropdown relative inline-flex [--placement:bottom-end]">
                      <button id="dropdown1" type="button" class="dropdown-toggle btn gnw6d btn-text btn-sm max-sm:btn-square" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                        <span class="w0v5f max-sm:hidden">Admin</span>
                        <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 w0v5f size-4"></span>
                      </button>
                      <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown1" tabindex="-1">
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can view</a></li>
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can edit</a></li>
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Owner</a></li>
                      </ul>
                    </div>
                  </li>
                  <li>
                    <div class="nfjpm">
                      <div class="kqy8v rounded-full">
                        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="User Avatar">
                      </div>
                    </div>
                    <div class="e6ynr">
                      <h6 class="text-base-content font-medium">Laura Perez</h6>
                      <p class="text-base-content/50 text-sm">la@example.com</p>
                    </div>
                    <div class="dropdown relative inline-flex [--placement:bottom-end]">
                      <button id="dropdown2" type="button" class="dropdown-toggle btn gnw6d btn-text btn-sm max-sm:btn-square" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                        <span class="w0v5f max-sm:hidden">Can view</span>
                        <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 w0v5f size-4"></span>
                      </button>
                      <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown2" tabindex="-1">
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Admin</a></li>
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can edit</a></li>
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Owner</a></li>
                      </ul>
                    </div>
                  </li>
                  <li>
                    <div class="nfjpm">
                      <div class="kqy8v rounded-full">
                        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="User Avatar">
                      </div>
                    </div>
                    <div class="e6ynr">
                      <h6 class="text-base-content font-medium">Cristofer Torff</h6>
                      <p class="text-base-content/50 text-sm">torff@example.com</p>
                    </div>
                    <div class="dropdown relative inline-flex [--placement:bottom-end]">
                      <button id="dropdown3" type="button" class="dropdown-toggle btn gnw6d btn-text btn-sm max-sm:btn-square" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                        <span class="w0v5f max-sm:hidden">Admin</span>
                        <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 w0v5f size-4"></span>
                      </button>
                      <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown3" tabindex="-1">
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can view</a></li>
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can edit</a></li>
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Owner</a></li>
                      </ul>
                    </div>
                  </li>
                  <li>
                    <div class="nfjpm">
                      <div class="kqy8v rounded-full">
                        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-2.png" alt="User Avatar">
                      </div>
                    </div>
                    <div class="e6ynr">
                      <h6 class="text-base-content font-medium">Sofiya Cerry</h6>
                      <p class="text-base-content/50 text-sm">sofi@example.com</p>
                    </div>
                    <div class="dropdown relative inline-flex [--placement:bottom-end]">
                      <button id="dropdown4" type="button" class="dropdown-toggle btn gnw6d btn-text btn-sm max-sm:btn-square" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                        <span class="w0v5f max-sm:hidden">Can edit</span>
                        <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 w0v5f size-4"></span>
                      </button>
                      <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown4" tabindex="-1">
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can view</a></li>
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Admin</a></li>
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Owner</a></li>
                      </ul>
                    </div>
                  </li>
                  <li>
                    <div class="nfjpm">
                      <div class="kqy8v rounded-full">
                        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-4.png" alt="Phillip Ekstrom Bothman">
                      </div>
                    </div>
                    <div class="e6ynr">
                      <h6 class="text-base-content font-medium">Phillip Ekstrom Bothman</h6>
                      <p class="text-base-content/50 text-sm">phillip@example.com</p>
                    </div>
                    <div class="dropdown relative inline-flex [--placement:bottom-end]">
                      <button id="dropdown1" type="button" class="dropdown-toggle btn gnw6d btn-text btn-sm max-sm:btn-square" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                        <span class="w0v5f max-sm:hidden">Can view</span>
                        <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 w0v5f size-4"></span>
                      </button>
                      <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown1" tabindex="-1">
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can view</a></li>
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can edit</a></li>
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Owner</a></li>
                      </ul>
                    </div>
                  </li>
                  <li>
                    <div class="nfjpm">
                      <div class="kqy8v rounded-full">
                        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Rachel S. Johnson">
                      </div>
                    </div>
                    <div class="e6ynr">
                      <h6 class="text-base-content font-medium">Rachel S. Johnson</h6>
                      <p class="text-base-content/50 text-sm">rjohnson@gmail.com</p>
                    </div>
                    <div class="dropdown relative inline-flex [--placement:bottom-end]">
                      <button id="dropdown2" type="button" class="dropdown-toggle btn gnw6d btn-text btn-sm max-sm:btn-square" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                        <span class="w0v5f max-sm:hidden">Can Edit</span>
                        <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 w0v5f size-4"></span>
                      </button>
                      <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown2" tabindex="-1">
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Admin</a></li>
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can edit</a></li>
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Owner</a></li>
                      </ul>
                    </div>
                  </li>
                  <li>
                    <div class="nfjpm">
                      <div class="kqy8v rounded-full">
                        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-7.png" alt="Sophia A. Chen">
                      </div>
                    </div>
                    <div class="e6ynr">
                      <h6 class="text-base-content font-medium">Sophia A. Chen</h6>
                      <p class="text-base-content/50 text-sm">sophia@example.com</p>
                    </div>
                    <div class="dropdown relative inline-flex [--placement:bottom-end]">
                      <button id="dropdown3" type="button" class="dropdown-toggle btn gnw6d btn-text btn-sm max-sm:btn-square" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                        <span class="w0v5f max-sm:hidden">Can view</span>
                        <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 w0v5f size-4"></span>
                      </button>
                      <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown3" tabindex="-1">
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can view</a></li>
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can edit</a></li>
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Owner</a></li>
                      </ul>
                    </div>
                  </li>
                  <li>
                    <div class="nfjpm">
                      <div class="kqy8v rounded-full">
                        <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-8.png" alt="Liam J. Smith">
                      </div>
                    </div>
                    <div class="e6ynr">
                      <h6 class="text-base-content font-medium">Liam J. Smith</h6>
                      <p class="text-base-content/50 text-sm">ljsmith@email.com</p>
                    </div>
                    <div class="dropdown relative inline-flex [--placement:bottom-end]">
                      <button id="dropdown4" type="button" class="dropdown-toggle btn gnw6d btn-text btn-sm max-sm:btn-square" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                        <span class="w0v5f max-sm:hidden">Can edit</span>
                        <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 w0v5f size-4"></span>
                      </button>
                      <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown4" tabindex="-1">
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Can view</a></li>
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Admin</a></li>
                        <li><a class="dropdown-item px-2 b9hof text-sm" href="#">Owner</a></li>
                      </ul>
                    </div>
                  </li>
                </ul>
              </div>
            </div>

            <!-- Modal Footer -->
            <div class="w3jfd jz3o6 ip6vv">
              <div class="ck7pw"></div>
              <div class="flex w-full items-center justify-between sly4q max-md:flex-col">
                <div class="text-base-content flex items-center sly4q font-medium">
                  <span class="icon-[tabler--user] size-5"></span>
                  <span>Public to FlyonUI - ThemeSelection</span>
                </div>
                <input id="copy-project-link" type="text" class="hidden" value="https://themeselection.com">
                <button type="button" class="btn btn-primary js-clipboard" aria-label="Copy text to clipboard" data-clipboard-target="#copy-project-link" data-clipboard-action="copy">
                  <span class="js-clipboard-default icon-[tabler--copy] size-5 transition"></span>
                  <span class="js-clipboard-success icon-[tabler--copy-check] hidden size-5"></span>
                  Copy Project link
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script src="https://flyonui.becdn.net/pro/libs/clipboard/dist/clipboard.min.js"></script>
  <script src="https://flyonui.becdn.net/pro/libs/flyonui/dist/helper-clipboard.js"></script>

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
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#share-project")
      })
    })
  </script>
  

<div id="share-project-backdrop" data-overlay-backdrop-template="" style="z-index: 79;" class="overlay-backdrop transition duration-300 fixed inset-0 bg-base-300/60 overflow-y-auto "></div></body>


<body data-vh-checked="true" style="overflow: hidden;">
  <div class="dhabr h-dvh i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 j2be9 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button type="button" class="btn btn-primary" aria-haspopup="dialog" aria-expanded="true" aria-controls="share-design" data-overlay="#share-design">
          Open modal
        </button>
      </div>

      <div id="share-design" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 open opened" role="dialog" tabindex="-1" aria-overlay="true" style="outline: none;">
        <div class="dthlq w-full edp49">
          <div class="pbhw6 j5lbz">
            <div class="js11s relative">
              <div class="flex jz3o6 ip6vv">
                <!-- Header -->
                <div class="flex jz3o6 items-center rdi5h">
                  <div class="nfjpm rmjll w3dp6">
                    <div class="ylqpi e9rs7 rpj8y border p-3">
                      <span class="text-primary">
                        <svg width="42" height="42" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
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
                  </div>
                  <h3 class="text-base-content waiii t3mfo">Share FlyonUI Design</h3>
                  <p class="text-base-content/80">Invite your team to review collaborate on this project.</p>
                </div>

                <!-- Sharing Section -->
                <div class="border-base-content/20 rounded-box flex mnhlk items-center justify-between sly4q border f1870">
                  <button class="btn btn-square kqeru y1dss btn-primary">
                    <span class="icon-[tabler--screen-share] mhx2u"></span>
                  </button>
                  <div class="sxihv">
                    <h4 class="text-base-content flex items-center bglhu font-medium">
                      <span>Anyone with the link</span>
                      <span class="icon-[tabler--chevron-down] size-4"></span>
                    </h4>
                    <p class="text-base-content/80 text-sm">flyonui.com/component/button</p>
                  </div>
                  <div class="dropdown relative inline-flex">
                    <button id="dropdown-share-permission" type="button" class="dropdown-toggle btn btn-text" aria-haspopup="menu" aria-expanded="false" aria-label="Dropdown">
                      Can View
                      <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-4"></span>
                    </button>
                    <ul class="dropdown-menu dropdown-open:opacity-100 hidden d2b8g" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-share-permission" tabindex="-1">
                      <li><a class="dropdown-item" href="javascript:;">Can Edit</a></li>
                      <li><a class="dropdown-item" href="javascript:;">Can View</a></li>
                      <li><a class="dropdown-item" href="javascript:;">Can Comment</a></li>
                    </ul>
                  </div>
                </div>

                <!-- People with access -->
                <div>
                  <h4 class="text-base-content mb-2">People with access</h4>
                  <!-- Team Members List -->
                  <ul class="hqh7v">
                    <!-- Search -->
                    <li class="ljn0d fo8mv">
                      <span class="icon-[tabler--search] text-base-content/80 q7z0e me-2 girx5 shrink-0"></span>
                      <label class="rui3g" for="search-team-members">Full Name</label>
                      <input type="text" class="sxihv" placeholder="Search team members" id="search-team-members">
                    </li>
                    <!-- Member 1: Amelie Laurent -->
                    <li class="flex items-center sly4q">
                      <div class="nfjpm">
                        <div class="lt1t7 rounded-full">
                          <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-3.png" alt="Amelie Laurent">
                        </div>
                      </div>
                      <div>
                        <h5 class="text-base-content font-medium">Amelie Laurent</h5>
                        <p class="text-base-content/50 text-sm">oscott@hotmail.com</p>
                      </div>
                      <div class="dropdown relative ms-auto inline-flex">
                        <button id="dropdown-amelie-role" type="button" class="dropdown-toggle btn btn-text btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Role">
                          Owner
                          <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-4"></span>
                        </button>
                        <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-amelie-role" tabindex="-1">
                          <li><a class="dropdown-item px-2 b9hof text-sm" href="javascript:;">Owner</a></li>
                          <li><a class="dropdown-item px-2 b9hof text-sm" href="javascript:;">Editor</a></li>
                          <li><a class="dropdown-item px-2 b9hof text-sm" href="javascript:;">Viewer</a></li>
                        </ul>
                      </div>
                    </li>

                    <!-- Member 2: Maria Donin -->
                    <li class="flex items-center sly4q">
                      <div class="nfjpm">
                        <div class="lt1t7 rounded-full">
                          <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Maria Donin">
                        </div>
                      </div>
                      <div>
                        <h5 class="text-base-content font-medium">Maria Donin</h5>
                        <p class="text-base-content/50 text-sm">egaron@outlook.com</p>
                      </div>
                      <div class="dropdown relative ms-auto inline-flex">
                        <button id="dropdown-maria-role" type="button" class="dropdown-toggle btn btn-text btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Role">
                          Editor
                          <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-4"></span>
                        </button>
                        <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-maria-role" tabindex="-1">
                          <li><a class="dropdown-item px-2 b9hof text-sm" href="javascript:;">Owner</a></li>
                          <li><a class="dropdown-item px-2 b9hof text-sm" href="javascript:;">Editor</a></li>
                          <li><a class="dropdown-item px-2 b9hof text-sm" href="javascript:;">Viewer</a></li>
                        </ul>
                      </div>
                    </li>

                    <!-- Member 3: Phillip Ekstrom Bothman -->
                    <li class="flex items-center sly4q">
                      <div class="nfjpm">
                        <div class="lt1t7 rounded-full">
                          <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-6.png" alt="Phillip Ekstrom">
                        </div>
                      </div>
                      <div>
                        <h5 class="text-base-content font-medium">Phillip Ekstrom Bothman</h5>
                        <p class="text-base-content/50 text-sm">pwilson@aol.com</p>
                      </div>
                      <div class="dropdown relative ms-auto inline-flex">
                        <button id="dropdown-phillip-role" type="button" class="dropdown-toggle btn btn-text btn-sm" aria-haspopup="menu" aria-expanded="false" aria-label="Role">
                          Editor
                          <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-4"></span>
                        </button>
                        <ul class="dropdown-menu dropdown-open:opacity-100 hidden rxznq" role="menu" aria-orientation="vertical" aria-labelledby="dropdown-phillip-role" tabindex="-1">
                          <li><a class="dropdown-item px-2 b9hof text-sm" href="javascript:;">Owner</a></li>
                          <li><a class="dropdown-item px-2 b9hof text-sm" href="javascript:;">Editor</a></li>
                          <li><a class="dropdown-item px-2 b9hof text-sm" href="javascript:;">Viewer</a></li>
                        </ul>
                      </div>
                    </li>
                  </ul>
                </div>

                <hr class="border-base-content/20 une78">

                <!-- Footer Actions -->
                <div class="flex mnhlk items-center njdg2">
                  <button type="button" class="btn btn-soft btn-primary">
                    <span class="icon-[tabler--copy] size-5"></span>
                    Copy Link
                  </button>
                  <button type="button" class="btn g2v48">
                    <span class="icon-[tabler--code] size-5"></span>
                    Embed
                  </button>
                  <button type="button" class="btn btn-primary ms-auto">Save</button>
                </div>
              </div>

              <!-- Close Button -->
              <button class="btn btn-circle btn-sm btn-text absolute w3z1y psag3" aria-label="Close" data-overlay="#share-design" aria-expanded="true">
                <span class="icon-[tabler--x] text-base-content size-4"></span>
              </button>
            </div>
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

  <script>
    window.addEventListener("load", () => {
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#share-design")
      })
    })
  </script>
  

<div id="share-design-backdrop" data-overlay-backdrop-template="" style="z-index: 79;" class="overlay-backdrop transition duration-300 fixed inset-0 bg-base-300/60 overflow-y-auto "></div></body>


<body data-vh-checked="true" style="overflow: hidden;">
  <div class="dhabr h-dvh i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 j2be9 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button type="button" class="btn btn-primary" aria-haspopup="dialog" aria-expanded="true" aria-controls="search-modal" data-overlay="#search-modal">
          Open modal
        </button>
      </div>

      <div id="search-modal" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 open opened" role="dialog" tabindex="-1" aria-overlay="true" style="outline: none;">
        <div class="dthlq w-full zr8jv">
          <div class="pbhw6 j5lbz">
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

  <script>
    window.addEventListener("load", () => {
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#search-modal")
      })
    })
  </script>
  

<div id="search-modal-backdrop" data-overlay-backdrop-template="" style="z-index: 79;" class="overlay-backdrop transition duration-300 fixed inset-0 bg-base-300/60 overflow-y-auto "></div></body>


<body data-vh-checked="true" style="overflow: hidden;">
  <div class="dhabr h-dvh i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 j2be9 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button type="button" class="btn btn-primary" aria-haspopup="dialog" aria-expanded="true" aria-controls="add-payment-method" data-overlay="#add-payment-method">
          Open modal
        </button>
      </div>

      <div id="add-payment-method" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 open opened" role="dialog" tabindex="-1" aria-overlay="true" style="outline: none;">
        <div class="dthlq w-full vxt48">
          <div class="pbhw6 j5lbz">
            <div class="js11s relative">
              <form class="flex jz3o6 ip6vv">
                <!-- Header -->
                <div class="flex items-center njdg2">
                  <div class="nfjpm rmjll max-sm:hidden">
                    <div class="border-base-content/20 rounded-box kf4wy j8wvb">
                      <span class="icon-[tabler--credit-card] size-8"></span>
                    </div>
                  </div>
                  <div class="kf6hd">
                    <h3 class="text-base-content waiii t3mfo">Add Payment Method</h3>
                    <p class="text-base-content/80">Add a payment method to active plan</p>
                  </div>
                </div>

                <!-- Credit Card Visual -->
                <div class="dhabr rounded-box flex items-center justify-center rukzz fnetp lg:py-18">
                  <img src="https://cdn.flyonui.com/fy-assets/blocks/dashboard-app/dashboard-modals/image-1.png" alt="Credit Card Visual" class="rounded-box w-full yymzl">
                </div>

                <!-- Form Fields -->
                <div class="dpzny wfsyj njdg2 md:grid-cols-2 lg:grid-cols-3">
                  <!-- Name on card -->
                  <div class="lg:col-span-2">
                    <label class="text-base-content mb-1 block text-sm" for="card-holder-name">Name on card</label>
                    <input type="text" placeholder="John Doe" class="ljn0d" id="card-holder-name" value="Oliver Pitter" required="">
                  </div>

                  <!-- Expiry -->
                  <div>
                    <label for="card-expiry" class="text-base-content mb-1 block text-sm">Expiry</label>
                    <input class="ljn0d" type="text" placeholder="MM/YY" id="card-expiry" value="08/28" required="">
                  </div>

                  <!-- Card Number -->
                  <div class="lg:col-span-2">
                    <label for="card-number" class="text-base-content mb-1 block text-sm">Card Number</label>
                    <div class="ljn0d">
                      <span class="icon-[tabler--credit-card] text-base-content/80 q7z0e xn3np size-5 shrink-0"></span>
                      <input type="number" placeholder="xxxx xxxx xxxx xxxx" class="sxihv" id="card-number" required="">
                    </div>
                  </div>

                  <!-- CVV -->
                  <div>
                    <label for="card-cvv" class="text-base-content mb-1 block text-sm">CVV</label>
                    <input type="text" placeholder="***" class="ljn0d" id="card-cvv" required="">
                  </div>
                </div>

                <!-- Footer Actions -->
                <div class="flex mnhlk items-center edy4p njdg2">
                  <button type="button" class="btn g2v48 gnw6d" data-overlay="#add-payment-method" aria-expanded="true">
                    Cancel
                  </button>
                  <button type="submit" class="btn btn-primary">Add Card Details</button>
                </div>
              </form>
              <button class="btn btn-circle btn-sm btn-text absolute w3z1y psag3" aria-label="Close" data-overlay="#add-payment-method" aria-expanded="true">
                <span class="icon-[tabler--x] text-base-content size-4"></span>
              </button>
            </div>
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

  <script>
    window.addEventListener("load", () => {
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#add-payment-method")
      })
    })
  </script>
  

<div id="add-payment-method-backdrop" data-overlay-backdrop-template="" style="z-index: 79;" class="overlay-backdrop transition duration-300 fixed inset-0 bg-base-300/60 overflow-y-auto "></div></body>

<body data-vh-checked="true" style="">
  <div class="dhabr h-dvh i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 j2be9 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button type="button" class="btn btn-primary" aria-haspopup="dialog" aria-expanded="false" aria-controls="choose-seats" data-overlay="#choose-seats">
          Open modal
        </button>
      </div>

      <div id="choose-seats" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 hidden" role="dialog" style="">
        <div class="dthlq w-full pxnxg">
          <div class="pbhw6 j5lbz">
            <div class="js11s relative">
              <div class="flex jz3o6 ip6vv">
                <!-- Header -->
                <div class="kf6hd">
                  <h3 class="text-base-content waiii t3mfo">Choose Seats</h3>
                  <p class="text-base-content/80">Select how many seats you need in your plan.</p>
                </div>

                <!-- Seats Selection -->
                <h5 id="choose-seats-target" class="text-base-content rdi5h jehtf t3mfo lg:py-4">12</h5>
                <div id="seats-target" class="--prevent-on-load-init noUi-target relative h-3 rounded-full bg-neutral/10 noUi-ltr noUi-horizontal noUi-txt-dir-ltr" data-range-slider="{
                    &quot;start&quot;: 12,
                    &quot;connect&quot;: &quot;lower&quot;,
                    &quot;range&quot;: {
                      &quot;min&quot;: 0,
                      &quot;max&quot;: 24
                    },
                    &quot;cssClasses&quot;: {
                      &quot;target&quot;: &quot;relative h-3 rounded-full bg-neutral/10&quot;,
                      &quot;base&quot;: &quot;size-full relative z-1&quot;,
                      &quot;origin&quot;: &quot;absolute top-0 end-0  size-full origin-[0_0] rounded-full&quot;,
                    &quot;handle&quot;: &quot;absolute top-1/2 end-0  size-6 bg-base-100 border-4 border-primary rounded-full translate-x-2/4 -translate-y-2/4 hover:cursor-grab active:cursor-grabbing hover:ring-2 ring-primary active:ring-[3px]&quot;,
                      &quot;connects&quot;: &quot;relative z-0 w-full h-3  rounded-s-full overflow-hidden&quot;,
                      &quot;connect&quot;: &quot;absolute top-0 end-0  z-1 size-full bg-primary origin-[0_0]&quot;,
                      &quot;touchArea&quot;: &quot;absolute -top-1 -bottom-1 -start-1 -end-1&quot;
                    }
                  }"><div class=" noUi-base size-full relative z-1"><div class=" noUi-connects relative z-0 w-full h-3  rounded-s-full overflow-hidden"><div class=" noUi-connect absolute top-0 end-0  z-1 size-full bg-primary origin-[0_0]" style="transform: translate(0%, 0px) scale(0.5, 1);"></div></div><div class=" noUi-origin absolute top-0 end-0  size-full origin-[0_0] rounded-full" style="transform: translate(-50%, 0px); z-index: 4;"><div class="noUi-handle absolute top-1/2 end-0 size-6 bg-base-100 border-4 border-primary rounded-full translate-x-2/4 -translate-y-2/4 hover:cursor-grab active:cursor-grabbing hover:ring-2 ring-primary active:ring-[3px] noUi-handle-lower" data-handle="0" tabindex="0" role="slider" aria-orientation="horizontal" aria-valuemin="0.0" aria-valuemax="24.0" aria-valuenow="12.0" aria-valuetext="12.00"><div class=" noUi-touch-area absolute -top-1 -bottom-1 -start-1 -end-1"></div></div></div></div></div>

                <div class="ck7pw lg:mt-6"></div>

                <div class="e6ynr hqh7v">
                  <div class="flex items-center justify-between sly4q">
                    <span class="text-base-content/80">Price per seat</span>
                    <span class="text-base-content t3mfo">$19</span>
                  </div>
                  <div class="flex items-center justify-between sly4q">
                    <span class="text-base-content/80">Total per seat</span>
                    <span class="text-base-content t3mfo">$129</span>
                  </div>
                  <div class="flex items-center justify-between sly4q">
                    <span class="text-base-content/80">Total per month (annual pricing)</span>
                    <span class="text-base-content t3mfo">$99</span>
                  </div>

                  <div class="flex items-center">
                    <input type="checkbox" class="q0yur bqy1f me-2" id="Annual-pricing">
                    <label class="wqwbi xn3np text-base" for="Annual-pricing">Annual pricing</label>
                    <span class="ijn5q o1g2m bxh1m gehqc">Save 20%</span>
                  </div>

                  <!-- Footer Actions -->
                  <div class="dpzny njdg2 sm:grid-cols-2">
                    <button type="button" class="btn g2v48 gnw6d" data-overlay="#choose-seats" aria-expanded="false">
                      Back to Page
                    </button>
                    <button type="button" class="btn btn-primary">
                      Payment Details
                      <span class="icon-[tabler--arrow-right] qmuz4 shrink-0"></span>
                    </button>
                  </div>
                </div>
                <button class="btn btn-circle btn-sm btn-text absolute w3z1y psag3" aria-label="Close" data-overlay="#choose-seats" aria-expanded="false">
                  <span class="icon-[tabler--x] text-base-content size-4"></span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script src="https://flyonui.becdn.net/pro/libs/nouislider/dist/nouislider.min.js"></script>

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
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#choose-seats")
      })
      const range = document.querySelector("#seats-target")
      const rangeInstance = new HSRangeSlider(range)
      const target = document.querySelector("#choose-seats-target")

      range.noUiSlider.on("update", values => {
        // Convert to integer to remove decimal places
        const integerValue = Math.round(parseFloat(values[0]))
        target.innerText = integerValue
      })
    })
  </script>
  

</body>

<body data-vh-checked="true" style="overflow: hidden;">
  <div class="dhabr h-dvh i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 j2be9 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button type="button" class="btn btn-primary" aria-haspopup="dialog" aria-expanded="true" aria-controls="edit-employee-details" data-overlay="#edit-employee-details">
          Open modal
        </button>
      </div>

      <div id="edit-employee-details" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 open opened" role="dialog" tabindex="-1" aria-overlay="true" style="outline: none;">
        <div class="dthlq w-full edp49">
          <div class="pbhw6 j5lbz">
            <div class="relative">
              <form class="flex jz3o6 ip6vv fbpri">
                <!-- Header -->
                <h3 class="text-base-content waiii t3mfo">Edit employee details</h3>

                <!-- Employee Photo and Basic Info -->
                <div class="flex items-center njdg2 max-sm:flex-col sm:gap-6">
                  <!-- Profile Photo -->
                  <div class="nfjpm shrink-0">
                    <div class="hlrpg rpj8y">
                      <img src="https://cdn.flyonui.com/fy-assets/avatar/avatar-5.png" alt="Employee photo">
                    </div>
                  </div>

                  <!-- Name and Position -->
                  <div class="dpzny wfsyj njdg2 sm:grid-cols-2">
                    <div>
                      <input type="text" placeholder="John Doe" class="ljn0d" id="employee-name" required="">
                    </div>
                    <div>
                      <select class="select" id="employee-position" required="">
                        <option value="">Select position</option>
                        <option value="sr-project-manager" selected="">Sr.Project Manager</option>
                        <option value="project-manager">Project Manager</option>
                        <option value="developer">Developer</option>
                        <option value="designer">Designer</option>
                      </select>
                    </div>
                    <div class="zb007">
                      <input type="email" placeholder="john.doe@gmail.com" class="ljn0d" id="employee-email" required="">
                    </div>
                  </div>
                </div>

                <!-- Form Fields -->
                <div class="dpzny wfsyj njdg2 sm:grid-cols-2">
                  <!-- Division and Gender Row -->
                  <div>
                    <label for="employee-division" class="text-base-content mb-1 block text-sm">Division</label>
                    <select class="select" id="employee-division" required="">
                      <option value="">Select division</option>
                      <option value="product-development" selected="">Product &amp; Development</option>
                      <option value="marketing">Marketing</option>
                      <option value="sales">Sales</option>
                      <option value="hr">Human Resources</option>
                    </select>
                  </div>
                  <div>
                    <label for="employee-gender" class="text-base-content mb-1 block text-sm">Gender</label>
                    <select class="select" id="employee-gender" required="">
                      <option value="">Select gender</option>
                      <option value="male" selected="">Male</option>
                      <option value="female">Female</option>
                      <option value="other">Other</option>
                    </select>
                  </div>

                  <!-- Age and Email Row -->
                  <div>
                    <label for="employee-age" class="text-base-content mb-1 block text-sm">Age</label>
                    <select class="select" id="employee-age" required="">
                      <option value="">Select age</option>
                      <option value="32" selected="">32 Years</option>
                      <option value="25">25 Years</option>
                      <option value="28">28 Years</option>
                      <option value="35">35 Years</option>
                    </select>
                  </div>
                  <div>
                    <label class="text-base-content mb-1 block text-sm" for="employee-email-alt">Email</label>
                    <input type="email" placeholder="Johndoe@gmail.com" class="ljn0d" id="employee-email-alt" required="">
                  </div>

                  <!-- Employee ID and Address Row -->
                  <div>
                    <label class="text-base-content mb-1 block text-sm" for="employee-id">Employee ID</label>
                    <input type="text" placeholder="EMP-254875269-54214" class="ljn0d" id="employee-id" readonly="">
                  </div>
                  <div>
                    <label class="text-base-content mb-1 block text-sm" for="employee-address">Address</label>
                    <input type="text" placeholder="4135 Parkway Street, Los Angeles" class="ljn0d" id="employee-address" required="">
                  </div>

                  <!-- Phone Number and Date Applied Row -->
                  <div>
                    <label class="text-base-content mb-1 block text-sm" for="employee-phone">Phone Number</label>
                    <input type="tel" placeholder="+316 4587 6589" pattern="\\+[0-9]{3} [0-9]{4} [0-9]{4}" class="ljn0d" id="employee-phone" required="">
                  </div>
                  <div>
                    <label for="employee-date-applied" class="text-base-content mb-1 block text-sm">Date Applied</label>
                    <div class="ljn0d">
                      <span class="icon-[tabler--calendar] text-base-content/80 q7z0e xn3np size-5 shrink-0"></span>
                      <input type="text" placeholder="12 June 2024" class="sxihv flatpickr-input" id="employee-date-applied" required="" readonly="readonly">
                    </div>
                  </div>
                </div>

                <div class="ck7pw"></div>

                <!-- Footer Actions -->
                <div class="flex mnhlk items-center justify-between njdg2">
                  <button type="button" class="btn g2v48 gnw6d" data-overlay="#edit-employee-details" aria-expanded="true">
                    Cancel
                  </button>
                  <button type="submit" class="btn btn-primary">Save Details</button>
                </div>
              </form>
              <button class="btn btn-circle btn-sm btn-text absolute w3z1y psag3" aria-label="Close" data-overlay="#edit-employee-details" aria-expanded="true">
                <span class="icon-[tabler--x] text-base-content size-4"></span>
              </button>
            </div>
          </div>
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
    window.addEventListener("load", () => {
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#edit-employee-details")
      })
      flatpickr("#employee-date-applied", {
        monthSelectorType: "static"
      })
    })
  </script>
  

<div class="flatpickr-calendar animate" tabindex="-1"><div class="flatpickr-months"><span class="flatpickr-prev-month"><svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 17 17"><g></g><path d="M5.207 8.471l7.146 7.147-0.707 0.707-7.853-7.854 7.854-7.853 0.707 0.707-7.147 7.146z"></path></svg></span><div class="flatpickr-month"><div class="flatpickr-current-month"><span class="cur-month">November </span><div class="numInputWrapper"><input class="numInput cur-year" type="number" tabindex="-1" aria-label="Year"><span class="arrowUp"></span><span class="arrowDown"></span></div></div></div><span class="flatpickr-next-month"><svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 17 17"><g></g><path d="M13.207 8.472l-7.854 7.854-0.707-0.707 7.146-7.146-7.146-7.148 0.707-0.707 7.854 7.854z"></path></svg></span></div><div class="flatpickr-innerContainer"><div class="flatpickr-rContainer"><div class="flatpickr-weekdays"><div class="flatpickr-weekdaycontainer">
      <span class="flatpickr-weekday">
        Sun</span><span class="flatpickr-weekday">Mon</span><span class="flatpickr-weekday">Tue</span><span class="flatpickr-weekday">Wed</span><span class="flatpickr-weekday">Thu</span><span class="flatpickr-weekday">Fri</span><span class="flatpickr-weekday">Sat
      </span>
      </div></div><div class="flatpickr-days" tabindex="-1"><div class="dayContainer"><span class="flatpickr-day prevMonthDay" aria-label="October 26, 2025" tabindex="-1">26</span><span class="flatpickr-day prevMonthDay" aria-label="October 27, 2025" tabindex="-1">27</span><span class="flatpickr-day prevMonthDay" aria-label="October 28, 2025" tabindex="-1">28</span><span class="flatpickr-day prevMonthDay" aria-label="October 29, 2025" tabindex="-1">29</span><span class="flatpickr-day prevMonthDay" aria-label="October 30, 2025" tabindex="-1">30</span><span class="flatpickr-day prevMonthDay" aria-label="October 31, 2025" tabindex="-1">31</span><span class="flatpickr-day" aria-label="November 1, 2025" tabindex="-1">1</span><span class="flatpickr-day" aria-label="November 2, 2025" tabindex="-1">2</span><span class="flatpickr-day" aria-label="November 3, 2025" tabindex="-1">3</span><span class="flatpickr-day" aria-label="November 4, 2025" tabindex="-1">4</span><span class="flatpickr-day" aria-label="November 5, 2025" tabindex="-1">5</span><span class="flatpickr-day" aria-label="November 6, 2025" tabindex="-1">6</span><span class="flatpickr-day" aria-label="November 7, 2025" tabindex="-1">7</span><span class="flatpickr-day" aria-label="November 8, 2025" tabindex="-1">8</span><span class="flatpickr-day" aria-label="November 9, 2025" tabindex="-1">9</span><span class="flatpickr-day" aria-label="November 10, 2025" tabindex="-1">10</span><span class="flatpickr-day" aria-label="November 11, 2025" tabindex="-1">11</span><span class="flatpickr-day" aria-label="November 12, 2025" tabindex="-1">12</span><span class="flatpickr-day" aria-label="November 13, 2025" tabindex="-1">13</span><span class="flatpickr-day" aria-label="November 14, 2025" tabindex="-1">14</span><span class="flatpickr-day" aria-label="November 15, 2025" tabindex="-1">15</span><span class="flatpickr-day" aria-label="November 16, 2025" tabindex="-1">16</span><span class="flatpickr-day" aria-label="November 17, 2025" tabindex="-1">17</span><span class="flatpickr-day" aria-label="November 18, 2025" tabindex="-1">18</span><span class="flatpickr-day" aria-label="November 19, 2025" tabindex="-1">19</span><span class="flatpickr-day" aria-label="November 20, 2025" tabindex="-1">20</span><span class="flatpickr-day" aria-label="November 21, 2025" tabindex="-1">21</span><span class="flatpickr-day" aria-label="November 22, 2025" tabindex="-1">22</span><span class="flatpickr-day" aria-label="November 23, 2025" tabindex="-1">23</span><span class="flatpickr-day" aria-label="November 24, 2025" tabindex="-1">24</span><span class="flatpickr-day" aria-label="November 25, 2025" tabindex="-1">25</span><span class="flatpickr-day today" aria-label="November 26, 2025" aria-current="date" tabindex="-1">26</span><span class="flatpickr-day" aria-label="November 27, 2025" tabindex="-1">27</span><span class="flatpickr-day" aria-label="November 28, 2025" tabindex="-1">28</span><span class="flatpickr-day" aria-label="November 29, 2025" tabindex="-1">29</span><span class="flatpickr-day" aria-label="November 30, 2025" tabindex="-1">30</span><span class="flatpickr-day nextMonthDay" aria-label="December 1, 2025" tabindex="-1">1</span><span class="flatpickr-day nextMonthDay" aria-label="December 2, 2025" tabindex="-1">2</span><span class="flatpickr-day nextMonthDay" aria-label="December 3, 2025" tabindex="-1">3</span><span class="flatpickr-day nextMonthDay" aria-label="December 4, 2025" tabindex="-1">4</span><span class="flatpickr-day nextMonthDay" aria-label="December 5, 2025" tabindex="-1">5</span><span class="flatpickr-day nextMonthDay" aria-label="December 6, 2025" tabindex="-1">6</span></div></div></div></div></div><div id="edit-employee-details-backdrop" data-overlay-backdrop-template="" style="z-index: 79;" class="overlay-backdrop transition duration-300 fixed inset-0 bg-base-300/60 overflow-y-auto "></div></body>

<body data-vh-checked="true" style="overflow: hidden;">
  <div class="dhabr h-dvh i3xre sm:py-16 lg:py-24">
    <div class="wpaot owca9 j2be9 sm:px-6 lg:px-8">
      <div class="flex justify-center">
        <button type="button" class="btn btn-primary" aria-haspopup="dialog" aria-expanded="true" aria-controls="create-app" data-overlay="#create-app">
          Open modal
        </button>
      </div>

      <div id="create-app" class="overlay erw2q overlay-open:opacity-100 overlay-open:duration-300 qm726 open opened" role="dialog" tabindex="-1" aria-overlay="true" style="outline: none;">
        <div class="dthlq w-full gkz1f">
          <div class="pbhw6">
            <div class="js11s relative yyuvw">
              <!-- Header -->
              <div class="zqxh1 kf6hd rdi5h">
                <h3 class="text-base-content waiii t3mfo">Create App</h3>
                <p class="text-base-content/80">Provide data with this form to create your app.</p>
              </div>

              <div class="dpzny wfsyj x1pg6 md:grid-cols-3 md:gap-10" data-stepper="">
                <!-- Stepper Nav -->
                <div class="flex items-center">
                  <ul class="flex w-full sa5q9 md:flex-col md:justify-between md:gap-5">
                    <li class="flex gy7oi a5p47 items-center njdg2 md:flex-1 active" data-stepper-nav-item="{ &quot;index&quot;: 1 }">
                      <span class="nfjpm rmjll">
                        <span class="stepper-active:text-bg-primary stepper-success:text-bg-soft-primary stepper-completed:text-bg-success loa97 rounded-field j4z3m">
                          <span class="icon-[tabler--home] size-6 shrink-0"></span>
                        </span>
                      </span>
                      <span class="flex jz3o6 rsqkx max-md:hidden">
                        <span class="stepper-active:text-primary stepper-success:text-base-content/50 stepper-completed:text-success text-base-content text-base font-medium vxiam">
                          Details
                        </span>
                        <span class="text-base-content/80 stepper-success:text-base-content/50 text-xs">
                          Enter Details
                        </span>
                      </span>
                    </li>
                    <li class="flex gy7oi a5p47 items-center njdg2 md:grow" data-stepper-nav-item="{ &quot;index&quot;: 2 }">
                      <span class="nfjpm rmjll">
                        <span class="stepper-active:text-bg-primary stepper-success:text-bg-soft-primary stepper-completed:text-bg-success loa97 rounded-field j4z3m">
                          <span class="icon-[tabler--file-horizontal] size-6 shrink-0"></span>
                        </span>
                      </span>
                      <span class="flex jz3o6 rsqkx max-md:hidden">
                        <span class="stepper-active:text-primary stepper-success:text-base-content/50 stepper-completed:text-success text-base-content text-base font-medium vxiam">
                          FRAMEWORKS
                        </span>
                        <span class="text-base-content/80 stepper-success:text-base-content/50 text-xs">
                          Select Framework
                        </span>
                      </span>
                    </li>
                    <li class="flex gy7oi a5p47 items-center njdg2 md:grow" data-stepper-nav-item="{ &quot;index&quot;: 3 }">
                      <span class="nfjpm rmjll">
                        <span class="stepper-active:text-bg-primary stepper-success:text-bg-soft-primary stepper-completed:text-bg-success loa97 rounded-field j4z3m">
                          <span class="icon-[tabler--database] size-6 shrink-0"></span>
                        </span>
                      </span>
                      <span class="flex jz3o6 rsqkx max-md:hidden">
                        <span class="stepper-active:text-primary stepper-success:text-base-content/50 stepper-completed:text-success text-base-content text-base font-medium vxiam">
                          DATABASE
                        </span>
                        <span class="text-base-content/80 stepper-success:text-base-content/50 text-xs">
                          Select Database
                        </span>
                      </span>
                    </li>
                    <li class="flex gy7oi a5p47 items-center njdg2 md:grow" data-stepper-nav-item="{ &quot;index&quot;: 4 }">
                      <span class="nfjpm rmjll">
                        <span class="stepper-active:text-bg-primary stepper-success:text-bg-soft-primary stepper-completed:text-bg-success loa97 rounded-field j4z3m">
                          <span class="icon-[tabler--credit-card] size-6 shrink-0"></span>
                        </span>
                      </span>
                      <span class="flex jz3o6 rsqkx max-md:hidden">
                        <span class="stepper-active:text-primary stepper-success:text-base-content/50 stepper-completed:text-success text-base-content text-base font-medium vxiam">
                          BILLING
                        </span>
                        <span class="text-base-content/80 stepper-success:text-base-content/50 text-xs">
                          Payment Details
                        </span>
                      </span>
                    </li>
                  </ul>
                </div>
                <!-- End Stepper Nav -->

                <!-- Stepper Content -->
                <div class="unfpg md:col-span-2">
                  <!-- First Content -->
                  <div data-stepper-content-item="{ &quot;index&quot;: 1 }">
                    <div class="flex jz3o6 ip6vv">
                      <div>
                        <label class="wqwbi" for="app-name">Application Name</label>
                        <input type="text" placeholder="Application Name" class="ljn0d" id="app-name" required="">
                      </div>
                      <div>
                        <h4 class="text-base-content w3dp6 c9rvi font-medium">Category</h4>
                        <ul class="hqh7v">
                          <li>
                            <label class="flex e6ynr gy7oi a5p47 lx78o items-center justify-between njdg2" for="create-app-category-1">
                              <span class="flex items-center njdg2">
                                <span class="nfjpm rmjll">
                                  <span class="e50a2 rounded-field j4z3m">
                                    <span class="icon-[tabler--file-invoice] size-6 shrink-0"></span>
                                  </span>
                                </span>
                                <span class="flex jz3o6 rsqkx">
                                  <span class="text-base-content text-base font-medium">CRM Application</span>
                                  <span class="text-base-content/80 text-xs">Scales with any business</span>
                                </span>
                              </span>
                              <input type="radio" name="create-app-category" class="d6aiv saa4z bmjz1 zwsg8" id="create-app-category-1">
                            </label>
                          </li>
                          <li>
                            <label class="flex e6ynr gy7oi a5p47 lx78o items-center justify-between njdg2" for="create-app-category-2">
                              <span class="flex items-center njdg2">
                                <span class="nfjpm rmjll">
                                  <span class="kzsz6 rounded-field j4z3m">
                                    <span class="icon-[tabler--shopping-cart] size-6 shrink-0"></span>
                                  </span>
                                </span>
                                <span class="flex jz3o6 rsqkx">
                                  <span class="text-base-content text-base font-medium">eCommerce Platforms</span>
                                  <span class="text-base-content/80 text-xs">Grow your business</span>
                                </span>
                              </span>
                              <input type="radio" name="create-app-category" class="d6aiv saa4z bmjz1 zwsg8" id="create-app-category-2" checked="">
                            </label>
                          </li>
                          <li>
                            <label class="flex e6ynr gy7oi a5p47 lx78o items-center justify-between njdg2" for="create-app-category-3">
                              <span class="flex items-center njdg2">
                                <span class="nfjpm rmjll">
                                  <span class="fncbu rounded-field j4z3m">
                                    <span class="icon-[tabler--device-laptop] size-6 shrink-0"></span>
                                  </span>
                                </span>
                                <span class="flex jz3o6 rsqkx">
                                  <span class="text-base-content text-base font-medium">Online Learning platform</span>
                                  <span class="text-base-content/80 text-xs">Start learning today</span>
                                </span>
                              </span>
                              <input type="radio" name="create-app-category" class="d6aiv saa4z bmjz1 zwsg8" id="create-app-category-3">
                            </label>
                          </li>
                        </ul>
                      </div>
                    </div>
                  </div>
                  <!-- End First Content -->
                  <!-- Second Content -->
                  <div data-stepper-content-item="{ &quot;index&quot;: 2 }" style="display: none;">
                    <div class="flex jz3o6 ip6vv">
                      <div>
                        <h4 class="text-base-content w3dp6 c9rvi font-medium">Select Framework</h4>
                        <ul class="hqh7v">
                          <li>
                            <label class="flex e6ynr gy7oi a5p47 lx78o items-center justify-between njdg2" for="framework-react">
                              <span class="flex items-center njdg2">
                                <span class="nfjpm rmjll">
                                  <span class="e50a2 rounded-field j4z3m">
                                    <span class="icon-[tabler--brand-react] size-6 shrink-0"></span>
                                  </span>
                                </span>
                                <span class="flex jz3o6 rsqkx">
                                  <span class="text-base-content text-base font-medium">React Native</span>
                                  <span class="text-base-content/80 text-xs">Create rich native apps</span>
                                </span>
                              </span>
                              <input type="radio" name="framework" class="d6aiv saa4z bmjz1 zwsg8" id="framework-react" checked="">
                            </label>
                          </li>
                          <li>
                            <label class="flex e6ynr gy7oi a5p47 lx78o items-center justify-between njdg2" for="framework-angular">
                              <span class="flex items-center njdg2">
                                <span class="nfjpm rmjll">
                                  <span class="fncbu rounded-field j4z3m">
                                    <span class="icon-[tabler--brand-angular] size-6 shrink-0"></span>
                                  </span>
                                </span>
                                <span class="flex jz3o6 rsqkx">
                                  <span class="text-base-content text-base font-medium">Angular</span>
                                  <span class="text-base-content/80 text-xs">Most suited for your application</span>
                                </span>
                              </span>
                              <input type="radio" name="framework" class="d6aiv saa4z bmjz1 zwsg8" id="framework-angular">
                            </label>
                          </li>
                          <li>
                            <label class="flex e6ynr gy7oi a5p47 lx78o items-center justify-between njdg2" for="framework-vue">
                              <span class="flex items-center njdg2">
                                <span class="nfjpm rmjll">
                                  <span class="kzsz6 rounded-field j4z3m">
                                    <span class="icon-[tabler--brand-vue] size-6 shrink-0"></span>
                                  </span>
                                </span>
                                <span class="flex jz3o6 rsqkx">
                                  <span class="text-base-content text-base font-medium">Vue</span>
                                  <span class="text-base-content/80 text-xs">Progressive framework</span>
                                </span>
                              </span>
                              <input type="radio" name="framework" class="d6aiv saa4z bmjz1 zwsg8" id="framework-vue">
                            </label>
                          </li>
                          <li>
                            <label class="flex e6ynr gy7oi a5p47 lx78o items-center justify-between njdg2" for="framework-html">
                              <span class="flex items-center njdg2">
                                <span class="nfjpm rmjll">
                                  <span class="hkakl rounded-field j4z3m">
                                    <span class="icon-[tabler--brand-html5] size-6 shrink-0"></span>
                                  </span>
                                </span>
                                <span class="flex jz3o6 rsqkx">
                                  <span class="text-base-content text-base font-medium">HTML</span>
                                  <span class="text-base-content/80 text-xs">For simple applications</span>
                                </span>
                              </span>
                              <input type="radio" name="framework" class="d6aiv saa4z bmjz1 zwsg8" id="framework-html">
                            </label>
                          </li>
                        </ul>
                      </div>
                    </div>
                  </div>
                  <!-- End Second Content -->
                  <!-- Third Content -->
                  <div data-stepper-content-item="{ &quot;index&quot;: 3 }" style="display: none;">
                    <div class="flex jz3o6 ip6vv">
                      <div>
                        <label class="wqwbi" for="database-name">Database Name</label>
                        <input type="text" placeholder="Database Name" class="ljn0d" id="database-name" required="">
                      </div>
                      <div>
                        <h4 class="text-base-content w3dp6 c9rvi font-medium">Select Database Engine</h4>
                        <ul class="hqh7v">
                          <li>
                            <label class="flex e6ynr gy7oi a5p47 lx78o items-center justify-between njdg2" for="database-firebase">
                              <span class="flex items-center njdg2">
                                <span class="nfjpm rmjll">
                                  <span class="fncbu rounded-field j4z3m">
                                    <span class="icon-[tabler--brand-firebase] size-6 shrink-0"></span>
                                  </span>
                                </span>
                                <span class="flex jz3o6 rsqkx">
                                  <span class="text-base-content text-base font-medium">Firebase</span>
                                  <span class="text-base-content/80 text-xs">Cloud Firestore</span>
                                </span>
                              </span>
                              <input type="radio" name="database" class="d6aiv saa4z bmjz1 zwsg8" id="database-firebase" checked="">
                            </label>
                          </li>
                          <li>
                            <label class="flex e6ynr gy7oi a5p47 lx78o items-center justify-between njdg2" for="database-aws">
                              <span class="flex items-center njdg2">
                                <span class="nfjpm rmjll">
                                  <span class="hkakl rounded-field j4z3m">
                                    <span class="icon-[tabler--brand-aws] size-6 shrink-0"></span>
                                  </span>
                                </span>
                                <span class="flex jz3o6 rsqkx">
                                  <span class="text-base-content text-base font-medium">AWS</span>
                                  <span class="text-base-content/80 text-xs">Amazon Fast NoSQL Database</span>
                                </span>
                              </span>
                              <input type="radio" name="database" class="d6aiv saa4z bmjz1 zwsg8" id="database-aws">
                            </label>
                          </li>
                          <li>
                            <label class="flex e6ynr gy7oi a5p47 lx78o items-center justify-between njdg2" for="database-mysql">
                              <span class="flex items-center njdg2">
                                <span class="nfjpm rmjll">
                                  <span class="yspo9 rounded-field j4z3m">
                                    <span class="icon-[tabler--database] size-6 shrink-0"></span>
                                  </span>
                                </span>
                                <span class="flex jz3o6 rsqkx">
                                  <span class="text-base-content text-base font-medium">MySQL</span>
                                  <span class="text-base-content/80 text-xs">Basic MySQL database</span>
                                </span>
                              </span>
                              <input type="radio" name="database" class="d6aiv saa4z bmjz1 zwsg8" id="database-mysql">
                            </label>
                          </li>
                        </ul>
                      </div>
                    </div>
                  </div>
                  <!-- End Third Content -->
                  <!-- Fourth Content -->
                  <div data-stepper-content-item="{ &quot;index&quot;: 4 }" style="display: none;">
                    <div class="flex jz3o6 ip6vv">
                      <div>
                        <h4 class="text-base-content c9rvi font-medium">Payment Details</h4>
                      </div>
                      <!-- Card Number -->
                      <div>
                        <label class="wqwbi" for="card-number">Card Number</label>
                        <div class="ljn0d">
                          <span class="icon-[tabler--credit-card] text-base-content/80 q7z0e xn3np size-5 shrink-0"></span>
                          <input type="text" placeholder="1234 1234 1234 1234" class="sxihv" id="card-number" required="">
                        </div>
                      </div>

                      <!-- Name, Expiration Date, CVV Row -->
                      <div class="dpzny wfsyj njdg2 md:grid-cols-3">
                        <!-- Name -->
                        <div>
                          <label for="cardholder-name" class="wqwbi">Name</label>
                          <input type="text" placeholder="John doe" class="ljn0d" id="cardholder-name" required="">
                        </div>

                        <!-- Expiration Date -->
                        <div>
                          <label for="expiration-date" class="wqwbi">Expiration Date</label>
                          <div class="ljn0d">
                            <span class="icon-[tabler--calendar] text-base-content/80 q7z0e xn3np size-5 shrink-0"></span>
                            <input type="text" placeholder="12/25" class="sxihv" id="expiration-date" required="">
                          </div>
                        </div>

                        <!-- CVV -->
                        <div>
                          <label for="cvv" class="wqwbi">CVV</label>
                          <div class="ljn0d">
                            <span class="icon-[tabler--lock] text-base-content/80 q7z0e xn3np size-5 shrink-0"></span>
                            <input type="text" placeholder="123" class="sxihv" id="cvv" required="" maxlength="4">
                          </div>
                        </div>
                      </div>

                      <!-- Save Card Checkbox -->
                      <div class="flex items-center bglhu">
                        <input type="checkbox" class="q0yur bqy1f" id="save-card">
                        <label class="wqwbi text-base" for="save-card">Save card for future billing?</label>
                      </div>
                    </div>
                  </div>
                  <!-- End Fourth Content -->
                  <!-- Final Content -->
                  <div data-stepper-content-item="{ &quot;isFinal&quot;: true }" style="display: none;">
                    <div class="dhabr rounded-box border-base-content/20 flex bm27d items-center justify-center border dkr8s p-4">
                      <h3 class="text-base-content/50 waiii">Successfully Submitted</h3>
                    </div>
                  </div>
                  <!-- End Final Content -->
                  <!-- Button Group -->
                  <div class="ndnti flex items-center justify-between gap-x-2">
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
                      <span class="icon-[tabler--check] q4jyb"></span>
                    </button>
                    <button type="reset" class="btn btn-primary ms-auto" data-stepper-reset-btn="" style="display: none;">
                      Reset
                    </button>
                  </div>
                  <!-- End Button Group -->
                </div>
                <!-- End Stepper Content -->
              </div>

              <button class="btn btn-circle btn-sm btn-text absolute w3z1y psag3" aria-label="Close" data-overlay="#create-app" aria-expanded="true">
                <span class="icon-[tabler--x] text-base-content size-4"></span>
              </button>
            </div>
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

  <script>
    window.addEventListener("load", () => {
      setTimeout(() => {
        // Check if modal exists
        HSOverlay.open("#create-app")
      })
    })
  </script>
  

<div id="create-app-backdrop" data-overlay-backdrop-template="" style="z-index: 79;" class="overlay-backdrop transition duration-300 fixed inset-0 bg-base-300/60 overflow-y-auto "></div></body>


