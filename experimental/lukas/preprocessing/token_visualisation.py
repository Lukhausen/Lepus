import os
import html
import hashlib # For slightly more stable hashing than built-in hash()
from flask import Flask, request, render_template_string
from transformers import AutoTokenizer, __version__ as transformers_version

# --- Flask App Initialization ---
app = Flask(__name__)
app.secret_key = os.urandom(24)

# --- Helper Functions for Color ---

def get_color_from_string(input_string):
    """Generates a hex color code based on the hash of the input string."""
    # Use sha256 for a more consistent hash, take first few bytes
    hash_object = hashlib.sha256(input_string.encode('utf-8'))
    hex_dig = hash_object.hexdigest()
    # Take first 6 hex characters for RRGGBB
    hash_int = int(hex_dig[:6], 16)
    # Ensure it's within the valid color range (might not be strictly necessary with sha256[:6])
    hash_int = hash_int % 0xFFFFFF
    # Format as a 6-digit hex string, prefixed with #
    return f"#{hash_int:06x}"

def get_text_color_for_bg(hex_color):
    """Determines if black or white text provides better contrast for a given hex background color."""
    hex_color = hex_color.lstrip('#')
    # Convert hex to RGB
    try:
        rgb = tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
    except ValueError:
        # Fallback for invalid hex code (shouldn't happen with generation method)
        return "#000000" # Default to black

    # Calculate luminance using the WCAG formula (simplified)
    # L = 0.2126 * R + 0.7152 * G + 0.0722 * B
    # Normalize RGB values to 0-1 range first
    r, g, b = [x / 255.0 for x in rgb]
    # Apply gamma correction approximation
    r = r <= 0.03928 and r / 12.92 or ((r + 0.055) / 1.055) ** 2.4
    g = g <= 0.03928 and g / 12.92 or ((g + 0.055) / 1.055) ** 2.4
    b = b <= 0.03928 and b / 12.92 or ((b + 0.055) / 1.055) ** 2.4
    luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b

    # WCAG contrast ratio threshold often involves comparing luminance with black/white
    # Simplified: if luminance > 0.179 (suggested threshold), use black text, else white
    return "#000000" if luminance > 0.179 else "#FFFFFF"


# --- HTML Template (Embedded) ---
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transformer Tokenizer Visualizer</title>
    <style>
        body {
            font-family: sans-serif;
            line-height: 1.6;
            margin: 20px;
            background-color: #f4f4f4;
        }
        .container {
            background-color: #fff;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            max-width: 900px; /* Increased max-width slightly */
            margin: auto;
        }
        h1, h2 {
            color: #333;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }
        form label {
            display: block;
            margin-top: 15px;
            font-weight: bold;
            color: #555;
        }
        form input[type="text"],
        form textarea {
            width: 100%;
            padding: 10px;
            margin-top: 5px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 1rem;
        }
        form textarea {
            min-height: 150px;
            font-family: monospace;
        }
        form button {
            background-color: #007bff;
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
            margin-top: 20px;
            transition: background-color 0.2s ease;
        }
        form button:hover {
            background-color: #0056b3;
        }
        .results {
            margin-top: 30px;
            border-top: 1px solid #eee;
            padding-top: 20px;
        }
        .error {
            color: #d9534f;
            background-color: #f2dede;
            border: 1px solid #ebccd1;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 15px;
        }
        .token-visualization {
            font-family: monospace;
            white-space: pre-wrap;
            word-wrap: break-word;
            background-color: #ffffff;
            border: 1px solid #ddd;
            padding: 15px;
            border-radius: 4px;
            overflow-x: auto;
        }
        /* General Token Style (border, padding, etc.) */
        .token {
            display: inline-block;
            border: 1px solid #aaa; /* Slightly darker border */
            padding: 2px 4px; /* Adjusted padding */
            margin: 1px 2px; /* Adjusted margin */
            border-radius: 4px;
            white-space: pre-wrap;
            overflow-wrap: break-word;
            line-height: 1.4;
            font-weight: 500; /* Slightly bolder */
            box-shadow: 0 1px 1px rgba(0,0,0,0.05); /* Subtle shadow */
        }
        /* Removed token-even/token-odd backgrounds - using inline style now */

        .token-space {
            /* Make spaces slightly more visible */
            min-width: 0.6em;
            border-style: dotted;
            border-color: #bbb;
            background-color: #ffffff !important; /* Override generated color for spaces */
            color: #888 !important; /* Gray text for spaces */
            font-weight: normal;
            box-shadow: none;
        }
        .token-newline {
            /* Make newline tokens visible */
            min-width: 2em; /* Wider */
            border-style: dashed;
            border-color: #bbb;
            background-color: #e8f5e9 !important; /* Override generated - light green */
            color: #555 !important; /* Darker text for newline */
            font-style: italic;
            text-align: center;
            font-weight: normal;
            box-shadow: none;
        }
        pre {
            white-space: pre-wrap;
            word-wrap: break-word;
            background-color: #ffffff;
            border: 1px solid #ddd;
            padding: 10px;
            border-radius: 4px;
        }
        footer {
            margin-top: 30px;
            text-align: center;
            font-size: 0.8em;
            color: #777;
        }

    </style>
</head>
<body>
    <div class="container">
        <h1>Transformer Tokenizer Visualizer</h1>

        <form method="post">
            <label for="model_name">Hugging Face Model Name:</label>
            <input type="text" id="model_name" name="model_name"
                   value="{{ model_name | default('Qwen/Qwen2.5-0.5B', true) }}"
                   placeholder="e.g., gpt2, bert-base-uncased, Qwen/Qwen2.5-0.5B" required>

            <label for="text_input">Text to Tokenize:</label>
            <textarea id="text_input" name="text_input"
                      placeholder="Enter text here..." required>{{ text_input | default('', true) }}</textarea>

            <button type="submit">Tokenize</button>
        </form>

        {% if error_message %}
            <div class="error">
                <strong>Error:</strong> {{ error_message }}
            </div>
        {% endif %}

        {% if tokens_html %}
            <div class="results">
                <h2>Results for: <tt>{{ processed_model_name }}</tt></h2>
                <h3>Original Text:</h3>
                <pre>{{ text_input | escape }}</pre>

                <h3>Tokenization ({{ token_count }} tokens):</h3>
                <div class="token-visualization">
                    {{ tokens_html | safe }} {# Render the pre-formatted HTML #}
                </div>
            </div>
        {% endif %}

        <footer>
            Using Flask and Transformers v{{ hf_version }}
        </footer>
    </div>
</body>
</html>
"""

# --- Updated Helper Function to Generate Token HTML with Colors ---
def generate_token_html_with_colors(tokenizer, text):
    """Tokenizes text and generates HTML with unique colors for each token type."""
    try:
        token_ids = tokenizer.encode(text)
        tokens = [tokenizer.decode([token_id]) for token_id in token_ids]
    except Exception as e:
        print(f"Warning: encode/decode failed ({e}), falling back to tokenize.")
        try:
            tokens = tokenizer.tokenize(text)
        except Exception as e2:
            raise ValueError(f"Failed to tokenize text with both methods. Error: {e2}") from e2

    # Map unique tokens to colors
    unique_tokens = sorted(list(set(tokens)))
    token_color_map = {token: get_color_from_string(token) for token in unique_tokens}

    rendered_html = ""
    for i, token in enumerate(tokens):
        safe_token = html.escape(token)
        css_class = "token" # Start with base class
        style_attrs = ""

        is_space = safe_token.isspace() and '\n' not in token # Treat space-only tokens
        is_newline_token = safe_token == html.escape("<0x0A>") # Qwen specific newline
        contains_newline = '\n' in token # General newline check

        if is_newline_token:
            css_class += " token-newline"
            safe_token = '<NL>'
            # Use predefined styles for newline, ignore generated color
        elif is_space:
            css_class += " token-space"
            safe_token = ' ' * len(token)
            # Use predefined styles for space, ignore generated color
        elif contains_newline and len(token) > 1 : # If token contains NL but isn't just NL
             # Render the non-newline part with color, add <br>
             bg_color = token_color_map.get(token, "#CCCCCC") # Fallback color
             text_color = get_text_color_for_bg(bg_color)
             style_attrs = f'style="background-color: {bg_color}; color: {text_color}; border-color: {text_color};"' # Adjust border too
             safe_token = html.escape(token.replace('\n', '')) + '<br>' # Replace newline with break
        else:
            # Regular token: Apply generated color
            bg_color = token_color_map.get(token, "#CCCCCC") # Fallback color
            text_color = get_text_color_for_bg(bg_color)
            # Adjust border color for better visibility against background
            border_color_intensity = 180 # Mid-gray intensity
            border_color = "#000000" if int(bg_color[1:3], 16)*0.299 + int(bg_color[3:5], 16)*0.587 + int(bg_color[5:7], 16)*0.114 < border_color_intensity else "#FFFFFF"
            style_attrs = f'style="background-color: {bg_color}; color: {text_color}; border-color: {text_color};"' # Use text color for border

        # Add the token span to the HTML
        rendered_html += f'<span class="{css_class}" {style_attrs}>{safe_token}</span>'

    return rendered_html, len(tokens)


# --- Flask Route (Uses the new HTML generation function) ---
@app.route('/', methods=['GET', 'POST'])
def index():
    model_name = request.form.get('model_name', 'Qwen/Qwen2.5-0.5B')
    text_input = request.form.get('text_input', '')
    tokens_html = None
    error_message = None
    token_count = 0
    processed_model_name = model_name

    if request.method == 'POST':
        if not model_name or not text_input:
            error_message = "Model Name and Text Input cannot be empty."
        else:
            try:
                tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
                print(f"Successfully loaded tokenizer: {model_name}")

                # Use the updated function for color generation
                tokens_html, token_count = generate_token_html_with_colors(tokenizer, text_input)

            except OSError as e:
                error_message = f"Could not load tokenizer '{model_name}'. Is the name correct? Is the model public? (Error: {e})"
                print(f"Error loading tokenizer: {e}")
            except ValueError as e:
                 error_message = f"Error during tokenization: {e}"
                 print(f"Tokenization error: {e}")
            except Exception as e:
                error_message = f"An unexpected error occurred: {e}"
                print(f"Unexpected error: {e}")

    return render_template_string(
        HTML_TEMPLATE,
        model_name=model_name,
        text_input=text_input,
        tokens_html=tokens_html,
        error_message=error_message,
        token_count=token_count,
        processed_model_name=processed_model_name,
        hf_version=transformers_version
    )

# --- Run the App ---
if __name__ == '__main__':
    print("Starting Flask server with token colorization...")
    print("Transformers version:", transformers_version)
    app.run(host='0.0.0.0', port=5000, debug=True)