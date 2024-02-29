# Analysis notes

2024-02-28, ds started

## Some `mrLoadRet` / `mrTools` info

`mrTools` and `mgl` have some interdependence, so recommended to install both:

- **use this** (julien besle's fork with some nottingham specific fixes) https://github.com/julienbesle/mrTools
- **use this** https://github.com/justingardner/mgl (the `mex` stuff will not work on ubuntu / windows without some v hard word, but there are some helper functions in `matlab` that are required)

- **for reference** - the Stanford/NYU repo: https://github.com/justingardner/mrTools

## Freesurfer

Also required for surface stuff... we rely on `freesurfer` segmentations (something to talk about at some point):

- https://surfer.nmr.mgh.harvard.edu/


## Data info

- Get the MSc data set from here (zip file to download) <https://tinyurl.com/2024-msc-data>
- you might also want to check out [this page with some details](https://schluppeck.github.io/dafni/firstAnalysis.html) from our "Data analysis for neuroimaging" class. There is some other stuff to go through for inspiration if you want... @Rowanhuxnotts