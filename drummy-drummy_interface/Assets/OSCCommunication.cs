using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;



public class OSCCommunication : MonoBehaviour {

	UnityOSC.OSCPacket prevPacket;

	public GameObject[] buttons;

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
				UnityOSC.OSCPacket latestPacket = packets [packets.Count - 1];

				if (prevPacket == null || latestPacket.TimeStamp != prevPacket.TimeStamp) {
					HandlePacket (latestPacket);	
				}
				prevPacket = latestPacket;
			}
		}
	}

	void HandlePacket (UnityOSC.OSCPacket packet) {
		List<object> data = packet.Data;
		GameObject[] buttons = GetButtons ();

		Int32 id = System.Convert.ToInt32 (data [0]);
		bool state = System.Convert.ToBoolean (data [1]);

		if (id >= 0 && id < buttons.Length){
			buttons [id].GetComponent<Button> ().SetState (state);	
		}

	}

	GameObject[] GetButtons () {
		if (buttons.Length == 0) {
			buttons = GameObject.FindGameObjectsWithTag ("Button");
			Array.Sort (buttons, delegate(GameObject a, GameObject b) {
				return a.GetComponent<Button> ().id.CompareTo (b.GetComponent<Button> ().id);
			});
		}

		return buttons;
	}
}
