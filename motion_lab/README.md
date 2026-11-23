# Boxing Motion Lab

Two complementary footage sources:
1. Permission-cleared stable training footage: extract actual movement for original animation clips.
2. Professional match footage: analyze timing, range, combinations, strategy and defensive patterns; do not reproduce protected footage, likenesses or proprietary game animation.

First capture set: jab, cross, lead hook, rear uppercut, slip left, slip right. Prefer full-body fixed-camera recordings, multiple angles, 30+ FPS, clearly visible joints.

Pipeline: footage inventory -> MediaPipe pose landmarks -> quality review/occlusion correction -> Blender cleanup and rig retargeting -> FBX or glTF -> Roblox Animation Editor -> publish assets -> Xbox combat tests.

Roblox import documentation: https://create.roblox.com/docs/animation/editor
Do not commit copyrighted footage, large binaries or private source recordings to this public repo. Store raw media outside Git; only approved derived assets and metadata go here.
