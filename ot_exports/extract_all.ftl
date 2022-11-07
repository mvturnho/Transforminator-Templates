<#assign tunnels=payloadElement.configuration.tunnels.*/>
<#assign transformers=payloadElement.configuration["message-transformers"].*/>
<#assign mappings=payloadElement.configuration.mappings.*/>
<#assign mappings_folder="mappings"/>
<#assign transformation_folder="transformations"/>
<#assign tunnelvar_folder="tunnelvars"/>

<#--  itterate all tunnels  -->
Tunnel runtimevariables strored in ${tunnelvar_folder} folder in these files:

<#list tunnels as tunnel>
    <#assign vars=""/>
    <#assign numvars=0/>
    <#assign rtv=tunnel["runtime-variables"].*/>
    <#--  all runtime variables in the tunnel  -->
    <#list rtv as attr>
        <#if (attr.value != "AQ==")>
            <#if (attr.value?starts_with("//"))>
                <#assign vars+= attr.name + "=xpath://" + attr.value/>      
            <#else>
                <#assign vars+= attr.name + "=" + attr.value/>
            </#if>
            <#assign vars+= "\n"/>
            <#assign numvars+=1/>
        </#if>
    </#list>
    <#--  if we have found runtimevars write them to a file for the specific tunnel  -->
    <#if (vars?has_content)>
        <#assign filename= tunnelvar_folder + "/" + tunnel.common.name + ".tunnelvars"/>
        <#assign res=tools.saveFile(filename,vars)/>
# Tunnel ${tunnel.common.name}
${numvars} runtime variables found; saved to:
${filename}
    <#else/>
#Tunnel ${tunnel.common.name}
    NO runtime variables
    </#if>
</#list>
______________________________________________________________
<#--  Transformations  -->
Transformations strored in ${transformation_folder} folder in these files:

<#assign num = 1>
<#--  loop for all transformation  -->
<#list transformers as transformer>
    <#assign classname=transformer.classname/>
    <#--  decode base64  -->
    <#assign content=tools.b64Decode(transformer.content)/>
    <#assign filename=transformation_folder + "/" + transformer.name?replace("/","_")?replace("\\","_") + extensions.map[classname]/>
    <#--  save to file  -->
    <#assign res=tools.saveFile(filename,content)/>
${num} - ${transformer.name}
${filename}
<#if (transformer["template-attributes"]?has_content)>
    
Transformation Attributes:
    <#list transformer["template-attributes"].* as attr>
${attr.name}=${attr.value}
    </#list>
    <#assign num+=1/>
<#else/>

NO Transformation Attrinutes
</#if>
----------------------------------------------
    
</#list>
______________________________________________________________
<#--  Mappings  -->
<#if (mappings?has_content)>
Transformations strored in ${mappings_folder} folder in these files:

    <#--  go throug all mappings in the export xml  -->
    <#list mappings as mapping>
        <#assign map='"Source value","Target value"\n'/>
        <#--  all key/val pairs in the mapping  -->
        <#list mapping.values.* as val>
            <#assign kv_item = '"'+val["source-key"]+'"' + ',' + '"'+val["target-key"]+'"' + '\n'/>
            <#assign map+=kv_item/>
        </#list>
        <#--  write to file  -->
        <#assign filename=mappings_folder + "/" + mapping.name + ".csv"/>
        <#assign res=tools.saveFile(filename,map) />
#write mappings ${mapping.name} to file:
        ${filename}
    </#list>
<#else/>
No mappings found
</#if>

