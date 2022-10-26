<#ftl encoding='UTF-8'>
<#--  Cangelog  -->
<#--  17-02-2020 - add  '_tunnel' extension for tunnelcodes to make them more unique in the config  -->
<#--    -->
<#-- we first create hasmaps for all entities in the configuration with the code as their keys -->
<#-- then itterate the tunnels and add UML for all selected tunnels -->
<#assign template_version='2.1'>
<#setting number_format="computer">

<#assign allAttachments = attachments(messageheader)>
<#assign configurationAttachment = allAttachments["configuration"]>
<#assign configuration = tunnelFunction("getDom",configurationAttachment)>
<#assign tunnelcodes = url_tunnels?eval>
<#assign options = url_options?eval>

<#assign left_to_right = options.left_to_right?eval>
<#assign use_notes = options.use_notes?eval>
<#assign add_content = options.add_content?eval>
<#assign add_mappings = options.add_mappings?eval>
<#assign add_certs = options.add_certificates?eval>
<#assign add_organisations = options.add_organisations?eval>

<#assign logo_url = 'https://www.jnet.nl/contents/images/logo.png'>

<#assign color_green="#9bc43e">
<#assign color_light_green = "#b4debe">
<#assign color_elight_green = "#bbffbb">
<#assign color_grey="#dddddd">
<#assign color_blue="#eeeeff">
<#assign color_dark_blue="#ccccff">
<#assign color_trigger_interface="#ff9933">
<#assign color_interface_esb = '#ccccff'>
<#--  setup datastructures from the configuration -->

<#assign gendate=configuration.@generationDate>

<#assign version=configuration.@version>
<#assign tunnels=configuration.tunnels.* >
<#assign entrypoints=configuration.entrypoints.*>
<#assign exitpoints=configuration.exit\-points.*>
<#assign requestprofiles=configuration.request\-profiles.*>
<#assign responseprofiles=configuration.response\-profiles.*>
<#-- for 2.x exports -->
<#assign outgoingprofiles=configuration.outgoing\-profiles.*>
<#assign organisations = configuration.organisations.* >
<#assign msg_transformers = configuration.message\-transformers.* >
<#assign mappings = configuration.mappings.* >
<#assign certificates = configuration.certificates.*>
<#assign proxyservers = configuration.proxy\-servers.*>
<#assign xsd_schemas = configuration.xsd\-schemas.*>
<#assign file_tunnels = []>
<#assign code_map = {} >
<#assign type_map = {} >
<#assign tunnel_map = {}>
<#assign interface_map = {}>
<#assign deliverypoint_map = {}>
<#assign connector_map = {}>
<#assign transformer_map = {}>
<#assign expression_map = {}>
<#assign response_profile_map = {}>
<#assign note_map = {}>
<#assign filetunnel_selector_map = {}>
<#assign selector_tunnel_map = {}>
<#-- First we store all references in maps with their codes as keys -->
<#-- get all tunnels -->
<#assign tunnel_num = 0>
<#list tunnels as tunnel>
	<#assign tunnel_num += 1>
	<#assign code = tunnel.@code +  '_tunnel'>
	<#assign code_map += { code : tunnel }>
	<#assign type_map += { code: 'Tunnel' }>
	<#list tunnel.deliverypoints.* as dp>
		<#assign dcode = dp.@code + '_deliverypoint'>
		<#assign dp_num = dp.seq\-number>
		<#assign code_map += { dcode : dp }>
		<#assign type_map += { dcode : "DeliveryPoint" }>
	</#list>
	<#-- also look in tunnel-identification for <transport-params><transport-param><name>selector.tunnel</name>  -->
	<#-- so we can later connect the receivertunnels to the ExitPoint pipeline.service.selector.tunnel.backend and pipeline.service.selector.tunnel.fault selectors -->
	<#-- from the exit points we check for these attributes -->
	<#list tunnel.tunnel\-identification.transport\-params.* as tparm>
		<#if tparm.name?contains('selector.tunnel')>
			<#assign selector_tunnel_map += {tparm.value : code} >
		</#if>
	</#list>
</#list>
<#-- get all Filetunnels -->
<#assign file_tunnels = configuration.plugins.filepipeline\-plugin.file\-tunnels.*>
<#list file_tunnels as file_tunnel >
	<#assign tunnel_num += 1>
	<#assign code = file_tunnel.@code + '_filetunnel'>
	<#assign code_map += { code : file_tunnel }>
	<#assign type_map += {code: 'FileTunnel'}>
	<#list file_tunnel.file\-tunnel\-params.* as ft_param>
		<#if ft_param.prop\-name?contains('selector.filetunnel')>
			<#assign filetunnel_selector_map += { ft_param.prop\-value : code }>
		</#if>
	</#list>
</#list>
<#-- store certificates for fast reference -->
<#list certificates as cert>
	<#assign code = cert.@code + '_cert'>
	<#assign code_map += { code : cert }>
	<#assign type_map += { code : "Certificate" }>
</#list>
<#--  store entrypoints -->
<#assign num = 0>
<#list entrypoints as entrypoint>
	<#assign num += 1>
	<#assign code = entrypoint.@code + '_entrypoint'>
	<#assign code_map += { code : entrypoint } >
	<#assign type_map += { code : "EntryPoint" }>
</#list>
<#-- store exitpoints -->
<#assign num = 0>
<#list exitpoints as exitpoint>
	<#assign num += 1>
	<#assign code = exitpoint.@code + '_exitpoint'>
	<#assign code_map += { code : exitpoint } >
	<#assign type_map += { code : "ExitPoint" } >
</#list>
<#-- store request profiles -->
<#assign num = 0>
<#list requestprofiles as rp>
	<#assign num += 1>
	<#assign code = rp.@code + '_profile'>
	<#assign code_map += { code : rp}>
	<#assign type_map += { code : "VerzoekProfiel"}>
</#list>
<#-- store response profiles for V1.x or V2.x -->
<#assign num = 0>
<#-- For 1.x exports -->
<#list responseprofiles as resp>
	<#assign num += 1>
	<#assign code = resp.@code + '_profile'>
	<#assign code_map += { code : resp}>
	<#assign type_map += { code : "AntwoordProfiel"}>
</#list>
<#-- For 2.x exports -->
<#list outgoingprofiles as op>
	<#assign num += 1>
	<#assign code = op.@code + '_profile'>
	<#assign code_map += { code : op}>
	<#assign type_map += { code : "Verzoekprofiel"}>
</#list>
<#-- store organisations -->
<#assign num = 0>
<#list organisations as org>
	<#assign num += 1>
	<#assign code = org.@code + '_organisation'>
	<#assign code_map += { code : org }>
	<#assign type_map += { code : "Organisatie"}>
</#list>
<#-- store transformations -->
<#assign num = 0>
<#list msg_transformers as msgtrs >
	<#assign num += 1>
	<#assign code = msgtrs.@code + '_transformation'>
	<#assign code_map += { code : msgtrs }>
	<#assign type_map += { code : "BerichtTransformatie"}>
</#list>
<#-- store mappings -->
<#assign num = 0>
<#list mappings as mapping>
	<#assign num += 1>
	<#assign code = mapping.@code + '_mapping'>
	<#assign code_map += { code : mapping} >
</#list>
<#-- strore proxy codes -->
<#list proxyservers as sys_server>
	<#assign code = sys_server.@code + '_sys_server'>
	<#assign code_map += {code : sys_server}>
	<#list sys_server.proxy\-endpoints.* as proxy_endpoint>
		<#assign code = proxy_endpoint.@code + '_proxy_endpoint'>
		<#assign code_map += {code : proxy_endpoint}>
	</#list>
	<#list sys_server.proxy\-nodes.* as proxy_node>
		<#assign code = proxy_node.@code + '_proxy_node'>
		<#assign code_map += {code : proxy_node}>
	</#list>
</#list>
<#-- store schema's -->
<#list xsd_schemas as schema>
	<#assign code_map += {schema.@code + '_schema' : schema}>
</#list>
<#-- COMMON FUNCTIONS -->
<#-- check if object is a string -->
<#function isString obj> 
	<#return obj?is_string && !obj?is_hash_ex> 
</#function>
<#-- clean the codes from characters that are special to plantuml and remove leading and trailing spaces -->
<#function code_c code>
	<#return code?replace('.','_')?replace('-','_')?replace('#','_')?replace('{','')?replace('}','')?replace(':','')?trim>
</#function>
<#-- replace all special characters to unicode -->
<#function name_c name>
	<#assign uc_name = name>
	<#assign codes = {'[':'<U+005B>'} + {']':'<U+005D>'} + {'(':'<U+0028>'} + {')':'<U+0029>'} + {'{':'<U+007B>'} + {'}':'<U+007D>'}>
	<#list codes?keys as uc_char>
		<#assign uc_name = uc_name?replace(uc_char,codes[uc_char])>
	</#list>
	<#return uc_name>
</#function>
<#function unicode text>
	<#assign u_text = text>
	<#assign codes = {'[':'<U+005B>'} + {']':'<U+005D>'} + {'(':'<U+0028>'} + {')':'<U+0029>'} + {'{':'<U+007B>'} + {'}':'<U+007D>'}+{'/':'<U+002F>'}+{'@':'<U+0040>'}+{'|':'<U+007C>'}+{'*','<U+002A>'}+{'?':'<U+003F>'}+{':','<U+003A>'}>
	<#list codes?keys as uc_char>
		<#assign u_text = u_text?replace(uc_char,codes[uc_char])>
	</#list>
	<#return u_text>
</#function>
<#function unescape text>
	<#assign u_text = text?replace('&lt;','<')?replace('&gt;','>')?replace('&quot;','"')?replace('&amp;','&')>
</#function>
<#-- get organisation name if exists -->
<#function get_organisation_name org_code>
	<#if code_map[org_code + '_organisation']?has_content>
		<#return code_map[org_code + '_organisation'].name>
	</#if>
	<#return org_code>
</#function>
<#-- check if the value is a code -->
<#function value_is_code value>
	<#if code_map[value]??>
		<#return true>
	</#if>
	<#return false>	
</#function>
<#-- check if the tunnel was marked to be documented -->
<#-- if the todo tunnels hash is empty we do all tunnels in the configuration -->
<#function do_tunnel tunnel>
    <#if tunnelcodes?has_content>
        <#list tunnelcodes as tc>
            <#if tc.code == tunnel.@code>
                <#return true>
            </#if>
        </#list>
    <#else>
	    <#return true>
	</#if>
	<#return false>
</#function>
<#-- determine color to use for the tunnel -->
<#function get_tunnel_color tunnel>
    <#if tunnelcodes?has_content>
        <#list tunnelcodes as tc>
            <#if tc.code == tunnel.@code>
                <#return tc.color>
            </#if>
        </#list>
    </#if>
	<#return color_green>
</#function>

<#-- Functions to create plantuml -->

<#-- add details UML to note -->
<#-- itterate all settings for the node -->
<#function add_details node, note=''>
	<#assign note_details = ''>
	<#assign xmlstring = ''>
	<#assign descriptionstring = ''>
	<#if node.@code?has_content>
		<#assign note_details += "| code | " + node.@code +" |\n">
	</#if>
	<#-- namesequences to treat different -->
	<#assign retentions_names = ['audit-retention-fault','audit-retention'] >
	<#assign exitpoint_reference_names = ['res-async-exitpoint-ref' , 'fetch-end-exitpoint-ref' , 'upload-end-exitpoint-ref'] >
	<#assign partyref_names = ['party-ref' , 'fetch-party-ref' , 'upload-party-ref']>
	<#assign copyrighted = false><#if node.copyrighted??><#assign copyrighted = node.copyrighted></#if>
	<#list node.* as key>
		<#if key?children?size lt 2>
			<#-- add name for the party reference -->
			<#if partyref_names?seq_contains(key?node_name)>
				<#assign note_details += "| " + key?node_name + " | " + get_organisation_name(key) + ' - ' + key +" |\n">
			<#-- add name for the exitpoint reference -->
			<#elseif exitpoint_reference_names?seq_contains(key?node_name)>
				<#assign note_details += "| " + key?node_name + " | " + key+ ' : ' + code_map[key + '_exitpoint'].name +" |\n">
			<#-- add name for the entrypoint reference -->
			<#elseif key?node_name == 'invm-entry-point-ref'>
				<#assign note_details += "| " + key?node_name + " | " + key+ ' : ' + code_map[key + '_entrypoint'].name +" |\n">
			<#--  calculate days   -->
			<#elseif retentions_names?seq_contains(key?node_name) >
				<#if key?eval gt 0>
					<#assign days = key?eval / 3600>
					<#assign note_details += "| " + key?node_name + " | " + days + "days " + key + "seconds |\n">
				</#if>
			<#-- Proxy references -->
			<#elseif key?node_name == 'proxy-endpoint-ref'>
				<#assign proxy_code = key + '_proxy_endpoint'>
				<#if code_map[proxy_code]?has_content>
					<#assign proxy_endpoint = code_map[proxy_code]>
					<#assign proxy_details =   ' code              : ' + key +'\\n'> 
					<#assign proxy_details +=  ' name              : ' + proxy_endpoint.name + '\\n'>
					<#assign proxy_details +=  ' listen port       : ' + proxy_endpoint.listen\-port + '\\n'>
					<#assign proxy_details +=  ' listen protocol   : ' + proxy_endpoint.listen\-protocol + '\\n'>
					<#assign proxy_details +=  ' endpoint host     : ' + proxy_endpoint.virtual\-host + '\\n'>
					<#assign proxy_details +=  ' endpoint port     : ' + proxy_endpoint.virtual\-port + '\\n'>
					<#assign proxy_details +=  ' endpoint protocol : ' + proxy_endpoint.virtual\-protocol + '\\n'>
					<#assign note_details += "| " + key?node_name + " |" + proxy_details + " |\n">
				</#if>
			<#-- add content (tranlations) to the note -->
			<#elseif key?node_name == 'content'>
				<#if add_content && copyrighted='false'>
					<#assign xmlstring = '.. **content** ..\n'>
					<#assign content_string = tunnelFunction("Base64ToBinary",key?string)>
					<#assign xmlstring += unicode(content_string)?replace('#','~#')?replace('--','~--')?replace('&lt;','<')?replace('&gt;','>')?replace('&quot;','"')?replace('&amp;','&')>
				<#else>
					<#assign xmlstring = '.. **content** ..\nCopyright\n'>
				</#if>
			<#-- add description to the note -->
			<#elseif key?node_name == 'description'>
				<#assign descriptionstring = '.. **description** ..\n'>
				<#assign descriptionstring += unicode(key?string)?replace('#','~#')?replace('--','~--')>
			<#-- mask passwords -->
			<#elseif key?node_name == 'password'>
				<#assign note_details += "| " + key?node_name + " | * * password hidden * * |\n">
			<#else>
				<#assign note_details += "| " + key?node_name + " | " + key?replace('|','\\|')?replace('/','<U+002F>')?replace("\n","\\n") +" |\n">
			</#if>
		</#if>
	</#list>
	<#assign note_details += note>
	<#assign note_details += descriptionstring + '\n'>
	<#if add_content><#assign note_details += xmlstring></#if>
	<#return note_details>
</#function>
<#-- addTunnel UML -->
<#function add_tunnel tunnel, tunnel_num>
	<#assign tunnel_code = tunnel.@code +  '_tunnel'>
	<#assign tunnel_code_c = code_c(tunnel_code)>
	<#assign tunnelcolor = color_green>
	<#assign tunnelcolor = get_tunnel_color(tunnel)>
	<#-- check for async exitpoint and add if needed -->
	<#if tunnel.common.res\-async?has_content>
		<#if tunnel.common.res\-async?string == 'true'>
		<#--  assign tunnelcolor = color_light_green -->
		<#if tunnel.common.res\-async\-exitpoint\-ref?has_content>
			<#assign if_code = tunnel.common.res\-async\-exitpoint\-ref + '_exitpoint'>
			<#assign ifcode_c = add_interface(if_code)>
			<#assign res = note_to_interface("right",tunnel_num,if_code)>
			<#-- the exitpoint can heconnected to en exntrypoint to another tunnel -->
			<#-- for V1.7 -->
			<#if code_map[if_code].esb\-entry\-point\-ref?has_content>
				<#assign entrypoint_code = code_map[if_code].esb\-entry\-point\-ref + '_entrypoint'>
				<#assign res = add_connector(ifcode_c,entrypoint_code,tunnel_num,"[bold,#6666ff]")>
			<#-- for V2.x -->
			<#elseif code_map[if_code].invm\-entry\-point\-ref?has_content>
				<#assign entrypoint_code = code_map[if_code].invm\-entry\-point\-ref + '_entrypoint'>
				<#assign res = add_connector(ifcode_c,entrypoint_code,tunnel_num,"[bold,#6666ff]")>
			</#if>
			<#assign res = add_connector( tunnel_code_c , ifcode_c, "async_exitpoint - " + tunnel_num,"[bold,#ff0000]")>
		</#if>
		</#if>
	</#if>
	<#assign tunnel_node = '[' + type_map[tunnel_code] + ' #' + tunnel_num + '\\n' + name_c(tunnel.common.name) + '] as ' + tunnel_code_c + ' ' + tunnelcolor>
	<#assign tunnel_map += {tunnel_code : tunnel_node } >
	<#assign res = note_to_tunnel("left", tunnel_num, tunnel_code)>
	<#return tunnel_code_c>
</#function>
<#-- Add delivery points UML -->
<#-- itterate delivery points and when we have an expression -->
<#-- we insert an expression node before connecting the exitpoint -->
<#function add_deliverypoint dp_code, dp_num>
	<#assign dp_code_c = code_c(dp_code) >
	<#assign dp = code_map[dp_code]>
	<#assign dp_color = color_blue>
	<#if dp.is\-primary == 'true'>
		<#assign dp_color = color_dark_blue>
	</#if>
	<#assign delp = '[DeliveryPoint #' + dp_num + '] as ' + dp_code_c  + ' ' + dp_color>
	<#assign deliverypoint_map += {dp_code:delp}>
	<#if dp.expression?has_content && dp.expression?length gt 0>
		<#assign dp_expression = dp.expression?replace('[','<U+005B>')?replace(']','<U+005D>')>
		<#if dp.expr\-value?is_string>
			<#assign value = dp.expr\-value?replace('[','<U+005B>')?replace(']','<U+005D>')>
			<#assign dp_expression += " == " + value>
		</#if>
		<#assign expression_map += {dp_code_c+'_expr' : '[Expression:\\n' + dp_expression + '] as ' + dp_code_c + '_expr ' + color_grey}>
		<#assign res = add_connector( tunnel_code_c , dp_code_c+"_expr", tunnel_num +'-'+dp_num)>
		<#assign res = add_connector( dp_code_c+"_expr" , dp_code_c, tunnel_num +'-'+dp_num)>
	<#else>
		<#assign res = add_connector( tunnel_code_c , dp_code_c, tunnel_num +'-'+dp_num)>
	</#if>
	<#return dp_code_c>
</#function>
<#--  -->
<#-- FILETUNNELS -->
<#-- find attribute with selector.filetunnel -->
<#function add_filetunnel exitpoint_code comment>
	<#assign exitpoint = code_map[exitpoint_code]>
	<#if exitpoint.attributes?has_content>
		<#list exitpoint.attributes.* as att>
			<#if att.name?contains('selector.filetunnel')>
				<#-- find the code for the filetunnel in file-tunnel-params -->
				<#-- so we can connect the exitpoint to the filetunnel -->
				<#if att.value?starts_with('const://')>
					<#assign selector = att.value?replace('const://','')>
					<#if filetunnel_selector_map[selector]?has_content>
						<#assign ft_code = filetunnel_selector_map[selector]>
						<#assign res = add_connector(exitpoint_code,ft_code, 'selector:'+att.value?replace('const://','')+' - ' + comment,"[bold,#6666ff]")>
					</#if>
				</#if>
			<#elseif att.name?contains('pipeline.service.selector.tunnel.backend')>
				<#assign selector = att.value?replace('const://','')>
				<#if selector_tunnel_map[selector]?has_content>
					<#assign tcode = selector_tunnel_map[selector]>
					<#assign res = add_connector(exitpoint_code,tcode, 'selector:'+att.value?replace('const://','')+' - ' + comment,"[bold,#6666ff]")>
				</#if>
			<#elseif att.name?contains('pipeline.service.selector.tunnel.fault')>
				<#assign selector = att.value?replace('const://','')>
				<#if selector_tunnel_map[selector]?has_content>
					<#assign tcode = selector_tunnel_map[selector]>
					<#assign res = add_connector(exitpoint_code,tcode, 'selector:'+att.value?replace('const://','')+' - ' + comment,"[bold,#6666ff]")>
				</#if>
			</#if>
		</#list>
	</#if>
	<#return false>
</#function>
<#-- add an interface UML (exitpoint or entrypoint -->
<#function add_interface if_code>
	<#assign if_code_c = code_c(if_code)>
	<#if !interface_map[if_code_c]??>
		<#assign interface = code_map[if_code]>
		<#assign if_color = color_blue>
		<#-- make trigger entrypoint more easy to recognize in de flow with a signal color like orange -->
		<#if interface.protocol == 'INTERVAL'><#assign if_color = color_trigger_interface>
		<#elseif interface.protocol == 'INVM' || interface.protocol == 'ESB'><#assign if_color = color_interface_esb></#if>
		<#assign if_node = '[' + type_map[if_code] +':\\n'>
		<#assign if_node += name_c(interface.name) + '] as ' + if_code_c + ' ' + if_color>
		<#assign interface_map += {if_code_c : if_node}>
	</#if>
	<#return if_code_c>
</#function>
<#-- add expression UML  -->
<#-- expressions are also nodes that determine the path in the flow -->
<#-- we also replace special chars with unicode chars -->
<#function add_expression node>
	<#assign pt_code = node.@code>
	<#assign pt_code_c = code_c(pt_code)+'_expr'>
	<#assign pt_comment = "" >
	<#assign pt_comment += node.expression?replace('[','<U+005B>')?replace(']','<U+005D>')?replace('/','<U+002F>') + " == ">
	<#assign pt_comment += node.expr\-value?replace('[','<U+005B>')?replace(']','<U+005D>')?replace('/','<U+002F>')>
	<#assign expression_map += {pt_code_c: '[Expression:\\n' + pt_comment +'] as ' + pt_code_c + ' ' + color_grey }>
	<#return pt_code_c>
</#function>
<#-- add transformer UML -->
<#function add_transformer mt_code>
	<#assign mt_code_c = code_c(mt_code)>
	<#assign transformer_map += { mt_code_c : '[' + type_map[mt_code] + ':\\n' + name_c(code_map[mt_code].name)+'] as '+ mt_code_c}>
	<#return mt_code_c>
</#function>
<#-- Connect exitpoints defined in groovy scripts that get called from the MessageTransformation scripts -->
<#function connect_mt_exitpoint mt_code, label>
	<#assign mt = code_map[mt_code]>
	<#assign retval = false>
	<#-- shame this is a waste of time for most transformations so we first check if its a groovy thing-->
	<#if mt.classname?contains("GroovyTransformer")>
		<#list mt.template\-attributes.* as att>
			<#assign val_code = att.value?replace('const://','')?replace('tunnelvar://','') + '_exitpoint'>
			<#if code_map[val_code]?? >
				<#if type_map[val_code] == "ExitPoint">
					<#assign res = add_connector(code_c(mt_code), code_c(val_code),"from-Groovy-script "+tunnel_num, "[bold,#aaaaff]")>
					<#assign retval = true>
				</#if>
			</#if>>
		</#list>
	</#if>
	<#return retval>
</#function>
<#-- itterate the request/response profile for message transformers -->
<#-- the optionalParam can be used for color or other style params -->
<#function folow_profile profile_code, exp_code_c, label, optionalParam="">
	<#assign rp_code_c = code_c(profile_code)>
	<#list code_map[profile_code].profile\-templates.* as pt>
		<#assign mt_code = pt.messagetransformer\-ref + '_transformation'>
		<#assign res = connect_mt_exitpoint(mt_code,label)>
		<#assign mt_code_c = add_transformer(mt_code)>
		<#if pt.order\-number?has_content>
			<#assign nlabel = label + '-'+pt.order\-number>
		<#else>
			<#assign nlabel = label>
		</#if>
		<#assign res = note_to_transformation("right",tunnel_num, mt_code)>
		<#if pt.expression?has_content && pt.expression?length gt 0>
			<#assign pt_code_c = add_expression(pt)>
			<#assign res = add_connector( rp_code_c , pt_code_c , nlabel, optionalParam)>
			<#assign res = add_connector( pt_code_c , mt_code_c , nlabel, optionalParam)>
			<#assign res = add_connector( mt_code_c , exp_code_c, nlabel, optionalParam)>
		<#else>
			<#assign res = add_connector(rp_code_c, mt_code_c ,nlabel, optionalParam)>
			<#assign res = add_connector(mt_code_c, exp_code_c,nlabel, optionalParam)>
		</#if>
	</#list>
</#function>
<#-- function to add connectors -->
<#-- when connector is already defined we add the comment to the existing connector-->
<#function add_connector from, to, comment, optionalParam="">
	<#assign from_c = code_c(from)>
	<#assign to_c = code_c(to)>
	<#if connector_map[from_c+to_c]??>
		<#assign val = connector_map[from_c+to_c]>
		<#assign com = val[2] + " / " + comment >
		<#assign connector_map += {from_c+to_c,[from_c,to_c,com,optionalParam]}>
	<#else>
		<#assign connector_map += {from_c+to_c,[from_c,to_c,comment,optionalParam]}>
	</#if>
	<#return true>
</#function>
<#-- Add response/request profile by code -->
<#function add_profile rp_code>
	<#assign rp_code_c = code_c(rp_code)>
	<#assign rp_name_c = name_c(code_map[rp_code].name)>
	<#assign response_profile_map += {rp_code :'[' + type_map[rp_code] + ':\\n' + rp_name_c + '] as ' + rp_code_c}>
	<#assign res = note_to_node('right',rp_code)>
	<#return rp_code_c>
</#function>
<#-- Add a note to a transformation -->
<#function note_to_node align node_code>
	<#if use_notes??>
		<#assign node_code_c = code_c(node_code)>
		<#assign node_note = "note "+align+" of " + node_code_c +"\n">
		<#assign node = code_map[node_code]>
		<#assign node_note += add_details(node)>
		<#assign node_note += "end note">
		<#assign note_map += {node_code_c : node_note}>
		<#return true>
	</#if>
	<#return false>
</#function>
<#-- add a note to an interface (entrypoint/exitpoint) -->
<#function note_to_interface align tunnel_num, ep_code>
	<#assign ep_code_c = code_c(ep_code)>
	<#-- check if the code is in the code_map -->
	<#--  <#if code_map[ep_code]??>  -->
		<#assign ep = code_map[ep_code]>
		<#if use_notes?? && !note_map[ep_code_c]??>
			<#assign ep_note = "note "+align+" of " + ep_code_c +"\n">
			<#assign ep_note += add_details(ep)>
			<#-- exitpoint has properties and attributes -->
			<#if ep.properties?has_content><#assign ep_note += ".. **properties** ..\n"></#if>
			<#list ep.properties.* as prop>
				<#if prop.value?is_string>
					<#assign ep_note += "| " + prop.name + " | " + prop.value?replace('|','\\|')?replace('/','<U+002F>') + " |\n">
				<#else>
					<#assign ep_note += "| " + prop.name + " | ">
					<#list prop.value as pps>
						<#assign ep_note += pps + "\\n">
					</#list>
					<#assign ep_note += " |\n">
				</#if>
			</#list>
			<#if ep.attributes?has_content><#assign ep_note += ".. **attributes** ..\n"></#if>
			<#list ep.attributes.* as att>
				<#assign ep_note += "| " + att.order\-number + " | " + att.name + " | " + att.value?replace('|','\\|')?replace('/','<U+002F>') + " |\n">
			</#list>
			<#assign ep_note += "end note">
			<#assign note_map += {ep_code_c : ep_note}>
			<#return true>
		</#if>
	<#--  <#else>
		<#assign ep_note = "note "+align+" of " + ep_code_c +"\n">
		<#assign ep_note += "code: "+ep_code_c+" NOT FOUND IN MAP!\n">
		<#assign ep_note += "end note">
		<#assign note_map += {ep_code_c : ep_note}>
	</#if>  -->
	<#return false>
</#function>
<#-- add a note to a tunnel -->
<#function note_to_tunnel align tunnel_num, tunnel_code>
	<#if use_notes??>
		<#assign tunnel_code_c = code_c(tunnel_code)>
		<#assign tunnel_note = "note "+align+" of " + tunnel_code_c +"\n">
		<#assign tunnel_note += "Tunnel #"+tunnel_num+ "\n">
		<#assign tunnel = code_map[tunnel_code]>
		<#assign tunnel_note += add_details(tunnel)>
		<#assign tunnel_note += ".. **Common** ..\n">
		<#assign tunnel_note += add_details(tunnel.common)>
		<#-- check to see if we should add identification -->
		<#if tunnel.tunnel\-identification.transport\-params\-or != "false">
		    <#assign tunnel_note += ".. **Identification** ..\n">
    		<#assign tunnel_note += add_details(tunnel.tunnel\-identification)>
    		<#list tunnel.tunnel\-identification.transport\-params.* as tparam>
    			<#assign tunnel_note += '| ' + tparam.name + ' | ' + tparam.value + ' |\n'>
    		</#list>
		</#if>
		<#if tunnel.runtime\-variables?has_content>
    		<#assign tunnel_note += ".. **runtime_vars** ..\n|<#gainsboro><r>#|name|value|metrics|predefined|proces-field|\n">
    		<#list tunnel.runtime\-variables.* as var>
    			<#if isString(var['name'])>
    				<#assign metrics = '-'>
    				<#assign predef = '-'>
    				<#assign procesf = '-'>
    				<#if var['metrics-field']?is_string> <#assign metrics = var['metrics-field']?replace('true','<#PowderBlue><r>')?replace('false','')> </#if>
    				<#if var['predefined-field']?is_string> <#assign predef = var['predefined-field']?replace('true','<#PowderBlue><r>')?replace('false','')> </#if>
    				<#if var['process-field']?is_string> <#assign procesf = var['process-field']?replace('true','<#PowderBlue><r>')?replace('false','')> </#if>
    				<#-- filter out all predefined runtimevars -->
    				<#if var['value']?has_content>
    					<#if !var['value']?starts_with('AQ==')>
    						<#assign tunnel_note += '|<#gainsboro><r> '+var['order-number']+' | '+var['name']+' | '+var['value']?replace('|','\\|')?replace('/','<U+002F>')+ ' | ' + metrics+ ' | ' + predef+ ' | ' + procesf +' |\n'>
    					</#if>
    				</#if>
    			</#if>
    		</#list>
		</#if>
		<#assign tunnel_note += "end note">
		<#assign note_map += {tunnel_code_c : tunnel_note}>
		<#return true>
	</#if>
	<#return false>
</#function>
<#-- Add a note to a transformation -->
<#function note_to_transformation align tunnel_num, trf_code>
	<#if use_notes??>
		<#assign trf_code_c = code_c(trf_code)>
		<#assign trf_note = "note "+align+" of " + trf_code_c +"\n">
		<#assign trf = code_map[trf_code]>
		<#assign note_attr = ''>
		<#if trf.template\-attributes?has_content><#assign note_attr += ".. **attributes** ..\n"></#if>
		<#list trf.template\-attributes.* as att>
			<#if version?starts_with('1.7.5')>
				<#assign ordn = att.oder\-number>
			<#else>
				<#assign ordn = att.order\-number>
			</#if>
			<#assign val_code = att.value?replace('const://','')?replace('tunnelvar://','')>
			<#if code_map[val_code]?? >
				<#assign note_attr += '|<#gainsboro><r> '+ordn+' | '+att.name+' | '+att.value?replace('/','<U+002F>')+ ' - '+ code_map[val_code].name +' |\n'>
			<#else>
				<#assign note_attr += '|<#gainsboro><r> '+ordn+' | '+att.name+' | '+att.value?replace('/','<U+002F>')+' |\n'>
			</#if>
		</#list>
		<#assign trf_note += add_details(trf,note_attr)>
		<#assign trf_note += "\nend note">
		<#assign note_map += {trf_code_c : trf_note}>
		<#return true>
	</#if>
	<#return false>
</#function>

<#-- Macro's to add all entities like tunnels, entrypoint etc to the output -->
<#macro output_all_uml>

' tunnels
<#list tunnel_map?keys as key>
${tunnel_map[key]}
</#list>
' interfaces
<#list interface_map?keys as key>
${interface_map[key]}
</#list>
' deliverypoints
<#list deliverypoint_map?keys as key>
${deliverypoint_map[key]}
</#list>
' response profiles
<#list response_profile_map?keys as key>
${response_profile_map[key]}
</#list>
' expressions
<#list expression_map?keys as key>
${expression_map[key]?replace(' and ',' and \\n')?replace(' or ',' or \\n')}
</#list>
' message transformers
<#list transformer_map?keys as key>
${transformer_map[key]}
</#list>
' notes
<#if use_notes>
<#list note_map?keys as key>
${note_map[key]}
</#list>
</#if>
' connectors
<#list connector_map?keys as key>
${connector_map[key][0]} -${connector_map[key][3]}-> ${connector_map[key][1]} :${connector_map[key][2]}
</#list>
</#macro>

<#macro ouput_uml_top>
<#if left_to_right>
left to right direction
</#if>

<#assign skinparam = 'skinparam {
    componentStyle rectangle
    RoundCorner 8
    titleBorderRoundCorner 8
    titleBorderThickness 2
    titleBorderColor grey
    titleBackgroundColor #eeeeee
    titleFontSize	28
    NoteFontName monospaced
    NoteFontStyle normal
    NoteBackgroundColor #eeeeee
    NoteBorderColor #grey
    NoteFontColor #grey
    NoteFontSize 6
    NoteShadowing true
    DPI 200
    Shadowing false
    DefaultFontName Roboto Condensed
    DefaultMonospacedFontName Inconsolata
    InterfaceBackgroundColor #ee1111
    ArrowColor #111111
    defaultFontSize 10
    legendBackgroundColor #ffffff
}
'>

${skinparam}
</#macro>

<#macro output_legend>
legend top left

<img:${logo_url}>

Template version:   ${template_version}
Exportfile:         ${exportfile}
Opentunnel version: ${version}
Generation date:    ${gendate?datetime.iso?string("yyyy-MM-dd")}

color legend:
|<${color_blue}>		EntryPoints         	|
|<${color_green}>		Tunnels           	|
|<${color_light_green}>		Async Tunnels  	|
|<${color_elight_green}>		File Tunnels	|
|<${color_dark_blue}>		Primary delivery point 	|
<#list tunnelcodes as tc>
|<${tc.color}> #${tc.id} - ${code_map[tc.code +  '_tunnel'].common.name}        |
</#list>

<#if add_organisations>
Organisations:
|= name |= description |
<#list organisations as org>
<#if version?starts_with('1.7.5')>
| ${org.name} |
<#else>
| ${org.name} |
</#if>
</#list>
</#if>

<#if add_mappings>
Mappings:
<#list mappings as mapping>
${mapping.name}:
|= key |= value |
	<#list mapping.values.* as value>
| ${value.source\-key} | ${value.target\-key} |
	</#list>
</#list>
</#if>
<#if add_certs>
certificates:
|= serial |= type |= issuer-dn |
<#list certificates as cert>
| ${cert.serial\-number} | ${cert.type} | ${cert.issuer\-dn} |
</#list>
</#if>
end legend
</#macro>

@startuml
<#call ouput_uml_top()>
footer ${.now}
<#assign tunnel_num = 0>
<#list tunnels as tunnel>
	<#if do_tunnel(tunnel)>
        <#assign tunnel_code_c = add_tunnel(tunnel, tunnel_num) >
	<#-- request -->
	<#-- response can have a response-profiles for fault an normal -->
		<#if tunnel.response.fault\-messagetransformer\-ref?has_content>
			<#assign mt_code = tunnel.response.fault\-messagetransformer\-ref + '_transformation'>
			<#assign mt_code_c = add_transformer(mt_code)>
			<#assign res = add_connector( tunnel_code_c , mt_code_c , "fault-response-"+tunnel_num, "[#red]")>
			<#assign res = note_to_transformation("right",tunnel_num, mt_code)>		
		</#if>
		<#-- Ack message transformer -->
		<#if tunnel.response.ack\-messagetransformer\-ref?has_content>
			<#assign amt_code = tunnel.response.ack\-messagetransformer\-ref + '_transformation'>
			<#assign amt_code_c = add_profile(amt_code)>
			<#assign res = add_connector( tunnel_code_c , amt_code_c, "ack response-"+tunnel_num, "[#green]")>
			<#assign res = add_connector( amt_code_c, tunnel_code_c,  "ack response-"+tunnel_num, "[#green]")>
			<#assign res = add_transformer(amt_code)>
			<#assign res = note_to_transformation("right", tunnel_num, amt_code)>
		</#if>
		<#-- Antwoordprofiel -->
		<#if tunnel.response.profile\-ref?has_content>
			<#assign rp_code = tunnel.response.profile\-ref + '_profile'>
			<#assign rp_code_c = add_profile(rp_code)>
			<#assign res = add_connector( tunnel_code_c , rp_code_c, "response-"+tunnel_num, "[#green]")>
			<#assign res = folow_profile(rp_code, tunnel_code_c, "response-"+tunnel_num, "[#green]")>
		</#if>
		<#-- Error exitpoint -->
		<#if tunnel.request.error\-exitpoint\-ref?has_content>
			<#assign ep_code = tunnel.request.error\-exitpoint\-ref + '_exitpoint'>
			<#assign ep_code_r = add_interface(ep_code)>
			<#assign res = note_to_interface("left" tunnel_num, ep_code) >
			<#assign res = add_connector( tunnel_code_c, ep_code_c, "request_error-"+tunnel_num, "[#red]")>
		</#if>
	<#-- entrypoints -->
		<#list tunnel.common.entry\-points.* as ep>
			<#assign ep_code = ep.entry\-point\-ref + '_entrypoint'>
			<#assign ep_code_c = add_interface(ep_code)>
			<#assign res = note_to_interface("left" tunnel_num, ep_code) >
			<#assign res = add_connector( ep_code_c ,tunnel_code_c, tunnel_num)>
		</#list>
	<#-- delivery points have exitpoints and may have verzoek profiel-->
		<#assign dp_num = 0>
		<#list tunnel.deliverypoints.* as dp>
			<#assign dp_code = dp.@code + '_deliverypoint'>
			<#if dp.seq\-number?has_content>
				<#assign dp_num = dp.seq\-number>
			<#else>
				<#assign dp_num += 1>
			</#if>
			<#assign dp_code_c = add_deliverypoint(dp_code,dp_num)>
	<#-- exitpoints -->
			<#assign exp_code = dp.exitpoint\-ref + '_exitpoint'>
		    <#assign exp_code_c = add_interface(exp_code)>
	<#-- check verzoek profiel V2-->
			<#if dp.outgoing\-profile\-ref?has_content>
				<#assign rp_code = dp.outgoing\-profile\-ref + '_profile'>
	<#-- check verzoek profiel V1.7 -->
			<#elseif dp.requestprofile\-ref?has_content>
				<#assign rp_code = dp.requestprofile\-ref + '_profile'>
			<#else>
				<#assign rp_code = ''>
			</#if>
			<#if rp_code?has_content>
				<#assign rp_code_c = add_profile(rp_code)>
				<#assign res = add_connector( dp_code_c , rp_code_c, tunnel_num + "-" + dp_num)>
	<#-- check voor bericht translaties in verzoekprofiel -->
				<#assign res = folow_profile(rp_code, exp_code_c, tunnel_num + "-" + dp_num)>
			<#else>
				<#assign res = add_connector(dp_code_c, exp_code_c, tunnel_num + "-" + dp_num)>
			</#if>
	<#-- connect exitpoint to filetunnel if there is one (determined by attribute selector.filetunnel -->
			<#assign res = add_filetunnel(exp_code, tunnel_num + "-" + dp_num)>
	<#-- add note to the exitpoint -->
			<#assign res = note_to_interface("right",tunnel_num,exp_code)>
	<#-- connect the tunnels if the exitpoint has a reference to an entrypoint V1.7 and V2.0-->
			<#if code_map[exp_code].esb\-entry\-point\-ref?has_content>
				<#assign entrypoint_code = code_map[exp_code].esb\-entry\-point\-ref + '_entrypoint'>
				<#assign res = add_connector(exp_code_c,entrypoint_code,tunnel_num,"[bold,#6666ff]")>
			<#elseif code_map[exp_code].invm\-entry\-point\-ref?has_content>
				<#assign entrypoint_code = code_map[exp_code].invm\-entry\-point\-ref + '_entrypoint'>
				<#assign entrypoint_code_c = add_interface(entrypoint_code)>
				<#assign res = note_to_interface("left" tunnel_num, entrypoint_code) >
				<#assign res = add_connector(exp_code_c,entrypoint_code,tunnel_num,"[bold,#6666ff]")> 
			</#if>
		</#list><#-- deliverypoints -->
	</#if>
	<#assign tunnel_num += 1>
</#list><#-- tunnel -->
<#-- Process the Filetunnels if they exist -->
<#assign filetunnelcolor = color_elight_green>
<#list file_tunnels as file_tunnel>
	<#assign tunnel_num += 1>
	<#assign tunnel_code = file_tunnel.@code + '_filetunnel'>
	<#assign tunnel_code_c = code_c(tunnel_code)>
	<#assign tunnel_node = '[' + type_map[tunnel_code] + ' #' + tunnel_num + '\\n' + name_c(file_tunnel.name) + '] as ' + tunnel_code_c + ' ' + filetunnelcolor>
	<#assign tunnel_map += {tunnel_code : tunnel_node } >
	<#assign res = note_to_node('left',tunnel_code)>
<#-- connect filetunnel to the file fetch exitpoint -->
	<#assign if_code = file_tunnel.fetch\-end\-exitpoint\-ref + '_exitpoint'>
	<#assign ifcode_c = add_interface(if_code)>
	<#assign res = note_to_interface("right",tunnel_num,if_code)>
	<#assign res = add_connector(tunnel_code_c,ifcode_c, tunnel_num)>
<#-- connect filetunnel to the file upload exitpoint -->
	<#assign upl_ic_code = file_tunnel.upload\-end\-exitpoint\-ref + '_exitpoint'>
	<#assign upl_ic_code_c = add_interface(upl_ic_code)>
	<#assign res = note_to_interface("right",tunnel_num,upl_ic_code)>
	<#assign res = add_connector(tunnel_code_c,upl_ic_code_c, tunnel_num)>
</#list>


<#-- All UML -->
<#call output_all_uml()>
<#-- LEGEND -->
<#call output_legend()>


@enduml