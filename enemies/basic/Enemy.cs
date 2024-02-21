using Godot;
using System;

public partial class Enemy : CharacterBody2D
{
	public EnemyTypes.Type EnemyType = EnemyTypes.Type.Normal;
	private float speed;
	private float health;
	private float stunDuration;
	private bool isStunned = false;
	private Node2D player;
	private Timer stunTimer;
	private SoundUtils soundUtils;
	private Global global;

	public override void _Ready()
	{
		global = GetNode<Global>("/root/Global");
		AddToGroup(global.Enemy);
		player = GetTree().Root.GetNode<Node2D>("/root/Main/Player");
		EnemyTypes.EnemyTypeProperties properties = EnemyTypes.TypeProperties[EnemyType];
		health = properties.Health;
		speed = properties.Speed;
		stunDuration = properties.StunDuration;
		stunTimer = new Timer();
		AddChild(stunTimer);
		stunTimer.OneShot = true;
		stunTimer.WaitTime = stunDuration;
		stunTimer.Connect("timeout", new Callable(this, nameof(OnStunTimerTimeout)));
		soundUtils = GetNode<SoundUtils>("/root/SoundUtils");
	}

    public override void _Process(double delta)
    {
		// doing anything related to gui changes should be done here. This function
		// is called every frame which can change....physics process is constant 
		Modulate = global.theme["secondary"];
    }
    public override void _PhysicsProcess(double delta)
	{
		HandleMovement();
	}
	
	public void Stun()
	{
		if (!isStunned)
		{
			isStunned = true;
			stunTimer.WaitTime = stunDuration;
			stunTimer.Start();
		}
		else
		{
			stunTimer.WaitTime = stunDuration;
		}
	}

	public void Damage(float damage)
	{
		soundUtils.PlayEnemyHitSound();
		health -= damage;
		if (health <= 0)
		{
			Die();
		}
	}

	private void Die()
	{
		speed = 0;
		global.statsTracker.AddEnemyDeath();
		QueueFree();
	}
	
	private void HandleMovement()
	{
		if (isStunned) { return; }
		Vector2 playerPosition = player.Position;
		Vector2 targetPosition = (playerPosition - Position).Normalized();
		if (Position.DistanceTo(playerPosition) > 2)
		{
			Velocity = targetPosition * speed;
			MoveAndSlide();
			LookAt(playerPosition);
		}
	}
	
	private void OnStunTimerTimeout()
	{
		isStunned = false;
	}
}
