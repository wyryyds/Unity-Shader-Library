// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader"Unity Shaders Book/Chapter 8/Alpha Blend ZWrite"
{
	Properties
	{
		_Color("Main Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white"{}
	//用于控制整体的透明度
	_AlphaScale("Alpha Scale",Range(0,1)) = 1
	}

		SubShader
	{
		//指定渲染队列，指明该shader是一个使用了透明度混合的shader
		Tags{"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

		Pass
		{
			ZWrite On
	        //不输出任何颜色
	        ColorMask 0
        }

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			ZWrite Off
		//将源颜色的混合因子设置为SrcAlpha,将目标颜色的混合因子设置为OneMinusSrcAlpha
		Blend SrcAlpha OneMinusSrcAlpha

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include"Lighting.cginc"

	fixed4 _Color;
	sampler2D _MainTex;
	float4 _MainTex_ST;
	fixed _AlphaScale;

	struct a2v
	{
		float4 vertex : POSITION;
		float3 normal:NORMAL;
		float4 texcoord:TEXCOORD0;
	};

	struct v2f
	{
		float4 pos:SV_POSITION;
		float3 worldNormal:TEXCOORD0;
		float3 worldPos:TEXCOORD1;
		float2 uv:TEXCOORD2;
	};

	v2f vert(a2v v)
	{
		v2f o;

		o.pos = UnityObjectToClipPos(v.vertex);
		o.worldNormal = UnityObjectToWorldNormal(v.normal);
		o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

		return o;
	}

	fixed4 frag(v2f i) :SV_Target
	{
		fixed3 worldNormal = normalize(i.worldNormal);
		fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
		fixed4 texColor = tex2D(_MainTex, i.uv);

		fixed3 albedo = texColor.rgb * _Color.rgb;
		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
		fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
		//设置返回值中的透明通道
		return fixed4(ambient + diffuse,texColor.a * _AlphaScale);
	}

		ENDCG
	}
	}
		Fallback"Diffuse"

}