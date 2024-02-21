using Godot;

public partial class Health : Node2D
{
	[Export] public int Strength = 1;
	private Area2D pickupArea;
	private SoundUtils soundUtils;
	private MeshInstance2D meshInstance2D;
	private Global global;

	public override void _Ready()
	{
		global = GetNode<Global>("/root/Global");
		pickupArea = GetNode<Area2D>("pickupArea");
		pickupArea.BodyEntered += Pickup;
		soundUtils = GetNode<SoundUtils>("/root/SoundUtils");
		meshInstance2D = GetNode<MeshInstance2D>("MeshInstance2D");
	}

    public override void _Process(double delta)
    {
		// doing anything related to gui changes should be done here. This function
		// is called every frame which can change....physics process is constant 
		Modulate = global.theme["secondary"];
    }


	public void Pickup(Node2D body)
	{
		if (!body.IsInGroup(global.Player)) return;
		soundUtils.PlayPickupHealthItemSound();
		Player player = (Player)body;
		int possibleVal = player.Health + Strength;
		if (possibleVal <= player.MaxHealth)
		{
			player.Health = possibleVal;
		}
		else
		{
			player.Health = player.MaxHealth;
		}
		QueueFree();
	}
}
