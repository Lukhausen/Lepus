# Chain-of-Thought Prompting Pattern for Creating Synthetic Data

Example: [open in ChatGPT](https://chatgpt.com/share/670ecf86-2b14-8008-980e-6fa782b271b1)
This pattern breaks down complex queries into atomic steps, encouraging detailed analysis and creative thinking. The process should repeat at least 3 times before introduction the conclusion possibility.

## Prompt Structure

1. **Initial Prompt**
   ```
   Investigate the following query: "[Insert query here]"  
   To formulate an informed answer, break this task down into as many steps as possible. Only output the first atomic step you would take. Be very meticulous in your approach.
   ```

2. **Execution Prompt**
   ```
   Now do this step. Be as detailed as possible in your explanation and execution of that step. Output every thought and idea. Only focus on the execution of the current step. Do not think about further steps right now.
   ```

3. **Next Atomic Step Prompt**
   ```
   What would be the next atomic step?
   ```

4. **Execution of Next Step**
   ```
   Now do this step. Be as detailed as possible in your explanation and execution of that step. Output every thought and idea. Only focus on the execution of the current step.
   ```

5. **Creativity/Innovation insertion Prompt** (Use occasionally)
   Append the typical Next Atomic Step Prompt.
   ```
   What would be the next atomic step? Be creative in your approach.
   ```
   add something like
   `Be creative in your approach.` or `Be innovative in how you approach this.` or `Approach this in an unexpected way`
   The Core Idea is to encourage creativity and out-of-the-box thinking to come to better solutions.
   

7. **Repeat** steps 3-5 until giving the LLM the possibility to Finalize.

8. **Finalization Prompt**
   ```
   What would be the next atomic step? If the Last Response was the final Answer just print "FINAL."
   ```



# Notes
I tried this with GPT 4o and it worked flawlessly, even replicating the style and approach of o1, but when trying it on the way dumber LLaMa 3.1 8B It struggled to understand the Query. Maybe more emphasis on Query Understanding is needed.
