using System;
using Godot;

public partial class Player : CharacterBody2D
{
	[Export] public float MaxHealth { set; get; } = 100.00f;
	[Export] public float Speed = 900;
	private MeshInstance2D player;
	private PackedScene projectileScene = GD.Load<PackedScene>("res://projectiles/basic/Projectile.tscn");
	private float health;
	[Signal] public delegate void PlayerPerishedEventHandler();
	private Global global;
	private string direction;

	public override void _Ready()
	{
		direction = "right";
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
			Projectile projectile = (Projectile)projectileScene.Instantiate();
			// int padding = isLeft ? -5 : 5;
			float projectileRotation;
			switch (direction)
			{
				case "up":
					projectileRotation = Mathf.DegToRad(270);
					break;
				case "down":
					projectileRotation = Mathf.DegToRad(90);
					break;
				case "left":
					projectileRotation = Mathf.DegToRad(180);
					break;
				case "right":
					projectileRotation = Mathf.DegToRad(0);
					break;
				default:
					projectileRotation = 0;
					break;
			}
			projectile.Start(GlobalPosition + new Vector2(0, 0), projectileRotation, this);
			GetTree().Root.AddChild(projectile);
		}
	}

	private void HandleMovement(double delta)
	{
		if (Input.IsActionPressed("up"))
		{
			direction = "up";
			Velocity = Vector2.Up * Speed * (float)delta;
		}
		else if (Input.IsActionPressed("down"))
		{
			direction = "down";
			Velocity = Vector2.Down * Speed * (float)delta;
		}
		else if (Input.IsActionPressed("left"))
		{
			direction = "left";
			Velocity = Vector2.Left * Speed * (float)delta;
		}
		else if (Input.IsActionPressed("right"))
		{
			direction = "right";
			Velocity = Vector2.Right * Speed * (float)delta;
		}
		else
		{
			Velocity = Vector2.Zero;
		}
	}
}
