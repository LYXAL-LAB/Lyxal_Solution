/* Copyright 2014 Mozilla Foundation
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
    AnnotationBorderStyleType,
    AnnotationEditorType,
    AnnotationPrefix,
    AnnotationType,
    FeatureTest,
    Util,
    warn,
    unreachable
} from "../shared/util";
import {
    PDFDateString,
    renderRichText,
    setLayerDimensions
} from "./display_utils";
import { AnnotationStorage } from "./annotation_storage";
import { ColorConverters } from "../shared/scripting_utils";
import { DOMSVGFactory } from "./svg_factory";
import { PDFPageProxy } from "./api";

// Interfaces for dependencies
interface PageViewport {
    width: number;
    height: number;
    scale: number;
    rotation: number;
    transform: number[];
    convertToViewportPoint(x: number, y: number): number[];
    convertToViewportRectangle(rect: number[]): number[];
}

interface IDownloadManager {
    downloadUrl(url: string, filename: string): void;
    downloadData(data: Uint8Array, filename: string, contentType: string): void;
    download(blob: Blob, url: string, filename: string): void;
    openOrDownloadData(element: HTMLElement, data: Uint8Array, filename: string): void;
}

interface IPDFLinkService {
    getDestinationHash(dest: any): string;
    getAnchorUrl(hash: string): string;
    setHash(hash: string): void;
    executeNamedAction(action: string): void;
    cachePageRef(pageNum: number, pageRef: any): void;
    isPageVisible(pageNumber: number): boolean;
    page: number;
    pagesCount: number;
    goToDestination(dest: any): Promise<void>;
    navigateTo(dest: any): void;
}

interface AnnotationData {
    subtype: string;
    annotationType: number;
    rect: number[];
    transform?: number[];
    color?: number[];
    title?: string;
    creationDate?: string;
    hasPopupResponse?: boolean;
    parentRect?: number[];
    borderStyle?: {
        width: number;
        style: number;
        dashArray?: number[];
        horizontalCornerRadius?: number;
        verticalCornerRadius?: number;
    };
    id: string;
    [key: string]: any;
}

interface AnnotationLayerParameters {
    pageDiv: HTMLDivElement;
    pdfPage: PDFPageProxy;
    viewport: PageViewport;
    linkService: IPDFLinkService;
    downloadManager: IDownloadManager;
    imageResourcesPath?: string;
    renderForms?: boolean;
    annotationStorage?: AnnotationStorage;
    enableScripting?: boolean;
    hasJSActions?: Promise<boolean>;
    fieldObjects?: any; // Promise<{[key: string]: Object[]}> | null
    annotationCanvasMap?: Map<string, HTMLCanvasElement>;
    accessibilityManager?: any;
    annotationEditorUIManager?: any;
    structTreeLayer?: any;
}

/**
 * @abstract
 */
class AnnotationElement {
    data: AnnotationData;
    layer: HTMLDivElement;
    linkService: IPDFLinkService;
    downloadManager: IDownloadManager;
    imageResourcesPath: string;
    renderForms: boolean;
    svgFactory: DOMSVGFactory;
    annotationStorage: AnnotationStorage | null;
    enableScripting: boolean;
    hasJSActions: Promise<boolean> | null;
    fieldObjects: any;
    parent: AnnotationElement | null;
    container: HTMLElement | null;
    popup: AnnotationElement | null;
    
    protected _isExtension: boolean;

    static _hasPopupMesh(data: AnnotationData, storage: AnnotationStorage | null) {
        // TODO: check if popup mesh exists
        return false;
    }

    constructor(parameters: any, isRenderable: boolean = false, ignoreBorder: boolean = false) {
        this._isExtension = false;
        this.data = parameters.data;
        this.layer = parameters.layer;
        this.linkService = parameters.linkService;
        this.downloadManager = parameters.downloadManager;
        this.imageResourcesPath = parameters.imageResourcesPath || "";
        this.renderForms = parameters.renderForms || false;
        this.svgFactory = parameters.svgFactory || new DOMSVGFactory();
        this.annotationStorage = parameters.annotationStorage || null;
        this.enableScripting = parameters.enableScripting || false;
        this.hasJSActions = parameters.hasJSActions || null;
        this.fieldObjects = parameters.fieldObjects || null;
        this.parent = parameters.parent || null;
        this.container = null;
        this.popup = null;

        if (isRenderable) {
            this.container = this._createContainer(ignoreBorder);
        }
    }

    get _date() {
        return PDFDateString.toDateObject(this.data.creationDate || "");
    }

    _createContainer(ignoreBorder: boolean = false): HTMLElement {
        const data = this.data;
        const page = this.layer; // pageDiv
        const container = document.createElement("section");
        
        container.setAttribute("data-annotation-id", data.id);
        if (data.annotationType) {
             container.setAttribute("data-annotation-type", Util.getAnnotationTypeStr(data.annotationType)); // Need to impl getAnnotationTypeStr if not present
        }

        const width = data.rect[2] - data.rect[0];
        const height = data.rect[3] - data.rect[1];

        container.style.width = `${width}px`;
        container.style.height = `${height}px`;
        
        // Positioning handled by CSS transform usually, but here we might need to set top/left
        // The original code relies on the viewport transform being applied to the layer or calculating positions.
        // Assuming the layer has the page dimensions and these coords are relative to it.
        // Wait, pdf.js sets specific transforms.
        
        return container;
    }

    render() {
        if (this.container && this.layer) {
             this.layer.appendChild(this.container);
        }
    }

    show() {
        if (this.container) {
            this.container.hidden = false;
        }
        if (this.popup) {
            this.popup.show();
        }
    }

    hide() {
        if (this.container) {
            this.container.hidden = true;
        }
        if (this.popup) {
            this.popup.hide();
        }
    }

    hasPopup() {
        return !!this.data.hasPopupResponse;
    }
}

class LinkAnnotationElement extends AnnotationElement {
    constructor(parameters: any) {
        super(parameters, true, true); // isRenderable, ignoreBorder
    }

    render() {
        if (!this.container) return;
        
        this.container.className = "linkAnnotation";
        
        const { url, dest, newWindow } = this.data;
        const link = document.createElement("a");

        if (url) {
            Util.addLinkAttributes(link, {
                url,
                target: newWindow ? LinkTarget.BLANK : LinkTarget.NONE,
            });
        } else if (dest) {
            // Internal link
             Util.addLinkAttributes(link, {
                url: this.linkService.getDestinationHash(dest),
                target: LinkTarget.NONE,
            });
        }

        this.container.appendChild(link);
        super.render();
    }
}

export class AnnotationLayer {
    pageDiv: HTMLDivElement;
    pdfPage: PDFPageProxy;
    viewport: PageViewport;
    linkService: IPDFLinkService;
    downloadManager: IDownloadManager;
    imageResourcesPath: string;
    renderForms: boolean;
    annotationStorage: AnnotationStorage | null;
    enableScripting: boolean;
    hasJSActions: Promise<boolean> | null;
    fieldObjects: any;
    annotationCanvasMap: Map<string, HTMLCanvasElement> | null;
    accessibilityManager: any;
    annotationEditorUIManager: any;
    structTreeLayer: any;
    div: HTMLDivElement | null = null;

    constructor(parameters: AnnotationLayerParameters) {
        this.pageDiv = parameters.pageDiv;
        this.pdfPage = parameters.pdfPage;
        this.viewport = parameters.viewport;
        this.linkService = parameters.linkService;
        this.downloadManager = parameters.downloadManager;
        this.imageResourcesPath = parameters.imageResourcesPath || "";
        this.renderForms = parameters.renderForms || false;
        this.annotationStorage = parameters.annotationStorage || null;
        this.enableScripting = parameters.enableScripting || false;
        this.hasJSActions = parameters.hasJSActions || null;
        this.fieldObjects = parameters.fieldObjects || null;
        this.annotationCanvasMap = parameters.annotationCanvasMap || null;
        this.accessibilityManager = parameters.accessibilityManager || null;
        this.annotationEditorUIManager = parameters.annotationEditorUIManager || null;
        this.structTreeLayer = parameters.structTreeLayer || null;
    }

    async render(parameters: any) {
        const annotations = parameters.annotations || await this.pdfPage.getAnnotations();
        if (annotations.length === 0) {
            return;
        }

        const div = document.createElement("div");
        div.className = "annotationLayer";
        this.div = div;
        this.pageDiv.appendChild(div);

        // Set dimensions
        setLayerDimensions(div, this.viewport);

        // Process annotations
        for (const data of annotations) {
             if (!data) continue;
             
             // Factory logic
             let element: AnnotationElement | null = null;
             const commonParams = {
                 data,
                 layer: div,
                 linkService: this.linkService,
                 downloadManager: this.downloadManager,
                 imageResourcesPath: this.imageResourcesPath,
                 renderForms: this.renderForms,
                 annotationStorage: this.annotationStorage,
                 enableScripting: this.enableScripting,
                 hasJSActions: this.hasJSActions,
                 fieldObjects: this.fieldObjects,
             };

             if (data.subtype === "Link") {
                 element = new LinkAnnotationElement(commonParams);
             } else {
                 // Fallback for now
                 element = new AnnotationElement(commonParams, false);
             }

             if (element) {
                 element.render();
             }
        }
    }
}

// Temporary internal enum for LinkTarget until we find where it is or define it
const LinkTarget = {
    NONE: 0,
    SELF: 1,
    BLANK: 2,
    PARENT: 3,
    TOP: 4,
};

// Add helper to Util if missing, or use local
// Ideally this should be in src/shared/util.ts
// But for now, I'm patching logic here
