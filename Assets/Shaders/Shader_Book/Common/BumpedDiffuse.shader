Shader"Unity Shaders Book/Common/BumpedDiffuse"
{
	Properties
	{
		//颜色
		_Color("Color Tint",Color)=(1,1,1,1)
		//贴图
		_MainTex("Main Tex",2D)="white"{}
	    //法线纹理
	    _BumpMap("Bump Map",2D)="white"{}
		//控制凹凸程度
	    _BumpScale("Bump Scale",float) = 1.0
	}

		Subshader
	{
		//RenderType与Queue的解释：https://blog.csdn.net/u013477973/article/details/80607989
		Tags{"RenderType" = "Opaque" "Queue" = "Geometry"}

		Pass
		{
			//ForwardBase：用于正向渲染中，该Pass会计算环境光、最重要的平行光、逐顶点/SH光源和Lightmaps光照贴图
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include"Lighting.cginc"
			#include"AutoLight.cginc"

			fixed4 _Color;
	        sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				//顶点切线方向
				//tangent.w分量来决定切线空间中的副切线的方向性
				float4 tangent:TANGENT;
				//纹理坐标
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				//存储纹理坐标
				float4 uv:TEXCOORD0;
				float4 TtoW0:TEXCOORD1;
				float4 TtoW1:TEXCOORD2;
				float4 TtoW2:TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				//xy存储了_MainTex的纹理坐标
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				//zw存储了_BumpMap的纹理坐标
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				//计算世界空间下坐标
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				//计算世界空间下法线
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				//计算世界空间下的切线
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				//计算世界空间下的副切线
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
				//存储切线空间到世界空间的变换矩阵的每一行
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				//获取世界空间下坐标
				float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
				//计算平行光方向与视角方向
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				//采样法线纹理获得切线空间的法线
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
				//从将法线从切线空间变换到世界空间下
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				//纹理采样结果*颜色属性来作为材质反射率
				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				//计算环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
				//计算漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
				//计算光照衰减与阴影
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4(ambient + diffuse * atten, 1.0);
			}
			ENDCG
        }
	    //与BasePass的计算基本一致,去除环境光，自发光，逐顶点光照与SH光照部分的计算。
		Pass
		{
			Tags{"LightMode" = "ForwardAdd"}

			Blend One One

			CGPROGRAM

			#pragma multi_compile_fwdadd
			#pragma vertex vert
			#pragma fragment frag

			#include"Lighting.cginc"
			#include"AutoLight.cginc"

			fixed4 _Color;
		    sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));

				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4(diffuse * atten, 1.0);
			}
			ENDCG
        }
	}
	FallBack"Diffuse"
}