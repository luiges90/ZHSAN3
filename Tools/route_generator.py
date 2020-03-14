### Install Dependencies:
### pip install pathfinding
from pathfinding.core.diagonal_movement import DiagonalMovement
from pathfinding.core.grid import Grid
from pathfinding.finder.a_star import AStarFinder
from pathfinding.finder.finder import ExecutionRunsException
import xml.etree.ElementTree as ET
import csv
import json
from io import StringIO

map_file_path = '../ScenarioScene/GameMap/Zhsan2.tmx'
scen_file_path = '194QXGJ-qh'
MAX_DISTANCE = 75

print('ZHSan route generator. Scenario file path:', scen_file_path)
print('Max architecture distance', MAX_DISTANCE)

print('Parsing TMX file', map_file_path)
map_xml = ET.parse(map_file_path).getroot()
width = int(map_xml.attrib['width'])
height = int(map_xml.attrib['height'])

print('Reading map data. Width', width, 'Height', height)
map_data = []
for r in range(0, height):
	row = []
	for c in range(0, width):
		row.append(0)
	map_data.append(row)

for child in map_xml:
	if child.tag == 'layer':
		print('Layer',child.attrib)
		for child2 in child:
			csv_data = csv.reader(StringIO(child2.text))
			incoming_map_data = []
			for row in csv_data:
				if len(row) > 0:
					temp = []
					for col in row:
						if len(col) > 0:
							temp.append(int(col))
					incoming_map_data.append(temp)
			for r in range(0, len(map_data)):
				for c in range(0, len(map_data[r])):
					if map_data[r][c] == 0 and incoming_map_data[r][c] != 0:	
						map_data[r][c] = incoming_map_data[r][c]

print('Reading architecture data.')
architectures = {}
with open(scen_file_path + '/Architectures.json', mode='r', encoding='utf-8') as arch_file:
	archs = json.loads(arch_file.read(), strict=False)
	for arch in archs:
		architectures[arch['_Id']] = arch['MapPosition']
		
print('Reading movement kind data.')
movement_kinds = {}
with open(scen_file_path + '/MovementKinds.json', mode='r', encoding='utf-8') as kind_file:
	kinds = json.loads(kind_file.read(), strict=False)
	for kind in kinds:
		costs = kind['MovementCosts']
		for index in costs:
			if costs[index] >= 100:
				costs[index] = -1
		movement_kinds[kind['_Id']] = costs
	
print('Data read complete. Architecture count:', len(architectures), 'Movement Kinds count:', len(movement_kinds))

print('Calculating exclusion areas')
arch_exclusion = []
for r in range(0, height):
	row = []
	for c in range(0, width):
		row.append([])
	arch_exclusion.append(row)
for a in architectures:
	for r in range(architectures[a][0]-4, architectures[a][0]+5):
		for c in range(architectures[a][1]-4, architectures[a][1]+5):
			arch_exclusion[r][c].append(a)

print('Calculating paths')
for kind in movement_kinds:
	kind_paths = []
	print('Calulcating path for Movement Kind',kind,'Data',movement_kinds[kind])
	for a1 in architectures:
		for a2 in architectures:
			if a1 < a2:
				if abs(architectures[a1][0] - architectures[a2][0]) + abs(architectures[a1][1] - architectures[a2][1]) > MAX_DISTANCE:
					# print('SKIP Architecture',a1,'to',a2,'Straight line distance too long')
					continue
					
				print('Finding path for Architecture',a1,'to',a2)
				grid_data = []
				for r in range(0, len(map_data)):
					grid_r = []
					for c in range(0, len(map_data[r])):
						if len(arch_exclusion[r][c]) == 0 or a1 in arch_exclusion[r][c] or a2 in arch_exclusion[r][c]:
							grid_r.append(movement_kinds[kind][str(map_data[r][c])])
						else:
							grid_r.append(-1)
					grid_data.append(grid_r)
				grid = Grid(matrix=grid_data)

				start = grid.node(architectures[a1][0], architectures[a1][1])
				end = grid.node(architectures[a2][0], architectures[a2][1])
				try:
					finder = AStarFinder(diagonal_movement=DiagonalMovement.never, max_runs=MAX_DISTANCE*MAX_DISTANCE)
					path, runs = finder.find_path(start, end, grid)
				except ExecutionRunsException:
					print('Path too long')
					path = []
				
				print('found path',path)
				if len(path) > 0:
					kind_paths.append({
						'MovementKind': kind,
						'StartArchitecture': a1,
						'EndArchitecture': a2,
						'Path': path
					})
					kind_paths.append({
						'MovementKind': kind,
						'StartArchitecture': a2,
						'EndArchitecture': a1,
						'Path': list(reversed(path))
					})
				grid.cleanup()
	with open(scen_file_path + '/Paths/' + str(kind) + '.json', mode='w', encoding='utf-8') as fout:
		fout.write(json.dumps(kind_paths, indent=0, separators=(',',':'), ensure_ascii=False, sort_keys=True))
