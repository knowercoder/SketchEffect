using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SketchEffect.Utils
{
	//Rotates the camera Root
	public class AutoRotate : MonoBehaviour
	{
		public Vector3 BaseRotation;
		public Vector3 RotationSpeed;

		// Update is called once per frame
		void Update()
		{
			transform.rotation = Quaternion.Euler(BaseRotation + RotationSpeed * Time.fixedTime);
		}
	}
}