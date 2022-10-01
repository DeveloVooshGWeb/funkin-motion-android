package;

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

class TestServer
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
		
	}
	
	public static function update():Void
	{
		if (server != null && initialized)
		{
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
								trace(daStringRaw);
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
}