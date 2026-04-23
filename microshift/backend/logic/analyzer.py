from typing import List, Dict, Any

def analyze(monolith: dict, services: dict) -> dict:
    modules = {m["id"]: m for m in monolith.get("modules", [])}
    dependencies = monolith.get("dependencies", [])
    svc_list = services.get("services", [])

    # Build adjacency
    incoming = {m: [] for m in modules}
    outgoing = {m: [] for m in modules}
    for dep in dependencies:
        f, t = dep["from_module"], dep["to_module"]
        if f in outgoing:
            outgoing[f].append(dep)
        if t in incoming:
            incoming[t].append(dep)

    # Score each module's coupling
    module_risk = {}
    for mid, mod in modules.items():
        in_count = len(incoming[mid])
        out_count = len(outgoing[mid])
        high_strength = sum(1 for d in incoming[mid] + outgoing[mid] if d.get("strength") == "high")
        complexity_score = {"low": 1, "medium": 2, "high": 3}.get(mod.get("complexity", "medium"), 2)
        risk_score = (in_count * 1.5) + (out_count * 1.0) + (high_strength * 2) + (complexity_score * 1.5)
        level = "low" if risk_score < 5 else "medium" if risk_score < 10 else "high"
        module_risk[mid] = {
            "module_id": mid,
            "module_name": mod["name"],
            "risk_score": round(risk_score, 1),
            "risk_level": level,
            "incoming_deps": in_count,
            "outgoing_deps": out_count,
            "high_strength_connections": high_strength,
            "complexity": mod.get("complexity", "medium"),
            "layer": mod.get("layer", "business")
        }

    # Detect unmapped modules
    mapped_modules = set()
    for svc in svc_list:
        for mod_id in svc.get("mapped_modules", []):
            mapped_modules.add(mod_id)

    unmapped = [mid for mid in modules if mid not in mapped_modules]

    # Circular dependency detection (simple DFS)
    cycles = _detect_cycles(modules, dependencies)

    # Shared data risks
    data_layer_modules = [m for m, info in modules.items() if info.get("layer") == "data"]
    shared_data_risk = len(data_layer_modules) > 0

    # Service coupling (cross-service dependencies)
    module_to_service = {}
    for svc in svc_list:
        for mod_id in svc.get("mapped_modules", []):
            module_to_service[mod_id] = svc["id"]

    cross_service_deps = []
    for dep in dependencies:
        f_svc = module_to_service.get(dep["from_module"])
        t_svc = module_to_service.get(dep["to_module"])
        if f_svc and t_svc and f_svc != t_svc:
            cross_service_deps.append({
                "from_service": f_svc,
                "to_service": t_svc,
                "via_modules": f"{dep['from_module']} → {dep['to_module']}",
                "strength": dep.get("strength", "medium"),
                "type": dep.get("type", "uses")
            })

    # Overall risk summary
    high_risk_count = sum(1 for r in module_risk.values() if r["risk_level"] == "high")
    medium_risk_count = sum(1 for r in module_risk.values() if r["risk_level"] == "medium")
    overall_risk = "high" if high_risk_count >= 2 or cycles else "medium" if high_risk_count >= 1 or medium_risk_count >= 3 else "low"

    return {
        "overall_risk": overall_risk,
        "module_risks": list(module_risk.values()),
        "unmapped_modules": unmapped,
        "circular_dependencies": cycles,
        "shared_data_risk": shared_data_risk,
        "cross_service_dependencies": cross_service_deps,
        "summary": {
            "total_modules": len(modules),
            "total_dependencies": len(dependencies),
            "total_services": len(svc_list),
            "high_risk_modules": high_risk_count,
            "medium_risk_modules": medium_risk_count,
            "low_risk_modules": len(modules) - high_risk_count - medium_risk_count,
            "unmapped_count": len(unmapped),
            "cross_service_dep_count": len(cross_service_deps),
            "has_cycles": bool(cycles),
        }
    }


def _detect_cycles(modules: dict, dependencies: list) -> list:
    graph = {m: [] for m in modules}
    for dep in dependencies:
        if dep["from_module"] in graph:
            graph[dep["from_module"]].append(dep["to_module"])

    visited = set()
    rec_stack = set()
    cycles = []

    def dfs(node, path):
        visited.add(node)
        rec_stack.add(node)
        for neighbor in graph.get(node, []):
            if neighbor not in visited:
                dfs(neighbor, path + [neighbor])
            elif neighbor in rec_stack:
                cycle_start = path.index(neighbor) if neighbor in path else 0
                cycle = path[cycle_start:] + [neighbor]
                cycles.append(" → ".join(cycle))
        rec_stack.discard(node)

    for node in modules:
        if node not in visited:
            dfs(node, [node])

    return list(set(cycles))
