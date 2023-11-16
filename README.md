# Demo: Python Chat to Azure Function

This is a Python application that runs a simple web application which posts data to an Azure Function and displays the result.

## Development

For local development and testing, you can run this locally or in a GitHub Codespace / Dev Container. This project contains launch settings for both Python/Flask (web) application and the Azure Functions project.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/ChrisRomp/demo-chat-functions)

For the Azure Functions project, be sure to set the `AzureWebJobsFeatureFlags` to `EnableWorkerIndexing` in your `local.settings.json` file to enable the [Azure Functions Python v2 programming model](https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference-python?tabs=asgi%2Capplication-level&pivots=python-mode-decorators).

Example:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "AzureWebJobsFeatureFlags": "EnableWorkerIndexing"
  }
}
```

## Configuration

Configure these app settings:

| Setting | Required | Default | Notes |
| --- | --- | --- | --- |
| `API_ENDPOINT` | Yes | `http://localhost:7071/api/http_trigger` | The API endpoint to call |
| `FORWARD_EASY_AUTH` | No | False | Set to "true" or "1" to enable. See below. |

## Easy Auth

To easily enable authentication, you can configure Azure App Service to use several identity services, including Entra (Azure AAD). See the [Configure your App Service or Azure Functions app to use Microsoft Entra sign-in](https://learn.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad?tabs=workforce-tenant) documentation for more information.

When the `FORWARD_EASY_AUTH` option is set, this application will include the user claims headers in its backend function call, if needed for logging, etc.

See the [Work with user identities in Azure App Service authentication](https://learn.microsoft.com/en-us/azure/app-service/configure-authentication-user-identities) document for more information about these headers.

| Header | Description |
| --- | --- |
| `X-MS-CLIENT-PRINCIPAL` | A Base64 encoded JSON representation of available claims. |
| `X-MS-CLIENT-PRINCIPAL-ID` | An identifier for the caller set by the identity provider. |
| `X-MS-CLIENT-PRINCIPAL-NAME` | A human-readable name for the caller set by the identity provider, e.g. Email Address, User Principal Name. |
| `X-MS-CLIENT-PRINCIPAL-IDP` | The name of the identity provider used by App Service Authentication. |
