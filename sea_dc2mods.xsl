<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:sru_dc="info:srw/schema/1/dc-schema"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.loc.gov/mods/v3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="sru_dc oai_dc dc"
    version="2.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:include href="inc/dcmiType.xsl"/>
    <xsl:include href="inc/mimeType.xsl"/>
    <xsl:include href="inc/csdgm.xsl"/>
    <xsl:include href="inc/forms.xsl"/>
    <xsl:include href="inc/iso3166-1.xsl"/>
    <xsl:include href="inc/iso639-2.xsl"/>
    <!-- Do you have a Handle server?  If so, specify the base URI below including the trailing slash a la: http://hdl.loc.gov/ -->
    <xsl:variable name="handleServer">
        <xsl:text>http://hdl.loc.gov/</xsl:text>
    </xsl:variable>
    <xsl:variable name="apos">'</xsl:variable>
    <xsl:template match="*[not(node())]"/>
    <!-- strip empty DC elements that are output by tools like ContentDM -->
    <xsl:template match="/">
        <xsl:if test="sru_dc:dcCollection">
            <xsl:apply-templates select="sru_dc:dcCollection"/>
        </xsl:if>
        <xsl:if test="sru_dc:dc">
            <xsl:apply-templates select="sru_dc:dc"/>
        </xsl:if>
        <xsl:if test="oai_dc:dc">
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sru_dc:dcCollection">
        <modsCollection xmlns="http://www.loc.gov/mods/v3"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-2.xsd">
            <xsl:apply-templates select="sru_dc:dc">
                <xsl:with-param name="dcCollection">
                    <xsl:text>true</xsl:text>
                </xsl:with-param>
            </xsl:apply-templates>
        </modsCollection>
    </xsl:template>
    <xsl:template match="sru_dc:dc">
        <xsl:param name="dcCollection"/>
        <xsl:choose>
            <xsl:when test="$dcCollection = 'true'">
                <mods version="3.2">
                    <xsl:call-template name="dcMain"/>
                </mods>
            </xsl:when>
            <xsl:otherwise>
                <mods version="3.2" xmlns="http://www.loc.gov/mods/v3"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-2.xsd">
                    <xsl:call-template name="dcMain"/>
                </mods>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    <xsl:template match="oai_dc:dc">
        <mods version="3.2" xmlns="http://www.loc.gov/mods/v3"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-2.xsd">
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
        <xsl:for-each select="dc:publisher">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:for-each select="dc:date">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:for-each select="dc:format">
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
        <titleInfo>
            <title>
                <xsl:apply-templates/>
            </title>
        </titleInfo>
    </xsl:template>
    <xsl:template match="dc:creator">
        <xsl:choose>
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
                        <xsl:text>Cuenco, José Maria</xsl:text>
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
                        <xsl:text>Hôi mỹ thuât Viêt Nam</xsl:text>
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
                        <namePart>Jăyvarmăn</namePart>
                        <namePart type="termOfAddress">VII</namePart>
                        <namePart type="termOfAddress">King of Cambodia</namePart>
                        <namePart type="date">ca. 1120-ca. 1215</namePart>
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
        </xsl:choose>
    </xsl:template>
    <xsl:template match="dc:description">
        <!--<abstract>
            <xsl:apply-templates/>
        </abstract>-->
        <xsl:choose>
            <xsl:when
                test="string(text()) = 'This item digitized and made available online with funds provided by United States Department of Education, TICFIA (Technological Innovation and Cooperation for Foreign Information) Grant P337A05006.'">
                <note tpye="funding">
                    <xsl:apply-templates/>
                </note>
            </xsl:when>
            <xsl:when
                test="string(text()) = 'This item digitized and made available online with funds provided by United States Department of Education, TICFIA (Technological Innovation and Cooperation for Foreign Information) Grant P337A090018..'">
                <note tpye="funding">
                    <xsl:apply-templates/>
                </note>
            </xsl:when>
            <xsl:when test="string(text()) = 'Location : Siem Reap.'"> </xsl:when>
            <xsl:when test="string(text()) = 'Location : Phnom Penh.'"/>
            <xsl:when test="string(text()) = 'Location : Kampong Speu Province.'"/>
            <xsl:when test="string(text()) = 'Svay, Kandal Province, Cambodia.'"/>
            <xsl:when test="string(text()) = 'Kandal Province, Cambodia'"/>
            <xsl:when
                test="string(text()) = 'The Thirty-Seven Nats. A Phase of Spirit-Worship prevailing in Burma, By Sir R. C. Temple, Bart., C.I.E.   With full-page and other illustrations.'"/>
            <xsl:when
                test="string(text()) = 'London. W. Griggs, Chromo-Lithographer to the King. 1906'"/>
            <xsl:when test="string(text()) = 'Location : Kandal Province.'"/>
            <xsl:when test="string(text()) = 'Mounted on photographic mounting card, 285 X 222 cm.'"/>
            <xsl:when test="string(text()) = 'Phnom Penh'"/>
            <xsl:when test="string(text()) = 'That Luang, Vientiane, Laos'"/>
            <xsl:when test="string(text()) = 'Svay, Kandal Province'"/>
            <xsl:when test="string(text()) = 'Location : Udong.'"/>
            <xsl:when test="string(text()) = 'Ho Phakeo, Vientiane, Laos'"/>
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
            <xsl:when test="string(text()) = 'Wat Prerung'"/>
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
    <xsl:template match="dc:publisher">
        
        <!-- Still have to do place of publication vs. publisher processing -->
        <!-- Less than 50...might be worth fixing all of these? -->
        <xsl:choose>
            <xsl:when
                test="string(text()) = 'Northern Illinois University Libraries - Southeast Asia Digital Library (http://sea.lib.niu.edu)' or 'Southeast Asia Digital Library, Northern Illinois University' or 'Northern Illinois University Libraries - Southeast Asia Digital Library'">
                <originInfo>
                    <publisher>
                        <xsl:text>Northern Illinois University</xsl:text>
                    </publisher>
                </originInfo>
                <relatedItem type="host">
                    <typeOfResource collection="yes"/>
                    <titleInfo>
                        <title>Southeast Asia Digital Library</title>
                    </titleInfo>
                    <location>
                        <url>http://sea.lib.niu.edu</url>
                    </location>
                </relatedItem>
            </xsl:when>

            <xsl:otherwise>
                <originInfo>
                    <publisher>
                        <xsl:apply-templates/>
                    </publisher>
                </originInfo>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="dc:contributor"> <!-- Less than 20...consider fixing -->
        <name>
            <namePart>
                <xsl:apply-templates/>
            </namePart>
            <!-- <role>
                <roleTerm type="text">
                    <xsl:text>contributor</xsl:text>
                </roleTerm>
            </role> -->
        </name>
    </xsl:template>

    <!--                   DATE                           -->

    <xsl:template match="dc:date[.='unknown']"/>

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

    <xsl:template match="dc:date">
        <originInfo>
            <xsl:choose>

                <!-- 01/10/1930 -->
                <xsl:when test="matches(.,'(\d{2})/(\d{2})/(\d{4})')">
                    <dateOther encoding="w3cdtf" keyDate="yes">
                        <xsl:value-of
                            select="concat(
                            substring(., 7, 4),
                            '-',
                            substring(., 1, 2),
                            '-',
                            substring(., 4, 2)
                            )"
                        />
                    </dateOther>
                </xsl:when>

                <!-- 10 January 1930 -->
                <xsl:when
                    test="matches(., '(\d{2})\W(January|February|March|April|May|June|July|August|September|October|November|December)\W(\d{4})')">
                    <dateOther encoding="w3cdtf" keyDate="yes">
                        <xsl:call-template name="format_date">
                            <xsl:with-param name="old_date" select="."/>
                        </xsl:call-template>
                    </dateOther>
                </xsl:when>

                <!-- 1930-1935 -->
                <xsl:when test="matches(.,'(\d{4})-(\d{4})')">
                    <dateOther encoding="w3cdtf" keyDate="yes" point="start">
                        <xsl:value-of select="substring-before(.,'-')"/>
                    </dateOther>
                    <dateOther encoding="w3cdtf" keyDate="yes" point="end">
                        <xsl:value-of select="substring-after(.,'-')"/>
                    </dateOther>
                </xsl:when>

                <!-- 19300110 -->
                <xsl:when test="matches(.,'(\d{8})')">
                    <dateOther encoding="w3cdtf" keyDate="yes">
                        <xsl:value-of
                            select="concat(
                            substring(., 1, 4),
                            '-',
                            substring(., 5, 2),
                            '-',
                            substring(., 7, 2)
                            )"
                        />
                    </dateOther>
                </xsl:when>

                <!-- January 1930 -->
                <xsl:when
                    test="matches(.,'(January|February|March|April|May|June|July|August|September|October|November|December)\W(12|13|14|15|16|17|18|19|20)\d\d')">
                    <dateOther encoding="w3cdtf" keyDate="yes">
                        <xsl:call-template name="format_date_simple">
                            <xsl:with-param name="old_date" select="."/>
                        </xsl:call-template>
                    </dateOther>
                </xsl:when>

                <xsl:otherwise>
                    <dateOther encoding="w3cdtf" keyDate="yes">
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
                    <extent>1 photograph</extent>
                    <xsl:if test="/oai_dc:dc/dc:format!='Photograph'">
                        <xsl:for-each select="/oai_dc:dc/dc:format">
                            <extent>
                                <xsl:value-of select="/oai_dc:dc/dc:format"/>
                            </extent>
                        </xsl:for-each>
                    </xsl:if>
                    <internetMediaType>image/jpeg</internetMediaType>
                    <internetMediaType>image/tiff</internetMediaType>
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
                    <internetMediaType>image/jpeg</internetMediaType>
                    <internetMediaType>image/tiff</internetMediaType>
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
                    <internetMediaType>image/jpeg</internetMediaType>
                    <internetMediaType>image/tiff</internetMediaType>
                    <digitalOrigin>reformatted digital</digitalOrigin>
                </physicalDescription>
            </xsl:when>
            <xsl:when test="string(text()) = 'Book'">
                <!-- is a book a collection? -->
                <typeOfResource>
                    <xsl:text>text</xsl:text>
                </typeOfResource>
                <genre authority="aat">
                    <xsl:text>books</xsl:text>
                </genre>
                <physicalDescription>
                    <extent>
                        <xsl:value-of select="dc:format"/>
                    </extent>
                    <!-- revisit...need to get rid of $b, like "ill." -->
                    <internetMediaType>image/jpeg</internetMediaType>
                    <internetMediaType>image/tiff</internetMediaType>
                    <digitalOrigin>reformatted digital</digitalOrigin>
                </physicalDescription>
            </xsl:when>
            <xsl:when test="string(text()) = 'Page'">
                <typeOfResource>
                    <xsl:text>text</xsl:text>
                </typeOfResource>
                <physicalDescription>
                    <internetMediaType>image/jpeg</internetMediaType>
                    <internetMediaType>image/tiff</internetMediaType>
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
                    <internetMediaType>application/pdf</internetMediaType>
                    <digitalOrigin>reformatted digital</digitalOrigin>
                </physicalDescription>
            </xsl:when>

            <xsl:when test="string(text()) = 'ArchivalMaterial'">
                <typeOfResource collection="yes">
                    <xsl:text>mixed material</xsl:text>
                </typeOfResource>
                <physicalDescription>
                    <internetMediaType>image/jpeg</internetMediaType>
                    <internetMediaType>image/tiff</internetMediaType>
                    <digitalOrigin>reformatted digital</digitalOrigin>
                </physicalDescription>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="not(string($types) = text())">
                    <xsl:variable name="lowercaseType"
                        select="translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
                    <!--<typeOfResource>
                        	<xsl:text>mixed material</xsl:text>
                	</typeOfResource>-->
                    <genre>
                        <xsl:value-of select="$lowercaseType"/>
                    </genre>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dc:format">
        <physicalDescription>
            <extent>
                <xsl:apply-templates/>
            </extent>
        </physicalDescription>
    </xsl:template>

    <xsl:template match="dc:identifier">
        <xsl:variable name="iso-3166Check">
            <xsl:value-of select="substring(text(), 1, 2)"/>
        </xsl:variable>
        <identifier>
            <xsl:attribute name="type">
                <xsl:choose>
                    <!-- handled by location/url -->
                    <xsl:when
                        test="starts-with(text(), 'http://') and (not(contains(text(), $handleServer) or not(contains(substring-after(text(), 'http://'), 'hdl'))))">
                        <xsl:text>uri</xsl:text>
                    </xsl:when>
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
                        test="(starts-with(text(), 'ISRC') or starts-with(text(), 'isrc')) or ((string-length(text()) = 12) and (contains($iso3166-1, $iso-3166Check))) or ((string-length(text()) = 15) and (contains(text(), '-') or contains(text(), '/')) and contains($iso3166-1, $iso-3166Check))">
                        <xsl:text>isrc</xsl:text>
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
                        test="(starts-with(text(), 'UPC') or starts-with(text(), 'upc')) or (string-length(text()) = 12 and not(contains(text(), ' ')) and not(contains($iso3166-1, $iso-3166Check)))">
                        <xsl:text>upc</xsl:text>
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
            <xsl:choose>
                <xsl:when
                    test="starts-with(text(),'urn:hdl') or starts-with(text(),'hdl') or starts-with(text(),$handleServer)">
                    <xsl:value-of select="concat('hdl:',substring-after(text(),$handleServer))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </identifier>
    </xsl:template>
    <xsl:template match="dc:source">
        <xsl:choose>
            <xsl:when test="matches(.,'^(Call Number: )')">
                <!-- Finish meeeee! -->
            </xsl:when>
            <xsl:otherwise>
                <note>
                    <xsl:apply-templates/>
                </note>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dc:language[.='Jawi']"/>
    <xsl:template match="dc:language">
        <xsl:if test="string(text()) = 'Burmese'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Burmese</languageTerm>
                <languageTerm type="code" authority="iso639-2b">bur</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test="string(text()) = 'PaO' or string(text()) = concat('Pa',$apos,'O')">
            <language>
                <languageTerm type="text" authority="iso639-2b">Taungthu</languageTerm>
                <languageTerm type="code" authority="iso639-2b">kar</languageTerm>
                <languageTerm type="text" authority="local">Pa'O</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test="string(text()) = 'English'">
            <language>
                <languageTerm type="text" authority="iso639-2b">English</languageTerm>
                <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test="string(text()) = 'Malay'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Malay</languageTerm>
                <languageTerm type="code" authority="iso639-2b">mal</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test="string(text()) = 'Thai'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Thai</languageTerm>
                <languageTerm type="code" authority="iso639-2b">tha</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test="string(text()) = 'Vietnamese'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Vietnamese</languageTerm>
                <languageTerm type="code" authority="iso639-2b">vie</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test="string(text()) = 'Thai-Isan' or string(text()) = 'Thi-Isan'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Northeastern Thai</languageTerm>
                <languageTerm type="code" authority="iso639-2b">tai</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test="string(text()) = 'Pali-Thai-Isan'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Pali</languageTerm>
                <languageTerm type="code" authority="iso639-2b">pli</languageTerm>
            </language>
            <language>
                <languageTerm type="text" authority="iso639-2b">Northeastern Thai</languageTerm>
                <languageTerm type="code" authority="iso639-2b">tai</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test="string(text()) = 'Pali'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Pali</languageTerm>
                <languageTerm type="code" authority="iso639-2b">pli</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test="string(text()) = 'French'">
            <language>
                <languageTerm type="text" authority="iso639-2b">French</languageTerm>
                <languageTerm type="code" authority="iso639-2b">fre</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test="string(text()) = 'Printed in Lao Tham (Northern Thai) script'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Northern Thai</languageTerm>
                <languageTerm type="code" authority="iso639-2b">tai</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test="string(text()) = 'Shan'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Shan</languageTerm>
                <languageTerm type="code" authority="iso639-2b">shn</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test="string(text()) = 'Tagalog'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Tagalog</languageTerm>
                <languageTerm type="code" authority="iso639-2b">tgl</languageTerm>
            </language>
        </xsl:if>
        <xsl:if test="string(text()) = 'Khmer'">
            <language>
                <languageTerm type="text" authority="iso639-2b">Khmer</languageTerm>
                <languageTerm type="code" authority="iso639-2b">khm</languageTerm>
            </language>
        </xsl:if>
    </xsl:template>
    <xsl:template match="dc:relation">
        <relatedItem>
            <xsl:choose>
                <xsl:when test="starts-with(text(), 'http://')">
                    <location>
                        <url>
                            <xsl:value-of select="."/>
                        </url>
                    </location>
                    <identifer type="uri">
                        <xsl:apply-templates/>
                    </identifer>
                </xsl:when>
                <xsl:otherwise>
                    <titleInfo>
                        <title>
                            <xsl:apply-templates/>
                        </title>
                    </titleInfo>
                </xsl:otherwise>
            </xsl:choose>
        </relatedItem>
    </xsl:template>
    <xsl:template match="dc:coverage">
        <xsl:if test=".='Burma'">
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
        <accessCondition>
            <xsl:apply-templates/>
        </accessCondition>
    </xsl:template>
</xsl:stylesheet>
