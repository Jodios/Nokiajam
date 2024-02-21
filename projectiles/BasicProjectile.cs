using Godot;

public partial class BasicProjectile : Node2D
{

	[Export] public int Speed = 50;
	[Export] public float Damage = 20;
	[Export] public float Piercing = 20;

	private Vector2 direction = Vector2.Zero;

	private Area2D hitbox;

	private Player parent;

	public override void _Ready()
	{
		hitbox = GetNode<Area2D>("hitbox");
		hitbox.BodyEntered += HitboxCollisionHandler;
		Modulate = Global.theme["primary"];
		Global.statsTracker.AddShotFired();
	}

	public override void _Process(double delta)
	{
		Position += Speed * direction * (float)delta;
	}

	public void Start(
		Vector2 position,
		Vector2 direction,
		Player parent
	)
	{
		Position = position;
		this.direction = direction;
		this.parent = parent;
	}

	private void HitboxCollisionHandler(Node2D body)
	{
		if (body.IsInGroup(Global.Border))
		{
			QueueFree();
		}
		if (!body.IsInGroup(Global.Enemy)) return;

		if (body is Enemy)
		{
			Global.statsTracker.AddShotLanded();
			Enemy enemy = (Enemy)body;
			enemy.Damage(Damage);
		}
		QueueFree();
	}

}

