using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffectsBase
{
    public Shader gussianBlurShader;
    private Material gaussianBlurMaterial=null;
    public Material Material
    {
        get
        {
            gaussianBlurMaterial = CheckShaderAndCreateMaterial(gussianBlurShader, gaussianBlurMaterial);
            return gaussianBlurMaterial;
        }
    }
    //��˹ģ����������
    [Range(0, 4)]
    public int iterations=3;
    //ģ����Χ
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    //����ϵ��
    [Range(1, 8)]
    public int downSample = 2;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(Material!=null)
        {
            //��ͼ�����Ž�����
            int rtw = source.width / downSample;
            int rth = source.height / downSample;
            //������֮�����һ��С��ԭ��Ļ�ֱ��ʳߴ�Ļ�����
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtw, rth, 0);
            //������Ⱦ������˲�ģʽΪ˫����
            buffer0.filterMode = FilterMode.Bilinear;
            //�洢���ź��ͼ������
            Graphics.Blit(source, buffer0);

            for(int i = 0; i < iterations; i++)
            {
                Material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtw, rth, 0);

                //ִ�е�һ��Pass����buffer0Ϊ���룬buffer1Ϊ���
                //��һ��Pass��ʹ����ֱ�����һά��˹�˽����˲�
                Graphics.Blit(buffer0, buffer1, Material, 0);

                //����GetTemporary�����ڴ�֮��������
                RenderTexture.ReleaseTemporary(buffer0);

                //�����buffer1�洢��buffer0��
                buffer0 = buffer1;

                //���·���buffer1
                buffer1 = RenderTexture.GetTemporary(rtw, rth, 0);

                //ִ�еڶ���Pass���Ե�һ��Pass�������Ϊ���롣
                //ʹ��ˮƽ�����һά��˹�˽����˲�
                Graphics.Blit(buffer0, buffer1, Material, 1);
                //����
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            Graphics.Blit(buffer0, destination);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

}
