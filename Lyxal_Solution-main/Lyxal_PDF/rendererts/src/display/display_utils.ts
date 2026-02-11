
import { Util } from '../shared/util';

export class DOMCanvasFactory {
    create(width: number, height: number): { canvas: HTMLCanvasElement, context: CanvasRenderingContext2D } {
        if (width <= 0 || height <= 0) {
            throw new Error("Invalid canvas size");
        }
        const canvas = document.createElement("canvas");
        const context = canvas.getContext("2d");
        if (!context) {
            throw new Error("Could not create canvas context");
        }
        canvas.width = width;
        canvas.height = height;
        return { canvas, context };
    }

    createOffscreen(width: number, height: number): { canvas: HTMLCanvasElement | OffscreenCanvas, context: CanvasRenderingContext2D | OffscreenCanvasRenderingContext2D } {
        // Use OffscreenCanvas if available
        if (typeof OffscreenCanvas !== "undefined") {
             const canvas = new OffscreenCanvas(width, height);
             const context = canvas.getContext("2d");
             if (!context) throw new Error("Could not create offscreen context");
             return { canvas, context: context as OffscreenCanvasRenderingContext2D }; 
        }
        return this.create(width, height);
    }

    destroy(canvas: HTMLCanvasElement) {
        canvas.width = 0;
        canvas.height = 0;
    }
}

export class PixelsPerInch {
    static get PDF() { return 72; }
    static get CSS() { return 96; }
}

export function getOutputScale(ctx: CanvasRenderingContext2D | any) {
    const devicePixelRatio = window.devicePixelRatio || 1;
    const backingStoreRatio = ctx.webkitBackingStorePixelRatio ||
                              ctx.mozBackingStorePixelRatio ||
                              ctx.msBackingStorePixelRatio ||
                              ctx.oBackingStorePixelRatio ||
                              ctx.backingStorePixelRatio || 1;
    const pixelRatio = devicePixelRatio / backingStoreRatio;
    return {
        sx: pixelRatio,
        sy: pixelRatio,
        scaled: pixelRatio !== 1
    };
}

export function loadJpegStream(id: string, imageData: Uint8Array, objs: any) {
    const blob = new Blob([imageData as BlobPart], { type: "image/jpeg" });
    const url = URL.createObjectURL(blob);
    const img = new Image();
    img.src = url;
    
    return new Promise((resolve, reject) => {
        img.onload = () => {
            URL.revokeObjectURL(url);
            resolve(img);
        };
        img.onerror = () => {
            URL.revokeObjectURL(url);
            reject(new Error("Image load failed"));
        };
    });
}

export class PDFDateString {
  static toDateObject(input: string): Date | null {
    if (!input || typeof input !== "string") {
      return null;
    }

    // Optional prefix "D:"
    if (input.substring(0, 2) === "D:") {
      input = input.substring(2);
    }

    // YYYYMMDDHHmmSSOHH'mm'
    const year = parseInt(input.substring(0, 4), 10);
    let month = parseInt(input.substring(4, 6), 10) - 1;
    let day = parseInt(input.substring(6, 8), 10);
    let hours = parseInt(input.substring(8, 10), 10);
    let minutes = parseInt(input.substring(10, 12), 10);
    let seconds = parseInt(input.substring(12, 14), 10);
    let utRel = input.substring(14, 15);
    let offsetHours = parseInt(input.substring(15, 17), 10);
    let offsetMinutes = parseInt(input.substring(18, 20), 10);

    if (isNaN(year)) return null;
    if (isNaN(month)) month = 0;
    if (isNaN(day)) day = 1;
    if (isNaN(hours)) hours = 0;
    if (isNaN(minutes)) minutes = 0;
    if (isNaN(seconds)) seconds = 0;
    if (isNaN(offsetHours)) offsetHours = 0;
    if (isNaN(offsetMinutes)) offsetMinutes = 0;

    const date = new Date(Date.UTC(year, month, day, hours, minutes, seconds));

    if (utRel === "-" || utRel === "+" || utRel === "Z") {
        const offset = (offsetHours * 60 + offsetMinutes) * 60000;
        if (utRel === "-") {
            date.setTime(date.getTime() + offset);
        } else if (utRel === "+") {
            date.setTime(date.getTime() - offset);
        }
    }

    return date;
  }
}

export function setLayerDimensions(div: HTMLDivElement, viewport: any, mustFlip = false, mustRotate = true) {
    div.style.width = Math.floor(viewport.width) + "px";
    div.style.height = Math.floor(viewport.height) + "px";
    div.style.position = "absolute";
    
    // Position 0,0 relative to container
    // If viewport has transform, we might need CSS transform here
    // But usually layer divs are just sized to the page
}

// TODO: Implement full rich text rendering
export function renderRichText(content: any): HTMLElement | null {
    if (!content) return null;
    const div = document.createElement("div");
    div.textContent = typeof content === 'string' ? content : (content.str || "");
    return div;
}

export const OutputScale = {
    get pixelRatio() {
        return window.devicePixelRatio || 1;
    }
}
