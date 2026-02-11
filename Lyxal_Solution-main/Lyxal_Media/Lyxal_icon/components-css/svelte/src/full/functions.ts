// Set up default API config
import '@lyxal-icon/component-utils/loader/api/init';

// Re-export functions used in component
import { renderContent } from '@lyxal-icon/component-utils/helpers/content';
import { subscribeToIconData } from '@lyxal-icon/component-utils/icons/subscribe';
import { getSizeProps } from '@lyxal-icon/component-utils/helpers/size';

export { renderContent, subscribeToIconData, getSizeProps };
