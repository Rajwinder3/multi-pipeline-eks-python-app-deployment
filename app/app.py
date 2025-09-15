import os
import pymysql
from flask import Flask, request, jsonify, render_template_string

app = Flask(__name__)

# Read database credentials from environment variables
DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_NAME = os.getenv("DB_NAME")

# Connect to the MySQL database
def get_db_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )

# Create table and insert message if not exists
def init_db():
    connection = get_db_connection()
    with connection:
        with connection.cursor() as cursor:
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS messages (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    content VARCHAR(255) NOT NULL
                )
            """)
            connection.commit()

            cursor.execute("SELECT * FROM messages")
            if cursor.rowcount == 0:
                cursor.execute("INSERT INTO messages (content) VALUES ('Hello, user')")
                connection.commit()

# Fetch message from DB
def get_message():
    connection = get_db_connection()
    with connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT content FROM messages LIMIT 1")
            result = cursor.fetchone()
            return result["content"] if result else "No message"

# Initialize the DB on app start
init_db()

HTML_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>Real Calculator</title>
    <style>
        body {
            background: #202020;
            font-family: Arial, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            color: white;
        }
        .message {
            margin-bottom: 20px;
            font-size: 24px;
            color: #0ff;
        }
        .calculator {
            background: #2e2e2e;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 0 15px rgba(0,0,0,0.5);
            width: 300px;
        }
        .display {
            background: #000;
            color: #0f0;
            font-size: 32px;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            text-align: right;
            overflow-x: auto;
        }
        .buttons {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
        }
        .buttons button {
            font-size: 20px;
            padding: 20px;
            border: none;
            border-radius: 5px;
            background: #444;
            color: white;
            cursor: pointer;
            transition: background 0.2s ease;
        }
        .buttons button:hover {
            background: #666;
        }
        .buttons .equals {
            grid-column: span 2;
            background: #28a745;
        }
        .buttons .clear {
            background: #dc3545;
        }
        .buttons .zero {
            grid-column: span 2;
        }
    </style>
</head>
<body>
    <div class="message">{{ message }}</div>
    <div class="calculator">
        <div class="display" id="display">0</div>
        <div class="buttons">
            <button onclick="press('7')">7</button>
            <button onclick="press('8')">8</button>
            <button onclick="press('9')">9</button>
            <button onclick="press('/')">÷</button>
            <button onclick="press('4')">4</button>
            <button onclick="press('5')">5</button>
            <button onclick="press('6')">6</button>
            <button onclick="press('*')">×</button>
            <button onclick="press('1')">1</button>
            <button onclick="press('2')">2</button>
            <button onclick="press('3')">3</button>
            <button onclick="press('-')">−</button>
            <button onclick="press('0')" class="zero">0</button>
            <button onclick="press('.')">.</button>
            <button onclick="press('+')">+</button>
            <button onclick="clearDisplay()" class="clear">C</button>
            <button onclick="calculate()" class="equals">=</button>
        </div>
    </div>
    <script>
        let expression = '';

        function press(char) {
            if (expression === '0' && char !== '.') {
                expression = '';
            }
            expression += char;
            document.getElementById('display').innerText = expression;
        }

        function clearDisplay() {
            expression = '';
            document.getElementById('display').innerText = '0';
        }

        function calculate() {
            fetch('/calculate', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ expression: expression })
            })
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    document.getElementById('display').innerText = data.error;
                } else {
                    expression = data.result.toString();
                    document.getElementById('display').innerText = expression;
                }
            });
        }
    </script>
</body>
</html>
'''

@app.route('/')
def index():
    message = get_message()
    return render_template_string(HTML_TEMPLATE, message=message)

@app.route('/calculate', methods=['POST'])
def calculate():
    data = request.get_json()
    expr = data.get('expression', '')
    try:
        result = eval(expr)
        return jsonify({'result': result})
    except Exception:
        return jsonify({'error': 'Invalid expression'}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
