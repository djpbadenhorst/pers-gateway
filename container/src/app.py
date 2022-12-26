import os
import json
import requests
from datetime import datetime, timedelta, timezone

from flask import Flask, session
from flask import request, redirect, render_template, send_from_directory

from utils import start_instance

app = Flask(__name__)
app.secret_key = os.environ['FLASK_SECRET']


@app.route('/',methods=['GET'])
def index():
    if request.method == 'GET':
        if (session.get('auth_expires') and session.get('auth_expires') > datetime.now(timezone.utc)):
            try:
                response = requests.get(f'''http://{os.environ['GATEWAY_IP']}:80''', timeout=30)
                if response.status_code == 503 or response.status_code == 500:
                    raise Exception
            except Exception:
                start_instance()
                response = requests.get(f'''http://{os.environ['GATEWAY_IP']}:80''', timeout=30)
            return response.content
        else:
            return redirect('/login', code=302)


@app.route('/login',methods=['GET', 'POST'])
def login():
    if request.method == 'GET':
        if request.headers.get('Authorization'):
            return json.loads({'status':'success','message':'Authenticated'}), 200
        else:
            return render_template('login.html', error=False)
        
    elif request.method == 'POST':
            username = request.form.get('username')
            password = request.form.get('password')
            if True or (username == 'djpbadenhorst@gmail.com' and password=='B@man1313'):
                session['auth_expires'] = datetime.now(timezone.utc) + timedelta(hours=1)
                return redirect('/', code=302)
            else:
                return render_template('login.html', error=True)


@app.route('/favicon.ico')
def favicon():
    return send_from_directory(os.path.join(os.path.dirname(__file__), 'static','images'), 'favicon.ico')


if __name__ == '__main__':
    app.run(host='0.0.0.0')

