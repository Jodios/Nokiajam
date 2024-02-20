using Godot;
using System;
using Godot.Collections;

public partial class EnemyTypes : Node
{
	public enum Type
	{
		Normal,
	}

	public partial class EnemyTypeProperties : Resource
	{
		public float Health { get; set; }
		public float Speed { get; set; }
		public float StunDuration { get; set; }
	}

	public static readonly Dictionary<Type, EnemyTypeProperties> TypeProperties = new Dictionary<Type, EnemyTypeProperties>
	{
		{
			Type.Normal, 
			new EnemyTypeProperties 
			{ 
				Health = 50, 
				Speed = 5,
				StunDuration = 1
			} 
		},
	};
}
