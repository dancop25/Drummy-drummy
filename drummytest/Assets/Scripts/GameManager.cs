using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class GameManager : MonoBehaviour {

	public List<GameObject> notes = new List<GameObject>() ;

	public GameObject prefab;



	// Use this for initialization
	void Start () {
	
		GameObject myNote = new GameObject ();
		Note n = myNote.AddComponent<Note> ();

		n.Type = NoteType.Blue;
		notes.Add (myNote);
		Debug.Log (notes.Count);

	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
