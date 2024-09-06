import { APIGatewayRequestAuthorizerEvent, APIGatewayAuthorizerResult, PolicyDocument, StatementEffect } from 'aws-lambda';

export const handler = async (event: APIGatewayRequestAuthorizerEvent): Promise<APIGatewayAuthorizerResult> => {
    try {
        console.log('Received event:', JSON.stringify(event, null, 2)); // Log the entire event

        // Extract the authorization token from the event
        const authorizationToken = event.headers?.authorization || ''; // Use 'authorization' from the headers
        const expectedToken = process.env.API_KEY || ''; // Expected token from environment variable

        // Log the received token and expected token
        console.log('Authorization token received:', authorizationToken);
        console.log('Expected token:', expectedToken);

        // Extract the routeArn to use as the resource in the policy
        const apiGatewayResource = (event as any).routeArn || '';

        console.log('API Gateway Resource:', apiGatewayResource); // Log the API Gateway resource being accessed

        // Validate the incoming token
        if (authorizationToken === expectedToken) {
            console.log('Authorization successful. Generating Allow policy.');
            return generatePolicy('user', 'Allow', apiGatewayResource);
        } else {
            console.log('Authorization failed. Generating Deny policy.');
            return generatePolicy('user', 'Deny', apiGatewayResource);
        }
    } catch (error) {
        console.error('Error processing the authorization request:', error);
        throw new Error('Unauthorized'); // Re-throw error to ensure API Gateway responds with 401/403
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
                Resource: ["*"],
            },
        ],
    };

    console.log('Generated policy:', JSON.stringify(policyDocument, null, 2)); // Log the generated policy

    return {
        principalId,
        policyDocument,
    };
};
