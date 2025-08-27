#import "@preview/supercharged-dhbw:3.4.0": *
#import "acronyms.typ": acronyms
#import "glossary.typ": glossary
//#import "chapters/arcprize.typ": arcprize
//#import "chapters/introduction.typ": introduction
//#import "chapters/previouse_methods.typ": previouse_methods
//#import "chapters/preparing_data.typ": preparing_data
//#import "chapters/our_approach.typ": our_approach


#import "chapters/introduction.typ": introduction
#import "chapters/background.typ": background
#import "chapters/experimental.typ": experimental
#import "chapters/results.typ": results
#import "chapters/conclusion.typ": conclusion
#import "chapters/reward.typ" : reward
#import "chapters/data_augumentation.typ": data_augumentation
#import "chapters/previouse_methods.typ": previouse_methods
#import "chapters/our_approach.typ": our_approach  
#import "chapters/terminology.typ": terminology
#import "chapters/abstract.typ": abstract
#import "chapters/use_of_ai.typ": use_of_ai
#import "chapters/post_training_benchmark.typ": post_training_benchmark
#import "chapters/limitations.typ": limitations
#import "chapters/chapter_authorship.typ": chapter_authorship


#show: supercharged-dhbw.with(
  title: "Evaluating Synthetic Chain-of-Thought via RL Fine-Tuning for ARC-AGI Problem Solving",
  authors: (
    (name: "Lukas Marschhausen", student-id: "1840227", course: "TINF22AI1", course-of-studies: "Applied Computer Science", company: (
      (name: "Cisco Systems GmbH", post-code: "65760", city: "Eschborn")
    )),
    (name: "Marc Schmengler", student-id: "1708015", course: "TINF22AI1", course-of-studies: "Applied Computer Science", company: (
      (name: "XYZ GmbH", post-code: "12345", city: "Berlin")
    )),

  ),
  acronyms: acronyms, // displays the acronyms defined in the acronyms dictionary
  at-university: false, // if true the company name on the title page and the confidentiality statement are hidden
  bibliography: bibliography(("bibliography/lukas_refs.bib", "bibliography/marc_refs.bib")),
  date: datetime.today(),
  glossary: glossary, // displays the glossary terms defined in the glossary dictionary
  language: "en", // en, de
  supervisor: (company: "-"),
  university: "Cooperative State University Baden-Württemberg",
  university-location: "Mannheim",
  university-short: "DHBW",
  show-confidentiality-statement: false,
  abstract: abstract,
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

#use_of_ai  

//Introduction
#introduction

#terminology
//Background
//#background
#background 

//Methodology
#previouse_methods  

#our_approach

//Data Augumentation
#data_augumentation


//Reward
#reward

//Experimental
#experimental

#post_training_benchmark

#limitations

//Conclusion
#conclusion


#chapter_authorship



