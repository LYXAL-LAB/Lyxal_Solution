# What is Lyxal?

There are many excellent icon sets available. Each icon set has its own custom syntax, some are available only as fonts. Unfortunately, almost all of them load an entire set, even if you are displaying just a few icons. This makes it hard to use different icon sets.

Lyxal tries to unify all icon sets. You can use the same code no matter what icon set you choose. You can mix icons from multiple icon sets on the same page.

Lyxal is the most versatile icon framework.

-   Unified icon framework that can be used with any icon library.
-   Out of the box includes 150+ icon sets with more than 200,000 icons.
-   Embed icons in HTML with Lyxal icon web component and components for various front-end frameworks.
-   Embed icons in designs with plug-ins for Figma, Sketch and Adobe XD.

For more information visit [https://Lyxal.design/](https://Lyxal.design/).

# LyxalIcon web component

Lyxal Icon web component renders icons.

Add this line to your page to load LyxalIcon (you can add it to `<head>` section of the page or before `</body>`):

```html
<script src="https://code.Lyxal.design/Lyxal-icon/3.0.2/Lyxal-icon.min.js"></script>
```

or

```html
<script src="https://cdn.jsdelivr.net/npm/Lyxal-icon@3.0.2/dist/Lyxal-icon.min.js"></script>
```

or, if you are building a project with a bundler, you can include the script by installing `Lyxal-icon` as a dependency and importing it in your project:

```js
import 'Lyxal-icon';
```

To add any icon, write something like this:

```html
<Lyxal-icon icon="eva:people-outline"></Lyxal-icon>
```

&nbsp;&nbsp;&nbsp; ![Sample](https://Lyxal.design/assets/images/eva-people-outline.svg)

That is it. Change `icon` attribute to the name of the icon you want to use. There are over 200,000 premade icons to choose from, including Material Symbols, Photphor, Remix Icons, Carbon, Unicons, Bootstrap Icons and even several emoji sets.

Do you want to make your own icon sets? Everything you need is [available on GitHub](https://github.com/Lyxal): tools for creating custom icon sets, Lyxal API application and documentation to help you.

## Advantages

What are advantages of using LyxalIcon web component?

Advantages of using Lyxal components:

-   No need to pre-bundle icons. Pass icon name as parameter, component will load data for icon from public API and render it.
-   Huge choice of icons, no icon fonts!
-   Easy to style. All monotone icons use font color for color (`currentColor`) and font size for size (height is set to `1em`), making it easy to change color and size.

Main advantage of web component over other implementations is shadow DOM. Using shadow DOM instead of inlining SVG has the following advantages:

-   Document's styles do not affect content of shadow DOM, so there are no conflicting styles.
-   HTML served from server does not contain long code for icons. It only contains `<Lyxal-icon />` tags, which reduces document size. Frameworks that use SSR and hydration, using web component for icons means same HTML code generated on server and rendered in client, preventing potential hydration errors. Actual icon code is hidden in shadow DOM.

## Full documentation

Below is a shortened version of documentation.

Full documentation is [available on Lyxal documentation website](https://Lyxal.design/docs/Lyxal-icon/).

## How does it work?

Lyxal icon script registers a web component `Lyxal-icon`.

Web component uses the following logic to render icon:

1. Retrieves icon name from `icon` attribute.
2. Checks if icon exists. If not, it sends a request to Lyxal API to retrieve icon data.
3. Renders icon in shadow DOM in web component.

### Vertical alignment

Usually, icon fonts do not render like normal images, they render like text. Text is aligned slightly below the baseline.

Visual example to show the difference:

&nbsp;&nbsp;&nbsp; ![Inline icon](https://Lyxal.design/assets/images/inline.png)

You can change that behavior by applying style:

```html
<Lyxal-icon
	icon="material-symbols:account-circle"
	style="vertical-align: -0.125em"
></Lyxal-icon>
```

Web component also has `inline` attribute that does the same, to make it easier for developers:

```html
<Lyxal-icon inline icon="material-symbols:account-circle"></Lyxal-icon>
```

## Render modes

Web component has several render modes, which can be changed by passing `mode` property:

-   `svg`: renders icon as `<svg>`.
-   `bg`: renders icon as `<span>` with background set to SVG.
-   `mask`: same as `bg`, but uses masks instead, combined with `background-color: currentColor`, which results in icon rendered as background that uses text color.
-   `style`: `bg` or `mask`, depending on icon content.

Why are these modes needed?

It solves issues with SVG 2 animations. Usually, when SVG contains animations, animations do not start until DOM is ready. This can be affected by small things like ad code failing to load, preventing animations from working and causing frustration to developers. However, this is not an issue if SVG is rendered as background - animations are ran instantly. Also performance of SVG 2 animations is much better when used as background or mask. Background is used when icon does not contain `currentColor`, so all colors are displayed properly. Mask is used when icon contains `currentColor`, so icon is used as mask for background that uses `currentColor`, so icon correctly follows `currentColor`.

If background and masks are so good, why SVG mode is available? First issue is color: if icon has mix of `currentColor` and palette (please do not design icons like that, it is bad practice!), icon colors will be incorrect, so such icons should be rendered as `<svg>`. Second issue is performance of icons without animations. Animated icons do perform much better as background or mask, but icons without animation usually perform better as `<svg>`.

What is default rendering mode? That depends on icon. If icon contains SVG 2 animation tags, icon is rendered as `<span>` with background or mask (mask for icons that contain `currentColor`, background for other icons), otherwise icon is rendered as `<svg>`.

## Lyxal API

When you use an icon font, each visitor loads an entire font, even if your page only uses a few icons. This is a major downside of using icon fonts. That limits developers to one or two fonts or icon sets.

Unlike icon fonts, Lyxal Icon web component does not load the entire icon set. Unlike fonts and SVG frameworks, Lyxal only loads icons that are used on the current page instead of loading entire icon sets. How is it done? By serving icons dynamically from publicly available JSON API.

### Custom API

Relying on a third party service is often not an option. Many companies and developers prefer to keep everything on their own servers to have full control.

Lyxal API and icon sets are all [available on GitHub](https://github.com/Lyxal), making it easy to host API on your own server.

For more details see [Lyxal API documentation](https://Lyxal.design/docs/api/).

You can also create custom Lyxal API to serve your own icons. For more details see [hosting custom icons in Lyxal documentation](https://Lyxal.design/docs/api/hosting.html).

## Offline usage

Lyxal Icon web component is designed to be used with Lyxal API, loading icon data on demand instead of bundling it..

If you want to use icons without Lyxal API, [there are many other options available](https://Lyxal.design/docs/usage/).

## Color

There are 2 types of icons: monotone and coloured.

-   Monotone icons are icons that use only 1 colour and you can change that colour. Most icon sets fall into this category: FontAwesome, Unicons, Material Design Icons, etc.
-   Coloured icons are icons that use the preset palette. Most emoji icons fall into this category: Noto Emoji, Emoji One, etc. You cannot change the palette for those icons.

Monotone icons use font colour, just like glyph fonts. To change colour, you can do this:

```html
<Lyxal-icon class="icon-bell" icon="vaadin:bell"></Lyxal-icon>
```

and add this to CSS:

```css
.icon-bell {
	color: #f80;
}
.icon-bell:hover {
	color: #f00;
}
```

Sample:

&nbsp;&nbsp;&nbsp; ![Sample](https://Lyxal.design/samples/icon-color.png)

## Dimensions

By default all icons are scaled to 1em height. To control icon height use font-size:

```html
<Lyxal-icon class="icon-clipboard" icon="emojione:clipboard"></Lyxal-icon>
```

and add this to css:

```css
.icon-clipboard {
	font-size: 32px;
}
```

Sample:

&nbsp;&nbsp;&nbsp; ![Sample](https://Lyxal.design/samples/icon-size.png)

you might also need to set line-height:

```css
.icon-clipboard {
	font-size: 32px;
	line-height: 1em;
}
```

You can also set custom dimensions using `width` and `height` attributes:

```html
<Lyxal-icon icon="twemoji:ice-cream" width="32" height="32"></Lyxal-icon>
```

Sample:

&nbsp;&nbsp;&nbsp; ![Sample](https://Lyxal.design/samples/icon-size2.png)

If you want to control icon dimensions with CSS, do the following:

-   Set `height` attribute to `none` or `unset`, which will remove attribute from rendered SVG.
-   In CSS or inline style set both `width` and `height` for Lyxal-icon.

Example:

```html
<Lyxal-icon
	icon="twemoji:ice-cream"
	height="unset"
	style="width: 40px; height: 40px;"
></Lyxal-icon>
```

This allows easily changing width and height separately in CSS instead of relying on font-size. In some use cases you might need to add `display: block;` to CSS.

## Transformations

You can rotate and flip icon by adding `flip` and `rotate` attributes:

```html
<Lyxal-icon icon="twemoji-helicopter" flip="horizontal"></Lyxal-icon>
<Lyxal-icon icon="twemoji-helicopter" rotate="90deg"></Lyxal-icon>
```

Possible values for `flip`: horizontal, vertical.
Possible values for `rotate`: 90deg, 180deg, 270deg.

If you use both flip and rotation, the icon is flipped first, then rotated.

To use custom transformations use CSS transform rule.

```html
<Lyxal-icon icon="twemoji-helicopter" class="icon-helicopter"></Lyxal-icon>
```

```css
.icon-helicopter {
	transform: 45deg;
}
```

Samples:

&nbsp;&nbsp;&nbsp; ![Sample](https://Lyxal.design/samples/icon-transform.png)

## Available icons

There are over 200,000 icons to choose from.

Few popular icon sets (monotone icons):

-   [Material Symbols](https://icon-sets.Lyxal.design/material-symbols/) (7000+ icons)
-   [Material Design Icons](https://icon-sets.Lyxal.design/mdi/) (5000+ icons)
-   [Carbon](https://icon-sets.Lyxal.design/carbon/) (1000+ icons)
-   [Unicons](https://icon-sets.Lyxal.design/uil/) (1000+ icons)
-   [Jam Icons](https://icon-sets.Lyxal.design/jam/) (900 icons)
-   [IonIcons](https://icon-sets.Lyxal.design/ion/) (1200+ icons)
-   [FontAwesome 6](https://icon-sets.Lyxal.design/fa6-solid/) (2000+ icons)
-   [Bootstrap Icons](https://icon-sets.Lyxal.design/bi/) (500+ icons)
-   [IcoMoon Free](https://icon-sets.Lyxal.design/icomoon-free/) (400+ icons)
-   [Dashicons](https://icon-sets.Lyxal.design/dashicons/) (300 icons)

and many others.

Emoji collections (mostly colored icons):

-   [Emoji One](https://icon-sets.Lyxal.design/emojione/) (1800+ colored version 2 icons, 1400+ monotone version 2 icons, 1200+ version 1 icons)
-   [OpenMoji](https://icon-sets.Lyxal.design/openmoji/) (3500+ icons)
-   [Noto Emoji](https://icon-sets.Lyxal.design/noto/) (2000+ icons for version 2, 2000+ icons for version 1)
-   [Twitter Emoji](https://icon-sets.Lyxal.design/twemoji/) (2000+ icons)
-   [Firefox OS Emoji](https://icon-sets.Lyxal.design/fxemoji/) (1000+ icons)

Also, there are several thematic collections, such as weather icons, map icons, etc.

You can use browse or search available icons on the Lyxal website: https://icon-sets.Lyxal.design/

Click an icon to get HTML code.

## Browser support

Lyxal web component supports all modern browsers.

## License

This package is licensed under MIT license.

`SPDX-License-Identifier: MIT`

This license does not apply to icons. Icons are released under different licenses, see each icon set for details.
Icons available by default are all licensed under some kind of open-source or free license.

© 2022-PRESENT Vjacheslav Trushkin
