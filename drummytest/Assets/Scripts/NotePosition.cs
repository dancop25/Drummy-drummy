using UnityEngine;
using System.Collections;

public class NotePosition : MonoBehaviour {

	public float pos = 0.5f;
	public float speed = 100f;

	private Vector3 target;

	void Start () {
		target = transform.position;
	}

	void Update () {
		target = Camera.main.ScreenToWorldPoint (new Vector3(pos * Screen.width, 0.5f * Screen.height, 0f));
		target.z = transform.position.z;
		transform.position = Vector3.MoveTowards (transform.position, target, speed * Time.deltaTime);
	}
}
