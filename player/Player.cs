using Godot;
using Godot.Collections;

public partial class Player : CharacterBody2D
{
	[Export] public int MaxHealth { set; get; } = 3;
	[Export] public int MaxStuns { set; get; } = 3;
	[Export] public float Speed = 900;
	[Export] public ProjectileTypes.Type ProjectileType = ProjectileTypes.Type.Multiply;
	private MeshInstance2D player;
	public int Health { set; get; } = 0;
	public int Stuns { set; get; } = 0;
	[Signal] public delegate void PlayerPerishedEventHandler();
	private Global global;
	private Vector2 previousDirection;
	private Timer cooldownTimer;
	private bool coolingDown = false;
	private SoundUtils soundUtils;

	public override void _Ready()
	{
		previousDirection = Vector2.Right;
		global = GetNode<Global>("/root/Global");
		AddToGroup(Global.Player);
		player = GetNode<MeshInstance2D>("player");
		Health = MaxHealth;
		Stuns = MaxStuns;
		cooldownTimer = GetNode<Timer>("cooldown");
		cooldownTimer.Timeout += () =>
		{
			coolingDown = false;
		};
		soundUtils = GetNode<SoundUtils>("/root/SoundUtils");
	}

    public override void _Process(double delta)
    {
		// doing anything related to gui changes should be done here. This function
		// is called every frame which can change....physics process is constant 
		Modulate = Global.theme["secondary"];
    }

	public override void _PhysicsProcess(double delta)
	{
		HandleMovement(delta);
		HandleShootingAction();
		HandleStunAction();
		MoveAndSlide();
	}

	public void Damage(int damage)
	{
		Health -= damage;
		if (Health <= 0)
		{
			Die();
		}
	}

	private void Die()
	{
		Speed = 0;
		QueueFree();
		EmitSignal("PlayerPerished");
	}

	private void HandleStunAction()
	{
		if (Input.IsActionJustPressed("freeze"))
		{
			Array<Node> enemies = GetTree().GetNodesInGroup(Global.Enemy);
			foreach (var enemy in enemies)
			{
				enemy.Call("Stun");
			}
		}
	}

	private void HandleShootingAction()
	{
		if (coolingDown) return;
		if (Input.IsActionJustPressed("shoot"))
		{
			soundUtils.PlayShootingSound();
			coolingDown = true;
			cooldownTimer.Start();
			switch (ProjectileType)
			{
				case ProjectileTypes.Type.Basic:
					SpawnProjectile("res://projectiles/BasicProjectile.tscn");
					break;
				case ProjectileTypes.Type.Multiply:
					MultiplyProjectile("res://projectiles/BasicProjectile.tscn");
					break;
				default:
					SpawnProjectile("res://projectiles/BasicProjectile.tscn");
					break;
			}
		}
	}

	private void SpawnProjectile(string path)
	{
		PackedScene projectileScene = GD.Load<PackedScene>(path);
		var projectile = projectileScene.Instantiate();
		projectile.Call("Start", GlobalPosition + new Vector2(0, 0), previousDirection, this);
		GetTree().Root.AddChild(projectile);
	}

	private void MultiplyProjectile(string path)
	{
		PackedScene projectileScene = GD.Load<PackedScene>(path);
		for (int i = 0; i < 7; i++)
		{
			var multiplier = i % 2 == 0 ? 1 : -1;
			var projectile = projectileScene.Instantiate();
			projectile.CallDeferred(
				"Start",
				GlobalPosition + new Vector2(0, 0),
				previousDirection.Rotated(Mathf.DegToRad(i * 6 * multiplier)),
				this
			);
			GetTree().Root.AddChild(projectile);
		}
	}

	private void HandleMovement(double delta)
	{
		Vector2 direction = Vector2.Zero;
		if (Input.IsActionPressed("up"))
		{
			direction += Vector2.Up;
		}
		if (Input.IsActionPressed("down"))
		{
			direction += Vector2.Down;
		}
		if (Input.IsActionPressed("left"))
		{
			direction += Vector2.Left;
		}
		if (Input.IsActionPressed("right"))
		{
			direction += Vector2.Right;
		}
		if (direction != Vector2.Zero)
		{
			previousDirection = direction;
		}
		Velocity = direction * Speed * (float)delta;
	}

}
