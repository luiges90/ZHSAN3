import json
import importlib
skill_data = importlib.import_module('scen_importer_skill_data')

dev = True

def convert_skills(object):
	if k['ID'] in skill_data.SKILLS_LIST:
		return skill_data.SKILLS_LIST[k['ID']]
	else:
		skill_ids = [int(x) if len(x) > 0 else -1 for x in object['SkillsString'].split(' ')]
		title_ids = [int(x) if len(x) > 0 else -1 for x in object['RealTitlesString'].split(' ')]
		stunt_ids = [int(x) if len(x) > 0 else -1 for x in object['StuntsString'].split(' ')]
		skills = []
		if 10 in skill_ids:
			skills.append(10)
		if 11 in skill_ids:
			skills.append(20)
		if 14 in skill_ids:
			skills.append(30)
		if 15 in skill_ids:
			skills.append(40)
		if 16 in skill_ids:
			skills.append(50)
		if 6 in skill_ids:
			skills.append(60)
		if 12 in skill_ids:
			skills.append(70)
		if 71 in title_ids:
			skills.append(100)
		if 70 in title_ids:
			skills.append(110)
		if 74 in title_ids:
			skills.append(120)
		if 42 in title_ids:
			skills.append(130)
		if 11030 in title_ids:
			skills.append(150)
		if 20 in skill_ids:
			skills.append(10500)
		if 21 in skill_ids:
			skills.append(10600)
		if 22 in skill_ids:
			skills.append(10610)
		if 24 in skill_ids:
			skills.append(10501)
		if 230 in title_ids:
			skills.append(10100)
		if 34 in skill_ids:
			skills.append(10200)
		if 35 in skill_ids:
			skills.append(10210)
		if 320 in title_ids:
			skills.append(10220)
		if 300 in title_ids:
			skills.append(10200)
			skills.append(10210)
			skills.append(10220)
		if 44 in skill_ids:
			skills.append(10300)
		if 45 in skill_ids:
			skills.append(10310)
		if 321 in title_ids:
			skills.append(10320)
		if 301 in title_ids:
			skills.append(10300)
			skills.append(10310)
			skills.append(10320)
		if 54 in skill_ids:
			skills.append(10400)
		if 55 in skill_ids:
			skills.append(10410)
		if 322 in title_ids:
			skills.append(10420)
		if 302 in title_ids:
			skills.append(10400)
			skills.append(10410)
			skills.append(10420)
		if 80 in title_ids:
			skills.append(20020)
		if 13 in stunt_ids:
			skills.append(10700)
		if 230 in title_ids:
			skills.append(10710)
		if 106 in skill_ids:
			skills.append(200)
		return skills

output_folder = '../Scenarios/194QXGJ-qh'
file_name = '194QXGJ-qh'
with open('CommonData.json', mode='r', encoding='utf-8') as cfin:
	all_factions = []
	common = json.loads(cfin.read(), strict=False)
	with open(file_name + '.json', mode='r', encoding='utf-8') as fin:
		obj = json.loads(fin.read(), strict=False)
		
		with open(output_folder + '/TerrainDetails.json', mode='w', encoding='utf-8') as fout:
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
		with open(output_folder + '/MovementKinds.json', mode='w', encoding='utf-8') as fout:
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

		with open(output_folder + '/MilitaryKinds.json', mode='w', encoding='utf-8') as fout:
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
		with open(output_folder + '/ArchitectureKinds.json', mode='w', encoding='utf-8') as fout:
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
		with open(output_folder + '/Architectures.json', mode='w', encoding='utf-8') as fout:
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
			
		with open(output_folder + '/Sections.json', mode='w', encoding='utf-8') as fout:
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
				
		with open(output_folder + '/Factions.json', mode='w', encoding='utf-8') as fout:
			r = []
			colors = common['AllColors']
			for k in obj["Factions"]["GameObjects"]:
				sects = [int(x) for x in k['SectionsString'].split(' ') if x]
				r.append({
				  "_Id": k['ID'],
				  "Name": k['Name'],
				  "Leader": k['LeaderID'],
				  "Advisor": -1,
				  "Color": [round(colors[k['ColorIndex']]['R'] / 255.0, 3), round(colors[k['ColorIndex']]['G'] / 255.0, 3), round(colors[k['ColorIndex']]['B'] / 255.0, 3)],
				  "SectionList": sects,
				  "PlayerControlled": False
				})
				all_factions.append({
					"_Id": k['ID'],
					"Name": k['Name']
				})
			if dev:
				r.append({
					"_Id": 100,
					"Name": '耒火',
					"Leader": 1376,
					"Advisor": -1,
					"Color": [255, 0, 255],
					"SectionList": [500],
					"PlayerControlled": False
				})
				all_factions.append({
					"_Id": 100,
					"Name": '耒火'
				})
			fout.write(json.dumps(r, indent=2, ensure_ascii=False, sort_keys=True))
		
		with open(output_folder + '/Persons.json', mode='w', encoding='utf-8') as fout:
			r = []
			for k in obj['Persons']['GameObjects']:
				if k['ID'] >= 8000 and k['ID'] < 9000:
					continue
				if k['ID'] in faction_person_ids:
					status = 1
				elif k['ID'] in no_faction_person_ids:
					status = 2
				else:
					status = 0
				father_id_list = [x for x in obj['FatherIds'] if x['Key'] == k['ID']]
				mother_id_list = [x for x in obj['MotherIds'] if x['Key'] == k['ID']]
				spouse_id_list = [x for x in obj['SpouseIds'] if x['Key'] == k['ID']]
				brother_id_list = [x for x in obj['BrotherIds'] if x['Key'] == k['ID']]
				r.append({
					"_Id": k['ID'],
					"Status": status,
					"Alive": False if k['ID'] >= 7000 and k['ID'] < 8000 else k['Alive'],
					"Gender": k['Sex'],
					"Surname": k['SurName'],
					"GivenName": k['GivenName'],
					"CourtesyName": k['CalledName'],
					"AvailableYear": k['YearAvailable'],
					"BornYear": k['YearBorn'],
					"DeathYear": k['YearDead'],
					"DeadReason": 1 if k['DeadReason'] == 1 else 0,
					"Command": k['BaseCommand'],
					"Strength": k['BaseStrength'],
					"Intelligence": k['BaseIntelligence'],
					"Politics": k['BasePolitics'],
					"Glamour": k['BaseGlamour'],
					"AvailableArchitectureId": k['AvailableLocation'],
					"CommandExperience": 0,
					"StrengthExperience": 0,
					"IntelligenceExperience": 0,
					"PoliticsExperience": 0,
					"GlamourExperience": 0,
					"Popularity": int(min(10000, k['Reputation'] / 5)),
					"Prestige": int(min(10000, k['Reputation'] / 5)),
					"Karma": k['Karma'] * 100,
					"Merit": 0,
					"Task": 0,
					"TaskTarget": -1,
					"ProducingEquipment": None,
					"Skills": convert_skills(k),
					"FatherId": father_id_list[0]['Value'] if len(father_id_list) > 0 else -1,
					"MotherId": mother_id_list[0]['Value'] if len(mother_id_list) > 0 else -1,
					"SpouseIds": [spouse_id_list[0]['Value']] if len(spouse_id_list) > 0 and spouse_id_list[0]['Value'] >= 0 else [],
					"BrotherIds": brother_id_list[0]['Value'] if len(brother_id_list) > 0 else [],
					"Strain": k['Strain']
				})
			fout.write(json.dumps(r, indent=2, ensure_ascii=False, sort_keys=True))
			
		with open(output_folder + '/Biographies.json', mode='w', encoding='utf-8') as fout:
			r = []
			for k in obj['AllBiographies']['Biographys']:
				r.append({
					"_Id": k['Value']['ID'],
					"Text": k['Value']['Brief'] + "\n[color=green]演義：[/color]" + k['Value']['Romance'] + "\n[color=red]史實：[/color]" + k['Value']['History']
				})
			fout.write(json.dumps(r, indent=2, ensure_ascii=False, sort_keys=True))
				
		with open(output_folder + '/Troops.json', mode='w', encoding='utf-8') as fout:
			fout.write(json.dumps([], indent=2, ensure_ascii=False, sort_keys=True))
		
		with open(output_folder + '/Scenario.json', mode='w', encoding='utf-8') as fout:
			fout.write(json.dumps({
			  "CurrentFactionId": 1,
			  "GameData":
			  {
				"Year": obj['Date']['Year'],
				"Month": obj['Date']['Month'],
				"Day": obj['Date']['Day']
			  },
			  "Name": obj['ScenarioTitle'],
			  "Factions": all_factions
			}, indent=2, ensure_ascii=False, sort_keys=True))

