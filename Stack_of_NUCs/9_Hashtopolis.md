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

## Create a project folder for Hashtopolis
- Log in to NUC 2 again, the ansible controllers (via NUC 1)
- Create directory `/home/ansible/my-project/hashtopolis` and change to it
  - `mkdir hashtopolis`
  - `cd hashtopolis`
- Create the following files from this repo ([hashtopolis](hashtopolis))
  - `inventory` ([inventory](hashtopolis/inventory))
    - select one of the worker does to be the Hashtopolis server, and put its IP address in the the `[server]` section
    - enter the remaining worker node "agent" IP addresses in0 the `[agents]` section
  - `ansible.cfg` ([ansible.cfg](hashtopolis/ansible.cfg))
  - `apache.conf.j2` ([apache.conf.j2](hashtopolis/apache.conf.j2))
  - `info.php.j2` ([info.php.j2](hashtopolis/info.php.j2))
  - `conf.php.j2` ([conf.php.j2](hashtopolis/conf.php.j2))
  - `.my.cnf.j2` ([.my.cnf.j2](hashtopolis/.my.cnf.j2))
  - `hashtopolis-server.yml` ([hashtopolis-server.yml](hashtopolis/hashtopolis-server.yml))
  - `remove-hashtopolis-installer.yml` ([remove-hashtopolis-installer.yml](hashtopolis/remove-hashtopolis-installer.yml))
  - `remove-hashtopolis.yml` ([remove-hashtopolis.yml](hashtopolis/remove-hashtopolis.yml))
  - `hash-passwords.sh` ([hash-passwords.sh](hashtopolis/hash-passwords.sh))

## Install Hashtopolis Server
This playbook installs the LAMP stack and uses git clone to install the Hashtopolis server application.

⚠️ might need to add php.ini tweaks to the playbook for performance

- Optionally, customize the default passwords in the playbook `hashtopolis-server.yml`
  - mysql_root_password
  - hashtopolis_password
- Run the playbook
  - `ansible-playbook hashtopolis-server.yml`
- Confirm the server is up
  - open web browser and point to the Hashtopolis server's IP address
    - *Example: http://192.168.1.100/info.php*
    - *Example: http://192.168.1.00/install/index.php*

## Configure Hashtopolis Server
- Configure the server using the Web UI
  - open web browser and point to the Hashtopolis server's IP address and the path "/install"
    - *Example: http://192.168.1.100/install*
- You will be redirected to `install/index.php` and be prompted to click `Start Installation of Hashtopolis`
  - complete the installation gui to configure the server
  - create a Hashtopolis login account when prompted
    - Username (the user "admin" is already taken; don't try to use it)
    - Email Address
    - Password x2
   - ⚠️ Currently there is a server error 500 at the end of the wizard, but you can still log in
   - install/index.php line 88 is trying to stored the "version" valid ID to table StoredValue when it already exists; may need to be "update" not save
- Log in the the Hashtopolis server's IP address using the credentials you provided
- Apply Configurations
  - allow voucher reuse
    - Click **Config** > **Server**
    - Click **Server**
    - Check **Vouchers can be used multiple times and will not be deleted automatically.**
    - Click **Save Changes**
  - Import word lists
    - Click **Files** then click **Wordlists**
    - Under *Import files* select **10-million-password-list-top-100000.txt** and **rockyou.txt**
    - Click **Import files**
  - Import rule
    - Click **Files** then click **Rules**
    - Under *Import files* select **OneRuleToRuleThemAll.rule**
    - Click **Import files**
- After configuration is complete, remove the install directory
  - Run the playbook
    - `ansible-playbook remove-hashtopolis-installer.yml`

## Generate Voucher Codes
- Log in and create enough vouchers for all your worker nodes
  - Click **Agents** > **New Agent**
  - Under the *Clients* seciton, find the New voucher button
  - Click **Create**
  - Repeat to generate vouchers for all your workers
  - Save these voucher codes to `/home/ansible/my-project/hashtopolis/vouchers.txt`

Example vouchers.txt file:
~~~~
Aek5dy7J
iJZxosk4
TVxiOIRV
Hp0kLebl
~~~~

## Install Agents
- Create the following files from this repo ([hashtopolis](hashtopolis))
  - `config.json.j2` ([config.json.j2](hashtopolis/config.json.j2))
    - j2 template for the agent configuration file
    - see more options for this config file at https://github.com/hashtopolis/agent-python
  - `hashtopolis-agent.service` ([hashtopolis-agent.service](hashtopolis/hashtopolis-agent.service)) (unit file for the new hashtopolis-agent service)
  - `hashtopolis-agent.yml` ([hashtopolis-agent.yml](hashtopolis/hashtopolis-agent.yml))
  - `check-agent-service.yml` ([check-agent-service.yml](hashtopolis/check-agent-service.yml))
- Run the playbook
  - `ansible-playbook hashtopolis-agent.yml`
- Check the agent status
  - `ansible-playbook check-agent-service.yml`

If some agents are not coming on-line, check the node's `/home/ansible/config.json` file for a missing voucher code. Put in a voucher code and ``sudo systemctl restart hashtopolis-agent.service``

## Configure Agents For Cracking
- Log in to the Hashtopolis dashboard and view the agents
- Click **Agents** then **Show agents**
- Edit each agent *Trust* setting
  - Click on an agent
  - Click **Show/Hide details**
  - Next to *Trust** check the box for **Trust agent with secret data**

## Create Sample md5 Password Hashes
- Create a list of passwords you want to crack
  - Use a variety of passwords
    - poor passwords
    - kids passwords https://www.dinopass.com/
    - short leet passwords
    - short truly random passwords
      - sudo apt install pwgen -ypwgen
      - pwgen 5 1
      - pwgen 7 1
- Put the passwords in a file passwords.txt (example passwords.txt file [here](hashtopolis/passwords.txt))
- Create a list of md5 hashes from these passwords
  - Since we are cracking using very old NUCs here, the weak md5 hash is the best choice here
  - Create the hashes:
    - `sh hash-passwords.sh`
    - Reads `passwwords.txt` and outputs `hashes.txt`
- Sort hashes.txt file (important)
  - `sort -o hashes.txt hashes.txt`
  - Example hashes.txt file [here](hashtopolis/hashes.txt)
- Upload the hashes.txt file to Hashtopolis
  - Log in to the Hashtopolis dashboard
  - Click **Lists** then **New hashlist**
    - Name: **hashes.txt**
    - Hashtype: **0 (md5)**
    - Hashlist format: Text File
    - Hash source: **Paste**
    - Input fields: *paste in the contents of hashes.txt*
    - Click Create hashlist
  - You can also upload, the file in the browser, copy the file to the servers in the import directy and click import, or donwnload from a URL
  
## Create Task to Crack the Hashes - Wordlist and Rule
- Click **Tasks** > **New Task**
  - Name: **demo**
  - Hashlist: **hashes.txt**
  - Command:
    - Click Rules then check **OneRuleToRuleThemAll.rule**
    - Click Wordlists then check (<ins>under T</ins>) **rockyou.txt**
    - Command should be: `#HL# -r OneRuleToRuleThemAll.rule rockyou.txt`
  - Priority: **10** (greater than 0)
  - Maximum number of agents: *leave 0*
  - Task notes: **demo**
  - Color: **A00000**
  - Click **Create Task**
- Re-open your task **Demo**
  - Under Assigned agents
    - Node that your agents are assigned to the task, and the ability to *Unassign* agents from the task
    - WARNING if the task assignment fails, modify the agent(s) to be “trusted” with secret data

### Watch the Job Run
Allow a few minutes for the tasks to get assigned and started.
- Click **Tasks** -> **Show Tasks**
  - Note the progress of "Dispatched/Searched" as it tracks the percentage complete
  - Note the "Cracked" column, showing how many hashes were cracked; click the link to view the cracked hashes
  - Note the speed of of hash-checking in mega hashes per second; md5 is very fast to check and therefore md5 hashing is quite insecure
  - Click on the task's ID or name to view Task details
    - Check out the task "visual representation" and "Task Speed"
    - Click Dispatched chunks - "Show all" to view progress, and how log it took to complete each chunk (more powerful agents will be faster and take less time)
- Click **Agents** -> **Agents status**
  - Average device utlization may show Red until enough data is collected
  - Note show each device temperature and average CPU are shown
  - Note how different agents are working on different "chunks" of work
- Click **Chunk activity**
  - Note the chunk detail and how many hashes were cracked per chunk; click the link to view the cracked hashes

### After Job Completes
- Wait for your job to complete
  - Click **Lists** > **Cracks** to view cracked passwords
    - First to be cracked:
      - P@$$w0rd
      - Butterfly123!
      - January2022
      - covidsucks
      - sillywombat11
      - Ewug4
    - Consider what the difference would be without using the rule or with using the different wordlists (rockyou.txt vs 10-million-password-list-top-100000.txt)

## Create Tasks to Crack the Hashes - Bruteforce
- Click **Tasks** > **New Task**
  - Name: **brute7**
  - Hashlist: **hashes.txt**
  - Command:
    - `-a3 #HL# ?a?a?a?a?a?a?a`
  - Priority: **10**
  - Maximum number of agents: *leave 0*
  - Task notes: **brute force**
  - Color: **00A000**
  - Click **Create Task**
- Click **Tasks** > **New Task**
  - Name: **brute8**
  - Hashlist: **hashes.txt**
  - Command:
    - `-a3 #HL# ?a?a?a?a?a?a?a?a`
  - Priority: 10
 - Maximum number of agents: *leave 0*
- Task notes: **brute force**
  - Color: **00A000**
  - Click **Create Task**
- *Create more tasks for longer lengths if you'd like*

### Watch the Jobs Run
What do you expect these tasks to crack? Allow a few minutes for the tasks to get assigned and started.
- Click **Tasks** -> **Show Tasks**
  - Click on the task's ID or name to view Task details
    - Check out the task "visual representation" and "Task Speed"
    - Click Dispatched chunks - "Show all" to view progress, and how log it took to complete each chunk (more powerful agents will be faster and take less time)
- Click **Agents** -> **Agents status**
- Click **Chunk activity**

### After the Jobs Complete

## Uninstall Hashtopolis
Before you clean up Hashtopolis, take a look under **Learn More** for more hands-one password cracking you can test in the lab.

When you are ready to clean up:
- `ansible-playbook remove-hashtopolis.yml`

**NOTE** After running playbook to remove Hashtoplis, I found that upon reinstalling the server, the Hashtopolis server PHP stopped working. The following are commands to fix that issue.
- sudo apt install php-fpm
- sudo a2enmod proxy_fcgi setenvif
- sudo a2enconf php8.1-fpm
- sudo systemctl restart apache2

## Learn More
Try cracking other Hashes

### Ubuntu
- On NUC 1
  - Create a user account name tryhackme on NUC 1 with a simple password, like `password`
  - Dump the hash for the user tryhackme
    - `sudo grep tryhackme/etc/shadow | cut -f 2 -d“:”`
- In Hashtopolis
  - Create a hashlist
  - name Unix
  - paste in the hash (starts with and includes “$6$”)
    - you can also use the example hash from https://hashcat.net/wiki/doku.php?id=example_hashes
  - hashtype 1800 - sha512crypt, SHA512(UNIX)
  - No check for salted hashes, separator
  - No check for salt is in hex (only when salted hashes)
- Create a task
  - name unix
  - hashlist Unix
  - worklist rockyou.txt
  - priority 5
  - attack command: `#HL# rockyou.txt`

### Windows
Reference: https://hashcat.net/wiki/doku.php?id=example_hashes
- You can use hashes from that reference for testing

Steps:
1. On the Windows 10 PC
    - Add an account with the a simple password, such as password
      - net user person /active:yes /add
      - net localgroup administrators /add person
        - making this user an administrator makes it show up easier to find in the password hash dump
      - net user person *
        - set the password to something easy like `password`
    - Extract the SAM and SYSTEM registry hives
      - Open a shell as Administrator
        - reg save hklm\sam c:\sam
        - reg save hklm\system c:\system
        - the last parameter is the location to copy the file to
    - Remove the test user you created
      - net user person /delete
2. On NUC 1
    - Copy the SAM and SYSTEM registry hives to NUC 1
    - Install impacket-secretsdump
      - sudo apt install python3-impacket -y
    - Dump the system keys and hashes
      - If the files are named “sam” and “system”
        - impacket-secretsdump -sam SAM -system SYSTEM LOCAL
    - For your test user (i.e. person) there are two hashes
      - one for LM authentication, (deprecated and only populated with a value to ensure the syntax remains constant)
      - other is the NTLM string
      - For example, for person:
        - LM aad3b435b51404eeaad3b435b51404ee = means LM is not being stored
        - NTLM 8846f7eaee8fb117ad06bdd830b7586c
        - Warning 31d6cfe0d16ae931b73c59d7e0c089c0 means a blank password, and means you were not successful pulling the hashes (samdump2 for example, gives this hash)
3. In Hashtopolis
    - Create new hashlist
      - LM
        - Name: LM
        - Hashtype: 3000 - LM
        - Paste in text, the LM hash from https://hashcat.net/wiki/doku.php?id=example_hashes; the one you dumped will not work
        - Create
      - NTLM
      - Name: NTLM
      - Hashtype: 1000 - NTLM
      - Paste in text, the NTLM hash you dumped plus the one from https://hashcat.net/wiki/doku.php?id=example_hashes
      - Create
    - Create new tasks
      - LM
        - Name: LM
        - Hashlist: LM
        - Enable rule OneRuleToRuleThemAll.rule
        - Enable worklist rockyou.txt
        - Priority: 10
        - Attack command: #HL# rockyou.txt -r OneRuleToRuleThemAll.rule
    - NTLM
      - Name: LM
      - Hashlist: LM
      - Enable rule OneRuleToRuleThemAll.rule
      - Enable worklist rockyou.txt
      - Priority: 9
      - Attack command: #HL# rockyou.txt -r OneRuleToRuleThemAll.rule

## Important Notes
Intel CPUs require this runtime: “OpenCL Runtime for Intel Core and Intel Xeon Processors” (16.1.1 or later)
- https://github.com/intel/compute-runtime/releases
  - hmmmm sudo apt install intel-opencl-icd
- http://registrationcenter-download.intel.com/akdlm/irc_nas/vcp/15532/l_opencl_p_18.1.0.015.tgz

🚧Do i need to add install intel-opencl-icd to the hashtopolis-agent.yml file?

Testing: sudo crackers/1/hashcat.bin -a6 -m0 hashlists/1 ?d?d?d?d?d?d?d?d
