<p align="center">
  <a href="https://infrapi.io/">
    <img src="https://infrapi.io/infrapi.png" alt="InfraPI" width="96">
  </a>
</p>

<h1 align="center">InfraPI</h1>

<p align="center">
  <strong>Self-service infrastructure, as APIs.</strong><br>
  Open source · MIT · Internal developer platform
</p>

<p align="center">
  <a href="https://infrapi.io/">Website</a> ·
  <a href="https://infrapi.io/products/">Products</a> ·
  <a href="https://infrapi.io/learn/">Learn</a>
</p>

---

InfraPI turns the infrastructure products you already run into governed,
multi-tenant REST APIs. One URL layout, one token, one RBAC model, an OpenAPI
contract enforced on every request — so a portal, a CLI or a pipeline creates
what it needs without a ticket.

```bash
$ tofu-api serve -config aws.yaml

$ curl -X POST localhost:8080/aws/v1/namespaces/acme/instance \
    -H 'Authorization: Bearer …' \
    -d '{"ami": "ami-0abc12de", "instance_type": "t3.micro"}'

201 Created
{ "id": "i-0f3c9a1e2b4d5e6f7", "instance_type": "t3.micro", "private_ip": "10.0.1.23", … }
```

## The problem

- **Tickets instead of APIs** — teams wait days for a host, a DNS record or a
  dashboard that a script could create in seconds.
- **One-off integrations** — every internal API in front of a product is a
  hand-written client of that product, to keep in step with each of its releases.
- **Tenancy bolted on** — who may create what, in which team's space, is
  re-invented in each tool, or left to shared admin credentials.

## Products

Each one stands alone. Together, they are a platform.

| | Product | | What it does |
|---|---|---|---|
| 🛡️ | **[Kayra](https://github.com/infrapi/kayra)** | `v0.5.0` preview | Identity, namespaces and RBAC for your platform. Who callers are, which tenant they act in, what they may do there, and which APIs each tenant is subscribed to. · [Docs](https://infrapi.io/products/kayra/) |
| 🔌 | **[tofu-api](https://github.com/infrapi/tofu-api)** | `v0.8.0` early | Any OpenTofu or Terraform provider as a REST API. An OpenAPI contract generated from the provider's schemas, rules in one YAML file per provider, no code per resource. · [Docs](https://infrapi.io/products/tofu-api/) |
| 🧱 | **[lib](https://github.com/infrapi/lib)** | `v0.15.0` preview | The Go foundation of every InfraPI service. URL layout, auth, contract enforcement, RFC 9457 errors, metrics, tracing and Vault, shared by every service. · [Docs](https://infrapi.io/products/lib/) |

## How it fits together

```
 Callers      Portal · CLI · CI/CD · Scripts
                  │  bearer token · REST · OpenAPI
                  ▼
 APIs         tofu-api ─┬─ Your services   ──►  Kayra
              (any      │  (built on lib)       may this caller do this?
              provider) │                       identity · namespaces · RBAC · API catalog
                  │  provider plugin protocol · credentials per namespace from Vault
                  ▼
 Products     AWS · Grafana · …any provider

 Foundation   lib — URL layout, auth, contracts, errors, metrics, tracing, Vault
```

Every API shares one surface:
`/apis/{group}/{version}/namespaces/{ns}/{resource}` — OpenAPI enforced,
RFC 9457 errors, Prometheus metrics and OpenTelemetry traces.

## From a Terraform provider to a governed API in three steps

**1. Describe** — pick the resource types of an OpenTofu provider to expose,
and the rules over them, in one YAML file.

```yaml
provider:
  source: hashicorp/aws
  version: 6.0.0
  config:
    region: ${AWS_REGION}
resources:
  aws_instance:
    attributes:
      instance_type:
        enum: [t3.micro, t3.small]
```

**2. Serve** — one binary for every provider. The OpenAPI contract is
generated from the provider's schemas at start.

```bash
systemctl enable --now tofu-api@aws
# contract at /-/openapi/aws/v1.json
# Swagger UI at /-/docs
```

**3. Call** — any caller gets a plain REST API, checked against the
contract, scoped to its namespace.

```bash
curl -X POST :8080/aws/v1/namespaces/acme/instance \
  -d '{"ami":"ami-0abc…", "instance_type":"t3.micro"}'
```

## Why InfraPI

- **Composable** — adopt one piece at a time: tofu-api alone in front of one
  product, Kayra for tenancy and RBAC, lib for your own services.
- **Contract-first** — every API serves its OpenAPI contract and rejects any
  request that does not match it, before a handler runs.
- **Multi-tenant by design** — namespaces are the tenants. With tofu-api each
  one runs with its own credentials from Vault, so isolation comes from the
  credentials.
- **Plain to operate** — single Go binaries, systemd units, RPM and DEB
  packages, Prometheus metrics and OpenTelemetry traces. No cluster required.

## Get started

- 🎓 [Turn the AWS provider into an EC2 instance API](https://infrapi.io/learn/generate-an-api-contract/)
  — beginner, 15 min, no AWS account needed.
- 📚 Browse all [hands-on tutorials](https://infrapi.io/learn/)
  and the [product documentation](https://infrapi.io/products/).

## Contributing

Every InfraPI product is developed in the open under the MIT license. Use it,
fork it, open an issue or send a pull request:
[Kayra](https://github.com/infrapi/kayra/issues) ·
[tofu-api](https://github.com/infrapi/tofu-api/issues) ·
[lib](https://github.com/infrapi/lib/issues) ·
[docs](https://github.com/infrapi/docs).
