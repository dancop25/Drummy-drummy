// get input from touchOSC beatmachine buttons

(
~ip = "169.254.178.43";
~recvNetAddr = NetAddr(~ip, nil);
~sendNetAddr = NetAddr(~ip, 7777);
);

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
  OSCdef(name, ~createOscAction.(id), path, ~recvNetAddr, 6666);
};
);

~buttonSet = {|id, val| ~sendNetAddr.sendMsg(id, val); };
~buttonOn = {|id| ~buttonSet.(id, 1); };
~buttonOff = {|id| ~buttonSet.(id, 0); };

~touchOSCButtonOn = {|id| ~buttonOn.("/1/push%".format(id)); };
~touchOSCButtonOff = {|id| ~buttonOff.("/1/push%".format(id)); };

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