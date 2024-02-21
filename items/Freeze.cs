using Godot;

public partial class Freeze : Node2D
{
	[Export] public int Strength = 1;
	private Area2D pickupArea;
	private SoundUtils soundUtils;
	private MeshInstance2D meshInstance2D;

	public override void _Ready()
	{
		pickupArea = GetNode<Area2D>("pickupArea");
		pickupArea.BodyEntered += Pickup;
		soundUtils = GetNode<SoundUtils>("/root/SoundUtils");
		meshInstance2D = GetNode<MeshInstance2D>("MeshInstance2D");
	}

    public override void _Process(double delta)
    {
		// doing anything related to gui changes should be done here. This function
		// is called every frame which can change....physics process is constant 
		Modulate = Global.theme["secondary"];
    }

	public void Pickup(Node2D body)
	{
		if (!body.IsInGroup(Global.Player)) return;
		soundUtils.PlayPickupFreezeItemSound();
		Player player = (Player)body;
		int possibleVal = player.Stuns + Strength;
		if (possibleVal <= player.MaxStuns)
		{
			player.Stuns = possibleVal;
		}
		else
		{
			player.Stuns = player.MaxStuns;
		}
		QueueFree();
	}
}
