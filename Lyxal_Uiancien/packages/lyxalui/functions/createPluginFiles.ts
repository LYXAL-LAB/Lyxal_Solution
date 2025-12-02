// Types TypeScript
interface PluginTypes {
  base: string;
  component: string;
  utility: string;
}

type PluginType = keyof PluginTypes;

// Import des dépendances
import { promises as fs } from "fs";
import path from "path";

// Fonction pour créer les fichiers de plugin
export const createPluginFiles = async (
  type: PluginType,
  componentDir: string,
  jsContent: string,
  fileName: string,
): Promise<void> => {
  const types: PluginTypes = {
    base: "addBase",
    component: "addComponents",
    utility: "addUtilities",
  };

  // create object.ts
  const objectTsPath: string = path.join(componentDir, "object.ts");
  await fs.writeFile(objectTsPath, `export default ${jsContent};`);

  // create index.ts
  const indexTsPath: string = path.join(componentDir, "index.ts");
  const indexTsContent: string = `import ${fileName} from './object.ts';
import { addPrefix } from '../../functions/addPrefix.ts';

export default ({ ${types[type]}, prefix = '' }) => {
  const prefixed${fileName} = addPrefix(${fileName}, prefix);
  ${types[type]}({ ...prefixed${fileName} });
};
`;
  await fs.writeFile(indexTsPath, indexTsContent);
};
