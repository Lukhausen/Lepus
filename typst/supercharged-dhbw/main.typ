#import "@preview/supercharged-dhbw:3.4.0": *
#import "acronyms.typ": acronyms
#import "glossary.typ": glossary
//#import "chapters/arcprize.typ": arcprize
//#import "chapters/introduction.typ": introduction
//#import "chapters/previouse_methods.typ": previouse_methods
//#import "chapters/preparing_data.typ": preparing_data
//#import "chapters/our_approach.typ": our_approach


#import "chapter_new/introduction.typ": introduction
#import "chapter_new/background.typ": background
#import "chapter_new/methodology.typ": methodology
#import "chapter_new/experimental.typ": experimental
#import "chapter_new/results.typ": results
#import "chapter_new/conclusion.typ": conclusion


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

//Defining the quote block estetics
#set quote(block: true)
#show quote: set pad(x: 3em)


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

// Chapter 1: Introduction (
// Research question and motivation
// Significance of the work
// Brief overview of approach and contributions)
//#introduction


// Chapter 2: ARC Prize
//#arcprize

// Chapter 3: Previous Methods
//#previouse_methods


// Chapter 4: Our Approach (Deepseek)
//#our_approach

// Chapter 5: Preparing Data: Making shit avcailable to hugginface, chosing prompt
//#preparing_data

//How did our server work? what gpu did we try and failed with and tried again bla bla bla. what do the parmater do

//reward model: Mathematical forms

//evaluating model, how to evaluate model train sucess

//Lessons learned (improvments e.g. though post train improvmenet like ARcitects)

//conclusion 


//Introduction
#introduction

//Background
#background

//Methodology
#methodology

//Experimental
#experimental

//Results
#results

//Conclusion
#conclusion

