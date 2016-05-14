// get input from touchOSC beatmachine buttons
s.boot;
s.options.inDevice = "Built-in Input";
s.options.outDevice = "Built-in Output";
~projectDir = "~/Development/music-game/Drummy-drummy/audio-engine/".standardizePath;

// audio buffer
~buf = Buffer.read(s, ~projectDir +/+ "1bar-metro.wav");

~hitData = (
  'numFrames': ~buf.numFrames,
  'sampleRate': ~buf.sampleRate,
  'hits': [
    (time: 0.0, input: 10, action: 'single'),
    (time: 1.0, input: 10, action: 'single'),
    (time: 2.0, input: 20, action: 'single'),
    (time: 3.0, input: 30, action: 'on'),
    (time: 3.5, input: 30, action: 'off'),
  ]
);

~hitsToSamples = {|hitData|
  var blockSize = 512;
  var output = FloatArray.newClear(hitData['numFrames']);

  hitData.hits.do {|hit|
    var value = if (['single', 'on'].includes(hit['action'])) {
      hit['input'];
    } {
      hit['input'].neg
    };

    var start = (hit['time'] * hitData['sampleRate']).asInteger;
    var end = start + (blockSize - 1);

    output[start..end] = value;

    // add an off hit automatically if this was a single shot
    if(hit['action'] === 'single') {
      var offStart = end + 1;
      var offEnd = offStart + (blockSize - 1);
      output[offStart..offEnd] = value.neg;
    };
  };
  // convert to sample values, 2**15 instead of 2**16 as if we want to store
  // id 10, we will store 10 instead of 5 (which we would get with 2**16)
  output = output / (2 ** 15);

  output;
};

~combineAudioAndHits = {|buf, hitData, outputPath|
  buf.loadToFloatArray(action: {|audioArr|
    var hitsArr = ~hitsToSamples.(hitData);
    var numChannels = (buf.numChannels + 1);
    var combined = (audioArr.size + hitsArr.size).collect {|i|
      var mod = i % numChannels;
      var ind = floor(i / numChannels);
      // data channel
      if(mod == (numChannels - 1)) {
        hitsArr[ind];
      } {
        // audio channel(s)
        audioArr[(ind * buf.numChannels) + mod];
      }
    };

    var combinedBuf = Buffer.loadCollection(s, combined, numChannels, {|buf|
      buf.write(outputPath, "wav", "int16", completionMessage:{
        "written to %".format(outputPath).postln;
      });
    });
  });
};

~combineAudioAndHits.(~buf, ~hitData, ~projectDir +/+ "new-combo.wav");
