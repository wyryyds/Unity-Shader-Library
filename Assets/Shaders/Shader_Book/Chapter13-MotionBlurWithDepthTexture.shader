Shader"Unity Shaders Book/Chapter 13/MotionBlur With DepthTexture"
{
	Properties
	{
		_MainTex("Base (RGB)",2D)="white"{}
	    _BlurSize("Blur Size",Float)=1.0
	}

	SubShader
		{
			CGINCLUDE

            #include "UnityCG.cginc"
			sampler2D _MainTex;
		    half4 _MainTex_TexelSize;
			sampler2D _CameraDepthTexture;
			float4x4 _CurrentViewProjectionInverseMatrix;
			float4x4 _PreviousViewProjectionMatrix;
			half _BlurSize;

			struct v2f
			{
				float4 pos:SV_POSITION;
				half2 uv:TEXCOORD0;
				half2 uv_depth:TEXCOORD1;
			};

			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				o.uv_depth = v.texcoord;

#if UNITY_UV_STARTS_AT_TOP

				if (_MainTex_TexelSize.y < 0)
					o.uv_depth.y = 1 - o.uv_depth.y;

#endif
				return o;

			}

			fixed4 frag(v2f i) :SV_Target
			{
				//利用纹理坐标对深度纹理进行采样得到深度值。
				//深度值由NDC下的坐标映射而来
				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth);
			    //构建像素的NDC坐标
			    float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
				//利用投影矩阵的逆矩阵变换NDC坐标
				float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
				//得到世界空间下坐标
				float4 worldPos = D / D.w;

				float4 currentPos = H;
				float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
				//得到前一帧的世界空间坐标
				previousPos /= previousPos.w;
				//根据坐标差模拟速度
				float2 velocity = (currentPos.xy - previousPos.xy) / 2.0f;

				float2 uv = i.uv;
				float4 c = tex2D(_MainTex, uv);
				uv += velocity * _BlurSize;
				for (int it = 1;it < 3;it++, uv += velocity * _BlurSize)
				{
					float4 curColor = tex2D(_MainTex, uv);
					c += curColor;
				}
				c /= 3;

				return fixed4(c.rgb, 1.0);
			}
			ENDCG

			Pass
			{
				ZTest Always Cull Off ZWrite Off

				CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag

				ENDCG
			}
		}
		FallBack Off
}