using Godot;
using System;

public partial class Enemy : CharacterBody2D
{
    public override void _Ready()
    {
		AddToGroup(Global.Enemy);
    }

	public void Damage(float damage){

	}
}
