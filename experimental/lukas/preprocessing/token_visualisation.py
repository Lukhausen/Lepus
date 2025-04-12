import os
import html
import hashlib
from flask import Flask, request, render_template_string, jsonify
from transformers import AutoTokenizer, __version__ as transformers_version
import logging
import time

# --- Flask App Initialization ---
app = Flask(__name__)
app.secret_key = os.urandom(24)

# Configure basic logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# --- Caching mechanism (Simple Dictionary) ---
# WARNING: Basic in-memory cache, not for production without proper memory management.
tokenizer_cache = {}
MAX_CACHE_SIZE = 5

def get_tokenizer(model_name):
    """Gets a tokenizer from cache or loads it with simple LRU."""
    if model_name in tokenizer_cache:
        logging.info(f"Tokenizer cache hit: {model_name}")
        tokenizer_cache[model_name] = tokenizer_cache.pop(model_name) # Move to end (most recent)
        return tokenizer_cache[model_name]

    if len(tokenizer_cache) >= MAX_CACHE_SIZE:
        lru_key = next(iter(tokenizer_cache))
        logging.warning(f"Tokenizer cache full ({MAX_CACHE_SIZE}). Removing LRU: {lru_key}")
        del tokenizer_cache[lru_key]

    try:
        logging.info(f"Loading tokenizer: {model_name}")
        # time.sleep(1) # Optional: Simulate loading delay for UX testing
        tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
        tokenizer_cache[model_name] = tokenizer
        logging.info(f"Loaded and cached tokenizer: {model_name}")
        return tokenizer
    except Exception as e:
        logging.error(f"Failed loading tokenizer '{model_name}': {e}", exc_info=True)
        # Re-raise to be caught in the route and returned as JSON error
        raise OSError(f"Could not load tokenizer '{model_name}'. Is the name correct and model public? Original error: {e}")


# --- Helper Functions for Color (Unchanged) ---
def get_color_from_string(input_string):
    hash_object = hashlib.sha256(input_string.encode('utf-8'))
    hex_dig = hash_object.hexdigest()
    hash_int = int(hex_dig[:6], 16) % 0xFFFFFF
    return f"#{hash_int:06x}"

def get_text_color_for_bg(hex_color):
    hex_color = hex_color.lstrip('#')
    try:
        if len(hex_color) != 6: raise ValueError("Invalid hex length")
        rgb = tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
    except ValueError: return "#000000"
    r, g, b = [x / 255.0 for x in rgb]
    r = r <= 0.03928 and r / 12.92 or ((r + 0.055) / 1.055) ** 2.4
    g = g <= 0.03928 and g / 12.92 or ((g + 0.055) / 1.055) ** 2.4
    b = b <= 0.03928 and b / 12.92 or ((b + 0.055) / 1.055) ** 2.4
    luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
    return "#000000" if luminance > 0.179 else "#FFFFFF"


# --- Token HTML Generation (Unchanged logic, ensures <br> is outside span) ---
def generate_token_html_with_colors(tokenizer, text):
    """Generates token HTML with colors and correct line breaks."""
    if not isinstance(text, str):
        logging.warning(f"Received non-string input for tokenization: {type(text)}")
        return "", 0

    logging.info(f"Generating tokens for text length: {len(text)}")
    try:
        token_ids = tokenizer.encode(text)
        tokens_decoded = [tokenizer.decode([token_id], clean_up_tokenization_spaces=False) for token_id in token_ids]
    except Exception as e:
        logging.warning(f"encode/decode failed ({e}), falling back to tokenize.")
        try: tokens_decoded = tokenizer.tokenize(text)
        except Exception as e2:
            logging.error(f"Tokenization failed with both methods. Error: {e2}", exc_info=True)
            raise ValueError(f"Failed to tokenize text. Error: {e2}") from e2

    if not text or not tokens_decoded: return "", 0

    # Pre-calculate colors for unique tokens
    unique_tokens = sorted(list(set(t for t in tokens_decoded if t)))
    token_color_map = {token: get_color_from_string(token) for token in unique_tokens}

    rendered_html_parts = [] # Build parts then join - slightly more efficient
    token_count = 0
    for i, token in enumerate(tokens_decoded):
        if not token: continue # Skip empty tokens

        token_count += 1
        css_class = "token"
        style_attrs = ""
        is_newline_token = (token == '\n') or (token == "<0x0A>") # Add other special newline tokens?
        contains_newline = '\n' in token and not is_newline_token

        # Determine span content based on token type
        if is_newline_token:
            css_class += " token-newline"
            safe_span_content = "<NL>"
        elif contains_newline:
            safe_span_content = html.escape(token.replace('\n', '')) # Display text part only
        elif token.isspace():
             css_class += " token-space"
             safe_span_content = token.replace(' ', ' ').replace('\t', ' ' * 4)
        else:
             safe_span_content = html.escape(token)

        # Determine style (color) unless it's a special type with fixed style
        if not (is_newline_token or token.isspace()):
             bg_color = token_color_map.get(token, "#CCCCCC") # Use pre-calculated color
             text_color = get_text_color_for_bg(bg_color)
             style_attrs = f'style="background-color: {bg_color}; color: {text_color}; border-color: {text_color};"'

        # Construct the span
        span_html = f'<span class="{css_class}" {style_attrs}>{safe_span_content}</span>'
        rendered_html_parts.append(span_html)

        # Add <br> *after* the span if the token represented a newline
        if is_newline_token or contains_newline:
            rendered_html_parts.append("<br>")

    return "".join(rendered_html_parts), token_count


# --- HTML Template (Completely Restyled) ---
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Live Transformer Tokenizer</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <style>
        :root {
            --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
            --font-mono: 'JetBrains Mono', SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
            --color-bg: #f8f9fa; /* Light gray background */
            --color-container-bg: #ffffff;
            --color-text: #212529; /* Dark gray text */
            --color-text-muted: #6c757d; /* Lighter gray */
            --color-border: #dee2e6; /* Light border */
            --color-primary: #007bff; /* Blue for focus */
            --color-error-bg: #f8d7da;
            --color-error-text: #721c24;
            --color-error-border: #f5c6cb;
            --border-radius: 6px;
            --spacing: 1rem;
        }

        *, *::before, *::after { box-sizing: border-box; }

        body {
            font-family: var(--font-sans);
            line-height: 1.6;
            margin: 0;
            background-color: var(--color-bg);
            color: var(--color-text);
            padding: calc(var(--spacing) * 1.5);
        }

        .container {
            background-color: var(--color-container-bg);
            padding: calc(var(--spacing) * 1.5);
            border-radius: var(--border-radius);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.07);
            max-width: 900px;
            margin: auto;
        }

        h1 {
            font-size: 1.75rem;
            font-weight: 600;
            margin-top: 0;
            margin-bottom: calc(var(--spacing) * 1.5);
            color: var(--color-text);
        }
        h2 {
            font-size: 1.3rem;
            font-weight: 600;
            margin-top: calc(var(--spacing) * 2);
            margin-bottom: var(--spacing);
            color: var(--color-text);
            border-bottom: 1px solid var(--color-border);
            padding-bottom: calc(var(--spacing) / 2);
        }
         h3 {
            font-size: 1rem;
            font-weight: 500;
            margin-top: calc(var(--spacing) * 1.5);
            margin-bottom: calc(var(--spacing) / 2);
            color: var(--color-text-muted);
        }

        label {
            display: block;
            margin-bottom: calc(var(--spacing) / 3);
            font-weight: 500;
            color: var(--color-text);
            font-size: 0.9rem;
        }

        input[type="text"], textarea {
            width: 100%;
            padding: calc(var(--spacing) * 0.6) var(--spacing);
            border: 1px solid var(--color-border);
            border-radius: var(--border-radius);
            font-size: 1rem;
            line-height: 1.5;
            background-color: var(--color-container-bg);
            color: var(--color-text);
            transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
        }
        input[type="text"] { font-family: var(--font-sans); }
        textarea {
            font-family: var(--font-mono);
            min-height: 180px;
            resize: vertical;
        }
        input[type="text"]:focus, textarea:focus {
            border-color: var(--color-primary);
            outline: 0;
            box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
        }

        .input-group { margin-bottom: calc(var(--spacing) * 1.25); }

        /* Results Area Styling */
        .results {
            margin-top: calc(var(--spacing) * 2);
            border-top: 1px solid var(--color-border);
            padding-top: calc(var(--spacing) * 1.5);
            min-height: 150px; /* Ensure space for messages */
        }

        .status-message {
            font-style: italic;
            color: var(--color-text-muted);
            padding: var(--spacing) 0;
            text-align: center;
        }

        .error-display {
            background-color: var(--color-error-bg);
            color: var(--color-error-text);
            border: 1px solid var(--color-error-border);
            padding: var(--spacing);
            border-radius: var(--border-radius);
            margin-bottom: var(--spacing);
        }

        #token-visualization-content {
            font-family: var(--font-mono);
            white-space: pre-wrap;
            word-wrap: break-word;
            background-color: #ffffff; /* Explicit white background */
            border: 1px solid var(--color-border);
            padding: var(--spacing);
            border-radius: var(--border-radius);
            overflow-x: auto;
            text-align: left;
            line-height: 1.7; /* Increase line height for readability */
        }

        .token {
            display: inline-block;
            border: 1px solid #adb5bd; /* Softer border */
            padding: 1px 5px; /* Adjusted padding */
            margin: 2px 2px; /* Adjusted margin */
            border-radius: 4px;
            white-space: pre-wrap;
            overflow-wrap: break-word;
            line-height: 1.4; /* Inner line-height */
            font-weight: 400; /* Normal weight for mono */
            vertical-align: top;
            text-align: center;
            transition: transform 0.1s ease-out;
            cursor: default; /* Indicate non-interactive */
        }
        .token:hover { transform: scale(1.05); } /* Subtle hover effect */

        .token-space {
            min-width: 0.7em;
            border-style: dotted;
            border-color: #ced4da;
            background-color: transparent !important; /* Use transparent bg */
            color: var(--color-text-muted) !important;
            font-weight: 400;
            box-shadow: none;
        }

        .token-newline {
            min-width: 3em;
            border-style: dashed;
            border-color: #ced4da;
            background-color: #e9ecef !important; /* Light gray */
            color: var(--color-text-muted) !important;
            font-style: normal; /* Less emphasis */
            text-align: center;
            font-weight: 400;
            box-shadow: none;
            padding: 1px 6px;
        }

        footer {
            margin-top: calc(var(--spacing) * 2);
            text-align: center;
            font-size: 0.85em;
            color: var(--color-text-muted);
        }

        .hidden { display: none !important; } /* Utility class */
    </style>
</head>
<body>
    <div class="container">
        <h1>Live Transformer Tokenizer</h1>

        <div class="input-group">
            <label for="model_name">Hugging Face Model Name:</label>
            <input type="text" id="model_name" name="model_name"
                   value="{{ model_name | default('Qwen/Qwen2.5-0.5B', true) }}"
                   placeholder="e.g., gpt2, bert-base-uncased, Qwen/Qwen2.5-0.5B">
        </div>

        <div class="input-group">
            <label for="text_input">Text to Tokenize:</label>
            <textarea id="text_input" name="text_input"
                      placeholder="Enter text here...">{{ text_input | default('', true) }}</textarea>
        </div>

        {# Results Area - Dynamically updated #}
        <div class="results" id="results-area">
            {# Status message area (loading, initial prompt, errors) #}
            <div id="status-message-area">
                <div id="initial-prompt" class="status-message">Enter text above to see tokenization.</div>
                <div id="loading-indicator" class="status-message hidden">Tokenizing...</div>
                <div id="error-display" class="error-display hidden"></div>
            </div>

            {# Actual results container (hidden initially or when loading/error) #}
            <div id="results-content" class="hidden">
                 <h2>Results for: <tt id="processed-model-name"></tt></h2>
                 <h3>Tokenization (<span id="token-count-display">0</span> tokens):</h3>
                 <div id="token-visualization-content">
                     {# Content injected by JavaScript #}
                 </div>
            </div>
        </div>

        <footer>
            Using Flask and Transformers v{{ hf_version }}
        </footer>
    </div>

    {# --- JavaScript Section --- #}
    <script>
        function debounce(func, wait) {
            let timeout;
            return function executedFunction(...args) {
                const later = () => { clearTimeout(timeout); func(...args); };
                clearTimeout(timeout);
                timeout = setTimeout(later, wait);
            };
        }

        // DOM Elements
        const modelNameInput = document.getElementById('model_name');
        const textInput = document.getElementById('text_input');
        const resultsArea = document.getElementById('results-area');
        const statusMessageArea = document.getElementById('status-message-area');
        const initialPrompt = document.getElementById('initial-prompt');
        const loadingIndicator = document.getElementById('loading-indicator');
        const errorDisplay = document.getElementById('error-display');
        const resultsContent = document.getElementById('results-content');
        const processedModelNameDisplay = document.getElementById('processed-model-name');
        const tokenCountDisplay = document.getElementById('token-count-display');
        const tokenVisContent = document.getElementById('token-visualization-content');

        let currentRequestController = null;

        async function updateTokenization() {
            const modelName = modelNameInput.value.trim();
            const text = textInput.value; // Keep raw text

            if (currentRequestController) { currentRequestController.abort(); }
            currentRequestController = new AbortController();
            const signal = currentRequestController.signal;

            // --- Input Validation ---
            if (!modelName) {
                setError("Please enter a Hugging Face model name.");
                resultsContent.classList.add('hidden'); // Hide results section
                return;
            }
             if (!text) {
                 setInitialPrompt("Enter text above to see tokenization.");
                 resultsContent.classList.add('hidden'); // Hide results section
                 return;
             }

            // --- Update UI State: Loading ---
            setLoading();

            try {
                const response = await fetch('/tokenize_live', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({ model_name: modelName, text_input: text }),
                    signal: signal
                });

                if (signal.aborted) { console.log("Fetch aborted"); return; }

                const data = await response.json(); // Try to parse JSON regardless of status

                if (!response.ok) {
                    // Use error from JSON if available, otherwise use status text
                    const errorMsg = data?.error || `Server error: ${response.status} ${response.statusText}`;
                    throw new Error(errorMsg);
                }

                // --- Update UI State: Success ---
                if (data.error) { // Handle errors reported by the server in successful response
                     setError(data.error);
                     resultsContent.classList.add('hidden');
                } else {
                    processedModelNameDisplay.textContent = data.processed_model_name || modelName;
                    tokenCountDisplay.textContent = data.token_count || 0;
                    tokenVisContent.innerHTML = data.tokens_html || '';
                    setSuccess(); // Show results, hide status messages
                }

            } catch (error) {
                 if (error.name === 'AbortError') {
                    console.log('Fetch aborted.');
                 } else {
                    console.error("Fetch error:", error);
                    setError(`Error: ${error.message}`);
                    resultsContent.classList.add('hidden');
                 }
            } finally {
                 if (currentRequestController && signal === currentRequestController.signal) {
                    currentRequestController = null;
                 }
            }
        }

        // --- UI State Management Functions ---
        function setInitialPrompt(message) {
            statusMessageArea.classList.remove('hidden');
            initialPrompt.textContent = message;
            initialPrompt.classList.remove('hidden');
            loadingIndicator.classList.add('hidden');
            errorDisplay.classList.add('hidden');
            resultsContent.classList.add('hidden'); // Ensure results are hidden
        }

        function setLoading() {
            statusMessageArea.classList.remove('hidden');
            loadingIndicator.classList.remove('hidden');
            initialPrompt.classList.add('hidden');
            errorDisplay.classList.add('hidden');
            resultsContent.classList.add('hidden'); // Hide results while loading
        }

        function setError(message) {
            statusMessageArea.classList.remove('hidden');
            errorDisplay.textContent = message;
            errorDisplay.classList.remove('hidden');
            initialPrompt.classList.add('hidden');
            loadingIndicator.classList.add('hidden');
            resultsContent.classList.add('hidden'); // Hide results on error
        }

        function setSuccess() {
            statusMessageArea.classList.add('hidden'); // Hide all status messages
            errorDisplay.classList.add('hidden');
            initialPrompt.classList.add('hidden');
            loadingIndicator.classList.add('hidden');
            resultsContent.classList.remove('hidden'); // Show the results content area
        }

        // --- Event Listeners ---
        const debouncedUpdate = debounce(updateTokenization, 400); // 400ms debounce
        modelNameInput.addEventListener('input', debouncedUpdate);
        textInput.addEventListener('input', debouncedUpdate);

        // --- Initial Page Load State ---
        if (!textInput.value) {
            setInitialPrompt("Enter text above to see tokenization.");
        } else if (!modelNameInput.value) {
             setError("Please enter a Hugging Face model name.");
        }
        else {
            // If both fields have content on load, trigger an initial tokenization
            console.log("Initial content detected, triggering update on load.");
            updateTokenization();
        }

    </script>

</body>
</html>
"""

# --- Flask Route for Initial Page Load (Unchanged) ---
@app.route('/', methods=['GET'])
def index():
    # Provides default values for the template on initial load
    return render_template_string(
        HTML_TEMPLATE,
        model_name='Qwen/Qwen2.5-0.5B', # Default model
        text_input='',          # Default empty text
        # Results are handled by JS now
        hf_version=transformers_version
    )

# --- Flask Route for Live Tokenization (AJAX - Refined Error Handling) ---
@app.route('/tokenize_live', methods=['POST'])
def tokenize_live():
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    data = request.get_json()
    model_name = data.get('model_name', '').strip()
    text_input = data.get('text_input', '') # Preserve whitespace in text

    if not model_name:
        # Return error in JSON, but with 200 OK status as the request itself was handled
        # Client-side JS will check the 'error' field
        return jsonify({"error": "Model Name cannot be empty."}), 200

    # No need to check for empty text_input here, handle it gracefully (0 tokens)

    try:
        tokenizer = get_tokenizer(model_name) # Handles caching and loading errors
        tokens_html, token_count = generate_token_html_with_colors(tokenizer, text_input)

        return jsonify({
            "processed_model_name": model_name,
            "tokens_html": tokens_html,
            "token_count": token_count,
            "error": None # Success
        }), 200

    except (OSError, ValueError, KeyError, Exception) as e:
        # Handle errors during tokenizer loading or token generation
        error_message = f"{str(e)}" # Use the exception message directly
        # More specific message for common loading error
        if isinstance(e, OSError) and ("not found" in str(e).lower() or "no such file" in str(e).lower() or "repository not found" in str(e).lower()):
             error_message = f"Model '{model_name}' not found or unavailable. Check spelling and Hugging Face Hub status."

        logging.error(f"Error in /tokenize_live for '{model_name}': {e}", exc_info=False) # Log less verbosely unless debugging
        # Return error details in JSON, but still with 200 OK status
        # The client JS is responsible for displaying the error based on the 'error' field
        return jsonify({"error": error_message}), 200


# --- Run the App (Unchanged) ---
if __name__ == '__main__':
    print(f"Starting Flask server for Live Tokenizer (v2 Style)...")
    print(f"Using Transformers version: {transformers_version}")
    print(f"Visit http://127.0.0.1:5000 (or your host IP)")
    app.run(host='0.0.0.0', port=5000, debug=True, use_reloader=False)