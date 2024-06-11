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
- the preferred way of driving the system is under Linux\`ubuntu` through `gnu/octave` 
- we have also installed and checked `PsychoPy` under Windows, which works well.
- switching the projector on/off is via software. You can use the `PyUtil` tool under both `ubuntu` and `Windows` partitions or `vputil` command in Terminal.


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

## Initial vision experiment for `UHFVIS` project

Some notes and a [scanning-readme](./vision-experiment.md) for getting off the ground.

## Documentation from `VPixx` website 

Trying out a couple of provided demos to test digital IO and also ProPIXX display capabilities:

<https://www.vpixx.com/manuals/psychtoolbox/html/intro.html>

## Contact

For now: <denis.schluppeck@nottingham.ac.uk>
