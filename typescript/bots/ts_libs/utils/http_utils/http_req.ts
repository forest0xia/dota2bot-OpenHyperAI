/**
 * In game Http request layer. 
 * 
 * Will be used to:
 * 1. Interact with backend services enpowered with machine learning AI. ML AI is the way out.
 * 2. Dynamically load hero builds from 3rd party sources like dotabuff in game.
 * 
 * Please feel very welcome to help us utilize the existing functionality to build more challenging bots!
 */
export interface RequestData {
    uuid: string;
    gameTime: number;
    requestBody: {
        [key: string]: any;
    }
}
export interface ResultData {
    [key: string]: any;
}

export type Api = "uuid" | "gamestate";

export class Request {
    static UUID: string | null = null; // game state tracking id.
    static BASE_URL: string = "https://OHA.com";

    static HttpPost(
        postData: RequestData,
        api: Api, 
        callback?: (res: string) => void)
    {
        if (this.UUID !== null) {
            return RawPostBodyRequest(`${Request.BASE_URL}/${api}`, callback, postData)
        } else {
            return this.GetUUID(callback);
        }
    }

    static GetUUID(callback?: (uuid: string) => void) {
        return RawPostBodyRequest(`${Request.BASE_URL}/uuid`, callback)
    }

}

function RawPostBodyRequest(
    url: string, 
    callback?: (res: any) => void,
    postData?: RequestData)
{
    const reqData = JSON.stringify(postData)
    const req = CreateRemoteHTTPRequest(url);
    req.SetHTTPRequestRawPostBody("application/json", reqData);
    req.Send((result: ResultData) => {
        print(`Raw ${url} Result: ${result}`)
        if (callback) {
            callback(result);
        }
    });
    return req;
}
