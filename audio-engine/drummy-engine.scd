// get input from touchOSC beatmachine buttons
s.boot;

// networking
(
~ip = "169.254.178.43";
~recvNetAddr = NetAddr(~ip, nil);
~sendNetAddr = NetAddr(~ip, 7777);
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
    state.postln;
    if(state == 1) {
      var rootFreq = 45.midicps;
      var degree = id - 1;

      Synth(\button, [
        \freq, Scale.melodicMinor.degreeToFreq(degree, rootFreq, 1)
      ]);
    };
  }
};


9.do {|i|
  var id = i + 1;
  var name = "button%".format(id).asSymbol;
  var path = "/1/push%".format(id).asSymbol;
  OSCdef(name, ~createOscAction.(id), path, ~recvNetAddr, 6666);
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


~buf = Buffer.read(s, Platform.userConfigDir+/+"sounds/1bar-metro.wav");