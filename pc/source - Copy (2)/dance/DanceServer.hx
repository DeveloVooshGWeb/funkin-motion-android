package dance;

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

import flixel.FlxG;

using StringTools;

class DanceServer
{
	public static var server:Socket;
	public static var initialized:Bool = false;
	public static var bufSize:Int = 16384;
	public static var buffer:Bytes = Bytes.alloc(bufSize);
	public static var buffer2:BytesBuffer = new BytesBuffer();
	public static var messageReceived:Bool = false;
	public static var messageData:Dynamic = {};
	public static var ip:String = "127.0.0.1";
	public static var port:Int = 9000;
	public static var sockets:Array<Socket> = [];
	
	public static var accData:Array<Float> = [0, 0, 0];

	public static var justPresses:Array<Bool> = [false, false, false, false];
	public static var realJustPresses:Array<Bool> = [false, false, false, false];
	public static var pressed:Array<Bool> = [false, false, false, false];

	public static var up:Array<Bool> = [false, false];
	public static var right:Array<Bool> = [false, false];
	public static var down:Array<Bool> = [false, false];
	public static var left:Array<Bool> = [false, false];
	
	public static function createSocket(?daIp:String, ?daPort:Int):Void
	{
		initialized = false;
		
		ip = daIp != null ? daIp : ip;
		port = daPort != null ? daPort : port;
		
		if (server != null)
		{
			server.shutdown(true, true);
			server.close();
		}
		
		sockets = [];
		
		server = new Socket();
		try
		{
			server.bind(new Host(ip), port);
			server.listen(1);
			server.setBlocking(false);
			server.setFastSend(false);
			server.setTimeout(0);
			sockets = [server];
			initialized = true;
		}
		catch(e:Dynamic)
		{
			errorCon(e);
			initialized = false;
		}
	}
	
	public static function doGWeb(daStr:String):String
	{
		return "\r\r\n\n\r\n" + Base64.encode(Bytes.ofString(daStr));
	}
	
	public static function socketSend(daSocket:Socket, daStr:String):Void
	{
		if (server != null && initialized)
		{
			try {
				var daBytesOfString = Bytes.ofString(doGWeb(daStr));
				daSocket.output.writeBytes(daBytesOfString, 0, daBytesOfString.length);
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
	
	public static function isJSON(daStr:String):Bool
	{
		try
		{
			Json.parse(daStr);
			return true;
		}
		catch (e:Dynamic)
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

	public static function onData(daSocket:Socket, daString:String):Void
	{
		if (isJSON(daString))
		{
			var daParsed:Dynamic = Json.parse(daString);
			if (Std.is(daParsed, Array))
			{
				accData = daParsed;
			}
		}
	}
	
	public static function update():Void
	{
		if (server != null && initialized)
		{
			up = getControls(1);
			right = getControls(2);
			down = getControls(3);
			left = getControls(4);
			var inputSockets = Socket.select(sockets, null, null, 0);
			for (socket in inputSockets.read)
			{
				if (socket == server)
				{
					var newSocket = socket.accept();
					newSocket.setBlocking(false);
					newSocket.setFastSend(false);
					newSocket.setTimeout(0);
					sockets.push(newSocket);
				}
				else
				{
					try
					{
						var bytesReceived = socket.input.readBytes(buffer, 0, buffer.length);
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
								//trace(daStringRaw);
								if (isGWeb(daStringRaw))
								{
									var forFuckSake:Array<String> = daStringRaw.split("\r\r\n\n\r\n");
									for (crap in forFuckSake)
									{
										var decodedStr:String = Base64.decode(crap).toString();
										if (decodedStr != "")
										{
											onData(socket, decodedStr);
										}
									}
								}
							}
						}
					}
					catch(e:Dynamic)
					{
						trace('Client Socket Threw Error!');
						trace(e);
						sockets.remove(socket);
					}
				}
			}
		}
	}

	public static function getAccDataRounded(shit:Int):Float
	{
		//return FlxMath.roundDecimal(Server.accData[shit - 1], 2);
		return accData[shit - 1];
	}

	public static function getAccData():Array<Float>
	{
		return [getAccDataRounded(1), getAccDataRounded(2), getAccDataRounded(3)];
	}

	public static function compareCrap(toComp:Float, pos:Int):Bool
	{
		var comparer:Float = 0.005;
		var toRet:Bool = false;
		switch(pos)
		{
		case 0 | 3:
			if (toComp < comparer * -1)
			{
				toRet = true;
			}
		case 2 | 1:
			if (toComp > comparer)
			{
				toRet = true;
			}
		default:
			if (toComp < comparer * -1)
			{
				toRet = true;
			}
		}
		return toRet;
	}

	public static function getControls(pos:Int):Array<Bool>
	{
		var ourTable:Array<Bool> = [false, false, false];
		var realPos:Int = pos - 1;
		//var compareCrapShit:Int = -1;
		var ourAccData:Array<Float> = getAccData();
		var toUseData:Float = -99999;
		switch(realPos)
		{
			case 0 | 2:
				toUseData = ourAccData[2];
			case 1 | 3:
				toUseData = ourAccData[0];
		}
		//trace('real pos: ' + realPos + ' coordinates: ' + toUseData);
		//trace('real pos: ' + realPos + ' COMPARE: ' + compareCrap(toUseData, realPos));
		if (toUseData != -99999)
		{

			/*if (compareCrap(ourAccData[2], 99999)) //anything lol except 0 1 2 and 3
			{
				
			}*/
			//was suppose to make you push ur phone before input will be accepted lol
			
			//if (compareCrap(toUseData, realPos) || ((realPos == 1 || realPos == 3) && compareCrap(ourAccData[1], realPos)))

			if (compareCrap(toUseData, realPos))
			{
			
				/*if (!Server.justPresses[realPos])
				{
					Server.realJustPresses[realPos] = true;
					Server.justPresses[realPos] = true;
				} else {
					Server.realJustPresses[realPos] = false;
				}*/
				
				if (!pressed[realPos])
				{
					realJustPresses[realPos] = true;
					pressed[realPos] = true;
				} else {
					realJustPresses[realPos] = false;
				}
			} else {
			
				/*if (Server.justPresses[realPos])
				{
					Server.realJustPresses[realPos] = false;
					Server.justPresses[realPos] = false;
				}*/
				
				if (pressed[realPos])
				{
					pressed[realPos] = false;
				}
			}
			
			var orCrap:Bool = false;
			var orCrap2:Bool = false;

			/*switch(realPos)
			{
			case 0:
				orCrap = FlxG.keys.pressed.UP;
				orCrap2 = FlxG.keys.justPressed.UP;
			case 1:
				orCrap = FlxG.keys.pressed.RIGHT;
				orCrap2 = FlxG.keys.justPressed.RIGHT;
			case 2:
				orCrap = FlxG.keys.pressed.DOWN;
				orCrap2 = FlxG.keys.justPressed.DOWN;
			case 3:
				orCrap = FlxG.keys.pressed.LEFT;
				orCrap2 = FlxG.keys.justPressed.LEFT;
			}*/

			/*ourTable[0] = pressed[realPos] || orCrap;
			ourTable[1] = realJustPresses[realPos] || orCrap2;*/
			
			ourTable[0] = pressed[realPos];
			ourTable[1] = realJustPresses[realPos];
			
			switch(realPos)
			{
				case 0:
					if (up[0] && !ourTable[0])
						ourTable[2] = true;
				case 1:
					if (right[0] && !ourTable[0])
						ourTable[2] = true;
				case 2:
					if (down[0] && !ourTable[0])
						ourTable[2] = true;
				case 3:
					if (left[0] && !ourTable[0])
						ourTable[2] = true;
			}
			
			//trace(ourTable);
			return ourTable;
		} else {
			return ourTable;
		}
	}
}