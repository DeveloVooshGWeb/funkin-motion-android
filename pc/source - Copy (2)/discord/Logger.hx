package discord;

import sys.net.Socket;
import sys.net.Host;
import haxe.Json;
import haxe.io.Bytes;
import flixel.util.FlxTimer;
import haxe.io.Eof;
import haxe.io.BytesBuffer;
import haxe.io.Bytes;
import haxe.crypto.Base64;
import haxe.io.Error;

using StringTools;

class Logger
{
	public static var daTim:FlxTimer;
	public static var client:Socket;
	public static var connected:Bool = false;
	public static var disconnected:Bool = false;
	public static var bufSize:Int = 16384;
	public static var buffer:Bytes = Bytes.alloc(bufSize);
	public static var buffer2:BytesBuffer = new BytesBuffer();
	public static var messageReceived:Bool = false;
	public static var messageData:Dynamic = {};
	
	public static function shutdownExistingSocket():Void
	{
		if (client != null)
		{
			client.shutdown(true, true);
			client.close();
		}
	}
	
	public static function createSocket():Void
	{
		disconnected = false;
		connected = false;
		
		shutdownExistingSocket();
	
		client = new Socket();
		try
		{
			client.connect(new Host("127.0.0.1"), 9000);
			client.listen(1);
			client.setBlocking(false);
			client.setFastSend(false);
			client.setTimeout(0);
			connected = true;
			socketSend("conClient");
		}
		catch(e:Dynamic)
		{
			errorCon(e);
			connected = false;
			disconnected = true;
		}
	}

	public static function socketSend(daStr:String):Void
	{
		if (client != null && connected)
		{
			try {
				var daBytesOfString = Bytes.ofString(daStr);
				client.output.writeBytes(daBytesOfString, 0, daBytesOfString.length);
			}
			catch(e:Dynamic)
			{
				trace('Error Sending Socket Data!');
			}
		}
	}
	
	public static function errorCon(err:Dynamic):Void
	{
		trace('Error Connecting: ' + err);
	}
	
	public static function bulkAnd(data1:Dynamic, data2:Array<String>):Bool
	{
		var toRet:Bool = true;
		for (shit in data2)
		{
			if (!Reflect.hasField(data1, shit))
			{
				toRet = false;
			}
		}
		return toRet;
	}
	
	public static function isJSON(str:String):Bool
	{
		try {
			Json.parse(str);
			return true;
		}
		catch(e:Dynamic)
		{
			return false;
		}
	}
	
	public static function isGWeb(daStr:String):Bool
	{
		try {
			if (!daStr.contains("\r\r\n\n\r\n"))
			{
				return false;
			}
			var daSplit:Array<String> = daStr.split("\r\r\n\n\r\n");
			for (b64 in daSplit)
			{
				Base64.decode(b64).toString();
			}
			return true;
		}
		catch(e:Dynamic)
		{
			return false;
		}
	}
	
	public static function onData(daString:String):Void
	{
		if (isJSON(daString))
		{
			var daJson:Dynamic = Json.parse(daString);
			if (bulkAnd(daJson, ["t", "d"]))
			{	
				switch(daJson.t)
				{
					case 'MESSAGE_CREATE':
						messageReceived = true;
						messageData = daJson.d;
				}
			}
		}
		else if (daString == 'conServer')
		{
			socketSend(Json.stringify({ op: 20, token: Token.token }));
		}
	}
	
	public static function update():Void
	{
		if (disconnected)
		{
			createSocket();
		}
	
		if (client != null && connected)
		{
			var sockets = Socket.select([client], null, null, 0);
			if (sockets.read.length > 0)
			{
				try {
					var bytesReceived = client.input.readBytes(buffer, 0, buffer.length);
					if (bytesReceived > 0)
					{
						buffer2.addBytes(buffer, 0, bytesReceived);
						while (buffer2.length > 2)
						{
							var bufferLength = buffer2.length;
							var daBytes:Bytes = buffer2.getBytes();
							buffer2 = new BytesBuffer();
							buffer = Bytes.alloc(bufSize);
							var daStringRaw:String = daBytes.toString();
							if (isGWeb(daStringRaw))
							{
								var forFuckSake:Array<String> = daStringRaw.split("\r\r\n\n\r\n");
								for (crap in forFuckSake)
								{
									var decodedStr:String = Base64.decode(crap).toString();
									if (decodedStr != "")
									{
										onData(decodedStr);
									}
								}
							}
						}
					}
				}
				catch(e:Dynamic)
				{
					trace('Socket Threw Error!');
					if (!(e == 'Blocking' || (Std.is(e, Error) && ((e:Error).match(Error.Custom(Error.Blocked)) || (e:Error).match(Error.Blocked)))))
					{
						trace('Socket Has Error!');
						shutdownExistingSocket();
						disconnected = true;
					}
				}
			}
		}
	}
}