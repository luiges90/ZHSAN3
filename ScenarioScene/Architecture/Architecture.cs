using Godot;
using Godot.Collections;
using System;
using ZHSAN3;

public class Architecture : Node2D
{
	private int id;

	private IntPosition mapPosition;

	public Faction BelongedFaction { get; set; }
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		
	}

	public static Architecture Load(Dictionary<string, object> json)
	{
		return new Architecture
		{
			id = (int)json["Id"],
			mapPosition = new IntPosition((float)json["MapPositionX"], (float)json["MapPositionY"])
		};
	}

	//  // Called every frame. 'delta' is the elapsed time since the previous frame.
	//  public override void _Process(float delta)
	//  {
	//      
	//  }
}
