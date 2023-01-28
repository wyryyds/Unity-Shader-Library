// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shaders Book/Chapter 7/Single Texture"
{
	Properties
	{
		_Color("Color Tint",Color)=(1,1,1,1)
		_MainTex("Main Tex",2D)="white"{}
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}

		SubShader
		{
			Pass
			{
				Tags{"LightMode" = "ForwardBase"}

				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag

				#include "Lighting.cginc"

				fixed4 _Color;
		        sampler2D _MainTex;
				//�õ����������ƽ��ֵ,.xz�������ֵ��.zw�洢ƫ��ֵ
				float4 _MainTex_ST;
				fixed4 _Specular;
				float _Gloss;

				struct a2v
				{
					float4 vertex:POSITION;
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
					//�����������ģ�Ϳռ�ת�����ü��ռ�
					o.pos = UnityObjectToClipPos(v.vertex);
					//�������ģ�Ϳռ�ת������ռ�
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					//�����������ģ�Ϳռ�ת��������ռ�
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xzy;
					//��������任���ȼ������ţ��ڼ���ƫ��
					o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					return o;
				}

				fixed4 frag(v2f i) :SV_Target
				{
					//�����һ
					fixed3 worldNormal = normalize(i.worldNormal);
				    //����API��ȡ��Դ����
				    fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					//����������������ɫ��������Ϊ���ʵķ�����
					fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
					//������������Ҫ���Ϸ�����
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xzy * albedo;
					//��������,�������Բ��ʷ�������Ϊϵ��
					fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
					//����API��ȡ���߷���
					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
					//BlinnPhongģ��
					fixed3 halfDir = normalize(worldLightDir + viewDir);
					//�߹���
					fixed3 specular = _LightColor0.rgb * _Specular.rgb *
						pow(max(0, dot(worldNormal, halfDir)), _Gloss);

					return fixed4(ambient + diffuse + specular, 1.0);
				}
					ENDCG
            }
			
		}
			Fallback"Specular"
}