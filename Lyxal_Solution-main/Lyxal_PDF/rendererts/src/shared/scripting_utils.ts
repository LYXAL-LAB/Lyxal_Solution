
/* Copyright 2020 Mozilla Foundation
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

import { Util } from "./util";

function convertBlackAndWhiteToRGB(color: number[]) {
  const c = color[0];
  return [c, c, c];
}

function convertCMYKToRGB(color: number[]) {
  const c = color[0],
    m = color[1],
    y = color[2],
    k = color[3];

  return [
    1 - Math.min(1, c + k),
    1 - Math.min(1, m + k),
    1 - Math.min(1, y + k),
  ];
}

export class ColorConverters {
  static get CMYK() {
    return convertCMYKToRGB;
  }

  static get Gray() {
    return convertBlackAndWhiteToRGB;
  }

  static get RGB() {
    return (color: number[]) => color;
  }

  static get T() {
    return (color: number[]) => null; // Transparent
  }
}

