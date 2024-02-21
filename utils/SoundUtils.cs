using Godot;

/*
Started regretting doing it this way mid way :D 
*/
public partial class SoundUtils : Node
{
	public AudioStreamPlayer HealthItem;
	public AudioStreamPlayer FreezeItem;
	public AudioStreamPlayer Freeze;
	public AudioStreamPlayer Perish;
	public AudioStreamPlayer EnemyHit;
	public AudioStreamPlayer Shoot;
	private bool playing = false;
	public override void _Ready()
	{
		HealthItem = GetNode<AudioStreamPlayer>("HealthItem");
		FreezeItem = GetNode<AudioStreamPlayer>("FreezeItem");
		Freeze = GetNode<AudioStreamPlayer>("Freeze");
		Perish = GetNode<AudioStreamPlayer>("Perish");
		EnemyHit = GetNode<AudioStreamPlayer>("EnemyHit");
		Shoot = GetNode<AudioStreamPlayer>("Shoot");
	}
	public void PlayPickupHealthItemSound() { PlaySound(HealthItem); }
	public void PlayPickupFreezeItemSound() { PlaySound(FreezeItem); }
	public void PlayFreezeActionSound() { PlaySound(Freeze); }
	public void PlayPerishSound() { PlaySound(Perish); }
	public void PlayEnemyHitSound() { PlaySound(EnemyHit); }
	public void PlayShootingSound() { PlaySound(Shoot); }
	private void PlaySound(AudioStreamPlayer player)
	{
		if (playing) return;
		playing = true;
		player.Play(0);
		player.Finished += () => { playing = false; };
	}
}
