// Types TypeScript pour Tailwind CSS
interface AddBaseFunction {
  (styles: Record<string, any>): void;
}

interface AddComponentsFunction {
  (components: Record<string, any>): void;
}

interface AddUtilitiesFunction {
  (utilities: Record<string, any>): void;
}

interface AddVariantFunction {
  (name: string, definition: string | string[]): void;
}

interface TailwindHelpers {
  addBase: AddBaseFunction;
  addComponents: AddComponentsFunction;
  addUtilities: AddUtilitiesFunction;
  addVariant: AddVariantFunction;
}

const version = "1.0.0"
import { pluginOptionsHandler } from "./functions/pluginOptionsHandler.ts"
import { plugin } from "./functions/plugin.ts"
import variables from "./functions/variables.ts"
import themesObject from "./theme/object.ts"
import { base, components, utilities } from "./imports.ts"

export default plugin.withOptions(
  (options) => {
    return (helpers: TailwindHelpers) => {
      const { addBase, addComponents, addUtilities, addVariant } = helpers;
      const {
        include,
        exclude,
        prefix = "",
      } = pluginOptionsHandler(options, addBase, themesObject, version)

      const shouldIncludeItem = (name: string) => {
        if (include && exclude) {
          return include.includes(name) && !exclude.includes(name)
        }
        if (include) {
          return include.includes(name)
        }
        if (exclude) {
          return !exclude.includes(name)
        }
        return true
      }

      Object.entries(base).forEach(([name, item]: [string, any]) => {
        if (!shouldIncludeItem(name)) return
        item({ addBase, prefix })
      })

      Object.entries(components).forEach(([name, item]: [string, any]) => {
        if (!shouldIncludeItem(name)) return
        item({ addComponents, prefix })
      })

      Object.entries(utilities).forEach(([name, item]: [string, any]) => {
        if (!shouldIncludeItem(name)) return
        item({ addUtilities, prefix })
      })

      // drawer variants. Can not be nested in layers so defined here
      addVariant(
        `${prefix}is-drawer-close`,
        `&:where(.${prefix}drawer-toggle:not(:checked) ~ .${prefix}drawer-side, .${prefix}drawer-toggle:not(:checked) ~ .${prefix}drawer-side *)`,
      )
      addVariant(
        `${prefix}is-drawer-open`,
        `&:where(.${prefix}drawer-toggle:checked ~ .${prefix}drawer-side, .${prefix}drawer-toggle:checked ~ .${prefix}drawer-side *)`,
      )
    }
  },
  () => ({
    theme: {
      extend: variables,
    },
  }),
)
