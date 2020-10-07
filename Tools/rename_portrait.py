import json
import os

file_name = '194QXGJ-qh'
with open('../Scenarios/' + file_name + '/Persons.json', mode='r', encoding='utf-8') as file:
	obj = json.loads(file.read())

portrait_dir = '../Images/PersonPortrait/'
for person in obj:
	id = person["_Id"]
	name = person["Surname"] + person["GivenName"]
	try:
		os.rename(portrait_dir + name + ".jpg", portrait_dir + str(id) + ".jpg")
	except FileExistsError:
		os.remove(str(id) + ".jpg")
		os.rename(portrait_dir + name + ".jpg", portrait_dir + str(id) + ".jpg")
	except FileNotFoundError:
		print('找不到頭像：' + name)
	