using Godot;
using Godot.Collections;
using static Godot.Collections.Array;
using System;

public class Scenario : Node
{
	public float TileSize
	{
		get; private set;
	}

	private PackedScene factionScene, architectureScene;

	private Array<Faction> factions;
	private Array<Architecture> architectures;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		Setup();

		LoadGame("user://Scenarios/000Test.json");

		factionScene = GD.Load<PackedScene>("res://ScenarioScene/Faction/Faction.tscn");
		architectureScene = GD.Load<PackedScene>("res://ScenarioScene/Architecture/Architecture.tscn");

		AddChild(factionScene.Instance());
		AddChild(architectureScene.Instance());
	}

	private void Setup()
	{
		TileSize = GetNode<TileMap>("Map").CellSize[0];
	}

	private void LoadGame(String path)
	{
		File file = new File();
		file.Open(path, File.ModeFlags.Read);
		String json = file.GetAsText();
		Dictionary<string, object> obj = (Dictionary<string, object>) JSON.Parse(json).Result;

		foreach (object item in (Array<object>)obj["Architectures"])
		{
			Architecture a = Architecture.Load((Dictionary<string, object>)item);
			architectures.Add(a);
		}
		foreach (object item in (Array<object>)obj["Factions"])
		{
			Faction f = Faction.Load((Dictionary<string, object>)item);
			factions.Add(f);
		}
	}

}
