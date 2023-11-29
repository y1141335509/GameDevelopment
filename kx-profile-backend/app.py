# LOCAL ENV (run the following in your terminal MAC OS)
# source ./backend-env/bin/activate
# python3 app.py

from flask import Flask, request, jsonify
from flask_cors import CORS
import openai
import os


# setup OPENAI API KEY:
# (terminal) export OPENAI_API_KEY='YOUR_OPENAI_API_KEY'
# next, get API KEY directly from your local environment:
openai.api_key = os.getenv('OPENAI_API_KEY')

print(os.getenv('OPENAI_API_KEY'))


conversations = []
# initialize flask app:
app = Flask(__name__)
CORS(app=app)       # handle Cross Origin Resource Sharing
@app.route("/message", methods=['POST'])    # default backend IP is https://127.0.0.1:5000
def handleMessage():
    data = request.json
    user_message = data['message']

    # call Open AI API from here:
    response = openai.chat.completions.create(
        model='gpt-3.5-turbo',      # choose the appropriate language model
        messages=[{
            'role': 'user',
            'content': user_message,
        }]
    )
    reply = response.choices[0].message.content
    conversations.append(reply)

    return jsonify({'reply': reply})







if __name__ == '__main__':
    app.run(debug=True)














