import json

dev = True

file_name = '194QXGJ-qh'
with open('CommonData.json', mode='r', encoding='utf-8') as cfin: 
	common = json.loads(cfin.read(), strict=False)
	with open(file_name + '.json', mode='r', encoding='utf-8') as fin:
		obj = json.loads(fin.read(), strict=False)
		
		with open(file_name + '/TerrainDetails.json', mode='w', encoding='utf-8') as fout:
			r = []
			for i in common['AllTerrainDetails']['TerrainDetails']:
				k = i['Value']
				r.append({
					"_Id": k['ID'],
					"Name": k['Name'],
					"TerrainIds": [k['ID']]
				})
			fout.write(json.dumps(r, indent=2, ensure_ascii=False, sort_keys=True))
		"""
		movement_to_save = [] 
		movement_set = {}
		movement_mapping = {}
		movement_mapping_reverse = {}
		with open(file_name + '/MovementKinds.json', mode='w', encoding='utf-8') as fout:
			r = []
			for i in common['AllMilitaryKinds']['MilitaryKinds']:
				k = i['Value']
				costs = {
					"_Id": k['ID'],
					"MovementCosts": {
						1: k['PlainAdaptability'],
						2: k['GrasslandAdaptability'],
						3: k['ForrestAdaptability'],
						4: k['MarshAdaptability'],
						5: k['MountainAdaptability'],
						6: k['WaterAdaptability'],
						7: k['RidgeAdaptability'],
						8: k['WastelandAdaptability'],
						9: k['DesertAdaptability'],
						10: k['CliffAdaptability']
					}
				}
				cost_key = frozenset(costs['MovementCosts'].items())
				if cost_key in movement_set.keys():
					movement_mapping[movement_set[cost_key]].append(k['ID'])
					movement_mapping_reverse[k['ID']] = movement_set[cost_key]
				else:
					movement_set[cost_key] = costs['_Id']
					movement_mapping[costs['_Id']] = [k['ID']]
					movement_mapping_reverse[k['ID']] = costs['_Id']
					movement_to_save.append(costs)
			fout.write(json.dumps(movement_to_save, indent=2, ensure_ascii=False, sort_keys=True))

		with open(file_name + '/MilitaryKinds.json', mode='w', encoding='utf-8') as fout:
			r = []
			for i in common['AllMilitaryKinds']['MilitaryKinds']:
				k = i['Value']
				r.append({
					"_Id": k['ID'],
					"Name": k['Name'],
					"BaseOffence": k['Offence'],
					"BaseDefence": k['Defence'],
					"Offence": k['OffencePerScale'] * k['MaxScale'] / k['MinScale'],
					"Defence": k['DefencePerScale'] * k['MaxScale'] / k['MinScale'],
					"RangeMin": 1 if k['ContactOffence'] else 2,
					"RangeMax": k['OffenceRadius'],
					"MaxQuantityMuiltipler": k['MaxScale'] / 20000,
					"Speed": k['Movability'],
					"Initiative": k['Speed'],
					"EquipmentCost": k['CreateCost'] / 10000,
					"MovementKind": movement_mapping_reverse[k['ID']],
					"FoodPerSoldier": k['FoodPerSoldier'] - 1,
					"TerrainStrength": {
						1: k['PlainRate'],
						2: k['GrasslandRate'],
						3: k['ForrestRate'],
						4: k['MarshRate'],
						5: k['MountainRate'],
						6: k['WaterRate'],
						7: k['RidgeRate'],
						8: k['WastelandRate'],
						9: k['DesertRate'],
						10: k['CliffRate']
					}
				})
			fout.write(json.dumps(r, indent=2, ensure_ascii=False, sort_keys=True))
		"""
		with open(file_name + '/ArchitectureKinds.json', mode='w', encoding='utf-8') as fout:
			r = []
			for i in common['AllArchitectureKinds']['ArchitectureKinds']:
				k = i['Value']
				r.append({
					"_Id": k['ID'],
					"Image": str(k['ID']) + ".png",
					"Name": k['Name'],
					"Agriculture": k['AgricultureBase'] + k['AgricultureUnit'],
					"Commerce": k['CommerceBase'] + k['CommerceUnit'],
					"Morale": k['MoraleBase'] + k['MoraleUnit'],
					"Endurance": k['EnduranceBase'] + k['EnduranceUnit'],
					"Population": k['PopulationBase'] + k['PopulationBoundary'] * 5,
				})
			fout.write(json.dumps(r, indent=2, ensure_ascii=False, sort_keys=True))
			
		faction_person_ids = []
		no_faction_person_ids = []
		if dev:
			faction_person_ids += [1375,1376,1377,1378,1379,1380,1381,1382,1383,1384,1385,1386,1387,1388]
		with open(file_name + '/Architectures.json', mode='w', encoding='utf-8') as fout:
			r = []
			states = {x['ID']: x['Name'] for x in obj['States']['GameObjects']}
			for k in obj['Architectures']['GameObjects']:
				position = [int(x) for x in k['ArchitectureAreaString'].split(' ') if x]
				persons = [int(x) for x in k['PersonsString'].split(' ') if x]
				faction_person_ids += persons
				no_faction_persons = [int(x) for x in k['NoFactionPersonsString'].split(' ') if x]
				no_faction_person_ids += no_faction_persons
				r.append({
					"_Id": k["ID"],
					"Kind": k['KindId'],
					"Name": k['Name'],
					"Title": states[k['StateID']] + ' ' + k['Name'],
					"MapPosition": [position[0], position[1] - 1],
					"PersonList": persons + no_faction_persons if not dev or k["ID"] != 64 else [1375,1376,1377,1378,1379,1380,1381,1382,1383,1384,1385,1386,1387,1388],
					"Population": k['Population'],
					"MilitaryPopulation": k['Population'] * 0.4,
					"Fund": k['Fund'],
					"Food": k['Food'],
					"Agriculture": k['Agriculture'],
					"Commerce": k['Commerce'],
					"Morale": k['Morale'],
					"Endurance": k['Endurance'],
					"Troop": 0,
					"TroopMorale": 0,
					"TroopCombativity": 0,
					"Equipments": {}
				})
			fout.write(json.dumps(r, indent=2, ensure_ascii=False, sort_keys=True))
			
		with open(file_name + '/Sections.json', mode='w', encoding='utf-8') as fout:
			r = []
			for k in obj["Sections"]["GameObjects"]:
				archs = [int(x) for x in k['ArchitecturesString'].split(' ') if x]
				r.append({
				  "_Id": k['ID'],
				  "Name": k['Name'],
				  "ArchitectureList": archs,
				  "TroopList": []
				})
			fout.write(json.dumps(r, indent=2, ensure_ascii=False, sort_keys=True))
				
		with open(file_name + '/Factions.json', mode='w', encoding='utf-8') as fout:
			r = []
			colors = common['AllColors']
			for k in obj["Factions"]["GameObjects"]:
				sects = [int(x) for x in k['SectionsString'].split(' ') if x]
				r.append({
				  "_Id": k['ID'],
				  "Name": k['Name'],
				  "Color": [colors[k['ColorIndex']]['R'], colors[k['ColorIndex']]['G'], colors[k['ColorIndex']]['B']],
				  "SectionList": sects,
				  "PlayerControlled": False
				})
			if dev:
				r.append({
					"_Id": 100,
					"Name": '耒火',
					"Color": [255, 0, 255],
					"SectionList": [500],
					"PlayerControlled": True
				})
			fout.write(json.dumps(r, indent=2, ensure_ascii=False, sort_keys=True))
		
		with open(file_name + '/Persons.json', mode='w', encoding='utf-8') as fout:
			r = []
			for k in obj['Persons']['GameObjects']:
				if k['ID'] in faction_person_ids:
					status = 1
				elif k['ID'] in no_faction_person_ids:
					status = 2
				else:
					status = 0
				r.append({
					"_Id": k['ID'],
					"Status": status,
					"Gender": k['Sex'],
					"Surname": k['SurName'],
					"GivenName": k['GivenName'],
					"CourtesyName": k['CalledName'],
					"Command": k['BaseCommand'],
					"Strength": k['BaseStrength'],
					"Intelligence": k['BaseIntelligence'],
					"Politics": k['BasePolitics'],
					"Glamour": k['BaseGlamour'],
					"Task": 0,
					"ProducingEquipment": None
				})
			fout.write(json.dumps(r, indent=2, ensure_ascii=False, sort_keys=True))
				
		with open(file_name + '/Troops.json', mode='w', encoding='utf-8') as fout:
			fout.write(json.dumps([], indent=2, ensure_ascii=False, sort_keys=True))
		
		with open(file_name + '/Scenario.json', mode='w', encoding='utf-8') as fout:
			fout.write(json.dumps({
			  "CurrentFactionId": 1,
			  "GameData":
			  {
				"Year": obj['Date']['Year'],
				"Month": obj['Date']['Month'],
				"Day": obj['Date']['Day']
			  }
			}, indent=2, ensure_ascii=False, sort_keys=True))

