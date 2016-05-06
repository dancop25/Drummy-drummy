// get input from touchOSC beatmachine buttons
(
~createOscAction = {|id|
  {|msg, time, addr, recvPort|
    var state = msg[1];
    [id, state].postln;
  }
};


9.do {|i|
  var id = i + 1;
  var name = "button%".format(id).asSymbol;
  var path = "/1/push%".format(id).asSymbol;
  OSCdef(name, ~createOscAction.(id), path, nil, 6666);
};
)

