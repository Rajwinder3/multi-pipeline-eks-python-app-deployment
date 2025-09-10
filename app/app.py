from flask import Flask, request, jsonify, render_template_string

app = Flask(__name__)

HTML = '''
<!DOCTYPE html>
<html>
<head>
    <title>Real Calculator</title>
    <style>
        body {
            background: #202020;
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
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
    return render_template_string(HTML)

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
