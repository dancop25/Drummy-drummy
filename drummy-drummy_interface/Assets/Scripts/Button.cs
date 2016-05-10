
using UnityEngine;
using System.Collections;

public class Button : MonoBehaviour {

	public Sprite pushedSprite;
	public Sprite unpushedSprite;

	public int id;

	void OnMouseDown()
	{
		SetState (true);
		Debug.Log("pushed");
		Debug.Log (id);
	}

	void OnMouseUp()
	{
		SetState (false);
	}

	void SetState(bool state)
	{
		Sprite sprite;

		if (state) {
			sprite = pushedSprite;
		} else {
			sprite = unpushedSprite;
		}

		GetComponent<SpriteRenderer> ().sprite = sprite;
	}
}

