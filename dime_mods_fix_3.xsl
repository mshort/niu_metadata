<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mods="http://www.loc.gov/mods/v3" version="1.0">

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
            <xsl:apply-templates select="mods:titleInfo"/>
            <xsl:apply-templates select="mods:name"/>
            <xsl:apply-templates select="mods:typeOfResource"/>
            <xsl:apply-templates select="mods:genre"/>
            <xsl:apply-templates select="mods:originInfo"/>
            <xsl:apply-templates select="mods:language"/>
            <xsl:apply-templates select="mods:physicalDescription"/>
            <xsl:apply-templates select="mods:note"/>
            <xsl:apply-templates select="mods:subject"/>
            <xsl:apply-templates select="mods:classification"/>
            <xsl:apply-templates select="mods:relatedItem"/>
            <xsl:apply-templates select="mods:identifier"/>
            <mods:location>
                <xsl:apply-templates select="mods:location/mods:physicalLocation"/>
                <mods:shelfLocator>
                    <xsl:if test="mods:classification[@authority='lcc']">
                        <xsl:value-of select="mods:classification[@authority='lcc']"/>
                    </xsl:if>
                    <xsl:if test="not(mods:classification[@authority='lcc'])">
                        <xsl:text>PS648.D55 F3643 1917a no.</xsl:text>
                    </xsl:if>
                </mods:shelfLocator>
                <mods:url access="object in context" usage="primary display"
                    >http://dimenovels.lib.niu.edu/islandora/object/dimenovels:</mods:url>
            </mods:location>
            <mods:accessCondition type="useAndReproduction">Use of this public-domain resource is
                unrestricted.</mods:accessCondition>
            <xsl:apply-templates select="mods:recordInfo"/>
        </mods:mods>
    </xsl:template>

    <xsl:template match="/mods:mods/mods:name[@type='personal']">
        <mods:name authority="naf" type="personal"
            authorityURI="http://id.loc.gov/authorities/names"
            valueURI="http://id.loc.gov/authorities/names/">
            <mods:namePart>
                <xsl:value-of select="mods:namePart"/>
            </mods:namePart>
            <xsl:if test="mods:namePart[@type='date']">
                <mods:namePart type="date">
                    <xsl:value-of select="mods:namePart[@type='date']"/>
                </mods:namePart>
            </xsl:if>
            <mods:role>
                <mods:roleTerm type="text">author</mods:roleTerm>
            </mods:role>
        </mods:name>
    </xsl:template>

    <xsl:template match="/mods:mods/mods:genre">
        <xsl:choose>
            <xsl:when test=".='Love stories'">
                <mods:genre authority="lcsh" authorityURI="http://id.loc.gov/authorities/subjects"
                    valueURI="http://id.loc.gov/authorities/subjects/sh85078595">
                    <xsl:value-of select="."/>
                </mods:genre>
            </xsl:when>
            <xsl:when test=".='Sea stories'">
                <mods:genre authority="lcsh" authorityURI="http://id.loc.gov/authorities/subjects"
                    valueURI="http://id.loc.gov/authorities/subjects/sh85119251">
                    <xsl:value-of select="."/>
                </mods:genre>
            </xsl:when>
            <xsl:when test=".='Historical fiction'">
                <mods:genre authority="lcsh" authorityURI="http://id.loc.gov/authorities/subjects"
                    valueURI="http://id.loc.gov/authorities/subjects/sh94003033">
                    <xsl:value-of select="."/>
                </mods:genre>
            </xsl:when>
            <xsl:when test=".='Adventure stories'">
                <mods:genre authority="lcsh" authorityURI="http://id.loc.gov/authorities/subjects"
                    valueURI="http://id.loc.gov/authorities/subjects/sh85001072">
                    <xsl:value-of select="."/>
                </mods:genre>
            </xsl:when>
            <xsl:when test=".='Detective and mystery stories'">
                <mods:genre authority="lcsh" authorityURI="http://id.loc.gov/authorities/subjects"
                    valueURI="http://id.loc.gov/authorities/subjects/sh85037260">
                    <xsl:value-of select="."/>
                </mods:genre>
            </xsl:when>
            <xsl:when test=".='Humorous stories'">
                <mods:genre authority="lcsh" authorityURI="http://id.loc.gov/authorities/subjects"
                    valueURI="http://id.loc.gov/authorities/subjects/sh85062975">
                    <xsl:value-of select="."/>
                </mods:genre>
            </xsl:when>
            <xsl:when test=".='War stories'">
                <mods:genre authority="lcsh" authorityURI="http://id.loc.gov/authorities/subjects"
                    valueURI="http://id.loc.gov/authorities/subjects/sh85145220">
                    <xsl:value-of select="."/>
                </mods:genre>
            </xsl:when>
            <xsl:when test=".='Western stories'">
                <mods:genre authority="lcsh" authorityURI="http://id.loc.gov/authorities/subjects"
                    valueURI="http://id.loc.gov/authorities/subjects/sh85146287">
                    <xsl:value-of select="."/>
                </mods:genre>
            </xsl:when>
            <xsl:otherwise>
                <mods:genre authority="lcsh" authorityURI="http://id.loc.gov/authorities/subjects"
                    valueURI="http://id.loc.gov/authorities/subjects/">
                    <xsl:value-of select="."/>
                </mods:genre>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="/mods:mods/mods:originInfo">
        <mods:originInfo eventType="publication">
            <mods:place>
                <mods:placeTerm type="code" authority="marccountry">
                    <xsl:value-of
                        select="/mods:mods/mods:originInfo/mods:place/mods:placeTerm[@type='code']"
                    />
                </mods:placeTerm>
            </mods:place>
            <mods:place>
                <mods:placeTerm type="text">
                    <xsl:value-of
                        select="/mods:mods/mods:originInfo/mods:place/mods:placeTerm[@type='text']"
                    />
                </mods:placeTerm>
            </mods:place>
            <mods:publisher>
                <xsl:value-of select="mods:publisher"/>
            </mods:publisher>
            <mods:dateIssued keyDate="yes">
                <xsl:value-of select="mods:dateIssued"/>
            </mods:dateIssued>
            <mods:copyrightDate>
                <xsl:value-of select="mods:dateIssued"/>
            </mods:copyrightDate>
        </mods:originInfo>
    </xsl:template>

    <xsl:template match="/mods:mods/mods:language">
        <mods:language>
            <mods:languageTerm authority="iso639-2b" type="code">eng</mods:languageTerm>
            <mods:languageTerm authority="iso639-2b" type="text">English</mods:languageTerm>
        </mods:language>
    </xsl:template>

    <xsl:template match="/mods:mods/mods:physicalDescription">
        <mods:physicalDescription>
            <mods:form authority="local">
                <xsl:value-of select="mods:form[@authority='local']"/>
            </mods:form>
            <mods:form authority="rdacontent" type="content">
                <xsl:value-of select="mods:form[@type='content']"/>
            </mods:form>
            <mods:form authority="rdamedia" type="media">
                <xsl:value-of select="mods:form[@type='media']"/>
            </mods:form>
            <mods:form authority="rdacarrier" type="carrier">
                <xsl:value-of select="mods:form[@type='carrier']"/>
            </mods:form>
            <mods:internetMediaType>image/tiff</mods:internetMediaType>
            <mods:internetMediaType>image/jp2</mods:internetMediaType>
            <mods:internetMediaType>image/jpeg</mods:internetMediaType>
            <mods:internetMediaType>application/pdf</mods:internetMediaType>
            <mods:internetMediaType>text/plain</mods:internetMediaType>
            <mods:extent unit="pages">
                <xsl:if test="contains(mods:extent,' pages')">
                    <xsl:value-of select="substring-before(mods:extent, ' pages')"/>
                </xsl:if>
                <xsl:if test="contains(mods:extent,' p.')">
                    <xsl:value-of select="substring-before(mods:extent, ' p.')"/>
                </xsl:if>
            </mods:extent>
            <mods:digitalOrigin>
                <xsl:value-of select="mods:digitalOrigin"/>
            </mods:digitalOrigin>
        </mods:physicalDescription>
    </xsl:template>

    <xsl:template match="/mods:mods/mods:subject">
        <mods:subject authority="lcsh" authorityURI="http://id.loc.gov/authorities/subjects"
            valueURI="http://id.loc.gov/authorities/subjects/">
            <xsl:apply-templates/>
        </mods:subject>
    </xsl:template>

    <xsl:template match="/mods:mods/mods:relatedItem[@type='series'][1]">
        <mods:relatedItem type="series">
            <mods:titleInfo>
                <mods:title>
                    <xsl:value-of
                        select="/mods:mods/mods:relatedItem[@type='series']/mods:titleInfo[not(@type)]/mods:title"
                    />
                </mods:title>
                <mods:partNumber>
                    <xsl:value-of
                        select="/mods:mods/mods:relatedItem[@type='series']/mods:titleInfo/mods:partNumber"
                    />
                </mods:partNumber>
            </mods:titleInfo>
            <mods:titleInfo type="uniform">
                <mods:title>
                    <xsl:value-of
                        select="/mods:mods/mods:relatedItem[@type='series']/mods:titleInfo[@type='uniform']/mods:title"
                    />
                </mods:title>
                <mods:partNumber>
                    <xsl:value-of
                        select="/mods:mods/mods:relatedItem[@type='series']/mods:titleInfo/mods:partNumber"
                    />
                </mods:partNumber>
            </mods:titleInfo>
        </mods:relatedItem>
    </xsl:template>

    <xsl:template match="/mods:mods/mods:relatedItem[@type='series'][2]"/>

</xsl:stylesheet>
