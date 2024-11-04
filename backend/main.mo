import Nat "mo:base/Nat";

import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Text "mo:base/Text";
import Blob "mo:base/Blob";
import Nat8 "mo:base/Nat8";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";

actor {
    public func detectObjects(apiKey : Text, base64Image : Text) : async Result.Result<Text, Text> {
        let url = "https://api.anthropic.com/v1/messages";
        let body = "{\"model\":\"claude-3-5-sonnet-20241022\",\"max_tokens\":8000,\"messages\":[{\"role\":\"user\",\"content\":[{\"type\":\"image\",\"source\":{\"type\":\"base64\",\"media_type\":\"image/jpeg\",\"data\":\"" # base64Image # "\"}}]}],\"system\":\"You are an expert computer vision system. Analyze the provided image and return ONLY a JSON object containing bounding boxes. Follow these strict rules:\\n1. Output MUST be valid JSON with no additional text\\n2. Each detected object must have:\\n   - 'element': descriptive name of the object\\n   - 'bbox': [x1, y1, x2, y2] coordinates (normalized 0-1)\\n   - 'confidence': confidence score (0-1)\\n3. Use this exact format:\\n   {\\n     \\\"detections\\\": [\\n       {\\n         \\\"element\\\": \\\"object_name\\\",\\n         \\\"bbox\\\": [x1, y1, x2, y2],\\n         \\\"confidence\\\": 0.95\\n       }\\n     ]\\n   }\"}";

        let request_headers = [
            ("Content-Type", "application/json"),
            ("x-api-key", apiKey),
            ("anthropic-version", "2023-06-01")
        ];

        try {
            let ic : actor { 
                http_request : {
                    url : Text;
                    method : Text;
                    body : [Nat8];
                    headers : [(Text, Text)];
                } -> async {
                    status : Nat;
                    headers : [(Text, Text)];
                    body : [Nat8];
                };
            } = actor("aaaaa-aa");

            let response = await ic.http_request({
                url = url;
                method = "POST";
                body = Blob.toArray(Text.encodeUtf8(body));
                headers = request_headers;
            });

            if (response.status == 200) {
                let responseBody = Text.decodeUtf8(Blob.fromArray(response.body));
                switch (responseBody) {
                    case (?text) {
                        #ok(text)
                    };
                    case (null) {
                        #err("Failed to decode response body")
                    };
                };
            } else {
                #err("HTTP request failed with status: " # Nat.toText(response.status))
            };
        } catch (e) {
            #err("Error making HTTP request: " # Error.message(e))
        };
    };
}
