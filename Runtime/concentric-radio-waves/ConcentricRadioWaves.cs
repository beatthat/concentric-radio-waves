using BeatThat.Properties;
using UnityEngine;

namespace BeatThat
{
    /// <summary>
    /// ConcentricRadioWaves is just a kind of loading animation (draws concentric radio waves eminating outwards)
    /// The rendering is all handled by the ConcentricRadioWaves shader/material, 
    /// but if you want the effect to be Pausable, attach this component
    /// </summary>
    public class ConcentricRadioWaves : MonoBehaviour
	{
		public bool m_pause;
		public HasMaterial m_hasMaterial;

		public void OnPause (bool p)
		{
			this.isPaused = p;
		}

		// Analysis disable ConvertToAutoProperty
		public bool isPaused { get { return m_pause; } set { m_pause = value; } }
		// Analysis restore ConvertToAutoProperty

		private HasMaterial hasMaterial { get { return (m_hasMaterial = HasMaterial.FindOrAdd(this.gameObject)); } }

		void Start()
		{
			if(this.material == null) {
				this.material = Instantiate(this.hasMaterial.material);
				this.hasMaterial.material = this.material;
			}
		}

		private float time { get; set; }

		void Update()
		{
			if(this.isPaused) { return; }

			this.time += Time.deltaTime;

			this.material.SetFloat("_OverrideTime", this.time);
		}
			
		private Material material { get; set; }
	}
}

