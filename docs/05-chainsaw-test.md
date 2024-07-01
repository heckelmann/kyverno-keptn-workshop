# Pre-Deployment Checks (chainsaw test)

With pre-deployment checks enabled and the maintenance window check in place, the KeptnTask is supposed to be executed before the deployment is successful.

However, if this automation is not working properly it can put your system at risk.
To exercise the automation and make sure it behaves as expected you can write and execute a chainsaw test.

A full documentation of KeptnTasks can be found [here](https://kyverno.github.io/chainsaw/latest/).

## Exercise

In this exercise, you will create a chainsaw test to verify that a KeptnTask is run when the deployment is updated.

### Create the chainsaw test

Create a new file `chainsaw-test.yaml` in the `tests/01-maintenance-window-check` folder of your repository and add the following content:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/kyverno/chainsaw/main/.schemas/json/test-chainsaw-v1alpha1.json
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: maintenance-window-check-dev
spec:
  namespace: demo-app-dev
  steps:
  - try:
    - delete:
        ref:
          apiVersion: lifecycle.keptn.sh/v1
          kind: KeptnApp
          name: demo-app
    - delete:
        ref:
          apiVersion: apps/v1
          kind: Deployment
          name: demo-app
    - assert:
        timeout: 1m
        resource:
          apiVersion: lifecycle.keptn.sh/v1
          kind: KeptnApp
          metadata:
            name: demo-app
    - assert:
        resource:
          apiVersion: lifecycle.keptn.sh/v1
          kind: KeptnTask
          spec:
            checkType: pre
            context:
              appName: demo-app
              appVersion: v1
              objectType: App
              taskType: pre
              workloadName: ""
            taskDefinition: maintenance-window-check
          status:
            status: Succeeded
```

This chainsaw test deletes the existing KeptnApp and the demo app Deployment.
ArgoCD will recreate the Deployment and Keptn will run the pre-deployment task.
Chainsaw will verify that a KeptnTask was executed and that the execution was successful.

### Run the chainsaw test

The test above can be run with:

```bash
chainsaw test tests/01-maintenance-window-check
```

If the test succeeds you should see an output similar to:
```
Version: 0.2.5
Loading default configuration...
- Using test file: chainsaw-test
- TestDirs [./exercises/01-keptn-tasks/]
- SkipDelete false
- FailFast false
- ReportFormat ''
- ReportName ''
- Namespace ''
- FullName false
- IncludeTestRegex ''
- ExcludeTestRegex ''
- ApplyTimeout 5s
- AssertTimeout 30s
- CleanupTimeout 30s
- DeleteTimeout 15s
- ErrorTimeout 30s
- ExecTimeout 5s
- DeletionPropagationPolicy Background
- Template true
- NoCluster false
- PauseOnFailure false
Loading tests...
- maintenance-window-check-dev (./exercises/01-keptn-tasks/)
Loading values...
Running tests...
=== RUN   chainsaw
=== PAUSE chainsaw
=== CONT  chainsaw
=== RUN   chainsaw/maintenance-window-check-dev
=== PAUSE chainsaw/maintenance-window-check-dev
=== CONT  chainsaw/maintenance-window-check-dev
    | 00:14:44 | maintenance-window-check-dev | step-1   | TRY       | RUN   |
    | 00:14:44 | maintenance-window-check-dev | step-1   | DELETE    | RUN   | lifecycle.keptn.sh/v1/KeptnApp @ demo-app-dev/demo-app
    | 00:14:45 | maintenance-window-check-dev | step-1   | DELETE    | OK    | lifecycle.keptn.sh/v1/KeptnApp @ demo-app-dev/demo-app
    | 00:14:45 | maintenance-window-check-dev | step-1   | DELETE    | DONE  | lifecycle.keptn.sh/v1/KeptnApp @ demo-app-dev/demo-app
    | 00:14:45 | maintenance-window-check-dev | step-1   | DELETE    | RUN   | apps/v1/Deployment @ demo-app-dev/demo-app
    | 00:14:45 | maintenance-window-check-dev | step-1   | DELETE    | OK    | apps/v1/Deployment @ demo-app-dev/demo-app
    | 00:14:45 | maintenance-window-check-dev | step-1   | DELETE    | DONE  | apps/v1/Deployment @ demo-app-dev/demo-app
    | 00:14:45 | maintenance-window-check-dev | step-1   | ASSERT    | RUN   | lifecycle.keptn.sh/v1/KeptnApp @ demo-app-dev/demo-app
    | 00:15:15 | maintenance-window-check-dev | step-1   | ASSERT    | DONE  | lifecycle.keptn.sh/v1/KeptnApp @ demo-app-dev/demo-app
    | 00:15:15 | maintenance-window-check-dev | step-1   | ASSERT    | RUN   | lifecycle.keptn.sh/v1/KeptnTask @ demo-app-dev/*
    | 00:15:25 | maintenance-window-check-dev | step-1   | ASSERT    | DONE  | lifecycle.keptn.sh/v1/KeptnTask @ demo-app-dev/*
    | 00:15:25 | maintenance-window-check-dev | step-1   | TRY       | DONE  |
--- PASS: chainsaw (0.00s)
    --- PASS: chainsaw/maintenance-window-check-dev (40.17s)
PASS
Tests Summary...
- Passed  tests 1
- Failed  tests 0
- Skipped tests 0
Done.
```

### Summary

In this exercise, you have learned how to use chainsaw to validate that pre-deployment tasks defined in your KeptnAppContext are correctly executed when the demo app is updated.
