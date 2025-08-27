#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction

#let conclusion = [
= Conclusion

This paper provides insights into developing reasoning capabilities in language models for abstract spatial reasoning tasks, particularly within the context of the ARC-AGI-2 benchmark. Through systematic experimentation with reinforcement learning techniques, we have identified several critical factors that influence the emergence and enhancement of reasoning behaviors in transformer-based architectures.

==  Summary of Contributions

First, we established that model capacity represents a fundamental constraint for developing sophisticated reasoning capabilities, consistent with the emergent abilities phenomenon described in scaling laws. Our experiments with 3B and 7B parameter models revealed limitations in their ability to develop emergent reasoning for complex spatial abstraction tasks without explicit guidance. This finding aligns with the scaling laws principle that certain cognitive capabilities may only emerge beyond specific parameter thresholds, representing qualitative phase transitions rather than gradual improvements.

Second, we demonstrated that structural elements surrounding the training process—particularly prompt engineering, data augmentation, and reward function design—significantly impact performance outcomes. Our targeted augmentation methodology expanded the original 1,000-task dataset to approximately 28,000 tasks through systematic geometric transformations and structural reorganizations, providing a more robust foundation for model learning.

Third, we identified and addressed the challenge of reward hacking, where models optimize for high reward scores without developing meaningful reasoning strategies. Through careful reward function engineering that separated structural assessment from content evaluation, we implemented a more nuanced training that better guided model development.

Fourth, our results provide evidence that reasoning behaviors can be effectively cultivated through structured incentive mechanisms. When natural emergence failed, we successfully induced deeper, more meaningful reasoning patterns by explicitly rewarding longer reasoning chains. This was not merely an encouragement of verbosity; the "kickstarted" model achieved a reward score of 0.22992, a substantial improvement over both the baseline model (0.12946) and a fine-tuned model that did not receive the kickstart incentive (0.15484). This demonstrates that cognitive capabilities can be methodically developed, leading to quantifiably better outcomes, rather than relying solely on spontaneous emergence.


== Key Methodological Insights

The reward function design proved absolutely critical. By evaluating structure and content separately, we created more precise training signals that balanced basic requirements with higher-level reasoning goals.
We also made improvements in tokenization efficiency. Our analysis of Qwen2.5's tokenization patterns helped us develop grid representations that used 62% fewer tokens while preserving all the structural information. This made training much more efficient.
When our initial approaches hit dead ends, we had to adapt. Our pivot to rewarding reasoning length first, then transitioning to content-focused rewards, helped guide our models through learning plateaus they otherwise couldn't overcome.

== Practical Implications
A really exciting aspect of our work is how accessible this kind of research has become. Our entire project cost only about €350 in on-demand cloud GPU resources, despite using hardware worth over €160,000. The fact that students can access this level of computing power is incredible.

Our benchmarking showed that thinking-enabled models are genuinely more versatile. The kickstarted thinking model achieved a reward score of 0.22992, significantly outperforming both the base model's 0.12946 and a fine-tuned model without the kickstart incentive, which scored 0.15484. While none of the models solved any ARC-AGI-2 problems fully, this marked improvement validates our kickstarting approach and demonstrates its effectiveness in cultivating meaningful reasoning.

In conclusion, not every model can become a reasoning model—it needs sufficient size and capability. But we've shown that with the right techniques, we can encourage models to develop more substantive reasoning chains that are better aligned with a task's objectives. There's definitely huge potential to improve performance on the ARC-AGI-2 benchmark with the post-training optimizations we've discussed.

]
