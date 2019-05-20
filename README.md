# meteor

meteor is jmeter based load testing framework that supports load testing using Docker, docker-machine and AWS. It also supports load tests without docker. 

To install and setup;
1. Clone this repo
2. Update config.json with details of load generators and controller
3. Add user data in jmeterData.csv under jmeterScripts directory
4. Add jmeter script file (jmx) under jmeterScripts directory
5. For accessing linux machine without password setup private and public key. Copy .ppk file in keyfile folder
6. run ./runLoadTest.ps1 (for using hyperv run this script in elevated access in powershell)

meteor also supports logging in graphite but graphite needs to run separately. Server IP and port needs to be updated in jmeter script as a variable. 

- When you run these scripts on a windows machine it creates load generators and controllers on linux machines. Support for Windows load generators and controllers is to be added.


Config setup;



# For running load generators;
* value of location can be;
  - local
  - local-docker
  - cloud
  - cloud-docker
* host should contain comma separated list of servers if location is local or local-docker
* private key file should be available in keyfile folder
* for cloud load generators, the valud of driver can be;
  - amazonec2 (for ec2 instances, accesskeyid and accesskeypass are required) 
  - hyperv (for Hyervisor virual machines, hypervswitchname required)
  - virtualbox (for virtual box virtual machines)

```json  
    "loadgen":{
        "OS": "linux",
        "location":"cloud-docker",
        "host": "192.168.20.22,192.168.20.21",
        "privatekey":"privatekey.ppk",
        "cloud": {
            "loadgencount": 1,
            "driver": "virtualbox",
            "hypervswitchname":"Private Switch",
            "accesskeyid": "aws access id",
            "accesskeypass": "aws access key"
        }
    },
```    
# For controller setup
* if createinstance is true, script will try creating a docker-machine with host name provided in host. If false, it will check if host machine is active. 

```json
  "controller":{
        "OS":"linux",
        "location": "cloud-docker",
        "host": "192.168.20.17",
        "privatekey":"privatekey.ppk",
        "cloud":{
            "createinstance": "false",
            "driver": "virtualbox",
            "hypervswitchname":"Private Switch",
            "accesskeyid": "aws access key",
            "accesskeypass":"aws access pass",
            "host": "jmetercontroller"
        }
    }
```
