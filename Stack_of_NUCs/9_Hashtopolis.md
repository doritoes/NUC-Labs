# Hashtopolis
Cyber security professionals use [Hashtopolis](https://hashtopolis.org/) to create a cluster of systems running Hashcat, a versatile password hash cracking tool. Intel NUCs don't have the power for executing proper audits, but this is a great hands-on learning experience.

It is important to discuss GPUs at this point.
  * hashcat is no longer CPU-only; it uses GPUs and CPUs via OpenCL
  * if your NUCs have a supported GPU, great it; otherwise you will be using OpenCL and CPU
    * in my lab this worked out to only 61039 kH/s for md5 and 330 H/s for mode 1880 (Unix)
  * if you have an NVIDIA GPU install hashcat-nvidia for better performance
  * because of this complexity, we are installing the ''hashcat'' package and its requirements instead of the traditional hashtopolis way of simply copying the binary and running it

There are two pieces to set up:
- server
  - central server distributes the keyspace of a task, aggregates jobs, and collects results in MySQL database
  - communicates over HTTPS with agent machines
  - passes over files, binaries and task commands
- agents
  - act on the commands, execute the hash cracking application, and report "founds" to the server

Purpose:
- Demonstrate running a cluster of hash cracking nodes managed with Ansible

References:
- https://github.com/hashtopolis
- https://jakewnuk.com/posts/hashtopolis-infrastructure/
- https://github.com/peterezzo/hashtopolis-docker
- https://resources.infosecinstitute.com/topic/hashcat-tutorial-beginners/
- https://infosecscout.com/install-hashcat-on-ubuntu/

🚧 To be continued...

## Create a project folder for Hashtopolis
## Install Server
## Configure Hashtopolis Server
## Generate Voucher Codes
## Install Agents
## Confirm Agents are Up and Running
## Create Sample md5 Password Hashes
## Create Tasks to Crack the Hashes
## Uninstall Hashtopolis

## Learn More
Try cracking other Hashes

### Ubuntu
### Windows
