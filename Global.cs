using Godot;
using Godot.Collections;

public partial class Global : Node
{

	private static Dictionary<string, Dictionary<string, Color>> themes = new(){
		{
			"original", new(){
				{"primary", new("#c7f0d8")},
				{"secondary", new("#43523d")}
			}
		},
		{
			"harsh", new(){
				{"primary", new("#9bc700")},
				{"secondary", new("#2b3f09")}
			}
		},
		{
			"gray", new(){
				{"primary", new("#879188")},
				{"secondary", new("#1a1914")}
			}
		},
	};
	public static Dictionary<string, Color> theme = themes["original"]; 

	public const string Enemy = "enemy";
	public const string Player = "player";
	public const string Border = "border";

	public Node CurrentScene { get; set; }

	public override void _Ready()
	{
		Viewport root = GetTree().Root;
		CurrentScene = root.GetChild(root.GetChildCount() - 1);
	}
}
