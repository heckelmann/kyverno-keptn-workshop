# Pre-Deployment Checks

Before deploying a KeptnApp or KeptnWorkload, you want to make sure that some pre-condition checks are met. This could be a maintenance window check, a security scan, or any other check that you want to run before deploying your application.

With Keptn you can define these checks as `KeptnTaskDefinition` and assign them to a `KeptnAppContext` or a specific workload.

These Tasks could be executed before or after your Pod is scheduled on the Kubernetes cluster.

A full documentation of KeptnTasks can be found [here](https://keptn.sh/stable/docs/guides/tasks/).

## Exercise

In this exercise, you will create a KeptnTask that checks if a maintenance window is open for your application.

We will use the already existing Python script `checkmaintenance.py` that is stored in the `tasks` folder of this repository and execute it as a KeptnTask.

### Create KeptnTaskDefinition

Create a new file `maintenance-window-check.yaml` in the `gitops/dev/demo-app/templates` folder of your repository and add the following content:

```yaml
apiVersion: lifecycle.keptn.sh/v1alpha3
kind: KeptnTaskDefinition
metadata:
  name: maintenance-window-check
  namespace: demo-app-dev
spec:
  retries: 3
  timeout: "5m"
  python:
    httpRef: 
      url: 'https://raw.githubusercontent.com/heckelmann/kyverno-keptn-workshop/main/tasks/checkmaintenance.py'
```

This KeptnTaskDefinition defines a task that retries 3 times with a timeout of 5 minutes. The task is executed by a Python script that is stored in the `tasks` folder of this repository.

### Assign Task to KeptnApp

To assign this task to a KeptnApp, you need to add it to the `KeptnAppContext`, as shown in the example below:

```yaml
apiVersion: lifecycle.keptn.sh/v1
kind: KeptnAppContext
metadata:
  name: demo-app
  namespace: demo-app-dev
spec:
  preDeploymentTasks:
    - maintenance-window-check
```

This will execute the `maintenance-window-check` task before deploying the `demo-app` application.

### Deploy the Task

Commit and push the changes to your repository and refresh in ArgoCD the `demo-app-dev` application.

### Verify the Task

We will deploy a new version of the `demo-app-dev` application and check if the maintenance window check is executed before the deployment.

Change the Version in `gitops/dev/demo-app/values.yaml` to `v1.1` and commit and push the changes to your repository.	

You should see the maintenance window check in K9s before the deployment is started.

Now we remove the Maintenance Window and re-deploy the application. The deployment should now be successful.

To restart a blocked deployment you need to increase the `revision` of the `KeptnApp` with this Command:

```bash
kubectl -n demo-app-dev patch keptnapp demo-app --type='json' -p='[{"op": "replace", "path": "/spec/revision", "value": 2}]'
```

### Summary

In this exercise, you have learned how to create a KeptnTaskDefinition and assign it to a KeptnApp. You have also learned how to execute the task before deploying an application and how to verify the task execution.