from flask import Flask, request, jsonify
from flask_cors import CORS
import openai
import os

# Initialize Flask app
app = Flask(__name__)
CORS(app=app)
# CORS(app, resources={r"/Users/yinghaiyu/Main/DesktopMain/STUDY/GameDevelopment/kx-profile/public/Resources/hiyori_free_en/runtime/*": {"origins": "http://localhost:3000"}})

# Load OpenAI API key from environment variable
print("hello: ", os.getenv('OPENAI_API_KEY'))
# openai.api_key = os.getenv('OPENAI_API_KEY')
openai.api_key = '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'

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
        model='ft:gpt-3.5-turbo-1106:personal::8RZZVB7y',      # Choose the appropriate language model
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











