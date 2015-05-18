<?xml version="1.0" encoding="utf-8"?>

<!-- XSL to transform corrected MODS records from history collections (Twain, Lincoln, Prairie, Gilded) into DC -->

<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods srw_dc"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:srw_dc="info:srw/schema/1/dc-schema"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- This stylesheet transforms MODS version 3.2 records and collections of records to simple Dublin Core (DC) records, based on the Library of Congress' MODS to simple DC mapping <http://www.loc.gov/standards/mods/mods-dcsimple.html> 		The stylesheet will transform a collection of MODS 3.2 records into simple Dublin Core (DC)as expressed by the SRU DC schema <http://www.loc.gov/standards/sru/dc-schema.xsd>The stylesheet will transform a single MODS 3.2 record into simple Dublin Core (DC)as expressed by the OAI DC schema <http://www.openarchives.org/OAI/2.0/oai_dc.xsd>		Because MODS is more granular than DC, transforming a given MODS element or subelement to a DC element frequently results in less precise tagging, and local customizations of the stylesheet may be necessary to achieve desired results. This stylesheet makes the following decisions in its interpretation of the MODS to simple DC mapping: 	When the roleTerm value associated with a name is creator, then name maps to dc:creatorWhen there is no roleTerm value associated with name, or the roleTerm value associated with name is a value other than creator, then name maps to dc:contributorStart and end dates are presented as span dates in dc:date and in dc:coverageWhen the first subelement in a subject wrapper is topic, subject subelements are strung together in dc:subject with hyphens separating themSome subject subelements, i.e., geographic, temporal, hierarchicalGeographic, and cartographics, are also parsed into dc:coverageThe subject subelement geographicCode is dropped in the transform	Revision 1.1	2007-05-18 <tmee@loc.gov>		Added modsCollection conversion to DC SRU		Updated introductory documentation	Version 1.0	2007-05-04 Tracy Meehleib <tmee@loc.gov>-->
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="/">

        <xsl:choose>
            <xsl:when test="//mods:modsCollection">
                <srw_dc:dcCollection
                    xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/standards/sru/dc-schema.xsd">
                    <xsl:apply-templates/>
                    <xsl:for-each select="mods:modsCollection/mods:mods">
                        <srw_dc:dc
                            xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/standards/sru/dc-schema.xsd">
                            <xsl:apply-templates/>
                        </srw_dc:dc>
                    </xsl:for-each>
                </srw_dc:dcCollection>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="mods:mods">
                    <oai_dc:dc
                        xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd"
                        xmlns:dc="http://purl.org/dc/elements/1.1/">
                        <xsl:element name="dc:format">image/tiff</xsl:element>
                        <xsl:apply-templates/>
                    </oai_dc:dc>
                    
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    <xsl:template match="mods:titleInfo">
        <dc:title>
            <xsl:value-of select="mods:nonSort"/>
            <xsl:if test="mods:nonSort">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select="mods:title"/>
            <xsl:if test="mods:subTitle">
                <xsl:text>: </xsl:text>
                <xsl:value-of select="mods:subTitle"/>
            </xsl:if>
            <xsl:if test="mods:partNumber">
                <xsl:text>. </xsl:text>
                <xsl:value-of select="mods:partNumber"/>
            </xsl:if>
            <xsl:if test="mods:partName">
                <xsl:text>. </xsl:text>
                <xsl:value-of select="mods:partName"/>
            </xsl:if>
        </dc:title>
    </xsl:template>
    <xsl:template match="mods:name">
        <xsl:choose>
            <xsl:when test="mods:role/mods:roleTerm='creator'">
                <dc:creator>
                    <xsl:call-template name="name"/>
                </dc:creator>
            </xsl:when>

            <xsl:otherwise>
                <dc:contributor>
                    <xsl:call-template name="name"/>
                </dc:contributor>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="mods:classification">
        <dc:subject>
            <xsl:value-of select="."/>
        </dc:subject>
    </xsl:template>


    <xsl:template match="mods:subject">

        <xsl:for-each select="mods:topic | mods:occupation">
            <dc:subject>
                <xsl:value-of select="."/>
            </dc:subject>
        </xsl:for-each>


        <xsl:for-each select="mods:temporal">
            <dc:coverage>
                <xsl:value-of select="."/>
            </dc:coverage>
        </xsl:for-each>

    </xsl:template>


    <xsl:template match="mods:abstract | mods:tableOfContents | mods:note">
        <dc:description>
            <xsl:value-of select="."/>
        </dc:description>
    </xsl:template>

    <xsl:template match="mods:originInfo">

        <xsl:for-each select="mods:dateIssued | mods:dateCreated | mods:dateCaptured">
            <dc:date>
                <xsl:value-of select="."/>
            </dc:date>
        </xsl:for-each>

        <xsl:for-each select="mods:publisher">
            <dc:source>
                <xsl:value-of select="translate(.,'&lt;u&gt;/', '')"/>
            
            </dc:source>
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="mods:genre">
        <xsl:choose>
            <xsl:when test="@authority='dct'">
                <dc:type>
                    <xsl:value-of select="."/>
                </dc:type>
                <xsl:for-each select="mods:typeOfResource">
                    <dc:type>
                        <xsl:value-of select="."/>
                    </dc:type>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <dc:type>
                    <xsl:value-of select="."/>
                </dc:type>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="mods:typeOfResource">
        <xsl:choose>
            <xsl:when test="@collection='yes'">
                <dc:type>Collection</dc:type>
            </xsl:when>
            <xsl:when test=". ='software' and ../mods:genre='database'">
                <dc:type>DataSet</dc:type>
            </xsl:when>
            <xsl:when test=".='software' and ../mods:genre='online system or service'">
                <dc:type>Service</dc:type>
            </xsl:when>
            <xsl:when test=".='software'">
                <dc:type>Software</dc:type>
            </xsl:when>
            <xsl:when test=".='cartographic material'">
                <dc:type>Image</dc:type>
            </xsl:when>
            <xsl:when test=".='multimedia'">
                <dc:type>InteractiveResource</dc:type>
            </xsl:when>
            <xsl:when test=".='moving image'">
                <dc:type>MovingImage</dc:type>
            </xsl:when>
            <xsl:when test=".='three-dimensional object'">
                <dc:type>PhysicalObject</dc:type>
            </xsl:when>
            <xsl:when test="starts-with(.,'sound recording')">
                <dc:type>Sound</dc:type>
            </xsl:when>
            <xsl:when test=".='still image'">
                <dc:type>StillImage</dc:type>
            </xsl:when>
            <xsl:when test=". ='text'">
                <dc:type>Text</dc:type>
            </xsl:when>
            <xsl:when test=".='notated music'">
                <dc:type>Text</dc:type>
            </xsl:when>
            <xsl:when test=".='Painting/Drawing/Etching/Other'">
                <dc:type>Image</dc:type>
            </xsl:when>
            <xsl:otherwise>
                <dc:type>
                    <xsl:value-of select="."/>
                </dc:type>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="mods:physicalDescription">
        <xsl:if test="mods:extent">
            <dc:format>
                <xsl:value-of select="mods:extent"/>
            </dc:format>
        </xsl:if>
        <xsl:if test="mods:form">
            <dc:subject>
                <xsl:value-of select="mods:form"/>
            </dc:subject>
        </xsl:if>
        <xsl:if test="mods:internetMediaType">
            <dc:format>
                <xsl:value-of select="mods:internetMediaType"/>
            </dc:format>
        </xsl:if>
    </xsl:template>
    <xsl:template match="mods:mimeType">
        <dc:format>
            <xsl:value-of select="."/>
        </dc:format>
    </xsl:template>
    <xsl:template match="mods:identifier">
        <xsl:variable name="type"
            select="translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
        <xsl:choose>
            <xsl:when test="contains ('isbn issn uri doi lccn uri', $type)">
                <dc:identifier>
                    <xsl:value-of select="$type"/>: <xsl:value-of select="."/>
                </dc:identifier>
            </xsl:when>
            <xsl:otherwise>
                <dc:identifier>
                    <xsl:value-of select="."/>
                </dc:identifier>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="mods:location">
        <dc:identifier>
            <xsl:for-each select="mods:url">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </dc:identifier>
    </xsl:template>
    <xsl:template match="mods:language">
        <dc:language>
            <xsl:value-of select="normalize-space(.)"/>
        </dc:language>
    </xsl:template>
    <xsl:template
        match="mods:relatedItem[mods:titleInfo | mods:name | mods:identifier | mods:location]">
        <xsl:choose>
            <xsl:when test="@type='original'">
                <dc:source>
                    <xsl:for-each
                        select="mods:titleInfo/mods:title | mods:identifier | mods:location/mods:url">
                        <xsl:if test="normalize-space(.)!= ''">
                            <xsl:value-of select="."/>
                            <xsl:if test="position()!=last()">--</xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </dc:source>
            </xsl:when>
            <xsl:when test="@type='series'"/>
            <xsl:otherwise>
                <dc:relation>
                    <xsl:for-each
                        select="mods:titleInfo/mods:title | mods:identifier | mods:location/mods:url">
                        <xsl:if test="normalize-space(.)!= ''">
                            <xsl:value-of select="."/>
                            <xsl:if test="position()!=last()">--</xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </dc:relation>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="mods:accessCondition">
        <dc:rights>
            <xsl:value-of select="."/>
        </dc:rights>
    </xsl:template>
    <xsl:template name="name">
        <xsl:variable name="name">
            <xsl:for-each select="mods:namePart[not(@type)]">
                <xsl:value-of select="."/>
                <xsl:text> </xsl:text>
            </xsl:for-each>
            <xsl:value-of select="mods:namePart[@type='family']"/>
            <xsl:if test="mods:namePart[@type='given']">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="mods:namePart[@type='given']"/>
            </xsl:if>
            <xsl:if test="mods:namePart[@type='date']">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="mods:namePart[@type='date']"/>
                <xsl:text/>
            </xsl:if>
            <xsl:if test="mods:displayForm">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="mods:displayForm"/>
                <xsl:text>) </xsl:text>
            </xsl:if>
            <xsl:for-each select="mods:role[mods:roleTerm[@type='text']!='creator']">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="normalize-space(.)"/>
                <xsl:text>) </xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="normalize-space($name)"/>
    </xsl:template>

    <xsl:template match="mods:temporal[@point='start']  ">
        <xsl:value-of select="."/>-<xsl:value-of select="../mods:temporal[@point='end']"/>
    </xsl:template>
    <xsl:template match="mods:temporal[@point!='start' and @point!='end']  ">
        <xsl:value-of select="."/>
    </xsl:template>
    <!-- suppress all else:-->
    <xsl:template match="*"/>


</xsl:stylesheet>
