Shader "DOM/DOMOpacityMapShader"
{
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		Pass
		{
            Cull Off
            ZWrite Off
            Blend One One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

            sampler2D _LightDepthTex;
            float4 _LightZBufferParams;

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};
		
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
            float LightLinear01Depth(float z)
            {
                return 1.0 / (_LightZBufferParams.x * z + _LightZBufferParams.y);
            }
			
			fixed4 frag (v2f i) : SV_Target
			{
                float opacityValue = 0.01;
                float4 lightClipPos = i.vertex;
                lightClipPos.xyz = lightClipPos.xyz / lightClipPos.w;
                float Z = Linear01Depth(lightClipPos.z);
                float2 lightUV = lightClipPos.xy * 0.5 + 0.5;

                fixed4 depthRGBA = tex2D(_LightDepthTex,lightUV);
				float near = 0.94;//DecodeFloatRGBA(depthRGBA);
                float base = 0.01;//(1.0 - near) / 4;

                float4 layerDistance = float4(0.0,0.0,0.0,0.0);
                layerDistance.x = near + base;
                layerDistance.y = layerDistance.x + base;
                layerDistance.z = layerDistance.y + base;
                layerDistance.w = layerDistance.z + base;

                float4 opacityMap = float4(0.0,0.0,0.0,0.0);
                if(Z < layerDistance.x) opacityMap.x = opacityValue;
                 if(Z < layerDistance.y) opacityMap.y = opacityValue;
                 if(Z < layerDistance.z) opacityMap.z = opacityValue;
                 if(Z < layerDistance.w) opacityMap.w = opacityValue;

                return (fixed4)opacityMap;
			}
			ENDCG
		}
	}
}