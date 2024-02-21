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
		HealthItem.Finished += Finished;

		FreezeItem = GetNode<AudioStreamPlayer>("FreezeItem");
		FreezeItem.Finished += Finished;

		Freeze = GetNode<AudioStreamPlayer>("Freeze");
		Freeze.Finished += Finished;

		Perish = GetNode<AudioStreamPlayer>("Perish");
		Perish.Finished += Finished;

		EnemyHit = GetNode<AudioStreamPlayer>("EnemyHit");
		EnemyHit.Finished += Finished;

		Shoot = GetNode<AudioStreamPlayer>("Shoot");
		Shoot.Finished += Finished;
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
	}

	private void Finished() {
		playing = false;
	}
}
