# LOCAL ENV (run the following in your terminal MAC OS)
# source ./backend-env/bin/activate
# python3 app.py

from flask import Flask, request, jsonify
import openai
import sys

OPENAI_API_KEY = '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'

app = Flask(__name__)

@app.route("/message", methods=['POST'])
def handleMessage():
    data = request.json
    user_message = data['message']

    # call Open AI API from here:
    # response = ...
    response = openai.completions.create(
        engine='gpt-3.5-turbo',      # choose the appropriate language model
        prompt=user_message,
        max_tokens=300
    )
    reply = response.choices[0].text.strip()

    return jsonify({'reply': 'Here is AI response ... '})







if __name__ == '__main__':
    app.run(debug=True)














