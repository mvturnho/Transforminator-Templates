<#assign tunnels=payloadElement.configuration.tunnels.*/>
<#assign mappings=payloadElement.configuration.mappings.*/>

#AUTO GENERATED from tunnel export "${transforminator_inputfilename}"
xslt.transformer.factory=saxon

#definitions like xmlns:// header:// and mapping:// go here.
xmlns://bg=http://www.egem.nl/StUF/sector/bg/0310
xmlns://stuf=http://www.egem.nl/StUF/StUF0301
xmlns://zkn=http://www.egem.nl/StUF/sector/zkn/0310
xmlns://zkn0310=http://www.egem.nl/StUF/sector/zkn/0310

#Tunnels

<#list tunnels as tunnel>
#Tunnel ${tunnel.common.name}
    <#assign rtv=tunnel["runtime-variables"].*/>
    <#list rtv as attr>
        <#if (attr.value != "AQ==")>
            <#if (attr.value?starts_with("//"))>
${attr.name}=xpath://${attr.value}
            <#else>
${attr.name}=${attr.value}
            </#if>
        </#if>
    </#list>
</#list>

#Mappings

<#list mappings as mapping>
#write mappings to file: "${mapping.name}.csv"
    <#assign map='"Source value","Target value"\n'/>
    <#list mapping.values.* as val>
        <#assign kv_item = '"'+val["source-key"]+'"' + ',' + '"'+val["target-key"]+'"' + '\n'/>
        <#assign map+=kv_item/>
    </#list>
${tools.saveFile(mapping.name,map)}
</#list>