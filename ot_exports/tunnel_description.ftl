<#assign tunnels=payloadElement.configuration.tunnels.*/>
<#assign entrypoints=payloadElement.configuration.entrypoints.*/>
<#assign exitpoints=payloadElement.configuration['exit-points'].*>
<#assign outgoingprofiles=payloadElement.configuration['outgoing-profiles'].*>

<#assign enp_map={}/>
<#assign exp_map={}/>
<#assign oup_map={}/>

<#--  map entrypoints  -->
<#list entrypoints as entrypoint>
	<#assign code = entrypoint.@code>
	<#assign enp_map += { code : entrypoint } >
</#list>
<#--  map exitpoints  -->
<#list exitpoints as exitpoint>
	<#assign code = exitpoint.@code>
	<#assign exp_map += { code : exitpoint } >
</#list>
<#--  map profiles  -->
<#list outgoingprofiles as op>
	<#assign code = op.@code>
	<#assign oup_map += { code : op}>
</#list>
<#--  Iterate tunnels  -->
<#list tunnels as tunnel>
Tunnel: ${tunnel.common.name}
    <#assign vars=""/>
    <#assign numvars=0/>
    <#assign entrp=tunnel.common["entry-points"].*/>
    <#--  iterate all entrypoints for this tunnel  -->
    <#list entrp as enp>
        <#assign enp_ref=enp["entry-point-ref"]/>
        <#assign entrypoint=enp_map[enp_ref] />
        <#assign url=entrypoint.protocol?lower_case+'://'+entrypoint.host+':'+entrypoint.port+entrypoint['context-path']>
    Entrypoint:     ${entrypoint.name}
                    ${url}
    </#list>

    <#--  iterate all deliverypoints for this tunnel  -->
    <#list tunnel.deliverypoints.* as deliverypoint>
        <#assign exp_ref=deliverypoint['exitpoint-ref']/>
        <#assign oup_ref=deliverypoint['outgoing-profile-ref']/>
        <#assign exitpoint=exp_map[exp_ref]/>
        <#assign url= exitpoint.protocol?lower_case+'://'+exitpoint.host+':'+exitpoint.port+exitpoint['contextPath']>
        <#--  show all exitpoints with profiles and the conditions that apply  -->
    Exitpoint:      ${exitpoint.name}
            <#if (deliverypoint.expression?has_content)>
            IF:     ${deliverypoint.expression} == ${deliverypoint['expr-value']}
            THEN:   use this Exitpoint
            </#if>
            <#if (oup_ref?has_content)>
            WITH:   ${oup_map[oup_ref].name}
            </#if>
            URL:    ${url}       
    </#list>

</#list>


