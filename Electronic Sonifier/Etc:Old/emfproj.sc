// MAIN ISSUES
// 1. how do i set the right bin to the new amplitude? checking binfreq doesnt work bc the bin frequencies dont line up perfectly. TRY USING PARALLEL CHAINS
// 2. how do i access the value of the magnitude of a bin to check if it's equal to 0 or not, it's a demand-rate ugen

s.boot;

(
b = Buffer.alloc(s, 2048);
b.bufnum;

~changefreqlist = List(0);
~changemaglist = List(0);

~findquantizefreqs = { |item, i|
	//item.postln;
	//item.inspect;
	if(i.even, {
		if(item != 0, {
			var bin, binfreq, closestnote;
			bin = (i/2).floor;
			binfreq = bin * 48000 / 2048;
			closestnote = ~scalefreqlist.minItem({ arg item, i; abs(binfreq - item)});
			~changefreqlist = ~changefreqlist.add(closestnote);
			~changemaglist = ~changemaglist.add(item);
			item = 0;
		}, {item});
	}, {item});
};

~testfunc = { |magnitude, phase, bin, index|
	if(bin == 500, {
		[40, 0]
	}, {
		[0, 0]
	};)
};

~quantizefreqs = { |item, i|
	if(i.even, {
		var bin, binfreq;
		//SendReply.ar(Impulse.ar(48000), values: [item]);
		bin = (i/2).floor;
		binfreq = bin * 48000 / 2048;
		binfreq.postln;
		if(binfreq == ~changefreqlist[0], {
			item = ~changemaglist[0];
			~changefreqlist = ~changefreqlist.removeAt[0];
			~changemaglist = ~changemaglist.removeAt[0];
		}, {item});
	}, {item});
};

(
~scalefreqlist = List.new(0);
~root = 50;
~currentfreq = ~root;
~currentdegree = 0;
~currentoctave = 0;

while ( {~currentfreq < 20000}, {
	~scalefreqlist.add(~currentfreq); //add the current frequency into the list
	~currentdegree = ~currentdegree + 1; //increment the degree
	if ( ~currentdegree > 6, {~currentdegree = 0; ~currentoctave = ~currentoctave + 1;}); //wrap around to the next octave if needed
	~currentfreq = Scale.major.degreeToFreq(~currentdegree, ~root, ~currentoctave); //find the next frequency based on the scale
}
);

~scalefreqlist.postln;
)

) //run this for all the overhead



(
    {
	a = SoundIn.ar();
	f = FFT(b, a);
	//f = PV_RandComb(f, 0.95, Impulse.kr(0.4));
	//f = PV_LocalMax(f, 0.5);
	//f = PV_MagShift(f, 1, 0);
	//f = PV_BinShift(f, 1, MouseX.kr(0, 2));
	//f = PV_PhaseShift(f, MouseX.kr(0, 6.28), 1);

	//f = FFT(y, a);
	f = PV_LocalMax(f, 25);

	//f = f.pvcollect(2048, ~testfunc);

	l = UnpackFFT(f, 2048);
	//l = l.collect(~findquantizefreqs);
	//l = l.collect(~quantizefreqs);
	f = PackFFT(f, 2048, l);



	//f = f.pvcollect(2048, ~findquantizefreqs, 0, 512);
	//f = f.pvcollect(2048, ~quantizefreqs, 0, 2);

	//g = UnpackFFT(h, 2048);


	IFFT(f);

    }.freqscope;
) // run input

l[0].dpoll("Value", run: 1).inspect










