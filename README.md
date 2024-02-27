# 7T-visual-code

visual stim code for the 7T, laptop, VPixx, etc.

## Potential code snippets

- `face_localiser/FFAlocaliser()` (needs `mglEditScreenParams()`)
- `scene_localiser/scene_localiser()` (needs some param fixes)

NB! `scene_localiser()` depends on local text file to stim order, etc. double check timings, how to input...

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