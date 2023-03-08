Shader"Unity Shaders Book/Common/BumpedDiffuse"
{
	Properties
	{
		//��ɫ
		_Color("Color Tint",Color)=(1,1,1,1)
		//��ͼ
		_MainTex("Main Tex",2D)="white"{}
	    //��������
	    _BumpMap("Bump Map",2D)="white"{}
		//���ư�͹�̶�
	    _BumpScale("Bump Scale",float) = 1.0
	}

		Subshader
	{
		//RenderType��Queue�Ľ��ͣ�https://blog.csdn.net/u013477973/article/details/80607989
		Tags{"RenderType" = "Opaque" "Queue" = "Geometry"}

		Pass
		{
			//ForwardBase������������Ⱦ�У���Pass����㻷���⡢����Ҫ��ƽ�й⡢�𶥵�/SH��Դ��Lightmaps������ͼ
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
				//�������߷���
				//tangent.w�������������߿ռ��еĸ����ߵķ�����
				float4 tangent:TANGENT;
				//��������
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				//�洢��������
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
				//xy�洢��_MainTex����������
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				//zw�洢��_BumpMap����������
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				//��������ռ�������
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				//��������ռ��·���
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				//��������ռ��µ�����
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				//��������ռ��µĸ�����
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
				//�洢���߿ռ䵽����ռ�ı任�����ÿһ��
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				//��ȡ����ռ�������
				float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
				//����ƽ�йⷽ�����ӽǷ���
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				//�����������������߿ռ�ķ���
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
				//�ӽ����ߴ����߿ռ�任������ռ���
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				//����������*��ɫ��������Ϊ���ʷ�����
				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				//���㻷����
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
				//����������
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
				//�������˥������Ӱ
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4(ambient + diffuse * atten, 1.0);
			}
			ENDCG
        }
	    //��BasePass�ļ������һ��,ȥ�������⣬�Է��⣬�𶥵������SH���ղ��ֵļ��㡣
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