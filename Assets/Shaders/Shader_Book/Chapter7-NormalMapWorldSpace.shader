// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader"Unity Shaders Book/Chapter 7/Normal Map In World Space"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white"{}
	//法线纹理
	_BumpMap("Normal Map",2D) = "bump"{}
	//控制凹凸程度
	_BumpScale("Bump Scale",float) = 1.0
	_Specular("Specular",Color) = (1,1,1,1)
	_Gloss("Gloss",Range(8.0,256)) = 20
	}

		SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

		struct a2v
		{
			float4 vertex:POSITION;
			float3 normal:NORMAL;
			//切线方向
			float4 tangent:TANGENT;
			float4 texcoord:TEXCOORD0;
		};
		struct v2f
		{
			float4 pos:SV_POSITION;
			float4 uv:TEXCOORD0;
			float4 TtoW0:TEXCOORD1;
			float4 TtoW1:TEXCOORD2;
			float4 TtoW2:TEXCOORD3;
		};


		v2f vert(a2v v)
		{
			v2f o;

			o.pos = UnityObjectToClipPos(v.vertex);

			o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

			o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
			//计算世界空间下的顶点位置
			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			//计算世界空间下的法线
			fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
			//计算世界空间下的切线
			fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
			//计算世界空间下的副切线
			fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
			//存储切线空间到世界空间的变换矩阵的每一行
			o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
			o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
			o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

			return o;
		}
		fixed4 frag(v2f i) :SV_Target
		{
			//获取世界空间下的坐标
			float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
			//计算世界空间下的光照方向
			fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
			//计算世界空间下的视角方向
			fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
			//纹理采样
			fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

			bump.xy *= _BumpScale;
			bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
			//将法线从切线空间变换到世界空间下
			bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
			
			//纹理采样结果*颜色属性来作为材质反射率
			fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
			//环境光结果
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			//漫反射结果，在世界空间中计算
			fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump,lightDir));

			fixed3 halfDir = normalize(viewDir + lightDir);
			//高光结果
			fixed3 specular = _LightColor0.rgb * _Specular.rgb
				* pow(max(0, dot(bump, halfDir)), _Gloss);

			return fixed4(ambient + diffuse + specular, 1.0);
		}

		ENDCG

		}

	}
		Fallback"Specular"
}