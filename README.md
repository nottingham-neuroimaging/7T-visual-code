# 7T-visual-code

visual stim code for the 7T, laptop, VPixx, etc.

## Potential code snippets

- `face_localiser/FFAlocaliser()` (needs `mglEditScreenParams()`)
- `scene_localiser/scene_localiser()` (needs some param fixes)

NB! `scene_localiser()` depends on local text file to stim order, etc. double check timings, how to input...

### 7T console room  settings + notes

```text
ip address: 10.156.192.150
username: vpixx
/home/vpixx/projects/7T-visual-code/ptb-code
# psychtoolbox is stored at
/usr/share/octave/site/m/psychtoolbox-3/
```

- todo: `VPixx` switch ON for projector... documentation
- todo: BNC connector? for getting TTL pulse from scanner
- todo: ...


### Documentation from `VPixx` website 

Trying out a couple of provided demos to test digital IO and also ProPIXX display capabilities:

<https://www.vpixx.com/manuals/psychtoolbox/html/intro.html>


### DS laptop

```bash
# remember to run matlab w/o desktop for MGL
matlab -nodesktop
```

```matlab
% for now (DAFNI code) - will pull out and github separately
cd ~/projects/7T-visual-code/face_localiser/
FFAlocaliser('debug=1')  % for small debug display
```

## Setting up VPixx / debugging code on `macOS`

To get some code running under `macOS` for developing away from console room requires dealing with `Psychtoolbox`/`macOS` madness.

- [Some setup notes](macos-notes.md) to make reproducing this easier.