from typing import List, Dict, Any

STRANGLER_FIG_PHASES = [
    "Identify & Scope",
    "Extract & Parallel Run",
    "Route Traffic",
    "Decommission Legacy",
    "Verify & Stabilize"
]

def generate_plan(monolith: dict, services: dict, analysis: dict) -> dict:
    modules = {m["id"]: m for m in monolith.get("modules", [])}
    svc_list = services.get("services", [])
    module_risks = {r["module_id"]: r for r in analysis.get("module_risks", [])}

    # Sort services by priority (lower number = migrate first), then by risk (low risk first)
    def service_sort_key(svc):
        mods = svc.get("mapped_modules", [])
        avg_risk = sum(
            {"low": 1, "medium": 2, "high": 3}.get(module_risks.get(m, {}).get("risk_level", "medium"), 2)
            for m in mods
        ) / max(len(mods), 1)
        return (svc.get("priority", 99), avg_risk)

    ordered_services = sorted(svc_list, key=service_sort_key)

    steps = []
    step_num = 1

    # Phase 0: Preparation
    steps.append({
        "step": step_num,
        "phase": "Preparation",
        "title": "Audit & Document the Monolith",
        "description": f"Document all {len(modules)} modules, their owners, and SLAs. Set up monitoring and baseline performance metrics.",
        "actions": [
            "Map all module boundaries and interfaces",
            "Document existing API contracts",
            "Set up distributed tracing (e.g., Jaeger, Zipkin)",
            "Define success metrics for each migration phase",
            "Create rollback playbooks"
        ],
        "estimated_duration": "1-2 weeks",
        "risk_level": "low",
        "downtime_risk": False,
        "continuity_notes": "No changes to production. Pure observation phase."
    })
    step_num += 1

    steps.append({
        "step": step_num,
        "phase": "Preparation",
        "title": "Set Up Infrastructure",
        "description": "Provision container orchestration, CI/CD pipelines, API gateway, and service mesh.",
        "actions": [
            "Set up Kubernetes or Docker Swarm cluster",
            "Configure API Gateway (Kong, NGINX, or AWS API Gateway)",
            "Set up CI/CD pipelines per service",
            "Configure service discovery (Consul or Kubernetes DNS)",
            "Set up centralized logging (ELK or Loki)"
        ],
        "estimated_duration": "1-2 weeks",
        "risk_level": "low",
        "downtime_risk": False,
        "continuity_notes": "Infrastructure parallel to production. No impact."
    })
    step_num += 1

    # Phase 1-N: Per-service migration
    for svc in ordered_services:
        mods = svc.get("mapped_modules", [])
        svc_risks = [module_risks.get(m, {}) for m in mods]
        max_risk = "high" if any(r.get("risk_level") == "high" for r in svc_risks) else \
                   "medium" if any(r.get("risk_level") == "medium" for r in svc_risks) else "low"
        mod_names = [modules.get(m, {}).get("name", m) for m in mods]

        downtime_risk = max_risk == "high" or any(
            r.get("incoming_deps", 0) > 3 for r in svc_risks
        )

        actions = [
            f"Create new {svc['name']} repository and skeleton",
            f"Implement business logic from: {', '.join(mod_names)}",
            "Write unit and integration tests (target >80% coverage)",
            "Deploy new service alongside monolith (Strangler Fig)",
            "Route a percentage of traffic to new service (5% → 25% → 50% → 100%)",
            "Monitor for errors, latency regressions, and data inconsistencies",
            "Decommission corresponding monolith modules once stable"
        ]

        if max_risk == "high":
            actions.insert(3, "Run shadow mode: mirror production traffic without serving responses")
            actions.append("Conduct load testing before increasing traffic share")

        steps.append({
            "step": step_num,
            "phase": "Extraction",
            "title": f"Extract {svc['name']}",
            "description": f"Migrate modules [{', '.join(mod_names)}] into the standalone {svc['name']}.",
            "service_id": svc["id"],
            "service_name": svc["name"],
            "technology": svc.get("technology", "Python/FastAPI"),
            "port": svc.get("port"),
            "actions": actions,
            "estimated_duration": "2-3 weeks" if max_risk == "high" else "1-2 weeks",
            "risk_level": max_risk,
            "downtime_risk": downtime_risk,
            "continuity_notes": _continuity_note(svc, max_risk, downtime_risk)
        })
        step_num += 1

    # Final phase
    steps.append({
        "step": step_num,
        "phase": "Completion",
        "title": "Decommission Monolith",
        "description": "Retire the monolith after all services are stable and fully traffic-switched.",
        "actions": [
            "Confirm 100% traffic routed through microservices",
            "Run final regression test suite",
            "Archive monolith codebase (do not delete immediately)",
            "Shut down monolith servers",
            "Update all documentation and runbooks",
            "Conduct post-migration retrospective"
        ],
        "estimated_duration": "1 week",
        "risk_level": "medium",
        "downtime_risk": False,
        "continuity_notes": "Traffic already fully migrated. Monolith shutdown is low-risk at this point."
    })

    # Calculate totals
    high_steps = sum(1 for s in steps if s["risk_level"] == "high")
    total_weeks_min = 2 + len(ordered_services) * 1 + 1
    total_weeks_max = 4 + len(ordered_services) * 3 + 1

    continuity_risks = []
    if analysis.get("shared_data_risk"):
        continuity_risks.append({
            "risk": "Shared Database",
            "impact": "Multiple services reading/writing same DB causes tight coupling",
            "mitigation": "Use Database-per-Service pattern. Introduce an API layer over shared data first.",
            "severity": "high"
        })
    if analysis.get("circular_dependencies"):
        continuity_risks.append({
            "risk": "Circular Dependencies",
            "impact": "Circular deps prevent clean service boundaries",
            "mitigation": "Break cycles by introducing an event-driven approach or shared library.",
            "severity": "high"
        })
    if analysis.get("cross_service_dependencies"):
        continuity_risks.append({
            "risk": "Tight Cross-Service Coupling",
            "impact": "Services calling each other synchronously creates cascading failures",
            "mitigation": "Use async messaging (Kafka/RabbitMQ) for non-critical calls. Apply circuit breakers.",
            "severity": "medium"
        })
    if analysis.get("unmapped_modules"):
        continuity_risks.append({
            "risk": "Unmapped Modules",
            "impact": f"{len(analysis['unmapped_modules'])} modules have no target service assigned",
            "mitigation": "Assign all modules to a service before migration starts.",
            "severity": "medium"
        })

    return {
        "pattern": "Strangler Fig Pattern",
        "pattern_description": "Incrementally replace monolith functionality by routing traffic to new microservices while keeping the monolith running.",
        "steps": steps,
        "continuity_risks": continuity_risks,
        "summary": {
            "total_steps": len(steps),
            "total_services_to_migrate": len(ordered_services),
            "high_risk_steps": high_steps,
            "estimated_duration_weeks": f"{total_weeks_min}–{total_weeks_max}",
            "strategy": "Strangler Fig Pattern",
            "recommended_team_size": max(3, len(ordered_services))
        }
    }


def _continuity_note(svc, risk_level, downtime_risk):
    name = svc["name"]
    if downtime_risk:
        return (f"⚠️ {name} is high-risk. Use shadow mode and gradual traffic shifting. "
                f"Maintain rollback capability for at least 2 weeks post-cutover.")
    elif risk_level == "medium":
        return f"Use feature flags to control traffic routing to {name}. Monitor error rates closely."
    else:
        return f"{name} is low-risk. Can migrate with minimal ceremony. A/B test for 1 week before full cutover."
