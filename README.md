# 7T-visual-code

visual stim code for the 7T, laptop, VPixx, etc.

## General (shareable) material

Go to the [docs folder](./docs/) which is also published to the github pages.


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

```bash
# remember to run matlab w/o desktop for MGL
matlab -nodesktop
```

Running MGL code is possible, although it requires re-plugging DVI and USB cables into the `VPixx` setup, so not advisable.

## Setting up VPixx / debugging code on `macOS`

To get some code running under `macOS` for developing away from console room requires dealing with `Psychtoolbox`/`macOS` madness.

- [Some setup notes](./docs/macos-notes.md) to make reproducing this easier.