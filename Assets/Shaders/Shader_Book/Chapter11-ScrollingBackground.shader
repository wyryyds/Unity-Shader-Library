Shader"Unity Shaders Book/Chapter 11/Scrolling Background"
{
	Properties
	{
		//第一层背景纹理，由远到近依次为第一层，第二层....
		_MainTex("Base Layer (RGB)",2D) = "white"{}
	    //第二层背景纹理
	    _DetailTex("2nd Layer (RGB)",2D) = "white"{}
	    //第一层滚动速度
	    _ScrollX("Base layer Scroll Speed",Float) = 1.0
		//第二层滚动速度
		_Scroll2X("2nd Layer Scroll Speed",Float) = 1.0
		//控制纹理整体亮度
		_Multiplier("Layer Multiplier",Float) = 1
	}

	SubShader
	{
		Tags{"RenderType" = "Opaque" "Queue" = "Geometry"}

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _DetailTex_ST;
			sampler2D _DetailTex;
			float _ScrollX;
			float _Scroll2X;
			float _Multiplier;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD;
			};
			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//得到纹理坐标并且进行偏移
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + frac(float2 (_Scroll2X, 0.0) * _Time.y);
				return o;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				//纹理采样
				fixed4 firstLayer = tex2D(_MainTex,i.uv.xy);
			    fixed4 secondLayer = tex2D(_DetailTex, i.uv.zw);
				//使用第二层纹理的透明通道来混合两张纹理
				fixed4 c = lerp(firstLayer, secondLayer, secondLayer.a);
				c.rgb *= _Multiplier;
				return c;
			}
				ENDCG
		}
	}
			FallBack"VertexLit"
}