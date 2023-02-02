// Ricky Moctezuma 2023

// This is a short program that plays 4 notes sequentially in approximately increasing octaves via a Sawtooth oscillator
// The notes alternate between the left and right channels - note, I'm sure there's a more elegant way to do this using if/else, but for now I just used two if statements and added 1 to two of the frequencies to make them odd
// There is a frequency-based tremolo effect that becomes increasingly faster as the frequency increases

s.boot;

{
   [220, 441, 880, 1761].do {
      |n|
      n.postln; // output the current frequency being played
	  if(n.even, {f = {Saw.ar(n, 0.5 * SinOsc.ar(n/100))}.play(outbus:0, fadeTime:1)}); // play out of the left channel for even frequencies
	  if(n.odd, {f = {Saw.ar(n, 0.5 * SinOsc.ar(n/100))}.play(outbus:1, fadeTime:1)}); // play out of the right channel for odd frequencies
      2.wait; // wait 2 seconds
	  f.free; // stop the oscillator
   }
}.fork(); // shorthand to use a Routine so that .wait can be used