using Godot;

public partial class Freeze : Node2D
{
	[Export] public int Strength = 1;
	private Area2D pickupArea;
	private SoundUtils soundUtils;

	public override void _Ready()
	{
		pickupArea = GetNode<Area2D>("pickupArea");
		pickupArea.BodyEntered += Pickup;
		soundUtils = GetNode<SoundUtils>("/root/SoundUtils");
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
