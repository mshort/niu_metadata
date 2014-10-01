<?xml version="1.0" encoding="UTF-8"?>

<!-- XSL to correct Discovery Garden's transform of legacy history collections (Twain, Lincoln, Prairie, Gilded) into MODS -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:mods="http://www.loc.gov/mods/v3" version="3.0" xmlns:functx="http://www.functx.com"
    exclude-result-prefixes="xs functx">

    <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
    <xsl:strip-space elements="*"/>

    <!-- Special characters for string processing -->

    <xsl:variable name="apos">'</xsl:variable>
    <xsl:variable name="quote">"</xsl:variable>

    <xsl:variable name="in" select="('&lt;u&gt;','&lt;/u&gt;','&lt;br>','&lt;i>','&lt;/i>')"/>
    <xsl:variable name="out" select="('','',' ','')"/>

    <!-- These helper functions handle the multi-replace that strips the markup from publisher, note, title, etc. -->

    <xsl:function name="functx:if-absent" as="item()*">
        <xsl:param name="arg" as="item()*"/>
        <xsl:param name="value" as="item()*"/>

        <xsl:sequence
            select=" 
            if (exists($arg))
            then $arg
            else $value
            "
        />
    </xsl:function>

    <xsl:function name="functx:replace-multi" as="xs:string?">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="changeFrom" as="xs:string*"/>
        <xsl:param name="changeTo" as="xs:string*"/>

        <xsl:sequence
            select="if (count($changeFrom) > 0)
            then functx:replace-multi(
            replace($arg, $changeFrom[1],
            functx:if-absent($changeTo[1],'')),
            $changeFrom[position() > 1],
            $changeTo[position() > 1])
            else $arg"
        />
    </xsl:function>

    <!-- Identity template and prefix to create a copy of the source -->

    <xsl:template match="*">
        <xsl:element name="mods:{local-name()}" namespace="http://www.loc.gov/mods/v3">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- Basic wrapper -->

    <xsl:template match="mods:mods">
        <mods:mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.4"
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd">
            <mods:recordInfo>
                <mods:recordContentSource authority="oclcorg">JNA</mods:recordContentSource>
                <mods:languageOfCataloging>
                    <mods:languageTerm authority="iso639-2b" type="code">eng</mods:languageTerm>
                </mods:languageOfCataloging>
            </mods:recordInfo>
            <xsl:apply-templates/>
        </mods:mods>
    </xsl:template>

    <xsl:template match="mods:titleInfo/mods:title">
        <xsl:choose>
            <xsl:when test="(starts-with(.,'The '))">
                <mods:nonSort>The</mods:nonSort>
                <mods:title>
                    <xsl:value-of select="substring-after(.,'The ')"/>
                </mods:title>
            </xsl:when>
            <xsl:when test="(starts-with(.,'An'))">
                <mods:nonSort>An</mods:nonSort>
                <mods:title>
                    <xsl:value-of select="substring-after(.,'An ')"/>
                </mods:title>
            </xsl:when>
            <xsl:when test="(starts-with(.,'A'))">
                <mods:nonSort>A</mods:nonSort>
                <mods:title>
                    <xsl:value-of select="substring-after(.,'A ')"/>
                </mods:title>
            </xsl:when>
            <xsl:otherwise>
                <mods:title>
                    <xsl:value-of select="."/>
                </mods:title>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Strip out "unpublished" -->

    <xsl:template match="mods:originInfo[(mods:publisher='unpublished')]"/>

    <!-- Add keydate and remove markup in publisher. If the date is 'unknown,' then assume
    it is in the 18th century and mark as questionable. -->


    <!-- 10 January 1930 -->
    <xsl:template name="format_date">
        <xsl:param name="old_date"/>
        <xsl:variable name="mo">
            <xsl:value-of select="substring-before(substring-after($old_date,' '),' 1')"/>
        </xsl:variable>
        <xsl:variable name="day">
            <xsl:value-of select="substring-before($old_date,$mo)"/>
        </xsl:variable>
        <xsl:variable name="year">
            <xsl:value-of select="substring-after($old_date,$mo)"/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($year)"/>
        <xsl:value-of select="'-'"/>
        <xsl:choose>
            <xsl:when test="$mo = 'January'">01</xsl:when>
            <xsl:when test="$mo = 'February'">02</xsl:when>
            <xsl:when test="$mo = 'March'">03</xsl:when>
            <xsl:when test="$mo = 'April'">04</xsl:when>
            <xsl:when test="$mo = 'May'">05</xsl:when>
            <xsl:when test="$mo = 'June'">06</xsl:when>
            <xsl:when test="$mo = 'July'">07</xsl:when>
            <xsl:when test="$mo = 'August'">08</xsl:when>
            <xsl:when test="$mo = 'September'">09</xsl:when>
            <xsl:when test="$mo = 'October'">10</xsl:when>
            <xsl:when test="$mo = 'November'">11</xsl:when>
            <xsl:when test="$mo = 'December'">12</xsl:when>
        </xsl:choose>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="normalize-space($day)"/>
    </xsl:template>

    <!-- January 1930 -->
    <xsl:template name="format_date_simple">
        <xsl:param name="old_date"/>
        <xsl:variable name="mo">
            <xsl:value-of select="substring-before($old_date,' 1')"/>
        </xsl:variable>
        <xsl:variable name="year">
            <xsl:value-of select="substring-after($old_date,' ')"/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($year)"/>
        <xsl:value-of select="'-'"/>
        <xsl:choose>
            <xsl:when test="$mo = 'January'">01</xsl:when>
            <xsl:when test="$mo = 'February'">02</xsl:when>
            <xsl:when test="$mo = 'March'">03</xsl:when>
            <xsl:when test="$mo = 'April'">04</xsl:when>
            <xsl:when test="$mo = 'May'">05</xsl:when>
            <xsl:when test="$mo = 'June'">06</xsl:when>
            <xsl:when test="$mo = 'July'">07</xsl:when>
            <xsl:when test="$mo = 'August'">08</xsl:when>
            <xsl:when test="$mo = 'September'">09</xsl:when>
            <xsl:when test="$mo = 'October'">10</xsl:when>
            <xsl:when test="$mo = 'November'">11</xsl:when>
            <xsl:when test="$mo = 'December'">12</xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- January 13, 1930 -->
    <xsl:template name="format_date_complex">
        <xsl:param name="old_date"/>
        <xsl:variable name="mo">
            <xsl:value-of select="substring-before($old_date,' ')"/>
        </xsl:variable>
        <xsl:variable name="day">
            <xsl:value-of select="substring-after($old_date, ' ')"/>
        </xsl:variable>
        <xsl:variable name="year">
            <xsl:value-of select="substring-after($old_date,', ')"/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($year)"/>
        <xsl:value-of select="'-'"/>
        <xsl:choose>
            <xsl:when test="$mo = 'January'">01</xsl:when>
            <xsl:when test="$mo = 'February'">02</xsl:when>
            <xsl:when test="$mo = 'March'">03</xsl:when>
            <xsl:when test="$mo = 'April'">04</xsl:when>
            <xsl:when test="$mo = 'May'">05</xsl:when>
            <xsl:when test="$mo = 'June'">06</xsl:when>
            <xsl:when test="$mo = 'July'">07</xsl:when>
            <xsl:when test="$mo = 'August'">08</xsl:when>
            <xsl:when test="$mo = 'September'">09</xsl:when>
            <xsl:when test="$mo = 'October'">10</xsl:when>
            <xsl:when test="$mo = 'November'">11</xsl:when>
            <xsl:when test="$mo = 'December'">12</xsl:when>
        </xsl:choose>
        <xsl:value-of select="'-'"/>
        <xsl:value-of select="$day"/>
    </xsl:template>

    <xsl:template match="mods:originInfo">

        <mods:originInfo>
            <xsl:for-each select="mods:dateIssued">
                <xsl:choose>
                    <xsl:when test="(.='unknown') or (.='Date unknown') or (.='9999')">
                        <mods:dateIssued encoding="iso8601" keyDate="yes" qualifier="questionable"
                            >18</mods:dateIssued>
                    </xsl:when>

                    <!-- January 1930 -->
                    <!-- January, 1930 -->
                    <!-- January, 1930. -->
                    <!-- January 1930. -->
                    <xsl:when
                        test="matches(.,'^(January|February|March|April|May|June|July|August|September|October|November|December)(,)*?\W(\d{4})(\.)*')">
                        <dateOther encoding="w3cdtf" keyDate="yes">
                            <xsl:call-template name="format_date_simple">
                                <xsl:with-param name="old_date" select="."/>
                            </xsl:call-template>
                        </dateOther>
                    </xsl:when>

                    <!-- January 13, 1930 -->
                    <xsl:when
                        test="matches(.,'^(January|February|March|April|May|June|July|August|September|October|November|December)\W[0-9]+,\W\d{4}')">
                        <dateOther encoding="w3cdtf" keyDate="yes">
                            <xsl:call-template name="format_date_complex">
                                <xsl:with-param name="old_date" select="."/>
                            </xsl:call-template>
                        </dateOther>
                    </xsl:when>

                    <!-- 10 January 1930 -->
                    <!-- 1 January 1930 -->
                    <xsl:when
                        test="matches(., '(\d)*?\d\W(January|February|March|April|May|June|July|August|September|October|November|December)\W(\d{4})')">
                        <dateOther encoding="w3cdtf" keyDate="yes">
                            <xsl:call-template name="format_date">
                                <xsl:with-param name="old_date" select="."/>
                            </xsl:call-template>
                        </dateOther>
                    </xsl:when>

                    <!-- 1930-1935 -->
                    <!-- ca. 1930-1935 -->
                    <!-- 1930 - 1935 -->
                    <xsl:when test="matches(.,'^(ca.\W)*?(\d{4})(\W)*?-(\W)*?(\d{4})')">
                        <dateOther encoding="w3cdtf" keyDate="yes" point="start"
                            qualifier="approximate">
                            <xsl:value-of select="substring-before(.,'-')"/>
                        </dateOther>
                        <dateOther encoding="w3cdtf" keyDate="yes" point="end"
                            qualifier="approximate">
                            <xsl:value-of select="substring-after(.,'-')"/>
                        </dateOther>
                    </xsl:when>

                    <!-- ca. 1855 -->

                    <xsl:when test="matches(.,'^(ca.)\W(\d{4})')">
                        <dateOther encoding="w3cdtf" keyDate="yes" qualifier="approximate">
                            <xsl:value-of select="substring-after(.,' ')"/>
                        </dateOther>
                    </xsl:when>

                    <xsl:when test="(.='1846, 1847, 1848') or (.='1846,1847,1848')">
                        <mods:dateIssued encoding="w3cdtf" keyDate="yes" point="start"
                            qualifier="approximate">1846</mods:dateIssued>
                        <mods:dateIssued encoding="w3cdtf" point="end" qualifier="approximate"
                            >1848</mods:dateIssued>
                    </xsl:when>

                    <xsl:otherwise>
                        <mods:dateIssued encoding="w3cdtf" keyDate="yes">
                            <xsl:value-of select="."/>
                        </mods:dateIssued>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <!-- If the publisher contains <u> mark-up, we can assume that it is a bibliographic reference. -->

            <xsl:for-each select="mods:publisher">
                <xsl:if test="not(contains(.,'&lt;'))">
                    <xsl:if test="contains(.,', ')">
                        <mods:publisher>
                            <xsl:value-of select="substring-before(.,',')"/>
                        </mods:publisher>
                    </xsl:if>
                    <xsl:if test="not(contains(.,', '))">
                        <mods:publisher>
                            <xsl:value-of select="."/>
                        </mods:publisher>
                    </xsl:if>
                </xsl:if>

                <!-- Matches strings with subtitles -->

                <xsl:if test="matches(.,'&lt;u&gt;[A-Z].*?:.*&lt;/u&gt;')">
                    <mods:place>
                        <mods:placeTerm type="text">
                            <xsl:value-of
                                select="substring-before(substring-after(.,'&lt;/u&gt;. '),':')"/>
                        </mods:placeTerm>
                    </mods:place>
                    <mods:publisher>
                        <xsl:value-of
                            select="substring-before(substring-after(substring-after(functx:replace-multi(.,$in,''),': '),': '),', 1')"
                        />
                    </mods:publisher>
                </xsl:if>

                <!-- Matches strings without subtitles -->

                <xsl:if test="matches(.,'&lt;u&gt;[^:]*&lt;/u&gt;')">
                    <mods:place>
                        <mods:placeTerm type="text">
                            <xsl:if test="contains(.,'&lt;br>')">
                                <xsl:value-of
                                    select="substring-before(substring-after(.,'&lt;/u&gt;.&lt;br>'),':')"
                                />
                            </xsl:if>
                            <xsl:if test="not(contains(.,'&lt;br>'))">
                                <xsl:value-of
                                    select="substring-before(substring-after(.,'&lt;/u&gt;. '),':')"
                                />
                            </xsl:if>
                        </mods:placeTerm>
                    </mods:place>
                    <mods:publisher>
                        <xsl:value-of
                            select="substring-before(substring-after(functx:replace-multi(.,$in,''),': '),', 1')"
                        />
                    </mods:publisher>
                </xsl:if>
            </xsl:for-each>
        </mods:originInfo>

        <!-- every mods:publisher is stripped of its markup and sent to a source note -->

        <xsl:for-each select="mods:publisher">

            <xsl:if test="contains(.,'&lt;u&gt;')">

                <mods:note type="source note">
                    <xsl:value-of select="functx:replace-multi(.,$in, $out)"/>
                </mods:note>
            </xsl:if>
        </xsl:for-each>

    </xsl:template>

    <xsl:template match="mods:note[.='no theme']"/>

    <!-- How should we handle links in notes? -->

    <xsl:template match="mods:note">

        <xsl:for-each select=".">
            <mods:note>
                <xsl:value-of select="functx:replace-multi(.,$in, $out)"/>
            </mods:note>
        </xsl:for-each>
    </xsl:template>

    <!-- We don't want unknown, so match and ignore. -->

    <xsl:template
        match="mods:name[(mods:namePart='unknown') or (mods:namePart='Unknown') or (mods:namePart='Anonymous') or (mods:namePart='Creator unknown') or (mods:namePart='Author unknown') or (mods:namePart='UNKNOWN')]"/>

    <!-- Name -->

    <xsl:template match="mods:name">
        <xsl:for-each select=".">
            <xsl:choose>
                <xsl:when test="mods:description='m'">
                    <mods:name>
                        <mods:namePart>
                            <xsl:value-of select="mods:namePart"/>
                        </mods:namePart>
                        <mods:role>
                            <mods:roleTerm>
                                <xsl:value-of select="mods:role/mods:roleTerm"/>
                            </mods:roleTerm>
                        </mods:role>
                        <mods:description>male</mods:description>
                    </mods:name>
                </xsl:when>

                <xsl:when test="mods:description='f'">
                    <mods:name>
                        <mods:namePart>
                            <xsl:value-of select="mods:namePart"/>
                        </mods:namePart>
                        <mods:role>
                            <mods:roleTerm>
                                <xsl:value-of select="mods:role/mods:roleTerm"/>
                            </mods:roleTerm>
                        </mods:role>
                        <mods:description>female</mods:description>
                    </mods:name>
                </xsl:when>
                <xsl:otherwise>
                    <mods:name>
                        <mods:namePart>
                            <xsl:value-of select="mods:namePart"/>
                        </mods:namePart>
                        <mods:role>
                            <mods:roleTerm>
                                <xsl:value-of select="mods:role/mods:roleTerm"/>
                            </mods:roleTerm>
                        </mods:role>
                    </mods:name>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="mods:accessCondition[.='unknown']"/>

    <xsl:template match="mods:accessCondition">
        <xsl:choose>
            <xsl:when
                test="(.='public domain') or (.='Public Domain') or (.='Public domain') or contains(.,'public domain')">
                <mods:accessCondition type="useAndReproduction">Use of this public-domain resource
                    is unrestricted.</mods:accessCondition>
            </xsl:when>
            <xsl:otherwise>
                <mods:note type="ownership">
                    <xsl:value-of select="."/>
                </mods:note>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Genre -->

    <xsl:template match="mods:genre">
        <xsl:if test=".='advertisement'">
            <mods:genre authority="aat">advertisements</mods:genre>
        </xsl:if>

        <xsl:if test=".='advice literature'">
            <mods:genre authority="aat">advice literature</mods:genre>
        </xsl:if>

        <xsl:if test=".='announcement'">
            <mods:genre authority="aat">announcements</mods:genre>
        </xsl:if>

        <xsl:if test="(.='article') or (.='aricle') or (.='article;') or (.='articles')">
            <mods:genre authority="aat">articles</mods:genre>
        </xsl:if>

        <xsl:if test=".='autobiography'">
            <mods:genre authority="aat">autobiographies</mods:genre>
        </xsl:if>

        <xsl:if test=".='bibliography'">
            <mods:genre authority="aat">bibliographies</mods:genre>
        </xsl:if>

        <xsl:if test=".='biography'">
            <mods:genre authority="aat">biographies (documents)</mods:genre>
        </xsl:if>

        <xsl:if test=".='catalogue'">
            <mods:genre authority="aat">exhibition catalogs</mods:genre>
        </xsl:if>

        <xsl:if test=".='diaries'">
            <mods:genre authority="aat">diaries</mods:genre>
        </xsl:if>

        <xsl:if test="(.='essay') or (.='esssy')">
            <mods:genre authority="aat">essays</mods:genre>
        </xsl:if>

        <xsl:if test=".='fiction'">
            <mods:genre authority="aat">fiction</mods:genre>
        </xsl:if>

        <xsl:if test=".='advertisement'">
            <mods:genre authority="lcsh">government publications</mods:genre>
        </xsl:if>

        <xsl:if test=".='guidebook'">
            <mods:genre authority="aat">guidebooks</mods:genre>
        </xsl:if>

        <xsl:if test=".='history'">
            <mods:genre authority="local">history</mods:genre>
        </xsl:if>

        <xsl:if test=".='interview'">
            <mods:genre authority="aat">interviews</mods:genre>
        </xsl:if>

        <xsl:if test=".='letter'">
            <mods:genre authority="aat">letters (correspondence)</mods:genre>
        </xsl:if>

        <xsl:if test=".='memoir'">
            <mods:genre authority="aat">memoirs</mods:genre>
        </xsl:if>

        <xsl:if test="(.='narrative') or (.='Narrative')">
            <mods:genre authority="aat">guidebooks</mods:genre>
        </xsl:if>

        <xsl:if test=".='obituary'">
            <mods:genre authority="aat">obituaries</mods:genre>
        </xsl:if>

        <xsl:if test=".='pamphlet'">
            <mods:genre authority="aat">pamphlets</mods:genre>
        </xsl:if>

        <xsl:if test=".='play'">
            <mods:genre authority="aat">plays (document genre)</mods:genre>
        </xsl:if>

        <xsl:if test=".='poetry'">
            <mods:genre authority="aat">poetry</mods:genre>
        </xsl:if>

        <xsl:if test=".='proceedings'">
            <mods:genre authority="aat">proceedings</mods:genre>
        </xsl:if>

        <xsl:if test=".='report'">
            <mods:genre authority="aat">reports</mods:genre>
        </xsl:if>

        <xsl:if test=".='sermon'">
            <mods:genre authority="aat">sermons</mods:genre>
        </xsl:if>

        <xsl:if test=".='speech'">
            <mods:genre authority="aat">speeches</mods:genre>
        </xsl:if>

        <xsl:if test=".='song'">
            <mods:genre authority="aat">songs (document genre)</mods:genre>
        </xsl:if>
    </xsl:template>

    <!-- TypeofResource -->

    <xsl:template match="mods:typeOfResource">

        <xsl:if test=".='Painting/Drawing/Etching/Other'">
            <mods:typeOfResource>still image</mods:typeOfResource>
            <mods:genre authority="aat">pictures (two-dimensional representations)</mods:genre>
            <mods:physicalDescription>
                <mods:internetMediaType>image/jpeg</mods:internetMediaType>
                <mods:internetMediaType>image/jp2</mods:internetMediaType>
                <mods:internetMediaType>image/tiff</mods:internetMediaType>
                <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
            </mods:physicalDescription>
        </xsl:if>

        <xsl:if test=".='Photograph'">
            <mods:typeOfResource>still image</mods:typeOfResource>
            <mods:genre authority="aat">photographs</mods:genre>
            <mods:physicalDescription>
                <mods:internetMediaType>image/jpeg</mods:internetMediaType>
                <mods:internetMediaType>image/jp2</mods:internetMediaType>
                <mods:internetMediaType>image/tiff</mods:internetMediaType>
                <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
            </mods:physicalDescription>
        </xsl:if>

        <xsl:if test=".='Song'">
            <mods:typeOfResource>notated music</mods:typeOfResource>
            <mods:genre authority="aat">sheet music</mods:genre>
            <mods:physicalDescription>
                <mods:internetMediaType>image/jpeg</mods:internetMediaType>
                <mods:internetMediaType>image/jp2</mods:internetMediaType>
                <mods:internetMediaType>image/tiff</mods:internetMediaType>
                <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
            </mods:physicalDescription>
        </xsl:if>

        <xsl:if test=".='Manuscript/Document'">
            <mods:typeOfResource manuscript="yes">mixed material</mods:typeOfResource>
            <mods:genre authority="aat">manuscripts (document genre)</mods:genre>
            <mods:physicalDescription>
                <mods:internetMediaType>image/jpeg</mods:internetMediaType>
                <mods:internetMediaType>image/jp2</mods:internetMediaType>
                <mods:internetMediaType>image/tiff</mods:internetMediaType>
                <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
            </mods:physicalDescription>
        </xsl:if>

        <xsl:if test=".='Map'">
            <mods:typeOfResource>cartographic</mods:typeOfResource>
            <mods:genre authority="aat">maps</mods:genre>
            <mods:physicalDescription>
                <mods:internetMediaType>image/jpeg</mods:internetMediaType>
                <mods:internetMediaType>image/jp2</mods:internetMediaType>
                <mods:internetMediaType>image/tiff</mods:internetMediaType>
                <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
            </mods:physicalDescription>
        </xsl:if>

        <xsl:if test=".='Ad/Poster'">
            <mods:typeOfResource>still image</mods:typeOfResource>
            <mods:genre authority="aat">advertisements</mods:genre>
            <mods:physicalDescription>
                <mods:internetMediaType>image/jpeg</mods:internetMediaType>
                <mods:internetMediaType>image/jp2</mods:internetMediaType>
                <mods:internetMediaType>image/tiff</mods:internetMediaType>
                <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
            </mods:physicalDescription>
        </xsl:if>

        <xsl:if test=".='Cartoon'">
            <mods:typeOfResource>still image</mods:typeOfResource>
            <mods:genre authority="aat">political cartoons</mods:genre>
            <mods:physicalDescription>
                <mods:internetMediaType>image/jpeg</mods:internetMediaType>
                <mods:internetMediaType>image/jp2</mods:internetMediaType>
                <mods:internetMediaType>image/tiff</mods:internetMediaType>
                <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
            </mods:physicalDescription>
        </xsl:if>

        <xsl:if test=".='book'">
            <mods:genre authority="aat">books</mods:genre>
        </xsl:if>

        <xsl:if test=".='sheet music'">
            <mods:genre authority="aat">sheet music</mods:genre>
        </xsl:if>

        <xsl:if test=".='newspaper'">
            <mods:genre authority="aat">clippings (information artifacts)</mods:genre>
        </xsl:if>

        <xsl:if test="(.='journal') or (.='article')">
            <mods:genre authority="aat">articles</mods:genre>
        </xsl:if>

        <xsl:if test="(.='photograph') or (.='Photograph')">
            <mods:genre authority="aat">photographs</mods:genre>
        </xsl:if>

        <xsl:if test=".='manuscript'">
            <mods:typeOfResource manuscript="yes">mixed material</mods:typeOfResource>
            <mods:genre authority="aat">manuscripts (document genre)</mods:genre>
        </xsl:if>

    </xsl:template>

    <!-- Remove invalid physicalDescription/form/type -->


    <xsl:template match="mods:physicalDescription">

        <xsl:if test="mods:form/mods:type='People'">
            <mods:subject authority="local">
                <mods:topic>people</mods:topic>
            </mods:subject>
        </xsl:if>

        <xsl:if test="mods:form/mods:type='Place'">
            <mods:subject authority="local">
                <mods:topic>place</mods:topic>
            </mods:subject>
        </xsl:if>

        <xsl:if test="mods:form/mods:type='Equipment'">
            <mods:subject authority="local">
                <mods:topic>equipment</mods:topic>
            </mods:subject>
        </xsl:if>

        <xsl:if test="mods:form/mods:type='text'">
            <mods:typeOfResource>text</mods:typeOfResource>
            <mods:physicalDescription>
                <mods:internetMediaType>text/html</mods:internetMediaType>
                <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
            </mods:physicalDescription>
        </xsl:if>

        <xsl:if test="mods:form/mods:type='image'">
            <mods:typeOfResource>still image</mods:typeOfResource>
            <mods:physicalDescription>
                <mods:internetMediaType>image/jpeg</mods:internetMediaType>
                <mods:internetMediaType>image/jp2</mods:internetMediaType>
                <mods:internetMediaType>image/tiff</mods:internetMediaType>
                <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
            </mods:physicalDescription>
        </xsl:if>

        <xsl:if test="mods:form/mods:type='sound'">
            <mods:typeOfResource>sound recording-musical</mods:typeOfResource>
            <mods:physicalDescription>
                <mods:internetMediaType>audio/vnd.rn-realaudio</mods:internetMediaType>
                <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
            </mods:physicalDescription>
        </xsl:if>

        <xsl:if test="mods:form/mods:type='video'">
            <mods:typeOfResource>moving image</mods:typeOfResource>
            <mods:physicalDescription>
                <mods:internetMediaType>video/vnd.rn-realvideo</mods:internetMediaType>
                <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
            </mods:physicalDescription>
        </xsl:if>

    </xsl:template>

    <!-- Subjects -->

    <xsl:template match="mods:subject">
        <xsl:for-each select="mods:topic | mods:temporal">
            <mods:subject authority="local">
                <mods:topic>
                    <xsl:value-of select="."/>
                </mods:topic>
            </mods:subject>
        </xsl:for-each>

        <xsl:if test="mods:temporal='Lincoln'">
            <mods:location>
                <mods:url usage="primary display" access="object in context"
                    >http://lincoln.lib.niu.edu/object/[[pid]]</mods:url>
            </mods:location>
            <mods:subject>
                <mods:temporal encoding="w3cdtf" point="start">1818</mods:temporal>
                <mods:temporal encoding="w3cdtf" point="end">1860</mods:temporal>
            </mods:subject>
            <mods:relatedItem type="host">
                <mods:typeOfResource collection="yes"/>
                <mods:titleInfo>
                    <mods:title>Abraham Lincoln historical digitization project</mods:title>
                </mods:titleInfo>
                <mods:location>
                    <mods:url>http://lincoln.lib.niu.edu/</mods:url>
                </mods:location>
            </mods:relatedItem>
        </xsl:if>

        <xsl:if test="mods:temporal='Prairie' or mods:temporal='Prarie'">
            <mods:location>
                <mods:url usage="primary display" access="object in context"
                    >http://prairiefire.lib.niu.edu/object/[[pid]]</mods:url>
            </mods:location>
            <mods:subject>
                <mods:temporal encoding="w3cdtf" point="start">1673</mods:temporal>
                <mods:temporal encoding="w3cdtf" point="end">1818</mods:temporal>
            </mods:subject>
            <mods:relatedItem type="host">
                <mods:typeOfResource collection="yes"/>
                <mods:titleInfo>
                    <mods:title>Prairie Fire</mods:title>
                    <mods:subTitle>the Illinois country, 1673-1818</mods:subTitle>
                </mods:titleInfo>
                <mods:location>
                    <mods:url>http://prairiefire.lib.niu.edu/</mods:url>
                </mods:location>
            </mods:relatedItem>
        </xsl:if>

        <xsl:if test="mods:temporal='Civil' or mods:temporal='Cvil'">
            <mods:location>
                <mods:url usage="primary display" access="object in context"
                    >http://civilwar.lib.niu.edu/object/[[pid]]</mods:url>
            </mods:location>
            <mods:subject>
                <mods:temporal encoding="w3cdtf" point="start">1861</mods:temporal>
                <mods:temporal encoding="w3cdtf" point="end">1865</mods:temporal>
            </mods:subject>
            <mods:relatedItem type="host">
                <mods:typeOfResource collection="yes"/>
                <mods:titleInfo>
                    <mods:title>Illinois during the Civil War, 1861-1865</mods:title>
                </mods:titleInfo>
                <mods:location>
                    <mods:url>http://civilwar.lib.niu.edu/</mods:url>
                </mods:location>
            </mods:relatedItem>
        </xsl:if>

        <xsl:if
            test="mods:temporal='GildedAge' or mods:temporal='Gilded' or mods:temporal='Guilded'">
            <mods:location>
                <mods:url usage="primary display" access="object in context"
                    >http://gildedage.lib.niu.edu/object/[[pid]]</mods:url>
            </mods:location>
            <mods:subject>
                <mods:temporal encoding="w3cdtf" point="start">1866</mods:temporal>
                <mods:temporal encoding="w3cdtf" point="end">1896</mods:temporal>
            </mods:subject>
            <mods:relatedItem type="host">
                <mods:typeOfResource collection="yes"/>
                <mods:titleInfo>
                    <mods:title>Illinois during the Gilded Age</mods:title>
                </mods:titleInfo>
                <mods:location>
                    <mods:url>http://gildedage.lib.niu.edu/</mods:url>
                </mods:location>
            </mods:relatedItem>
        </xsl:if>

        <xsl:if test="mods:temporal='Twain' or mods:temporal='Twian'">
            <mods:location>
                <mods:url usage="primary display" access="object in context"
                    >http://twain.lib.niu.edu/object/[[pid]]</mods:url>
            </mods:location>
            <mods:subject>
                <mods:temporal encoding="w3cdtf" point="start">1835</mods:temporal>
                <mods:temporal encoding="w3cdtf" point="end">1910</mods:temporal>
            </mods:subject>
            <mods:relatedItem type="host">
                <mods:typeOfResource collection="yes"/>
                <mods:titleInfo>
                    <mods:title>Mark Twain's Mississippi</mods:title>
                </mods:titleInfo>
                <mods:location>
                    <mods:url>http://twain.lib.niu.edu/</mods:url>
                </mods:location>
            </mods:relatedItem>
        </xsl:if>

        <xsl:if test="(mods:temporal='Message') or (mods:temporal='Progressive')">
            <mods:subject authority="local">
                <mods:topic>Message</mods:topic>
            </mods:subject>
        </xsl:if>


        <xsl:if test="mods:topic=concat('1893 Chicago',$apos,'s World Fair')">
            <mods:subject authority="lcsh">
                <mods:topic>World's Columbian Exposition (1893 : Chicago, Ill.)</mods:topic>
            </mods:subject>
        </xsl:if>

        <xsl:if test="mods:topic='Black Hawk War'">
            <mods:subject authority="lcsh">
                <mods:topic>Black Hawk War, 1832</mods:topic>
            </mods:subject>
        </xsl:if>

        <xsl:if test="mods:topic='Haymarket'">
            <mods:subject authority="lcsh">
                <mods:topic>Haymarket Square Riot, Chicago, Ill., 1886</mods:topic>
            </mods:subject>
        </xsl:if>

        <xsl:if test="mods:topic='Campaign of 1858'">
            <mods:subject authority="lcsh">
                <mods:geographic>United States</mods:geographic>
                <mods:topic>Politics and government </mods:topic>
                <mods:temporal>1857-1861</mods:temporal>
            </mods:subject>
            <mods:subject authority="lcsh">
                <mods:topic>Political campaigns</mods:topic>
                <mods:geographic>United States</mods:geographic>
                <mods:topic>History</mods:topic>
            </mods:subject>
        </xsl:if>

        <xsl:if test="mods:topic='Chicago Fire'">
            <mods:subject authority="lcsh">
                <mods:topic>Great Fire, Chicago, Ill., 1871</mods:topic>
            </mods:subject>
        </xsl:if>

        <xsl:if test="mods:topic='Civil War (Twain)'">
            <mods:subject authority="lcsh">
                <mods:geographic>United States</mods:geographic>
                <mods:topic>History</mods:topic>
                <temporal>Civil War, 1861-1865</temporal>
            </mods:subject>
        </xsl:if>

        <xsl:if test="mods:topic='Mexican War'">
            <mods:subject authority="lcsh">
                <mods:topic>Mexican War, 1846-1848</mods:topic>
            </mods:subject>
        </xsl:if>


        <xsl:if test="mods:topic='Pullman'">
            <mods:subject authority="lcsh">
                <mods:topic>Pullman Strike, 1894</mods:topic>
            </mods:subject>
            <mods:subject authority="lcsh">
                <mods:topic>Strikes and lockouts</mods:topic>
                <mods:topic>Railroads</mods:topic>
                <mods:geographic>United States</mods:geographic>
            </mods:subject>
        </xsl:if>

        <xsl:if test="mods:topic='Populism'">
            <mods:subject authority="lcsh">
                <mods:topic>Populism</mods:topic>
                <mods:geographic>United States</mods:geographic>
            </mods:subject>
            <mods:subject authority="lcsh">
                <mods:topic>Populist Party (U.S.)</mods:topic>
            </mods:subject>
        </xsl:if>

        <xsl:if test="mods:topic='Presidential Campaigns'">
            <mods:subject authority="lcsh">
                <mods:topic>Presidents</mods:topic>
                <mods:geographic>United States</mods:geographic>
                <mods:topic>History</mods:topic>
            </mods:subject>
            <mods:subject authority="lcsh">
                <mods:topic>Political campaigns</mods:topic>
                <mods:geographic>United States</mods:geographic>
                <mods:topic>History</mods:topic>
            </mods:subject>
            <mods:subject authority="lcsh">
                <mods:topic>Presidential candidates</mods:topic>
                <mods:geographic>United States</mods:geographic>
                <mods:topic>History</mods:topic>
            </mods:subject>
            <mods:subject authority="lcsh">
                <mods:geographic>United States</mods:geographic>
                <mods:topic>Politics and government</mods:topic>
                <mods:topic>History</mods:topic>
            </mods:subject>
        </xsl:if>

        <xsl:if test="mods:topic='DeKalb'">
            <mods:subject authority="lcsh">
                <mods:geographic>De Kalb (Ill. : Township)</mods:geographic>
            </mods:subject>
        </xsl:if>

        <xsl:if test="mods:topic='Transportation'">
            <mods:subject authority="lcsh">
                <mods:topic>Transportation</mods:topic>
                <mods:geographic>United States</mods:geographic>
                <mods:topic>History</mods:topic>
                <mods:temporal>19th century</mods:temporal>
            </mods:subject>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
