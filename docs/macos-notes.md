# `macOS` setup notes

## Issues

`Psychtoolbox` does not deal well with recent version of `macOS`, and especially running on the ARM chips. We don't actually want to run mission critical code on the 7T console from Psychtoolbox. `mgl` is a really good alternative, but would require a couple of fixes to integrate with `VPixx`, as button response and scanner trigger come through a different route (note `HID` / `USB` but the digital in ports from `VPixx/ResponsePixx`)... eiether way, for coding and testing, we want to be able to run things on Apple MacBooks with the new Apple Silicon, as many people, including students have those as their main work horse computers.

## Things to do, to get things running.

- Download recent version of `Psychtoolbox` (see [github repo](https://github.com/Psychtoolbox-3/Psychtoolbox-3/tree/3.0.19.7))

```matlab
>> PsychtoolboxVersion
ans =
'3.0.19 - Flavor: Manual Install, 26-Feb-2024 17:27:13'
% and matlab itself

>> ver
----------------------------------
MATLAB Version: 9.10.0.1739362 (R2021a) Update 5
MATLAB License Number: 646274
Operating System: macOS  Version: 14.3.1 Build: 23D60
```

- <strong>Important</strong>: ARM-architecture matlab / octave won't play nicely with `Psychtoolbox`. Make sure you run the (old-style) `Intel` versions via Rosetta (MK says on the website this make timing not usable for experiments, but for hacking up code remotely this is good.)
![](./images/matlab-arch.png)

- equivalent for `octave`
  - install `brew` (https://brew.sh/)
  - look for `octave` versions in the past:

```bash
brew search octave
```

We actually need to do some backflips to get `x84_64` binaries of octave through brew ( [see this article](https://www.wisdomgeek.com/development/installing-intel-based-packages-using-homebrew-on-the-m1-mac/) ), so let's check if we can jsut download the binaries for octave another way :grimacing: 

- **nope**... won't work, so back to the *two homebrew* versions

```bash
# .... 
octave 8.4.0_2 is already installed but outdated (so it will be upgraded).
Error: Cannot install under Rosetta 2 in ARM default prefix (/opt/homebrew)!
To rerun under ARM use:
  arch -arm64 brew install ...
To install under x86_64, install Homebrew into /usr/local.
```
 
## get a `Rosetta` flavour shell

```bash
arch -x86_64 zsh
cd /usr/local && mkdir homebrew
curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
```

You may have to `sudo mkdir homebrew` in that folder and `chmod a+rw` to get the `curl` command to run.

After that's successfully installed, we can now do the following (**on my machine, recompiling `gcc` and `octave` took - literally - hours, so make some coffee ;)**

```bash
# get the version control svn for rosetta first
arch -x86_64 /usr/local/homebrew/bin/brew install svn
# then octave install should work
arch -x86_64 /usr/local/homebrew/bin/brew install octave
```

and now we should be able to run `octave` in `x86_64` (rosetta), which will then in turn make Psychtoolbox binaries work ok (we hope!!)


On my machine, there are then two `octave` installs. One for each architecture. To run the `Psychtoolbox` compatible one:

```bash
arch -x84_64 /usr/local/homebrew/bin/octave
```
### For multimedia / video

Need to install version of `GStreamer` <https://gstreamer.freedesktop.org/download//#macos>. Apparently `arch` is ok to be `x86_64?` (will this play nicely with intel code running octave?)


## Notes / video log
### Basic install

- [short recording of testing](https://www.youtube.com/watch?v=4B3s1_dK_DA) - youtube clip of looking at demos on an M1 mac / laptop

{% include youtube.html id="4B3s1_dK_DA" %}


