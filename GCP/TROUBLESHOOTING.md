# Troubleshooting Google Deployments

<!-- spell-checker: ignore volterra markdownlint nating vnet -->

### Startup Script Logs
The main output log file is /var/log/cloud/onboard.log. When the BIG-IP instance is created and ready for SSH access, login and check the log file for errors.

```bash
# Login to BIG-IP CLI, then enter bash mode
tail -f /var/log/cloud/onboard.log
```

### Startup Script Log Directory is Missing
If /var/log/cloud directory does not exist, then the GCP virtual machine instance did not properly execute the startup script. Refer to GCP documentation regarding startup scripts, how to validate if they ran, where to look, etc.

- Startup Script - https://cloud.google.com/compute/docs/startupscript
- Viewing logs - https://cloud.google.com/compute/docs/startupscript#viewing_startup_script_logs

### Service Account Permissions
If you are doing HA setup and the service account permissions are incorrect, then you can have HA setup failures or problems when you initiate traffic failover from active BIG-IP to standby BIG-IP. Refer to the README for your particular deployment for correct roles and permissions.

### F5 Toolchain and Restnoded Logs
During onboarding, the BIG-IP will run multiple F5 Automation Toolchain components. If the startup scripts log file does not have the info you need, then check restnoded logs.

```bash
# Login to BIG-IP CLI, then enter bash mode
tail -f /var/log/restnoded/restnoded.log

# Check for historical errors
cat /var/log/restnoded/restnoded.log | grep -i err
```

Checking restnoded log files will give more details as to why the toolchain specific component failed. It can be due to timeout, invalid config/declaration, or other reasons. If more logging is needed, then increase log level. You can also check the F5 toolchain troubleshooting links for more info.

- DO: https://clouddocs.f5.com/products/extensions/f5-declarative-onboarding/latest/troubleshooting.html
- AS3: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/userguide/troubleshooting.html
- FAST: https://clouddocs.f5.com/products/extensions/f5-appsvcs-templates/latest/userguide/troubleshooting.html
- TS: https://clouddocs.f5.com/products/extensions/f5-telemetry-streaming/latest/userguide/troubleshooting.html
- CFE: https://clouddocs.f5.com/products/extensions/f5-cloud-failover/latest/userguide/troubleshooting.html

### Successful Deployment Example Logs
If all goes well, the end of the /var/log/cloud/onboard.log file will look similar to the output below.

```bash
Testing network: curl http://example.com
Status code:   Not done yet...
Got 200! VE is Ready!
Retrieving BIG-IP password from Metadata secret
Thu Oct 28 16:18:29 PDT 2021
declarative-onboarding is ready
Submitting DO declaration
DO task created
DO task working...
DO task working...
DO task working...
DO task successful
Thu Oct 28 23:19:03 UTC 2021
appsvcs is ready
Submitting AS3 declaration
Failed to deploy AS3; continuing...
Response code: 400
Thu Oct 28 23:19:03 UTC 2021
cloud-failover is ready
Submitting CFE declaration
Deployment of CFE succeeded
Removing DO/AS3/TS/CFE declaration files
Thu Oct 28 23:19:34 UTC 2021
Finished custom config
```
