# Nautobot Lab
The mission in this Lab is to follow along with the book **Network Automation with Nautobot** (c) 2024 Packt Publishing

There are other ways to quickly deploy Nautobot using Docker or Kubernetes, for example:
- https://github.com/nautobot/nautobot-lab
- https://github.com/nautobot/nautobot-docker-compose
- https://github.com/nautobot/helm-charts

This Lab is focused on building an understanding of how the server works, and is based on the [official Nautobot docs](https://docs.nautobot.com/projects/core/en/stable/installation).

Want to learn more about nautobot in a hands-on challenge? Check out [100 Days of Nautobot](https://networktocode.com/blog/2025-01-17-100-days-of-nautobot/)

Commentary for the Home Labber:
- Nautobot is still very must a rough product for use by technologists with strong automation and/or programming skills
- Nautobot doesn't work well for a home lab. The IPAM solution is far too high maintenance, and doesn't integrate with a Windows server DNS/DHCP or firewall-based DNS/DHCP.
- Doesn't manage the "prosumer" gear, and not every labber is going to have Cisco or Arista in their lab. Incomplete Ubiquiti coverage, not enough for a useful lab.
- Tried to use the vyOS open source router without success

Commentary for the Business:
- You need a big network automation evangelist to dedicate the time and energy to reap the rewards
- Conversely, if you lose that person it could quickly fail

Mission:
- Install and Deploy Nautobot on Ubuntu server
- Kick the tires on the environment
- Was not able to get nautobot to work with VyOS or any of the lab gear to test further

Materials:
- NUC running Ubuntu server or a VM running Ubuntu server
- USB sticks
  - 1 USB sticks, 8GB or more to load Ubuntu on the NUC

# Overview
## Installing and Deploying Nautobot
Chapter 3 from the book steps through setting up our first Nautobot server. It also assist in setting up necessary items as you get started.
- [Install Nautobot](1_Install_Nautobot.md)

TIP Chapter 10 has quicker and more concise instructions if that works better for you.

## Installing and Deploying Nautobot
Chapters 3 and 10 continue to help set up some necessary items before we get started.
- [Initial Configuration](2_Initial_Configuration.md)

## Configuring a VyOS Router
In this set we set up a VyOS virtual router so we can test configuring it using Nautobot.
- [VyOS Router](3_VyOS_Router.md)

## Adding Devices
In this step, devices are added.
- [Adding Devices](4_Adding_Devices.md)

## IP Addressing
In this step, IP addressing is set up.
- [IP Addressing](5_IP_Addressing.md)

## Cabling
In this step, cables are configured.
- [Cabling](6_Cabling.md)

## Dynamic Inventory
In this step, an example dynamic inventory is tested
- [Dynamic Inventory](7_Dynamic_Inventory.md)


## Golden Config
https://docs.nautobot.com/projects/golden-config/en/latest/

## Cleanup and Next Steps
When you are done working with nautobot, simply delete the docker container/VM or erase the NUC.
