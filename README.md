# cf-fortio

[Fortio](https://fortio.org/) on [Cloud Foundry](http://cloudfoundry.org)

Write a `manifest-vars.yml` file like this
```yaml
apps_domain: my-apps-domain.example.com
reports_bucket: http://storage.googleapis.com/my-reports-bucket  # report-ui app mirrors data from here
echo_server_instances: 2  # set equal to the number of diego cells in your deployment
```

then

```bash
git submodule update --init --recursive
cf push --vars-file manifest-vars.yml
cf add-network-policy fortio-admin --destination-app fortio-echo-server
```

then
- connect to `fortio.((apps_domain))/fortio` to drive the admin UI
- create a google cloud storage transfer job to upload results to your bucket:
   - [create transfer job](https://console.cloud.google.com/storage/transfer/config)
   - use the "list of object URLs" pointing at `http://fortio.((apps_domain))/fortio/data/index.tsv`
   - TODO: automate this somehow
- after you're done, `cf stop fortio-admin` so that you're not leaving a DoS tool lying around on the web :-)
