(
~c = { |mute=1|
    var sig, freq, base_freq, tunedFreq, tuningRatio, noteNumber, tunedSig, modulo12offset;
    var p1majorNote, p1roundedOffset, p2majorNote, p2roundedOffset, majorNote;

    base_freq = 6.25; // Fundamental frequency of the major scale being tuned to - set this to the lowest frequency value possible so that low frequencies will have values to quantize to. Default 6.25
    sig = SoundIn.ar();

    freq = Tartini.kr(sig)[0]; // Get stream of current fundamental note

    //PrintVal.kr(freq);

    tunedFreq = freq;
	// Implements empirical formula to get scale degree from frequency and fundamental
    a = (2.pow(1/12)) * freq / base_freq;
    b = 12*(a.log10());

    noteNumber = (b / (2.log10())); // Finds the chromatic scale degree, with decimals if not aligned exactly with an existing note. This scales infinitely up and does not wrap around for octaves yet
    modulo12offset = (noteNumber-1) % 12; // Finds note offset within the octave

	// Rounding mechanism for scale degrees 0-4
    p1roundedOffset = ((modulo12offset/2).round())*2; // Rounds to closest scale degree
    p1majorNote = noteNumber - modulo12offset + p1roundedOffset; // Combines octave base with the scale degree to get the final note degree
	//p1majorNote = p1majorNote + MouseX.kr(-7, 7).round;

	// Rounding mechanism for scale degrees 5-12
    p2roundedOffset = (((modulo12offset-5)/2).round())*2+5; // Rounds to closest scale degree
    p2majorNote = noteNumber - modulo12offset + p2roundedOffset; // Combines octave base with the scale degree to get the final note degree
	//p2majorNote = p2majorNote + MouseX.kr(-7, 7).round;

    // Note that the expression 1 - ROUND(TRUNC(X/5)/2,0) is basically true if x < 5, false otherwise
    // In this case supercollider picks p1majorNote in one case, p2majorNote in the other

    majorNote = Select.kr( // Functions as an if statement. Uses P1 rounding mechanism if the scale degree is 0-4 and uses P2 rounding mechanism for degrees 5-12
        ((modulo12offset/5).trunc()/2).round(),
        [ p1majorNote, p2majorNote]
    );

    tunedFreq = 2.pow((majorNote - 1)/12) * base_freq; // Reverse operation to output target frequency value from scale degree
    tuningRatio = tunedFreq / freq; // Finds ratio between original frequency and target frequency

    //PrintVal.kr(tunedFreq);

	tunedSig = PitchShift.ar(sig, pitchRatio: tuningRatio, timeDispersion: 0.5); // Adjusts pitch of entire signal to match the fundamental to desired note in scale. Time dispersion helps remove comb filter effect and smooth the signal out

	//////////

	~g = GrainIn.ar(1, Impulse.kr(MouseY.kr(1, 100)), MouseX.kr(0.001, 0.03), tunedSig, mul: mute); // sounds cool when drawing exponential graphs with the mous

	//~g = MoogVCF.ar(tunedSig, MouseX.kr(20, 15000), MouseY.kr(0, 1)); // Try quantizing the cutoff frequency and using a high resonance to generate a tuned pitch out of more noisy inputs?

	//~g = Resonz.ar(tunedSig, MouseY.kr(20, 15000), MouseX.kr(0, 1));

	Out.ar([0, 1, 4], ~g);

}.play(s);
)

