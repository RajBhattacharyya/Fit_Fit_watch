from flask import Flask, jsonify
import random

app = Flask(__name__)

@app.route('/steps')
def get_steps():
    steps = random.randint(10000, 12500) 
    return jsonify({"steps": steps})

@app.route('/heartbeat')
def get_heartbeat():
    heartbeat = random.randint(80, 100) 
    return jsonify({"heartbeat": heartbeat})

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
