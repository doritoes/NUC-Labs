# Appendix - Build VyOS ISO with VM Agents Installed
Reference: https://docs.vyos.io/en/latest/contributing/build-vyos.html

We will use Docker for this ISO build and run off the VyOS rolling release.

Install Prerequisites:
- `sudo apt install -y git curl`

Install docker
  - `curl -fsSL https://get.docker.com -o get-docker.sh`
  - `sh get-docker.sh`

Build the container that hosts the build environment:
- `git clone -b current --single-branch https://github.com/vyos/vyos-build`
- `cd vyos-build`
- add data/build-flavors/vmagents.toml
```
# VM Agents enabled (aka "universal") ISO image

image_format = "iso"

# Include these packages in the image regardless of the architecture
packages = [
  # QEMU and Xen guest tools exist for multiple architectures
  "qemu-guest-agent",
  "xen-guest-agent"
]

[architectures.amd64]
  # Hyper-V and VMware guest tools are x86-only
  packages = ["hyperv-daemons", "vyos-1x-vmware"]
```
- build container
  - `cd ~/vyos-build`
  - `sudo docker build -t vyos/vyos-build:current docker`
Build the ISO from source inside the container:
- `sudo docker run --rm -it --privileged -v $(pwd):/vyos -w /vyos vyos/vyos-build:current bash`
  - `cd /vyos`
  - `sudo make clean`
  - `sudo ./build-vyos-image --architecture amd64 --build-by "j.randomhacker@vyos.io" vmagents`
    - or without the vm agents
    - `sudo ./build-vyos-image --architecture amd64 --build-by "j.randomhacker@vyos.io" generic`
  - `exit`
- When the build is successful, the resulting iso can be found inside the build directory similr to vyos-1.5-rolling-202510072128-generic-amd64. On this host this is in  `~/vyos-build/build`
