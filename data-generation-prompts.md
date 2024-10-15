# Investigative Chain-of-Thought Prompting Pattern

This document outlines a prompt structure designed to break down queries into multiple atomic steps. The process involves a repeating pattern that ensures thorough analysis, with prompts encouraging detailed execution and creativity, followed by a finalization step.

The structure repeats at least 3 times before introducing the finalization prompt, and sporadic creativity prompts are included to diversify thinking.

## Prompt Structure

### 1. Initial Prompt

**When to use:** This prompt initiates the investigation by asking the LLM to break down the task into the first atomic step. The goal is to encourage meticulous thinking and avoid skipping ahead.

```
Investigate the following query: "[Insert query here]"  
To formulate an informed answer, break this task down into as many steps as possible. Only output the first atomic step you would take. Be very meticulous in your approach.
```

### 2. Execution Prompt

**When to use:** Once the LLM outputs the first atomic step, this prompt asks it to execute that step with detailed reasoning and explanation.

```
Now do this step. Be as detailed as possible in your explanation and execution of that step. Output every thought and idea. Only focus on the execution of the current step. Do not think about further steps right now.
```

### 3. Next Atomic Step Prompt

**When to use:** After completing one atomic step, this prompt asks what the next logical step should be. It keeps the chain of thought progressing step-by-step.

```
What would be the next atomic step?
```

### 4. Execution of Next Step

**When to use:** Once the next step is identified, this prompt calls for the detailed execution of that step, ensuring thorough reasoning at every stage.

```
Now do this step. Be as detailed as possible in your explanation and execution of that step. Output every thought and idea. Only focus on the execution of the current step.
```

### 5. Creativity/Innovation Prompt

**When to use:** Sporadically use this prompt after several steps to introduce creativity or innovation. It's meant to inject fresh thinking into the chain of thought process.

```
What would be the next atomic step? Be creative in your approach.
```
or
```
What would be the next atomic step? Be innovative in how you approach this.
```

### 6. Repeat the Pattern

**When to use:** Continue repeating the prompts in the same pattern (Step, Execution, Next Step) at least 3 times to ensure the task is broken down thoroughly. Use creativity or innovation prompts occasionally to keep the flow diverse and engaging.

### 7. Finalization Prompt

**When to use:** After repeating the atomic steps multiple times, introduce this prompt to evaluate whether the task has been completed or if there are more steps to take.

```
What would be the next atomic step? Or is this the Final Answer?
```

### 8. Final Step Prompt

**When to use:** This prompt is the last in the sequence and is used to confirm that the final answer has been reached. If the process is complete, the LLM should print "FINAL" to signify completion.

```
What would be the next atomic step? If the Last Response was the final Answer just print "FINAL."
```

## Summary of Steps

1. **Initial Prompt:** Begins the process by asking for the first atomic step.
2. **Execution Prompt:** Asks for a detailed execution of the atomic step.
3. **Next Atomic Step Prompt:** Queries for the next step in the sequence.
4. **Creativity/Innovation Prompt:** Injects variety and diverse thinking into the process.
5. **Repeat the Process:** Iterate this pattern at least 3 times before finalization.
6. **Finalization Prompt:** Asks whether the task is complete or if further steps are required.
7. **Final Step Prompt:** If the answer is complete, this prompt confirms it by outputting "FINAL."

This prompting pattern encourages meticulous breakdown of complex tasks, detailed execution, and innovative thinking while ensuring a clear final answer is reached. The process is designed to maintain a logical flow of thought while allowing for creative solutions when necessary.
