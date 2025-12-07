import { test, expect, describe } from "bun:test";
import { CanvasGraphics } from '../src/display/canvas';
import { OperatorList } from '../src/core/operator_list';
import { OPS } from '../src/core/ops';

// Mock Canvas Context
class MockContext {
    calls: string[] = [];

    save() { this.calls.push("save"); }
    restore() { this.calls.push("restore"); }
    transform(a: number, b: number, c: number, d: number, e: number, f: number) { 
        this.calls.push(`transform(${a},${b},${c},${d},${e},${f})`); 
    }
    beginPath() { this.calls.push("beginPath"); }
    moveTo(x: number, y: number) { this.calls.push(`moveTo(${x},${y})`); }
    lineTo(x: number, y: number) { this.calls.push(`lineTo(${x},${y})`); }
    fill() { this.calls.push("fill"); }
    stroke() { this.calls.push("stroke"); }
    set fillStyle(val: string) { this.calls.push(`fillStyle=${val}`); }
    set strokeStyle(val: string) { this.calls.push(`strokeStyle=${val}`); }
    set lineWidth(val: number) { this.calls.push(`lineWidth=${val}`); }
}

describe("CanvasGraphics", () => {
    test("should execute operator list correctly", () => {
        const mockCtx = new MockContext();
        const graphics = new CanvasGraphics(mockCtx as any, {}, { get: () => null });
        const opList = new OperatorList();

        // Draw a red rectangle
        opList.addOp(OPS.setLineWidth, [2]);
        opList.addOp(OPS.setStrokeColorN, [1, 0, 0]); // Red
        opList.addOp(OPS.constructPath, [[OPS.moveTo, OPS.lineTo, OPS.lineTo, OPS.lineTo], [10, 10, 100, 10, 100, 100, 10, 100]]);
        opList.addOp(OPS.stroke, []);

        graphics.executeOperatorList(opList);

        const expected = [
            "lineWidth=2",
            "strokeStyle=rgb(255, 0, 0)",
            "beginPath",
            "moveTo(10,10)",
            "lineTo(100,10)",
            "lineTo(100,100)",
            "lineTo(10,100)",
            "stroke"
        ];

        expect(mockCtx.calls.length).toBe(expected.length);
        for(let i=0; i<expected.length; i++) {
            expect(mockCtx.calls[i]).toBe(expected[i]);
        }
    });
});

