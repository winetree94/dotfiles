---
name: oshiz-operations
description: Handle Oshiz (오시즈) operational work, including production data analysis, incidents, deployments, releases, customer support, and product operations. Use current project instructions for implementation and infrastructure facts. Vivident shared infrastructure remains owned by vivident-infrastructure.
---

# Oshiz Operations

Oshiz is operated by Vivident.

## Route the work

- For application, infrastructure, deployment, incident, release, product, asset, catalog, or prompt work, use the Oshiz project at `~/Workspaces/vivident/eevee`. Verify the checkout exists, read its root and affected-directory instructions, then use the project-local skills and current configuration. Do not copy component, environment, or workflow details into this global skill.
- For metrics, funnels, retention, revenue, user behavior, events, chats, Idolive, cohorts, or support investigations that require production data, read [references/data-analysis.md](references/data-analysis.md) and [references/data-model.md](references/data-model.md).
- For Vivident's shared intranet, network, routers, or company runners, use `vivident-infrastructure`. Do not select it solely because Vivident operates Oshiz.

Read only the references required for the request. When one request spans modes, combine their constraints rather than choosing the less restrictive one.

## Preserve service-level boundaries

- Never perform customer-account, payment, entitlement, reward, or content corrections through ad hoc database writes. Locate the supported admin or application workflow; if none is documented, stop and ask for direction.
- Keep production-data privacy and read-only constraints in the data-analysis references. Keep changing application and infrastructure facts in the owning project rather than mirroring them here.
