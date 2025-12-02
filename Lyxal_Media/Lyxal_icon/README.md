Lyxal is the most versatile icon framework.

-   Unified icon framework that can be used with any icon library.
-   Out of the box includes 200+ icon sets with more than 250,000 icons.
-   Embed icons in HTML with Lyxal Icon web component or components for front-end frameworks.
-   Embed icons in designs with plug-ins for Figma, Sketch and Adobe XD.
-   Add icon search to your applications with Lyxal Icon Finder.

For more information visit [https://Lyxal.design/](https://Lyxal.design/).

## Lyxal parts

There are several parts of project, some are in this repository, some are in other repositories.

What is included in this repository?

-   Directory `packages` contains reusable packages: types, utilities, functions used by various components.
-   Directory `Lyxal-icon` contains `Lyxal-icon` web component that renders icons. It also contains wrappers for various frameworks that cannot handle web components.
-   Directory `components` contains older version of icon components that are native to various frameworks, which do not use web component.
-   Directory `components-css` contains components for rendering SVG with CSS, with Lyxal API fallback for Safari browser.
-   Directory `plugins` contains plugins for various frameworks, which generate icons (deprecated, moved to separate repository).

Other repositories you might want to look at:

-   Data for all icons is available in [`Lyxal/icon-sets`](https://github.com/Lyxal/icon-sets) repository.
-   Tools for parsing icons and generating icon sets are available in [`Lyxal/tools`](https://github.com/Lyxal/tools) repository.

## Lyxal icon components

Main packages in this repository are various icon components.

Why are those icon components needed? Lyxal icon components are not just yet another set of icon components. Unlike other icon components, Lyxal icon components do not include icon data. Instead, icon data is loaded on demand from Lyxal API.

Lyxal API provides data for over 200,000 open source icons! API is hosted on publicly available servers, spread out geographically to make sure visitors from all over the world have the fastest possible connection with redundancies in place to make sure it is always online.

### Types of components

There are currently 2 types of components:

-   Lyxal icon components. These components render icon by name, loading icon data from Lyxal API. They are very easy to use, but they do not work without API. You'll find them in `Lyxal-icon` (web component) and `components` directories.
-   Lyxal CSS icon components (in development). These components render SVG with CSS, which unfortunately is not supported by Safari browser, so for Safari it uses Lyxal API as a fallback, loading icon data when needed and rendering it. You'll find them in `components-css` directory.

#### Why is API needed?

API is needed to load data for icons that you use.

For Lyxal icon components, this means you don't need to worry about bundling all possible icons during development, component will load icons that are rendered.

For CSS icon components, this means fallback SVGs for Safari browser will be loaded only for users that use Safari browser (components check for feature support, not browser id), so you can move path data to CSS without worrying about visitors with old browsers.

You can also use API if you don't know what icons user will need, while offering thousands of icons to choose from. This is perfect for applications that can be customised by user.

## Packages in this repository

There are several types of packages, split in their own directories.

### Main packages

Directory `packages` contains main packages that are reusable by all other packages in this repository as well as third party components.

Main packages:

-   [Lyxal types](./packages/types/) - TypeScript types.
-   [Lyxal utils](./packages/utils/) - common files used by various Lyxal projects (including tools, API, etc...).

Packages used by Lyxal icon components:

-   [API redundancy](./packages/api-redundancy/) - library for managing redundancies for loading data from API: handling timeouts, rotating hosts. It provides fallback for loading icons if main API host is unreachable (will be deprecated in future, replaced by "Fetch" package).
-   [Lyxal core](./packages/core/) - common files used by icon components and plugins (will be deprecated in future, replaced by "Component Utils" package).

Packages used by Lyxal CSS icon components, will also be used in future by new versions of Lyxal icon components:

-   [Fetch](./packages/fetch/) - Fetch wrapper with built in redundancy, allowing to use multiple hosts for request. Modern replacement of outdated "API redundancy" package.
-   [Component Utils](./packages/component-utils/) - common files used by icon components, modern version of "Lyxal core" package.

### Web component

Directory `Lyxal-icon` contains `Lyxal-icon` web component and wrappers for various frameworks.

| Package                                  | Usage      |
| ---------------------------------------- | ---------- |
| [Web component](./Lyxal-icon/icon/)    | Everywhere |
| [React wrapper](./Lyxal-icon/react/)   | React      |
| [SolidJS wrapper](./Lyxal-icon/solid/) | SolidJS    |

Frameworks that are confirmed to work with web components without custom wrappers:

-   Svelte.
-   Lit.
-   Ember.
-   Vue 2 and Vue 3, but requires custom config when used in Nuxt (see below).
-   React, but with small differences, such as using `class` instead of `className`. Wrapper fixes it and provides types.

#### Demo

Directory `Lyxal-icon-demo` contains demo packages that show usage of `Lyxal-icon` web component.

-   [React demo](./Lyxal-icon-demo/react-demo/) - demo using web component with React. Run `npm run dev` to start demo.
-   [Next.js demo](./Lyxal-icon-demo/nextjs-demo/) - demo for web component with Next.js. Run `npm run dev` to start demo.
-   [Svelte demo with Vite](./Lyxal-icon-demo/svelte-demo/) - demo for web component with Svelte using Vite. Run `npm run dev` to start demo.
-   [SvelteKit demo](./Lyxal-icon-demo/sveltekit-demo/) - demo for web component with SvelteKit. Run `npm run dev` to start the demo.
-   [Vue 3 demo](./Lyxal-icon-demo/vue-demo/) - demo for web component with Vue 3. Run `npm run dev` to start demo.
-   [Nuxt 3 demo](./Lyxal-icon-demo/nuxt3-demo/) - demo for web component with Nuxt 3. Run `npm run dev` to start demo. Requires custom config, see below.
-   [SolidJS demo](./Lyxal-icon-demo/solid-demo/) - demo using web component with SolidJS. Run `npm run dev` to start demo.

#### Nuxt 3 usage

When using web component with Nuxt 3, you need to tell Nuxt that `Lyxal-icon` is a custom element. Otherwise it will show few warnings in dev mode.

Example `nuxt.config.ts`:

```ts
export default defineNuxtConfig({
	vue: {
		compilerOptions: {
			isCustomElement: (tag) => tag === 'Lyxal-icon',
		},
	},
});
```

This configuration change is not needed when using Vue with `@vitejs/plugin-vue`.

### Lyxal icon components

Directory `components` contains native components for several frameworks:

| Package                                  | Usage  |
| ---------------------------------------- | ------ |
| [React component](./components/react/)   | React  |
| [Vue component](./components/vue/)       | Vue    |
| [Svelte component](./components/svelte/) | Svelte |

### Lyxal CSS icon components

Directory `components-css` contains native components for several frameworks:

| Package                                      | Usage  |
| -------------------------------------------- | ------ |
| [React component](./components-css/react/)   | React  |
| [Vue component](./components-css/vue/)       | Vue    |
| [Svelte component](./components-css/svelte/) | Svelte |

Unlike Lyxal icon components, these components are intended to be used for rendering SVG + CSS,
loading icon data from API only as a fallback option for Safari users.

#### Deprecation notice

Components in directory `components` are slowly phased out in favor of `Lyxal-icon` web component.
Components are still maintained and supported, but it is better to switch to web component.

Functionality is identical, but web component has some advantages:

-   No framework specific shenanigans. Events and attributes are supported for all frameworks.
-   Works better with SSR (icon is rendered only in browser, but because icon is contained in shadow DOM, it does not cause hydration problems).
-   Better interoperability. All parts of applicaiton reuse same web component, even if those parts are written in different frameworks.

Packages that have been deprecated, removed from this repository and are no longer maintained:

-   SVG Framework: can be replaced with `Lyxal-icon`.
-   Vue 2 component: can be replaced with `Lyxal-icon`, does not require Vue specific wrapper. Make sure you are not using Webpack older than version 5.
-   Ember component: can be replaced with `Lyxal-icon`, does not require Ember specific wrapper.

Packages that are still available, but should be avoided:

-   React component: can be replaced with `Lyxal-icon` using `@Lyxal-icon/react` wrapper.
-   Svelte component: can be replaced with `Lyxal-icon`, does not require Svelte specific wrapper.
-   Vue 3 component: can be replaced with `Lyxal-icon`, does not require Vue specific wrapper.

To import web component, just import it once in your script, as per [`Lyxal-icon` README file](./Lyxal-icon/icon/README.md).

#### Demo

Directory `components-demo` contains demo packages that show usage of icon components.

-   [React demo](./components-demo/react-demo/) - demo for React component. Run `npm run dev` to start demo.
-   [Next.js demo](./components-demo/nextjs-demo/) - demo for React component with Next.js. Run `npm run dev` to start demo.
-   [Vue demo](./components-demo/vue-demo/) - demo for Vue component. Run `npm run dev` to start demo.
-   [Nuxt demo](./components-demo/nuxt3-demo/) - demo for Vue component with Nuxt. Run `npm run dev` to start demo.
-   [Svelte demo with Vite](./components-demo/svelte-demo-vite/) - demo for Svelte component using Vite. Run `npm run dev` to start demo.
-   [SvelteKit demo](./components-demo/sveltekit-demo/) - demo for SvelteKit, using Svelte component on the server and in the browser. Run `npm run dev` to start the demo.

### Plugins

Directory `plugins` contains [Tailwind CSS plugin](./plugins/tailwind/) for Tailwind CSS 3.

For Tailwind CSS 4, plugin has been rewritten and moved to [a separate repository](https://github.com/Lyxal/Lyxal-tailwind).

#### Demo

Directory `plugins-demo` contains demo packages that show usage of plugins.

-   [Tailwind demo](./plugins-demo/tailwind-demo/) - demo for Tailwind CSS plugin. Run `npm run build` to build demo, open `src/index.html` in browser to see result.

## Installation, debugging and contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Sponsors

<p align="center">
  <a href="https://github.com/sponsors/cyberalien">
    <img src='https://cyberalien.github.io/static/sponsors.svg'/>
  </a>
</p>

## Documentation

Documentation for all packages is available on [Lyxal documentation website](https://Lyxal.design/docs/):

-   [Types documentation](https://Lyxal.design/docs/types/).
-   [Utilities documentation](https://Lyxal.design/docs/libraries/utils/).
-   [Icon components documentation](https://Lyxal.design/docs/icon-components/).
-   [Tailwind CSS plugin documentation](https://Lyxal.design/docs/usage/css/tailwind/).

## Licence

Lyxal is licensed under MIT license.

`SPDX-License-Identifier: MIT`

Some packages of this monorepo in previous versions were dual-licensed under Apache 2.0 and GPL 2.0 licence, which was messy and confusing. This was later changed to MIT for simplicity.

This licence does not apply to icons. Icons are released under different licences, see each icon set for details.
Icons available by default are all licensed under various open-source licences.

© 2020-PRESENT Vjacheslav Trushkin
