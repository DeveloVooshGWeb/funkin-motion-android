const net = require('net');
const WebSocketClient = require('websocket').w3cwebsocket;

var guildUsed = "";
var channelUsed = "";

var client = new WebSocketClient("ws://localhost");

const gatewayVersion = 9;
const server = net.createServer(onClientConnection);
var daInt = setInterval(() => {}, 10000);

console.log('Starting Server...');

server.listen(9000, "127.0.0.1", function() {
	console.log('Server Started...');
})

function onClientConnection(sock) {
	console.log('Client With Address ' + sock.remoteAddress + ':' + sock.remotePort + ' Connected...');
	sendData(sock, 'mebus christ');
	sock.on('data', function(dataRaw) {
		var data = dataRaw.toString().trim();
		console.log('Message Received: ' + data);
		console.log(Buffer.from(data).toString('base64'));
		if (data == 'conClient')
		{
			console.log('Connecting...');
			sendData(sock, JSON.stringify({data: "hello lol"}));
			connect(sock);
		} else {
			if (isJSON(data)) {
				var data2 = JSON.parse(data);
				if (data2.op != null && data2.op == 20 && data2.token != null && typeof data2.token == 'string' && data2.guild_id != null && typeof data2.guild_id == 'string' && data2.channel_id != null && typeof data2.channel_id == 'string') {
					guildUsed = data2.guild_id;
					channelUsed = data2.channel_id;
					stringified = JSON.stringify({op: 2, d: {token: data2.token, intents: 513, properties: {$os: "linux", $browser: "chrome", $device: "chrome"}}});
					//console.log(stringified);
					client.send(stringified);
				} else {
					client.send(data);
				}
			}
		}
	})
	sock.on('close', function() {
		console.log('Socket Died!');
	})
	sock.on('error', function(err) {
		console.log(err);
	})
}

function reconnect()
{

	client = new WebSocketClient('wss://gateway.discord.gg/?v=' + gatewayVersion + '&encoding=json');
	
}

function connect(sock) {
	
	reconnect();
	
	client.onerror = function() {
		console.log('Connection Error');
		reconnect(sock);
	}

	client.onclose = function() {
		console.log('Connection Closed');
		reconnect(sock);
	}

	client.onopen = function() {
		console.log('WebSocket Client Connected...');
		sendData(sock, "conServer");
	}

	client.onmessage = function(e) {
		if (typeof e.data == 'string') {
			if (isJSON(e.data))
			{
				const { op, t, d } = JSON.parse(e.data);
				if (op == 10) {
					clearInterval(daInt);
					daInt = setInterval(() => {
						console.log("HEARTBEAT!");
						if (client.readyState == client.OPEN) {
							client.send(JSON.stringify({op: 1, d: null}));
						}
					}, d.heartbeat_interval);
				}
				switch(t) {
					case 'MESSAGE_CREATE':
						if ((d.channel_id == channelUsed || channelUsed == "") && (d.guild_id == guildUsed || guildUsed == "")) {
							console.log('Received: ' + e.data);
							sendData(sock, e.data);
						}
						break;
				}
			}
		}
	}
	
}

function isJSON(str) {
	try {
		JSON.parse(str);
		return true;
	} catch(e) {
		return false;
	}
}

function sendData(sock, data) {
	sock.write(Buffer.from(data).toString('base64') + "\r\r\n\n\r\n");
}