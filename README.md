# 7T-visual-code

visual stim code for the 7T, laptop, VPixx, etc.

## General (shareable) material

Go to the [docs folder](./docs/) which is also published to the github pages.

## Samples of `Psychtoolbox` code and related resources

Go to the [ptb-folder](./ptb-code). Make sure you add `MatlabUtilies` to your path for the code in there to pick up the dependencies.

### 7T console room  settings + notes

```text
username: vpixx
/home/vpixx/projects/7T-visual-code/ptb-code
# psychtoolbox is stored at
/usr/share/octave/site/m/psychtoolbox-3/
```

### Documentation from `VPixx` website 

Trying out a couple of provided demos to test digital IO and also ProPIXX display capabilities:

<https://www.vpixx.com/manuals/psychtoolbox/html/intro.html>

### macOS laptops

This is mostly relevant for coding up experiments off-site, as the console room computer is set up for Windows11/Ubuntu.

```bash
# remember to run matlab w/o desktop for MGL
matlab -nodesktop
```

To get some code running under `macOS` for developing away from console room requires dealing with `Psychtoolbox`/`macOS` madness.

- [Some setup notes](./docs/macos-notes.md) to make reproducing this easier. There are instructions on how to get the free/open `octave` to run with the correction version for Psychtoolbox code.

Running MGL code is possible, although it requires re-plugging DVI and USB cables into the `VPixx` setup, so not advisable.



