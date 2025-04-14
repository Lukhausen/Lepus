#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction

#let our_approach = [
= Our Approach

All curretnt opensource approcahes relie soley on the direct inferencing without any Chain of though or intermediate reasoning steps. tjhe ARCitect, Ice Cuber, as well as all other open source approchaes present on the leaderboard had no measures in place, that actually tried extract the reasoning part and logical thinking requried to solve an arc task. Yet, as we can clearly see on the benchmark pubkishged by ARC (see @arc_leaderboard) that reasoning model like openais o1 or o3 score higher out of the box than non reasoning models.

This is due to their capability of test time compute. Their traing was structred in a way that made them not directly complete a input prompt with an output prompt but to have an intermediade step in which they use chain of though to reason about what they should answer.


]
