<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mods="http://www.loc.gov/mods/v3"
    version="1.0">
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="*">
        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:copy-of select="@*|namespace::*[name()]"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="mods:mods">
        <mods:mods xmlns:mods="http://www.loc.gov/mods/v3"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd"
            version="3.5">
            <xsl:apply-templates/>
        </mods:mods>
    </xsl:template>
    
    <xsl:template match="mods:note[@type='digitization status']"/>
    <xsl:template match="/mods:mods/mods:genre[text()='Fiction']"/>
    
</xsl:stylesheet>