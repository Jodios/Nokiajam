using Godot;

/**
I still don't know what the best approach to doing this is. 
For now I will NOT use this type. I will just spawn multiple
basic projectiles in the player node.
**/
public partial class MultiplyProjectile : Node2D
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
		global = GetNode<Global>("/root/Global");
		hitbox = GetNode<Area2D>("hitbox");
		hitbox.BodyEntered += HitboxCollisionHandler;
		Modulate = Global.theme["primary"];
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
		if (!body.IsInGroup(Global.Enemy)) return;

		if (body is Enemy)
		{
			Enemy enemy = (Enemy)body;
			enemy.Damage(Damage);
		}
		QueueFree();
	}

}

