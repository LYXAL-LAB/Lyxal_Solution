
import { OPS } from '../core/ops';
import { Util } from '../shared/util';
import { OperatorList } from '../core/operator_list';

export class DOMSVGFactory {
    create(width: number, height: number): SVGElement {
        const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        svg.setAttribute("version", "1.1");
        svg.setAttribute("width", width + "px");
        svg.setAttribute("height", height + "px");
        svg.setAttribute("preserveAspectRatio", "none");
        svg.setAttribute("viewBox", `0 0 ${width} ${height}`);
        return svg;
    }

    createElement(type: string): SVGElement {
        return document.createElementNS("http://www.w3.org/2000/svg", type);
    }
}

export class SVGGraphics {
    svg: SVGElement;
    current: any;
    stateStack: any[] = [];
    objs: any;
    commonObjs: any;
    private factory: DOMSVGFactory;
    
    constructor(commonObjs: any, objs: any) {
        this.commonObjs = commonObjs;
        this.objs = objs;
        this.factory = new DOMSVGFactory();
        this.svg = this.factory.create(0, 0); // Dimensions updated later
    }

    save() {
        // SVG doesn't have a simple save/restore stack like Canvas.
        // Usually managed by nested <g> groups.
    }

    restore() {
        // Close <g>
    }

    executeOperatorList(operatorList: OperatorList) {
        // ... switch on OPS ...
    }
}
