using BeatThat.Properties;
using UnityEngine;

namespace BeatThat
{
    /// <summary>
    /// ConcentricRadioWaves is just a kind of loading animation (draws concentric radio waves eminating outwards)
    /// The rendering is all handled by the ConcentricRadioWaves shader/material, 
    /// but if you want the effect to be Pausable, attach this component
    /// </summary>
    [ExecuteInEditMode]
    public class ConcentricRadioWaves : MonoBehaviour
    {
        public bool m_pause;
        public HasMaterial m_hasMaterial;

        public void OnPause(bool p)
        {
            this.isPaused = p;
        }

        // Analysis disable ConvertToAutoProperty
        public bool isPaused { get { return m_pause; } set { m_pause = value; } }
        // Analysis restore ConvertToAutoProperty

        private HasMaterial hasMaterial { get { return (m_hasMaterial = HasMaterial.FindOrAdd(this.gameObject)); } }

#if UNITY_EDITOR
        void OnEnable()
        {
            if(!Application.isPlaying) {
                UnityEditor.EditorApplication.update += this.Update;
            }
        }

        void OnDisable()
        {
            if (!Application.isPlaying)
            {
                UnityEditor.EditorApplication.update -= this.Update;
            }
        }
#endif
        void Start()
        {
            if (this.material == null)
            {
                this.material = Application.isPlaying ? Instantiate(this.hasMaterial.material) : this.hasMaterial.material;
                this.hasMaterial.material = this.material;
            }
        }

        private float time { get; set; }

        void Update()
        {
            if (this.isPaused) { return; }

#if UNITY_EDITOR
            if(Application.isPlaying) {
                this.time += Time.deltaTime;
            }
            else {
                Debug.Log("[" + System.DateTime.Now);
                if(m_lastTime.HasValue) {
                    this.time += (float)(System.DateTime.Now - m_lastTime.Value).TotalSeconds;
                }
                m_lastTime = System.DateTime.Now;
            }
#else
            this.time += Time.deltaTime;
#endif

			this.material.SetFloat("_OverrideTime", this.time);
		}

#if UNITY_EDITOR
        private System.DateTime? m_lastTime;
#endif

        private Material material { get; set; }
	}
}

