// get input from touchOSC beatmachine buttons
s.boot;
~projectDir = "~/Development/music-game/Drummy-drummy/audio-engine/".standardizePath;
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



// audio buffer
~buf = Buffer.read(s, ~projectDir +/+ "1bar-metro.wav");
// trigger data buffer
~dataBuf = Buffer.read(s, ~projectDir +/+ "1bar-metro-data.wav");

// load buffers to arrays
~audioArr = [];
~buf.loadToFloatArray(action: {|arr|
  ~audioArr = arr;
  "loaded".postln;
});

~dataArr = [];
~dataBuf.loadToFloatArray(action: {|arr|
  ~dataArr = arr;
  "loaded".postln;
});

// Interleave them into a new buffer, format is
// audioL, audioR, data...
~combined = (~audioArr.size + ~dataArr.size).collect {|i|
  var mod = i % 3;
  var ind = floor(i / 3);

  if(mod == 2) {
    ~dataArr[ind];
  } {
    ~audioArr[(ind * 2) + mod];
  }
};

// load interleaved into a buffer
~triple = Buffer.loadCollection(s, ~combined, 3, {|buf| "done".postln;});
// save it as a new file for good use
~triple.write(~projectDir +/+ "1bar-metro-combined.wav", "wav", "int16");

// SynthDef for playing back audio and data
SynthDef(\comboPlayer, {|buf=0, out=0|
  var frames = BufFrames.kr(buf);
  var phase = Phasor.ar(0, BufRateScale.kr(buf), 0, frames).poll;
  var sig = BufRd.ar(3, buf, phase);
  var trig = Trig.ar(sig[2]);
  SendReply.kr(A2K.kr(trig), '/note', [1]);

  Out.ar(out,
    sig[0..1];
  );
}).add;

OSCdef(\trigger, {|msg, time, addr, recvPort|
  msg.postln;
}, '/note');


x.free;x = Synth(\comboPlayer, [\buf, ~triple]);