package;

#if windows
import Discord.DiscordClient;
#end
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.Lib;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import discord.Logger;

import haxe.Http;
import lime.graphics.Image;
import openfl.display.BitmapData;
import haxe.io.Bytes;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;
		
	private var curPing:Dynamic = {};
	
	public var toProcess:Array<String> = [];
	public var currentIteration:Int = 0;
	
	public var isError:Bool = false;

	override function create()
	{
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		if (transIn != null)
			trace('reg ' + transIn.region);

		super.create();
	}


	var array:Array<FlxColor> = [
		FlxColor.fromRGB(148, 0, 211),
		FlxColor.fromRGB(75, 0, 130),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(255, 127, 0),
		FlxColor.fromRGB(255, 0 , 0)
	];

	var skippedFrames = 0;

	override function update(elapsed:Float)
	{
		TestServer.update();
		if (Logger.disconnected)
		{
			Logger.disconnected = false;
			Logger.createSocket();
		}
		Logger.update();
		
		if (FlxG.keys.justPressed.T)
		{
			Logger.createSocket();
		}
		
		if (Logger.messageReceived)
		{
			Logger.messageReceived = false;
			curPing = Logger.messageData;
			ping();
		}
	
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		if (FlxG.save.data.fpsRain && skippedFrames >= 6)
			{
				if (currentColor >= array.length)
					currentColor = 0;
				(cast (Lib.current.getChildAt(0), Main)).changeFPSColor(array[currentColor]);
				currentColor++;
				skippedFrames = 0;
			}
			else
				skippedFrames++;

		if ((cast (Lib.current.getChildAt(0), Main)).getFPSCap != FlxG.save.data.fpsCap && FlxG.save.data.fpsCap <= 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		lastBeat = curStep;
		curBeat = Math.floor(curStep / 4);
	}

	public static var currentColor = 0;

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{

		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
	
	public function getPFP(discordImagePixels:Null<BitmapData>, authorIdShit:String):BitmapData
	{
		// Y E S
		if (CachedPFP.cachedPFP.exists(authorIdShit))
		{
			var gotShit:Image = CachedPFP.cachedPFP.get(authorIdShit);
			if (Reflect.hasField(discordImagePixels, "image"))
				if (discordImagePixels.image != gotShit)
					return BitmapData.fromImage(gotShit);
				else
					return discordImagePixels;
			else
				return BitmapData.fromImage(gotShit);
		}
		else
			return discordImagePixels;
	}
	
	public function ping():Void
	{
		//PlayState overrides this and if your dumb then get out of here lol
		isError = false;
		if (!CachedPFP.cachedPFP.exists(curPing.author.id))
		{
			#if sys
			sys.thread.Thread.create(() -> {
			#end
				var currentIterationShit:Int = currentIteration++;
				var authorIdShit:String = Reflect.getProperty(curPing.author, "id");
				var avatarIdShit:String = Reflect.getProperty(curPing.author, "avatar");
				toProcess[currentIterationShit] = Reflect.getProperty(curPing.author, "id");
				var daContent:String = Reflect.getProperty(curPing, "content");
				var http:Http = new Http("https://cdn.discordapp.com/avatars/" + authorIdShit + "/" + avatarIdShit + ".png?size=128");
				http.onBytes = function(daBytes:Bytes)
				{
					CachedPFP.cachedPFP.set(toProcess[currentIterationShit], Image.fromBytes(daBytes));
				}
				http.onError = function(err)
				{
					isError = true;
				}
				http.request();
			#if sys
			});
			#end
		}
	}
}
