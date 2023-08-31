from flask import Flask, render_template, request
from datetime import datetime

app = Flask(__name__)

MESSAGES_FILE = 'templates/messages.txt'
messages = []


def load_messages():
  try:
    with open(MESSAGES_FILE, 'r', encoding='utf-8') as file:
      for line in file:
        message_data = line.strip().split(',')
        if len(message_data) == 2:
          message = {'text': message_data[0], 'timestamp': message_data[1]}
          messages.append(message)
  except FileNotFoundError:
    pass


def save_messages():
  with open(MESSAGES_FILE, 'w', encoding='utf-8') as file:
    for message in messages:
      file.write(f"{message['text']},{message['timestamp']}\n")


@app.route('/')
def home():
  reversed_messages = list(reversed(messages))
  return render_template('index.html', messages=reversed_messages)


@app.route('/post_message', methods=['POST'])
def post_message():
  message_text = request.form['message']
  timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
  message = {'text': message_text, 'timestamp': timestamp}
  messages.append(message)
  save_messages()
  return render_template('index.html', messages=messages)


if __name__ == '__main__':
  load_messages()
  app.run(host='0.0.0.0', port=5000)
