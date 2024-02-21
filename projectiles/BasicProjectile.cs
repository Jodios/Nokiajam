using Godot;

public partial class BasicProjectile : Node2D
{

	[Export] public int Speed = 50;
	[Export] public float Damage = 20;
	[Export] public float Piercing = 20;

	private Vector2 direction = Vector2.Zero;

	private Area2D hitbox;

	private Player parent;
	private Global global;

	public override void _Ready()
	{
		hitbox = GetNode<Area2D>("hitbox");
		hitbox.BodyEntered += HitboxCollisionHandler;
		global = GetNode<Global>("/root/Global");
		global.statsTracker.AddShotFired();
	}

	public override void _Process(double delta)
	{
		Modulate = global.theme["secondary"];
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
		if (body.IsInGroup(global.Border))
		{
			QueueFree();
		}
		if (!body.IsInGroup(global.Enemy)) return;

		if (body is Enemy)
		{
			global.statsTracker.AddShotLanded();
			Enemy enemy = (Enemy)body;
			enemy.Damage(Damage);
		}
		QueueFree();
	}

}

