extends Node

class_name AI

var _ai_architecture: AIArchitecture

func _init():
	_ai_architecture = AIArchitecture.new(self)

func run_faction(faction: Faction, scenario):
	for sect in faction.get_sections():
		run_section(faction, sect, scenario)
		
func run_section(faction: Faction, section: Section, scenario):
	if not faction.player_controlled:
		_ai_architecture._allocate_person(section)
	for arch in section.get_architectures():
		if not faction.player_controlled or arch.auto_task:
			_ai_architecture._assign_task(arch, scenario)

func military_kind_power(military_kind: MilitaryKind) -> float:
	var offence_factor = military_kind.offence * (sqrt(military_kind.range_max) - sqrt(military_kind.range_min - 1))
	var defence_factor = military_kind.defence
	return offence_factor + defence_factor

