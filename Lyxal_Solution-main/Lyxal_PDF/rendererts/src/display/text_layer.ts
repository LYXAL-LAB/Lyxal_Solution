import { Util } from '../shared/util';
import { TextContent } from '../core/evaluator';

export class TextLayerBuilder {
    textLayerDiv: HTMLElement;
    textContent: TextContent | null = null;
    viewport: any;

    constructor({ textLayerDiv, viewport }: { textLayerDiv: HTMLElement, viewport: any }) {
        this.textLayerDiv = textLayerDiv;
        this.viewport = viewport;
    }

    render(textContent: TextContent) {
        this.textContent = textContent;
        this.textLayerDiv.innerHTML = "";
        
        const items = textContent.items;
        for (let i = 0; i < items.length; i++) {
            const item = items[i];
            
            // Create span
            const el = document.createElement("span");
            el.textContent = item.str;
            
            // Style and Position
            // We need to map PDF coords to Viewport coords
            // transform: [scaleX, skewY, skewX, scaleY, transX, transY]
            // We usually use CSS transform matrix.
            
            // Simplified positioning:
            // Calculate screen coordinates
            const tx = Util.transform(item.transform, this.viewport.transform);
            
            // Font size calculation (simplified)
            const fontSize = Math.sqrt(tx[0] * tx[0] + tx[1] * tx[1]);
            
            el.style.fontSize = `${fontSize}px`;
            el.style.fontFamily = "sans-serif"; // Should map to loaded font family
            el.style.position = "absolute";
            el.style.left = `${tx[4]}px`;
            el.style.top = `${tx[5] - fontSize}px`; // PDF origin is bottom-left, CSS is top-left. Adjust Y.
            // Also need to handle flipY if not handled by viewport transform.
            // Usually viewport handles the flip.
            
            // Apply transform for rotation/skew
            // el.style.transform = `matrix(...)`;
            
            this.textLayerDiv.appendChild(el);
        }
    }
    
    // TODO: Improve with proper layout matching, transparent text for selection overlay
}

