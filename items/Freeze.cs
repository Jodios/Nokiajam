using Godot;

public partial class Freeze : Node2D
{
	[Export] public int Strength = 1;
	private Area2D pickupArea;

	public override void _Ready()
	{
		pickupArea = GetNode<Area2D>("pickupArea");
		pickupArea.BodyEntered += Pickup;
	}

	public void Pickup(Node2D body)
	{
		if (!body.IsInGroup(Global.Player)) return;
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
