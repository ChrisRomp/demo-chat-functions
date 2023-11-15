from flask import Flask, request, jsonify, render_template
import requests
import asyncio

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/get-response', methods=['POST'])
async def get_response():
    prompt = request.json['prompt']
    response = await call_api(prompt)
    return jsonify(response)

async def call_api(prompt):
    # Replace 'api_endpoint' and 'api_key' with actual API details
    api_endpoint = "http://localhost:7071/api/http_trigger"
    headers = {"Content-Type": "application/json"}
    data = {"name": prompt}

    # Get the default event loop
    loop = asyncio.get_event_loop()

    def make_request():
        return requests.post(api_endpoint, json=data, headers=headers)

    # Async call to the API using the event loop
    response = await loop.run_in_executor(None, make_request)
    return response.text

if __name__ == '__main__':
    app.run(debug=True)  # Running in debug mode