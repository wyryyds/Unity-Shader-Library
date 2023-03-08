Shader"Unity Shaders Book/Chapter 7/Normal Map In Tangent Space"
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
			Tags { "LightMode"="ForwardBase" }

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
			float3 lightDir:TEXCOORD1;
			float3 viewDir:TEXCOORD2;
		};


		v2f vert(a2v v)
		{
			v2f o;

			o.pos = UnityObjectToClipPos(v.vertex);

			o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

			o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
			//内置宏，把切线方向，副切线方向和法线方向按行排列来得到从模型空间转换到切线空间
			//的变换矩阵rotation
			TANGENT_SPACE_ROTATION;
			//将光源从模型空间转换到切线空间
			o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
			//将视线从模型空间转换到切线空间
			o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

			return o;
		}
        fixed4 frag(v2f i) :SV_Target
		{
			//归一化
			fixed3 tangentLightDir = normalize(i.lightDir);
		    fixed3 tangentViewDir = normalize(i.viewDir);
			//纹理采样
			fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
			//法线纹理设置为Normalmap时可以直接使用内置函数反映射
			//如果没有设置为Normalmap，需要手动计算
			fixed3 tangentNormal;
			//tangentNormal.xy=(packedNormal.xy*2-1)*_BumpScale;
			//tangentNormal.z=sqrt(1.0-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
			tangentNormal=UnpackNormal(packedNormal);
			tangentNormal.xy *= _BumpScale;
			tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
			//纹理采样结果*颜色属性来作为材质反射率
			fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
			//环境光结果
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			//漫反射结果，在切线空间中计算
			fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

			fixed3 halfDir = normalize(tangentNormal + tangentLightDir);
			//高光结果
			fixed3 specular = _LightColor0.rgb * _Specular.rgb
				* pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

			return fixed4(ambient + diffuse + specular, 1.0);
		}
		
		ENDCG

		}

	}
		Fallback"Specular"
}