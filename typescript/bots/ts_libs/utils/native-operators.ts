import { Vector } from "bots/ts_libs/dota";

type InternalScalarType = Vector;

export function sub<T extends InternalScalarType>(a: T, b: T): T {
    // @ts-ignore
    return a - b;
}

export function add<T extends InternalScalarType>(a: T, b: T): T {
    // @ts-ignore
    return a + b;
}

export function multiply(a: Vector, b: Vector | number): Vector;
export function multiply<T extends InternalScalarType>(a: T, b: T): T {
    // @ts-ignore
    return a * b;
}

export function dot(a: Vector, b: Vector): number {
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

// Method to calculate the 2D length (magnitude) of the vector
export function length2D(a: Vector): number {
    return Math.sqrt(a.x * a.x + a.y * a.y);
}

export function length3D(vec: Vector): number {
    return Math.sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z);
}
