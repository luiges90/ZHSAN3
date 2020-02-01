using Godot;
using System;

public class Scenario : Node
{
    private float TILE_SIZE;

    private PackedScene factionScene, architectureScene;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		TILE_SIZE = GetNode<TileMap>("Map").CellSize[0];

        factionScene = GD.Load<PackedScene>("res://ScenarioScene/Faction/Faction.tscn");
        architectureScene = GD.Load<PackedScene>("res://ScenarioScene/Architecture/Architecture.tscn");

        AddChild(factionScene.Instance());
        AddChild(architectureScene.Instance());
    }

}
