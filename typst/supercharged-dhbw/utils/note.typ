// Define a custom styled note function
#let note(content) = {
  block(
    width: 100%,
    fill: rgb(245, 245, 245),
    radius: 4pt,
    stroke: rgb(230, 230, 230),
    inset: 10pt,
  )[
    #set text(
      style: "italic",
      size: 11pt,
    )
    #align(left)[
      #text(
        size: 8pt,
        weight: "medium",
        fill: rgb(120, 120, 120),
        "Note"
      )
    ]
    #content
    

  ]
}