package;

import haxe.crypto.Base64;
import haxe.io.Bytes;

class BotData
{
	public static var token:String = Base64.decode("Bot Token In Base64").toString();
	public static var guild_id:String = "";
	public static var channel_id:String = "";
}