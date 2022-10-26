<#assign mappings=payloadElement.configuration.mappings.*/>
<#assign folder="mappings"/>
<#--  go throug all mappings in the export xml  -->
<#list mappings as mapping>
    <#assign map='"Source value","Target value"\n'/>
    <#--  all key/val pairs in the mapping  -->
    <#list mapping.values.* as val>
        <#assign kv_item = '"'+val["source-key"]+'"' + ',' + '"'+val["target-key"]+'"' + '\n'/>
        <#assign map+=kv_item/>
    </#list>
    <#--  write to file  -->
    <#assign filename=folder + "/" + mapping.name + ".csv"/>
    <#assign res=tools.saveFile(filename,map) />
#write mappings ${mapping.name} to file:
    ${filename}
</#list>