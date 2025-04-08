# Typst Installation and Usage in VS Code for Windows

## Installation

1. Open PowerShell or Command Prompt as Administrator.
2. Install Typst using the following command:
   ```bash
   winget install Typst.Typst
   ```
3. Restart VS Code if it is already open.

### Font Installation
Note that Typst does not support variable font types. To ensure proper document rendering, you need to install the fonts provided in the `typst/fonts` directory:
1. Navigate to the `typst/fonts` directory in your project
2. Install all the provided font files (OpenSans and Montserrat variants)
3. These fonts are required for proper document rendering and styling

## VS Code Extension

1. Open VS Code.
2. Go to the Extensions view (Ctrl+Shift+X).
3. Search for "TinyMIST Typst" and install this extension.

## Usage

1. Open your Typst file (e.g., `main.typ`) in VS Code.
2. Press Ctrl+Shift+P to open the Command Palette.
3. Type "Typst" and select "Typst Preview: Preview Opened File."
4. The live preview will open, allowing you to see your changes in real time.
5. You can now work on your Typst file, and the preview will update automatically.
6. Click on the preview to jump to the corresponding section in your code.

With this setup, you can create, edit, and preview Typst documents in real time within VS Code.

## Modular Chapter Management

This project uses a modular approach for chapter management to enable collaborative work without merge conflicts:

1. **Chapter Structure**: 
   - Each chapter is defined in a separate file within the `chapters` directory
   - Use the pattern: `#let chapter_name = [chapter content]`

2. **Adding a New Chapter**:
   - Create a new Typst file in the `chapters` directory (e.g., `chapters/your_chapter.typ`)
   - Define a variable with your content: `#let your_chapter = [Your content here...]`
   - Import it in the main file: `#import "chapters/your_chapter.typ": your_chapter`
   - Insert it where needed using: `#your_chapter`

3. **Example**:
   - The ARC Prize chapter is imported from `chapters/arcprize.typ`
   - It's inserted in the document with `#arcprize`

This modular system makes it easier to collaborate on large documents by reducing conflicts when multiple people work on different chapters simultaneously.

## Working with Acronyms

This template provides a comprehensive set of functions to reference acronyms in your document. The main benefit is that the first mention of an acronym is automatically written out in full, while subsequent mentions are shortened to just the acronym.

For acronyms with special plural forms, use an array as the value:

```typst
#let acronyms = (
  API: ("Application Programming Interface", "Application Programming Interfaces"),
  HTTP: ("Hypertext Transfer Protocol", "Hypertext Transfer Protocols"),
)
```

If you don't specify a plural form, the template will automatically add an "s" to the singular form.

### Using Acronyms in Your Document

#### Primary Functions

These are the functions you should use in most cases:

- **`acr()`**: Reference an acronym in the text
  - First use: `acr("API")` → "Application Programming Interface (API)"
  - Subsequent uses: `acr("API")` → "API"

- **`acrpl()`**: Reference an acronym in plural form
  - First use: `acrpl("API")` → "Application Programming Interfaces (APIs)"
  - Subsequent uses: `acrpl("API")` → "APIs"

**Note:** It's strongly recommended to use `acr()` and `acrpl()` in most cases, as they automatically handle the full/short form switching for you.

#### Special Case Functions

The following functions are available for specific use cases where you need more control and should be used sparingly:

- **`acrs()`**: Always use the short form (e.g., `acrs("API")` → "API")
- **`acrspl()`**: Short form in plural (e.g., `acrspl("API")` → "APIs")
- **`acrl()`**: Always use the long form (e.g., `acrl("API")` → "Application Programming Interface")
- **`acrlpl()`**: Long form in plural (e.g., `acrlpl("API")` → "Application Programming Interfaces")
- **`acrf()`**: Always use the full form (e.g., `acrf("API")` → "Application Programming Interface (API)")
- **`acrfpl()`**: Full form in plural (e.g., `acrfpl("API")` → "Application Programming Interfaces (APIs)")

The acronyms referenced with these functions will be linked to their definitions in the list of acronyms that appears in your document.

## Working with LLM Interactions

This template provides a set of utility functions for displaying LLM (Large Language Model) interactions in your document. These utilities make it easy to present AI conversations with consistent styling and formatting.

### Core Functions

There are three main functions available in `utils/llm.typ`:

1. **`llm-input(content)`**: Creates a styled user input block
   ```typst
   #llm-input([How much is 2+2?])
   ```

2. **`llm-output(model: "Model", content)`**: Creates a styled model response block
   ```typst
   #llm-output(model: "GPT-4", [The sum of 2+2 is 4.])
   ```

3. **`llm-interaction(model: "Model", ...messages)`**: Creates an alternating conversation
   ```typst
   #llm-interaction(
     model: "Claude 3",
     [What is machine learning?],
     [Machine learning is a subset of artificial intelligence...],
     [How does it differ from traditional programming?],
     [In traditional programming, humans write explicit rules...]
   )
   ```

### Usage Patterns

#### Basic Input-Output Pair
```typst
#llm-interaction(
  model: "GPT-4",
  [What's the capital of France?],
  [The capital of France is Paris.]
)
```

#### Fine-grained Control
For more control, use the individual input and output functions:
```typst
#llm-input([What's the tallest mountain in the world?])
#llm-output(model: "Claude 3", [Mount Everest is the tallest mountain...])
```

#### Multi-turn Conversations
The `llm-interaction` function automatically alternates between user and model:
```typst
#llm-interaction(
  model: "GPT-4",
  [What is entropy?],
  [Entropy is a measure of disorder or randomness...],
  [How does this relate to information theory?],
  [In information theory, entropy quantifies the amount of uncertainty...]
)
```

The first message is treated as user input, the second as model output, the third as user input, and so on, creating a natural conversation flow with appropriate styling for each message.