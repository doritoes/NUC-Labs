# Prepare Ubuntu Server
- 100GB is fine
- RAM: at least 4GB to 8GB
- CPU at least 2 to 4 vCPUs

Splunk compresses data at roughly a 50% ratio, so that space allows you to ingest hundreds of gigabytes of logs over time before you even have to think about "retention policies."

Ubuntu 24.04 is a solid host, but it’s "too efficient" out of the box for Splunk. You need to "loosen" the OS restrictions so Splunk can handle thousands of small log files simultaneously.

1. Pre-Installation: System Tuning
Run these steps before you install the Splunk .deb package to avoid the "Yellow Warning" banners in the Splunk UI.

A. Disable Transparent Huge Pages (THP)
THP is a Linux memory management feature that causes significant performance "stuttering" for database-like apps like Splunk.

Create a systemd service to disable it on every boot: sudo nano /etc/systemd/system/disable-thp.service

Paste this in:


[Unit]
Description=Disable Transparent Huge Pages (THP)
[Service]
Type=oneshot
ExecStart=/bin/bash -c "echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled && echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag"
[Install]
WantedBy=multi-user.target


Enable and start it: sudo systemctl daemon-reload && sudo systemctl enable --now disable-thp.service


B. Increase "ulimits" (Open File Limits)
Splunk keeps many "buckets" (files) open at once. The default Ubuntu limit (1024) is way too low.

Edit the limits file: sudo nano /etc/security/limits.conf

Add these lines to the very bottom:


* soft nofile 65535
* hard nofile 65535
* soft nproc 20480
* hard nproc 20480

(Note: The * applies to all users. If you create a specific splunk user later, you can replace the * with splunk.)


