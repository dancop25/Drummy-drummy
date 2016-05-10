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



~buf = Buffer.read(s, ~projectDir +/+ "1bar-metro.wav");
~dataBuf = Buffer.read(s, ~projectDir +/+ "1bar-metro-data.wav");

SynthDef(\combiner, {|audio, data, combined|
  var phase = Phasor.ar(0, BufRateScale.kr(audio), 0, BufFrames.kr(audio));
  var sigAudio = BufRd.ar(2, audio, phase);
  var sigData = BufRd.ar(1, data, phase);
  var env = EnvGen.ar(Env([1, 0], [BufDur.kr(audio)]), 1, doneAction: 2);
  var sigs = [sigData, sigData, sigData];
  env.poll;

  BufWr.ar(sigs, combined, phase, 0);
}).add;

~triple = Buffer.alloc(s, ~buf.numFrames, 3);
Synth(\combiner, [\audio, ~buf, \data, ~dataBuf, \combined, ~triple]);

~triple.loadToFloatArray(action: {|arr| ~gogo = arr;
  ~gogo.select {|x| x > 0}.postln
});


~dataBuf.loadToFloatArray(action: {|arr| ~gogoData = arr; });
~gogoData.select {|x| x > 0}.size

~data = FloatArray.newClear(~buf.numFrames);
~data = ~data.collect {|x, i|
  if(i % ~buf.sampleRate == 0) { 1 } { 0 };
};

~dataBuf = Buffer.loadCollection(s, ~data, 1, {|buf|
  var path = "%1bar-metro-data.wav".format(~projectDir);
  "buffer loaded".postln;
  buf.write(path, "wav", "int16");
});

~buf.loadToFloatArray(action: {|arr|
  ~data = arr;
  "loaded".postln;
});




SynthDef(\trigger, {|buf=0, out=0|
  var phase = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
  var sig = BufRd.ar(1, buf, phase);
  var trig = Trig.ar(sig);
  SendReply.kr(A2K.kr(trig), '/note', [1]);
}).add;

~trigger = Synth(\trigger, [\buf, ~buf]);
~trigger.free;

OSCdef(\trigger, {|msg, time, addr, recvPort|
  msg.postln;
}, '/note');




(
a = [1, 1, 1, 0, 0, 0];
b = Buffer.alloc(s, 2, 3);
)
b = b.sendCollection(a, action: {arg buf; "finished".postln;});

b.loadToFloatArray(action: {|arr|
  arr.postln;
});

b.plot

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

~audioArr.size
~dataArr.size

~combined = (~audioArr.size + ~dataArr.size).collect {|i|
  var mod = i % 3;
  var ind = floor(i / 3);

  if(mod == 2) {
    ~dataArr[ind];
  } {
    ~audioArr[(ind * 2) + mod];
  }
};

~triple = Buffer.loadCollection(s, ~combined, 3, {|buf| "done".postln;});

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

x.free;x = Synth(\comboPlayer, [\buf, ~triple]);

~triple.duration

~combined.size / 3 / 44100
~audioArr.size / 2 / 44100
~dataBuf.size