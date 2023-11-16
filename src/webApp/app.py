from flask import Flask, request, jsonify, render_template
import requests
import asyncio
import os

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/get-response', methods=['POST'])
async def get_response():
    # Collect easy auth headers if enabled
    use_easy_auth = os.getenv('FORWARD_EASY_AUTH', "False").lower() in ['true', '1']
    extra_headers = {}
    if use_easy_auth:
        # See: https://learn.microsoft.com/en-us/azure/app-service/configure-authentication-user-identities#access-user-claims-in-app-code
        extra_headers = {
            "X-MS-CLIENT-PRINCIPAL": request.headers.get('X-MS-CLIENT-PRINCIPAL', ""),
            "X-MS-CLIENT-PRINCIPAL-ID": request.headers.get('X-MS-CLIENT-PRINCIPAL-ID', "anonymous"),
            "X-MS-CLIENT-PRINCIPAL-NAME": request.headers.get('X-MS-CLIENT-PRINCIPAL-NAME', "anonymous"),
            "X-MS-CLIENT-PRINCIPAL-IDP": request.headers.get('X-MS-CLIENT-PRINCIPAL-IDP', "None")
        }
    prompt = request.json['prompt']
    response = await call_api(prompt, extra_headers)
    return jsonify(response)

async def call_api(prompt, extra_headers):
    api_endpoint = os.getenv('API_ENDPOINT', "http://localhost:7071/api/http_trigger")
    headers = {"Content-Type": "application/json"}

    # Append extra_headers if not null
    if extra_headers:
        headers.update(extra_headers)

    # Format payload
    data = {"name": prompt}

    # Get the default event loop
    loop = asyncio.get_event_loop()

    def make_request():
        return requests.post(api_endpoint, json=data, headers=headers)

    # Async call to the API using the event loop
    response = await loop.run_in_executor(None, make_request)
    return response.text
