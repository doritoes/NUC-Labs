# Hands-On Tutorial
Let's had a handle the Splunk basics by starting with the Tutorial. Splunk provides a famous sample dataset that contains fake web server logs (Apache)), secure logs, and vendor data.

## Import the "Buttercup Games" Dataset
1. Download the files files from [Splunk](https://help.splunk.com/en/splunk-enterprise/get-started/search-tutorial/10.0/part-1-getting-started/what-you-need-for-this-tutorial#id_00ebcad1_5243_445b_b1f1_e3a49fd8c759--en__Download_the_tutorial_data_files)
    - `tutorialdata.zip`
    - `Prices.csv.zip`
2. Upload the data files to Splunk
    - Log in to Splunk web UI
    - **Settings** > huge icon **Add Data**
    - Splunk offers a "tour" if you are curious
    - Click **Upload**
    - Select Source: Select the **turorialdata.zip** or draw/drop it then click **Next**
    - During the "Input Settings" step, select **Segment in path** and enter **1**
        - This is how Splunk can automatically assign a "Host" name based on folder structure
    - Click **Review** and review the settings
    - Click **Submit**
    - Click **Start Searching**
      - This automatically opens the search query: `source="tutorialdata.zip:*"`

## Jump in with Hands-On Introduction to Search
### Basic Search and Drill Down
Find all events where a purchase failed
- query: `index=main status=503`
  - Notice the hundreds of events
  - Note in the top search area that the time range is set to "All time". If you can't see any result that should be there, check the Time range and set back to **All time** for this Lab.
- On the left side notice the top item in Interesting Fields: **action**
  - Click on **action** to view different actions in the logs that had the 503 error
  - Click Selected: **Yes** and see how the "action" file is populated in the log fields
- Narrow search
  - Find a log entry showing "action = purchase", click **purchase**
  - Click **Add to search**
- Review the logs
  - What are the "hosts" in the logs? (try clicking on **host** under Selected Fields)

### Filtering
Find all failed login attempts in the secure logs
- query: `index=main sourcetype=secure* "failed password"`
- Review the logs returned
- Click the "V" to expand one of the log entries
- From the left side, try clicking on **host**, **source**, and **sourcetype**. This gives you and idea where the failed logins are happening

### Basic Statistics: Top Results
Show me the top 10 IP addresses that are visiting our site
- query: `index=main | top limit=10 clientip`
- Note you are on the **Statistics tab**. Click on the **Visualization** tab

### Timecharting
Create a line graph of web traffic over the last 24 hours
- query: `index=main sourcetype=access_combined* | timechart count`
- Note how the data is returned per date
- Note you are on the **Statistics tab**. Click on the **Visualization** tab
- From the small dropdown change the `Chart` from Column Chart to Line Chart

### Building the First Dashboard
1. Search for successful purchases: `index=main action=purchase status=200 | timechart count`
2. Click **Visualization**
3. From the small dropdown change the `Chart` from Column Chart to Line Chart
4. In the top search area, click **Save As** > **New Dashboard**
    - Close the dashboard type informational Window as necessary
    - Dashboard title: **Buttercup Games SOC**
    - Description: **Monitoring web purchases and security events**
    - Permissions: **Shared in App** so all users can see it
    - Dashboard type: **Classic Dashboards** (good for new users in a Lab)
    - Panel Title: **Successful Purchases Over Time**
    - Panel Content: Choose Line Chart (Splunk will automatically try to visualize the data if you have a timechart command, but if not, it will default to a table).
    - Click **Save to Dashboard**, then click **View Dashboard**
5. Search for failed purchases: `index=main action=purchase status=503 | timechart count`
6. Click **Visualization**
7. From the small dropdown change the `Chart` from Column Chart to Line Chart
8. In the top search area, click **Save As** > **Existing Dashboard**
    - Select existing: **Buttercup Games SOC**
    - Panel title: **Unuccessful Purchases Over Time**
    - Panel Content: Choose Line Chart (Splunk will automatically try to visualize the data if you have a timechart command, but if not, it will default to a table).
    - Click **Save to Dashboard**, then click **View Dashboard**

### Alerting
Splunk isn't very helpful without alerting. A passive logging system needs to be more active to be valuable.

Create an alert that emails you (or triggers a notification) if more than 5 failed logins occur within 1 minute.
- query: `index=main "failed password"`
- Click **Save As** > **Alert**
  - Title: **Failed Login Alert**
  - Description: **5 or more failed logins in 1 minute**
  - Permissions: **Shared in App**
  - Alert type: **Real-time**
  - Expires: **1 hour**
  - Trigger alert when:
     - **Number of Results**
     - **Is greater than 4**
    - in **1 minutes**
    - Trigger **Once**
    - Throttle: **15 minutes**
- Trigger Actions:
  - **Add action** > **Send email** (and configure as you wish)
- Click **Save**
- Click **View Alert**
- Optionally configure **Settings** > **Server settings** > **Email settings** so the alert emails will work
