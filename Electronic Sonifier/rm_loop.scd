// LOOPING SECTION

(
n = NetAddr.localAddr;
~bpm = 60;
~bufdur = 4; // duration in beats

//{Metro.ar(~bpm, 1)}.play;

// Instantiate buffers for loop tracks, calculating length based on the desired amount of beats and the current sample rate and tempo
~buf1 = Buffer.alloc(s, (~bufdur * s.sampleRate*(1/(~bpm/60))), bufnum: 1);
~buf2 = Buffer.alloc(s, (~bufdur * s.sampleRate*(1/(~bpm/60))), bufnum: 2);
~buf3 = Buffer.alloc(s, (~bufdur * s.sampleRate*(1/(~bpm/60))), bufnum: 3);
~buf4 = Buffer.alloc(s, (~bufdur * s.sampleRate*(1/(~bpm/60))), bufnum: 4);

// Create buflist for easier access to buffers via buffer number, and playlist to hold playback synths
~buflist = [~buf1, ~buf2, ~buf3, ~buf4];
~playlist = [0, 0, 0, 0];

// Buffer Record OSC Block
OSCdef(\bufrec, {
	arg msg;
	"Bufrec triggered".postln;

	// Wipe the previous buffer
	~buflist[msg[1] - 1].zero();

	// Record into the appropriate buffer and free the synth after
	{
		RecordBuf.ar(In.ar(4), bufnum: msg[1], recLevel: 1.0, loop: 0, doneAction:2); // Records into the buffer at half amplitude so as not to make the layers too loud.
		Out.ar([0, 1], [0]); // Mute output of RecordBuf so as not to double the current sound
	}.play(target: ~c, addAction:\addAfter);

	// Begin looped playback after recording is complete and load the synth into the playlist
	~playlist[msg[1] - 1] = {
		var play = PlayBuf.ar(1, bufnum: msg[1], loop: 1);
		Out.ar([0, 1], play);
	}.play();

}, "/bufrec");

// Buffer Play OSC Block
OSCdef(\bufplay, {
	arg msg;
	"Bufplay triggered".postln;

	// Checks if there is already an active synth in the playlist, and if not, create a new one and load it in
	if(~playlist[msg[1] - 1] == 0, {
		~playlist[msg[1] - 1] = {
			var play = PlayBuf.ar(1, bufnum: msg[1], loop: 1);
			Out.ar([0, 1], play);
		}.play;
	});
}, "/bufplay");

// Buffer Stop OSC Block
OSCdef(\bufstop, {
	arg msg;
	"Bufstop triggered".postln;

	// Checks if there is an active synth, and frees/resets it
	if(~playlist[msg[1] - 1] != 0, {
		~playlist[msg[1] - 1].free;
		~playlist[msg[1] - 1] = 0;
	});

}, "/bufstop");
)
