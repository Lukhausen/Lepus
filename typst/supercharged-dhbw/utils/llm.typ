// LLM conversation components for displaying interactions with language models

// Input block with user message
#let llm-input(content) = block(
  width: 100%,
  fill: rgb("#FFFDF5"),
  stroke: none,
  radius: 4pt,
  inset: (x: 12pt, y: 10pt),
  [
    #text(weight: "medium", size: 0.9em, fill: rgb("#62574A"), [User])
    #v(5pt)
    #text(fill: rgb("#000000"), [#content])
  ]
)

// Output block with model response
#let llm-output(model: "Model", content) = block(
  width: 100%,
  fill: rgb("#EFF8FF"),
  stroke: none,
  radius: 4pt,
  inset: (x: 12pt, y: 10pt),
  [
    #text(weight: "medium", size: 0.9em, fill: rgb("#3B5F8B"), [#model])
    #v(5pt)
    #text(fill: rgb("#000000"), [#content])
  ]
)

// Conversation with automatic alternating between user and model
#let llm-interaction(model: "Model", ..messages) = block(
  width: 100%,
  inset: 0pt,
  outset: (y: 10pt),
  breakable: true,
  [
    #for (i, message) in messages.pos().enumerate() {
      if i > 0 { v(8pt) }
      
      if calc.even(i) {
        // Even positions (0, 2, 4...) are user messages
        if type(message) == "dictionary" and message.keys().contains("content") {
          llm-input(message.at("content"))
        } else {
          llm-input(message)
        }
      } else {
        // Odd positions (1, 3, 5...) are model responses
        if type(message) == "dictionary" {
          let msg_model = message.at("model", default: model)
          let msg_content = message.at("content", default: message)
          llm-output(model: msg_model, msg_content)
        } else {
          llm-output(model: model, message)
        }
      }
    }
  ]
) 