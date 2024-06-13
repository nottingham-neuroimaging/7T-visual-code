# `VPixx` system on the 7T

This page provides information and some visual stimulus code for the 7T, notes for running frm the  `VPixx` system on the dedicated machine with `octave`+`Psychtoolbox` under the `ubuntu` install. 

<center>
<img src="./assets/7t-movie-stim.gif" width="100%"/>
<caption>
Coding on macOS (`x86_64` version of `octave`)
</caption>
</center>

## General points

- we have a `PROPixx` display system with audio, button boxes, analogue and digital I/O
- the projector lives in the scanner room in a shielded box
- one way of driving the system is under Linux\`ubuntu` through `gnu/octave` 
- we have also installed and checked `PsychoPy` under Windows, which works well.
- switching the projector on/off is via software. You can use the `PyUtil` tool under both `ubuntu` and `Windows` partitions or `vputil` command in Terminal.

## What does it look like?

The setup is made up of a stack of hardware blocks (PROPixx, ResponsePixx, ...) - there are two screens / one mirrors what the participant sees.

<p float="left">
    <img alt="Setup in console rool" src="./assets/whole-setup.png" width="32%"/>
    <img alt="Back of the VPixx setup" src="./assets/back-of-vpixx.png" width="32%"/>
    <img alt="The mirror system in situ" src="./assets/mirror-in-situ-2.png" width="32%"/>
</p>

The front surface mirror is positioned to project the image (from the `PROPixx` box on the left towards the participant in the bore).

This mirror is required inside the scanner room to redirect the projected image onto the display screen, which is suspended from the ceiling.

**Be very careful when moving the mirror into place** and avoid touching the mirror surface itself (it is a front surface mirror, so doesn't have a protective glass coating - finger prints can permanently damage it).


## Sample code for testing

- `SPMIC_demo_01` - grabs display, puts a yellow dot on the screen and moves it. For checking whether `VPixx` display gets picked up etc
- `SPMIC_demo_02` - simple implementation of a block design (static and moving faces, static objects, gray background). Timing can be adjusted pretty easily - has some opinionated suggestions on how to organise code.
- `ProceduralNoiseForObjects` - how to make dynamic noise using GPU (rather than pre-computed images and blitting them). Still needs some debugging re ALPHA blending to make it work with background suppression in movie / masked image stimuli
- `movie_test_{01,02}` - initial movie testing to check that movies can be loaded ok and display on screen. working.

## Triggering

Until we have figured out how to use the `DataPixx` for triggering we can rely on the USB reponse box for providng that trigger.

`KbDemo()` reports the Key "5" from the USB box, so can reuse simple `KbCheck` logic in a tight loop for triggering.

## To-dos (some physical)

- [x] add a second display for coding (current console room display mirrors projector). Done. Thanks to AP.
- [x] document minimal test code + examples
- [ ] document (SOP) for switching on/off projector, how to bring your own code, etc.
- [ ] test 45º mirror for projecting along line of bore + screen material
- [x] provide guidance to those wanting to write code away from console room (eg [coding / debugging on MacOS/Apple hardware](./macos-notes.md) requires some additional hoop-jumping)
- [ ] triggering via `ResponsePixx` system (cable in the works). Code that uses the Digital IN demo snippets from `VPixx` documentation.

## Initial vision experiment for `UHFVIS` project

Some notes and a [scanning-readme](./vision-experiment.md) for getting off the ground.

## Documentation from `VPixx` website 

Trying out a couple of provided demos to test digital IO and also ProPIXX display capabilities:

<https://www.vpixx.com/manuals/psychtoolbox/html/intro.html>

## Contact

For now: <denis.schluppeck@nottingham.ac.uk>
