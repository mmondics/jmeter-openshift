# Running JMeter Container in OpenShift
The container image used in this repository was originally built to run JMeter tests against an AcmeAir application. Thus, the container image includes required binaries for AcmeAir. You are free to remove these binaries or add binaries of your own by dropping files in the [test-plan directory](/test-plan/) along with any required libraries in the [test-plan/libraries directory](/test-plan/libraries/). You then should update the [jmeter-deployment.yaml](/openshift/jmeter-deployment.yaml) to reflect your customized image.

If you do not have any required binaries or libraries, the instructions below should work for your JMeter test plan.

1. Change into the project where you want the JMeter container to run.

    Replace `<project_name>` with the correct name.

    ```text
    oc project <project_name>
    ```

2. Grant elevated privileges to the `default` serviceaccount.

    This is required as JMeter runs as root.

    ```text
    oc adm policy add-scc-to-user anyuid -z default
    ```

3. Create a configMap that contains your JMeter test plan.

    The configmap must be named `jmeter-test` unless you edit the deployment YAML to reflect your name change.
    
    The test plan must be named `test-plan.jmx`.

    ```text
    oc create configmap jmeter-test --from-file test-plan.jmx
    ```

4. Create a configMap that contains test parameters to pass in the JMeter test.

    Required parameters are:

    - `HOST`: Hostname against which the JMeter script will run
    - `PORT`: Port that JMeter script will hit
    - `THREADS`: Number of virtual users to issue requests against the application
    - `DELAY`: Delay in starting the test in seconds - can be set to 0
    - `RAMP`: Ramp time in seconds - can be set to 0

    Any further customizations should be made in the JMeter test plan file. These parameters are intended to allow quick changes to the test without editing the test plan.

    ```test
    oc create configmap cm-params \
    --from-literal=HOST=acmeair.apps.atsocpd1.dmz \
    --from-literal=PORT=80 \
    --from-literal=THREAD=10 \
    --from-literal=DELAY=0 \
    --from-literal=RAMP=0
    ```

    The configMap must be named `cm-params` unless you edit the deployment YAML to reflect your name change.

5. Start the JMeter container by creating a deployment.

    ```text
    oc create -f https://raw.githubusercontent.com/mmondics/jmeter-openshift/main/openshift/jmeter-deployment.yaml
    ```

6. Look at the `jmeter-container` pod logs to check that the results of the JMeter test are as expected.

## Troubleshooting
1. Check the `jmeter-container` pod logs and events to start identifying the issue.

1. Check the `/test-plan/jMeter-log` log file in the pod for error messages.

    If your pod is crashlooping/not starting, you can start a debug pod to check the logs.

    ```text
    oc debug pod/<jmeter_pod>
    more /test-plan/jMeter-log
    ```