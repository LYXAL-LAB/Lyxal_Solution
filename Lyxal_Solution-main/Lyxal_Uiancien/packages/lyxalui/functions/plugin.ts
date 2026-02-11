// Types TypeScript
interface PluginOptions {
  [key: string]: any;
}

interface PluginConfig {
  [key: string]: any;
}

interface PluginHandler {
  (options?: PluginOptions): {
    handler: any;
    config: PluginConfig;
  };
  __isOptionsFunction?: boolean;
}

interface PluginWithOptions {
  (pluginFunction: (options?: PluginOptions) => any, configFunction?: (options?: PluginOptions) => PluginConfig): PluginHandler;
  __isOptionsFunction?: boolean;
}

interface Plugin {
  withOptions: PluginWithOptions;
}

export const plugin: Plugin = {
  withOptions: (pluginFunction, configFunction = () => ({})) => {
    const optionsFunction: PluginHandler = (options) => {
      const handler = pluginFunction(options);
      const config = configFunction(options);
      return { handler, config };
    };
    optionsFunction.__isOptionsFunction = true;
    return optionsFunction;
  },
};
