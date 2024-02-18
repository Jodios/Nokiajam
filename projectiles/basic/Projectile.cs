using Godot;

public partial class Projectile : Node2D
{

	[Export] public int Speed = 50;
	[Export] public float Damage = 20;

	private Vector2 direction = Vector2.Zero;

	private Area2D hitbox;

	private Player parent;

	private Global global;

	public override void _Ready()
	{
		global = GetNode<Global>("/root/Global");
		hitbox = GetNode<Area2D>("hitbox");
		hitbox.BodyEntered += HitboxCollisionHandler;
		Modulate = Global.theme["primary"];
	}

	public override void _Process(double delta)
	{
		Position += direction * (float)delta;
	}

	public void Start(Vector2 position, float rotation, Player parent)
	{
		Position = position;
		direction = new Vector2(Speed, 0).Rotated(rotation);
		this.parent = parent;
	}

	private void HitboxCollisionHandler(Node2D body)
	{
		if (!body.IsInGroup(Global.Enemy)) return;

		if (body is Enemy)
		{
			Enemy enemy = (Enemy)body;
			enemy.Damage(Damage);
		}
		QueueFree();
	}

}

