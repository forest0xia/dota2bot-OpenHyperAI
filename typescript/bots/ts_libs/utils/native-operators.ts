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
