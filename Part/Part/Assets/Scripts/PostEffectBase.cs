using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectsBase : MonoBehaviour
{
    /// <summary>
    /// �����Դ
    /// </summary>
    protected void CheckResources()
    {
        bool isSupported = CheckSupport();
        if (isSupported == false)
            NotSupported();
    }
    /// <summary>
    /// ƽ̨�Ƿ�֧����Ӧ����Ⱦ����
    /// </summary>
    /// <returns></returns>
    protected bool CheckSupport()
    {
        if(SystemInfo.supportsGraphicsFence == false|| SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.Default)==false)
        {
            return false;
        }
        return true;
    }
    protected void NotSupported()
    {
        enabled = false;
    }

    protected void Start()
    {
        CheckResources();
    }
    /// <summary>
    /// ���shader���Ҵ�������
    /// </summary>
    /// <param name="shader">ʹ�õ�shader</param>
    /// <param name="material">���ں���Ĳ���</param>
    /// <returns></returns>
    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null) return null;

        if (shader.isSupported && material && material.shader == shader) return material;

        if (!shader.isSupported) return null;
        else
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            if (material) return material;

            return null;
        }
    }
}
