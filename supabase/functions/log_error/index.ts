import { serve } from "https://deno.land/std@0.181.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { decode } from "https://deno.land/std@0.181.0/encoding/base64.ts";
import { SourceMapConsumer } from "npm:source-map@0.7.4";

//Using VLQ decode and mappings from the source map:
import { decode as myVlqDecode } from "https://esm.sh/vlq@1.0.1";

type DartLocation = {
    file_name: string | null;
    line: string | null;
    column: string | null;
}

//This caches parsed sourcemaps per JS file:
const mySourceMapCache = new Map<string, any>();

function myParseMappings(mappings: string){
    const myLines = mappings.split(";");
    let myGeneratedLine = 1;

    const parsed: any[] = [];
    let thePrevious = [0, 0, 0, 0, 0];

    for(const myLine of myLines){
        let myGeneratedColumn = 0;
        const mySegments: any[] = [];

        if(myLine.length > 0){
            const myParts = myLine.split(",");
            for(const myPart of myParts){
                const decoded = myVlqDecode(myPart);

                const seg = [];

                for(let i = 0; i < decoded.length; i++){
                    seg[i] = thePrevious[i] + decoded[i];
                    thePrevious[i] = seg[i];
                }

                myGeneratedColumn = seg[0];

                mySegments.push({ myGeneratedColumn, sourceIndex: seg[1], sourceLine: seg[2], sourceColumn: seg[3] });
            }
        }
        parsed.push({ myGeneratedLine, mySegments });
        myGeneratedLine++;
    }
    return parsed;
}

function mapSingleFrame(jsLine: number, jsColumn: number, sourceMap: any): { file_name: string | null, line: number | null, column: number | null }{
    const myLineEntry = sourceMap.parsedMappings[jsLine - 1];

    if(!myLineEntry || !myLineEntry.mySegments || myLineEntry.mySegments.length === 0){
        return { file_name: null, line: null, column: null };
    }

    let chosen = myLineEntry.mySegments[0];

    for(const mySegment of myLineEntry.mySegments){
        if(mySegment.myGeneratedColumn <= jsColumn){
            chosen = mySegment;
        }
        else{
            break;
        }
    }

    if(chosen.sourceIndex == null || chosen.sourceIndex < 0 || chosen.sourceIndex >= sourceMap.sources.length){
        return { file_name: null, line: null, column: null };
    }

    return { file_name: sourceMap.sources[chosen.sourceIndex], line: chosen.sourceLine + 1, column: chosen.sourceColumn + 1 };
}

async function getSourceMap(mapName: string, supabaseClient: any): Promise<any | null>{
    if(mySourceMapCache.has(mapName)){
        return mySourceMapCache.get(mapName);
    }

    try{
        const { data, error } = await supabaseClient.storage.from("sourcemaps").download(mapName);

        if(!data || error){
            console.log("The sourcemap is not found: ", mapName);
            mySourceMapCache.set(mapName, null);
            return null;
        }

        const myMapText = await data.text();
        const mySourceMap = JSON.parse(myMapText);

        //Parsing VLQ mappings:
        mySourceMap.parsedMappings = myParseMappings(mySourceMap.mappings);

        mySourceMapCache.set(mapName, mySourceMap);

        return mySourceMap;
    }
    catch(myError){
        console.error(`You have failed to load the sourcemap ${mapName}. This is the error: `, myError);
        mySourceMapCache.set(mapName, null);
        return null;
    }
}

async function mapJsToDart(myStacktrace: string, supabaseClient: any): Promise<{ file_name: string | null; line: number | null; column: number | null }>{
    //Matches:
    const myJsFrameRegex = /([^\s]+\.js):(\d+):(\d+)/g;
    const myFrames = [...myStacktrace.matchAll(myJsFrameRegex)];

    for(const myFrame of myFrames){
        const myJsUrl = myFrame[1];
        const myJsLine = Number(myFrame[2]);
        const myJsColumn = Number(myFrame[3]);

        if(!Number.isFinite(myJsLine) || !Number.isFinite(myJsColumn)){
            continue;
        }

        const myJsFile = myJsUrl.split("/").pop();

        if(!myJsFile){
            continue;
        }

        const myMapName = `${myJsFile}.map`;

        const mySourceMap = await getSourceMap(myMapName, supabaseClient);

        if(!mySourceMap){
            continue;
        }

        const mapped = mapSingleFrame(myJsLine, myJsColumn, mySourceMap);

        console.log("Resolved frame: ", {myJsFile, myJsLine, myJsColumn, mapped});

        //Accepting only real Dart files in the app:
        if(mapped.file_name && !mapped.file_name.includes("dart_sdk") && !mapped.file_name.includes("flutter")){
            return { file_name: mapped.file_name, line: mapped.line, column: mapped.column, };
        }
    }

        /*const { data, error } = await supabaseClient.storage.from("sourcemaps").download(myMapName);

        //console.log("The sourcemap fetch: ", { hasData: !!data, error, size: data ? (await data.arrayBuffer()).byteLength : null, });
        console.log("The sourcemap fetch: ", { myMapName, hasData: !!data, error, });

        if(!data){
            continue;
        }

        //const mapText = await data.text();
        const mySourceMap = JSON.parse(await data.text());

        if(!mySourceMap.mappings || !mySourceMap.sources){
            console.log("This is an invalid sourcemap format: ", myMapName);
            continue;
        }

        mySourceMap.parsedMappings = myParseMappings(mySourceMap.mappings);

        //const mapped = mapSingleFrame(myJsLine, myJsColumn, mySourceMap)

        //console.log("The resolved Dart file: ", mapped.file_name);

        const mapped = mapSingleFrame(myJsLine, myJsColumn, mySourceMap);

        console.log("The mapped variable: ", mapped);

        if(mapped.file_name && mapped.line != null && mapped.column != null && !mapped.file_name.includes("dart_sdk")){
            //return { file_name: mapped.file_name, line: String(mapped.line), column: String(mapped.column), };
            file_name = mapped.file_name;
            line = String(mapped.line);
            column = String(mapped.column);
        }

        if(!myData.file_name && myData.stacktrace?.includes(".dart.lib.js")){
            const mapped = await mapJsToDart(myData.stacktrace, supabaseClient);

            if(mapped.file_name){
                myData.file_name = mapped.file_name;
                myData.line = mapped.line;
                myData.column_number = mapped.column;
            }
            else{
                myData.file_name = "js_runtime";
            }
        }

        //console.log("This is the mapped source: ", mapped);

        //return { file_name: `js: ${myJsFile}`, line: String(myJsLine), column: String(myJsColumn), };

        //console.log("Looking at myMapPath: ", myMapPath);
    //}

    //If nothing matches:
    //return { file_name: null, line: null, column: null };


    //Handling Dart-native traces:
    /*const myDartMatch = myStacktrace.match(/(packages\/.+\.dart)\s+(\d+):(\d+)/);

    if(myDartMatch){
        return { file_name: myDartMatch[1], line: myDartMatch[2], column: myDartMatch[3], };
    }

    //Extracting the JS location:
    const myJsMatch = myStacktrace.match(/([a-zA-Z0-9_\-\.]+\.dart\.lib\.js):(\d+):(\d+)/);

    if(!myJsMatch){
        return { file_name: null, line: null, column: null };
    }

    const [ ,myJsFile, myLineStr, myColumnStr] = myJsMatch;
    const myJsLine = Number(myLineStr);
    const myJsColumn = Number(myColumnStr);

    const myMapName = `${myJsFile}.map`;

    //Fetching the sourcemap from Supabase:
    const { data, error } = await supabaseClient.storage.from("sourcemaps").download(myMapName);

    if(!data || error){
        console.log("The sourcemap fetch has failed: ", myMapName, error);
        return { file_name: null, line: null, column: null };
    }

    const myRawMap = JSON.parse(await data.text());

    if(!rawMap || !Array.isArray(myRawMap.sources) || myRawMap.sources.length === 0){
        return { file_name: null, line: null, column: null };
    }

    //Mapping JS to Dart:
    const mySourceMapConsumer = await new SourceMapConsumer(myRawMap);

    try{
        const myPosition = mySourceMapConsumer.originalPositionFor({
            line: myJsLine,
            column: myJsColumn,
        });

        if(!myPosition || !myPosition.source){
            return { file_name: null, line: null, column: null };
        }

        return { file_name: myPosition.source, line: myPosition.line?.toString() ?? null, column: myPosition.column?.toString() ?? null, };
    }
    finally{
        mySourceMapConsumer.destroy();
    }*/


    /*for(const myFrame of myFrames){
        const myJsFile = myFrame[1];
        const myJsLine = Number(myFrame[2]);
        const myJsColumn = Number(myFrame[3]);

        const myFileName = myJsFile.split("/").pop();

        if(!myFileName){
            continue;
        }

        const myMapName = `${myFileName}.map`;

        const { data, error } = await supabaseClient.storage.from("sourcemaps").download(myMapName);

        //console.log("The sourcemap fetch: ", { hasData: !!data, error, size: data ? (await data.arrayBuffer()).byteLength : null, });
        console.log("The sourcemap fetch: ", { myMapName, hasData: !!data, error, });

        if(!data){
            continue;
        }

        //const mapText = await data.text();
        const mySourceMap = JSON.parse(await data.text());

        if(!mySourceMap.mappings || !mySourceMap.sources){
            console.log("This is an invalid sourcemap format: ", myMapName);
            continue;
        }

        mySourceMap.parsedMappings = myParseMappings(mySourceMap.mappings);

        //const mapped = mapSingleFrame(myJsLine, myJsColumn, mySourceMap)

        //console.log("The resolved Dart file: ", mapped.file_name);

        const mapped = mapSingleFrame(myJsLine, myJsColumn, mySourceMap);

        console.log("The mapped variable: ", mapped);

        if(mapped.file_name && mapped.line != null && mapped.column != null && !mapped.file_name.includes("dart_sdk")){
            //return { file_name: mapped.file_name, line: String(mapped.line), column: String(mapped.column), };
            file_name = mapped.file_name;
            line = String(mapped.line);
            column = String(mapped.column);
        }

        /*if(!myData.file_name && myData.stacktrace?.includes(".dart.lib.js")){
            const mapped = await mapJsToDart(myData.stacktrace, supabaseClient);

            if(mapped.file_name){
                myData.file_name = mapped.file_name;
                myData.line = mapped.line;
                myData.column_number = mapped.column;
            }
            else{
                myData.file_name = "js_runtime";
            }
        }*/

        //console.log("This is the mapped source: ", mapped);

        //return { file_name: `js: ${myJsFile}`, line: String(myJsLine), column: String(myJsColumn), };

        //console.log("Looking at myMapPath: ", myMapPath);
    //}
    //If nothing matches:
    return { file_name: null, line: null, column: null };
}

function parseMyDartStack(stack: string): {
    file_name: string | null;
    line: string | null;
    column: string | null;
} | null{
    const myLines = stack.split("\n");

    for(const myLine of myLines){
        const myMatch = /^\s*(packages\/starexpedition4\/[^\s]+\.dart)\s+(\d+):(\d+)/.exec(myLine);

        if(myMatch){
            return { file_name: myMatch[1], line: myMatch[2], column: myMatch[3] };
        }
    }

    return null;
}

//Server:
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

        const supabaseClient = createClient(mySupabaseUrl!, mySupabaseServiceKey!, {auth: { autoRefreshToken: false, persistSession: false },});

        //Reading JSON:
        //Reading raw text:
        let body = await req.json();
        console.log("Raw JSON: ", body);

        //Normalizing fields to ensure that fields are not undefined:
        const safe = (v: any) => (v === undefined ? null : v);

        const myData = {
            message: safe(body.message),
            stacktrace: safe(body.stacktrace),
            device_info: safe(body.device_info),
            file_name: safe(body.file_name),
            line: safe(body.line),
            column_number: safe(body.column_number),
            extra: safe(body.extra),
            username: safe(body.username) ?? "null",
        };

        //Trying Dart stack first:
        if(typeof myData.stacktrace === "string"){
            const dartParsed = parseMyDartStack(myData.stacktrace);

            console.log("This is dartParsed: ", dartParsed);

            if(dartParsed){
                myData.file_name = dartParsed.file_name;
                myData.line = dartParsed.line;
                myData.column_number = dartParsed.column;
            }
        }
        //Falling back to JS to Dart source maps:
        if(!myData.file_name && typeof myData.stacktrace === "string" && myData.stacktrace.includes(".dart.lib.js")){
            try{
                const mapped = await mapJsToDart(myData.stacktrace, supabaseClient);

                console.log("The mapped source: ", mapped);

                if(mapped.file_name){
                    myData.file_name = mapped.file_name;
                    myData.line = mapped.line;
                    myData.column_number = mapped.column;
                }
            }
            catch(myError){
                console.error("Unfortunately, the source map mapping has failed: ", myError);
            }
        }

        //Looking at the final insert payload:
        console.log("Final insert payload: ", JSON.stringify({ ...myData, detected_at: new Date().toISOString(), }, null, 2));

        //Inserting the error to the star_expedition_errors database:
        const { error } = await supabaseClient.from("star_expedition_errors").insert({
            ...myData,
            detected_at: new Date().toISOString(),
        });

        if(error){
            console.error("The insert has failed: ", error);
            return new Response("The database insert has failed", {
                status: 500,
                headers: myCorsHeaders,
            });
        }

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