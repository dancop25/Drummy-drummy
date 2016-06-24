HID.findAvailable;
HID.postAvailable;
~drummy = HID.open(2341, 34952, "USB_0925_8888_6200000");

~data = "/Volumes/Data/Users/arthurc/Development/music-game/Drummy-drummy/audio-engine/songs/1bar-metro.json".parseYAMLFile;

~hits = ~data["hits"].collect {|hit| [hit["type"].asInteger, hit["time"].asInteger]};

~buf = Buffer.read(s, "/Volumes/Data/Users/arthurc/Development/music-game/Drummy-drummy/audio-engine/songs/1bar-metro.wav");


(
SynthDef(\time, {|buf=0, t_trig=1, out=0|
  var phase = Phasor.ar(0, BufRateScale.kr(~buf), 0, BufFrames.kr(~buf));
  var sig = BufRd.ar(2, ~buf, phase, 0);
  // var env = EnvGen.ar(Env.new([1, 1], [BufDur.kr(~buf)]), doneAction: 2);
  var ms = (phase / BufSampleRate.kr(~buf)) * 1000;

  SendReply.kr(t_trig, '/time', [ms]);
  Out.ar(0, sig.dup);
}).add;
)

(
OSCdef(\time, {|msg|
  ~curTime = msg[3];
}, '/time');
)

x = Synth(\time, [\buf, ~buf]);

(
~curTime = 0;
Tdef(\clock, {
  inf.do {|i|
    x.set(\t_trig, 1);
    0.016.wait;
  };
}).play(SystemClock);
)


(
~testHit = {|id, button, action, inputTime, threshold = 100|
  if(action == \down) {
    ~hits.any {|hit| (hit[1] - inputTime).abs <= threshold }.postln;
  }
};
)


(

~inputActionFactory = {| hid |
  {| value, physValue, rawValue,  arrayValue, usage, page, elid |
    var button = switch (elid,
      6, { \leftRim },
      7, { \rightRim },
      13, { \leftDrum },
      1, { \rightDrum },
      9, { \select },
      8, { \start },
      { \unknown }
    );

    var actionIndex = if (button == \leftDrum) { ((127 - rawValue) / 127).asInteger } { rawValue };
    var action = switch (actionIndex,
      0, { \up },
      1, { \down }
    );


    ~testHit.(hid.id, button, action, ~curTime);
  };
};

~drummy.action = ~inputActionFactory.(~drummy);
)


(
if (w.notNil) { w.close };
w = Window("Drummy").front;

~updateVisualisation.stop;
~updateVisualisation = {
  var windowTime = 4000;
  var colors = [Color.red(1), Color.blue(1)];
  var scaledHits = ~hits.collect {|hit|
    IdentityDictionary.newFrom([
      'color', colors[hit[0]],
      'x', (hit[1] / windowTime) * w.bounds.width;
    ]);
  };

  inf.do {
    var timeX = (~curTime / windowTime) * w.bounds.width;
    w.drawFunc = {
      scaledHits.do {|hit|
        var x = hit['x'] - timeX;

        Pen.color = hit['color'];
        Pen.moveTo(x@0);
        Pen.lineTo(x@w.bounds.height);
        Pen.stroke;
      };
    };
    w.refresh;
    0.016.wait; // 62.5 fps
  };
}.fork(AppClock);

)


~curTime = 200