using Godot;
using System;

public partial class SoundUtils : Node
{
	public static void PlaySound(AudioStreamPlayer player)
	{
		float left = AudioServer.GetBusPeakVolumeLeftDb(0, 0);
		float right = AudioServer.GetBusPeakVolumeLeftDb(0, 0);
		if (left > -199 || right > -199 ) return;
		player.Play(0);
	}
}
