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

import { $buildXFAObject, NamespaceIds } from "./namespaces.js";
import { $content, $finalize } from "./symbol_utils.js";
import {
  ContentObject,
  IntegerObject,
  Option01,
  Option10,
  OptionObject,
  StringObject,
  XFAObject,
  XFAObjectArray,
} from "./xfa_object.js";
import { getInteger, getStringOption } from "./utils.js";
// @ts-ignore
import { shadow, warn } from "../../shared/util.js";

const CONFIG_NS_ID = NamespaceIds.config.id;

class Acrobat extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "acrobat", /* hasChildren = */ true);
    this.acrobat7 = null;
    this.autoSave = null;
    this.common = null;
    this.validate = null;
    this.validateApprovalSignatures = null;
    this.submitUrl = new XFAObjectArray();
  }
}

class Acrobat7 extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "acrobat7", /* hasChildren = */ true);
    this.dynamicRender = null;
  }
}

class ADBE_JSConsole extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "ADBE_JSConsole", ["delegate", "Enable", "Disable"]);
  }
}

class ADBE_JSDebugger extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "ADBE_JSDebugger", ["delegate", "Enable", "Disable"]);
  }
}

class AddSilentPrint extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "addSilentPrint");
  }
}

class AddViewerPreferences extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "addViewerPreferences");
  }
}

class AdjustData extends Option10 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "adjustData");
  }
}

class AdobeExtensionLevel extends IntegerObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "adobeExtensionLevel", 0, n => n >= 1 && n <= 8);
  }
}

class Agent extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "agent", /* hasChildren = */ true);
    this.name = attributes.name ? attributes.name.trim() : "";
    this.common = new XFAObjectArray();
  }
}

class AlwaysEmbed extends ContentObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "alwaysEmbed");
  }
}

class Amd extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "amd");
  }
}

class Area extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "area");
    this.level = getInteger({
      data: attributes.level,
      defaultValue: 0,
      validate: n => n >= 1 && n <= 3,
    });
    this.name = getStringOption(attributes.name, [
      "",
      "barcode",
      "coreinit",
      "deviceDriver",
      "font",
      "general",
      "layout",
      "merge",
      "script",
      "signature",
      "sourceSet",
      "templateCache",
    ]);
  }
}

class Attributes extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "attributes", ["preserve", "delegate", "ignore"]);
  }
}

class AutoSave extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "autoSave", ["disabled", "enabled"]);
  }
}

class Base extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "base");
  }
}

class BatchOutput extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "batchOutput");
    this.format = getStringOption(attributes.format, [
      "none",
      "concat",
      "zip",
      "zipCompress",
    ]);
  }
}

class BehaviorOverride extends ContentObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "behaviorOverride");
  }

  [$finalize]() {
    this[$content] = new Map(
      this[$content]
        .trim()
        .split(/\s+/)
        .filter((x: any) => x.includes(":"))
        .map((x: any) => x.split(":", 2))
    );
  }
}

class Cache extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "cache", /* hasChildren = */ true);
    this.templateCache = null;
  }
}

class Change extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "change");
  }
}

class Common extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "common", /* hasChildren = */ true);
    this.data = null;
    this.locale = null;
    this.localeSet = null;
    this.messaging = null;
    this.suppressBanner = null;
    this.template = null;
    this.validationMessaging = null;
    this.versionControl = null;
    this.log = new XFAObjectArray();
  }
}

class Compress extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "compress");
    this.scope = getStringOption(attributes.scope, ["imageOnly", "document"]);
  }
}

class CompressLogicalStructure extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "compressLogicalStructure");
  }
}

class CompressObjectStream extends Option10 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "compressObjectStream");
  }
}

class Compression extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "compression", /* hasChildren = */ true);
    this.compressLogicalStructure = null;
    this.compressObjectStream = null;
    this.level = null;
    this.type = null;
  }
}

class Config extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "config", /* hasChildren = */ true);
    this.acrobat = null;
    this.present = null;
    this.trace = null;
    this.agent = new XFAObjectArray();
  }
}

class Conformance extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "conformance", ["A", "B"]);
  }
}

class ContentCopy extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "contentCopy");
  }
}

class Copies extends IntegerObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "copies", 1, n => n >= 1);
  }
}

class Creator extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "creator");
  }
}

class CurrentPage extends IntegerObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "currentPage", 0, n => n >= 0);
  }
}

class Data extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "data", /* hasChildren = */ true);
    this.adjustData = null;
    this.attributes = null;
    this.incrementalLoad = null;
    this.outputXSL = null;
    this.range = null;
    this.record = null;
    this.startNode = null;
    this.uri = null;
    this.window = null;
    this.xsl = null;
    this.excludeNS = new XFAObjectArray();
    this.transform = new XFAObjectArray();
  }
}

class Debug extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "debug", /* hasChildren = */ true);
    this.uri = null;
  }
}

class DefaultTypeface extends ContentObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "defaultTypeface");
    this.writingScript = getStringOption(attributes.writingScript, [
      "*",
      "Arabic",
      "Cyrillic",
      "EastEuropeanRoman",
      "Greek",
      "Hebrew",
      "Japanese",
      "Korean",
      "Roman",
      "SimplifiedChinese",
      "Thai",
      "TraditionalChinese",
      "Vietnamese",
    ]);
  }
}

class Destination extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "destination", [
      "pdf",
      "pcl",
      "ps",
      "webClient",
      "zpl",
    ]);
  }
}

class DocumentAssembly extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "documentAssembly");
  }
}

class Driver extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "driver", /* hasChildren = */ true);
    this.name = attributes.name ? attributes.name.trim() : "";
    this.fontInfo = null;
    this.xdc = null;
  }
}

class DuplexOption extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "duplexOption", [
      "simplex",
      "duplexFlipLongEdge",
      "duplexFlipShortEdge",
    ]);
  }
}

class DynamicRender extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "dynamicRender", ["forbidden", "required"]);
  }
}

class Embed extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "embed");
  }
}

class Encrypt extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "encrypt");
  }
}

class Encryption extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "encryption", /* hasChildren = */ true);
    this.encrypt = null;
    this.encryptionLevel = null;
    this.permissions = null;
  }
}

class EncryptionLevel extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "encryptionLevel", ["40bit", "128bit"]);
  }
}

class Enforce extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "enforce");
  }
}

class Equate extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "equate");

    this.force = getInteger({
      data: attributes.force,
      defaultValue: 1,
      validate: n => n === 0,
    });

    this.from = attributes.from || "";
    this.to = attributes.to || "";
  }
}

class EquateRange extends XFAObject {
  _unicodeRange: any;
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "equateRange");

    this.from = attributes.from || "";
    this.to = attributes.to || "";
    this._unicodeRange = attributes.unicodeRange || "";
  }

  get unicodeRange() {
    const ranges = [];
    const unicodeRegex = /U\+([0-9a-fA-F]+)/;
    const unicodeRange = this._unicodeRange;
    for (let range of unicodeRange
      .split(",")
      .map((x: any) => x.trim())
      .filter((x: any) => !!x)) {
      range = range.split("-", 2).map((x: any) => {
        const found = x.match(unicodeRegex);
        if (!found) {
          return 0;
        }
        return parseInt(found[1], 16);
      });
      if (range.length === 1) {
        range.push(range[0]);
      }
      ranges.push(range);
    }
    return shadow(this, "unicodeRange", ranges);
  }
}

class Exclude extends ContentObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "exclude");
  }

  [$finalize]() {
    this[$content] = this[$content]
      .trim()
      .split(/\s+/)
      .filter(
        (x: any) =>
          x &&
          [
            "calculate",
            "close",
            "enter",
            "exit",
            "initialize",
            "ready",
            "validate",
          ].includes(x)
      );
  }
}

class ExcludeNS extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "excludeNS");
  }
}

class FlipLabel extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "flipLabel", ["usePrinterSetting", "on", "off"]);
  }
}

class FontInfo extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "fontInfo", /* hasChildren = */ true);
    this.embed = null;
    this.map = null;
    this.subsetBelow = null;
    this.alwaysEmbed = new XFAObjectArray();
    this.defaultTypeface = new XFAObjectArray();
    this.neverEmbed = new XFAObjectArray();
  }
}

class FormFieldFilling extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "formFieldFilling");
  }
}

class GroupParent extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "groupParent");
  }
}

class IfEmpty extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "ifEmpty", [
      "dataValue",
      "dataGroup",
      "ignore",
      "remove",
    ]);
  }
}

class IncludeXDPContent extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "includeXDPContent");
  }
}

class IncrementalLoad extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "incrementalLoad", ["none", "forwardOnly"]);
  }
}

class IncrementalMerge extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "incrementalMerge");
  }
}

class Interactive extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "interactive");
  }
}

class Jog extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "jog", ["usePrinterSetting", "none", "pageSet"]);
  }
}

class LabelPrinter extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "labelPrinter", /* hasChildren = */ true);
    this.name = getStringOption(attributes.name, ["zpl", "dpl", "ipl", "tcpl"]);
    this.batchOutput = null;
    this.flipLabel = null;
    this.fontInfo = null;
    this.xdc = null;
  }
}

class Layout extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "layout", ["paginate", "panel"]);
  }
}

class Level extends IntegerObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "level", 0, n => n > 0);
  }
}

class Linearized extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "linearized");
  }
}

class Locale extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "locale");
  }
}

class LocaleSet extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "localeSet");
  }
}

class Log extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "log", /* hasChildren = */ true);
    this.mode = null;
    this.threshold = null;
    this.to = null;
    this.uri = null;
  }
}

// Renamed in MapElement to avoid confusion with usual js Map.
class MapElement extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "map", /* hasChildren = */ true);
    this.equate = new XFAObjectArray();
    this.equateRange = new XFAObjectArray();
  }
}

class MediumInfo extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "mediumInfo", /* hasChildren = */ true);
    this.map = null;
  }
}

class Message extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "message", /* hasChildren = */ true);
    this.msgId = null;
    this.severity = null;
  }
}

class Messaging extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "messaging", /* hasChildren = */ true);
    this.message = new XFAObjectArray();
  }
}

class Mode extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "mode", ["append", "overwrite"]);
  }
}

class ModifyAnnots extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "modifyAnnots");
  }
}

class MsgId extends IntegerObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "msgId", 1, n => n >= 1);
  }
}

class NameAttr extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "nameAttr");
  }
}

class NeverEmbed extends ContentObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "neverEmbed");
  }
}

class NumberOfCopies extends IntegerObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "numberOfCopies", null, n => n >= 2 && n <= 5);
  }
}

class OpenAction extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "openAction", /* hasChildren = */ true);
    this.destination = null;
  }
}

class Output extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "output", /* hasChildren = */ true);
    this.to = null;
    this.type = null;
    this.uri = null;
  }
}

class OutputBin extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "outputBin");
  }
}

class OutputXSL extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "outputXSL", /* hasChildren = */ true);
    this.uri = null;
  }
}

class Overprint extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "overprint", ["none", "both", "draw", "field"]);
  }
}

class Packets extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "packets");
  }

  [$finalize]() {
    if (this[$content] === "*") {
      return;
    }
    this[$content] = this[$content]
      .trim()
      .split(/\s+/)
      .filter((x: any) =>
        ["config", "datasets", "template", "xfdf", "xslt"].includes(x)
      );
  }
}

class PageOffset extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "pageOffset");
    this.x = getInteger({
      data: attributes.x,
      defaultValue: "useXDCSetting" as any,
      validate: n => true,
    });
    this.y = getInteger({
      data: attributes.y,
      defaultValue: "useXDCSetting" as any,
      validate: n => true,
    });
  }
}

class PageRange extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "pageRange");
  }

  [$finalize]() {
    const numbers = this[$content]
      .trim()
      .split(/\s+/)
      .map((x: any) => parseInt(x, 10));
    const ranges = [];
    for (let i = 0, ii = numbers.length; i < ii; i += 2) {
      ranges.push(numbers.slice(i, i + 2));
    }
    this[$content] = ranges;
  }
}

class Pagination extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "pagination", [
      "simplex",
      "duplexShortEdge",
      "duplexLongEdge",
    ]);
  }
}

class PaginationOverride extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "paginationOverride", [
      "none",
      "forceDuplex",
      "forceDuplexLongEdge",
      "forceDuplexShortEdge",
      "forceSimplex",
    ]);
  }
}

class Part extends IntegerObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "part", 1, n => false);
  }
}

class Pcl extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "pcl", /* hasChildren = */ true);
    this.name = attributes.name || "";
    this.batchOutput = null;
    this.fontInfo = null;
    this.jog = null;
    this.mediumInfo = null;
    this.outputBin = null;
    this.pageOffset = null;
    this.staple = null;
    this.xdc = null;
  }
}

class Pdf extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "pdf", /* hasChildren = */ true);
    this.name = attributes.name || "";
    this.adobeExtensionLevel = null;
    this.batchOutput = null;
    this.compression = null;
    this.creator = null;
    this.encryption = null;
    this.fontInfo = null;
    this.interactive = null;
    this.linearized = null;
    this.openAction = null;
    this.pdfa = null;
    this.producer = null;
    this.renderPolicy = null;
    this.scriptModel = null;
    this.silentPrint = null;
    this.submitFormat = null;
    this.tagged = null;
    this.version = null;
    this.viewerPreferences = null;
    this.xdc = null;
  }
}

class Pdfa extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "pdfa", /* hasChildren = */ true);
    this.amd = null;
    this.conformance = null;
    this.includeXDPContent = null;
    this.part = null;
  }
}

class Permissions extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "permissions", /* hasChildren = */ true);
    this.accessibleContent = null;
    this.change = null;
    this.contentCopy = null;
    this.documentAssembly = null;
    this.formFieldFilling = null;
    this.modifyAnnots = null;
    this.plaintextMetadata = null;
    this.print = null;
    this.printHighQuality = null;
  }
}

class PickTrayByPDFSize extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "pickTrayByPDFSize");
  }
}

class Picture extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "picture");
  }

  // TODO: check the validity of the picture clause.
  // See page 1150 in the spec.
}

class PlaintextMetadata extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "plaintextMetadata");
  }
}

class Presence extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "presence", [
      "preserve",
      "dissolve",
      "dissolveStructure",
      "ignore",
      "remove",
    ]);
  }
}

class Present extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "present", /* hasChildren = */ true);
    this.behaviorOverride = null;
    this.cache = null;
    this.common = null;
    this.copies = null;
    this.destination = null;
    this.incrementalMerge = null;
    this.layout = null;
    this.output = null;
    this.overprint = null;
    this.pagination = null;
    this.paginationOverride = null;
    this.script = null;
    this.validate = null;
    this.xdp = null;
    this.driver = new XFAObjectArray();
    this.labelPrinter = new XFAObjectArray();
    this.pcl = new XFAObjectArray();
    this.pdf = new XFAObjectArray();
    this.ps = new XFAObjectArray();
    this.submitUrl = new XFAObjectArray();
    this.webClient = new XFAObjectArray();
    this.zpl = new XFAObjectArray();
  }
}

class Print extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "print");
  }
}

class PrintHighQuality extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "printHighQuality");
  }
}

class PrintScaling extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "printScaling", ["appdefault", "noScaling"]);
  }
}

class PrinterName extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "printerName");
  }
}

class Producer extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "producer");
  }
}

class Ps extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "ps", /* hasChildren = */ true);
    this.name = attributes.name || "";
    this.batchOutput = null;
    this.fontInfo = null;
    this.jog = null;
    this.mediumInfo = null;
    this.outputBin = null;
    this.staple = null;
    this.xdc = null;
  }
}

class Range extends ContentObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "range");
  }

  [$finalize]() {
    this[$content] = this[$content]
      .split(",", 2)
      .map((range: any) => range.split("-").map((x: any) => parseInt(x.trim(), 10)))
      .filter((range: any) => range.every((x: any) => !isNaN(x)))
      .map((range: any) => {
        if (range.length === 1) {
          range.push(range[0]);
        }
        return range;
      });
  }
}

class Record extends ContentObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "record");
  }

  [$finalize]() {
    this[$content] = this[$content].trim();
    const n = parseInt(this[$content], 10);
    if (!isNaN(n) && n >= 0) {
      this[$content] = n;
    }
  }
}

class Relevant extends ContentObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "relevant");
  }

  [$finalize]() {
    this[$content] = this[$content].trim().split(/\s+/);
  }
}

class Rename extends ContentObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "rename");
  }

  [$finalize]() {
    this[$content] = this[$content].trim();
    // String must be a XFA name: same as XML one except that there
    // is no colon.
    if (
      this[$content].toLowerCase().startsWith("xml") ||
      new RegExp("[\\p{L}_][\\p{L}\\d._\\p{M}-]*", "u").test(this[$content])
    ) {
      warn("XFA - Rename: invalid XFA name");
    }
  }
}

class RenderPolicy extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "renderPolicy", ["server", "client"]);
  }
}

class RunScripts extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "runScripts", ["both", "client", "none", "server"]);
  }
}

class Script extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "script", /* hasChildren = */ true);
    this.currentPage = null;
    this.exclude = null;
    this.runScripts = null;
  }
}

class ScriptModel extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "scriptModel", ["XFA", "none"]);
  }
}

class Severity extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "severity", [
      "ignore",
      "error",
      "information",
      "trace",
      "warning",
    ]);
  }
}

class SilentPrint extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "silentPrint", /* hasChildren = */ true);
    this.addSilentPrint = null;
    this.printerName = null;
  }
}

class Staple extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "staple");
    this.mode = getStringOption(attributes.mode, [
      "usePrinterSetting",
      "on",
      "off",
    ]);
  }
}

class StartNode extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "startNode");
  }
}

class StartPage extends IntegerObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "startPage", 0, n => true);
  }
}

class SubmitFormat extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "submitFormat", [
      "html",
      "delegate",
      "fdf",
      "xml",
      "pdf",
    ]);
  }
}

class SubmitUrl extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "submitUrl");
  }
}

class SubsetBelow extends IntegerObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "subsetBelow", 100, n => n >= 0 && n <= 100);
  }
}

class SuppressBanner extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "suppressBanner");
  }
}

class Tagged extends Option01 {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "tagged");
  }
}

class Template extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "template", /* hasChildren = */ true);
    this.base = null;
    this.relevant = null;
    this.startPage = null;
    this.uri = null;
    this.xsl = null;
  }
}

class TemplateCache extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "templateCache");
    this.maxEntries = getInteger({
      data: attributes.maxEntries,
      defaultValue: 5,
      validate: n => n >= 0,
    });
  }
}

class Threshold extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "threshold", [
      "trace",
      "error",
      "information",
      "warning",
    ]);
  }
}

class To extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "to", [
      "null",
      "memory",
      "stderr",
      "stdout",
      "system",
      "uri",
    ]);
  }
}

class Trace extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "trace", /* hasChildren = */ true);
    this.area = new XFAObjectArray();
  }
}

class Transform extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "transform", /* hasChildren = */ true);
    this.groupParent = null;
    this.ifEmpty = null;
    this.nameAttr = null;
    this.picture = null;
    this.presence = null;
    this.rename = null;
    this.whitespace = null;
  }
}

class Type extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "type", [
      "none",
      "ascii85",
      "asciiHex",
      "ccittfax",
      "flate",
      "lzw",
      "runLength",
      "native",
      "xdp",
      "mergedXDP",
    ]);
  }
}

class Uri extends StringObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "uri");
  }
}

class Validate extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "validate", [
      "preSubmit",
      "prePrint",
      "preExecute",
      "preSave",
    ]);
  }
}

class ValidateApprovalSignatures extends ContentObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "validateApprovalSignatures");
  }

  [$finalize]() {
    this[$content] = this[$content]
      .trim()
      .split(/\s+/)
      .filter((x: any) => ["docReady", "postSign"].includes(x));
  }
}

class ValidationMessaging extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "validationMessaging", [
      "allMessagesIndividually",
      "allMessagesTogether",
      "firstMessageOnly",
      "noMessages",
    ]);
  }
}

class Version extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "version", ["1.7", "1.6", "1.5", "1.4", "1.3", "1.2"]);
  }
}

class VersionControl extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "VersionControl");
    this.outputBelow = getStringOption(attributes.outputBelow, [
      "warn",
      "error",
      "update",
    ]);
    this.sourceAbove = getStringOption(attributes.sourceAbove, [
      "warn",
      "error",
    ]);
    this.sourceBelow = getStringOption(attributes.sourceBelow, [
      "update",
      "maintain",
    ]);
  }
}

class ViewerPreferences extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "viewerPreferences", /* hasChildren = */ true);
    this.ADBE_JSConsole = null;
    this.ADBE_JSDebugger = null;
    this.addViewerPreferences = null;
    this.duplexOption = null;
    this.enforce = null;
    this.numberOfCopies = null;
    this.pageRange = null;
    this.pickTrayByPDFSize = null;
    this.printScaling = null;
  }
}

class WebClient extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "webClient", /* hasChildren = */ true);
    this.name = attributes.name ? attributes.name.trim() : "";
    this.fontInfo = null;
    this.xdc = null;
  }
}

class Whitespace extends OptionObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "whitespace", [
      "preserve",
      "ltrim",
      "normalize",
      "rtrim",
      "trim",
    ]);
  }
}

class Window extends ContentObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "window");
  }

  [$finalize]() {
    const pair = this[$content].split(",", 2).map((x: any) => parseInt(x.trim(), 10));
    if (pair.some((x: any) => isNaN(x))) {
      this[$content] = [0, 0];
      return;
    }
    if (pair.length === 1) {
      pair.push(pair[0]);
    }
    this[$content] = pair;
  }
}

class Xdc extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "xdc", /* hasChildren = */ true);
    this.uri = new XFAObjectArray();
    this.xsl = new XFAObjectArray();
  }
}

class Xdp extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "xdp", /* hasChildren = */ true);
    this.packets = null;
  }
}

class Xsl extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "xsl", /* hasChildren = */ true);
    this.debug = null;
    this.uri = null;
  }
}

class Zpl extends XFAObject {
  constructor(attributes: any) {
    super(CONFIG_NS_ID, "zpl", /* hasChildren = */ true);
    this.name = attributes.name ? attributes.name.trim() : "";
    this.batchOutput = null;
    this.flipLabel = null;
    this.fontInfo = null;
    this.xdc = null;
  }
}

class ConfigNamespace {
  [key: string]: any;
  static [$buildXFAObject](name: string, attributes: any) {
    if (ConfigNamespace.hasOwnProperty(name)) {
      return ConfigNamespace[name](attributes);
    }
    return undefined;
  }

  static acrobat(attrs: any) {
    return new Acrobat(attrs);
  }

  static acrobat7(attrs: any) {
    return new Acrobat7(attrs);
  }

  static ADBE_JSConsole(attrs: any) {
    return new ADBE_JSConsole(attrs);
  }

  static ADBE_JSDebugger(attrs: any) {
    return new ADBE_JSDebugger(attrs);
  }

  static addSilentPrint(attrs: any) {
    return new AddSilentPrint(attrs);
  }

  static addViewerPreferences(attrs: any) {
    return new AddViewerPreferences(attrs);
  }

  static adjustData(attrs: any) {
    return new AdjustData(attrs);
  }

  static adobeExtensionLevel(attrs: any) {
    return new AdobeExtensionLevel(attrs);
  }

  static agent(attrs: any) {
    return new Agent(attrs);
  }

  static alwaysEmbed(attrs: any) {
    return new AlwaysEmbed(attrs);
  }

  static amd(attrs: any) {
    return new Amd(attrs);
  }

  static area(attrs: any) {
    return new Area(attrs);
  }

  static attributes(attrs: any) {
    return new Attributes(attrs);
  }

  static autoSave(attrs: any) {
    return new AutoSave(attrs);
  }

  static base(attrs: any) {
    return new Base(attrs);
  }

  static batchOutput(attrs: any) {
    return new BatchOutput(attrs);
  }

  static behaviorOverride(attrs: any) {
    return new BehaviorOverride(attrs);
  }

  static cache(attrs: any) {
    return new Cache(attrs);
  }

  static change(attrs: any) {
    return new Change(attrs);
  }

  static common(attrs: any) {
    return new Common(attrs);
  }

  static compress(attrs: any) {
    return new Compress(attrs);
  }

  static compressLogicalStructure(attrs: any) {
    return new CompressLogicalStructure(attrs);
  }

  static compressObjectStream(attrs: any) {
    return new CompressObjectStream(attrs);
  }

  static compression(attrs: any) {
    return new Compression(attrs);
  }

  static config(attrs: any) {
    return new Config(attrs);
  }

  static conformance(attrs: any) {
    return new Conformance(attrs);
  }

  static contentCopy(attrs: any) {
    return new ContentCopy(attrs);
  }

  static copies(attrs: any) {
    return new Copies(attrs);
  }

  static creator(attrs: any) {
    return new Creator(attrs);
  }

  static currentPage(attrs: any) {
    return new CurrentPage(attrs);
  }

  static data(attrs: any) {
    return new Data(attrs);
  }

  static debug(attrs: any) {
    return new Debug(attrs);
  }

  static defaultTypeface(attrs: any) {
    return new DefaultTypeface(attrs);
  }

  static destination(attrs: any) {
    return new Destination(attrs);
  }

  static documentAssembly(attrs: any) {
    return new DocumentAssembly(attrs);
  }

  static driver(attrs: any) {
    return new Driver(attrs);
  }

  static duplexOption(attrs: any) {
    return new DuplexOption(attrs);
  }

  static dynamicRender(attrs: any) {
    return new DynamicRender(attrs);
  }

  static embed(attrs: any) {
    return new Embed(attrs);
  }

  static encrypt(attrs: any) {
    return new Encrypt(attrs);
  }

  static encryption(attrs: any) {
    return new Encryption(attrs);
  }

  static encryptionLevel(attrs: any) {
    return new EncryptionLevel(attrs);
  }

  static enforce(attrs: any) {
    return new Enforce(attrs);
  }

  static equate(attrs: any) {
    return new Equate(attrs);
  }

  static equateRange(attrs: any) {
    return new EquateRange(attrs);
  }

  static exclude(attrs: any) {
    return new Exclude(attrs);
  }

  static excludeNS(attrs: any) {
    return new ExcludeNS(attrs);
  }

  static flipLabel(attrs: any) {
    return new FlipLabel(attrs);
  }

  static fontInfo(attrs: any) {
    return new FontInfo(attrs);
  }

  static formFieldFilling(attrs: any) {
    return new FormFieldFilling(attrs);
  }

  static groupParent(attrs: any) {
    return new GroupParent(attrs);
  }

  static ifEmpty(attrs: any) {
    return new IfEmpty(attrs);
  }

  static includeXDPContent(attrs: any) {
    return new IncludeXDPContent(attrs);
  }

  static incrementalLoad(attrs: any) {
    return new IncrementalLoad(attrs);
  }

  static incrementalMerge(attrs: any) {
    return new IncrementalMerge(attrs);
  }

  static interactive(attrs: any) {
    return new Interactive(attrs);
  }

  static jog(attrs: any) {
    return new Jog(attrs);
  }

  static labelPrinter(attrs: any) {
    return new LabelPrinter(attrs);
  }

  static layout(attrs: any) {
    return new Layout(attrs);
  }

  static level(attrs: any) {
    return new Level(attrs);
  }

  static linearized(attrs: any) {
    return new Linearized(attrs);
  }

  static locale(attrs: any) {
    return new Locale(attrs);
  }

  static localeSet(attrs: any) {
    return new LocaleSet(attrs);
  }

  static log(attrs: any) {
    return new Log(attrs);
  }

  static map(attrs: any) {
    return new MapElement(attrs);
  }

  static mediumInfo(attrs: any) {
    return new MediumInfo(attrs);
  }

  static message(attrs: any) {
    return new Message(attrs);
  }

  static messaging(attrs: any) {
    return new Messaging(attrs);
  }

  static mode(attrs: any) {
    return new Mode(attrs);
  }

  static modifyAnnots(attrs: any) {
    return new ModifyAnnots(attrs);
  }

  static msgId(attrs: any) {
    return new MsgId(attrs);
  }

  static nameAttr(attrs: any) {
    return new NameAttr(attrs);
  }

  static neverEmbed(attrs: any) {
    return new NeverEmbed(attrs);
  }

  static numberOfCopies(attrs: any) {
    return new NumberOfCopies(attrs);
  }

  static openAction(attrs: any) {
    return new OpenAction(attrs);
  }

  static output(attrs: any) {
    return new Output(attrs);
  }

  static outputBin(attrs: any) {
    return new OutputBin(attrs);
  }

  static outputXSL(attrs: any) {
    return new OutputXSL(attrs);
  }

  static overprint(attrs: any) {
    return new Overprint(attrs);
  }

  static packets(attrs: any) {
    return new Packets(attrs);
  }

  static pageOffset(attrs: any) {
    return new PageOffset(attrs);
  }

  static pageRange(attrs: any) {
    return new PageRange(attrs);
  }

  static pagination(attrs: any) {
    return new Pagination(attrs);
  }

  static paginationOverride(attrs: any) {
    return new PaginationOverride(attrs);
  }

  static part(attrs: any) {
    return new Part(attrs);
  }

  static pcl(attrs: any) {
    return new Pcl(attrs);
  }

  static pdf(attrs: any) {
    return new Pdf(attrs);
  }

  static pdfa(attrs: any) {
    return new Pdfa(attrs);
  }

  static permissions(attrs: any) {
    return new Permissions(attrs);
  }

  static pickTrayByPDFSize(attrs: any) {
    return new PickTrayByPDFSize(attrs);
  }

  static picture(attrs: any) {
    return new Picture(attrs);
  }

  static plaintextMetadata(attrs: any) {
    return new PlaintextMetadata(attrs);
  }

  static presence(attrs: any) {
    return new Presence(attrs);
  }

  static present(attrs: any) {
    return new Present(attrs);
  }

  static print(attrs: any) {
    return new Print(attrs);
  }

  static printHighQuality(attrs: any) {
    return new PrintHighQuality(attrs);
  }

  static printScaling(attrs: any) {
    return new PrintScaling(attrs);
  }

  static printerName(attrs: any) {
    return new PrinterName(attrs);
  }

  static producer(attrs: any) {
    return new Producer(attrs);
  }

  static ps(attrs: any) {
    return new Ps(attrs);
  }

  static range(attrs: any) {
    return new Range(attrs);
  }

  static record(attrs: any) {
    return new Record(attrs);
  }

  static relevant(attrs: any) {
    return new Relevant(attrs);
  }

  static rename(attrs: any) {
    return new Rename(attrs);
  }

  static renderPolicy(attrs: any) {
    return new RenderPolicy(attrs);
  }

  static runScripts(attrs: any) {
    return new RunScripts(attrs);
  }

  static script(attrs: any) {
    return new Script(attrs);
  }

  static scriptModel(attrs: any) {
    return new ScriptModel(attrs);
  }

  static severity(attrs: any) {
    return new Severity(attrs);
  }

  static silentPrint(attrs: any) {
    return new SilentPrint(attrs);
  }

  static staple(attrs: any) {
    return new Staple(attrs);
  }

  static startNode(attrs: any) {
    return new StartNode(attrs);
  }

  static startPage(attrs: any) {
    return new StartPage(attrs);
  }

  static submitFormat(attrs: any) {
    return new SubmitFormat(attrs);
  }

  static submitUrl(attrs: any) {
    return new SubmitUrl(attrs);
  }

  static subsetBelow(attrs: any) {
    return new SubsetBelow(attrs);
  }

  static suppressBanner(attrs: any) {
    return new SuppressBanner(attrs);
  }

  static tagged(attrs: any) {
    return new Tagged(attrs);
  }

  static template(attrs: any) {
    return new Template(attrs);
  }

  static templateCache(attrs: any) {
    return new TemplateCache(attrs);
  }

  static threshold(attrs: any) {
    return new Threshold(attrs);
  }

  static to(attrs: any) {
    return new To(attrs);
  }

  static trace(attrs: any) {
    return new Trace(attrs);
  }

  static transform(attrs: any) {
    return new Transform(attrs);
  }

  static type(attrs: any) {
    return new Type(attrs);
  }

  static uri(attrs: any) {
    return new Uri(attrs);
  }

  static validate(attrs: any) {
    return new Validate(attrs);
  }

  static validateApprovalSignatures(attrs: any) {
    return new ValidateApprovalSignatures(attrs);
  }

  static validationMessaging(attrs: any) {
    return new ValidationMessaging(attrs);
  }

  static version(attrs: any) {
    return new Version(attrs);
  }

  static versionControl(attrs: any) {
    return new VersionControl(attrs);
  }

  static viewerPreferences(attrs: any) {
    return new ViewerPreferences(attrs);
  }

  static webClient(attrs: any) {
    return new WebClient(attrs);
  }

  static whitespace(attrs: any) {
    return new Whitespace(attrs);
  }

  static window(attrs: any) {
    return new Window(attrs);
  }

  static xdc(attrs: any) {
    return new Xdc(attrs);
  }

  static xdp(attrs: any) {
    return new Xdp(attrs);
  }

  static xsl(attrs: any) {
    return new Xsl(attrs);
  }

  static zpl(attrs: any) {
    return new Zpl(attrs);
  }
}

export { ConfigNamespace };

