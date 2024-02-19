using System;
using Godot;

public partial class Player : CharacterBody2D
{
	[Export] public float MaxHealth { set; get; } = 100.00f;
	[Export] public float Speed = 900;
	[Export] public ProjectileTypes.Type ProjectileType = ProjectileTypes.Type.Multiply;
	private MeshInstance2D player;
	private float health;
	[Signal] public delegate void PlayerPerishedEventHandler();
	private Global global;
	private Vector2 previousDirection;

	public override void _Ready()
	{
		previousDirection = Vector2.Right;
		global = GetNode<Global>("/root/Global");
		AddToGroup(Global.Player);
		player = GetNode<MeshInstance2D>("player");
		health = MaxHealth;
		Modulate = Global.theme["primary"];
	}

	public override void _PhysicsProcess(double delta)
	{
		HandleMovement(delta);
		HandleShootingAction();
		MoveAndSlide();
	}

	public void Damage(float damage)
	{
		health -= damage;
		if (health <= 0)
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

	private void HandleShootingAction()
	{
		if (Input.IsActionJustPressed("shoot"))
		{
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
		for (int i = 0; i < 6; i++)
		{
			var multiplier = i%2 == 0 ? 1 : -1;
			var projectile = projectileScene.Instantiate();
			projectile.Call(
				"Start",
				GlobalPosition + new Vector2(0, 0),
				previousDirection.Rotated(Mathf.DegToRad(i*6*multiplier)),
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
