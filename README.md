# micronaut.env.deduction=false doesn't stop k8s/cloud deduction in Micronaut 5

With environment deduction disabled, Micronaut 5 still activates the `k8s` and `cloud` environments when
`KUBERNETES_SERVICE_HOST` is set. Micronaut 4 doesn't.

```
./repro.sh            # Micronaut 5.2.22
./repro.sh 4.10.33    # Micronaut 4.10.33
```

| Environment | 5.2.22 | 4.10.33 |
|---|---|---|
| (nothing set) | `[]` | `[]` |
| `KUBERNETES_SERVICE_HOST=10.0.0.1` | `[k8s, cloud]` | `[k8s, cloud]` |
| `KUBERNETES_SERVICE_HOST=10.0.0.1` `-Dmicronaut.env.deduction=false` | `[k8s, cloud]` | `[]` |
| `KUBERNETES_SERVICE_HOST=10.0.0.1` `MICRONAUT_ENV_DEDUCTION=false` | `[k8s, cloud]` | `[]` |

The app is [`Repro.java`](src/main/java/repro/Repro.java): `ApplicationContext.run()` and print
`getEnvironment().getActiveNames()`. The [workflow](.github/workflows/repro.yml) runs it on both versions.

## Cause

Since micronaut-projects/micronaut-core#12045, `DefaultEnvironmentAndPackageDeducer.deduceEnvironmentsAndPackage` calls
`performEnvironmentDeduction` whether or not deduction is enabled. In 4.x, `DefaultEnvironment` only called it when it
was. The guide's "Disabling Environment Detection" section still says the property "prevents the Micronaut framework
from detecting current environments".

## Why it matters

micronaut-openapi creates an `Environment` at compile time and leaves controllers whose `@Requires(env = ...)` doesn't
match its active names out of the generated spec. On CI runners that are Kubernetes pods (e.g. Actions Runner
Controller), `KUBERNETES_SERVICE_HOST` is set, so every `@Requires(env = "api")` controller disappears from the spec,
and `-Dmicronaut.env.deduction=false` (the workaround from micronaut-projects/micronaut-openapi#1493) no longer helps.
Unsetting `KUBERNETES_SERVICE_HOST` for the build does.
