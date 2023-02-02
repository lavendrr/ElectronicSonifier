s.boot;

{PMOsc.ar(XLine.ar(100, 4000, 5), XLine.ar(5000,3000, 7), 5, 180)}.play
{PMOsc.ar(440)}.play;

{Trig.ar(Dust.ar(8), 0.5) * SinOsc.ar(Trig.ar(Dust.ar(8,1,400),0.5))}.play

{SinOsc.ar(1760)}.play;