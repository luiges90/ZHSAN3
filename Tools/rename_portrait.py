import json
import os

file_name = '194QXGJ-qh'
with open(file_name + '/Persons.json', mode='r', encoding='utf-8') as file:
	obj = json.loads(file.read())

portrait_dir = '../Images/PersonPortrait/'
for person in obj:
	id = person["_Id"]
	name = person["Surname"] + person["GivenName"]
	try:
		os.rename(portrait_dir + name + ".jpg", str(id) + ".jpg")
	except FileNotFoundError:
		print('找不到頭像：' + name)
	