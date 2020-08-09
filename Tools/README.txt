此資料夾包括遊戲開發使用的工具，使用Python 3運行。
This folder contains development tools for the project. Run with Python 3.

scen_importer.py
- 劇本導入工具。把舊版中三的劇本轉換成新版格式。
- Scenario importer tool.

route_generator.py
- AI路徑生成工具。如有任何兵種移動類(MovementKind)或地圖的改動，需要運行此工具重新生成所有AI路徑。注意：運行這工具一般需要數個小時。
- 運行這工具需要安裝python pathfinder模組。可以用pip安裝。
- AI Path generator. If you have changed any Movement Kind or any part of the map, this tool need to be run to regenerate all AI Paths. Note: This tool typically needs several hours to run.
- Depends on pathfinder module. Install through pip.

rename_portrait.py
- 頭像重命名工具，由劇本裡武將名稱改成其ID。注意這會直接更改在Images/Portrait裡的檔名，有需要請先備份。
- 運行後，用Godot開啟方案時會重新生成所有.import檔案，需要花一點時間。
- Rename all portrait files from officer names to their ID. This will update file names directly so first backup your data.
- After run, Godot will need to generate all .import files again, which may take some time.