# pyCGM2

fork from [pyCGM2](https://github.com/pyCGM2/pyCGM2) to be able to run on my arm Mac. This is by no means a stable build, but I hacked around and got it to work for `pyCGM2.Lib.CGM.cgm1` until `pyCGM2.Lib.CGM.cgm2_3`, by the time the models use IK fitting gets incredibly slow, so if you need those model I suggest you use a VM or find a way to build everything for arm - the btk repo that is cloned would build for arm, but I couldn't be bothered to also build OpenSim for arm.

to build:

```bash
docker build . -t pycgm2
```

to run:

```bash
docker run --platform linux/amd64 --rm pycgm2 python -c "import pyCGM2; print(pyCGM2.__version__)"
```
