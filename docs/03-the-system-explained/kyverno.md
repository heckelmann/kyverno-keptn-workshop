# Kyverno

During the workshop, you will interact with the following components:

- [`ClusterPolicy`](#clusterpolicy)

## Kyverno in a Nutshell

Kyverno is a policy engine designed for Kubernetes, it uses validating and configuration webhooks to enrich the admission logic when a resource is submitted to the Kubernetes API server.

Kyverno supports the following policy types:

- Validation
- Mutation
- Generation
- Image Verification
- Cleanup

![Kyverno Overview](kyverno-overview.png)

Read the [Kyverno Introduction](https://kyverno.io/docs/introduction/) to learn more about Kyverno architecture.

## ClusterPolicy

A [ClusterPolicy](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/main/docs/user/crd/index.html#kyverno.io/v1.ClusterPolicy) defines cluster-wide policies. Kyverno will consider such policies regardless of the namespace of the resource being submitted.

The match and exclude statements of a `ClusterPolicy` rule will be first evaluated and if there's a match, the rule logic will be executed.

```yaml
{% raw %}
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: load-test-completed
  annotations:
    argocd.argoproj.io/sync-options: Force=true,Replace=true  
spec:
  rules:
    - name: load-test-completed
      match:
        all:
        - resources:
            kinds:
            - Job/status
            operations:
            - UPDATE
            selector:
              matchLabels:
                generate.kyverno.io/rule-name: match-feature-flag-change
      preconditions:
        any:
          - key: "{{ request.object.status.succeeded || `[]` }}"
            operator: Equals
            value: 1    
      generate:
        apiVersion: metrics.keptn.sh/v1alpha3
        kind: Analysis
        name: service-analysis-kyverno-{{request.object.metadata.resourceVersion}}
        namespace: "demo-app-prod"
        data:
          spec:
            timeframe:
              recent: 1m
            args:
              "workload": "demo-app-prod"
            analysisDefinition:
              name: demo-app-analysis
{% endraw %}
```

The policy defined above will match `Job` status update requests, for jobs that have the `generate.kyverno.io/rule-name` label set to `match-feature-flag-change`.

When a match happens, and if the job is successful, Kyverno will generate a Keptn `Analysis` resource. This resource will be further processed by Keptn.
