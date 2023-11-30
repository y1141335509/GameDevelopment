# # LOCAL ENV (run the following in your terminal MAC OS)
# # source ./backend-env/bin/activate
# # python3 app.py

# from flask import Flask, request, jsonify
# from flask_cors import CORS
# import openai
# import os


# # setup OPENAI API KEY:
# # (terminal) export OPENAI_API_KEY='YOUR_OPENAI_API_KEY'
# # next, get API KEY directly from your local environment:
# openai.api_key = os.getenv('OPENAI_API_KEY')

# print(os.getenv('OPENAI_API_KEY'))





# conversations = []
# # initialize flask app:
# app = Flask(__name__)
# CORS(app=app)       # handle Cross Origin Resource Sharing
# @app.route("/message", methods=['POST'])    # default backend IP is https://127.0.0.1:5000
# def handleMessage():
#     data = request.json
#     user_message = data['message']

#     # call Open AI API from here:
#     response = openai.chat.completions.create(
#         model='gpt-3.5-turbo',      # choose the appropriate language model
#         messages=[{
#             'role': 'user',
#             'content': user_message,
#         }]
#     )
#     reply = response.choices[0].message.content
#     conversations.append(reply)

#     return jsonify({'reply': reply})







# if __name__ == '__main__':
#     app.run(debug=True)





from flask import Flask, request, jsonify
from flask_cors import CORS
import openai
import os

# Initialize Flask app
app = Flask(__name__)
CORS(app=app)

# Load OpenAI API key from environment variable
openai.api_key = os.getenv('OPENAI_API_KEY')

# Initialize a dictionary to store conversations by user session
conversations = {}

@app.route("/message", methods=['POST'])
def handleMessage():
    data = request.json
    user_message = data['message']
    session_id = data.get('sessionId', 'default')  # Get or create a session ID for the user

    # Get the conversation history for this user, or start a new one
    conversation = conversations.get(session_id, [])

    # Add the user's message to the conversation
    conversation.append({'role': 'user', 'content': user_message})


    # Call OpenAI API including the full conversation history
    response = openai.chat.completions.create(
        model='ft:gpt-3.5-turbo-1106:personal::8QiYxFq8',      # Choose the appropriate language model
        messages=conversation,
    )
    ai_reply = response.choices[0].message.content

    # Add AI's reply to the conversation
    conversation.append({'role': 'assistant', 'content': ai_reply})

    # Save the updated conversation
    conversations[session_id] = conversation


    return jsonify({'reply': ai_reply})

if __name__ == '__main__':
    app.run(debug=True)











