Shader "DOM/DOMDepthShader"
{
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

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
			
			float4 frag (v2f i) : SV_Target
			{
                float Z = i.vertex.z / i.vertex.w;
				return EncodeFloatRGBA(Linear01Depth(Z));
			}
			ENDCG
		}
	}
}