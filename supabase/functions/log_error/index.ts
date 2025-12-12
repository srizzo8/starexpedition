import { serve } from "https://deno.land/std@0.181.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const myCorsHeaders = {
   "Access-Control-Allow-Origin": "*",
   "Access-Control-Allow-Methods": "POST, OPTIONS",
   "Access-Control-Allow-Headers": "*",
   "Access-Control-Max-Age": "86400",
};

//Initializing the Supabase client:
//const mySecretToken = Deno.env.get("MY_TOKEN");
//const myPublicWebToken = Deno.env.get("PUBLIC_TOKEN");

serve(async (req: Request) => {
    try{
        //Handling the preflight of OPTIONS immediately, before anything else happens (for web browser requirements):
        if(req.method === "OPTIONS"){
            console.log("There is a preflight OPTIONS request from: ", req.headers.get("Origin"));
            return new Response("ok", {
                status: 200,
                headers: myCorsHeaders,
            });
        }

        const mySupabaseUrl = Deno.env.get("MY_SUPABASE_URL");
        const mySupabaseServiceKey = Deno.env.get("MY_SUPABASE_SERVICE_KEY");

        console.log("The Supabase URL: ", mySupabaseUrl);
        console.log("The Supabase Service Key: ", mySupabaseServiceKey ? "The service key exists!" : "The service key is missing!");

        if(!mySupabaseUrl || !mySupabaseServiceKey){
            console.log("The Supabase URL or Supabase Service Key is missing");
            return new Response("The server is misconfigured", {
                status: 500,
                headers: myCorsHeaders,
            });
        }

        const supabaseClient = createClient(mySupabaseUrl, mySupabaseServiceKey, {auth: { autoRefreshToken: false, persistSession: false },});

        /*const myRequestHeaders = req.headers.get("Access-Control-Request-Headers");

        if(myRequestHeaders){
            myCors["Access-Control-Allow-Headers"] = myRequestHeaders;
        }

        console.log("All of the request headers: ");
        for(const [key, value] of req.headers.entries()){
            console.log(`${key}: ${value}`);
        }

        //API key check:
        const myClientApiKey = req.headers.get("x-api-key");

        console.log("This is myClientApiKey: ", myClientApiKey);

        if(myClientApiKey !== mySecretToken && myClientApiKey !== myPublicWebToken){
            return new Response("Unauthorized", { status: 401, headers: myCorsHeaders, });
        }*/

        //Reading JSON:
        //Reading raw text:
        let body = await req.json();
        console.log("Raw JSON: ", body);

        if(!body || Object.keys(body).length === 0){
            console.error("An empty JSON body has been received");
            return new Response("JSON is invalid", {
                status: 400,
                headers: myCorsHeaders,
            });
        }

        //Normalizing fields to ensure that fields are not undefined:
        const safe = (v: any) => (v === undefined ? null : v);

        /*let myData;

        try{
            myData = body;
        }
        catch(myJsonError){
            console.error("You received a JSON parsing error: ", myJsonError);
            return new Response("JSON is malformed", {
                status: 400,
                headers: myCorsHeaders,
            });
        }*/

        const myData = {
            message: safe(body.message),
            stacktrace: safe(body.stacktrace),
            device_info: safe(body.device_info),
            file_name: safe(body.file_name),
            line: safe(body.line),
            column_number: safe(body.column_number),
            extra: safe(body.extra),
            username: safe(body.username),
        };

        //Handling for web JS-related errors:
        if(body.extra && typeof body.extra === "object"){
            if(body.extra.source && !myData.file_name){
                myData.file_name = body.extra.source;
            }
            if(body.extra.line && !myData.line){
                myData.line = body.extra.line;
            }
            if(body.extra.column && !myData.column_number){
                myData.column_number = body.extra.column;
            }
        }

        console.log("This is being inserted to the star_expedition_errors database: ", JSON.stringify(myData, null, 2));

        //Inserting the error to the star_expedition_errors database:
        const { error } = await supabaseClient.from("star_expedition_errors").insert({
            ...myData,
            detected_at: new Date().toISOString(),
        });

        //Inserting the error to the star_expedition_errors database:
        /*const { error } = await supabaseClient.from("star_expedition_errors").insert({
            message: myData.message,
            stacktrace: myData.stacktrace,
            device_info: myData.device_info,
            file_name: myData.file_name,
            line: myData.line,
            column_number: myData.column_number,
            extra: myData.extra,
            username: myData.username,
            detected_at: new Date().toISOString(),
        });*/

        if(error){
            console.error("The insert has failed: ", error);
            return new Response("The database insert has failed", {
                status: 500,
                headers: myCorsHeaders,
            });
        }

        //console.log("The error was successfully logged: ", JSON.stringify(myData, null, 2));
        return new Response("The error was successfully logged", {
            status: 200,
            headers: myCorsHeaders,
        });
    }
    catch(myErr){
        console.error("There is an unexpected insertion error: ", myErr);
        return new Response("Insertion error found", {
            status: 500,
            headers: myCorsHeaders,
        });
    }
});