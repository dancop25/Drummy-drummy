using UnityEngine;
using System.Collections;

public class NotePosition : MonoBehaviour {

	public float notePosition = 0;
	float height;
	float width;
		
	// Use this for initialization
	void Start () {

		height = Camera.main.orthographicSize * 2f;
		width = height / (float)Screen.height * (float)Screen.width;

		//transform.position = new Vector3 (width * notePosition, 0, 1);
		print (transform.position);

//		transform.position = new Vector3 (0f, 0f, 0f);

		//note.transform.position = notePosition * width;

		SetPos (0);
	}

	void SetPos(float pos) {
		transform.position = new Vector3 (pos, 0, 10);
	}
}
