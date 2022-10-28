    <!--  add this to your xslt -->
    <!--  use like this for example -->
    <!--  <xsl:variable name="key" select="//selection"/>  -->
    <!--  <element><xsl:value-of select="$mapname/entry[@key=$key]"/></element>  -->
    <xsl:variable name="mapname">
<#list payloadElement as element>
        <entry key="${element[0]}">${element[1]}</entry>
</#list>
    </xsl:variable>