// Audio Programming and Performance
// SPRING 2023
// Week 1
// Sample code
// Visda Goudarzi

// use CMD D on something to pull up the documentation

//--to evaluate (run) a line, put the cursor on the line and press cmd+return (or ctrl+return on windows)

//--to evaluate a block of code, put the cursor somewhere inside the () and press cmd+return (or ctrl+return on windows)

//--boot the server
s.boot;

// show the meter
s.meter;

s.scope;


"Hello SuperCollider".postln;

LOCAL AND GLOBAL VARIABLES


// local needs to be declared as var

(
   var number;
   number = 5;
)
   number;

// overwriting the content of the variable
(
   var mynum;
   mynum = 3;
   mynum = mynum + 100;
   mynum = mynum / 2;
   mynum;
)

// variables
(
   // declare a variable named age and assign a value to it
   var age = 33;

   // here the variable ‘age’ gets a new value, or 33 + 1
   age = age + 1;
   age.postln; // and it posts 34
)

// variables that are lowercase letter don't need to be declared before use
a = 3; // we assign the number 3 to the variable "a"
a = "hello"; // we can also assign a string to it because SC is not strongly typed
a = 0.333312; // or a floating point number;
a = [1, 34, 55, 0.1, "string in a list", \symbol, pi]; // or an array with mixed types
a // hit this line and we see in the post window what "a" contains

(
var v, b;
v = 22;
b = 33;
"The value of a is :".post; b.postln;
)

"The value of b is now : ".post; b.postln; // then run this line

//environment variables
// -- global variables start with ~
// if you don't specify values, the defaults are set

~myvar = 333;
~myvar // post it;

FUNCTIONS

// create a function and store it in f
// function definitions are enclosed in curly brackets {}.
f = { 44.postln };

// calculate the midi note of a given frequency
f = {
	69 + ( 12 * log( 220/440 ) / log(2) )
};

f.value

f.def

//  arguments are values which are passed into the Function when it is evaluated.

// names of arguments in the list may be initialized to a default value by using an equals sign. Arguments which are not explicitly initialized will be set to nil if no value is passed for them.

// an argument list either begins with the reserved word arg, or is contained between two vertical bars.
arg a, b, c=3; // is equivalent to:

|a, b, c=3|


// when you call value on a Function, you can pass in arguments, in order, by putting them in parentheses:
someFunc.value(arg1, arg2)


// let's make the fuction above with an input argument frequency

f = {
	  arg freq;
      69 + ( 12 * log( freq/440 ) / log(2) )
}

f.value(880)


DATA STRUCTURES

ARRAYS

a = [11, 22, 33, 44, 55]; //we create an array with these five numbers

a[0]; // we get at the first item in the array (most programming languages index at zero)

a[4] // returns 55, as index 4 into the array contains the value 55

a[1]+a[4] // returns 77 as 22 plus 55 equals 77

a.reverse // we can reverse the array

a.maxItem // the array can tell us what is the highest value

a = Array.fill(5, { 100.rand }); // create an array with five random numbers from 0 to 100

a = Array.fill(5, 100.rand ) // create an array with ONE random number from 0 to 100

a = Array.fill(5, { arg i; i }); // create a function with the iterator (‘i’) argument
a = Array.fill(5, { arg i; (i+1)*11 }); // the same as the first array we created
a = Array.fill(5, { arg i; i*i });
a = Array.series(5, 10, 2); // a new method (series).
// Fill the array with 5 items, starting at 10, adding 2 in every step.

m = Scale.minor.degrees; // the Scale class will return the degrees of the minor scale

Scale.major.degrees

Array.with(7, 'eight',  9).postln;

Array.fill(10, { arg i; i * 2 });

a = a.add(100.rand)

LISTS

l = List.new;
l.add(100.rand) // try to run this a few times and watch the list grow


LOOPING

10.do(
	{ "SCRAMBLE THIS 10 TIMES".scramble.postln;

}) // integer number is also an object

(
  var counter = 0; 1000.do({
  counter = counter + 1; "counter is now: ".post; counter.postln;
})
)

// instead of such counter we can use the argument passed into the function in a loop:

10.do({arg counter; counter.postln;});
// you can call this argument whatever you want:
10.do({arg num; num.postln;});
// and the typical convention is to use the character "i" (for iteration):
10.do({arg i; i.postln;});

// print out all the prime numbers from 0 to 1000
(
   p = List.new;
   10000.do({ arg i; // i is the iteration from 0 to 10000
              if( i.isPrime, { p.add(i) }); // no else condition - we don't need it
           });
   Post << p;
)

//looping through and array or list
(
[ 11, 22, 33, 44, 55, 66, 77, 88, 99 ].do({arg item, counter; item.post; " is in the array at   slot: ".post; counter.postln;
});
)

// looping using while

while (testFunc, bodyFunc); // syntax
(
   i = 0;
   while ({ i < 30 }, { i = i + 1; i.postln; });
)


TESTING SOUND

// use CMD . to stop sound
// using curly brackets like this means you're basically making a temp nameless function

{SinOsc.ar}.play;

{[SinOsc.ar(440), SinOsc.ar(220)]}.play

// Octave higher
{SinOsc.ar(880, 0, 1)}.play;
// Half the amplitude
{SinOsc.ar(880, 0, 0.5)}.play;
// Add another oscillator to multiply the frequency
{SinOsc.ar(880 * SinOsc.ar(2), 0, 0.5)}.play;
// Or multiply the amplitude
{SinOsc.ar(880, 0, 0.5 * SinOsc.ar(2) )}.play;

{Saw.ar(440)}.play;

{[Saw.ar(440,Saw.ar(2)), SinOsc.ar(660,0,SinOsc.ar(0.5))]}.play;

s.volume.gui;

2 + 5 + 10; // just doing some math


rrand(10, 20); // generate a random number between 10 and 20

// start recording
s.record;

// make some cool stuff with sound here


// stop recording
s.stopRecording;

// or use GUI with record button, volume control, mute control
s.makeWindow;

