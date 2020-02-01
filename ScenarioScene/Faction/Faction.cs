using Godot;
using Godot.Collections;
using System;

public class Faction : Node
{
	private int id;

	private Array<Architecture> architectureList;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		
	}

	public static Faction Load(Dictionary<string, object> json)
	{
		return new Faction
		{
			id = (int)json["Id"]
		};
	}

	public void AddArchitecture(Architecture arch)
	{
		arch.BelongedFaction = this;
		architectureList.Add(arch);
	}

//  // Called every frame. 'delta' is the elapsed time since the previous frame.
//  public override void _Process(float delta)
//  {
//      
//  }
}
