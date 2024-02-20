using Godot;

public partial class Health : Node2D
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
