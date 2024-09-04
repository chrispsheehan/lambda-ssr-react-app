import { APIGatewayTokenAuthorizerEvent, APIGatewayAuthorizerResult, PolicyDocument, StatementEffect } from 'aws-lambda';

/**
 * A simple token-based authorizer function for AWS API Gateway.
 */
export const handler = async (event: APIGatewayTokenAuthorizerEvent): Promise<APIGatewayAuthorizerResult> => {
    const token = event.authorizationToken;
    const expectedToken = process.env.API_KEY;
    const cloudfrontArn = process.env.CLOUDFRONT_ARN || ""

    // Validate the incoming token
    if (token === expectedToken) {
        return generatePolicy('user', 'Allow', event.methodArn, cloudfrontArn);
    } else {
        return generatePolicy('user', 'Deny', event.methodArn, cloudfrontArn);
    }
};

/**
 * Generates a policy document to allow or deny access to the API Gateway.
 */
const generatePolicy = (principalId: string, effect: StatementEffect, resource: string, cloudfrontArn: string): APIGatewayAuthorizerResult => {
    const policyDocument: PolicyDocument = {
        Version: '2012-10-17',
        Statement: [
            {
                Effect: effect,
                Action: 'execute-api:Invoke',
                Resource: resource,
                Principal: {
                    Service: 'cloudfront.amazonaws.com',
                },
                Condition: {
                    StringEquals: {
                        'AWS:SourceArn': cloudfrontArn,
                    },
                },
            },
        ],
    };

    console.log({
        principalId,
        policyDocument,
    })

    return {
        principalId,
        policyDocument,
    };
};
