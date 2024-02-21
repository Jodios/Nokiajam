using Godot;

public partial class Health : Node2D
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
