<#assign transformers=payloadElement.configuration["message-transformers"].*/>
<#assign folder="transformations"/>
Transformations strored in ${folder} folder in these files:

<#assign num = 1>
<#--  loop for all transformation  -->
<#list transformers as transformer>
    <#assign classname=transformer.classname/>
    <#--  decode base64  -->
    <#assign content=tools.b64Decode(transformer.content)/>
    <#assign filename=folder + "/" + transformer.name?replace("/","_")?replace("\\","_") + extensions.map[classname]/>
    <#--  save to file  -->
    <#assign res=tools.saveFile(filename,content)/>
${num} - ${transformer.name}
    ${filename}
    Attributes:
    <#list transformer["template-attributes"].* as attr>
${attr.name}=${attr.value}
    </#list>
    <#assign num+=1/>
----------------------------------------------
    
</#list>