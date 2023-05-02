// ELECTRONIC SONIFIER - SUPERCOLLIDER COMPONENT
// WIP
// RICKY MOCTEZUMA

(

// AUTOTUNE SECTION

{
    var sig, freq, base_freq, tunedFreq, tuningRatio, noteNumber, modulo12offset;
    var p1majorNote, p1roundedOffset, p2majorNote, p2roundedOffset, majorNote;

    base_freq = 6.25; // Fundamental frequency of the major scale being tuned to - set this to the lowest frequency value possible so that low frequencies will have values to quantize to
    sig = SoundIn.ar();

    freq = Tartini.kr(sig)[0]; // Get stream of current fundamental note

    PrintVal.kr(freq);

    tunedFreq = freq;
	// Implements empirical formula to get scale degree from frequency and fundamental
    a = (2.pow(1/12)) * freq / base_freq;
    b = 12*(a.log10());

    noteNumber = (b / (2.log10())); // Finds the chromatic scale degree, with decimals if not aligned exactly with an existing note. This scales infinitely up and does not wrap around for octaves yet
    modulo12offset = (noteNumber-1) % 12; // Finds note offset within the octave


	// Rounding mechanism for scale degrees 0-4
    p1roundedOffset = ((modulo12offset/2).round())*2; // Rounds to closest scale degree
    p1majorNote = noteNumber - modulo12offset + p1roundedOffset; // Combines octave base with the scale degree to get the final note degree

	// Rounding mechanism for scale degrees 5-12
    p2roundedOffset = (((modulo12offset-5)/2).round())*2+5; // Rounds to closest scale degree
    p2majorNote = noteNumber - modulo12offset + p2roundedOffset; // Combines octave base with the scale degree to get the final note degree

    // Note that the expression 1 - ROUND(TRUNC(X/5)/2,0) is basically true if x < 5, false otherwise
    // In this case supercollider picks p1majorNote in one case, p2majorNote in the other

    majorNote = Select.kr( // Functions as an if statement. Uses P1 rounding mechanism if the scale degree is 0-4 and uses P2 rounding mechanism for degrees 5-12
        ((modulo12offset/5).trunc()/2).round(),
        [ p1majorNote, p2majorNote]
    );

    tunedFreq = 2.pow((majorNote - 1)/12) * base_freq; // Reverse operation to output target frequency value from scale degree
    tuningRatio = tunedFreq / freq; // Finds ratio between original frequency and target frequency
    PrintVal.kr(tunedFreq);

    ~tunedSig = PitchShift.ar(sig, pitchRatio: tuningRatio, timeDispersion: 0.5); // Adjusts pitch of entire signal to match the fundamental to desired note in scale. Time dispersion helps remove comb filter effect and smooth the signal out, but may introduce a slight delay effect

    Out.ar([0, 1], ~tunedSig);

}.play;


	// LOOPING SECTION (see important note on line 78)


	n = NetAddr.localAddr;
	~bpm = 60;
	~bufdur = 4; // duration in beats

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

		// ~metro = {Metro.ar(~bpm, 1)}.play;

		// Wipe the previous buffer
		~buflist[msg[1] - 1].zero();

		// Record into the appropriate buffer and free the synth after
		{
			RecordBuf.ar(SoundIn.ar(), bufnum: msg[1], recLevel: 1.0, loop: 0, doneAction:2); // Records into the buffer at half amplitude so as not to make the layers too loud. IMPORTANT NOTE: Right now, this takes input straight from the mic rather than from the results of the AutoTuned signal as intended. For some reason, if I try to pass it ~tunedSig, it just records zeros into the buffer and I'm not able to figure out why. Hopefully this can be used in conjunction with the AutoTune later.
			Out.ar([0, 1], [0]); // Mute output of RecordBuf so as not to double the current sound
		}.play;

		// Begin looped playback after recording is complete and load the synth into the playlist

		~playlist[msg[1] - 1] = {PlayBuf.ar(1, bufnum: msg[1], loop: 1)}.play;

	}, "/bufrec");

	// Buffer Play OSC Block
	OSCdef(\bufplay, {
		arg msg;
		"Bufplay triggered".postln;

		// Checks if there is already an active synth in the playlist, and if not, create a new one and load it in
		if(~playlist[msg[1] - 1] == 0, {
			~playlist[msg[1] - 1] = {PlayBuf.ar(1, bufnum: msg[1], loop: 1)}.play;
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
