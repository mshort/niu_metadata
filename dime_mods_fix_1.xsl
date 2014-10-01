<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*">
        <xsl:element name="mods:{name()}" namespace="http://www.loc.gov/mods/v3">
            <xsl:copy-of select="namespace::*"/>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="/*">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

</xsl:stylesheet>
