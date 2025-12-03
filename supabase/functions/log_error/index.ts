import { serve } from "https://deno.land/std@0.181.0/http/server.ts";
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

const mySupabaseUrl = Deno.env.get("SUPABASE_URL")!;
const mySupabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

//Verifying my keys:
//console.log("SUPABASE_URL: ", mySupabaseUrl);
//console.log("SUPABASE_SERVICE_ROLE_KEY: ", mySupabaseKey);

if(!mySupabaseKey){
    console.error("SUPABASE_SERVICE_ROLE_KEY is not set");
    throw new Error("SUPABASE_SERVICE_ROLE_KEY is not set");
}

const supabase = createClient(mySupabaseUrl, mySupabaseKey);

serve(async (req: Request) => {
    try{
        if(req.method === "OPTIONS"){
            return new Response(null, {
                status: 204,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "POST, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type, Accept, Authorization, Origin",
                },
            });
        }

        const body = await req.json();
        const { message, stacktrace, user_id, device_info } = body;

        console.log("Received body: ", body);

        const { data, error } = await supabase.from("star_expedition_errors").insert([
            {
                message,
                stacktrace,
                user_id,
                device_info,
            }
        ]);

        if(error){
            console.error("There is an inserting-related error: ", error);
            return new Response(JSON.stringify({ status: "error", details: error.message }), {
                status: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Content-Type": "application/json"
                },
            });
        }
        else{
            console.log("The insert was successful");
        }

        return new Response(JSON.stringify({ status: "ok" }), {
            status: 200,
            headers: {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json"
            },
        });
    }
    catch(myError){
        console.error(myError);
        return new Response(JSON.stringify({ status: "error" }), {
            status: 500,
            headers: {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json"
            },
        });
    }
});