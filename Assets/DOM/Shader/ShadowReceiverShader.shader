Shader "Shadow/ShadowMapReceiverShader"
{
    Properties
    {
		_MainTex ("Base (RGB)", 2D) = "white" {}
        _Color ("BaseColor", Color) = (1,1,1,1)
        _DepthBias("DepthBias", Range(0,1.0)) = 0.5
    }

	SubShader
	{
		Tags
		{
		 	"RenderType"="Opaque" 
	 	}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex object_vert
			#pragma fragment object_frag
		
			#include "UnityCG.cginc"

            uniform half4 _MainTex_TexelSize;
            sampler2D _MainTex;
            float4 _Color;
            float _DepthBias;

            sampler2D _LightDepthTex;
            sampler2D _OpacityMapTex;
            float4x4 _LightProjection;

			struct appdata
			{
				float4 vertex : POSITION;
				float4 worldPos: TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 worldPos: TEXCOORD0;
			};
			
			v2f object_vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				float4 worldPos = mul(UNITY_MATRIX_M, v.vertex);
				o.worldPos.xyz = worldPos.xyz;
				o.worldPos.w = 1;
				return o;
			}
			
			fixed4 object_frag (v2f i) : SV_Target
			{
				// convert to light camera space
				fixed4 lightClipPos = mul(_LightProjection , i.worldPos);
			    lightClipPos.xyz = lightClipPos.xyz / lightClipPos.w;
                float Z = Linear01Depth(lightClipPos.z);
				float2 lightUV = lightClipPos.xy * 0.5 + 0.5;
	
				//get depth
				fixed4 depthRGBA = tex2D(_LightDepthTex,lightUV);
                fixed4 depthRGBA2 = tex2D(_OpacityMapTex,lightUV);
				float depth = DecodeFloatRGBA(depthRGBA);
				if(Z + _DepthBias > depth)
				{
					return depthRGBA2;
				}
				else
				{
					return _Color;
				}
			}
			ENDCG
		}
	}

	FallBack "Diffuse"
}
