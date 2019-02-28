(~start = {

	//s.quit;

	// Setup -------------------------
	~ip = ["localhost"];
   //~ip = ["pi8", "zero2", "zero3", "pi7"];
	~clients = ~ip.size;
	~number = 0;
	~server = Array.newClear(~clients);
	~message = Array.newClear(~clients);
	~control = Array.newClear(~clients);
	~buffers = Array.newClear(~clients);
	~keys = Array.newClear(~clients);
	~clientindex = 0;

	~setServer = { arg ip;
		~clients.do{ |i|
			~server[i] = Server("cloud"+i, NetAddr(ip[i], 57110));
			~message[i] = NetAddr(ip[i], 57120);
			~control[i] = NetAddr(ip[i], 9100);
			~server[i].initTree;
		}
	};

	~setServer.value(~ip);

	~pulsen =
	// Synth Definition
	SynthDef("pulsen", {
		arg
		freq1 = 220,
		interv = 1.5,
		width = 0.5,
		puls1 = 2,
		puls2 = 3,
		mul = 0.05,
		time = 6;

		var pulse = Lag.kr(Pulse.kr([puls1, puls2], width, mul), 0.001);
		var envelope1 = XLine.kr(2, 1, time, doneAction: 2) - 1;
		var sound1 = SinOsc.ar(freq1, 0, pulse) * envelope1;
		var sound2 = SinOsc.ar([freq1, freq1+interv], 0, pulse) * envelope1;

		Out.ar(0, sound2);
	}).add;

	~synth1 = SynthDef("SYNTH1", { arg
		freq=440,
		cutoff = 4000,
		gate=1,
		amp=1,
		pan=0,
		time = 2;

		var lfo1 = Saw.kr(0.5, 5000, 100);
		var lfo2 = LFTri.kr(0.2, 0, 40, 0.5);
		var lfo3 = LFTri.kr(40 , 0, 0.2, 1);

		var square = LFPulse.ar(freq, 0, 0.2, 0.2);
		var saw = Saw.ar(freq/2, 0.2);
		var gatelope = XLine.kr(2, 1, time, doneAction: 0) - 1;
		var envelope1 = EnvGen.kr(Env.adsr(0.1,0.3,0.5,1,0.6,-4),gatelope,doneAction: 2);
		var envelope2 = EnvGen.kr(Env.adsr(0.01,1,0.5,0.5,0.6,-4),gatelope,doneAction: 2)*cutoff*lfo3;
		var sound = (square + saw) * envelope1 * amp*gatelope;
		var filter = MoogFF.ar(sound, envelope2, 0.5);


		Out.ar(0, Pan2.ar(filter, pan));
	}).add;

	~test1 =
	// Synth Defintion Test
	SynthDef("sine", { arg freq=800;
		var osc, env;
		env = EnvGen.kr(Env.sine(0.2), doneAction: 2);
		osc = SinOsc.ar(freq, 0, 0.1) *env; // 800 Hz sine oscillator

		Out.ar(0, osc); // send output to audio bus zero.
	});

	~test2 =
	// Synth Defintion Test
	SynthDef("click", { arg vol=0.5;
		var osc, env;
		env = EnvGen.kr(Env.perc(0.001, 0.5), doneAction: 2);
		osc = WhiteNoise.ar(vol)*env; // 800 Hz sine oscillator

		Out.ar(0, osc); // send output to audio bus zero.
	});

	s.waitForBoot {

		~clients.do { |i|
			~pulsen.send(~server[i]);
			~synth1.send(~server[i]);
			~test1.send(~server[i]);
			~test2.send(~server[i]);
		};

		// SetupEND  -------------------------

		// Test
		(
		);
		~testTone = Routine ({
			inf.do {
				~clients.do { |i|
					~server[i].sendMsg("/s_new", "click", x = ~server[i].nextNodeID, 1, 1);
					~server[i].sendMsg("/n_set",x, \vol, 0.2);
					["Test node", i].postln;
					0.5.wait;
				}
			}
		});
		//s.sync;
		//~testTone.play;

		~awake = Routine ({
			inf.do {
				~clients.do { |i|
					~server[i].sendMsg("/s_new", "click", x = ~server[i].nextNodeID, 1, 1);
					~server[i].sendMsg("/n_set",x, \vol, 0.01);
					["Test node", i].postln;
					0.2.wait;
				}
			}
		});
	};
};
~start.value();
)

~testTone.play;
~testTone.stop;
~testTone.reset;

~awake.play;
~awake.stop;
~awake.reset;


// To receive OSC messages from rhizome
(

var oldtime = 0;
var door = 0;

thisProcess.openUDPPort(9002);

b = NetAddr.new("localhost", 9000);

// Subscribing to receive all messages
b.sendMsg("/sys/subscribe", 9002, "/note");
b.sendMsg("/sys/subscribe", 9002, "/message");

o = OSCFunc({ arg msg, time, addr, recvPort; [msg, recvPort].postln; }, '/note');
o = OSCFunc({ arg msg, time, addr, recvPort; msg.postln; }, '/message');
//o = OSCFunc({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln; }, '/message');

// Now sending stuff
b.sendMsg("/message", "hello");

//b.sendMsg("/note", 220, 0.2);

// -------- SENDING FROM ODROID
// b = NetAddr.new("192.168.0.26", 9000);

o = OSCFunc({ arg msg, time, addr, recvPort; ~noteOn1.value(msg, time) }, '/note');


~noteOn1 = {
	arg msg, time;

	var node;
	var freq = msg[1];
	var volume = msg[2];
	var length = [3, 5, 8.3, 12];
	var duration, pulse;
	var xset = 0.5, yset = 0.5, zset= 0.5;

/*	if (msg[3].notNil,  {xset = (msg[3]+180) / 360});
	if (msg[4].notNil, {yset = (msg[4] + 180) /360});
	if (msg[5] != 0, {zset = msg[5]/360});*/
	~number = (~number + 1)%~clients;

	/*	["Note-Received", freq, volume, time].postln;
	~number = (~number + 1)%~client+1;
	if ((oldtime-time).abs < 0.01, { freq = - 1 });*/

	if (freq > 0) {

		["play note", ~number, xset, yset, zset].postln;


		// Synth X
		duration = length.choose;
		pulse = duration/3.5;
		door = (door + 1)%~clients;

		~server[~number].sendMsg("/s_new", "pulsen", m = ~server[~number].nextNodeID, 0, 1);
		~server[~number].sendMsg("/n_set", m,
			\freq1, freq,
			\interv, 40.rand,
			\width, 0.4.rand+0.1,
			\puls1, pulse + (20.rand/5),
			\puls2, pulse, // 19.rand,
			\mul, (0.7.rand+0.01)*volume,
			\time, duration- (duration/2).rand
		);

		/*		~server[~number].sendMsg("/s_new", "pulsen", node = ~server[~number].nextNodeID, 0, 1);
		~server[~number].sendMsg("/n_set", node,
		\freq1, freq,
		\interv, yset.abs*40.rand,
		\width, 0.4.rand+0.1,
		\puls1, pulse + zset.abs*40,
		\puls2, pulse, // 19.rand,
		\mul, (0.5.rand+0.1)*volume,
		\time, duration- (duration/xset*2)
		);*/

		oldtime = time;

		node = ~keys[~number];
		if (node.notNil, {
			~server[~number].sendMsg("/n_set", node, \gate, 0);
			~keys[~number] = nil;
		});

		node = ~server[~number].nextNodeID;

		~keys[~number] = node;

		~server[~number].sendMsg("/s_new", "SYNTH1", node, 0, 1);
		~server[~number].sendMsg("/n_set", node,
			\freq, freq,
			//\gate, 1,
			\amp, volume,
			//\cutoff, yset.abs*6000,
			\time, duration- (duration*xset).rand+0.232523
		);
	};

	/*	if (freq == 0) {

	node = ~keys[~number];
	if (node.notNil, {
	~server[~number].sendMsg("/n_set", node, \gate, 0);
	~keys[~number] = nil;
	});
	}*/

}
)



~testTone.stop;
~testTone.reset;

~server[0].sendMsg("/s_new", "sine", x = ~server[0].nextNodeID, 1, 1);
~server[1].sendMsg("/s_new", "sine", x = ~server[1].nextNodeID, 1, 1);
~server[2].sendMsg("/s_new", "sine", x = ~server[2].nextNodeID, 1, 1);
~server[3].sendMsg("/s_new", "sine", x = ~server[3].nextNodeID, 1, 1);
~server[4].sendMsg("/s_new", "sine", x = ~server[4].nextNodeID, 1, 1);
~server[5].sendMsg("/s_new", "sine", x = ~server[5].nextNodeID, 1, 1);
~server[6].sendMsg("/s_new", "sine", x = ~server[6].nextNodeID, 1, 1);
~server[7].sendMsg("/s_new", "sine", x = ~server[7].nextNodeID, 1, 1);
~server[8].sendMsg("/s_new", "sine", x = ~server[8].nextNodeID, 1, 1);
~server[9].sendMsg("/s_new", "sine", x = ~server[9].nextNodeID, 1, 1);
~server[10].sendMsg("/s_new", "sine", x = ~server[10].nextNodeID, 1, 1);

