// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ConcentricRadioWaves"
{
	Properties
	{
		_NumRings ("NumRings", Float) = 4
		_ClipCenterPct ("ClipCenterPct", Range(0,1)) = 0
		_HeightDegrees ("HeightDegrees", Range(0,90)) = 45
		_Speed ("Speed", Float) = 0.3
		_OverrideTime ("OverrideTime", Float) = 0 // set every frame if _UseTimeProperty is set TRUE

		// use simple gradient colors for now
		// could replace with texture for more control
		_ColorCenter ("Color Center", Color) = (1,1,1,1)
		_ColorEdge ("Color Edge", Color) = (1,1,1,1)

		// set TRUE to make this pausable. You will then need a component updating _OverrideTime every frame
		[Toggle(USE_TIME_PROPERTY)] _UseTimeProperty ("Use Time Property", Float) = 0 
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}
		
//		Stencil
//		{
////			Ref 1
////			Comp 
//			Ref 1 //[_Stencil]
//			Comp NotEqual //[_StencilComp]
//			Pass replace //[_StencilOp] 
////			Fail replace
////			ReadMask [_StencilReadMask]
////			WriteMask [_StencilWriteMask]
//		}

		Cull Off
		Lighting Off
		ZWrite Off
//		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
//		ColorMask 0//[_ColorMask]

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ USE_TIME_PROPERTY
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
//				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float heightTan : DEPTH; // store tan(_HeightDegrees) here to avoid per-pixel calc
			};

			half _NumRings;
			half _ClipCenterPct;
			sampler2D _MainTex;
			float4 _ColorCenter;
			float4 _ColorEdge;
			half _HeightDegrees;
			half _Speed;
			float _OverrideTime;


			static const float _HeightTan = tan(radians(_HeightDegrees));

            v2f vert (appdata_t v) {
                v2f o = (v2f)0;
                o.texcoord = v.texcoord;
                o.vertex = UnityObjectToClipPos(v.vertex );
//                o.color = _ColorCenter;
//                #ifdef PIXELSNAP_ON
//                    o.pos = UnityPixelSnap(o.pos);
//                #endif
                return o;
            }
           
			fixed4 frag(v2f IN) : SV_Target
			{
				half u = IN.texcoord.x * 2 - 1;
				half v = IN.texcoord.y * 2 - 1;

				float h = sqrt((u * u) + (v * v));

				// pct that wave has traveled 
				// from its (_ClipCenterPct) offset center to the edge
				float pctDistTravelled = saturate(h * 2.0 - 1); 

				#ifdef USE_TIME_PROPERTY
				float time = _OverrideTime;
				#else
				float time = _Time.y;
				#endif

				float hOff = frac(h - frac(time * _Speed));

				float len = _NumRings * 2.0;

				float ringDist = (hOff * len);
				float ringStep = floor(ringDist);
				float eraser = ceil(fmod(ringStep,2.0)) * len;

				float attenuation = lerp(0.0, 1.0, pctDistTravelled);
//				float w = lerp(0.0, 1.0, saturate((h + _ClipCenterPct) * _ClipCenterPct));
				attenuation = (attenuation*attenuation);

				half4 color = lerp(_ColorCenter, _ColorEdge, pctDistTravelled);

				color.a = 1.0 - (saturate(color.a + (ringStep - eraser)));

				color.a = saturate(color.a);// - angleClip);

				color.a *= (float)(abs(tan(atan2(v,u))) < _HeightTan); // angle clip
				color.a *= (float)(h > _ClipCenterPct); // center clip
				color.a *= (float)(h <= 1.0); // outer ring clip
				color.a *= ceil(frac(ringDist) - attenuation); // rings get thinner as they travel

				return color;
			}
		ENDCG
		}
	}
}
