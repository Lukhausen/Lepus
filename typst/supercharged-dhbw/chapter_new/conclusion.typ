#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction

#let conclusion = [
= Conclusion

This Paper provides insights into developing reasoning capabilities in language models for abstract spatial reasoning tasks, particularly within the context of the ARC-AGI benchmark. Through systematic experimentation with reinforcement learning techniques, we have identified several critical factors that influence the emergence and enhancement of reasoning behaviors in transformer-based architectures.

==  Summary of Contributions

First, we established that model capacity represents a fundamental constraint for developing sophisticated reasoning capabilities. Our experiments with 3B and 7B parameter models revealed limitations in their ability to develop emergent reasoning for complex spatial abstraction tasks without explicit guidance. This finding aligns with broader research indicating that certain cognitive capabilities may only emerge beyond specific parameter thresholds.

Second, we demonstrated that structural elements surrounding the training process—particularly prompt engineering, data augmentation, and reward function design—significantly impact performance outcomes. Our targeted augmentation methodology expanded the original 1,000-task dataset to approximately 28,000 tasks through systematic geometric transformations and structural reorganizations, providing a more robust foundation for model learning.

Third, we identified and addressed the challenge of reward hacking, where models optimize for high reward scores without developing meaningful reasoning strategies. Through careful reward function engineering that separated structural assessment from content evaluation, we implemented a more nuanced training that better guided model development.

Fourth, we discovered that reasoning behaviors can be effectively cultivated through structured incentive mechanisms. When natural emergence failed, we successfully induced deeper reasoning patterns by explicitly rewarding longer reasoning chains, demonstrating that cognitive capabilities can be methodically developed rather than relying solely on spontaneous emergence.


== Key Methodological Insights

The reward function design proved absolutely critical. By evaluating structure and content separately (inspired by MORLAIF research), we created more precise training signals that balanced basic requirements with higher-level reasoning goals.
We also made significant improvements in tokenization efficiency. Our analysis of Qwen2.5's tokenization patterns helped us develop grid representations that used 62% fewer tokens while preserving all the structural information. This made training much more efficient.
When our initial approaches hit dead ends, we had to adapt. Our pivot to rewarding reasoning length first, then transitioning to content-focused rewards, helped guide our models through learning plateaus they otherwise couldn't overcome.

== Practical Implications
A really exciting aspect of our work is how accessible this kind of research has become. Our entire project cost only about €350 in on-demand cloud GPU resources, despite using hardware worth over €160,000. The fact that students can access this level of computing power is incredible.

Our benchmarking showed that thinking-enabled models are genuinely more versatile. The thinking model achieved a reward score of 0.22992 compared to the base model's 0.12946. While neither model solved ARC problems perfectly, this improvement shows we're on the right track with our reasoning approach.

In conclusion, not every model can become a reasoning model - it needs sufficient size and capability. But we've shown that with the right techniques, we can encourage models to develop reasoning chains that actually work. There's definitely huge potential to improve performance on the ARC-AGI benchmark with the post-training optimizations we've discussed.

]
