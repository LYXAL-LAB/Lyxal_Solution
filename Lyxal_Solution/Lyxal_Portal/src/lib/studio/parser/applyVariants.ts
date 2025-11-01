import type { VariantStyle } from '../types/component';

/**
 * Applique les variants et styles selon le variant spécifié
 * 
 * Les variants sont des styles conditionnels définis dans la structure
 * du composant. Ils peuvent contenir des classes CSS et des variables CSS.
 * 
 * @param variants - Objet contenant les définitions de variants
 * @param variant - Nom du variant à appliquer (ex: "primary", "secondary")
 * @param props - Props actuelles du composant
 * @returns Props avec les styles du variant appliqués
 */
export const applyVariants = (
  variants: Record<string, VariantStyle> = {},
  variant: string = 'default',
  props: Record<string, any> = {}
): Record<string, any> => {
  const variantStyles = variants[variant] || variants.default || {};

  // Fusionner les classes CSS
  if (variantStyles.css_classes && Array.isArray(variantStyles.css_classes)) {
    const existingClasses = props.className || [];
    const classesArray = Array.isArray(existingClasses) 
      ? existingClasses 
      : typeof existingClasses === 'string'
      ? existingClasses.split(' ').filter(Boolean)
      : [existingClasses];

    // Fusionner et dédupliquer, puis convertir en string
    props.className = [...new Set([...classesArray, ...variantStyles.css_classes])].join(' ');
  } else if (props.className && Array.isArray(props.className)) {
    // Convertir className array en string si pas de variant
    props.className = props.className.join(' ');
  }

  // Fusionner les variables CSS (styles inline)
  if (variantStyles.css_variables && typeof variantStyles.css_variables === 'object') {
    props.style = {
      ...props.style,
      ...variantStyles.css_variables,
    };
  }

  return props;
};

