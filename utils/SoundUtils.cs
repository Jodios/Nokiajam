using Godot;
using System;

public partial class SoundUtils : Node
{
	public static void PlaySound(AudioStreamPlayer player)
	{
		float left = AudioServer.GetBusPeakVolumeLeftDb(0, 0);
		float right = AudioServer.GetBusPeakVolumeLeftDb(0, 0);
		GD.Print(left + "     :      " + right);
		if (left > -199 || right > -199 ) return;
		GD.Print("Playing");
		player.Play(0);
	}
}
