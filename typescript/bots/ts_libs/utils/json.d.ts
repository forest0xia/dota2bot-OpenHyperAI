declare interface JSON {
    encode(object: any): string;
    decode(json: string): any;
}
