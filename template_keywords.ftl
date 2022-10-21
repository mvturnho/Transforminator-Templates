<#ftl encoding='UTF-8' >

<#assign functions=payloadElement["//sectiondef[@kind='public-func']"]/>

<#function getRefVal  val>
    <#if (val.ref?has_content)>
        <#return val.ref>
    <#else/>
        <#return val>
    </#if>
</#function>

<#function walkNode node >
    <#if (node?next_sibling??)>
        <#list node?children as next_node>
            walkNode(next_node)
        </#list>
    <#else/>
        ${node}
        <#return node>
    </#if>
    <#return "">
</#function>

<#list functions.* as function>
---
    ${getRefVal(function.type)}  ${function.name}
    <#assign params=function.param/>
    <#list params as param>
        ${getRefVal(param.type)}  ${param.declname}
    </#list>
    ${walkNode(function.detaileddescription)}
</#list>

