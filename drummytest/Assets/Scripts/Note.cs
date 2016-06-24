using UnityEngine;
using System.Collections;

public class Note : MonoBehaviour {

	public int time;
	private NoteType type;
	public NoteType Type {
		get { return type; }
		set
		{
			type = value;
			string path;

			switch (type)
			{
				case NoteType.Blue:
					path = "Materials/CubeMaterialBlue";
					break;

				case NoteType.Yellow:
				path = "Materials/CubeMaterialYellow";
					break;

				default:
				path = "Materials/CubeMaterialDefault";
					break;
			}

			Material mat = Resources.Load ("Materials/CubeMaterialBlue", typeof(Material)) as Material;

			prefab.GetComponent<Renderer>().material = mat;
		}
	}

	private GameObject prefab;


	// Use this for initialization
	void Start () {
		prefab = Resources.Load ("Prefabs/CubeNote", typeof(GameObject)) as GameObject;
		Instantiate (prefab, new Vector3 (0, 0, 0), Quaternion.identity);
	}


	// Update is called once per frame
	void Update () {
	
	}
}
