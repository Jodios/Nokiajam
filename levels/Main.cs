using Godot;
using System;

public partial class Main : Node2D
{
	[Export] public float EnemySpawnInterval = 2;
	[Export] public int MaxEnemySpawns = 10;
	private Timer enemySpawnTimer;
	private ColorRect background;

	public override void _Ready()
	{
		enemySpawnTimer = new Timer();
		AddChild(enemySpawnTimer);
		enemySpawnTimer.WaitTime = EnemySpawnInterval;
		enemySpawnTimer.Timeout += OnEnemySpawnTimeout;
		enemySpawnTimer.Start();
		Global.statsTracker.StartGame();
		background = GetNode<ColorRect>("background");
	}

	public override void _Process(double delta)
	{
		// doing anything related to gui changes should be done here. This function
		// is called every frame which can change....physics process is constant 
		Modulate = Global.theme["primary"];
	}

	private void OnEnemySpawnTimeout()
	{
		if (GetEnemyCount() < MaxEnemySpawns)
		{
			SpawnEnemy(EnemyTypes.Type.Normal);
		}
	}

	private int GetEnemyCount()
	{
		int enemyCount = 0;
		foreach (Node child in GetTree().Root.GetChildren())
		{
			if (child is Enemy)
			{
				enemyCount++;
			}
		}
		return enemyCount;
	}

	private void SpawnEnemy(EnemyTypes.Type type)
	{
		PackedScene enemyScene = GD.Load<PackedScene>("res://enemies/basic/Enemy.tscn");
		var enemy = (Enemy)enemyScene.Instantiate();
		enemy.EnemyType = type;
		enemy.Position = RandomSpawnPosition();
		GetTree().Root.AddChild(enemy);
	}

	private Vector2 RandomSpawnPosition()
	{
		int edge = new Random().Next(4);
		Vector2 spawnPosition;
		switch (edge)
		{
			case 0:
				spawnPosition = new Vector2(new Random().Next(84), 0);
				break;
			case 1:
				spawnPosition = new Vector2(84, new Random().Next(48));
				break;
			case 2:
				spawnPosition = new Vector2(new Random().Next(84), 48);
				break;
			case 3:
				spawnPosition = new Vector2(0, new Random().Next(48));
				break;
			default:
				spawnPosition = Vector2.Zero;
				break;
		}
		return spawnPosition;
	}
}
