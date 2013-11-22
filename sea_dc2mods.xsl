<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.loc.gov/mods/v3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="oai_dc dc"
    version="2.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <xsl:variable name="apos">'</xsl:variable>
    <xsl:template match="*[not(node())]"/>
    <!-- strip empty DC elements that are output by tools like ContentDM -->
    <xsl:template match="/">
        <xsl:if test="oai_dc:dc">
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="oai_dc:dc">
        <mods version="3.4" xmlns="http://www.loc.gov/mods/v3"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd">
            <xsl:call-template name="dcMain"/>
        </mods>
    </xsl:template>
    <xsl:template name="dcMain">
        <xsl:for-each select="dc:title">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:for-each select="dc:creator">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:for-each select="dc:contributor">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:for-each select="dc:type">
            <xsl:choose>
                <xsl:when test="contains(text(), 'Collection') or contains(text(), 'collection')">
                    <genre authority="dct">
                        <xsl:text>collection</xsl:text>
                    </genre>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="dc:subject | dc:coverage">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:for-each select="dc:description">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:for-each select="dc:date">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:for-each select="dc:identifier">
            <xsl:choose>
                <xsl:when test="starts-with(text(), 'http://')">
                    <location>
                        <url>
                            <xsl:value-of select="."/>
                        </url>
                    </location>
                    <xsl:apply-templates select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="dc:source | dc:relation">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:for-each select="dc:language">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:for-each select="dc:rights">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="dc:title">
        <xsl:choose>
            <xsl:when test="(starts-with(.,'The '))">
                <titleInfo>
                    <nonSort>The</nonSort>
                    <title>
                        <xsl:value-of select="substring-after(.,'The ')"/>
                    </title>
                </titleInfo>
            </xsl:when>
            <xsl:when test="(starts-with(.,'An '))">
                <titleInfo>
                    <nonSort>An</nonSort>
                    <title>
                        <xsl:value-of select="substring-after(.,'An ')"/>
                    </title>
                </titleInfo>
            </xsl:when>
            <xsl:when test="(starts-with(.,'A '))">
                <titleInfo>
                    <nonSort>A</nonSort>
                    <title>
                        <xsl:value-of select="substring-after(.,'A ')"/>
                    </title>
                </titleInfo>
            </xsl:when>
            <xsl:otherwise>
                <titleInfo>
                    <title>
                        <xsl:value-of select="."/>
                    </title>
                </titleInfo>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="dc:creator">
        <xsl:choose>
            <xsl:when
                test="(string(text()) = 'Anonymous') or (string(text()) = 'unknown') or (string(text()) = 'Unknown')">
                <xsl:apply-templates
                    select="*[(. != 'Anonymous') or (. != 'unknown') or (. != 'Unknown')]"/>
            </xsl:when>
            <xsl:when test="string(text()) = 'Ebihara, May Mayko'">
                <name type="personal" authority="naf">
                    <namePart>
                        <xsl:text>Ebihara, May</xsl:text>
                    </namePart>
                    <role>
                        <roleTerm type="text">
                            <xsl:text>photographer</xsl:text>
                        </roleTerm>
                    </role>
                </name>
            </xsl:when>
            <xsl:when test="string(text()) = 'Palgen-Maisonneuve, Mimi'">
                <name type="personal" authority="naf">
                    <namePart>
                        <xsl:text>Palgen-Maisonneuve, Mimi</xsl:text>
                    </namePart>
                    <namePart type="date">
                        <xsl:text>1918-1995</xsl:text>
                    </namePart>
                    <role>
                        <roleTerm type="text">
                            <xsl:text>photographer</xsl:text>
                        </roleTerm>
                    </role>
                </name>
            </xsl:when>
            <xsl:when test="string(text()) = 'Medalle, Galileo N.'">
                <name type="personal" authority="local">
                    <namePart>
                        <xsl:text>Medalle, Galileo</xsl:text>
                    </namePart>
                    <role>
                        <roleTerm type="text">
                            <xsl:text>photographer</xsl:text>
                        </roleTerm>
                    </role>
                </name>
            </xsl:when>
            <xsl:when test="string(text()) = 'Temple, Richard Carnac, Sir'">
                <name type="personal" authority="local">
                    <namePart>
                        <xsl:text>Temple, Richard Carnac</xsl:text>
                    </namePart>
                    <namePart type="termsOfAddress">
                        <xsl:text>Sir</xsl:text>
                    </namePart>
                    <namePart type="date">
                        <xsl:text>1850-1931</xsl:text>
                    </namePart>
                    <role>
                        <roleTerm type="text">
                            <xsl:text>author</xsl:text>
                        </roleTerm>
                    </role>
                </name>
            </xsl:when>
            <xsl:when test="string(text()) = 'Cuenco, Jose Ma.'">
                <name type="personal" authority="local">
                    <namePart>
                        <xsl:text>Cuenco, José Maria</xsl:text>
                    </namePart>
                    <role>
                        <roleTerm type="text">
                            <xsl:text>photographer</xsl:text>
                        </roleTerm>
                    </role>
                </name>
            </xsl:when>
            <xsl:when test="string(text()) = 'Vietnam Fine Arts Association of HoChiMinhCity'">
                <name type="corporate" authority="naf" lang="vie">
                    <namePart>
                        <xsl:text>Hôi mỹ thuât Viêt Nam</xsl:text>
                    </namePart>
                    <role>
                        <roleTerm type="text">
                            <xsl:text>creator</xsl:text>
                        </roleTerm>
                    </role>
                </name>
            </xsl:when>
            <xsl:when test="string(text()) = 'Goertz, Fr. Joseph'">
                <name type="personal" authority="naf">
                    <namePart>
                        <xsl:text>Goertz, Franz-Josef</xsl:text>
                    </namePart>
                    <namePart type="date">
                        <xsl:text>1942-</xsl:text>
                    </namePart>
                    <role>
                        <roleTerm type="text">
                            <xsl:text>creator</xsl:text>
                        </roleTerm>
                    </role>
                </name>
            </xsl:when>
            <xsl:when test="string(text()) = 'Martinez, Jose'">
                <name type="personal" authority="local">
                    <namePart>
                        <xsl:text>Martinez, Jose</xsl:text>
                    </namePart>
                    <role>
                        <roleTerm type="text">
                            <xsl:text>creator</xsl:text>
                        </roleTerm>
                    </role>
                </name>
            </xsl:when>
            <xsl:otherwise>
                <name>
                    <namePart>
                        <xsl:apply-templates/>
                    </namePart>
                    <role>
                        <roleTerm type="text">
                            <xsl:text>creator</xsl:text>
                        </roleTerm>
                    </role>
                </name>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="dc:subject">
        <xsl:choose>
            <xsl:when test="string(text()) = 'Vientiane'">
                <subject authority="lcsh">
                    <geographic>
                        <xsl:text>Viangchan (Laos)</xsl:text>
                    </geographic>
                </subject>
                <subject authority="local">
                    <!-- Included for example. Do we want to keep local terms? -->
                    <topic>
                        <xsl:text>Vientiane</xsl:text>
                    </topic>
                </subject>
            </xsl:when>
            <xsl:when test="string(text()) = 'Hindu'">
                <subject authority="lcsh">
                    <topic>
                        <xsl:text>Hindu architecture</xsl:text>
                    </topic>
                </subject>
            </xsl:when>
            <xsl:when test="string(text()) = 'Mount Meru'">
                <subject authority="local">
                    <geographic>
                        <xsl:text>Mount Meru</xsl:text>
                    </geographic>
                </subject>
            </xsl:when>
            <xsl:when test="string(text()) = 'Jayavarman VII'">
                <subject authority="lcsh">
                    <name type="personal" authority="naf">
                        <namePart>Jăyvarmăn</namePart>
                        <namePart type="termsOfAddress">VII</namePart>
                        <namePart type="termsOfAddress">King of Cambodia</namePart>
                        <namePart type="date">approximately 1120-approximately 1215</namePart>
                    </name>
                </subject>
            </xsl:when>
            <xsl:when test="string(text()) = 'temple'">
                <subject authority="lcsh">
                    <topic>
                        <xsl:text>Temples</xsl:text>
                    </topic>
                </subject>
            </xsl:when>
            <xsl:otherwise>
                <subject authority="local">
                    <topic>
                        <xsl:value-of select="."/>
                    </topic>
                </subject>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="dc:description">
        <!--<abstract>
            <xsl:apply-templates/>
        </abstract>-->
        <xsl:choose>
            <xsl:when
                test="string(text()) = 'This item digitized and made available online with funds provided by United States Department of Education, TICFIA (Technological Innovation and Cooperation for Foreign Information) Grant P337A05006.'">
                <note type="funding">
                    <xsl:apply-templates/>
                </note>
            </xsl:when>
            <xsl:when
                test="string(text()) = 'This item digitized and made available online with funds provided by United States Department of Education, TICFIA (Technological Innovation and Cooperation for Foreign Information) Grant P337A090018.'">
                <note type="funding">
                    <xsl:apply-templates/>
                </note>
            </xsl:when>
            <xsl:when test="string(text()) = 'Location : Siem Reap.'">
                <subject authority="lcsh">
                    <geographic>
                        <xsl:text>Siem Reap (Cambodia)</xsl:text>
                    </geographic>
                </subject>
            </xsl:when>
            <xsl:when test="string(text()) = 'Location : Phnom Penh.'">
                <subject authority="lcsh">
                    <geographic>
                        <xsl:text>Phnom Penh (Cambodia)</xsl:text>
                    </geographic>
                </subject>
            </xsl:when>
            <xsl:when test="string(text()) = 'Location : Kampong Speu Province.'">
                <subject authority="lcsh">
                    <geographic>
                        <xsl:text>Kâmpóng Spœ (Cambodia : Province)</xsl:text>
                    </geographic>
                </subject>
            </xsl:when>
            <xsl:when test="string(text()) = 'Svay, Kandal Province, Cambodia.'">
                <!--Control this? -->
                <subject authority="local">
                    <geographic>
                        <xsl:apply-templates/>
                    </geographic>
                </subject>
            </xsl:when>
            <xsl:when test="string(text()) = 'Kandal Province, Cambodia'">
                <subject authority="lcsh">
                    <geographic>
                        <xsl:text>Kândal (Cambodia : Province)</xsl:text>
                    </geographic>
                </subject>
            </xsl:when>
            <xsl:when
                test="string(text()) = 'The Thirty-Seven Nats. A Phase of Spirit-Worship prevailing in Burma, By Sir R. C. Temple, Bart., C.I.E.   With full-page and other illustrations.'">
                <note type="source">
                    <xsl:apply-templates/>
                </note>
            </xsl:when>
            <xsl:when
                test="string(text()) = 'London. W. Griggs, Chromo-Lithographer to the King. 1906'">
                <note type="source">
                    <xsl:apply-templates/>
                </note>
            </xsl:when>
            <xsl:when test="string(text()) = 'Location : Kandal Province.'">
                <subject authority="lcsh">
                    <geographic>
                        <xsl:text>Kândal (Cambodia : Province)</xsl:text>
                    </geographic>
                </subject>
            </xsl:when>
            <xsl:when test="string(text()) = 'Phnom Penh'">
                <subject authority="lcsh">
                    <geographic>
                        <xsl:text>Phnom Penh (Cambodia)</xsl:text>
                    </geographic>
                </subject>
            </xsl:when>
            <xsl:when test="string(text()) = 'That Luang, Vientiane, Laos'">
                <subject authority="lcsh">
                    <geographic>
                        <xsl:text>Vat Phathāt Lūang Vīangčhan (Laos)</xsl:text>
                    </geographic>
                </subject>
                <subject authority="lcsh">
                    <topic>Stūpas</topic>
                    <geographic>Laos</geographic>
                    <geographic>Viangchan</geographic>
                </subject>
                <subject authority="lcsh">
                    <topic>Buddhist temples</topic>
                    <geographic>Laos</geographic>
                    <geographic>Viangchan</geographic>
                </subject>
            </xsl:when>
            <xsl:when test="string(text()) = 'Svay, Kandal Province'">
                <!--Control this? -->
                <subject authority="local">
                    <geographic>
                        <xsl:apply-templates/>
                    </geographic>
                </subject>
            </xsl:when>
            <xsl:when test="string(text()) = 'Location : Udong.'">
                <!--Control this? -->
                <subject authority="local">
                    <geographic>Udong</geographic>
                </subject>
            </xsl:when>
            <!--         <xsl:when test="string(text()) = 'Ho Phakeo, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Japan'"/>
            <xsl:when test="string(text()) = 'Patou Xai, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Vat That Foun, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Vat Simeuang, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Wat Svay, Kandal Province'"/>
            <xsl:when test="string(text()) = 'Market at Kampong Kantuot, Kandal Province, Cambodia'"/>
            <xsl:when test="string(text()) = 'At Fête des Génies, Phnom Penh, Cambodia'"/>
            <xsl:when test="string(text()) = 'Vat Sisavat, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Wat Phnom, Phnom Penh, Cambodia'"/>
            <xsl:when test="string(text()) = 'Water Festival [Omtuk]   Kandal Province, Cambodia'"/>
            <xsl:when test="string(text()) = 'Vat Inpeng, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Vat Phia Vat, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Vat Tai Nyai, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Vat Sidamdouan, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Vat Chanthapalan, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Siem Reap'"/>
            <xsl:when test="string(text()) = 'Wat Langka, Phnom Penh, Cambodia'"/>
            <xsl:when test="string(text()) = 'Vat Hua Meuang, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Vat Phaxayasethathirat, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Vat Xieng Nyuen, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Don Chan Palace Hotel, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Bangkok, Thailand'"/>
            <xsl:when test="string(text()) = 'National Cultural Hall, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Vat Tai Noi, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Vat Haisok, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Vat That Khao, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Kandal Province, Cambodia.'"/>
            <xsl:when test="string(text()) = 'Trip to Bangkok'"/>
            <xsl:when test="string(text()) = 'Vat Mixay, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Takeo'"/>
            <xsl:when test="string(text()) = 'Riverfront, Phnom Penh, Cambodia'"/>
            <xsl:when test="string(text()) = 'Vat Chan, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Vat Somsangat, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Vat Xieng Vae, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Vat Phaphothisalalat, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Taken by Sue DieTrich'"/>
            <xsl:when test="string(text()) = 'Vat Phon Saat, Vientiane, Laos'"/>
            <xsl:when
                test="string(text()) = 'Chinese New Year, Kampong Kantout, Kandal Province, Cambodia'"/>
            <xsl:when test="string(text()) = 'Vat Oup Moung, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Vat Khoun Ta, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Vat Kao Nyot, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Hong Kong'"/>
            <xsl:when test="string(text()) = 'Wat Svay, Kandal Province, Cambodia'"/>
            <xsl:when test="string(text()) = 'Fountain Plaza, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'That Dam, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Wat Prerung'"/> -->
            <xsl:when test="matches(.,'^(Source : )')">
                <note type="source">
                    <xsl:value-of select="substring-after(.,'Source : ')"/>
                </note>
            </xsl:when>
            <xsl:otherwise>
                <note>
                    <xsl:apply-templates/>
                </note>
            </xsl:otherwise>
        </xsl:choose>
        <!--<tableOfContents>
            <xsl:apply-templates/>
        </tableOfContents>-->
    </xsl:template>

    <xsl:template match="dc:contributor">
        <xsl:choose>
            <xsl:when test=".='Art in the Age of Doi Moi (Renovation) in Vietnam'">
                <relatedItem type="host">
                    <titleInfo>
                        <title>Art in the age of Doi Moi</title>
                    </titleInfo>
                    <identifier>SEAImages:VNArtBooks</identifier>
                    <identifier>SEAImages:VNArtImages</identifier>
                </relatedItem>
            </xsl:when>
            <xsl:when test=".='On the Record: Indonesian Literary Figures'">
                <relatedItem type="host">
                    <titleInfo>
                        <title>On the record</title>
                        <subTitle>Indonesian Literary Figures </subTitle>
                    </titleInfo>
                    <identifier>SEAImages:LontarVideos</identifier>
                </relatedItem>
            </xsl:when>
            <xsl:otherwise>
                <name>
                    <namePart>
                        <xsl:apply-templates/>
                    </namePart>
                    <role>
                        <roleTerm type="text">
                            <xsl:text>contributor</xsl:text>
                        </roleTerm>
                    </role>
                </name>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dc:date">
        <originInfo>
            <xsl:choose>
                <xsl:when
                    test="(/oai_dc:dc/dc:publisher='Northern Illinois University Libraries - Southeast Asia Digital Library (http://sea.lib.niu.edu)') or (.!='Southeast Asia Digital Library, Northern Illinois University') or (.!='Northern Illinois University Libraries - Southeast Asia Digital Library')">
                    <publisher>Southeast Asia Digital Library</publisher>
                </xsl:when>
                <xsl:otherwise>
                    <publisher>
                        <xsl:value-of select="/oai_dc:dc/dc:publisher"/>
                    </publisher>
                </xsl:otherwise>
            </xsl:choose>


            <xsl:choose>
                <xsl:when test="(.='unknown') or (.='Date unknown') or (.='9999')">
                    <dateOther encoding="iso8601" keyDate="yes" qualifier="questionable"
                        >19</dateOther>
                </xsl:when>

                <!-- 1930-1935 -->
                <!-- ca. 1930-1935 -->
                <!-- 1930 - 1935 -->
                <xsl:when test="matches(.,'^(ca.\W)*?(\d{4})(\W)*?-(\W)*?(\d{4})')">
                    <dateOther encoding="w3cdtf" keyDate="yes" point="start" qualifier="approximate">
                        <xsl:value-of select="substring-before(.,'-')"/>
                    </dateOther>
                    <dateOther encoding="w3cdtf" keyDate="yes" point="end" qualifier="approximate">
                        <xsl:value-of select="substring-after(.,'-')"/>
                    </dateOther>
                </xsl:when>

                <!-- 1994-12-05 -->
                <xsl:when test="matches(.,'^(\d{4})\-(\d{2})\-(\d{2})')">
                    <dateOther encoding="w3cdtf" keyDate="yes">
                        <xsl:value-of select="."/>
                    </dateOther>
                </xsl:when>

                <!-- 1994 -->
                <xsl:when test="matches(.,'^([0-9]{4}){1}$')">
                    <dateOther encoding="w3cdtf" keyDate="yes">
                        <xsl:value-of select="."/>
                    </dateOther>
                </xsl:when>

                <!-- 12/05/1994 -->
                <xsl:when test="matches(.,'^([0-9]+)/([0-9]+)/([0-9]+)$')">
                    <xsl:analyze-string select="." regex="([0-9]+)/([0-9]+)/([0-9]+)$">
                        <xsl:matching-substring>
                            <dateOther encoding="w3cdtf" keyDate="yes">
                                <xsl:value-of select="regex-group(3)"/>
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="regex-group(1)"/>
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="regex-group(2)"/>
                            </dateOther>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <dateOther>
                        <xsl:value-of select="."/>
                    </dateOther>
                </xsl:otherwise>
            </xsl:choose>

        </originInfo>

    </xsl:template>

    <!--                       TYPE                      -->

    <xsl:template match="dc:type">
        <!-- based on DCMI Type Vocabulary as of 2012-06-14 at http://dublincore.org/documents/dcmi-type-vocabulary/ ... see also the included dcmiType.xsl serving as variable $types -->
        <xsl:choose>
            <xsl:when test="string(text()) = 'Photograph'">
                <typeOfResource>
                    <xsl:text>still image</xsl:text>
                </typeOfResource>
                <genre authority="aat">
                    <xsl:text>photographs</xsl:text>
                </genre>
                <physicalDescription>
                    <form authority="smd">photoprint</form>
                    <form authority="marcform">electronic</form>
                    <xsl:for-each select="/oai_dc:dc/dc:format">
                        <extent>
                            <xsl:value-of select="/oai_dc:dc/dc:format"/>
                        </extent>
                    </xsl:for-each>
                    <digitalOrigin>reformatted digital</digitalOrigin>
                </physicalDescription>
            </xsl:when>
            <xsl:when test="string(text()) = 'Painting'">
                <typeOfResource>
                    <xsl:text>still image</xsl:text>
                </typeOfResource>
                <genre authority="aat">
                    <xsl:text>paintings (visual works)</xsl:text>
                </genre>
                <physicalDescription>
                    <form authority="marcform">electronic</form>
                    <xsl:for-each select="/oai_dc:dc/dc:format">
                        <extent>
                            <xsl:value-of select="/oai_dc:dc/dc:format"/>
                        </extent>
                    </xsl:for-each>
                    <digitalOrigin>reformatted digital</digitalOrigin>
                </physicalDescription>
            </xsl:when>
            <xsl:when test="string(text()) = 'Manuscript'">
                <typeOfResource manuscript="yes">
                    <xsl:text>mixed material</xsl:text>
                </typeOfResource>
                <genre authority="aat">
                    <xsl:text>manuscripts (document genre)</xsl:text>
                </genre>
                <physicalDescription>
                    <form authority="marcform">electronic</form>
                    <xsl:for-each select="/oai_dc:dc/dc:format">
                        <extent>
                            <xsl:value-of select="/oai_dc:dc/dc:format"/>
                        </extent>
                    </xsl:for-each>
                    <digitalOrigin>reformatted digital</digitalOrigin>
                </physicalDescription>
            </xsl:when>
            <xsl:when test="string(text()) = 'Book'">
                <typeOfResource>
                    <xsl:text>text</xsl:text>
                </typeOfResource>
                <genre authority="aat">
                    <xsl:text>books</xsl:text>
                </genre>
                <physicalDescription>
                    <form authority="marcform">electronic</form>
                    <xsl:for-each select="/oai_dc:dc/dc:format">
                        <extent>
                            <xsl:value-of select="/oai_dc:dc/dc:format"/>
                        </extent>
                    </xsl:for-each>
                    <digitalOrigin>reformatted digital</digitalOrigin>
                </physicalDescription>
            </xsl:when>
            <xsl:when test="string(text()) = 'Page'">
                <typeOfResource>
                    <xsl:text>text</xsl:text>
                </typeOfResource>
                <physicalDescription>
                    <form authority="marcform">electronic</form>
                    <digitalOrigin>reformatted digital</digitalOrigin>
                </physicalDescription>
            </xsl:when>
            <xsl:when test="string(text()) = 'Journal/Newspaper'">
                <typeOfResource>
                    <xsl:text>text</xsl:text>
                </typeOfResource>
                <genre authority="aat">
                    <xsl:text>articles</xsl:text>
                </genre>
                <physicalDescription>
                    <form authority="marcform">electronic</form>
                    <xsl:for-each select="/oai_dc:dc/dc:format">
                        <extent>
                            <xsl:value-of select="/oai_dc:dc/dc:format"/>
                        </extent>
                    </xsl:for-each>
                    <internetMediaType>application/pdf</internetMediaType>
                    <digitalOrigin>born digital</digitalOrigin>
                </physicalDescription>
            </xsl:when>

            <xsl:when test="string(text()) = 'ArchivalMaterial'">
                <typeOfResource>
                    <xsl:text>mixed material</xsl:text>
                </typeOfResource>
                <genre authority="aat">
                    <xsl:text>documents</xsl:text>
                </genre>
                <physicalDescription>
                    <form authority="marcform">electronic</form>
                    <xsl:for-each select="/oai_dc:dc/dc:format">
                        <extent>
                            <xsl:value-of select="/oai_dc:dc/dc:format"/>
                        </extent>
                    </xsl:for-each>
                    <digitalOrigin>reformatted digital</digitalOrigin>
                </physicalDescription>
            </xsl:when>
            <xsl:when test="string(text())= 'Video'">
                <genre authority="aat">
                    <xsl:text>video recordings</xsl:text>
                </genre>
                <typeOfResource>
                    <xsl:text>moving image</xsl:text>
                </typeOfResource>
                <physicalDescription>
                    <form authority="marcform">electronic</form>
                    <xsl:for-each select="/oai_dc:dc/dc:format">
                        <extent>
                            <xsl:value-of select="/oai_dc:dc/dc:format"/>
                        </extent>
                    </xsl:for-each>
                </physicalDescription>
            </xsl:when>
            <xsl:otherwise>

                  <typeOfResource>
                    		<xsl:text>mixed material</xsl:text>
                	</typeOfResource>
                    <genre>
                        <xsl:value-of select="."/>
                    </genre>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dc:identifier">
        <xsl:variable name="iso-3166Check">
            <xsl:value-of select="substring(text(), 1, 2)"/>
        </xsl:variable>
        <identifier>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when
                        test="starts-with(text(),'urn:hdl') or starts-with(text(),'hdl') or starts-with(text(),'http://hdl.')">
                        <xsl:text>hdl</xsl:text>
                    </xsl:when>
                    <xsl:when test="starts-with(text(), 'doi')">
                        <xsl:text>doi</xsl:text>
                    </xsl:when>
                    <xsl:when test="starts-with(text(), 'ark')">
                        <xsl:text>ark</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(text(), 'purl')">
                        <xsl:text>purl</xsl:text>
                    </xsl:when>
                    <xsl:when test="starts-with(text(), 'tag')">
                        <xsl:text>tag</xsl:text>
                    </xsl:when>
                    <!-- will need to update for ISBN 13 as of January 1, 2007, see XSL tool at http://isbntools.com/ -->
                    <xsl:when
                        test="(starts-with(text(), 'ISBN') or starts-with(text(), 'isbn')) or ((string-length(text()) = 13) and contains(text(), '-') and (starts-with(text(), '0') or starts-with(text(), '1'))) or ((string-length(text()) = 10) and (starts-with(text(), '0') or starts-with(text(), '1')))">
                        <xsl:text>isbn</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="(starts-with(text(), 'ISMN') or starts-with(text(), 'ismn')) or starts-with(text(), 'M') and ((string-length(text()) = 11) and contains(text(), '-') or string-length(text()) = 9)">
                        <xsl:text>ismn</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="(starts-with(text(), 'ISSN') or starts-with(text(), 'issn')) or ((string-length(text()) = 9) and contains(text(), '-') or string-length(text()) = 8)">
                        <xsl:text>issn</xsl:text>
                    </xsl:when>
                    <xsl:when test="starts-with(text(), 'ISTC') or starts-with(text(), 'istc')">
                        <xsl:text>istc</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="(starts-with(text(), 'SICI') or starts-with(text(), 'sici')) or ((starts-with(text(), '0') or starts-with(text(), '1')) and (contains(text(), ';') and contains(text(), '(') and contains(text(), ')') and contains(text(), '&lt;') and contains(text(), '&gt;')))">
                        <xsl:text>sici</xsl:text>
                    </xsl:when>
                    <xsl:when test="starts-with(text(), 'LCCN') or starts-with(text(), 'lccn')">
                        <!-- probably can't do this quickly or easily without regexes and XSL 2.0 -->
                        <xsl:text>lccn</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>local</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </identifier>
        <location>
            <url usage="primary display" access="object in context">
                <xsl:text>http://sea.lib.niu.edu/islandora/object/</xsl:text>
                <xsl:value-of select="."/>
            </url>
        </location>
    </xsl:template>
    <xsl:template match="dc:source">
        <xsl:param name="palm">
            <xsl:text>Pa'O Religous and Literary Manuscripts</xsl:text>
        </xsl:param>
        <xsl:choose>
            <!-- Projects -->
            <xsl:when test=".='Palm-Leaf Manuscripts of Thailand'">
                <relatedItem type="host">
                    <titleInfo>
                        <title>Palm-leaf manuscripts of Thailand</title>
                    </titleInfo>
                    <identifier>SEAImages:KKManuscripts</identifier>
                </relatedItem>
            </xsl:when>
            <xsl:when test=".=$palm">
                <relatedItem type="host">
                    <titleInfo>
                        <title>Pa'o religous and literary manuscripts</title>
                    </titleInfo>
                    <identifier>SEAImages:PAOManuscripts</identifier>
                </relatedItem>
            </xsl:when>
            <xsl:when test=".='Jawi Transliteration Project'">
                <relatedItem type="host">
                    <titleInfo>
                        <title>Jawi Transliteration Project</title>
                    </titleInfo>
                    <identifier>SEAImages:Jawi</identifier>
                </relatedItem>
            </xsl:when>
            <xsl:when test=".='The Living Memory Project'">
                <relatedItem type="host">
                    <titleInfo>
                        <nonSort>The</nonSort>
                        <title>living memory project</title>
                    </titleInfo>
                    <identifier>SEAImages:LMPImages</identifier>
                    <!-- Images -->
                    <identifier>SEAImages:LMPVideos</identifier>
                    <!-- Video -->
                </relatedItem>
            </xsl:when>
            <xsl:when test=".='Early Imprints from Southeast Asia'">
                <relatedItem type="host">
                    <titleInfo>
                        <title>Early imprints from Southeast Asia</title>
                    </titleInfo>
                    <identifier>SEAImages:BLBooks</identifier>
                </relatedItem>
            </xsl:when>
            <xsl:when
                test=".='The May Ebihara Collection: Ethnographic Research in Rural Community, 1950-1995.'">
                <relatedItem type="host">
                    <titleInfo>
                        <nonSort>The</nonSort>
                        <title>May Ebihara collection</title>
                        <subTitle>ethnographic research in rural community, 1959-1995</subTitle>
                    </titleInfo>
                    <identifier>SEAImages:MECImages</identifier>
                </relatedItem>
            </xsl:when>
            <xsl:when test=".='The Diaries and Travel Writings of King Chulalongkorn of Siam'">
                <relatedItem type="host">
                    <titleInfo>
                        <nonSort>The</nonSort>
                        <title>diaries and travel writings of King Chulalongkorn of Siam</title>
                    </titleInfo>
                    <identifier>SEAImages:OUBooks</identifier>
                </relatedItem>
            </xsl:when>
            <xsl:when test=".='Then and Now: Historical Photographs of Cambodia'">
                <relatedItem type="host">
                    <titleInfo>
                        <title>Then and now</title>
                        <subTitle>historical photographs of Cambodia</subTitle>
                    </titleInfo>
                    <identifier>SEAImages:CPImages</identifier>
                </relatedItem>
            </xsl:when>
            <xsl:when test=".='Historical Archives and Photographs: University of San Carlos'">
                <relatedItem type="host">
                    <titleInfo>
                        <title>Historical archives and photographs</title>
                        <subTitle>Cebuano Studies Center, Philippines</subTitle>
                    </titleInfo>
                    <identifier>SEAImages:USCBooks</identifier>
                    <!-- Books -->
                    <identifier>SEAImages:USCImages</identifier>
                    <!-- Images -->
                </relatedItem>
            </xsl:when>
            <xsl:when test=".='Virtual Southeast Asia'">
                <relatedItem type="host">
                    <titleInfo>
                        <title>Virtual Southeast Asia</title>
                    </titleInfo>
                    <identifier>SEAImages:VSAImages</identifier>
                </relatedItem>
            </xsl:when>
            <xsl:when test=".='Living Memory of the Khmer'">
                <relatedItem type="host">
                    <titleInfo>
                        <title>Living Memory of the Khmer</title>
                    </titleInfo>
                    <identifier>SEAImages:LKVideos</identifier>
                </relatedItem>
            </xsl:when>
            <xsl:when test=".='Lontar Digital Library'">
                <xsl:apply-templates select="*[. != 'Lontar Digital Library']"/>
            </xsl:when>
            <xsl:when test=".='Mandalay Marionettes Theater Puppet Show'">
                <relatedItem type="host">
                    <titleInfo>
                        <title>Mandalay marionettes theater puppet show</title>
                    </titleInfo>
                    <identifier>SEAImages:NIUVideos</identifier>
                </relatedItem>
            </xsl:when>
            <xsl:when test=".='Collection of Natalia Kraevskaia'">
                <note>
                    <xsl:apply-templates/>
                </note>
            </xsl:when>
            <xsl:when test="(.='Northern Illinois Library') or (.='Northern Illinois University')">
                <relatedItem type="host">
                    <titleInfo>
                        <title>Burmese manuscripts from the Donn V. Hart Collection</title>
                    </titleInfo>
                    <identifier>SEAImages:NIUBooks</identifier>
                    <!-- Books -->
                    <identifier>SEAImages:NIUManuscripts</identifier>
                    <!-- Manuscripts -->
                </relatedItem>
            </xsl:when>
            <xsl:when test=".='Video Archive -- Television Program, Indonesia'">
                <relatedItem type="host">
                    <titleInfo>
                        <title>Video archive</title>
                        <subTitle>television program, Indonesia</subTitle>
                    </titleInfo>
                </relatedItem>
            </xsl:when>

            <!-- Other source -->
            <xsl:when test="matches(.,'(Call Number: )')">
                <classification authority="lcc">
                    <xsl:value-of select="substring-after(.,'Number: ')"/>
                </classification>
            </xsl:when>
            <xsl:when test=".='Gift of Bui Xuan Phai'">
                <note>
                    <xsl:apply-templates/>
                </note>
            </xsl:when>
            <xsl:when test=".='Public domain'">
                <accessCondition>Public domain</accessCondition>
            </xsl:when>
            <xsl:when
                test=".='Temple, Richard Carnac, Sir.  The Thirty-Seven Nats. A Phase of Spirit Worship Prevailing in Burma.  London: W. Griggs, 1906.'">
                <note type="source">
                    <xsl:value-of select="."/>
                </note>
            </xsl:when>
            <xsl:when test=".='SEAnet Books'">
                <relatedItem type="host">
                    <titleInfo>
                        <title>SEAnet Books</title>
                    </titleInfo>
                    <identifier>SEAImages:SEAnetBooks</identifier>
                </relatedItem>
            </xsl:when>
            <xsl:otherwise>
                <note>
                    <xsl:apply-templates/>
                </note>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dc:language">
        <xsl:if test=".='Burmese'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Burmese</languageTerm>
                <languageTerm type="code" authority="iso639-2b">bur</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test="(.='PaO') or (.=concat('Pa',$apos,'O'))">
            <language>
                <languageTerm type="text" authority="iso639-2b">Taungthu</languageTerm>
                <languageTerm type="code" authority="iso639-2b">kar</languageTerm>
                <languageTerm type="text" authority="iso639-3">Pa'o Karen</languageTerm>
                <languageTerm type="code" authority="iso639-2b">blk</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test=". = 'English'">
            <language>
                <languageTerm type="text" authority="iso639-2b">English</languageTerm>
                <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
            </language>
        </xsl:if>

        <xsl:if test=".='Malay'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Malay</languageTerm>
                <languageTerm type="code" authority="iso639-2b">mal</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test=". = 'Thai'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Thai</languageTerm>
                <languageTerm type="code" authority="iso639-2b">tha</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test=". = 'Vietnamese'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Vietnamese</languageTerm>
                <languageTerm type="code" authority="iso639-2b">vie</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test="(. = 'Thai-Isan') or (. = 'Thi-Isan')">
            <language>
                <languageTerm type="text" authority="iso639-2b">Northeastern Thai</languageTerm>
                <languageTerm type="code" authority="iso639-2b">tai</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test=". = 'Pali-Thai-Isan'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Pali</languageTerm>
                <languageTerm type="code" authority="iso639-2b">pli</languageTerm>
            </language>
            <language>
                <languageTerm type="text" authority="iso639-2b">Northeastern Thai</languageTerm>
                <languageTerm type="code" authority="iso639-2b">tai</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test=". = 'Pali'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Pali</languageTerm>
                <languageTerm type="code" authority="iso639-2b">pli</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test=". = 'French'">
            <language>
                <languageTerm type="text" authority="iso639-2b">French</languageTerm>
                <languageTerm type="code" authority="iso639-2b">fre</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test=". = 'Russian'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Russian</languageTerm>
                <languageTerm type="code" authority="iso639-2b">rus</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test=". = 'Spanish'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Spanish</languageTerm>
                <languageTerm type="code" authority="iso639-2b">spa</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test=". = 'Portuguese'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Portuguese</languageTerm>
                <languageTerm type="code" authority="iso639-2b">por</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test=". = 'Printed in Lao Tham (Northern Thai) script'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Northern Thai</languageTerm>
                <languageTerm type="code" authority="iso639-2b">tai</languageTerm>
                <scriptTerm type="text" authority="iso15924">Tai Tham (Lanna)</scriptTerm>
                <scriptTerm type="code" authority="iso15924">lana</scriptTerm>
            </language>
        </xsl:if>
        <xsl:if test=". = 'Shan'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Shan</languageTerm>
                <languageTerm type="code" authority="iso639-2b">shn</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test=". = 'Tagalog'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Tagalog</languageTerm>
                <languageTerm type="code" authority="iso639-2b">tgl</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test=". = 'Tetum'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Tetum</languageTerm>
                <languageTerm type="code" authority="iso639-2b">tet</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test=". = 'Khmer'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Khmer</languageTerm>
                <languageTerm type="code" authority="iso639-2b">khm</languageTerm>
            </language>
        </xsl:if>
    </xsl:template>
    <xsl:template match="dc:relation">
        <relatedItem>
            <location>
                <url>
                    <xsl:text>http://sea.lib.niu.edu/islandora/object/</xsl:text>
                    <xsl:value-of select="."/>
                </url>
            </location>
        </relatedItem>
    </xsl:template>
    <xsl:template match="dc:coverage">
        <xsl:if test="(.='Burma') or (.='Myanmar/Burma')">
            <subject authority="lcsh">
                <geographic>Burma</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Myanma</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>mm</geographicCode>
            </subject>
        </xsl:if>
        <xsl:if test=".='Thailand' or .='Thai' or .='Thailand (Siam)'">
            <subject authority="lcsh">
                <geographic>Thailand</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Prathet Thai</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>th</geographicCode>
            </subject>
        </xsl:if>
        <xsl:if test=".='Malaysia'">
            <subject authority="lcsh">
                <geographic>Malaysia</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Malaysia</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>my</geographicCode>
            </subject>
        </xsl:if>
        <xsl:if test=".='Cambodia'">
            <subject authority="lcsh">
                <geographic>Cambodia</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Kâmpŭchéa</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>kh</geographicCode>
            </subject>
        </xsl:if>
        <xsl:if test=".='Philippines'">
            <subject authority="lcsh">
                <geographic>Philippines</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Pilipinas</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>ph</geographicCode>
            </subject>
        </xsl:if>
        <xsl:if test=".='Singapore'">
            <subject authority="lcsh">
                <geographic>Singapore</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Singapore</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>sg</geographicCode>
            </subject>
        </xsl:if>
        <xsl:if test=".='Vietnam'">
            <subject authority="lcsh">
                <geographic>Vietnam</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Việt Nam</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>vn</geographicCode>
            </subject>
        </xsl:if>
        <xsl:if test=".='Laos'">
            <subject authority="lcsh">
                <geographic>Laos</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Lao</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>la</geographicCode>
            </subject>
        </xsl:if>
        <xsl:if test=".='Japan'">
            <subject authority="lcsh">
                <geographic>Japan</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Nihon</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>jp</geographicCode>
            </subject>
        </xsl:if>
        <xsl:if test=".='China'">
            <subject authority="lcsh">
                <geographic>China</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Zhonghua</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>cn</geographicCode>
            </subject>
        </xsl:if>
        <xsl:if test="'North America--------'">
            <xsl:apply-templates select="*[. != 'North America--------']"/>
        </xsl:if>
        <xsl:if test=".='Indonesia'">
            <subject authority="lcsh">
                <geographic>Indonesia</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Indonesia</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>id</geographicCode>
            </subject>
        </xsl:if>
        <xsl:if test=".='Egypt'">
            <subject authority="lcsh">
                <geographic>Egypt</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Miṣr</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>eg</geographicCode>
            </subject>
        </xsl:if>
        <xsl:if test=".='East Timor'">
            <subject authority="lcsh">
                <geographic>Timor-Leste</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Timor-Leste</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>tl</geographicCode>
            </subject>
        </xsl:if>
        <xsl:if test=".='Cambodia;Vietnam'">
            <subject authority="lcsh">
                <geographic>Cambodia</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Kâmpŭchéa</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>kh</geographicCode>
            </subject>
            <subject authority="lcsh">
                <geographic>Vietnam</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Việt Nam</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>vn</geographicCode>
            </subject>
        </xsl:if>
        <xsl:if test=".='Greece'">
            <subject authority="lcsh">
                <geographic>Greece</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Ellás</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>gr</geographicCode>
            </subject>
        </xsl:if>
        <xsl:if test=".='Madrid (Spain)'">
            <subject authority="lcsh">
                <geographic>Spain</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>España</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>es</geographicCode>
            </subject>
        </xsl:if>
        <xsl:if test=".='Italy'">
            <subject authority="lcsh">
                <geographic>Italy</geographic>
            </subject>
            <subject authority="tgn">
                <geographic>Italia</geographic>
            </subject>
            <subject authority="iso3166">
                <geographicCode>it</geographicCode>
            </subject>
        </xsl:if>
    </xsl:template>
    <xsl:template match="dc:rights">
        <accessCondition type="use and reproduction">
            <xsl:apply-templates/>
        </accessCondition>
    </xsl:template>
</xsl:stylesheet>
