# Typst Installation and Usage in VS Code for Windows

## Installation

1. Open PowerShell or Command Prompt as Administrator.
2. Install Typst using the following command:
   ```bash
   winget install Typst.Typst
   ```
3. Restart VS Code if it is already open.

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