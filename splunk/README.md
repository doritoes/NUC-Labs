# Splunk Lab
The mission in this Lab is to build a home Splunk instance and practice working with it.

Mission:
- Install and Deploy Splunk on Unbuntu server
- Kick the tires on the environment
- Ingest firewall logs
- Was not able to get nautobot to work with VyOS or any of the lab gear to test further

Materials:
- NUC running Ubuntu server or a VM running Ubuntu server
- USB sticks
  - 1 USB sticks, 8GB or more to load Ubunutu on the NUC

# Overview
## Preparing the Server
Covers requirements for setting up the Ubuntu server - [Preparing the Ubuntu Server](1_Prepare_Ubuntu_Server.md)

## Installing Splunk and the Personal License
How to get the Splunk Developer License and install it - [Install Splunk](2_Install_Splunk.md)

## Jump in with Hands-On Labs
https://docs.splunk.com/Documentation/Splunk/latest/SearchTutorial/GetthetutorialdataintoSplunk

Phase 1: The "Buttercup Games" DatasetSplunk provides a famous sample dataset called tutorialdata.zip. It contains fake web server logs (Apache), secure logs, and vendor data. Using this ensures all students see the same results when following your instructions.Download the Data: Have students download the tutorialdata.zip file.Upload: In the Splunk UI, go to Settings > Add Data > Upload.Host Segmenting: During the "Input Settings" step, tell students to select Segment in path and enter 1. This teaches them how Splunk can automatically assign a "Host" name based on a folder structure.Phase 2: Fundamental Search LabOnce the data is in, give the students these five "Missions" to practice SPL (Search Processing Language):Mission 1 (The Basics): "Find all events where a purchase failed."Query: index=main status=503Mission 2 (Filtering): "Find all failed login attempts in the secure logs."Query: index=main sourcetype=linux_secure "failed password"Mission 3 (Pipe & Stats): "Show me the top 10 IP addresses that are visiting our site."Query: index=main | top limit=10 clientipMission 4 (Timecharting): "Create a line graph of web traffic over the last 24 hours."Query: index=main sourcetype=access_combined | timechart countMission 5 (Visualizing): Have them take the result of Mission 4 and click the Visualization tab to change it from a table to a Line Chart.Phase 3: Building the First DashboardStudents love seeing their work come to life.Have them run a search for successful purchases: index=main action=purchase status=200.Click Save As > Dashboard Panel.Name the dashboard "Security Operations Center" and the panel "Successful Sales."Encourage them to add a second panel showing "Failed Logins" from Mission 2.Phase 4: Setting the "SOC" Mindset (Alerting)Since you mentioned developing skills, teach them that a SIEM is "Passive" until you make it "Active."Exercise: "Create an alert that emails you (or triggers a notification) if more than 5 failed logins occur within 1 minute."Process: Run the search index=main "failed password", then click Save As > Alert. Set the trigger condition to "Greater than 5" within a "Rolling Window of 1 minute."Summary of Student Lab ObjectivesSkillLab ActionData OnboardingUploading .zip logs and defining sourcetypes.InvestigationUsing keywords to find specific error codes ($404$, $500$, $503$).ReportingUsing the stats and chart commands to summarize data.VisualizationConverting "Big Data" into readable Bar, Pie, and Line charts.



## Adding Logs
Installing the "Universal Forwarder" on your other machines so they can start sending their logs to Splunk

OPNsense

pfSense

NAS

## Basic Queries

## Advanced Queries

## Gotchas

## Learning More

## Cleanup and Next Steps
