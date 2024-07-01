# Pre-Deployment Checks (chainsaw test)

With pre-deployment checks enabled and the maintenance window check in place, a KeptnTask is now supposed to execute before the deployment is considered successful.

However, if this automation is not working properly it can put your system at risk.
To exercise the automation and make sure it behaves as expected you can write and execute a chainsaw test.

Full documentation of chainsaw can be found [here](https://kyverno.github.io/chainsaw/latest/).

## Exercise

In this exercise, you will create a chainsaw test to verify that a KeptnTask is run when the deployment is updated.

### Create the chainsaw test

Create a new file `chainsaw-test.yaml` in the `tests/05-pre-deployment-checks` folder of your repository and add the following content:

```yaml
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: maintenance-window-check
spec:
  bindings:
  - name: repo
    value: (env('GITHUB_REPOSITORY'))
  steps:
  - try:
    - apply:
        resource:
          apiVersion: argoproj.io/v1alpha1
          kind: Application
          metadata:
            name: demo-app-test
            namespace: argocd
            annotations:
              argocd.argoproj.io/sync-wave: '10'
            finalizers:
              - resources-finalizer.argocd.argoproj.io
          spec:
            project: default
            source:
              path: charts/demo-app
              repoURL: (join('/', ['https://github.com', $repo]))
              targetRevision: main
              helm:
                valuesObject:
                  repo:
                    name: ($repo)
                  keptn:
                    appContext:
                      preDeploymentTasks:
                      - maintenance-window-check
                valueFiles:
                  - ../../gitops/dev/demo-app/values.yaml
                  - ../../gitops/dev/demo-app/values-specific.yaml
                parameters:
                  - name: commitID
                    value: $ARGOCD_APP_REVISION
                  - name: serviceVersion
                    value: v1
                  - name: service.nodePort
                    value: '31106'
            destination:
              server: https://kubernetes.default.svc
              namespace: ($namespace)
            syncPolicy:
              automated:
                prune: true
                selfHeal: true
    - assert:
        timeout: 10m
        resource:
          apiVersion: argoproj.io/v1alpha1
          kind: Application
          metadata:
            name: demo-app-test
            namespace: argocd
          status:
            health:
              status: Healthy
            sync:
              status: Synced
    - assert:
        timeout: 1m
        resource:
          apiVersion: lifecycle.keptn.sh/v1
          kind: KeptnApp
          metadata:
            name: demo-app
    - apply:
        resource:
          apiVersion: argoproj.io/v1alpha1
          kind: Application
          metadata:
            name: demo-app-test
            namespace: argocd
            annotations:
              argocd.argoproj.io/sync-wave: '10'
            finalizers:
              - resources-finalizer.argocd.argoproj.io
          spec:
            project: default
            source:
              path: charts/demo-app
              repoURL: (join('/', ['https://github.com', $repo]))
              targetRevision: main
              helm:
                valuesObject:
                  repo:
                    name: ($repo)
                  keptn:
                    appContext:
                      preDeploymentTasks:
                      - maintenance-window-check
                valueFiles:
                  - ../../gitops/dev/demo-app/values.yaml
                  - ../../gitops/dev/demo-app/values-specific.yaml
                parameters:
                  - name: commitID
                    value: $ARGOCD_APP_REVISION
                  - name: serviceVersion
                    value: v2
                  - name: service.nodePort
                    value: '31106'
            destination:
              server: https://kubernetes.default.svc
              namespace: ($namespace)
            syncPolicy:
              automated:
                prune: true
                selfHeal: true
    - assert:
        timeout: 2m
        resource:
          apiVersion: lifecycle.keptn.sh/v1
          kind: KeptnTask
          spec:
            checkType: pre
            context:
              appName: demo-app
              appVersion: v2
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
chainsaw test tests/05-pre-deployment-checks
```

If the test succeeds you should see an output similar to:

```
Version: 0.2.5
Loading default configuration...
- Using test file: chainsaw-test
- TestDirs [./tests/05-pre-deployment-checks]
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
- maintenance-window-check (./tests/05-pre-deployment-checks)
Loading values...
Running tests...
=== RUN   chainsaw
=== PAUSE chainsaw
=== CONT  chainsaw
=== RUN   chainsaw/maintenance-window-check
=== PAUSE chainsaw/maintenance-window-check
=== CONT  chainsaw/maintenance-window-check
    | 08:45:48 | maintenance-window-check | @setup   | CREATE    | OK    | v1/Namespace @ chainsaw-moved-bream
    | 08:45:48 | maintenance-window-check | step-1   | TRY       | RUN   |
    | 08:45:48 | maintenance-window-check | step-1   | APPLY     | RUN   | argoproj.io/v1alpha1/Application @ argocd/demo-app-test
    | 08:45:48 | maintenance-window-check | step-1   | CREATE    | OK    | argoproj.io/v1alpha1/Application @ argocd/demo-app-test
    | 08:45:48 | maintenance-window-check | step-1   | APPLY     | DONE  | argoproj.io/v1alpha1/Application @ argocd/demo-app-test
    | 08:45:48 | maintenance-window-check | step-1   | ASSERT    | RUN   | argoproj.io/v1alpha1/Application @ argocd/demo-app-test
    | 08:46:50 | maintenance-window-check | step-1   | ASSERT    | DONE  | argoproj.io/v1alpha1/Application @ argocd/demo-app-test
    | 08:46:50 | maintenance-window-check | step-1   | ASSERT    | RUN   | lifecycle.keptn.sh/v1/KeptnApp @ chainsaw-moved-bream/demo-app
    | 08:46:50 | maintenance-window-check | step-1   | ASSERT    | DONE  | lifecycle.keptn.sh/v1/KeptnApp @ chainsaw-moved-bream/demo-app
    | 08:46:50 | maintenance-window-check | step-1   | APPLY     | RUN   | argoproj.io/v1alpha1/Application @ argocd/demo-app-test
    | 08:46:50 | maintenance-window-check | step-1   | PATCH     | OK    | argoproj.io/v1alpha1/Application @ argocd/demo-app-test
    | 08:46:50 | maintenance-window-check | step-1   | APPLY     | DONE  | argoproj.io/v1alpha1/Application @ argocd/demo-app-test
    | 08:46:50 | maintenance-window-check | step-1   | ASSERT    | RUN   | lifecycle.keptn.sh/v1/KeptnTask @ chainsaw-moved-bream/*
    | 08:47:31 | maintenance-window-check | step-1   | ASSERT    | DONE  | lifecycle.keptn.sh/v1/KeptnTask @ chainsaw-moved-bream/*
    | 08:47:31 | maintenance-window-check | step-1   | TRY       | DONE  |
    | 08:47:31 | maintenance-window-check | step-1   | CLEANUP   | RUN   |
    | 08:47:31 | maintenance-window-check | step-1   | DELETE    | RUN   | argoproj.io/v1alpha1/Application @ argocd/demo-app-test
    | 08:47:31 | maintenance-window-check | step-1   | DELETE    | OK    | argoproj.io/v1alpha1/Application @ argocd/demo-app-test
    | 08:47:37 | maintenance-window-check | step-1   | DELETE    | DONE  | argoproj.io/v1alpha1/Application @ argocd/demo-app-test
    | 08:47:37 | maintenance-window-check | step-1   | CLEANUP   | DONE  |
    | 08:47:37 | maintenance-window-check | @cleanup | DELETE    | RUN   | v1/Namespace @ chainsaw-moved-bream
    | 08:47:37 | maintenance-window-check | @cleanup | DELETE    | DONE  | v1/Namespace @ chainsaw-moved-bream
--- PASS: chainsaw (0.00s)
    --- PASS: chainsaw/maintenance-window-check (108.74s)
PASS
Tests Summary...
- Passed  tests 1
- Failed  tests 0
- Skipped tests 0
Done.
```

### Summary

In this exercise, you have learned how to use Chainsaw to validate that pre-deployment tasks defined in your KeptnAppContext are correctly executed when the demo app is updated.
