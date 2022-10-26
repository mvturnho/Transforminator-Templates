<#assign tunnels=payloadElement.configuration.tunnels.*/>
<#assign folder="tunnelvars"/>
<#--  itterate all tunnels  -->
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
        <#assign filename=folder + "/" + tunnel.common.name + ".tunnelvars"/>
        <#assign res=tools.saveFile(filename,vars)/>
# Tunnel ${tunnel.common.name}
    ${numvars} variables found; saved to:
    ${filename}
    <#else>
#Tunnel ${tunnel.common.name}
    NO variables
    </#if>
</#list>
