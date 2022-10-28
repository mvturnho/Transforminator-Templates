    <!--  add this to your xslt -->
    <#--  use like this for example -->
    <#--  <xsl:variable name="key" select="//selection"/>  -->
    <#--  <element><xsl:value-of select="$mapname/entry[@key=$key]"/></element>  -->
    <xsl:variable name="mapname">
        <#list csvmapping.map?keys as key>
            <#if (!key?starts_with('Source'))>
        <entry key="${key}">${csvmapping.map[key]}</entry>
            </#if>
        </#list> 
    </xsl:variable>
