using UnityEngine;
using System.Collections;
using System.Net;
using System.Collections.Generic;

public class OSCCommunication : MonoBehaviour {



	// Use this for initialization
	void Start () {
	
		OSCHandler.Instance.CreateClient("SuperCollider", IPAddress.Parse("192.168.18.240"), 5555);

		OSCHandler.Instance.CreateServer("SuperCollider", 6666);

		Debug.Log ("OSC Ready");
	}
	
	// Update is called once per frame
	void Update () {

		OSCHandler.Instance.UpdateLogs ();

		if (OSCHandler.Instance.Servers.ContainsKey ("SuperCollider")) {
			List<UnityOSC.OSCPacket> packets = OSCHandler.Instance.Servers ["SuperCollider"].packets;

			if (packets.Count > 0) {
				HandlePacket (packets [packets.Count - 1]);
	
			}
		}
	}

	void HandlePacket (UnityOSC.OSCPacket packet) {
		List<object> data = packet.Data;
		Debug.Log (packet.Address);
		Debug.Log (data);
	}

}
