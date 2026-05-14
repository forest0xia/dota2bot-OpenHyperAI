/**
 * In game Http request layer.
 *
 * Will be used to:
 * 1. Interact with backend services enpowered with machine learning AI. ML AI is the way out.
 * 2. Dynamically load hero builds from 3rd party sources like dotabuff in game.
 *
 * Please feel very welcome to help us utilize the existing functionality to build more challenging bots!
 */
const JSON = require("../json");

export interface RequestData {
    uuid: string;
    gameTime: number;
    requestBody: {
        [key: string]: any;
    };
}
export interface ResultData {
    [key: string]: any;
}

export type Api = "uuid" | "gamestate";

export class Request {
    static UUID: string | null = null; // game state tracking id.
    static BASE_URL: string = "http://127.0.0.1:5000/";
    // static BASE_URL: string = "https://chatgpt-with-dota2bot.onrender.com/";

    static HttpPost(postData: RequestData, api: Api, callback?: (res: string) => void) {
        if (this.UUID !== null) {
            return Request.RawPostRequest(`${Request.BASE_URL}/${api}`, callback, postData);
        } else {
            return this.GetUUID(callback);
        }
    }

    static GetUUID(callback?: (uuid: string) => void) {
        return Request.RawPostRequest(`${Request.BASE_URL}/uuid`, callback);
    }

    static RawPostRequest(url: string, callback?: (res: any) => void, postData?: RequestData) {
        const reqData = JSON.encode(postData);
        const req = CreateRemoteHTTPRequest(url);
        req.SetHTTPRequestRawPostBody("application/json", reqData);
        req.Send((result: any) => {
            print(`Raw ${url} Result: ${result}`);
            let resultData: ResultData = JSON.decode(result);
            print(`Jsonified result: ${resultData}`);
            if (callback) {
                callback(result);
            }
        });
        return req;
    }

    static RawGetRequest(url: string, callback?: (res: any) => void) {
        const req = CreateRemoteHTTPRequest(url);
        // req.SetHTTPRequestGetOrPostParameter("", "")
        req.Send((result: any) => {
            print(`Raw ${url} Result: ${result}`);
            // let resultData: ResultData = JSON.decode(result);
            // print(`Jsonified result: ${resultData}`)
            if (callback) {
                callback(result);
            }
        });
        return req;
    }
}
