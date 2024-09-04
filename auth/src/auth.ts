import { APIGatewayAuthorizerResult, PolicyDocument, StatementEffect, APIGatewayRequestAuthorizerEvent } from 'aws-lambda';

/**
 * A simple token-based authorizer function for AWS API Gateway.
 */
export const handler = async (event: APIGatewayRequestAuthorizerEvent): Promise<APIGatewayAuthorizerResult> => {
    const token = event.headers?.Authorization || event.headers?.authorization;
    const expectedToken = process.env.API_KEY;
    const cloudfrontArn = process.env.CLOUDFRONT_ARN || "";

    // Validate the incoming token
    if (token === expectedToken) {
        return generatePolicy('user', 'Allow', event.methodArn);
    } else {
        return generatePolicy('user', 'Deny', event.methodArn);
    }
};

/**
 * Generates a policy document to allow or deny access to the API Gateway.
 */
const generatePolicy = (principalId: string, effect: StatementEffect, resource: string): APIGatewayAuthorizerResult => {
    const policyDocument: PolicyDocument = {
        Version: '2012-10-17',
        Statement: [
            {
                Effect: effect,
                Action: 'execute-api:Invoke',
                Resource: resource,
            },
        ],
    };

    return {
        principalId,
        policyDocument,
    };
};
