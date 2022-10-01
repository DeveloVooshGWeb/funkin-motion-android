package;

import openfl.display.BitmapData;
import lime.graphics.Image;
import haxe.io.Bytes;

class CachedPFP
{
	#if (haxe >= "4.0.0")
	public static var cachedPFP:Map<String, Image> = new Map();
	#else
	public static var cachedPFP:Map<String, Image> = new Map<String, Image>();
	#end
}