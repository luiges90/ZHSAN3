import json
import importlib
skill_data = importlib.import_module('scen_importer_skill_data')

dev = True

def prepare_influence_data(common):
    all_skills = common['AllSkills']['Skills']
    all_titles = common['AllTitles']['Titles']
    all_stunts = common['AllStunts']['Stunts']

    influence_skills = {}
    for t in all_skills:
        influences = [int(x) for x in filter(None, t['Value']['InfluencesString'].split(' '))]
        for i in influences:
            if i not in influence_skills:
                influence_skills[i] = set()
            influence_skills[i].add(t['Key'])

    influence_titles = {}
    for t in all_titles:
        influences = [int(x) for x in filter(None, t['Value']['InfluencesString'].split(' '))]
        for i in influences:
            if i not in influence_titles:
                influence_titles[i] = set()
            influence_titles[i].add(t['Key'])

    influence_stunts = {}
    for t in all_stunts:
        influences = [int(x) for x in filter(None, t['Value']['InfluencesString'].split(' '))]
        for i in influences:
            if i not in influence_stunts:
                influence_stunts[i] = set()
            influence_stunts[i].add(t['Key'])

    return (influence_skills, influence_titles, influence_stunts)

def convert_skill(new_list, influences, newid, conversion, required_influence = []):
    for inf in influences:
        if len(required_influence) > 0:
            for req in required_influence:
                if not req in inf[1]:
                    continue
        for c in conversion:
            if c in inf[0]:
                for _ in inf[0][c].intersection(set(inf[1])):
                    if newid not in new_list:
                        new_list[newid] = 0
                    new_list[newid] += conversion[c]

def convert_skills(object, influence_data):
    influence_skills = influence_data[0]
    influence_titles = influence_data[1]
    influence_stunts = influence_data[2]

    if k['ID'] in skill_data.SKILLS_LIST:
        return skill_data.SKILLS_LIST[k['ID']]
    else:
        skill_ids = [int(x) for x in filter(
            None, object['SkillsString'].split(' '))]
        title_ids = [int(x) for x in filter(
            None, object['RealTitlesString'].split(' '))]
        stunt_ids = [int(x) for x in filter(
            None, object['StuntsString'].split(' '))]

        influences = [(influence_skills, skill_ids), 
                      (influence_titles, title_ids),
                      (influence_stunts, stunt_ids)]

        new_skills = {}
        convert_skill(new_skills, influences, 10, {0: 2, 10: 5, 70: 6, 80: 10})
        convert_skill(new_skills, influences, 20, {1: 2, 11: 5, 71: 6, 81: 10})
        convert_skill(new_skills, influences, 30, {4: 2, 14: 5, 74: 6, 84: 10})
        convert_skill(new_skills, influences, 40, {5: 2, 15: 5, 75: 6, 85: 10})
        convert_skill(new_skills, influences, 50, {91: 5})
        convert_skill(new_skills, influences, 60, {90: 5})
        convert_skill(new_skills, influences, 70, {2: 2, 12: 5, 72: 6, 82: 10})
        convert_skill(new_skills, influences, 110, {20: 3, 60: 3})
        convert_skill(new_skills, influences, 120, {21: 3, 61: 3})
        convert_skill(new_skills, influences, 130, {124: 1})
        convert_skill(new_skills, influences, 140, {122: 5})
        convert_skill(new_skills, influences, 150, {30: 1})
        convert_skill(new_skills, influences, 200, {466: 1})

        convert_skill(new_skills, influences, 10100, {6470: 5})
        convert_skill(new_skills, influences, 10200, {410: 2}, [290])
        convert_skill(new_skills, influences, 10210, {420: 2}, [290])
        convert_skill(new_skills, influences, 10220, {250: 5, 251: 2}, [290])
        convert_skill(new_skills, influences, 10300, {410: 2}, [291])
        convert_skill(new_skills, influences, 10310, {420: 2}, [291])
        convert_skill(new_skills, influences, 10320, {250: 5, 251: 2}, [291])
        convert_skill(new_skills, influences, 10400, {410: 2}, [292])
        convert_skill(new_skills, influences, 10410, {420: 2}, [292])
        convert_skill(new_skills, influences, 10420, {250: 2, 251: 5, 252: 10}, [292])
        convert_skill(new_skills, influences, 10500, {250: 2, 251: 5, 252: 10}, [292])
        convert_skill(new_skills, influences, 10501, {250: 2, 251: 5, 252: 10}, [290, 291])
        convert_skill(new_skills, influences, 10600, {202: 2, 222: 2})
        convert_skill(new_skills, influences, 10610, {204: 2, 224: 2})
        convert_skill(new_skills, influences, 10700, {4020: 1, 4021: 2, 4022: 5, 4023: 10, 4024: 20})
        convert_skill(new_skills, influences, 10710, {607: 5})
        convert_skill(new_skills, influences, 10800, {6100: 1, 6101: 2, 6102: 3, 6103: 4})
        convert_skill(new_skills, influences, 10810, {260: 1, 261: 10})
        convert_skill(new_skills, influences, 11000, {400: 1, 401: 2, 402: 3, 403: 4, 404: 6})
        convert_skill(new_skills, influences, 11000, {405: 1, 406: 2, 407: 3, 408: 4, 409: 6})

        return new_skills

output_folder = '../Scenarios/194QXGJ-qh'
file_name = '194QXGJ-qh'
with open('CommonData.json', mode='r', encoding='utf-8') as cfin:
    all_factions = []
    common = json.loads(cfin.read(), strict=False)
    influence_data = prepare_influence_data(common)
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
                  "PlayerControlled": False,
                  "Capital": k['CapitalID']
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
                    "PlayerControlled": False,
                    "Capital": 64
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
                    "InternalExperience": 0,
                    "CombatExperience": 0,
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
                    "Skills": convert_skills(k, influence_data),
                    "FatherId": father_id_list[0]['Value'] if len(father_id_list) > 0 else -1,
                    "MotherId": mother_id_list[0]['Value'] if len(mother_id_list) > 0 else -1,
                    "SpouseIds": [spouse_id_list[0]['Value']] if len(spouse_id_list) > 0 and spouse_id_list[0]['Value'] >= 0 else [],
                    "BrotherIds": brother_id_list[0]['Value'] if len(brother_id_list) > 0 else [],
                    "Strain": k['Strain'],
                    "Ideal": k['Ideal'],
                    "LoyaltyShift": 0,
                    "Ambition": k['Ambition'] * 20 + 10,
                    "Morality": k['PersonalLoyalty'] * 20 + 10
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

