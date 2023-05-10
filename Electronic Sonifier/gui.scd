// ORIGINAL LOOPING STATION CODE BY "rukano", FOUND AT https://sccode.org/1-1HT
// MODIFIED BY RICKY MOCTEZUMA FOR USE IN THE ELECTRONIC SONIFIER INSTRUMENT

var click_out = 0;
var win = Window("Super Looper", Rect(100, 200, 800, 650)).front;
var numbufs = 64;
var layout = win.addFlowLayout((0@0), (0@0));
var container = ();
var size = (40@40);
var metronome = ();
var font = Font("Synchro LET", 18);
var font2 = Font("Synchro LET", 14);
var buffer = nil!numbufs;
var durations = [2,4,8,16];
var player = nil!numbufs;
var player_button = (nil!(numbufs/4))!4;
var recorder_button = (nil!(numbufs/4))!4;
var reload_func = {
	var tempo = TempoClock.default.tempo.reciprocal;
	numbufs.do{ |i|
		var slot = floor(i/(numbufs/4));
		buffer[i].free;
		buffer[i] = Buffer.alloc(s, s.sampleRate * durations[slot] * tempo);
	};
};

TempoClock.default.tempo = 138/60;

// Window
win.view.background_(Color.white);
// Mute function assigned to the M key (MAYBE REMOVE THIS SINCE I ADDED THE BUTTON)
win.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
	if(keycode == 46, {
		~c.get(\mute, {
			|mute|
			if(mute == 1, {~c.set(\mute, 0); "Muted".postln}, {~c.set(\mute, 1); "Unmuted".postln});
		})
	}, {})
};


// Controls
StaticText(win, (800@10));

StaticText(win, (100@30))
.font_(font)
.string_(" Tempo:");

NumberBox(win, (100@30))
.align_(\right)
.font_(font)
.step_(0.01)
.scroll_step_(0.1)
.clipLo_(40)
.clipHi_(400)
.value_(TempoClock.default.tempo * 60)
.action_{ |v| TempoClock.default.tempo = (v.value / 60).postln};

StaticText(win, (40@10));
Button(win, (120@30))
.font_(font)
.states_([["Reload", Color.red, Color.white]])
.action_{ reload_func.value };
StaticText(win, (40@10));

StaticText(win, (100@30))
.font_(font)
.align_(\center)
.string_(" Click:");

metronome.button = Button(win, (100@30)).states_([
	["OFF", Color.white, Color.black],
	["ON", Color.white, Color.red(0.75)],
])
.font_(font)
.action_{ |v|
	if ( v.value.booleanValue )
		{ metronome.player_instance = metronome.player.play(quant:4) }
		{ metronome.player_instance.stop }
};

metronome.display = 4.collect{
	StaticText(win, (15@10));
	UserView(win, (30@30)).background_(Color.red(0.25))
};
StaticText(win, (15@10));
StaticText(win, (800@10));
layout.nextLine;

4.do{ |i| StaticText(win, (200@30)).align_(\center).font_(font).string_(durations[i]) };


// Loopers
4.do{ |i|
	var font = Font("Synchro LET", 14);
	var bsize = 43;
	container[i] = ();
	container[i].view = CompositeView(win, (200@400));
	container[i].view.background_([Color.black, Color.white, Color.black, Color.white][i]);
	container[i].layout = container[i].view.addFlowLayout((5@5),(5@5));
	(numbufs/4).do{ |j|
		var current_buffer = (i * (numbufs/4))+j;
		// REC
		recorder_button[i][j] = Button(container[i].view, (bsize@bsize))
		.font_(font)
		.states_([
			["REC", Color.red, Color.white],
			["-", Color.white, Color.red]
		])
		.action_{ |v|
			("will record buffer: "++current_buffer).postln;
			Pbind(
				\instrument, \buf_recorder,
				\buf, Pseq([buffer[current_buffer]], 1),
				\addAction, \addToTail
			).play(quant:4);
			AppClock.sched(
				(TempoClock.default.tempo.reciprocal * durations[i])
				+ ((TempoClock.default.nextBar - TempoClock.default.beats) * TempoClock.default.beatDur),
				{ v.value_(0) }
			);
		};

		// PLAY
		player_button[i][j] = Button(container[i].view, (bsize@bsize))
		.font_(font)
		.states_([
			["PLAY", Color.green, Color.white],
			["STOP", Color.black, Color.green(0.5)]
		])
		.action_{ |v|
			if (v.value.booleanValue) {
				("will play buffer: "++current_buffer).postln;
				buffer[current_buffer].postln;
				player[current_buffer] = Pbind(
					\instrument, \buf_player,
					\buf, buffer[current_buffer],
					\dur, durations[i]
				).play(quant:4);
			} {
				("stopping buffer: "++current_buffer).postln;
				player[current_buffer].stop;
			}
		};
	};
};


// FX MODE BUTTONS
StaticText(win, (20@15));
layout.nextLine;

StaticText(win, (15@1));
Button(win, (130@30))
.font_(font2)
.states_([["Bypass", Color.blue, Color.white]])
.action_{ ~c.set(\mode, 0); "FX Bypass mode enabled".postln; };
StaticText(win, (15@1));

StaticText(win, (15@1));
Button(win, (130@30))
.font_(font2)
.states_([["Preset Filter", Color.blue, Color.white]])
.action_{ ~c.set(\mode, 1); "Preset Filter mode enabled".postln; };
StaticText(win, (15@1));

StaticText(win, (15@1));
Button(win, (130@30))
.font_(font2)
.states_([["Variable Filter", Color.blue, Color.white]])
.action_{ ~c.set(\mode, 2); "Variable Filter mode enabled".postln;};
StaticText(win, (15@1));

StaticText(win, (15@1));
Button(win, (130@30))
.font_(font2)
.states_([["Resonz Filter", Color.blue, Color.white]])
.action_{ ~c.set(\mode, 3); "Resonz Filter mode enabled".postln; };
StaticText(win, (15@1));

StaticText(win, (15@1));
Button(win, (130@30))
.font_(font2)
.states_([["Granular", Color.blue, Color.white]])
.action_{ ~c.set(\mode, 4); "Granular mode enabled".postln; };
StaticText(win, (15@1));

layout.nextLine;
StaticText(win, (20@15));
layout.nextLine;
StaticText(win, (15@1));
~mutebutton = Button(win, (130@30))
.font_(font2)
.states_([["Enable AutoTune", Color.black, Color.white], ["Disable AutoTune", Color.black, Color.green]])
.action_{ ~c.get(\autotune, {arg val; if(val==0, {~c.set(\autotune, 1); "AutoTune enabled".postln}, {~c.set(\autotune, 0); "AutoTune disabled".postln}) }) };
StaticText(win, (15@1));

StaticText(win, (15@1));
NumberBox(win, (100@30))
.align_(\right)
.font_(font)
.step_(1)
.scroll_step_(1)
.clipLo_(-24)
.clipHi_(24)
.value_(0)
.action_{|v| ~c.set(\note_offset, v.value)};
StaticText(win, (10@30));
StaticText(win, (75@30))
.string_("AutoTune note offset");

layout.nextLine;
StaticText(win, (20@15));
layout.nextLine;

StaticText(win, (15@1));
Button(win, (130@30))
.font_(font2)
.states_([["Mute input", Color.black, Color.white], ["Unmute input", Color.black, Color.red]])
.action_{ ~c.get(\mute, {arg val; if(val==0, {~c.set(\mute, 1); "Muted input".postln}, {~c.set(\mute, 0); "Unmuted input".postln}) }) };
StaticText(win, (15@1));

StaticText(win, (15@1));
NumberBox(win, (100@30))
.align_(\right)
.font_(font)
.step_(0.1)
.scroll_step_(0.1)
.clipLo_(0.1)
.clipHi_(5)
.value_(1)
.action_{|v| ~c.set(\amp, v.value)};
StaticText(win, (10@30));
StaticText(win, (75@30))
.string_("Input amp multiplier");


// Players
metronome.player = Pbind(
	\instrument, \click,
	\freq, Pseq([1000, Pn(500,3)], inf)
);

metronome.display_player = Pbind(
	\type, \setProperties,
	\args, #[\background],
	\receiver, Pstutter(2, Pseq(metronome.display, inf)),
	\background, Pseq([Color.green, Color.red(0.25)], inf),
	\dur, Pseq([9,1]/10, inf)
).play(quant:4);

win.onClose_{
	metronome.display_player.stop;
	metronome.player_instance.stop;
	numbufs.do{ |i| buffer[i].free };
	SystemClock.clear;
	AppClock.clear;
	TempoClock.default.clear;
};

s = Server.default;
s.waitForBoot {

reload_func.value;

SynthDef(\click, { |freq|
	var snd = SinOsc.ar(freq, 0.5pi) * EnvGen.ar(Env.perc(0.001,0.05), doneAction:2);
	OffsetOut.ar(click_out, snd!2);
}).add;

SynthDef(\buf_recorder, { |buf|
		RecordBuf.ar(In.ar(4), buf, loop:0, doneAction:2)
}).add;

SynthDef(\buf_player, { |out, buf, rate=1|
	var snd = PlayBuf.ar(1, buf, rate, loop:0, doneAction:2);
	OffsetOut.ar(out, snd!2)
}).add;
};






