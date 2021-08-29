import os
import json
import importlib
skill_data = importlib.import_module('scen_importer_skill_data')

file_name = '194QXGJ-qh'
output_folder = '../Scenarios/' + file_name

import_persons = True

# TODO skills to add: 10800, 10810, 20000, 20010, 20020
def convert_specials(p, title_level):
    if k['ID'] in skill_data.SKILLS_LIST:
        return skill_data.SKILLS_LIST[k['ID']]
    else:
        skill_ids = [int(x) for x in filter(None, p['SkillsString'].split(' '))]
        title_ids = [int(x) for x in filter(None, p['RealTitlesString'].split(' '))]
        stunt_ids = [int(x) for x in filter(None, p['StuntsString'].split(' '))]

        new_skills = {}
        new_stunts = {}
        skill_classes_total = {0: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0, 10: 0}

        if 0 in skill_ids:
            new_skills[10] = max(new_skills.get(10, 0), 1 + max(0, ((p['BasePolitics'] * 0.5 + p['BaseGlamour'] * 0.5) - 50) / 30))
            skill_classes_total[0] += 1
        if 1 in skill_ids:
            new_skills[20] = max(new_skills.get(20, 0), 1 + max(0, ((p['BaseIntelligence'] * 0.5 + p['BaseGlamour'] * 0.5) - 50) / 30))
            skill_classes_total[0] += 1
        if 2 in skill_ids:
            new_skills[70] = max(new_skills.get(70, 0), 1 + max(0, ((p['BaseIntelligence'] * 0.5 + p['BasePolitics'] * 0.5) - 50) / 30))
            skill_classes_total[0] += 1
        if 3 in skill_ids:
            new_skills[30] = max(new_skills.get(30, 0), 1 + max(0, ((p['BaseCommand'] * 0.5 + p['BaseStrength'] * 0.5) - 50) / 30))
            skill_classes_total[0] += 1
        if 4 in skill_ids:
            new_skills[30] = max(new_skills.get(30, 0), 1 + max(0, ((p['BaseIntelligence'] * 0.5 + p['BaseGlamour'] * 0.5) - 50) / 30))
            skill_classes_total[0] += 1
        if 5 in skill_ids:
            new_skills[40] = max(new_skills.get(40, 0), 1 + max(0, ((p['BaseStrength'] * 0.5 + p['BaseIntelligence'] * 0.5) - 50) / 30))
            skill_classes_total[0] += 1
        if 6 in skill_ids:
            new_skills[60] = max(new_skills.get(60, 0), 1 + max(0, ((p['BaseCommand'] * 0.5 + p['BaseStrength'] * 0.5) - 50) / 20))
            skill_classes_total[0] += 1

        if 10 in skill_ids:
            new_skills[10] = max(new_skills.get(10, 0), 1 + max(0, ((p['BasePolitics'] * 0.5 + p['BaseGlamour'] * 0.5) - 60) / 20))
            skill_classes_total[0] += 2
        if 11 in skill_ids:
            new_skills[20] = max(new_skills.get(20, 0), 1 + max(0, ((p['BaseIntelligence'] * 0.5 + p['BaseGlamour'] * 0.5) - 60) / 20))
            skill_classes_total[0] += 2
        if 12 in skill_ids:
            new_skills[70] = max(new_skills.get(70, 0), 1 + max(0, ((p['BaseIntelligence'] * 0.5 + p['BasePolitics'] * 0.5) - 60) / 20))
            skill_classes_total[0] += 2
        if 13 in skill_ids:
            new_skills[30] = max(new_skills.get(30, 0), 1 + max(0, ((p['BaseCommand'] * 0.5 + p['BaseStrength'] * 0.5) - 60) / 20))
            skill_classes_total[0] += 2
        if 14 in skill_ids:
            new_skills[30] = max(new_skills.get(30, 0), 1 + max(0, ((p['BaseIntelligence'] * 0.5 + p['BaseGlamour'] * 0.5) - 60) / 20))
            skill_classes_total[0] += 2
        if 15 in skill_ids:
            new_skills[40] = max(new_skills.get(40, 0), 1 + max(0, ((p['BaseStrength'] * 0.5 + p['BaseIntelligence'] * 0.5) - 60) / 20))
            skill_classes_total[0] += 2
        if 16 in skill_ids:
            new_skills[50] = max(new_skills.get(50, 0), 1 + max(0, ((p['BaseGlamour'] * 0.5 + p['BaseStrength'] * 0.5) - 60) / 20))
            skill_classes_total[0] += 2
        if 1 in skill_ids and 11 in skill_ids:
            new_skills[100] = max(new_skills.get(100, 0), max(0, ((p['BaseIntelligence'] * 0.5 + p['BaseGlamour'] * 0.5) - 70) / 15))
        if 0 in skill_ids and 10 in skill_ids:
            new_skills[110] = max(new_skills.get(110, 0), max(0, ((p['BasePolitics'] * 0.5 + p['BaseGlamour'] * 0.5) - 70) / 15))
        if 2 in skill_ids and 12 in skill_ids:
            new_skills[120] = max(new_skills.get(120, 0), max(0, ((p['BaseIntelligence'] * 0.75 + p['BasePolitics'] * 0.25) - 70) / 15))
        if skill_classes_total[0] > 5 or (p['BasePolitics'] * 0.5 + p['BaseGlamour'] * 0.5) >= 80:
            new_skills[10] = new_skills[10] + 1 if new_skills.get(10, 0) > 0 else 0
            new_skills[20] = new_skills[20] + 1 if new_skills.get(20, 0) > 0 else 0
            new_skills[30] = new_skills[30] + 1 if new_skills.get(30, 0) > 0 else 0
            new_skills[40] = new_skills[40] + 1 if new_skills.get(40, 0) > 0 else 0
            new_skills[50] = new_skills[50] + 1 if new_skills.get(50, 0) > 0 else 0
            new_skills[60] = new_skills[60] + 1 if new_skills.get(60, 0) > 0 else 0
            new_skills[70] = new_skills[70] + 1 if new_skills.get(70, 0) > 0 else 0
            new_skills[130] = max(new_skills.get(130, 0), max(0, ((p['BasePolitics'] * 0.25 + p['BaseGlamour'] * 0.75) - 70) / 20))
            new_skills[140] = max(new_skills.get(140, 0), max(0, ((p['BaseIntelligence'] * 0.5 + p['BasePolitics'] * 0.5) - 70) / 20))
            new_skills[150] = max(new_skills.get(150, 0), max(0, ((p['BasePolitics'] * 0.25 + p['BaseGlamour'] * 0.75) - 70) / 20))
            new_skills[130] = new_skills[130] + max(0, title_level / 2 - 2) if new_skills.get(130, 0) > 0 else 0
            new_skills[140] = new_skills[140] + max(0, title_level / 2 - 2) if new_skills.get(140, 0) > 0 else 0
            new_skills[150] = new_skills[150] + max(0, title_level / 2 - 2) if new_skills.get(150, 0) > 0 else 0
        if skill_classes_total[0] > 10 or (p['BasePolitics'] * 0.5 + p['BaseGlamour'] * 0.5) >= 90 or title_level >= 6:
            new_skills[10] = new_skills[10] + max(1, title_level / 2 - 2) if new_skills.get(10, 0) > 0 else 0
            new_skills[20] = new_skills[20] + max(1, title_level / 2 - 2) if new_skills.get(20, 0) > 0 else 0
            new_skills[30] = new_skills[30] + max(1, title_level / 2 - 2) if new_skills.get(30, 0) > 0 else 0
            new_skills[40] = new_skills[40] + max(1, title_level / 2 - 2) if new_skills.get(40, 0) > 0 else 0
            new_skills[50] = new_skills[50] + max(1, title_level / 2 - 2) if new_skills.get(50, 0) > 0 else 0
            new_skills[60] = new_skills[60] + max(1, title_level / 2 - 2) if new_skills.get(60, 0) > 0 else 0
            new_skills[70] = new_skills[70] + max(1, title_level / 2 - 2) if new_skills.get(70, 0) > 0 else 0
            new_skills[160] = max(new_skills.get(160, 0), max(0, ((p['BaseIntelligence'] * 0.5 + p['BasePolitics'] * 0.5) - 75) / 10))
            new_skills[170] = max(new_skills.get(170, 0), max(0, ((p['BaseCommand'] * 0.5 + p['BaseIntelligence'] * 0.5) - 75) / 10))
            new_skills[160] = new_skills[160] + max(0, title_level / 2 - 2) if new_skills.get(160, 0) > 0 else 0
            new_skills[170] = new_skills[170] + max(0, title_level / 2 - 2) if new_skills.get(170, 0) > 0 else 0

        if 20 in skill_ids:
            new_skills[10500] = max(new_skills.get(10500, 0), 1 + max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 50) / 30))
            new_stunts[40] = max(new_stunts.get(40, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 50) / 30))
            skill_classes_total[2] += 1
        if 21 in skill_ids:
            new_skills[10600] = max(new_skills.get(10600, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 40) / 30))
            new_stunts[40] = max(new_stunts.get(40, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 30))
            skill_classes_total[2] += 1
        if 22 in skill_ids:
            new_skills[10610] = max(new_skills.get(10610, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 40) / 30))
            new_stunts[40] = max(new_stunts.get(40, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 30))
            skill_classes_total[2] += 1
        if 23 in skill_ids:
            skill_classes_total[2] += 1
        if 24 in skill_ids:
            new_skills[10501] = max(new_skills.get(10501, 0), 1 + max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 50) / 20))
            new_stunts[40] = max(new_stunts.get(40, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 50) / 20))
            skill_classes_total[2] += 3
        if 25 in skill_ids:
            skill_classes_total[2] += 2
        if 26 in skill_ids:
            new_skills[300] = max(new_skills.get(300, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BasePolitics'] * 0.25) - 50) / 20))
            new_skills[310] = max(new_skills.get(310, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BasePolitics'] * 0.75) - 50) / 20))
            skill_classes_total[2] += 2
        if skill_classes_total[2] > 3 or p['BaseCommand'] >= 80:
            new_skills[300] = new_skills[300] + 1 if new_skills.get(300, 0) > 0 else 0
            new_skills[310] = new_skills[310] + 1 if new_skills.get(310, 0) > 0 else 0
            new_skills[10500] = new_skills[10500] + 1 if new_skills.get(10500, 0) > 0 else 0
            new_skills[10501] = new_skills[10501] + 1 if new_skills.get(10501, 0) > 0 else 0
            new_skills[10600] = new_skills[10600] + 1 if new_skills.get(10600, 0) > 0 else 0
            new_skills[10610] = new_skills[10610] + 1 if new_skills.get(10610, 0) > 0 else 0
            new_stunts[40] = new_stunts[40] + 1 if new_stunts.get(40, 0) > 0 else 0
            new_stunts[130] = max(new_stunts.get(130, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 75) / 10))
            new_stunts[230] = max(new_stunts.get(230, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseIntelligence'] * 0.75) - 75) / 10))
        if skill_classes_total[2] > 5 or p['BaseCommand'] >= 90 or title_level >= 6:
            new_skills[300] = new_skills[300] + max(1, title_level / 2 - 2) if new_skills.get(300, 0) > 0 else 0
            new_skills[310] = new_skills[310] + max(1, title_level / 2 - 2) if new_skills.get(310, 0) > 0 else 0
            new_skills[10500] = new_skills[10500] + max(1, title_level / 2 - 2) if new_skills.get(10500, 0) > 0 else 0
            new_skills[10501] = new_skills[10501] + max(1, title_level / 2 - 2) if new_skills.get(10501, 0) > 0 else 0
            new_skills[10600] = new_skills[10600] + max(1, title_level / 2 - 2) if new_skills.get(10600, 0) > 0 else 0
            new_skills[10610] = new_skills[10610] + max(1, title_level / 2 - 2) if new_skills.get(10610, 0) > 0 else 0
            new_stunts[40] = new_stunts[40] + max(1, title_level / 2 - 2) if new_stunts.get(40, 0) > 0 else 0
            new_stunts[130] = new_stunts[130] + max(1, title_level / 2 - 2) if new_stunts.get(130, 0) > 0 else 0
            new_stunts[230] = new_stunts[230] + max(1, title_level / 2 - 2) if new_stunts.get(230, 0) > 0 else 0


        if 30 in skill_ids:
            new_skills[10210] = max(new_skills.get(10210, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 40) / 30))
            new_stunts[20] = max(new_stunts.get(20, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 30))
            new_stunts[2000] = max(new_stunts.get(2000, 0), 1 + max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 50) / 30))
            skill_classes_total[3] += 1
        if 31 in skill_ids:
            new_skills[10200] = max(new_skills.get(10200, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 25))
            new_stunts[10] = max(new_stunts.get(10, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 25))
            new_stunts[2000] = max(new_stunts.get(2000, 0), 1 + max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 50) / 25))
            skill_classes_total[3] += 2
        if 32 in skill_ids:
            new_skills[10210] = max(new_skills.get(10210, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 40) / 20))
            new_stunts[20] = max(new_stunts.get(20, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 20))
            new_stunts[2000] = max(new_stunts.get(2000, 0), 1 + max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 50) / 20))
            skill_classes_total[3] += 3
        if 33 in skill_ids:
            new_skills[10210] = max(new_skills.get(10210, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 40) / 25))
            skill_classes_total[3] += 2
        if 34 in skill_ids:
            new_skills[10700] = max(new_skills.get(10700, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BasePolitics'] * 0.25) - 40) / 20))
            new_skills[11020] = max(new_skills.get(11020, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 20))
            new_stunts[30] = max(new_stunts.get(30, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 20))
            skill_classes_total[3] += 3
        if 35 in skill_ids:
            new_skills[10210] = max(new_skills.get(10210, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 40) / 20))
            new_skills[11010] = max(new_skills.get(11010, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 20))
            skill_classes_total[3] += 3
        if 36 in skill_ids:
            new_skills[10200] = max(new_skills.get(10200, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 15))
            new_stunts[10] = max(new_stunts.get(10, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 15))
            skill_classes_total[3] += 4
        if skill_classes_total[3] > 3 and skill_classes_total[2] > 0:
            new_skills[10220] = max(new_skills.get(10220, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 40) / 20))
        if skill_classes_total[3] > 5 or (p['BaseCommand'] * 0.5 + p['BaseStrength'] * 0.5) >= 80:
            new_skills[10200] = new_skills[10200] + 1 if new_skills.get(10200, 0) > 0 else 0
            new_skills[10210] = new_skills[10210] + 1 if new_skills.get(10210, 0) > 0 else 0
            new_skills[10220] = new_skills[10220] + 1 if new_skills.get(10220, 0) > 0 else 0
        if skill_classes_total[3] > 9 or (p['BaseCommand'] * 0.5 + p['BaseStrength'] * 0.5) >= 90 or title_level >= 6:
            new_skills[10200] = new_skills[10200] + max(1, title_level / 2 - 2) if new_skills.get(10200, 0) > 0 else 0
            new_skills[10210] = new_skills[10210] + max(1, title_level / 2 - 2) if new_skills.get(10210, 0) > 0 else 0
            new_skills[10220] = new_skills[10220] + max(1, title_level / 2 - 2) if new_skills.get(10220, 0) > 0 else 0

        if 40 in skill_ids:
            new_skills[10310] = max(new_skills.get(10310, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 30))
            new_stunts[20] = max(new_stunts.get(20, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 30))
            new_stunts[2100] = max(new_stunts.get(2100, 0), 1 + max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 50) / 30))
            skill_classes_total[4] += 1
        if 41 in skill_ids:
            new_skills[10300] = max(new_skills.get(10300, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 25))
            new_stunts[10] = max(new_stunts.get(10, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 25))
            new_stunts[2100] = max(new_stunts.get(2100, 0), 1 + max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 50) / 25))
            skill_classes_total[4] += 2
        if 42 in skill_ids:
            new_skills[10300] = max(new_skills.get(10300, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 20))
            new_stunts[10] = max(new_stunts.get(10, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 20))
            new_stunts[2100] = max(new_stunts.get(2100, 0), 1 + max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 50) / 20))
            skill_classes_total[4] += 3
        if 43 in skill_ids:
            new_skills[10300] = max(new_skills.get(10300, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 25))
            skill_classes_total[4] += 2
        if 44 in skill_ids:
            new_skills[10300] = max(new_skills.get(10300, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 40) / 20))
            new_skills[11000] = max(new_skills.get(11000, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 20))
            skill_classes_total[4] += 3
        if 45 in skill_ids:
            new_skills[10310] = max(new_skills.get(10300, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 40) / 20))
            new_skills[11010] = max(new_skills.get(11010, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 20))
            skill_classes_total[4] += 3
        if 46 in skill_ids:
            new_skills[10300] = max(new_skills.get(10300, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 15))
            new_stunts[10] = max(new_stunts.get(10, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 15))
            skill_classes_total[4] += 4
        if skill_classes_total[4] > 3 and skill_classes_total[2] > 0:
            new_skills[10320] = max(new_skills.get(10320, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 40) / 20))
        if skill_classes_total[3] + skill_classes_total[4] > 6 and new_skills.get(10600, 0) > 0:
            new_skills[10600] += 1
        if skill_classes_total[3] + skill_classes_total[4] > 12 and new_skills.get(10600, 0) > 0:
            new_skills[10600] += 1
        if skill_classes_total[3] + skill_classes_total[4] > 6 and new_skills.get(10610, 0) > 0:
            new_skills[10610] += 1
        if skill_classes_total[3] + skill_classes_total[4] > 12 and new_skills.get(10610, 0) > 0:
            new_skills[10610] += 1
        if skill_classes_total[4] > 5 or (p['BaseCommand'] * 0.5 + p['BaseStrength'] * 0.5) >= 80:
            new_skills[10300] = new_skills[10300] + 1 if new_skills.get(10300, 0) > 0 else 0
            new_skills[10310] = new_skills[10310] + 1 if new_skills.get(10310, 0) > 0 else 0
            new_skills[10320] = new_skills[10320] + 1 if new_skills.get(10320, 0) > 0 else 0
        if skill_classes_total[4] > 9 or (p['BaseCommand'] * 0.5 + p['BaseStrength'] * 0.5) >= 90 or title_level >= 6:
            new_skills[10300] = new_skills[10300] + max(1, title_level / 2 - 2) if new_skills.get(10300, 0) > 0 else 0
            new_skills[10310] = new_skills[10310] + max(1, title_level / 2 - 2) if new_skills.get(10310, 0) > 0 else 0
            new_skills[10320] = new_skills[10320] + max(1, title_level / 2 - 2) if new_skills.get(10320, 0) > 0 else 0

        if 50 in skill_ids:
            new_skills[10400] = max(new_skills.get(10400, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 30))
            new_stunts[10] = max(new_stunts.get(10, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 30))
            new_stunts[100] = max(new_stunts.get(100, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 60) / 30))
            new_stunts[200] = max(new_stunts.get(200, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseIntelligence'] * 0.75) - 60) / 30))
            new_stunts[2200] = max(new_stunts.get(2200, 0), 1 + max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 50) / 30))
            skill_classes_total[5] += 1
        if 51 in skill_ids:
            new_skills[10400] = max(new_skills.get(10400, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 25))
            new_stunts[10] = max(new_stunts.get(10, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 25))
            new_stunts[100] = max(new_stunts.get(100, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 60) / 25))
            new_stunts[200] = max(new_stunts.get(200, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseIntelligence'] * 0.75) - 60) / 25))
            new_stunts[2200] = max(new_stunts.get(2200, 0), 1 + max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 50) / 25))
            skill_classes_total[5] += 2
        if 52 in skill_ids:
            new_skills[10400] = max(new_skills.get(10400, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 20))
            new_stunts[10] = max(new_stunts.get(10, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 20))
            new_stunts[100] = max(new_stunts.get(100, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 60) / 20))
            new_stunts[200] = max(new_stunts.get(200, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseIntelligence'] * 0.75) - 60) / 20))
            new_stunts[2200] = max(new_stunts.get(2200, 0), 1 + max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 50) / 20))
            skill_classes_total[5] += 3
        if 53 in skill_ids:
            new_skills[10400] = max(new_skills.get(10400, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 40) / 25))
            new_skills[11000] = max(new_skills.get(11000, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 20))
            skill_classes_total[5] += 2
        if 54 in skill_ids:
            new_skills[10400] = max(new_skills.get(10400, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 40) / 20))
            new_skills[11020] = max(new_skills.get(11020, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 20))
            skill_classes_total[5] += 3
        if 55 in skill_ids:
            new_skills[10420] = max(new_skills.get(10420, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 40) / 20))
            skill_classes_total[5] += 3
        if 56 in skill_ids:
            new_skills[10400] = max(new_skills.get(10400, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 15))
            new_stunts[10] = max(new_stunts.get(10, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 40) / 15))
            new_stunts[100] = max(new_stunts.get(100, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 60) / 15))
            new_stunts[200] = max(new_stunts.get(200, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseIntelligence'] * 0.75) - 60) / 15))
            skill_classes_total[5] += 4
        if skill_classes_total[5] > 3:
            new_skills[10410] = max(new_skills.get(10410, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 40) / 20))
        if skill_classes_total[3] + skill_classes_total[4] + skill_classes_total[5] > 15:
            new_skills[10900] = max(new_skills.get(10900, 0), max(0, ((p['BaseCommand'] * 0.5 + p['BaseStrength'] * 0.5) - 60) / 20))
        if skill_classes_total[5] > 5 or (p['BaseCommand'] * 0.5 + p['BaseStrength'] * 0.5) >= 80:
            new_skills[10400] = new_skills[10400] + 1 if new_skills.get(10400, 0) > 0 else 0
            new_skills[10410] = new_skills[10410] + 1 if new_skills.get(10410, 0) > 0 else 0
            new_skills[10420] = new_skills[10420] + 1 if new_skills.get(10420, 0) > 0 else 0
        if skill_classes_total[5] > 9 or (p['BaseCommand'] * 0.5 + p['BaseStrength'] * 0.5) >= 90 or title_level >= 6:
            new_skills[10400] = new_skills[10400] + max(1, title_level / 2 - 2) if new_skills.get(10400, 0) > 0 else 0
            new_skills[10410] = new_skills[10410] + max(1, title_level / 2 - 2) if new_skills.get(10410, 0) > 0 else 0
            new_skills[10420] = new_skills[10420] + max(1, title_level / 2 - 2) if new_skills.get(10420, 0) > 0 else 0
        if skill_classes_total[3] + skill_classes_total[4] + skill_classes_total[5] > 8:
            new_stunts[10] = new_stunts[10] + 1 if new_stunts.get(10, 0) > 0 else 0
            new_stunts[20] = new_stunts[20] + 1 if new_stunts.get(20, 0) > 0 else 0
            new_stunts[100] = max(new_stunts.get(100, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 60) / 15))
            new_stunts[110] = max(new_stunts.get(110, 0), max(0, (p['BaseCommand'] - 60) / 15))
            new_stunts[200] = max(new_stunts.get(200, 0), max(0, ((p['BaseStrength'] * 0.25 + p['BaseIntelligence'] * 0.75) - 70) / 10))
            new_stunts[210] = max(new_stunts.get(210, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseIntelligence'] * 0.75) - 70) / 10))
        if skill_classes_total[3] + skill_classes_total[4] + skill_classes_total[5] > 15 or title_level >= 6:
            new_stunts[10] = new_stunts[10] + max(1, title_level / 2 - 2) if new_stunts.get(10, 0) > 0 else 0
            new_stunts[20] = new_stunts[20] + max(1, title_level / 2 - 2) if new_stunts.get(20, 0) > 0 else 0
            new_stunts[100] = new_stunts[100] + max(1, title_level / 2 - 2) if new_stunts.get(100, 0) > 0 else 0
            new_stunts[110] = new_stunts[110] + max(1, title_level / 2 - 2) if new_stunts.get(110, 0) > 0 else 0
            new_stunts[200] = new_stunts[200] + max(1, title_level / 2 - 2) if new_stunts.get(200, 0) > 0 else 0
            new_stunts[210] = new_stunts[210] + max(1, title_level / 2 - 2) if new_stunts.get(210, 0) > 0 else 0

        if 60 in skill_ids:
            skill_classes_total[6] += 1
        if 61 in skill_ids:
            skill_classes_total[6] += 1
        if 62 in skill_ids:
            skill_classes_total[6] += 2
        if 63 in skill_ids:
            skill_classes_total[6] += 2
        if 64 in skill_ids:
            skill_classes_total[6] += 3
        if 65 in skill_ids:
            skill_classes_total[6] += 3
        if 66 in skill_ids:
            skill_classes_total[6] += 4

        if 70 in skill_ids:
            new_skills[10700] = max(new_skills.get(10700, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseIntelligence'] * 0.75) - 40) / 25))
            skill_classes_total[7] += 2
        if 71 in skill_ids:
            new_skills[10700] = max(new_skills.get(10700, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseIntelligence'] * 0.75) - 40) / 25))
            skill_classes_total[7] += 2
        if 72 in skill_ids:
            new_skills[10700] = max(new_skills.get(10700, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseIntelligence'] * 0.75) - 40) / 25))
            skill_classes_total[7] += 2
        if 73 in skill_ids:
            new_skills[10700] = max(new_skills.get(10700, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseIntelligence'] * 0.75) - 40) / 25))
            skill_classes_total[7] += 2
        if 74 in skill_ids:
            new_skills[10700] = max(new_skills.get(10700, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseIntelligence'] * 0.75) - 40) / 25))
            skill_classes_total[7] += 2
        if 75 in skill_ids:
            new_skills[10100] = max(new_skills.get(10100, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BasePolitics'] * 0.25) - 40) / 25))
            new_skills[10710] = max(new_skills.get(10700, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseIntelligence'] * 0.75) - 40) / 25))
            skill_classes_total[7] += 2
        if 76 in skill_ids:
            new_skills[10110] = max(new_skills.get(10110, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BasePolitics'] * 0.25) - 40) / 25))
            new_skills[10710] = max(new_skills.get(10700, 0), max(0, ((p['BaseCommand'] * 0.25 + p['BaseIntelligence'] * 0.75) - 40) / 25))
            skill_classes_total[7] += 2
        if skill_classes_total[5] > 5 or (p['BaseCommand'] * 0.5 + p['BaseIntelligence'] * 0.5) >= 80:
            new_skills[10700] = new_skills[10700] + 1 if new_skills.get(10700, 0) > 0 else 0
            new_skills[10710] = new_skills[10710] + 1 if new_skills.get(10710, 0) > 0 else 0
        if skill_classes_total[5] > 9 or (p['BaseCommand'] * 0.5 + p['BaseStrength'] * 0.5) >= 90 or title_level >= 6:
            new_skills[10700] = new_skills[10700] + max(1, title_level / 2 - 2) if new_skills.get(10700, 0) > 0 else 0
            new_skills[10710] = new_skills[10710] + max(1, title_level / 2 - 2) if new_skills.get(10710, 0) > 0 else 0

        if 80 in skill_ids:
            skill_classes_total[8] += 3
        if 81 in skill_ids:
            skill_classes_total[8] += 3
        if 82 in skill_ids:
            skill_classes_total[8] += 3
        if 83 in skill_ids:
            skill_classes_total[8] += 3
        if 84 in skill_ids:
            skill_classes_total[8] += 3
        if 85 in skill_ids:
            skill_classes_total[8] += 2
        if 86 in skill_ids:
            skill_classes_total[8] += 2
        if skill_classes_total[8] > 6:
            new_skills[10000] = max(new_skills.get(10000, 0), 1 + max(0, ((p['BaseCommand'] * 0.25 + p['BaseGlamour'] * 0.75) - 70) / 15))

        if 90 in skill_ids:
            new_stunts[1100] = max(new_stunts.get(1100, 0), max(0, ((p['BaseStrength'] * 0.75 + p['BaseIntelligence'] * 0.25) - 60) / 15))
            new_stunts[1200] = max(new_stunts.get(1200, 0), max(0, ((p['BaseIntelligence'] * 0.75 + p['BaseGlamour'] * 0.25) - 60) / 15))
            skill_classes_total[9] += 2
        if 91 in skill_ids:
            new_stunts[1300] = min(1, max(new_stunts.get(1300, 0), max(0, ((p['BaseStrength'] * 0.75 + p['BaseIntelligence'] * 0.25) - 60) / 15)))
            new_stunts[1400] = min(1, max(new_stunts.get(1400, 0), max(0, (p['BaseIntelligence'] - 60) / 15)))
            skill_classes_total[9] += 2
        if 92 in skill_ids:
            skill_classes_total[9] += 1
        if 93 in skill_ids:
            skill_classes_total[9] += 2
        if 94 in skill_ids:
            skill_classes_total[9] += 2
        if 95 in skill_ids:
            skill_classes_total[9] += 3
        if 96 in skill_ids:
            new_skills[11100] = max(new_skills.get(11100, 0), 1 + max(0, ((p['BaseIntelligence'] * 0.75 + p['BaseGlamour'] * 0.25) - 70) / 15))
            new_skills[11130] = max(new_skills.get(11130, 0), 1 + max(0, ((p['BaseCommand'] * 0.75 + p['BaseGlamour'] * 0.25) - 70) / 15))
            new_stunts[1000] = max(new_stunts.get(1000, 0), max(0, ((p['BaseIntelligence'] * 0.75 + p['BaseGlamour'] * 0.25) - 60) / 15))
            skill_classes_total[9] += 2
        if skill_classes_total[9] > 4 or p['BaseIntelligence'] >= 80:
            new_skills[11100] = new_skills[11100] + 1 if new_skills.get(11100, 0) > 0 else 0
            new_skills[11130] = new_skills[11130] + 1 if new_skills.get(11130, 0) > 0 else 0
            new_skills[11110] = max(new_skills.get(11110, 0), max(0, ((p['BaseIntelligence'] * 0.25 + p['BaseGlamour'] * 0.75) - 70) / 10))
            new_skills[11120] = max(new_skills.get(11120, 0), max(0, ((p['BaseCommand'] * 0.75 + p['BaseIntelligence'] * 0.25) - 70) / 10))
            new_stunts[1100] = new_stunts[1100] + 1 if new_stunts.get(1100, 0) > 0 else 0
            new_stunts[1200] = new_stunts[1200] + 1 if new_stunts.get(1200, 0) > 0 else 0
        if skill_classes_total[9] > 7 or p['BaseIntelligence'] >= 90 or title_level >= 6:
            new_skills[11100] = new_skills[11100] + max(1, title_level / 2 - 2) if new_skills.get(11100, 0) > 0 else 0
            new_skills[11110] = new_skills[11110] + max(1, title_level / 2 - 2) if new_skills.get(11110, 0) > 0 else 0
            new_skills[11120] = new_skills[11120] + max(1, title_level / 2 - 2) if new_skills.get(11120, 0) > 0 else 0
            new_skills[11130] = new_skills[11130] + max(1, title_level / 2 - 2) if new_skills.get(11130, 0) > 0 else 0
            new_stunts[1100] = new_stunts[1100] + max(1, title_level / 2 - 2) if new_stunts.get(1100, 0) > 0 else 0
            new_stunts[1200] = new_stunts[1200] + max(1, title_level / 2 - 2) if new_stunts.get(1200, 0) > 0 else 0

        if 100 in skill_ids:
            skill_classes_total[10] += 2
        if 101 in skill_ids:
            skill_classes_total[10] += 2
        if 102 in skill_ids:
            skill_classes_total[10] += 2
        if 103 in skill_ids:
            skill_classes_total[10] += 2
        if 104 in skill_ids:
            skill_classes_total[10] += 2
        if 105 in skill_ids:
            skill_classes_total[10] += 2
        if 106 in skill_ids:
            new_skills[200] = max(new_skills.get(200, 0), 1 + max(0, ((p['BaseGlamour']) - 60) / 20))
            skill_classes_total[10] += 2

        if 0 in stunt_ids:
            new_stunts[3000] = 1
        if 8 in stunt_ids:
            new_stunts[3010] = 1
        if 13 in stunt_ids:
            new_stunts[30] = max(new_stunts.get(30, 0), 1 + max(0, ((p['BaseStrength'] * 0.75 + p['BasePolitics'] * 0.25) - 50) / 20))
            new_stunts[120] = max(new_stunts.get(120, 0), 1 + max(0, ((p['BaseCommand'] * 0.75 + p['BasePolitics'] * 0.25) - 60) / 15))
            new_stunts[220] = max(new_stunts.get(220, 0), 1 + max(0, ((p['BaseCommand'] * 0.75 + p['BaseIntelligence'] * 0.25) - 70) / 10))

        if 42 in title_ids:
            new_skills[130] = max(new_skills.get(130, 0), 3)
        if 43 in title_ids:
            new_skills[140] = max(new_skills.get(140, 0), 3)
        if 70 in title_ids:
            new_skills[100] = max(new_skills.get(100, 0), 3)
        if 71 in title_ids:
            new_skills[110] = max(new_skills.get(110, 0), 3)
        if 81 in title_ids:
            new_skills[120] = max(new_skills.get(120, 0), 3)
        if 80 in title_ids:
            new_skills[20020] = max(new_skills.get(20020, 0), 1 + max(0, ((p['BaseIntelligence'] * 0.75 + p['BaseGlamour'] * 0.25) - 60) / 10))
        if 228 in title_ids:
            new_skills[10810] = max(new_skills.get(10810, 0), 1 + max(0, ((p['BaseCommand'] * 0.25 + p['BaseStrength'] * 0.75) - 60) / 10))
        if 229 in title_ids or 262 in title_ids:
            new_skills[10900] = max(new_skills.get(10900, 0), 1 + max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 60) / 10))
        if 230 in title_ids:
            new_skills[10710] = max(new_skills.get(10710, 0), 1 + max(0, ((p['BaseCommand'] * 0.75 + p['BasePolitics'] * 0.25) - 60) / 10))
        if 252 in title_ids:
            new_skills[11110] = max(new_skills.get(11110, 0), 1 + max(0, ((p['BaseIntelligence'] * 0.25 + p['BaseGlamour'] * 0.75) - 60) / 10))
            new_stunts[200] = max(new_stunts.get(200, 0), 1 + max(0, ((p['BaseIntelligence'] * 0.25 + p['BaseGlamour'] * 0.75) - 60) / 10))
            new_stunts[210] = max(new_stunts.get(210, 0), 1 + max(0, ((p['BaseIntelligence'] * 0.25 + p['BaseGlamour'] * 0.75) - 60) / 10))
            new_stunts[220] = max(new_stunts.get(220, 0), 1 + max(0, ((p['BaseIntelligence'] * 0.25 + p['BaseGlamour'] * 0.75) - 60) / 10))
            new_stunts[230] = max(new_stunts.get(230, 0), 1 + max(0, ((p['BaseIntelligence'] * 0.25 + p['BaseGlamour'] * 0.75) - 60) / 10))
            new_stunts[1200] = max(new_stunts.get(1200, 0), 1 + max(0, ((p['BaseIntelligence'] * 0.25 + p['BaseGlamour'] * 0.75) - 60) / 10))
        if 253 in title_ids:
            new_skills[11110] = max(new_skills.get(11110, 0), 1 + max(0, ((p['BaseIntelligence'] * 0.25 + p['BaseGlamour'] * 0.75) - 60) / 10))
            new_stunts[1000] = max(new_stunts.get(1000, 0), 1 + max(0, ((p['BaseIntelligence'] * 0.25 + p['BaseGlamour'] * 0.75) - 60) / 10))
        if 300 in title_ids or 320 in title_ids:
            bonus = 3 if 300 in title_ids else 1
            new_skills[10200] = max(new_skills.get(10200, 0), bonus + max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 60) / 10))
            new_skills[10210] = max(new_skills.get(10210, 0), bonus + max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 60) / 10))
            new_skills[10220] = max(new_skills.get(10220, 0), bonus + max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 60) / 10))
        if 301 in title_ids or 321 in title_ids:
            bonus = 3 if 301 in title_ids else 1
            new_skills[10300] = max(new_skills.get(10300, 0), bonus + max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 60) / 10))
            new_skills[10310] = max(new_skills.get(10310, 0), bonus + max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 60) / 10))
            new_skills[10320] = max(new_skills.get(10320, 0), bonus + max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 60) / 10))
        if 302 in title_ids or 322 in title_ids:
            bonus = 3 if 302 in title_ids else 1
            new_skills[10400] = max(new_skills.get(10400, 0), bonus + max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 60) / 10))
            new_skills[10410] = max(new_skills.get(10410, 0), bonus + max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 60) / 10))
            new_skills[10420] = max(new_skills.get(10420, 0), bonus + max(0, ((p['BaseCommand'] * 0.75 + p['BaseStrength'] * 0.25) - 60) / 10))
        if 360 in title_ids:
            new_stunts[1200] = max(new_stunts.get(1200, 0), 1 + max(0, (p['BaseIntelligence'] - 60) / 10))
        
        filtered_new_skills = {}
        for s in new_skills:
            v = int(new_skills[s])
            if v > 0:
                filtered_new_skills[s] = v

        filtered_new_stunts = {}
        for s in new_stunts:
            v = int(new_stunts[s])
            if v > 0:
                filtered_new_stunts[s] = v

        return {
            "Skills": filtered_new_skills,
            "Stunts": filtered_new_stunts
        }

if not os.path.exists(output_folder):
    os.makedirs(output_folder)

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
        with open(output_folder + '/Architectures.json', mode='w', encoding='utf-8') as fout:
            r = []
            states = {x['ID']: x['Name'] for x in obj['States']['GameObjects']}
            for k in obj['Architectures']['GameObjects']:
                raw_positions = [int(x) for x in k['ArchitectureAreaString'].split(' ') if x]
                positions_x = []
                positions_y = []
                for i in range(0, len(raw_positions), 2):
                    positions_x.append(raw_positions[i])
                    positions_y.append(raw_positions[i + 1])
                position_center = [
                    (min(positions_x) + max(positions_x)) // 2,
                    (min(positions_y) + max(positions_y)) // 2
                ]

                persons = [int(x) for x in k['PersonsString'].split(' ') if x]
                faction_person_ids += persons
                no_faction_persons = [int(x) for x in k['NoFactionPersonsString'].split(' ') if x]
                no_faction_person_ids += no_faction_persons
                r.append({
                    "_Id": k["ID"],
                    "Kind": k['KindId'],
                    "Name": k['Name'],
                    "Title": states[k['StateID']] + ' ' + k['Name'],
                    "MapPosition": [position_center[0], position_center[1] - 1],
                    "PersonList": persons + no_faction_persons,
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
                    "TroopCombativity": 20,
                    "Equipments": {},
                    "_RecentlyBattled": 0
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
            fout.write(json.dumps(r, indent=2, ensure_ascii=False, sort_keys=True))
        
        if import_persons:
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

                    title_level = max([0] + [e['Value']['Level'] for e in common['AllTitles']['Titles'] if e['Key'] in [int(x) for x in filter(None, k['RealTitlesString'].split(' '))]])
                    converted_specials = convert_specials(k, title_level)

                    close_ids = [x['Value'] for x in obj['CloseIds'] if str(x['Key']) == str(k['ID'])]
                    close_ids = [] if len(close_ids) == 0 else close_ids[0]
                    hated_ids = [x['Value'] for x in obj['HatedIds'] if str(x['Key']) == str(k['ID'])]
                    hated_ids = [] if len(hated_ids) == 0 else hated_ids[0]
                    person_relations = {x: {'value': 100, 'decay': 0.0} for x in close_ids}.copy()
                    person_relations.update({x: {'value': -100, 'decay': 0.0} for x in hated_ids})

                    popularity = int(min(10000, k['Reputation'] / 5))
                    prestige = int(min(10000, k['Reputation'] / 5))
                    karma = k['Karma'] * 100

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
                        "StratagemExperience": 0,
                        "CommandExperience": 0,
                        "StrengthExperience": 0,
                        "IntelligenceExperience": 0,
                        "PoliticsExperience": 0,
                        "GlamourExperience": 0,
                        "MilitaryTypeExperience": {},
                        "Popularity": popularity,
                        "Prestige": prestige,
                        "Karma": karma,
                        "Merit": 0,
                        "Task": 0,
                        "TaskTarget": -1,
                        "ProducingEquipment": None,
                        "Skills": converted_specials["Skills"],
                        "Stunts": converted_specials["Stunts"],
                        "FatherId": father_id_list[0]['Value'] if len(father_id_list) > 0 else -1,
                        "MotherId": mother_id_list[0]['Value'] if len(mother_id_list) > 0 else -1,
                        "SpouseIds": [spouse_id_list[0]['Value']] if len(spouse_id_list) > 0 and spouse_id_list[0]['Value'] >= 0 else [],
                        "BrotherIds": brother_id_list[0]['Value'] if len(brother_id_list) > 0 else [],
                        "Strain": k['Strain'],
                        "Ideal": k['Ideal'],
                        "LoyaltyShift": 0,
                        "Ambition": k['Ambition'] * 20 + 10,
                        "Morality": k['PersonalLoyalty'] * 20 + 10,
                        "Braveness": k['BaseBraveness'] * 10,
                        "Calmness": k['BaseCalmness'] * 10,
                        "PersonRelations": person_relations
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
                "Day": obj['Date']['Day'],
                "TurnPassed": 0
              },
              "Name": obj['ScenarioTitle'],
              "Factions": all_factions
            }, indent=2, ensure_ascii=False, sort_keys=True))

