# First local test

1. Clone this feature branch: `git clone -b feature/boxing-motion-lab https://github.com/freeski070605/Exit6GlovesUpGunsDown.git`.
2. Install Rojo 7.x, run `rojo serve` from the repo root and connect the Rojo Studio plugin to a blank Roblox place.
3. In Studio use Test > Start with two players. Move them within 4 studs, facing each other.
4. Xbox: left stick moves, right stick flicks left/right/up/down for jab/cross/hook/uppercut; face buttons also trigger punches. RT guards. Keyboard: 1-4 punch, F guard, Q/E slip.
5. Check player attributes `BoxingStamina` and observe health damage; guard reduces damage and slip temporarily avoids it.
6. This is a combat NETWORKING SCAFFOLD, not a finished fighting game. There are no punch animations, body modifier effects, full collision tracing, rounds, matchmaking or spectator AI yet.
7. Record issues, especially hit validation, latency, and right-stick responsiveness. Do not merge into main until tested.
