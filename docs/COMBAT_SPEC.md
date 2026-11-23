# Exit 6 | Gloves Up Guns Down — Combat Spec v0.1

## Goal
Full ChesterWorld city with skill-based outdoor boxing. Fight Night Champion is a quality benchmark, not a source of copied assets or code. Isolated combat prototype first; preserve original Exit 6.

## Input (Xbox first)
Left stick: footwork. Right stick: directional punches. RT: guard. LT: body modifier. LB + left stick: slips/rolls. Add alternative button layout and accessibility remapping.

## Simulation
States: Neutral, Moving, Guarding, Slipping, PunchStartup, PunchActive, PunchRecovery, Stunned, Knockdown, Clinch.

Client immediately animates and predicts presentation; server validates legal move, stamina, range, facing, timing and damage. Never trust client damage or hit declarations. Use swept hit volumes with lag-aware server validation, not simple Touched events.

## Initial moves
Jab, cross, lead hook, rear uppercut, slip left, slip right, high guard, low guard, step, pivot.

## Acceptance gate
Two Xbox players complete three rounds with reliable directional inputs, smooth transitions, useful defense and counters, consistent hit registration, and no major desync. Measure input-to-animation latency, server hit disagreement, frame rate and crowd load. No Fight Night quality claim until tested.

## City integration
Use approved ChesterWorld map assets, streamed neighborhoods, and priority simulation around active fights. The final game retains full-city walking and driving. No firearms in this boxing experience.
