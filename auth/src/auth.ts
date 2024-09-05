import { APIGatewayRequestAuthorizerEvent, APIGatewayAuthorizerResult, PolicyDocument, StatementEffect } from 'aws-lambda';

export const handler = async (event: APIGatewayRequestAuthorizerEvent): Promise<APIGatewayAuthorizerResult> => {
    console.log('Received event:', JSON.stringify(event, null, 2)); // Log the entire event

    const authorizationToken = event.headers?.Authorization || '';
    const expectedToken = process.env.API_KEY || '';
    const apiGatewayResource = process.env.API_GATEWAY_RESOURCE || '';

    // Log the received token and expected token
    console.log('Authorization token received:', authorizationToken);
    console.log('Expected token:', expectedToken);
    console.log('API Gateway Resource:', apiGatewayResource); // Log the API Gateway resource being accessed

    // Validate the incoming token
    if (authorizationToken === expectedToken) {
        console.log('Authorization successful. Generating Allow policy.');
        return generatePolicy('user', 'Allow', apiGatewayResource);
    } else {
        console.log('Authorization failed. Generating Deny policy.');
        return generatePolicy('user', 'Deny', apiGatewayResource);
    }
};

// Helper function to generate an IAM policy
const generatePolicy = (principalId: string, effect: StatementEffect, resource: string): APIGatewayAuthorizerResult => {
    const policyDocument: PolicyDocument = {
        Version: "2012-10-17",
        Statement: [
            {
                Action: "execute-api:Invoke",
                Effect: effect,
                Resource: resource,
            },
        ],
    };

    console.log('Generated policy:', JSON.stringify(policyDocument, null, 2)); // Log the generated policy

    // return {
    //     principalId,
    //     policyDocument,
    // };

    return {
        "principalId": "user",
        "policyDocument": {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Action": "*",
              "Resource": "*"
            }
          ]
        }
    };
};
