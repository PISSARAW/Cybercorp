package cybercorp.topology

import rego.v1

expected_vms := {"CC-PFS01", "CC-DC01", "CC-W11-01", "CC-KALI01"}
expected_switches := {"CC-LAN", "CC-AUDIT", "CC-WAN-MAINT"}

deny contains "V00: schema_version doit valoir 1" if {
    object.get(input, "schema_version", null) != 1
}

deny contains "V00: profil audit requis" if {
    object.get(input, "profile", null) != "audit"
}

deny contains "V00: switches doit être une liste présente" if {
    not is_array(object.get(input, "switches", null))
}

deny contains "V00: vms doit être une liste présente" if {
    not is_array(object.get(input, "vms", null))
}

deny contains msg if {
    name := expected_switches[_]
    matches := [s | s := input.switches[_]; object.get(s, "name", null) == name]
    count(matches) != 1
    msg := sprintf("V05: commutateur %s absent ou dupliqué", [name])
}

deny contains msg if {
    name := expected_vms[_]
    matches := [v | v := input.vms[_]; object.get(v, "name", null) == name]
    count(matches) != 1
    msg := sprintf("V05: VM %s absente ou dupliquée", [name])
}

deny contains msg if {
    sw := input.switches[_]
    name := object.get(sw, "name", "")
    startswith(name, "CC-")
    not name in expected_switches
    msg := sprintf("V05: commutateur CyberCorp inattendu: %s", [name])
}

deny contains msg if {
    vm := input.vms[_]
    name := object.get(vm, "name", "")
    startswith(name, "CC-")
    not name in expected_vms
    msg := sprintf("V05: VM CyberCorp inattendue: %s", [name])
}

deny contains msg if {
    name := {"CC-LAN", "CC-AUDIT"}[_]
    sw := input.switches[_]
    sw.name == name
    object.get(sw, "type", null) != "Private"
    msg := sprintf("V01: %s doit être Private", [name])
}

deny contains "V05: CC-WAN-MAINT doit être Internal" if {
    sw := input.switches[_]
    sw.name == "CC-WAN-MAINT"
    object.get(sw, "type", null) != "Internal"
}

deny contains msg if {
    name := {"CC-DC01", "CC-W11-01", "CC-KALI01"}[_]
    vm := input.vms[_]
    vm.name == name
    not is_array(object.get(vm, "adapters", null))
    msg := sprintf("V02: liste des cartes absente sur %s", [name])
}

deny contains msg if {
    name := {"CC-DC01", "CC-W11-01", "CC-KALI01"}[_]
    vm := input.vms[_]
    vm.name == name
    count(vm.adapters) != 1
    msg := sprintf("V02: %s doit avoir exactement une carte", [name])
}

deny contains msg if {
    name := {"CC-DC01", "CC-W11-01", "CC-KALI01"}[_]
    vm := input.vms[_]
    vm.name == name
    adapter := vm.adapters[_]
    expected := object.get({"CC-DC01": "CC-LAN", "CC-W11-01": "CC-LAN", "CC-KALI01": "CC-AUDIT"}, name, null)
    object.get(adapter, "switch", null) != expected
    msg := sprintf("V02/V03: %s doit être uniquement sur %s", [name, expected])
}

deny contains msg if {
    name := {"CC-DC01", "CC-W11-01", "CC-KALI01"}[_]
    vm := input.vms[_]
    vm.name == name
    adapter := vm.adapters[_]
    object.get(adapter, "connected", null) != true
    msg := sprintf("V02/V03: carte %s absente, déconnectée ou état inconnu", [name])
}

deny contains "V04: cartes pfSense absentes ou mal formées" if {
    vm := input.vms[_]
    vm.name == "CC-PFS01"
    not is_array(object.get(vm, "adapters", null))
}

deny contains "V04: pfSense doit avoir trois cartes en profil audit" if {
    vm := input.vms[_]
    vm.name == "CC-PFS01"
    count(vm.adapters) != 3
}

deny contains msg if {
    vm := input.vms[_]
    vm.name == "CC-PFS01"
    name := {"CC-LAN", "CC-AUDIT"}[_]
    matches := [a | a := vm.adapters[_]; object.get(a, "switch", null) == name; object.get(a, "connected", null) == true]
    count(matches) != 1
    msg := sprintf("V04: pfSense doit avoir une carte connectée à %s", [name])
}

deny contains "V04: troisième carte pfSense non déconnectée" if {
    vm := input.vms[_]
    vm.name == "CC-PFS01"
    disconnected := [a | a := vm.adapters[_]; object.get(a, "switch", "missing") == null; object.get(a, "connected", null) == false]
    count(disconnected) != 1
}
