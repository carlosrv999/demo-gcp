from flask import request, Flask
import socket

app = Flask(__name__)

@app.route("/healthz")
def healthz():
    return "Healthy"

@app.route("/")
def rootpage():
    return "root page"

@app.route("/greetings")
def hello():
    return "Hello World from " + socket.gethostname() + "."

@app.route("/square")
def square():
    x = request.args.get('x')
    try:
        x = int(x)
        return str(x ** 2)
    except:
        return "Ingrese un numero entero con el parametro x en la url (/square?x=1 por ejemplo)"

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
