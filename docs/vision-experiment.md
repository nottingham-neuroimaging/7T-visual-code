# Vision experiments

2024-05-17, ds

## Some suggestions for v1.0 of getting data

Feel free to add, chop, change (esp re BO maps, noise scansm etc) - just putting down some ideas for stimuli, order etc that I think will work well first time around.

**Ethics:** Developement ethics. SPMIC. @Sue.

**Project:** UHFVIS / UHFVIS UHF scheme (14h)

Plan for around ~10min of setup at start.


1. anatomy et al scans
    - PSIR / MP2RAGE, 1mm isotropic or higher-res (X minutes) 
    - T2* high-res? (at end?)
    - B0? field map or `topup` versions with PE direction flipped on two scans

2. functional stuff

    - **2d GE-EPI**, visual cortex coverage, 1mm isotropic, MB factor=?, ~TR=? TE=25ms, # slices

    - ~4 min duration (to keep participants awake?)

    - include noise scan for NORDIC
    - add tSNR scan (10 dynamics, no stim?)

    - could try **3d GE-EPI**, visual cortex coverage, <1mm isotropic?, ~TR=? TE=25ms, coverage?

## Stimuli

Visual stim code hosted at https://github.com/schluppeck/7T-visual-code (email me for renewing invites, if you are interested in the details / VPIXX stuff...)


Timings around [12s rest, 12s stim] to [15s rest, 15s stim]. Synced to multiples of TR (as per usual).

- block design rArA (flickering checkerboard, motion vs static)
- block design rArB (faces v objects), (moving faces v static object, etc.)


