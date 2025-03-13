#import "@preview/supercharged-dhbw:3.4.0": *
#import "acronyms.typ": acronyms
#import "glossary.typ": glossary
#import "chapters/arcprize.typ": arcprize
#import "chapters/introduction.typ": introduction

#show: supercharged-dhbw.with(
  title: "Exploring the Impact of Synthetic Chain-of-Thought Fine-Tuning on LLM Reasoning Abilities",
  authors: (
    (name: "Lukas Marschhausen", student-id: "1840227", course: "TINF22AI1", course-of-studies: "Applied Computer Science", company: (
      (name: "Cisco Systems GmbH", post-code: "65760", city: "Eschborn")
    )),
    (name: "Marc Schmengler", student-id: "1234567", course: "TINF22AI1", course-of-studies: "Applied Computer Science", company: (
      (name: "XYZ GmbH", post-code: "12345", city: "Berlin")
    )),

  ),
  acronyms: acronyms, // displays the acronyms defined in the acronyms dictionary
  at-university: false, // if true the company name on the title page and the confidentiality statement are hidden
  bibliography: bibliography("sources.bib"),
  date: datetime.today(),
  glossary: glossary, // displays the glossary terms defined in the glossary dictionary
  language: "en", // en, de
  supervisor: (company: "-"),
  university: "Cooperative State University Baden-Württemberg",
  university-location: "Mannheim",
  university-short: "DHBW",
  // for more options check the package documentation (https://typst.app/universe/package/supercharged-dhbw)
)

// Modular Chapter Import System
// This document uses a modular approach for chapter management to enable collaborative work without merge conflicts.
// Each chapter is defined in a separate file within the "chapters" directory using the pattern:
//   #let chapter_name = [chapter content]
// 
// To add a new chapter:
// 1. Create a new Typst file in the "chapters" directory (e.g., "chapters/your_chapter.typ")
// 2. Define a variable with your content: #let your_chapter = [Your content here...]
// 3. Import it in this main file: #import "chapters/your_chapter.typ": your_chapter
// 4. Insert it where needed using: #your_chapter

// Chapter 1: Introduction
#introduction

// Chapter 2: ARC Prize
#arcprize

= Quellen

https://www.forwardfuture.ai/p/the-magic-of-prolonged-thinking-test-time-compute-part-2

https://medium.com/thedeephub/test-time-training-ttt-a-new-approach-to-sequence-modeling-8baf1ea79ed7

https://nanonets.com/blog/what-is-test-time-training/

https://www.ibm.com/de-de/topics/chain-of-thoughts

https://the-decoder.de/deeper-insights-fuer-ki-sprachmodelle-mit-chain-of-thought-prompting-als-erfolgsfaktor/

https://aws.amazon.com/de/what-is/hyperparameter-tuning/

https://www.entrypointai.com/blog/fine-tuning-hyperparameters/

https://www.ibm.com/de-de/topics/deep-learning

https://epoch.ai/blog/scaling-laws-literature-review

https://medium.com/sage-ai/demystify-transformers-a-comprehensive-guide-to-scaling-laws-attention-mechanism-fine-tuning-fffb62fc2552