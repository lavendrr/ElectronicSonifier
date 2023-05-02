s.boot;

(
{
	var sig, freq, closestNote;
	sig = SoundIn.ar();
	//buf = ~scale;

	//freq = Tartini.kr(a)[0];
	//PrintVal.kr(freq);

	freq = Tartini.kr(sig)[0];

	//PrintVal.kr(index);
	//index = index/20000;
	//index = index * BufFrames.kr(buf);
	//pch = DegreeToKey.kr(buf, index.cpsmidi) + 48;
	//freq = pch.midicps;

	//sig = PitchShift.ar(sig, pitchRatio: 3);
	//t = Tartini.kr(sig)[0];
	//PrintVal.kr(t);





	closestNote = Control.kr(~scalefreqlist.minItem({ arg item, i; abs(~freq - item)}));

	//closestNote.postln;
	//ratio = closestNote/freq;

	sig = PitchShift.ar(sig, pitchRatio: closestNote/freq);


	Out.ar([0,1], sig);
}.freqscope
)

t[1].value

~scale = Buffer.loadCollection(s, Scale.major.degrees);

{(LFSaw.kr(0.8, 1)*10).poll;}.play

{a = SoundIn.ar();}.play;

~scalefreqlist.size

({
	a = SinOsc.ar(440);
	b = PitchShift.ar(a, pitchRatio: 2);
	PrintVal.kr(Tartini.kr(b)[0]);
	Out.ar([0,1], [b]);
}.play)

~scalefreqlist.dump;

~scalefreqlist.size.do

Post << ~scalefreqlist.dump;

(
{
    var sig, freq, base_freq, tunedFreq, tuningRatio, noteNumber, tunedSig;

    base_freq = 6.75;
	//sig = SinOsc.ar(MouseX.kr(100, 600));
	//sig = SinOsc.ar(SinOsc.ar(0.08, add: 1)*200);

	sig = SoundIn.ar();

    //buf = ~scale;

    //freq = Tartini.kr(a)[0];
    //PrintVal.kr(freq);

    freq = Tartini.kr(sig)[0];
    PrintVal.kr(freq);

    tunedFreq = freq;
    a = (2.pow(1/12)) * freq / base_freq;
    b = 12*a.log10();
    noteNumber = (b / (2.log10())).round();
    tunedFreq = 2.pow((noteNumber - 1)/12) * base_freq;
    tuningRatio = tunedFreq / freq;
    PrintVal.kr(tunedFreq);
    PrintVal.kr(tuningRatio);

    tunedSig = PitchShift.ar(sig, pitchRatio: tuningRatio);

    Out.ar([0,1], tunedSig);

}.freqscope;
)