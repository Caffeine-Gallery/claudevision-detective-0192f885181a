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
    // Simple JSON parsing function (for demonstration purposes)
    private func parseJSON(text : Text) : Result.Result<Text, Text> {
        if (Text.startsWith(text, #text "{") and Text.endsWith(text, #text "}")) {
            #ok(text)
        } else {
            #err("Invalid JSON format")
        }
    };

    // Simple JSON stringification function (for demonstration purposes)
    private func stringifyJSON(text : Text) : Text {
        text // In this case, we're just returning the text as-is
    };

    public func detectObjects(apiKey : Text, base64Image : Text) : async Result.Result<Text, Text> {
        let url = "https://api.anthropic.com/v1/messages";
        let body = "{\"model\":\"claude-3-5-sonnet-20241022\",\"max_tokens\":8000,\"messages\":[{\"role\":\"user\",\"content\":[{\"type\":\"image\",\"source\":{\"type\":\"base64\",\"media_type\":\"image/jpeg\",\"data\":\"" # base64Image # "\"}}]}],\"system\":\"You are an expert computer vision system. Analyze the provided image and return ONLY a JSON object containing bounding boxes. Follow these strict rules:\\n1. Output MUST be valid JSON with no additional text\\n2. Each detected object must have:\\n   - 'element': descriptive name of the object\\n   - 'bbox': [x1, y1, x2, y2] coordinates (normalized 0-1)\\n   - 'confidence': confidence score (0-1)\\n3. Use this exact format:\\n   {\\n     \\\"detections\\\": [\\n       {\\n         \\\"element\\\": \\\"object_name\\\",\\n         \\\"bbox\\\": [x1, y1, x2, y2],\\n         \\\"confidence\\\": 0.95\\n       }\\n     ]\\n   }\"}";

        let request_headers = [
            ("Content-Type", "application/json"),
            ("x-api-key", apiKey),
            ("anthropic-version", "2023-06-01")
        ];

        try {
            let ic : actor { call_raw : (Text, Text, Blob) -> async Blob } = actor("aaaaa-aa");
            let response = await ic.call_raw(
                "https://ic0.app",
                "http_request",
                to_candid({
                    url = url;
                    max_response_bytes = null;
                    headers = request_headers;
                    body = ?Text.encodeUtf8(body);
                    method = "POST";
                    transform = null;
                })
            );

            let decoded = from_candid(response) : ?{ body : ?Blob };
            switch (decoded) {
                case (?{ body = ?responseBody }) {
                    let decodedText = Text.decodeUtf8(responseBody);
                    switch (decodedText) {
                        case (?text) {
                            // Parse the response as JSON and then stringify it again to ensure valid JSON
                            switch (parseJSON(text)) {
                                case (#ok(parsed)) {
                                    #ok(stringifyJSON(parsed))
                                };
                                case (#err(e)) {
                                    #err("Failed to parse response as JSON: " # e)
                                };
                            };
                        };
                        case (null) {
                            #err("Failed to decode response body")
                        };
                    };
                };
                case (_) {
                    #err("Invalid response format")
                };
            };
        } catch (e) {
            #err("Error making HTTP request: " # Error.message(e))
        };
    };
}
