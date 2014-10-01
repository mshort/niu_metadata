<?xml version="1.0" encoding="UTF-8"?>

<!-- XSL to correct transform of American Archive's DC records into MODS -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:mods="http://www.loc.gov/mods/v3" version="3.5">

    <!-- Identity template and prefix to create a copy of the source -->

    <xsl:template match="@*|node()" name="identity">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@xlink:type"/>

    <!-- Basic wrapper -->

    <xsl:template match="mods:mods">
        <mods:mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.5"
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">

            <xsl:apply-templates select="mods:titleInfo"/>
            <xsl:apply-templates select="mods:name"/>
            <xsl:apply-templates select="mods:typeOfResource"/>
            <xsl:apply-templates select="mods:genre"/>
            <xsl:apply-templates select="mods:originInfo"/>
            <xsl:apply-templates select="mods:language"/>
            <xsl:apply-templates select="mods:physicalDescription"/>
            <xsl:apply-templates select="mods:note"/>
            <xsl:apply-templates select="mods:subject"/>
            <xsl:apply-templates select="mods:relatedItem"/>
            <xsl:apply-templates select="mods:identifier"/>
            <xsl:apply-templates select="mods:location"/>
            <xsl:apply-templates select="mods:accessCondition"/>
            <xsl:apply-templates select="mods:recordInfo"/>
        </mods:mods>
    </xsl:template>

    <xsl:template match="mods:originInfo">
        <mods:originInfo>
            <xsl:for-each select="mods:dateOther">
                <xsl:if test="not(matches(.,'^[9]{2,4}'))">
                    <mods:dateOther>
                        <xsl:attribute name="type">
                            <xsl:value-of select="./@type"/>
                        </xsl:attribute>
                        <xsl:if test="@type='Year Composed'">
                            <xsl:attribute name="keyDate">
                                <xsl:text>yes</xsl:text>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="."/>
                    </mods:dateOther>
                </xsl:if>
            </xsl:for-each>
        </mods:originInfo>
    </xsl:template>

    <xsl:template match="mods:genre">
        <xsl:for-each select=".">
            <xsl:choose>
                <xsl:when test="matches(.,'[A-Z].*?;')">
                    <mods:genre authority="local">
                        <xsl:value-of select="substring-before(.,';')"/>
                    </mods:genre>
                    <mods:genre authority="local">
                        <xsl:value-of select="substring-after(.,'; ')"/>
                    </mods:genre>
                </xsl:when>
                <xsl:otherwise>
                    <mods:genre authority="local">
                        <xsl:value-of select="."/>
                    </mods:genre>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
