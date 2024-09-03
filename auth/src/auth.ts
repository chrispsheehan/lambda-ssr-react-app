import { APIGatewayTokenAuthorizerEvent, APIGatewayAuthorizerResult, PolicyDocument } from 'aws-lambda';

/**
 * A simple token-based authorizer function for AWS API Gateway.
 */
export const handler = async (event: APIGatewayTokenAuthorizerEvent): Promise<APIGatewayAuthorizerResult> => {
    const token = event.authorizationToken;

    // Validate the incoming token
    if (token === 'allow') {
        return generatePolicy('user', 'Allow', event.methodArn);
    } else if (token === 'deny') {
        return generatePolicy('user', 'Deny', event.methodArn);
    } else {
        throw new Error('Unauthorized');
    }
};

/**
 * Generates a policy document to allow or deny access to the API Gateway.
 */
const generatePolicy = (principalId: string, effect: string, resource: string): APIGatewayAuthorizerResult => {
    const policyDocument: PolicyDocument = {
        Version: '2012-10-17',
        Statement: [
        ],
    };

    return {
        principalId,
        policyDocument,
    };
};
