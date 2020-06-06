extends Node
class_name AIAllocation

var _ai

func _init(ai):
	_ai = ai

func _allocate_person(section: Section):
	# TODO consider frontlines, person ability etc
	var person_per_arch = section.get_persons().size() / section.get_architectures().size()
	for a in section.get_architectures():
		if a.get_persons().size() < person_per_arch:
			var archs = section.get_architectures()
			archs.shuffle()
			for a2 in archs:
				if a.id == a2.id:
					continue
				var persons = a2.get_persons()
				persons.shuffle()
				while persons.size() > person_per_arch:
					var p = persons.pop_back()
					p.move_to_architecture(a)
					if a.get_persons().size() >= person_per_arch:
						break
 
