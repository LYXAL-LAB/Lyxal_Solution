import { IDENTITY_MATRIX } from "../shared/util";
import { Font } from './fonts';

export class TextState {
    charSpacing: number = 0;
    wordSpacing: number = 0;
    hScale: number = 100;
    leading: number = 0;
    fontName: string | null = null;
    font: Font | null = null;
    fontSize: number = 0;
    renderMode: number = 0;
    rise: number = 0;
    
    clone(): TextState {
        const t = new TextState();
        t.charSpacing = this.charSpacing;
        t.wordSpacing = this.wordSpacing;
        t.hScale = this.hScale;
        t.leading = this.leading;
        t.fontName = this.fontName;
        t.font = this.font;
        t.fontSize = this.fontSize;
        t.renderMode = this.renderMode;
        t.rise = this.rise;
        return t;
    }
}

export class GraphicsState {
    ctm: number[] = IDENTITY_MATRIX.slice();
    lineWidth: number = 1;
    lineCap: number = 0;
    lineJoin: number = 0;
    miterLimit: number = 10;
    dashArray: number[] = [];
    dashPhase: number = 0;
    
    textState: TextState = new TextState();
    
    strokeColor: number[] = [0];
    fillColor: number[] = [0];
    
    strokeColorSpace: string = "DeviceGray";
    fillColorSpace: string = "DeviceGray";
    
    clone(): GraphicsState {
        const clone = new GraphicsState();
        clone.ctm = this.ctm.slice();
        clone.lineWidth = this.lineWidth;
        clone.lineCap = this.lineCap;
        clone.lineJoin = this.lineJoin;
        clone.miterLimit = this.miterLimit;
        clone.dashArray = this.dashArray.slice();
        clone.dashPhase = this.dashPhase;
        clone.textState = this.textState.clone();
        clone.strokeColor = this.strokeColor.slice();
        clone.fillColor = this.fillColor.slice();
        clone.strokeColorSpace = this.strokeColorSpace;
        clone.fillColorSpace = this.fillColorSpace;
        return clone;
    }
}
