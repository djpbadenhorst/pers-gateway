import os
import json
import requests
from datetime import datetime, timedelta, timezone

from flask import Flask, session
from flask import request, redirect, render_template, send_from_directory

from utils import start_gateway, stop_gateway, check_gateway

app = Flask(__name__)
app.secret_key = os.environ['FLASK_SECRET']


@app.route('/api/gateway/on', methods=['POST'])
def gateway_on():
    if request.method == 'POST':
        start_gateway()
        return json.dumps({'status':'success','payload':{'message':'Instruction sent'} }), 200

        
@app.route('/api/gateway/off', methods=['POST'])
def gateway_off():
    if request.method == 'POST':
        stop_gateway()
        return json.dumps({'status':'success','payload':{'message':'Instruction sent'} }), 200

    
@app.route('/api/gateway/status', methods=['GET'])
def gateway_status():
    if request.method == 'GET':
        return json.dumps({'status':'success','payload':{'status':check_gateway()} }), 200

        
@app.route('/api/auth/authenticate', methods=['GET', 'POST'])
def authenticate():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        if (username == 'djpb' and password=='B@man1313'):
            session['auth_expires'] = datetime.now(timezone.utc) + timedelta(hours=1)
        else:
            session['auth_expires'] = datetime.now(timezone.utc)
        return redirect('/status', code=302)

            
@app.route('/api/auth/status', methods=['GET'])
def auth_status():
    if request.method == 'GET':
        if (session.get('auth_expires') and session.get('auth_expires') > datetime.now(timezone.utc)):
            return json.dumps({'status':'success','payload':{'message':'Authenticated'} }), 200
        else:
            return json.dumps({'status':'failure','payload':{'message':'Not Authenticated'} }), 403


if __name__ == '__main__':
    app.run(host='0.0.0.0')

