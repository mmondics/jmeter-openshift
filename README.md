# Running JMeter Container in OpenShift

1. Change into the project where you want the JMeter container to run.

    In these instructions, the project name is `acmeair`.

    ```text
    oc project acmeair
    ```

1. Grant elevated privileges to the `default` serviceaccount.

    This is required as JMeter runs as root.

    ```text
    oc adm policy add-scc-to-user anyuid -z default
    ```

1. Create a configMap that contains your JMeter test plan.

    The configmap must be named `jmeter-test` unless you edit the deployment YAML to reflect your name change.
    
    In the example below `AcmeAir-microservices.jmx` is a test plan in the current working directory.

    ```text
    oc create configmap jmeter-test --from-file AcmeAir-microservices.jmx
    ```

1. Create a configMap that contains test parameters to pass in the JMeter test.

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

1. Start the JMeter container by creating a deployment.

    ```text
    oc create -f <TBD>
    ```