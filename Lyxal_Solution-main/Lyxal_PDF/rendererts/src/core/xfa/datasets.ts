/* Copyright 2021 Mozilla Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import {
  $appendChild,
  $isNsAgnostic,
  $namespaceId,
  $nodeName,
  $onChild,
} from "./symbol_utils.js";
import { $buildXFAObject, NamespaceIds } from "./namespaces.js";
import { XFAObject, XmlObject } from "./xfa_object.js";

// @ts-ignore
const DATASETS_NS_ID = NamespaceIds.datasets.id;

class Data extends XmlObject {
  constructor(attributes: any) {
    super(DATASETS_NS_ID, "data", attributes);
  }

  [$isNsAgnostic]() {
    return true;
  }
}

class Datasets extends XFAObject {
  data: any | null;
  Signature: any | null;

  constructor(attributes: any) {
    super(DATASETS_NS_ID, "datasets", /* hasChildren = */ true);
    this.data = null;
    this.Signature = null;
  }

  [$onChild](child: any) {
    const name = child[$nodeName];
    if (
      (name === "data" && child[$namespaceId] === DATASETS_NS_ID) ||
      (name === "Signature" &&
        // @ts-ignore
        child[$namespaceId] === NamespaceIds.signature.id)
    ) {
      // @ts-ignore
      this[name] = child;
    }
    this[$appendChild](child);
  }
}

class DatasetsNamespace {
  static [$buildXFAObject](name: string, attributes: any) {
    if (DatasetsNamespace.hasOwnProperty(name)) {
      // @ts-ignore
      return DatasetsNamespace[name](attributes);
    }
    return undefined;
  }

  static datasets(attributes: any) {
    return new Datasets(attributes);
  }

  static data(attributes: any) {
    return new Data(attributes);
  }
}

export { DatasetsNamespace };

