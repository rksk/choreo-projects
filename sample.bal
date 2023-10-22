import ballerina/http;
import ballerina/jwt;

type SubscriptionResponse record {
    boolean isValidCustomer;
    string[] projectKeys;
};

service / on new http:Listener(8090) {
    resource function get .(http:Headers headers) returns string[]|http:BadRequest|error {
        string|error jwtAssertion = headers.getHeader("x-jwt-assertion");
        if (jwtAssertion is error) {
            http:BadRequest badRequest = {
                body: {
                    "error": "Bad Request",
                    "error_description": "Error while getting the JWT token"
                }
            };
            return badRequest;
        }

        [jwt:Header, jwt:Payload] [_, payload] = check jwt:decode(jwtAssertion);
        string email = "";
        if (payload["email"] != null) {
            email = payload["email"].toString();
        } else {
            http:BadRequest badRequest = {
                body: {
                    "error": "Bad Request",
                      "error_description": "Error while getting the email from the JWT token"
                }
            };
            return badRequest;
        }
        if (email == "user1@abc.com") {
            return ["asub"];
        } else if (email == "user2@abc.com") {
            return ["bsub"];
        } else if (email == "user3@abc.com") {
            return ["csub"];
        } else {
            return [];
        }
    }

    resource function post validate/subscriptions/[string user]() returns SubscriptionResponse {

        SubscriptionResponse response = {
            isValidCustomer: true,
            projectKeys: []
        };

        if (user == "user1@abc.com") {
            response.projectKeys = ["asub"];
        } else if (user == "user2@abc.com") {
            response.projectKeys = ["bsub"];
        } else if (user == "user3@abc.com") {
            response.projectKeys = ["csub"];
        } else if (user == "user4@abc.com") {
            response.projectKeys = [];
        } else if (user == "john@example.com") {
            response.projectKeys = ["examplesub"];
        } else {
            response.isValidCustomer = false;
        }

        return response;
    }
}
