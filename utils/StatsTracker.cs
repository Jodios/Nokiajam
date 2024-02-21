using System;
using System.Collections.Generic;
using Godot;
using System.Diagnostics;

public partial class StatsTracker
{
	public class DataModel
	{
		public List<Stat> Stats { get; set; } = new List<Stat>();
	}
	
	public class Stat
	{
		public int ID;
		public float timePlayed;
		public int enemiesKilled;
		public int shotsFired;
		public int shotsLanded;
		public float accuracy;
		public DateTime dateSaved;
	}
	
	private static DataModel _data;
	private const string SAVE_PATH = "user://stats.save";
	private const string STATS = "stats";
	private Stat currentStats = new Stat();
	private Stopwatch stopwatch = new Stopwatch();
	
	public void Initialize()
	{
		LoadStatsFromFile();
	}
	
	public Stat GetLatestStat()
	{
		if (_data == null || _data.Stats.Count == 0)
			return null;

		int lastIndex = _data.Stats.Count - 1;
		return _data.Stats[lastIndex];
	}
	
	public void StartGame()
	{
		stopwatch.Reset();
		stopwatch.Start();
		currentStats = new Stat();
	}
	
	public void StopGame(bool saveStats = true)
	{
		stopwatch.Stop();
		currentStats.dateSaved = DateTime.Now;
		if (saveStats)
			SaveStats();
	}

	public void AddEnemyDeath()
	{
		currentStats.enemiesKilled++;
	}

	public void AddShotLanded()
	{
		currentStats.shotsLanded++;
	}

	public void AddShotFired()
	{
		currentStats.shotsFired++;
	}

	public void SaveStats()
	{
		if (currentStats.shotsFired > 0)
			currentStats.accuracy = (float)currentStats.shotsLanded / currentStats.shotsFired * 100f;
		currentStats.ID = _data.Stats.Count + 1;
		TimeSpan elapsedTime = stopwatch.Elapsed;
		currentStats.timePlayed = (float)elapsedTime.TotalSeconds;
		SaveStatsToFile();
	}

	private void SaveStatsToFile()
	{
		using var saveGame = FileAccess.Open(SAVE_PATH, FileAccess.ModeFlags.Write);
		_data.Stats.Add(currentStats);
		var jsonData = convertDataModelToJsonData(_data);
		var jsonString = Json.Stringify(jsonData);
		saveGame.StoreLine(jsonString);
	}
	
	private void LoadStatsFromFile()
	{
		if (!FileAccess.FileExists(SAVE_PATH))
		{
			_data = new DataModel();
			return;
		}
		using var saveGame = FileAccess.Open(SAVE_PATH, FileAccess.ModeFlags.Read);
		var jsonString = saveGame.GetLine();
		var json = new Json();
		var parseResult = json.Parse(jsonString);
		if (parseResult != Error.Ok)
		{
			GD.Print($"JSON Parse Error: {json.GetErrorMessage()} in {jsonString} at line {json.GetErrorLine()}");
			_data = new DataModel();
			return;
		}
		var jsonData = new Godot.Collections.Dictionary<string, Variant>((Godot.Collections.Dictionary)json.Data);
		_data = convertJsonDataToDataModel(jsonData);
		GD.Print("Loading from file");
		GD.Print(jsonData);
	}
	
	private DataModel convertJsonDataToDataModel(Godot.Collections.Dictionary<string, Variant> jsonData)
	{
		DataModel dataModel = new DataModel();
		if (jsonData.TryGetValue("stats", out Variant value))
		{
			Godot.Collections.Array array = value.As<Godot.Collections.Array>();
			foreach (Variant item in array)
			{
				Godot.Collections.Dictionary<string, Variant> statDict = item.As<Godot.Collections.Dictionary<string, Variant>>();
				Stat stat = new Stat();
				stat.ID = (int)statDict["ID"];
				stat.timePlayed = (float)statDict["timePlayed"];
				stat.enemiesKilled = (int)statDict["enemiesKilled"];
				stat.shotsFired = (int)statDict["shotsFired"];
				stat.shotsLanded = (int)statDict["shotsLanded"];
				stat.accuracy = (float)statDict["accuracy"];
				stat.dateSaved = DateTime.Parse(statDict["dateSaved"].ToString());
				dataModel.Stats.Add(stat);
			}
		}
		return dataModel;
	}
	
	private Godot.Collections.Dictionary<string, Variant> convertDataModelToJsonData(DataModel dataModel)
	{
		Godot.Collections.Dictionary<string, Variant> raw = new Godot.Collections.Dictionary<string, Variant>();
		Godot.Collections.Array statArray = new Godot.Collections.Array();
		foreach (Stat stat in dataModel.Stats)
		{
			Godot.Collections.Dictionary<string, Variant> statDict = new Godot.Collections.Dictionary<string, Variant>
			{
				{ "ID", stat.ID },
				{ "timePlayed", stat.timePlayed },
				{ "enemiesKilled", stat.enemiesKilled },
				{ "shotsFired", stat.shotsFired },
				{ "shotsLanded", stat.shotsLanded },
				{ "accuracy", stat.accuracy },
				{ "dateSaved", stat.dateSaved.ToString("o") }
			};
			statArray.Add(statDict);
		}
		raw["stats"] = statArray;
		return raw;
	}
}
