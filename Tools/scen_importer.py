import json

file_name = '194QXGJ-qh'
with open(file_name + '.json', mode='r', encoding='utf-8') as fin:
	obj = json.loads(fin.read(), strict=False)
	
	with open(file_name + '/ArchitectureKinds.json', mode='w', encoding='utf-8') as fout:
		r = []
		for i in obj['GameCommonData']['AllArchitectureKinds']['ArchitectureKinds']:
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
		
	with open(file_name + '/Architectures.json', mode='w', encoding='utf-8') as fout:
		r = []
		states = {x['ID']: x['Name'] for x in obj['States']['GameObjects']}
		for k in obj['Architectures']['GameObjects']:
			position = [int(x) for x in k['ArchitectureAreaString'].split(' ') if x]
			persons = [int(x) for x in k['PersonsString'].split(' ') if x]
			r.append({
				"_Id": k["ID"],
				"Kind": k['KindId'],
				"Name": k['Name'],
				"Title": states[k['StateID']] + ' ' + k['Name'],
				"MapPosition": [position[0], position[1]],
				"PersonList": persons,
				"Population": k['Population'],
				"Fund": k['Fund'],
				"Food": k['Food'],
				"Agriculture": k['Agriculture'],
				"Commerce": k['Commerce'],
				"Morale": k['Morale'],
				"Endurance": k['Endurance']
			})
		fout.write(json.dumps(r, indent=2, ensure_ascii=False, sort_keys=True))
			
	with open(file_name + '/Factions.json', mode='w', encoding='utf-8') as fout:
		r = []
		colors = obj['GameCommonData']['AllColors']
		for k in obj["Factions"]["GameObjects"]:
			archs = [int(x) for x in k['ArchitecturesString'].split(' ') if x]
			r.append({
			  "_Id": k['ID'],
			  "Name": k['Name'],
			  "Color": [colors[k['ColorIndex']]['R'], colors[k['ColorIndex']]['G'], colors[k['ColorIndex']]['B']],
			  "ArchitectureList": archs,
			  "PlayerControlled": False
			})
		fout.write(json.dumps(r, indent=2, ensure_ascii=False, sort_keys=True))
			
	with open(file_name + '/Persons.json', mode='w', encoding='utf-8') as fout:
		r = []
		for k in obj['Persons']['GameObjects']:
			r.append({
				"_Id": k['ID'],
				"Surname": k['SurName'],
				"GivenName": k['GivenName'],
				"CourtesyName": k['CalledName'],
				"Command": k['BaseCommand'],
				"Strength": k['BaseStrength'],
				"Intelligence": k['BaseIntelligence'],
				"Politics": k['BasePolitics'],
				"Glamour": k['BaseGlamour'],
				"Task": 0
			})
		fout.write(json.dumps(r, indent=2, ensure_ascii=False, sort_keys=True))
			
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
	
	
	