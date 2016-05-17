s.boot;
s.options.inDevice = "Built-in Input";
s.options.outDevice = "Built-in Output";
~projectDir = "~/Development/music-game/Drummy-drummy/audio-engine/".standardizePath;

// networking
(
~ip = "192.168.18.106";
~recvNetAddr = NetAddr(~ip, nil);
~sendNetAddr = NetAddr(~ip, 6666);
);

// SynthDefs
SynthDef(\button, {|freq=220, mul=0.1, out=0|
  var sig = SinOsc.ar(freq);
  var env = EnvGen.ar(Env.perc, doneAction: 2);

  Out.ar(out,
    (sig * env * mul).dup;
  );
}).add;

// Input actions
(
~createOscAction = {|id|
  {|msg, time, addr, recvPort|
    var state = msg[1];
    [id, state].postln;
    if(state == 1) {
      var rootFreq = 67.midicps;
      // var degree = id - 1;
      var degree = id;

      Synth(\button, [
        \freq, Scale.melodicMinor.degreeToFreq(degree, rootFreq, 1)
      ]);
    };
  }
};


16.do {|i|
  // var id = i + 1;
  var id = i;
  var name = "button%".format(id).asSymbol;
  var path = "/button/%".format(id).asSymbol;
  OSCdef(name, ~createOscAction.(id), path, ~recvNetAddr, 5555);
};
);

// Button light functions
(
~buttonSet = {|id, val| ~sendNetAddr.sendMsg(id, val); };
~buttonOn = {|id| ~buttonSet.(id, 1); };
~buttonOff = {|id| ~buttonSet.(id, 0); };

~touchOSCButtonOn = {|id| ~buttonOn.("/1/push%".format(id)); };
~touchOSCButtonOff = {|id| ~buttonOff.("/1/push%".format(id)); };
);

// drummy sequence
Tdef(\rand, {
  inf.do {|i|
    var choice = i % 16;
    ~sendNetAddr.sendMsg("/button", choice, true);
    1.wait;
    ~sendNetAddr.sendMsg("/button", choice, false);

    1.wait;
  }
}).play(quant:Quant(1));

// Button random display pattern
Tdef(\random, {
  inf.do {|i|
    var randButtons = (1..9).scramble;

    (1..9).do {|x| ~touchOSCButtonOff.(x); };

    3.do {|j|
      ~touchOSCButtonOn.(randButtons[j]);
    };

    0.3.wait;
  }
}).play(quant:Quant(1));
