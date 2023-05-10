(
// PRESS M WITH LOOPSTATION IN FOREGROUND TO MUTE/UNMUTE INPUT SIGNAL
~c = { |mute=1, autotune=0, mode=0, base_freq = 6.25, note_offset = 0, amp = 1|
    var sig, freq, tunedFreq, tuningRatio, noteNumber, tunedSig, modulo12offset;
    var p1majorNote, p1roundedOffset, p2majorNote, p2roundedOffset, majorNote;

	//AUTOTUNE SECTION

    sig = SoundIn.ar(mul: 10*mute*amp);

    freq = Tartini.kr(sig)[0];

    tunedFreq = freq;

    a = (2.pow(1/12)) * freq / base_freq;
    b = 12*(a.log10());

    noteNumber = (b / (2.log10()));
    modulo12offset = (noteNumber-1) % 12;

    p1roundedOffset = ((modulo12offset/2).round())*2;
    p1majorNote = noteNumber - modulo12offset + p1roundedOffset;
	p1majorNote = p1majorNote + note_offset;

    p2roundedOffset = (((modulo12offset-5)/2).round())*2+5;
    p2majorNote = noteNumber - modulo12offset + p2roundedOffset;
	p2majorNote = p2majorNote + note_offset;

    majorNote = Select.kr(
        ((modulo12offset/5).trunc()/2).round(),
        [ p1majorNote, p2majorNote]
    );

    tunedFreq = 2.pow((majorNote - 1)/12) * base_freq;
    tuningRatio = tunedFreq / freq;

	tunedSig = Select.ar(autotune, [sig, PitchShift.ar(sig, pitchRatio: tuningRatio, timeDispersion: 0.5)]);

	////////// FX SECTION

	~g = Select.ar(mode, [tunedSig, MoogVCF.ar(tunedSig, 200, 0.8, mul: 4), MoogVCF.ar(tunedSig, MouseX.kr(20, 15000), MouseY.kr(0, 1)), Resonz.ar(tunedSig, MouseX.kr(20, 15000), MouseY.kr(0, 1)), GrainIn.ar(1, Impulse.kr(MouseY.kr(1, 100)), MouseX.kr(0.001, 0.03), tunedSig)]);

	Out.ar([0, 1, 4], ~g);

}.play(s);
)

~c.set(\amp, 1);
~c.set(\base_freq, 6.25); // Adjust base frequency here, keep it low so that the whole scale can be generated
~c.free

// Other parameters, use the GUI to adjust these
~c.set(\autotune, 0);
~c.set(\note_offset, 0);
~c.set(\mode, 1);
