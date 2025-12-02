export const IDENTITY_MATRIX = [1, 0, 0, 1, 0, 0];

export class Util {
    static IDENTITY_MATRIX = IDENTITY_MATRIX;

    static transform(m1: number[], m2: number[]): number[] {
        return [
            m1[0] * m2[0] + m1[2] * m2[1],
            m1[1] * m2[0] + m1[3] * m2[1],
            m1[0] * m2[2] + m1[2] * m2[3],
            m1[1] * m2[2] + m1[3] * m2[3],
            m1[0] * m2[4] + m1[2] * m2[5] + m1[4],
            m1[1] * m2[4] + m1[3] * m2[5] + m1[5],
        ];
    }

    static applyTransform(p: number[], m: number[]) {
        const x = p[0];
        const y = p[1];
        p[0] = x * m[0] + y * m[2] + m[4];
        p[1] = x * m[1] + y * m[3] + m[5];
    }
}

