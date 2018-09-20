// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UI/Ext/ConcentricRadioWaves"
{
	Properties
	{
		_NumRings ("NumRings", Float) = 4
		_ClipCenterPct ("ClipCenterPct", Range(0,1)) = 0
		_HeightDegrees ("HeightDegrees", Range(0,90)) = 45
		_Speed ("Speed", Float) = 0.3
		_OverrideTime ("OverrideTime", Float) = 0  // set every frame if _UseTimeProperty is set TRUE

		// use simple gradient colors for now
		// could replace with texture for more control
		_ColorCenter ("Color Center", Color) = (1,1,1,1)
		_ColorEdge ("Color Edge", Color) = (1,1,1,1)

		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15


//		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0 

		// set TRUE to make this pausable. You will then need a component updating _OverrideTime every frame
//		[Toggle(USE_TIME_PROPERTY)] _UseTimeProperty ("Use Time Property", Float) = 0 
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
		
		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp] 
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

//			#pragma multi_compile __ UNITY_UI_ALPHACLIP
//			#pragma multi_compile __ USE_TIME_PROPERTY
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
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

				o.worldPosition = v.vertex;
				o.vertex = UnityObjectToClipPos(o.worldPosition);

				#ifdef UNITY_HALF_TEXEL_OFFSET
				o.vertex.xy += (_ScreenParams.zw-1.0)*float2(-1,1);
				#endif

				o.color = v.color;

                #ifdef PIXELSNAP_ON
                    o.pos = UnityPixelSnap(o.pos);
                #endif

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

//				#ifdef USE_TIME_PROPERTY
//				float time = _OverrideTime;
//				#else
//				float time = _Time.y;
//				#endif

				float time = _OverrideTime > 0? _OverrideTime: _Time.y;

				float hOff = frac(h - frac(time * _Speed));

				float radius = _NumRings * 2.0;

				float ringDist = (hOff * radius);
				float ringStep = floor(ringDist);
				float eraser = ceil(fmod(ringStep,2.0)) * radius;

				float attenuation = lerp(0.0, 1.0, pctDistTravelled);
				attenuation = (attenuation*attenuation);

				half4 color = lerp(_ColorCenter, _ColorEdge, pctDistTravelled);

				color.a = 1.0 - (saturate(color.a + (ringStep - eraser)));
				color.a *= IN.color.a;

				color.a = saturate(color.a);// - angleClip);

				color.a *= (float)(abs(tan(atan2(v,u))) < _HeightTan); // angle clip
				color.a *= (float)(h > _ClipCenterPct); // center clip
				color.a *= (float)(h <= 1.0); // outer ring clip
				color.a *= ceil(frac(ringDist) - attenuation); // rings get thinner as they travel

				clip(color.a - 0.001);

				return color;
			}
		ENDCG
		}
	}
}
