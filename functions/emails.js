import * as functions from "firebase-functions";
import fetch from "node-fetch";
import dotenv from "dotenv";

//Loading variables from .env:
dotenv.config();

export const sendAnEmail = functions.https.onCall(async (myData, myContext) => {
    const { to, subject, html } = myData;

    const myKey = process.env.RESEND_KEY;

    const myResponse = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
            "Authorization": `Bearer: ${myKey}`,
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
          from: "no-reply@starexpedition.net",
          to: to,
          subject: subject,
          html: html
        })

        return await myResponse.json();
    });
});