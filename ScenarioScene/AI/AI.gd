extends Node

class_name AI

var _ai_architecture: AIArchitecture
var _ai_allocation: AIAllocation
var _ai_campaign: AICampaign
var _ai_troop: AITroop

var _scenario

func _init():
	_ai_architecture = AIArchitecture.new(self)
	_ai_campaign = AICampaign.new(self)
	_ai_allocation = AIAllocation.new(self)
	_ai_troop = AITroop.new(self)

func run_faction(faction: Faction, scenario):
	_scenario = scenario
	
	if faction.get_advisor() == null or randf() < 0.1:
		var candidates = faction.get_advisor_candidates()
		if candidates.size() > 0:
			faction._set_advisor(Util.max_by(candidates, "get_intelligence")[1])
	
	for sect in faction.get_sections():
		run_section(faction, sect, scenario)
		
func run_section(faction: Faction, section: Section, scenario):
	if not faction.player_controlled:
		_ai_allocation._allocate_person(section)
		_ai_allocation._allocate_resources(section)

	for arch in section.get_architectures():
		if not faction.player_controlled:
			_ai_architecture._outside_task(arch, scenario)
		if not faction.player_controlled or arch.auto_task:
			_ai_architecture._assign_task(arch, scenario)

	for arch in section.get_architectures():
		if not faction.player_controlled:
			_ai_campaign.defence(arch, section, scenario)
			_ai_campaign.offence(arch, section, scenario)
	
	for troop in section.get_troops():
		if not faction.player_controlled:
			_ai_troop.run_troop(troop, scenario)

		
func _unequipped_military_kind_power() -> float:
	var max_power = 0
	for k in _scenario.military_kinds:
		var kind = _scenario.military_kinds[k]
		if not kind.has_equipments():
			var power = _military_kind_power(kind)
			if power > max_power:
				max_power = power
	return max_power
		
func _military_kind_power(military_kind: MilitaryKind) -> float:
	var offence_factor = military_kind.offence * (sqrt(military_kind.range_max) - sqrt(military_kind.range_min - 1))
	var defence_factor = military_kind.defence
	var siege_factor = military_kind.architecture_attack_factor * 20 * offence_factor
	return offence_factor + defence_factor + siege_factor

func _frontline_connected_archs(arch: Architecture) -> Array:
	var archs = []
	for arch_id in arch.adjacent_archs:
		var other_faction = _scenario.architectures[arch_id].get_belonged_faction()
		if other_faction == null or other_faction.is_enemy_to(arch.get_belonged_faction()):
			archs.append(_scenario.architectures[arch_id])
	return archs

func _estimated_arch_military_power(arch) -> float:
	if arch.troop <= 0:
		return 0.0
	
	var troop_power = 0.0
	var total_equipment = 0
	for mk in arch.equipments:
		var kind = _scenario.military_kinds[mk]
		troop_power += arch.equipments[mk] * _military_kind_power(kind)
	if total_equipment > arch.troop:
		troop_power *= float(arch.troop) / total_equipment
	else:
		troop_power += (arch.troop - total_equipment) * _unequipped_military_kind_power()
	
	var person_power = 0.0
	var persons = arch.get_persons().duplicate()
	persons.sort_custom(self, "__compare_by_person_military_power_desc")
	
	var total_power = 0
	var troop_left = arch.troop
	for p in persons:
		var use_troop = p.get_max_troop_quantity()
		total_power += p.get_troop_leader_ability() * min(troop_left, use_troop) * (troop_power * (float(use_troop) / arch.troop))
		troop_left -= use_troop
		if troop_left <= 0:
			break
	
	return total_power

func __compare_by_person_troop_leader_ability_desc(p, q):
	return p.get_troop_leader_ability() > q.get_troop_leader_ability()
	
func __compare_by_person_troop_leader_ability_asc(p, q):
	return p.get_troop_leader_ability() < q.get_troop_leader_ability()
