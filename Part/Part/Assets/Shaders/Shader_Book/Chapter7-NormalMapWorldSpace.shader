// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader"Unity Shaders Book/Chapter 7/Normal Map In World Space"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white"{}
	//��������
	_BumpMap("Normal Map",2D) = "bump"{}
	//���ư�͹�̶�
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
			//���߷���
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
			//��������ռ��µĶ���λ��
			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			//��������ռ��µķ���
			fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
			//��������ռ��µ�����
			fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
			//��������ռ��µĸ�����
			fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
			//�洢���߿ռ䵽����ռ�ı任�����ÿһ��
			o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
			o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
			o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

			return o;
		}
		fixed4 frag(v2f i) :SV_Target
		{
			//��ȡ����ռ��µ�����
			float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
			//��������ռ��µĹ��շ���
			fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
			//��������ռ��µ��ӽǷ���
			fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
			//�������
			fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

			bump.xy *= _BumpScale;
			bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
			//�����ߴ����߿ռ�任������ռ���
			bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
			
			//����������*��ɫ��������Ϊ���ʷ�����
			fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
			//��������
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			//����������������ռ��м���
			fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump,lightDir));

			fixed3 halfDir = normalize(viewDir + lightDir);
			//�߹���
			fixed3 specular = _LightColor0.rgb * _Specular.rgb
				* pow(max(0, dot(bump, halfDir)), _Gloss);

			return fixed4(ambient + diffuse + specular, 1.0);
		}

		ENDCG

		}

	}
		Fallback"Specular"
}