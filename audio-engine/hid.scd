HID.findAvailable;
HID.postAvailable;
~drummy = HID.open(2341, 34952, "USB_0925_8888_6200000");

~kickBuf = Buffer.read(s, Platform.userExtensionDir +/+ "sounds/linndrum/kick.wav");
~snareBuf = Buffer.read(s, Platform.userExtensionDir +/+ "sounds/linndrum/sd.wav");
~cowBuf = Buffer.read(s, Platform.userExtensionDir +/+ "sounds/linndrum/cowb.wav");
~hatBuf = Buffer.read(s, Platform.userExtensionDir +/+ "sounds/linndrum/chh.wav");
~punkBuf = Buffer.read(s, Platform.userExtensionDir +/+ "sounds/daftpunkacapella-trim.wav");

SynthDef(\player, {|buf=0, mul=1, out=0|
	var sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf), doneAction: 2);

	Out.ar(out, Pan2.ar(sig) * mul);
}).add;

(
~hitAction = {|id, button, action|
	if (action == \down) {
		var buf, mul;
    switch (button,
      \leftRim,   { buf = ~cowBuf; mul = 3 },
      \rightRim,  { buf = ~hatBuf; mul = 3},
      \leftDrum,  { buf = ~kickBuf; mul = 4 },
      \rightDrum, { buf = ~snareBuf; mul = 3 },
      \start,     { buf = ~punkBuf; mul = 0.7 }
    );

		Synth(\player, [\buf, buf, \mul, mul]);
	};
};
)

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

		~hitAction.(hid.id, button, action);
	};
};

~drummy.action = ~inputActionFactory.(~drummy);

