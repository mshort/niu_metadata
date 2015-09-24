<xsl:stylesheet xmlns="http://www.loc.gov/mods/v3" xmlns:marc="http://www.loc.gov/MARC21/slim"
	xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xlink marc" version="1.0">
	<xsl:include href="http://www.loc.gov/standards/marcxml/xslt/MARC21slimUtils.xsl"/>
	<xsl:output encoding="UTF-8" indent="yes" method="xml"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="/">
		<mods:mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.5"
			xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
			<xsl:for-each select="//marc:record">
				<xsl:call-template name="marcRecord"/>
			</xsl:for-each>
		</mods:mods>
	</xsl:template>

	<xsl:template name="marcRecord">
		<xsl:variable name="leader" select="marc:leader"/>
		<xsl:variable name="leader6" select="substring($leader,7,1)"/>
		<xsl:variable name="leader7" select="substring($leader,8,1)"/>
		<xsl:variable name="leader19" select="substring($leader,20,1)"/>
		<xsl:variable name="controlField008" select="marc:controlfield[@tag='008']"/>
		<xsl:variable name="typeOf008">
			<xsl:choose>
				<xsl:when test="$leader6='a'">
					<xsl:choose>
						<xsl:when test="$leader7='a' or $leader7='c' or $leader7='d' or $leader7='m'">BK</xsl:when>
						<xsl:when test="$leader7='b' or $leader7='i' or $leader7='s'">SE</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$leader6='t'">BK</xsl:when>
				<xsl:when test="$leader6='p'">MM</xsl:when>
				<xsl:when test="$leader6='m'">CF</xsl:when>
				<xsl:when test="$leader6='e' or $leader6='f'">MP</xsl:when>
				<xsl:when test="$leader6='g' or $leader6='k' or $leader6='o' or $leader6='r'">VM</xsl:when>
				<xsl:when test="$leader6='c' or $leader6='d' or $leader6='i' or $leader6='j'">MU</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<!-- titleInfo -->

		<xsl:for-each select="marc:datafield[@tag='245']">
			<xsl:call-template name="createTitleInfoFrom245"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='210']">
			<xsl:call-template name="createTitleInfoFrom210"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='246']">
			<xsl:call-template name="createTitleInfoFrom246"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='240']">
			<xsl:call-template name="createTitleInfoFrom240"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='130']">
			<xsl:call-template name="createTitleInfoFrom130"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='730']">
			<xsl:call-template name="createTitleInfoFrom730"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='242']">
			<mods:titleInfo type="translated">
				<!--09/01/04 Added subfield $y-->
				<xsl:for-each select="marc:subfield[@code='y']">
					<xsl:attribute name="lang">
						<xsl:value-of select="text()"/>
					</xsl:attribute>
				</xsl:for-each>

				<!-- AQ1.27 tmee/dlf -->
				<xsl:variable name="title">
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:call-template name="subfieldSelect">
								<!-- 1/04 removed $h, b -->
								<xsl:with-param name="codes">a</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="titleChop">
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:value-of select="$title"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="@ind2>0">
						<mods:nonSort>
							<xsl:value-of select="normalize-space(substring($titleChop,1,@ind2))"/>
						</mods:nonSort>
						<mods:title>
							<xsl:value-of select="substring($titleChop,@ind2+1)"/>
						</mods:title>
					</xsl:when>
					<xsl:otherwise>
						<mods:title>
							<xsl:value-of select="$titleChop"/>
						</mods:title>
					</xsl:otherwise>
				</xsl:choose>

				<!-- 1/04 fix -->
				<xsl:call-template name="subtitle"/>
				<xsl:call-template name="part"/>
			</mods:titleInfo>
		</xsl:for-each>

		<!-- name -->

		<xsl:for-each select="marc:datafield[@tag='100']">
			<xsl:call-template name="createNameFrom100"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='110']">
			<xsl:call-template name="createNameFrom110"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='111']">
			<xsl:call-template name="createNameFrom111"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='710']">
			<xsl:call-template name="createNameFrom710"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='711']">
			<xsl:call-template name="createNameFrom711"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='720']">
			<xsl:call-template name="createNameFrom720"/>
		</xsl:for-each>
		<mods:typeOfResource>
			<xsl:if test="$leader7='c'">
				<xsl:attribute name="collection">yes</xsl:attribute>
			</xsl:if>
			<xsl:if test="$leader6='d' or $leader6='f' or $leader6='p' or $leader6='t'">
				<xsl:attribute name="manuscript">yes</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$leader6='a' or $leader6='t'">text</xsl:when>
				<xsl:when test="$leader6='e' or $leader6='f'">cartographic</xsl:when>
				<xsl:when test="$leader6='c' or $leader6='d'">notated music</xsl:when>
				<xsl:when test="$leader6='i'">sound recording-nonmusical</xsl:when>
				<xsl:when test="$leader6='j'">sound recording-musical</xsl:when>
				<xsl:when test="$leader6='k'">still image</xsl:when>
				<xsl:when test="$leader6='g'">moving image</xsl:when>
				<xsl:when test="$leader6='r'">three dimensional object</xsl:when>
				<xsl:when test="$leader6='m'">software, multimedia</xsl:when>
				<xsl:when test="$leader6='p'">mixed material</xsl:when>
			</xsl:choose>
		</mods:typeOfResource>

		<!-- genre -->

		<xsl:for-each select="marc:datafield[@tag=047]">
			<xsl:call-template name="createGenreFrom047"/>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=655]">
			<xsl:call-template name="createGenreFrom655"/>
		</xsl:for-each>

		<mods:originInfo eventType="publication">
			<xsl:call-template name="scriptCode"/>
			<xsl:for-each
				select="marc:datafield[(@tag=260 or @tag=264 or @tag=250) and marc:subfield[@code='a' or code='b' or @code='c' or code='g']]">
				<xsl:call-template name="z2xx880"/>
			</xsl:for-each>

			<xsl:variable name="MARCpublicationCode" select="normalize-space(substring($controlField008,16,3))"/>

			<mods:place>
				<xsl:if test="translate($MARCpublicationCode,'|','')">

					<mods:placeTerm>
						<xsl:attribute name="type">code</xsl:attribute>
						<xsl:attribute name="authority">marccountry</xsl:attribute>
						<xsl:value-of select="$MARCpublicationCode"/>
					</mods:placeTerm>

				</xsl:if>
				<xsl:for-each select="marc:datafield[@tag=044]/marc:subfield[@code='c']">

					<mods:placeTerm>
						<xsl:attribute name="type">code</xsl:attribute>
						<xsl:attribute name="authority">iso3166</xsl:attribute>
						<xsl:value-of select="."/>
					</mods:placeTerm>

				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=260]/marc:subfield[@code='a']">

					<mods:placeTerm>
						<xsl:attribute name="type">text</xsl:attribute>
						<xsl:call-template name="chopPunctuationFront">
							<xsl:with-param name="chopString">
								<xsl:call-template name="chopPunctuation">
									<xsl:with-param name="chopString" select="."/>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:placeTerm>

				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=264]/marc:subfield[@code='a']">

					<mods:placeTerm>
						<xsl:attribute name="type">text</xsl:attribute>
						<xsl:call-template name="chopPunctuationFront">
							<xsl:with-param name="chopString">
								<xsl:call-template name="chopPunctuation">
									<xsl:with-param name="chopString" select="."/>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:placeTerm>

				</xsl:for-each>
			</mods:place>

			<!-- tmee 1.35 1.36 dateIssued/nonMSS vs dateCreated/MSS -->
			<xsl:for-each select="marc:datafield[@tag=260]/marc:subfield[@code='b' or @code='c' or @code='g']">
				<xsl:choose>
					<xsl:when test="@code='b'">
						<mods:publisher>
							<xsl:call-template name="chopPunctuation">
								<xsl:with-param name="chopString" select="."/>
								<xsl:with-param name="punctuation">
									<xsl:text>:,;/ </xsl:text>
								</xsl:with-param>
							</xsl:call-template>
						</mods:publisher>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
			<xsl:for-each
				select="marc:datafield[@tag=264 and @ind2=1]/marc:subfield[@code='b' or @code='c' or @code='g']">
				<xsl:choose>
					<xsl:when test="@code='b'">
						<mods:publisher>
							<xsl:call-template name="chopPunctuation">
								<xsl:with-param name="chopString" select="."/>
								<xsl:with-param name="punctuation">
									<xsl:text>:,;/ </xsl:text>
								</xsl:with-param>
							</xsl:call-template>
						</mods:publisher>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>

			<xsl:variable name="dataField260c">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="marc:datafield[@tag=260]/marc:subfield[@code='c']"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="dataField264c">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="marc:datafield[@tag=264]/marc:subfield[@code='c']"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="controlField008-7-10" select="normalize-space(substring($controlField008, 8, 4))"/>
			<xsl:variable name="controlField008-11-14" select="normalize-space(substring($controlField008, 12, 4))"/>
			<xsl:variable name="controlField008-6" select="normalize-space(substring($controlField008, 7, 1))"/>

			<xsl:if
				test="$controlField008-6='c' or $controlField008-6='d' or $controlField008-6='i' or $controlField008-6='k' or $controlField008-6='m' or $controlField008-6='u'">
				<xsl:if test="$controlField008-7-10">
					<mods:dateIssued point="start">
						<xsl:value-of select="$controlField008-7-10"/>
					</mods:dateIssued>
				</xsl:if>
			</xsl:if>

			<xsl:if
				test="$controlField008-6='c' or $controlField008-6='d' or $controlField008-6='i' or $controlField008-6='k' or $controlField008-6='m' or $controlField008-6='u'">
				<xsl:if test="$controlField008-11-14">
					<mods:dateIssued point="end">
						<xsl:value-of select="$controlField008-11-14"/>
					</mods:dateIssued>
				</xsl:if>
			</xsl:if>

			<xsl:if test="$controlField008-6='q'">
				<xsl:if test="$controlField008-7-10">
					<mods:dateIssued encoding="w3cdtf" keyDate="yes" point="start" qualifier="questionable">
						<xsl:value-of select="$controlField008-7-10"/>
					</mods:dateIssued>
				</xsl:if>
			</xsl:if>
			<xsl:if test="$controlField008-6='q'">
				<xsl:if test="$controlField008-11-14">
					<mods:dateIssued encoding="w3cdtf" point="end" qualifier="questionable">
						<xsl:value-of select="$controlField008-11-14"/>
					</mods:dateIssued>
				</xsl:if>
			</xsl:if>


			<!-- tmee 1.77 008-06 dateIssued for value 's' -->
			<xsl:if test="$controlField008-6='s'">
				<xsl:if test="$controlField008-7-10">
					<mods:dateIssued>
						<xsl:value-of select="$controlField008-7-10"/>
					</mods:dateIssued>
				</xsl:if>
			</xsl:if>
			<xsl:if test="$controlField008-6='t'">
				<xsl:if test="$controlField008-11-14">
					<mods:dateIssued keyDate="yes" encoding="w3cdtf">
						<xsl:value-of select="$controlField008-7-10"/>
					</mods:dateIssued>
					<mods:copyrightDate encoding="w3cdtf">
						<xsl:value-of select="$controlField008-11-14"/>
					</mods:copyrightDate>
				</xsl:if>
			</xsl:if>

			<xsl:for-each select="marc:datafield[@tag=250]/marc:subfield[@code='a']">
				<mods:edition>
					<xsl:value-of select="."/>
				</mods:edition>
			</xsl:for-each>
		</mods:originInfo>

		<xsl:for-each select="marc:datafield[@tag=880]">
			<xsl:variable name="related_datafield" select="substring-before(marc:subfield[@code='6'],'-')"/>
			<xsl:variable name="occurence_number"
				select="substring( substring-after(marc:subfield[@code='6'],'-') , 1 , 2 )"/>
			<xsl:variable name="hit"
				select="../marc:datafield[@tag=$related_datafield and contains(marc:subfield[@code='6'] , concat('880-' , $occurence_number))]/@tag"/>

			<xsl:choose>
				<xsl:when test="$hit='260'">
					<mods:originInfo eventType="publication">
						<xsl:call-template name="scriptCode"/>
						<xsl:for-each
							select="../marc:datafield[@tag=260 and marc:subfield[@code='a' or code='b' or @code='c' or code='g']]">
							<xsl:call-template name="z2xx880"/>
						</xsl:for-each>
						<xsl:if test="marc:subfield[@code='a']">
							<mods:place>
								<mods:placeTerm type="text">
									<xsl:value-of select="marc:subfield[@code='a']"/>
								</mods:placeTerm>
							</mods:place>
						</xsl:if>
						<xsl:if test="marc:subfield[@code='b']">
							<mods:publisher>
								<xsl:value-of select="marc:subfield[@code='b']"/>
							</mods:publisher>
						</xsl:if>
						<xsl:if test="marc:subfield[@code='c']">
							<mods:dateIssued keyDate="yes" encoding="w3cdtf">
								<xsl:value-of select="marc:subfield[@code='c']"/>
							</mods:dateIssued>
						</xsl:if>
						<xsl:if test="marc:subfield[@code='g']">
							<mods:dateCreated>
								<xsl:value-of select="marc:subfield[@code='g']"/>
							</mods:dateCreated>
						</xsl:if>
						<xsl:for-each
							select="../marc:datafield[@tag=880]/marc:subfield[@code=6][contains(text(),'250')]">
							<mods:edition>
								<xsl:value-of select="following-sibling::marc:subfield"/>
							</mods:edition>
						</xsl:for-each>
					</mods:originInfo>
				</xsl:when>
				<xsl:when test="$hit='264'">
					<mods:originInfo eventType="publication">
						<xsl:call-template name="scriptCode"/>
						<xsl:for-each
							select="../marc:datafield[@tag=264 and marc:subfield[@code='a' or code='b' or @code='c' or code='g']]">
							<xsl:call-template name="z2xx880"/>
						</xsl:for-each>
						<xsl:if test="marc:subfield[@code='a']">
							<mods:place>
								<mods:placeTerm type="text">
									<xsl:value-of select="marc:subfield[@code='a']"/>
								</mods:placeTerm>
							</mods:place>
						</xsl:if>
						<xsl:if test="marc:subfield[@code='b']">
							<mods:publisher>
								<xsl:value-of select="marc:subfield[@code='b']"/>
							</mods:publisher>
						</xsl:if>
						<xsl:if test="marc:subfield[@code='c']">
							<mods:dateIssued>
								<xsl:value-of select="marc:subfield[@code='c']"/>
							</mods:dateIssued>
						</xsl:if>
						<xsl:if test="marc:subfield[@code='g']">
							<mods:dateCreated>
								<xsl:value-of select="marc:subfield[@code='g']"/>
							</mods:dateCreated>
						</xsl:if>
						<xsl:for-each
							select="../marc:datafield[@tag=880]/marc:subfield[@code=6][contains(text(),'250')]">
							<mods:edition>
								<xsl:value-of select="following-sibling::marc:subfield"/>
							</mods:edition>
						</xsl:for-each>
					</mods:originInfo>
				</xsl:when>
				<xsl:when test="$hit='300'">
					<mods:physicalDescription>
						<xsl:for-each select="../marc:datafield[@tag=300]">
							<xsl:call-template name="z3xx880"/>
						</xsl:for-each>
						<mods:extent>
							<xsl:for-each select="marc:subfield">
								<xsl:if test="@code='a' or @code='3' or @code='b' or @code='c'">
									<xsl:value-of select="."/>
									<xsl:text> </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</mods:extent>
					</mods:physicalDescription>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>

		<!-- 041 -->
		<xsl:variable name="controlField008-35-37"
			select="normalize-space(translate(substring($controlField008,36,3),'|#',''))"/>
		<xsl:if test="$controlField008-35-37">
			<mods:language>
				<mods:languageTerm authority="iso639-2b" type="code">
					<xsl:value-of select="substring($controlField008,36,3)"/>
				</mods:languageTerm>
				<xsl:if test="substring($controlField008,36,3)='eng'">
					<mods:languageTerm authority="iso639-2b" type="text">English</mods:languageTerm>
				</xsl:if>
			</mods:language>
		</xsl:if>
		<xsl:for-each select="marc:datafield[@tag=041]">
			<xsl:for-each
				select="marc:subfield[@code='a' or @code='b' or @code='d' or @code='e' or @code='f' or @code='g' or @code='h']">
				<xsl:variable name="langCodes" select="."/>
				<xsl:choose>
					<xsl:when test="../marc:subfield[@code='2']='rfc3066'">
						<!-- not stacked but could be repeated -->
						<xsl:call-template name="rfcLanguages">
							<xsl:with-param name="nodeNum">
								<xsl:value-of select="1"/>
							</xsl:with-param>
							<xsl:with-param name="usedLanguages">
								<xsl:text/>
							</xsl:with-param>
							<xsl:with-param name="controlField008-35-37">
								<xsl:value-of select="$controlField008-35-37"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<!-- iso -->
						<xsl:variable name="allLanguages">
							<xsl:copy-of select="$langCodes"/>
						</xsl:variable>
						<xsl:variable name="currentLanguage">
							<xsl:value-of select="substring($allLanguages,1,3)"/>
						</xsl:variable>
						<xsl:call-template name="isoLanguage">
							<xsl:with-param name="currentLanguage">
								<xsl:value-of select="substring($allLanguages,1,3)"/>
							</xsl:with-param>
							<xsl:with-param name="remainingLanguages">
								<xsl:value-of select="substring($allLanguages,4,string-length($allLanguages)-3)"/>
							</xsl:with-param>
							<xsl:with-param name="usedLanguages">
								<xsl:if test="$controlField008-35-37">
									<xsl:value-of select="$controlField008-35-37"/>
								</xsl:if>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:for-each>

		<xsl:variable name="physicalDescription">
			<!--3.2 change tmee 007/11 -->
			<xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='a']">
				<mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
			</xsl:if>
			<xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='b']">
				<mods:digitalOrigin>digitized microfilm</mods:digitalOrigin>
			</xsl:if>
			<xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='d']">
				<mods:digitalOrigin>digitized other analog</mods:digitalOrigin>
			</xsl:if>
			<xsl:variable name="controlField008-23" select="substring($controlField008,24,1)"/>
			<xsl:variable name="controlField008-29" select="substring($controlField008,30,1)"/>
			<xsl:variable name="check008-23">
				<xsl:if test="$typeOf008='BK' or $typeOf008='MU' or $typeOf008='SE' or $typeOf008='MM'">
					<xsl:value-of select="true()"/>
				</xsl:if>
			</xsl:variable>
			<xsl:variable name="check008-29">
				<xsl:if test="$typeOf008='MP' or $typeOf008='VM'">
					<xsl:value-of select="true()"/>
				</xsl:if>
			</xsl:variable>

			<xsl:if test="not(marc:datafield[@tag='655'][@ind2='4'][marc:subfield[@code='a']])">
				<xsl:for-each select="marc:datafield[@tag='655'][marc:subfield[@code='a']]">
					<xsl:if test="starts-with(marc:subfield[@code='a'],'Dime novels')">
						<form authority="local">Dime novels</form>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<xsl:for-each select="marc:datafield[@tag='655'][@ind2='4'][marc:subfield[@code='a']]">
				<xsl:if test="starts-with(marc:subfield[@code='a'],'Nickel weeklies')">
					<form authority="local">Nickel weeklies</form>
				</xsl:if>
				<xsl:if test="starts-with(marc:subfield[@code='a'],'Penny dreadfuls')">
					<form authority="local">Penny dreadfuls</form>
				</xsl:if>
				<xsl:if test="starts-with(marc:subfield[@code='a'],'Story papers')">
					<form authority="local">Story papers</form>
				</xsl:if>
			</xsl:for-each>

			<mods:form authority="rdacontent" type="content">text</mods:form>
			<mods:form authority="rdamedia" type="media">computer</mods:form>
			<mods:form authority="rdacarrier" type="carrier">online resource</mods:form>
			<mods:internetMediaType>image/tiff</mods:internetMediaType>
			<mods:internetMediaType>image/jp2</mods:internetMediaType>
			<mods:internetMediaType>image/jpeg</mods:internetMediaType>
			<mods:internetMediaType>application/pdf</mods:internetMediaType>
			<mods:internetMediaType>text/plain</mods:internetMediaType>
			<mods:digitalOrigin>reformatted digital</mods:digitalOrigin>

			<xsl:for-each select="marc:datafield[@tag=300][marc:subfield[@code='a']]">
				<mods:extent unit="pages">
					<xsl:if test="contains(.,' pages')">
						<xsl:value-of select="substring-before(., ' pages')"/>
					</xsl:if>
					<xsl:if test="contains(.,' p.')">
						<xsl:value-of select="substring-before(., ' p.')"/>
					</xsl:if>
				</mods:extent>
			</xsl:for-each>
			<!-- 1.43 tmee 351 3abc-->
			<xsl:for-each select="marc:datafield[@tag=351]">
				<mods:note type="arrangement">
					<xsl:for-each select="marc:subfield[@code='3']">
						<xsl:value-of select="."/>
						<xsl:text>: </xsl:text>
					</xsl:for-each>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">abc</xsl:with-param>
					</xsl:call-template>
				</mods:note>
			</xsl:for-each>
		</xsl:variable>

		<xsl:if test="string-length(normalize-space($physicalDescription))">
			<mods:physicalDescription>
				<xsl:for-each select="marc:datafield[@tag=300]">
					<xsl:call-template name="z3xx880"/>
				</xsl:for-each>
				<xsl:copy-of select="$physicalDescription"/>
			</mods:physicalDescription>
		</xsl:if>

		<xsl:for-each select="marc:datafield[@tag=520]">
			<xsl:call-template name="createAbstractFrom520"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=505]">
			<xsl:call-template name="createTOCFrom505"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=506]">
			<xsl:call-template name="createAccessConditionFrom506"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=540]">
			<xsl:call-template name="createAccessConditionFrom540"/>
		</xsl:for-each>

		<!-- 245c 362az 502-585 5XX-->


		<xsl:for-each select="marc:datafield[@tag=245]">
			<xsl:call-template name="createNoteFrom245c"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=362]">
			<xsl:call-template name="createNoteFrom362"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=500]">
			<xsl:call-template name="createNoteFrom500"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=502]">
			<xsl:call-template name="createNoteFrom502"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=504]">
			<xsl:call-template name="createNoteFrom504"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=508]">
			<xsl:call-template name="createNoteFrom508"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=511]">
			<xsl:call-template name="createNoteFrom511"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=515]">
			<xsl:call-template name="createNoteFrom515"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=518]">
			<xsl:call-template name="createNoteFrom518"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=524]">
			<xsl:call-template name="createNoteFrom524"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=530]">
			<xsl:call-template name="createNoteFrom530"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=533]">
			<xsl:call-template name="createNoteFrom533"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=534]">
			<xsl:call-template name="createNoteFrom534"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=535]">
			<xsl:call-template name="createNoteFrom535"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=536]">
			<xsl:call-template name="createNoteFrom536"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=538]">
			<xsl:call-template name="createNoteFrom538"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=541]">
			<xsl:call-template name="createNoteFrom541"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=545]">
			<xsl:call-template name="createNoteFrom545"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=546]">
			<xsl:call-template name="createNoteFrom546"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=561]">
			<xsl:call-template name="createNoteFrom561"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=562]">
			<xsl:call-template name="createNoteFrom562"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=581]">
			<xsl:call-template name="createNoteFrom581"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=583]">
			<xsl:call-template name="createNoteFrom583"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=585]">
			<xsl:call-template name="createNoteFrom585"/>
		</xsl:for-each>

		<xsl:for-each
			select="marc:datafield[@tag=501 or @tag=507 or @tag=513 or @tag=514 or @tag=516 or @tag=522 or @tag=525 or @tag=526 or @tag=544 or @tag=547 or @tag=550 or @tag=552 or @tag=555 or @tag=556 or @tag=565 or @tag=567 or @tag=580 or @tag=584 or @tag=586]">
			<xsl:call-template name="createNoteFrom5XX"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=034]">
			<xsl:call-template name="createSubGeoFrom034"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=045]">
			<xsl:call-template name="createSubTemFrom045"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=255]">
			<xsl:call-template name="createSubGeoFrom255"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=600]">
			<xsl:call-template name="createSubNameFrom600"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=610]">
			<xsl:call-template name="createSubNameFrom610"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=611]">
			<xsl:call-template name="createSubNameFrom611"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=630]">
			<xsl:call-template name="createSubTitleFrom630"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=648]">
			<xsl:call-template name="createSubChronFrom648"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=650]">
			<xsl:call-template name="createSubTopFrom650"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=651]">
			<xsl:call-template name="createSubGeoFrom651"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=653]">
			<xsl:call-template name="createSubFrom653"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=656]">
			<xsl:call-template name="createSubFrom656"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=662]">
			<xsl:call-template name="createSubGeoFrom662752"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=752]">
			<xsl:call-template name="createSubGeoFrom662752"/>
		</xsl:for-each>

		<!-- createClassificationFrom 0XX-->
		<xsl:for-each select="marc:datafield[@tag='090']">
			<xsl:call-template name="createClassificationFrom090"/>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='050']">
			<xsl:call-template name="createClassificationFrom050"/>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='060']">
			<xsl:call-template name="createClassificationFrom060"/>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='080']">
			<xsl:call-template name="createClassificationFrom080"/>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='082']">
			<xsl:call-template name="createClassificationFrom082"/>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='084']">
			<xsl:call-template name="createClassificationFrom084"/>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='086']">
			<xsl:call-template name="createClassificationFrom086"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=856]">
			<xsl:call-template name="createLocationFrom856"/>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=440]">
			<mods:relatedItem type="series">
				<mods:titleInfo>
					<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">a</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:title>
					<xsl:call-template name="part"/>
				</mods:titleInfo>
			</mods:relatedItem>
		</xsl:for-each>

		<!-- tmee 1.40 1.74-->

		<xsl:for-each select="marc:datafield[@tag=700][marc:subfield[@code='t']]">
			<mods:relatedItem type="constituent">
				<xsl:call-template name="constituentOrRelatedType"/>
				<xsl:variable name="constituentTitle">
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:call-template name="subfieldSelect">
								<!-- 1/04 removed $h, b -->
								<xsl:with-param name="codes">t</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="constituentTitleChop">
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:value-of select="$constituentTitle"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<mods:titleInfo>
					<xsl:choose>
						<xsl:when test="(starts-with($constituentTitle,'The '))">
							<mods:nonSort>The</mods:nonSort>
							<mods:title>
								<xsl:value-of select="substring-after($constituentTitle,'The ')"/>
							</mods:title>
						</xsl:when>
						<xsl:when test="(starts-with($constituentTitle,'An'))">
							<mods:nonSort>An</mods:nonSort>
							<mods:title>
								<xsl:value-of select="substring-after($constituentTitle,'An ')"/>
							</mods:title>
						</xsl:when>
						<xsl:when test="(starts-with($constituentTitle,'A '))">
							<mods:nonSort>A</mods:nonSort>
							<mods:title>
								<xsl:value-of select="substring-after($constituentTitle,'A ')"/>
							</mods:title>
						</xsl:when>
						<xsl:otherwise>
							<mods:title>
								<xsl:value-of select="$constituentTitle"/>
							</mods:title>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:call-template name="part"/>
				</mods:titleInfo>
				<mods:name type="personal">
					<xsl:call-template name="createNameFrom700"/>
				</mods:name>
				<xsl:call-template name="relatedForm"/>
				<xsl:call-template name="relatedIdentifierISSN"/>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=710][marc:subfield[@code='t']]">
			<mods:relatedItem type="constituent">
				<xsl:call-template name="constituentOrRelatedType"/>
				<mods:titleInfo>
					<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="specialSubfieldSelect">
									<xsl:with-param name="anyCodes">tfklmorsv</xsl:with-param>
									<xsl:with-param name="axis">t</xsl:with-param>
									<xsl:with-param name="afterCodes">dg</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:title>
					<xsl:call-template name="relatedPartNumName"/>
				</mods:titleInfo>
				<mods:name type="corporate">
					<xsl:for-each select="marc:subfield[@code='a']">
						<mods:namePart>
							<xsl:value-of select="."/>
						</mods:namePart>
					</xsl:for-each>
					<xsl:for-each select="marc:subfield[@code='b']">
						<mods:namePart>
							<xsl:value-of select="."/>
						</mods:namePart>
					</xsl:for-each>
					<xsl:variable name="tempNamePart">
						<xsl:call-template name="specialSubfieldSelect">
							<xsl:with-param name="anyCodes">c</xsl:with-param>
							<xsl:with-param name="axis">t</xsl:with-param>
							<xsl:with-param name="beforeCodes">dgn</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<xsl:if test="normalize-space($tempNamePart)">
						<mods:namePart>
							<xsl:value-of select="$tempNamePart"/>
						</mods:namePart>
					</xsl:if>
					<xsl:call-template name="role"/>
				</mods:name>
				<xsl:call-template name="relatedForm"/>
				<xsl:call-template name="relatedIdentifierISSN"/>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=711][marc:subfield[@code='t']]">
			<mods:relatedItem type="constituent">
				<xsl:call-template name="constituentOrRelatedType"/>
				<mods:titleInfo>
					<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="specialSubfieldSelect">
									<xsl:with-param name="anyCodes">tfklsv</xsl:with-param>
									<xsl:with-param name="axis">t</xsl:with-param>
									<xsl:with-param name="afterCodes">g</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:title>
					<xsl:call-template name="relatedPartNumName"/>
				</mods:titleInfo>
				<mods:name type="conference">
					<mods:namePart>
						<xsl:call-template name="specialSubfieldSelect">
							<xsl:with-param name="anyCodes">aqdc</xsl:with-param>
							<xsl:with-param name="axis">t</xsl:with-param>
							<xsl:with-param name="beforeCodes">gn</xsl:with-param>
						</xsl:call-template>
					</mods:namePart>
				</mods:name>
				<xsl:call-template name="relatedForm"/>
				<xsl:call-template name="relatedIdentifierISSN"/>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=730][@ind2=2]">
			<mods:relatedItem type="constituent">
				<xsl:call-template name="constituentOrRelatedType"/>
				<mods:titleInfo>
					<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">adfgklmorsv</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:title>
					<xsl:call-template name="part"/>
				</mods:titleInfo>
				<xsl:call-template name="relatedForm"/>
				<xsl:call-template name="relatedIdentifierISSN"/>
			</mods:relatedItem>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=760]">
			<mods:relatedItem type="series">
				<xsl:call-template name="relatedItem76X-78X"/>
			</mods:relatedItem>
		</xsl:for-each>

		<!--AQ1.23 tmee/dlf -->
		<xsl:for-each select="marc:datafield[@tag=762]">
			<mods:relatedItem type="constituent">
				<xsl:call-template name="relatedItem76X-78X"/>
			</mods:relatedItem>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=770]|marc:datafield[@tag=774]">
			<mods:relatedItem type="constituent">
				<xsl:call-template name="relatedItem76X-78X"/>
			</mods:relatedItem>
		</xsl:for-each>


		<xsl:for-each select="marc:datafield[@tag=772]|marc:datafield[@tag=773]">
			<mods:relatedItem type="host">
				<xsl:call-template name="relatedItem76X-78X"/>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=776]">
			<mods:relatedItem type="otherFormat">
				<xsl:call-template name="relatedItem76X-78X"/>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=780]">
			<mods:relatedItem type="preceding">
				<xsl:call-template name="relatedItem76X-78X"/>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=785]">
			<mods:relatedItem type="succeeding">
				<xsl:call-template name="relatedItem76X-78X"/>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=786]">
			<mods:relatedItem type="original">
				<xsl:call-template name="relatedItem76X-78X"/>
			</mods:relatedItem>
		</xsl:for-each>

		<xsl:call-template name="relatedForm"/>
		<mods:relatedItem type="series">
			<xsl:for-each select="marc:datafield[@tag='490']">
				<mods:titleInfo>
					<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">adfgklmors</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:title>
					<xsl:call-template name="part"/>
				</mods:titleInfo>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag='830']">
				<mods:titleInfo type="uniform">
					<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">adfgklmors</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:title>
					<xsl:call-template name="part"/>
				</mods:titleInfo>
			</xsl:for-each>
		</mods:relatedItem>

		<!-- 856, 020, 024, 022, 028, 010, 035, 037 -->

		<xsl:for-each select="marc:datafield[@tag='020']">
			<xsl:if test="marc:subfield[@code='a']">
				<mods:identifier type="isbn">
					<xsl:value-of select="marc:subfield[@code='a']"/>
				</mods:identifier>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='020']">
			<xsl:if test="marc:subfield[@code='z']">
				<mods:identifier type="isbn" invalid="yes">
					<xsl:value-of select="marc:subfield[@code='z']"/>
				</mods:identifier>
			</xsl:if>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='024'][@ind1='8']">
			<mods:identifier>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</mods:identifier>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='022'][marc:subfield[@code='a']]">
			<xsl:if test="marc:subfield[@code='a']">
				<mods:identifier type="issn">
					<xsl:value-of select="marc:subfield[@code='a']"/>
				</mods:identifier>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='022'][marc:subfield[@code='z']]">
			<xsl:if test="marc:subfield[@code='z']">
				<mods:identifier type="issn" invalid="yes">
					<xsl:value-of select="marc:subfield[@code='z']"/>
				</mods:identifier>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='022'][marc:subfield[@code='y']]">
			<xsl:if test="marc:subfield[@code='y']">
				<mods:identifier type="issn" invalid="yes">
					<xsl:value-of select="marc:subfield[@code='y']"/>
				</mods:identifier>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='022'][marc:subfield[@code='l']]">
			<xsl:if test="marc:subfield[@code='l']">
				<mods:identifier type="issn-l">
					<xsl:value-of select="marc:subfield[@code='l']"/>
				</mods:identifier>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='022'][marc:subfield[@code='m']]">
			<xsl:if test="marc:subfield[@code='m']">
				<mods:identifier type="issn-l" invalid="yes">
					<xsl:value-of select="marc:subfield[@code='m']"/>
				</mods:identifier>
			</xsl:if>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='010'][marc:subfield[@code='a']]">
			<mods:identifier type="lccn">
				<xsl:value-of select="normalize-space(marc:subfield[@code='a'])"/>
			</mods:identifier>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='010'][marc:subfield[@code='z']]">
			<mods:identifier type="lccn" invalid="yes">
				<xsl:value-of select="normalize-space(marc:subfield[@code='z'])"/>
			</mods:identifier>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='028']">
			<mods:identifier>
				<xsl:attribute name="type">
					<xsl:choose>
						<xsl:when test="@ind1='0'">issue number</xsl:when>
						<xsl:when test="@ind1='1'">matrix number</xsl:when>
						<xsl:when test="@ind1='2'">music plate</xsl:when>
						<xsl:when test="@ind1='3'">music publisher</xsl:when>
						<xsl:when test="@ind1='4'">videorecording identifier</xsl:when>
					</xsl:choose>
				</xsl:attribute>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">
						<xsl:choose>
							<xsl:when test="@ind1='0'">ba</xsl:when>
							<xsl:otherwise>ab</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</mods:identifier>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='035'][marc:subfield[@code='a'][contains(text(), '(OCoLC)')]]">
			<mods:identifier type="oclc">
				<xsl:value-of select="normalize-space(substring-after(marc:subfield[@code='a'], '(OCoLC)'))"/>
			</mods:identifier>
		</xsl:for-each>

		<!-- 1.51 tmee 20100129-->
		<xsl:for-each select="marc:datafield[@tag='856'][marc:subfield[@code='u']]">
			<xsl:if
				test="starts-with(marc:subfield[@code='u'],'urn:hdl') or starts-with(marc:subfield[@code='u'],'hdl') or starts-with(marc:subfield[@code='u'],'http://hdl.loc.gov') ">
				<mods:identifier>
					<xsl:attribute name="type">
						<xsl:if
							test="starts-with(marc:subfield[@code='u'],'urn:doi') or starts-with(marc:subfield[@code='u'],'doi')"
							>doi</xsl:if>
						<xsl:if
							test="starts-with(marc:subfield[@code='u'],'urn:hdl') or starts-with(marc:subfield[@code='u'],'hdl') or starts-with(marc:subfield[@code='u'],'http://hdl.loc.gov')"
							>hdl</xsl:if>
					</xsl:attribute>
					<xsl:value-of
						select="concat('hdl:',substring-after(marc:subfield[@code='u'],'http://hdl.loc.gov/'))"/>
				</mods:identifier>
			</xsl:if>


			<xsl:if
				test="starts-with(marc:subfield[@code='u'],'urn:hdl') or starts-with(marc:subfield[@code='u'],'hdl')">
				<mods:identifier type="hdl">
					<xsl:if test="marc:subfield[@code='y' or @code='3' or @code='z']">
						<xsl:attribute name="displayLabel">
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">y3z</xsl:with-param>
							</xsl:call-template>
						</xsl:attribute>
					</xsl:if>
					<xsl:value-of
						select="concat('hdl:',substring-after(marc:subfield[@code='u'],'http://hdl.loc.gov/'))"/>
				</mods:identifier>
			</xsl:if>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=024][@ind1=1]">
			<mods:identifier type="upc">
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</mods:identifier>
		</xsl:for-each>


		<!-- 1.51 tmee 20100129-->
		<xsl:for-each select="marc:datafield[@tag='856'][marc:subfield[@code='u']]">
			<xsl:if
				test="starts-with(marc:subfield[@code='u'],'urn:hdl') or starts-with(marc:subfield[@code='u'],'hdl') or starts-with(marc:subfield[@code='u'],'http://hdl.loc.gov') ">
				<mods:identifier>
					<xsl:attribute name="type">
						<xsl:if
							test="starts-with(marc:subfield[@code='u'],'urn:doi') or starts-with(marc:subfield[@code='u'],'doi')"
							>doi</xsl:if>
						<xsl:if
							test="starts-with(marc:subfield[@code='u'],'urn:hdl') or starts-with(marc:subfield[@code='u'],'hdl') or starts-with(marc:subfield[@code='u'],'http://hdl.loc.gov')"
							>hdl</xsl:if>
					</xsl:attribute>
					<xsl:value-of
						select="concat('hdl:',substring-after(marc:subfield[@code='u'],'http://hdl.loc.gov/'))"/>
				</mods:identifier>
			</xsl:if>

			<xsl:if
				test="starts-with(marc:subfield[@code='u'],'urn:hdl') or starts-with(marc:subfield[@code='u'],'hdl')">
				<mods:identifier type="hdl">
					<xsl:if test="marc:subfield[@code='y' or @code='3' or @code='z']">
						<xsl:attribute name="displayLabel">
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">y3z</xsl:with-param>
							</xsl:call-template>
						</xsl:attribute>
					</xsl:if>
					<xsl:value-of
						select="concat('hdl:',substring-after(marc:subfield[@code='u'],'http://hdl.loc.gov/'))"/>
				</mods:identifier>
			</xsl:if>
		</xsl:for-each>


		<xsl:for-each select="marc:datafield[@tag=856][@ind2=2][marc:subfield[@code='u']]">
			<mods:relatedItem>
				<mods:location>
					<mods:url>
						<xsl:if test="marc:subfield[@code='y' or @code='3']">
							<xsl:attribute name="displayLabel">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">y3</xsl:with-param>
								</xsl:call-template>
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="marc:subfield[@code='z']">
							<xsl:attribute name="note">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">z</xsl:with-param>
								</xsl:call-template>
							</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="marc:subfield[@code='u']"/>
					</mods:url>
				</mods:location>
			</mods:relatedItem>
		</xsl:for-each>

		<mods:relatedItem type="host">
			<mods:titleInfo>
				<title>Nickels and Dimes</title>
			</mods:titleInfo>
			<mods:location>
				<url>http://www.dimenovels.lib.niu.edu</url>
			</mods:location>
		</mods:relatedItem>

		<mods:location>
			<mods:physicalLocation authority="oclcorg">JNA</mods:physicalLocation>
			<mods:physicalLocation authority="NIUdb">fmlspx</mods:physicalLocation>
			<mods:physicalLocation>
				<xsl:value-of select="//marc:datafield[@tag=791][@ind1=2][marc:subfield[@code='a']]"/>
				<xsl:text> Rare Books and Special Collections, Northern Illinois University.</xsl:text>
			</mods:physicalLocation>
			<mods:shelfLocator>
				<xsl:for-each select="marc:datafield[@tag='090']">
					<xsl:call-template name="xxx880"/>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">ab</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</mods:shelfLocator>
		</mods:location>

		<mods:accessCondition type="useAndReproduction">Use of this public-domain resource is
			unrestricted.</mods:accessCondition>

		<mods:recordInfo>
			<xsl:for-each select="marc:leader[substring($leader,19,1)='a']">
				<mods:descriptionStandard>rda</mods:descriptionStandard>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=040]">
				<xsl:if test="marc:subfield[@code='e']">
					<mods:descriptionStandard>
						<xsl:value-of select="marc:subfield[@code='e']"/>
					</mods:descriptionStandard>
				</xsl:if>
				<mods:recordContentSource authority="oclcorg">
					<xsl:value-of select="marc:subfield[@code='a']"/>
				</mods:recordContentSource>
			</xsl:for-each>
			<xsl:for-each select="marc:controlfield[@tag=008]">
				<mods:recordCreationDate encoding="marc">
					<xsl:value-of select="substring(.,1,6)"/>
				</mods:recordCreationDate>
			</xsl:for-each>

			<xsl:for-each select="marc:controlfield[@tag=005]">
				<mods:recordChangeDate encoding="iso8601">
					<xsl:value-of select="."/>
				</mods:recordChangeDate>
			</xsl:for-each>
			<xsl:for-each select="marc:controlfield[@tag=001]">
				<mods:recordIdentifier source="NIUDb">
					<xsl:value-of select="."/>
				</mods:recordIdentifier>
			</xsl:for-each>

			<mods:recordOrigin>Converted from MARCXML to MODS version 3.5 using MARC21slim2MODS3-4.xsl, modified for
				MODS version 3.5 and Nickels and Dimes by Matthew Short</mods:recordOrigin>

			<xsl:for-each select="marc:datafield[@tag=040]/marc:subfield[@code='b']">
				<mods:languageOfCataloging>
					<mods:languageTerm authority="iso639-2b" type="code">
						<xsl:value-of select="."/>
					</mods:languageTerm>
				</mods:languageOfCataloging>
			</xsl:for-each>
		</mods:recordInfo>
	</xsl:template>

	<xsl:template name="displayForm">
		<xsl:for-each select="marc:subfield[@code='c']">
			<mods:displayForm>
				<xsl:value-of select="."/>
			</mods:displayForm>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="affiliation">
		<xsl:for-each select="marc:subfield[@code='u']">
			<mods:affiliation>
				<xsl:value-of select="."/>
			</mods:affiliation>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="uri">
		<xsl:for-each select="marc:subfield[@code='u']|marc:subfield[@code='0']">
			<xsl:attribute name="xlink:href">
				<xsl:value-of select="."/>
			</xsl:attribute>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="role">
		<xsl:for-each select="marc:subfield[@code='e']">
			<mods:role>
				<mods:roleTerm type="text">
					<xsl:call-template name="chopPunctuationFront">
						<xsl:with-param name="chopString">
							<xsl:call-template name="chopPunctuation">
								<xsl:with-param name="chopString" select="."/>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</mods:roleTerm>
			</mods:role>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code='4']">
			<mods:role>
				<mods:roleTerm authority="marcrelator" type="code">
					<xsl:value-of select="."/>
				</mods:roleTerm>
			</mods:role>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="part">
		<xsl:variable name="partNumber">
			<xsl:call-template name="specialSubfieldSelect">
				<xsl:with-param name="axis">nv</xsl:with-param>
				<xsl:with-param name="anyCodes">nv</xsl:with-param>
				<xsl:with-param name="afterCodes">fgkdlmor</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="partName">
			<xsl:call-template name="specialSubfieldSelect">
				<xsl:with-param name="axis">p</xsl:with-param>
				<xsl:with-param name="anyCodes">p</xsl:with-param>
				<xsl:with-param name="afterCodes">fgkdlmor</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string-length(normalize-space($partNumber))">
			<mods:partNumber>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="$partNumber"/>
				</xsl:call-template>
			</mods:partNumber>
		</xsl:if>
		<xsl:if test="string-length(normalize-space($partName))">
			<mods:partName>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="$partName"/>
				</xsl:call-template>
			</mods:partName>
		</xsl:if>
	</xsl:template>
	<xsl:template name="relatedPart">
		<xsl:if test="@tag=773">
			<xsl:for-each select="marc:subfield[@code='g']">
				<mods:part>
					<mods:text>
						<xsl:value-of select="."/>
					</mods:text>
				</mods:part>
			</xsl:for-each>
			<xsl:for-each select="marc:subfield[@code='q']">
				<mods:part>
					<xsl:call-template name="parsePart"/>
				</mods:part>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<xsl:template name="relatedPartNumName">
		<xsl:variable name="partNumber">
			<xsl:call-template name="specialSubfieldSelect">
				<xsl:with-param name="axis">g</xsl:with-param>
				<xsl:with-param name="anyCodes">g</xsl:with-param>
				<xsl:with-param name="afterCodes">pst</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="partName">
			<xsl:call-template name="specialSubfieldSelect">
				<xsl:with-param name="axis">p</xsl:with-param>
				<xsl:with-param name="anyCodes">p</xsl:with-param>
				<xsl:with-param name="afterCodes">fgkdlmor</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string-length(normalize-space($partNumber))">
			<mods:partNumber>
				<xsl:value-of select="$partNumber"/>
			</mods:partNumber>
		</xsl:if>
		<xsl:if test="string-length(normalize-space($partName))">
			<mods:partName>
				<xsl:value-of select="$partName"/>
			</mods:partName>
		</xsl:if>
	</xsl:template>
	<xsl:template name="relatedName">
		<xsl:for-each select="marc:subfield[@code='a']">
			<mods:name>
				<mods:namePart>
					<xsl:value-of select="."/>
				</mods:namePart>
			</mods:name>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedForm">
		<xsl:for-each select="marc:subfield[@code='h']">
			<mods:physicalDescription>
				<mods:form>
					<xsl:value-of select="."/>
				</mods:form>
			</mods:physicalDescription>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedExtent">
		<xsl:for-each select="marc:subfield[@code='h']">
			<mods:physicalDescription>
				<mods:extent>
					<xsl:value-of select="."/>
				</mods:extent>
			</mods:physicalDescription>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedNote">
		<xsl:for-each select="marc:subfield[@code='n']">
			<mods:note>
				<xsl:value-of select="."/>
			</mods:note>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedSubject">
		<xsl:for-each select="marc:subfield[@code='j']">
			<mods:subject>
				<mods:temporal encoding="iso8601">
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString" select="."/>
					</xsl:call-template>
				</mods:temporal>
			</mods:subject>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedIdentifierISSN">
		<xsl:for-each select="marc:subfield[@code='x']">
			<mods:identifier type="issn">
				<xsl:value-of select="."/>
			</mods:identifier>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedIdentifierLocal">
		<xsl:for-each select="marc:subfield[@code='w']">
			<mods:identifier type="local">
				<xsl:value-of select="."/>
			</mods:identifier>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedIdentifier">
		<xsl:for-each select="marc:subfield[@code='o']">
			<mods:identifier>
				<xsl:value-of select="."/>
			</mods:identifier>
		</xsl:for-each>
	</xsl:template>

	<!--tmee 1.40 510 isReferencedBy -->
	<xsl:template name="relatedItem510">
		<xsl:call-template name="displayLabel"/>
		<xsl:call-template name="relatedTitle76X-78X"/>
		<xsl:call-template name="relatedName"/>
		<xsl:call-template name="relatedOriginInfo510"/>
		<xsl:call-template name="relatedLanguage"/>
		<xsl:call-template name="relatedExtent"/>
		<xsl:call-template name="relatedNote"/>
		<xsl:call-template name="relatedSubject"/>
		<xsl:call-template name="relatedIdentifier"/>
		<xsl:call-template name="relatedIdentifierISSN"/>
		<xsl:call-template name="relatedIdentifierLocal"/>
		<xsl:call-template name="relatedPart"/>
	</xsl:template>
	<xsl:template name="relatedItem76X-78X">
		<xsl:call-template name="displayLabel"/>
		<xsl:call-template name="relatedTitle76X-78X"/>
		<xsl:call-template name="relatedName"/>
		<xsl:call-template name="relatedOriginInfo"/>
		<xsl:call-template name="relatedLanguage"/>
		<xsl:call-template name="relatedExtent"/>
		<xsl:call-template name="relatedNote"/>
		<xsl:call-template name="relatedSubject"/>
		<xsl:call-template name="relatedIdentifier"/>
		<xsl:call-template name="relatedIdentifierISSN"/>
		<xsl:call-template name="relatedIdentifierLocal"/>
		<xsl:call-template name="relatedPart"/>
	</xsl:template>
	<xsl:template name="subjectGeographicZ">
		<mods:geographic>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</mods:geographic>
	</xsl:template>
	<xsl:template name="subjectTemporalY">
		<mods:temporal>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</mods:temporal>
	</xsl:template>
	<xsl:template name="subjectTopic">
		<mods:topic>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</mods:topic>
	</xsl:template>
	<!-- 3.2 change tmee 6xx $v genre -->
	<xsl:template name="subjectGenre">
		<mods:genre>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</mods:genre>
	</xsl:template>

	<xsl:template name="nameABCDN">
		<xsl:for-each select="marc:subfield[@code='a']">
			<mods:namePart>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="."/>
				</xsl:call-template>
			</mods:namePart>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code='b']">
			<mods:namePart>
				<xsl:value-of select="."/>
			</mods:namePart>
		</xsl:for-each>
		<xsl:if test="marc:subfield[@code='c'] or marc:subfield[@code='d'] or marc:subfield[@code='n']">
			<mods:namePart>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">cdn</xsl:with-param>
				</xsl:call-template>
			</mods:namePart>
		</xsl:if>
	</xsl:template>
	<xsl:template name="nameABCDQ">
		<mods:namePart>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">aq</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="punctuation">
					<xsl:text>:,;/ </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</mods:namePart>
		<xsl:call-template name="termsOfAddress"/>
		<xsl:call-template name="nameDate"/>
	</xsl:template>
	<xsl:template name="nameACDEQ">
		<mods:namePart>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">acdeq</xsl:with-param>
			</xsl:call-template>
		</mods:namePart>
	</xsl:template>
	<xsl:template name="constituentOrRelatedType">
		<xsl:if test="@ind2=2">
			<xsl:attribute name="type">constituent</xsl:attribute>
		</xsl:if>
	</xsl:template>
	<xsl:template name="relatedTitle">
		<xsl:for-each select="marc:subfield[@code='t']">
			<mods:titleInfo>
				<mods:title>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:value-of select="."/>
						</xsl:with-param>
					</xsl:call-template>
				</mods:title>
			</mods:titleInfo>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedTitle76X-78X">
		<xsl:for-each select="marc:subfield[@code='t']">
			<mods:titleInfo>
				<mods:title>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:value-of select="."/>
						</xsl:with-param>
					</xsl:call-template>
				</mods:title>
				<xsl:if test="marc:datafield[@tag!=773]and marc:subfield[@code='g']">
					<xsl:call-template name="relatedPartNumName"/>
				</xsl:if>
			</mods:titleInfo>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code='p']">
			<mods:titleInfo type="abbreviated">
				<mods:title>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:value-of select="."/>
						</xsl:with-param>
					</xsl:call-template>
				</mods:title>
				<xsl:if test="marc:datafield[@tag!=773]and marc:subfield[@code='g']">
					<xsl:call-template name="relatedPartNumName"/>
				</xsl:if>
			</mods:titleInfo>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code='s']">
			<mods:titleInfo type="uniform">
				<mods:title>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:value-of select="."/>
						</xsl:with-param>
					</xsl:call-template>
				</mods:title>
				<xsl:if test="marc:datafield[@tag!=773]and marc:subfield[@code='g']">
					<xsl:call-template name="relatedPartNumName"/>
				</xsl:if>
			</mods:titleInfo>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedOriginInfo">
		<xsl:if test="marc:subfield[@code='b' or @code='d'] or marc:subfield[@code='f']">
			<mods:originInfo eventType="publication">
				<xsl:if test="@tag=775">
					<xsl:for-each select="marc:subfield[@code='f']">
						<mods:place>
							<mods:placeTerm>
								<xsl:attribute name="type">code</xsl:attribute>
								<xsl:attribute name="authority">marcgac</xsl:attribute>
								<xsl:value-of select="."/>
							</mods:placeTerm>
						</mods:place>
					</xsl:for-each>
				</xsl:if>
				<xsl:for-each select="marc:subfield[@code='d']">
					<mods:publisher>
						<xsl:value-of select="."/>
					</mods:publisher>
				</xsl:for-each>
				<xsl:for-each select="marc:subfield[@code='b']">
					<mods:edition>
						<xsl:value-of select="."/>
					</mods:edition>
				</xsl:for-each>
			</mods:originInfo>
		</xsl:if>
	</xsl:template>

	<!-- tmee 1.40 -->

	<xsl:template name="relatedOriginInfo510">
		<xsl:for-each select="marc:subfield[@code='b']">
			<mods:originInfo eventType="publication">
				<mods:dateOther type="coverage">
					<xsl:value-of select="."/>
				</mods:dateOther>
			</mods:originInfo>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedLanguage">
		<xsl:for-each select="marc:subfield[@code='e']">
			<xsl:call-template name="getLanguage">
				<xsl:with-param name="langString">
					<xsl:value-of select="."/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="nameDate">
		<xsl:for-each select="marc:subfield[@code='d']">
			<mods:namePart type="date">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="."/>
				</xsl:call-template>
			</mods:namePart>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="subjectAuthority">
		<xsl:if test="@ind2!=' '">
			<xsl:if test="@ind2!=8">
				<xsl:if test="@ind2!=9">
					<xsl:attribute name="authority">
						<xsl:choose>
							<xsl:when test="@ind2=0">lcsh</xsl:when>
							<xsl:when test="@ind2=1">lcshac</xsl:when>
							<xsl:when test="@ind2=2">mesh</xsl:when>
							<!-- 1/04 fix -->
							<xsl:when test="@ind2=3">nal</xsl:when>
							<xsl:when test="@ind2=4">local</xsl:when>
							<xsl:when test="@ind2=5">csh</xsl:when>
							<xsl:when test="@ind2=6">rvm</xsl:when>
							<xsl:when test="@ind2=7">
								<xsl:value-of select="marc:subfield[@code='2']"/>
							</xsl:when>
						</xsl:choose>
					</xsl:attribute>
				</xsl:if>
			</xsl:if>
		</xsl:if>

	</xsl:template>
	<!-- 1.75 
		fix -->
	<xsl:template name="subject653Type">
		<xsl:if test="@ind2!=' '">
			<xsl:if test="@ind2!='0'">
				<xsl:if test="@ind2!='4'">
					<xsl:if test="@ind2!='5'">
						<xsl:if test="@ind2!='6'">
							<xsl:if test="@ind2!='7'">
								<xsl:if test="@ind2!='8'">
									<xsl:if test="@ind2!='7'">
										<xsl:if test="@ind2!='8'">
											<xsl:if test="@ind2!='9'">
												<xsl:attribute name="type">
													<xsl:choose>
														<xsl:when test="@ind2=1">personal</xsl:when>
														<xsl:when test="@ind2=2">corporate</xsl:when>
														<xsl:when test="@ind2=3">conference</xsl:when>
													</xsl:choose>
												</xsl:attribute>
											</xsl:if>
										</xsl:if>
									</xsl:if>
								</xsl:if>
							</xsl:if>
						</xsl:if>
					</xsl:if>
				</xsl:if>
			</xsl:if>
		</xsl:if>


	</xsl:template>
	<xsl:template name="subjectAnyOrder">
		<xsl:for-each select="marc:subfield[@code='v' or @code='x' or @code='y' or @code='z']">
			<xsl:choose>
				<xsl:when test="@code='v'">
					<xsl:call-template name="subjectGenre"/>
				</xsl:when>
				<xsl:when test="@code='x'">
					<xsl:call-template name="subjectTopic"/>
				</xsl:when>
				<xsl:when test="@code='y'">
					<xsl:call-template name="subjectTemporalY"/>
				</xsl:when>
				<xsl:when test="@code='z'">
					<xsl:call-template name="subjectGeographicZ"/>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="specialSubfieldSelect">
		<xsl:param name="anyCodes"/>
		<xsl:param name="axis"/>
		<xsl:param name="beforeCodes"/>
		<xsl:param name="afterCodes"/>
		<xsl:variable name="str">
			<xsl:for-each select="marc:subfield">
				<xsl:if
					test="contains($anyCodes, @code) or (contains($beforeCodes,@code) and following-sibling::marc:subfield[@code=$axis])      or (contains($afterCodes,@code) and preceding-sibling::marc:subfield[@code=$axis])">
					<xsl:value-of select="text()"/>
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
	</xsl:template>



	<xsl:template match="marc:datafield[@tag=656]">
		<mods:subject>
			<xsl:call-template name="xxx880"/>
			<xsl:if test="marc:subfield[@code=2]">
				<xsl:attribute name="authority">
					<xsl:value-of select="marc:subfield[@code=2]"/>
				</xsl:attribute>
			</xsl:if>
			<mods:occupation>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:value-of select="marc:subfield[@code='a']"/>
					</xsl:with-param>
				</xsl:call-template>
			</mods:occupation>
		</mods:subject>
	</xsl:template>
	<xsl:template name="termsOfAddress">
		<xsl:if test="marc:subfield[@code='b' or @code='c']">
			<mods:namePart type="termsOfAddress">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">bc</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</mods:namePart>
		</xsl:if>
	</xsl:template>
	<xsl:template name="displayLabel">
		<xsl:if test="marc:subfield[@code='i']">
			<xsl:attribute name="displayLabel">
				<xsl:value-of select="marc:subfield[@code='i']"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="marc:subfield[@code='3']">
			<xsl:attribute name="displayLabel">
				<xsl:value-of select="marc:subfield[@code='3']"/>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template name="subtitle">
		<xsl:if test="marc:subfield[@code='b']">
			<mods:subTitle>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:value-of select="marc:subfield[@code='b']"/>
					</xsl:with-param>
				</xsl:call-template>
			</mods:subTitle>
		</xsl:if>
	</xsl:template>
	<xsl:template name="script">
		<xsl:param name="scriptCode"/>
		<xsl:attribute name="script">
			<xsl:choose>
				<!-- ISO 15924	and CJK is a local code	20101123-->
				<xsl:when test="$scriptCode='(3'">Arab</xsl:when>
				<xsl:when test="$scriptCode='(4'">Arab</xsl:when>
				<xsl:when test="$scriptCode='(B'">Latn</xsl:when>
				<xsl:when test="$scriptCode='!E'">Latn</xsl:when>
				<xsl:when test="$scriptCode='$1'">CJK</xsl:when>
				<xsl:when test="$scriptCode='(N'">Cyrl</xsl:when>
				<xsl:when test="$scriptCode='(Q'">Cyrl</xsl:when>
				<xsl:when test="$scriptCode='(2'">Hebr</xsl:when>
				<xsl:when test="$scriptCode='(S'">Grek</xsl:when>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>
	<xsl:template name="parsePart">
		<!-- assumes 773$q= 1:2:3<4
		     with up to 3 levels and one optional start page
		-->
		<xsl:variable name="level1">
			<xsl:choose>
				<xsl:when test="contains(text(),':')">
					<!-- 1:2 -->
					<xsl:value-of select="substring-before(text(),':')"/>
				</xsl:when>
				<xsl:when test="not(contains(text(),':'))">
					<!-- 1 or 1<3 -->
					<xsl:if test="contains(text(),'&lt;')">
						<!-- 1<3 -->
						<xsl:value-of select="substring-before(text(),'&lt;')"/>
					</xsl:if>
					<xsl:if test="not(contains(text(),'&lt;'))">
						<!-- 1 -->
						<xsl:value-of select="text()"/>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="sici2">
			<xsl:choose>
				<xsl:when test="starts-with(substring-after(text(),$level1),':')">
					<xsl:value-of select="substring(substring-after(text(),$level1),2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(text(),$level1)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="level2">
			<xsl:choose>
				<xsl:when test="contains($sici2,':')">
					<!--  2:3<4  -->
					<xsl:value-of select="substring-before($sici2,':')"/>
				</xsl:when>
				<xsl:when test="contains($sici2,'&lt;')">
					<!-- 1: 2<4 -->
					<xsl:value-of select="substring-before($sici2,'&lt;')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$sici2"/>
					<!-- 1:2 -->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="sici3">
			<xsl:choose>
				<xsl:when test="starts-with(substring-after($sici2,$level2),':')">
					<xsl:value-of select="substring(substring-after($sici2,$level2),2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after($sici2,$level2)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="level3">
			<xsl:choose>
				<xsl:when test="contains($sici3,'&lt;')">
					<!-- 2<4 -->
					<xsl:value-of select="substring-before($sici3,'&lt;')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$sici3"/>
					<!-- 3 -->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="page">
			<xsl:if test="contains(text(),'&lt;')">
				<xsl:value-of select="substring-after(text(),'&lt;')"/>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="$level1">
			<mods:detail level="1">
				<mods:number>
					<xsl:value-of select="$level1"/>
				</mods:number>
			</mods:detail>
		</xsl:if>
		<xsl:if test="$level2">
			<mods:detail level="2">
				<mods:number>
					<xsl:value-of select="$level2"/>
				</mods:number>
			</mods:detail>
		</xsl:if>
		<xsl:if test="$level3">
			<mods:detail level="3">
				<mods:number>
					<xsl:value-of select="$level3"/>
				</mods:number>
			</mods:detail>
		</xsl:if>
		<xsl:if test="$page">
			<mods:extent unit="page">
				<mods:start>
					<xsl:value-of select="$page"/>
				</mods:start>
			</mods:extent>
		</xsl:if>
	</xsl:template>
	<xsl:template name="getLanguage">
		<xsl:param name="langString"/>
		<xsl:param name="controlField008-35-37"/>
		<xsl:variable name="length" select="string-length($langString)"/>
		<xsl:choose>
			<xsl:when test="$length=0"/>
			<xsl:when test="$controlField008-35-37=substring($langString,1,3)">
				<xsl:call-template name="getLanguage">
					<xsl:with-param name="langString" select="substring($langString,4,$length)"/>
					<xsl:with-param name="controlField008-35-37" select="$controlField008-35-37"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<mods:language>
					<mods:languageTerm authority="iso639-2b" type="code">
						<xsl:value-of select="substring($langString,1,3)"/>
					</mods:languageTerm>
				</mods:language>
				<xsl:call-template name="getLanguage">
					<xsl:with-param name="langString" select="substring($langString,4,$length)"/>
					<xsl:with-param name="controlField008-35-37" select="$controlField008-35-37"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="isoLanguage">
		<xsl:param name="currentLanguage"/>
		<xsl:param name="usedLanguages"/>
		<xsl:param name="remainingLanguages"/>
		<xsl:choose>
			<xsl:when test="string-length($currentLanguage)=0"/>
			<xsl:when test="not(contains($usedLanguages, $currentLanguage))">
				<mods:language>
					<xsl:if test="@code!='a'">
						<xsl:attribute name="objectPart">
							<xsl:choose>
								<xsl:when test="@code='b'">summary or subtitle</xsl:when>
								<xsl:when test="@code='d'">sung or spoken text</xsl:when>
								<xsl:when test="@code='e'">libretto</xsl:when>
								<xsl:when test="@code='f'">table of contents</xsl:when>
								<xsl:when test="@code='g'">accompanying material</xsl:when>
								<xsl:when test="@code='h'">translation</xsl:when>
							</xsl:choose>
						</xsl:attribute>
					</xsl:if>
					<mods:languageTerm authority="iso639-2b" type="code">
						<xsl:value-of select="$currentLanguage"/>
					</mods:languageTerm>
				</mods:language>
				<xsl:call-template name="isoLanguage">
					<xsl:with-param name="currentLanguage">
						<xsl:value-of select="substring($remainingLanguages,1,3)"/>
					</xsl:with-param>
					<xsl:with-param name="usedLanguages">
						<xsl:value-of select="concat($usedLanguages,$currentLanguage)"/>
					</xsl:with-param>
					<xsl:with-param name="remainingLanguages">
						<xsl:value-of select="substring($remainingLanguages,4,string-length($remainingLanguages))"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="isoLanguage">
					<xsl:with-param name="currentLanguage">
						<xsl:value-of select="substring($remainingLanguages,1,3)"/>
					</xsl:with-param>
					<xsl:with-param name="usedLanguages">
						<xsl:value-of select="concat($usedLanguages,$currentLanguage)"/>
					</xsl:with-param>
					<xsl:with-param name="remainingLanguages">
						<xsl:value-of select="substring($remainingLanguages,4,string-length($remainingLanguages))"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="chopBrackets">
		<xsl:param name="chopString"/>
		<xsl:variable name="string">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="$chopString"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="substring($string, 1,1)='['">
			<xsl:value-of select="substring($string,2, string-length($string)-2)"/>
		</xsl:if>
		<xsl:if test="substring($string, 1,1)!='['">
			<xsl:value-of select="$string"/>
		</xsl:if>
	</xsl:template>
	<xsl:template name="rfcLanguages">
		<xsl:param name="nodeNum"/>
		<xsl:param name="usedLanguages"/>
		<xsl:param name="controlField008-35-37"/>
		<xsl:variable name="currentLanguage" select="."/>
		<xsl:choose>
			<xsl:when test="not($currentLanguage)"/>
			<xsl:when test="$currentLanguage!=$controlField008-35-37 and $currentLanguage!='rfc3066'">
				<xsl:if test="not(contains($usedLanguages,$currentLanguage))">
					<mods:language>
						<xsl:if test="@code!='a'">
							<xsl:attribute name="objectPart">
								<xsl:choose>
									<xsl:when test="@code='b'">summary or subtitle</xsl:when>
									<xsl:when test="@code='d'">sung or spoken text</xsl:when>
									<xsl:when test="@code='e'">libretto</xsl:when>
									<xsl:when test="@code='f'">table of contents</xsl:when>
									<xsl:when test="@code='g'">accompanying material</xsl:when>
									<xsl:when test="@code='h'">translation</xsl:when>
								</xsl:choose>
							</xsl:attribute>
						</xsl:if>
						<mods:languageTerm authority="rfc3066" type="code">
							<xsl:value-of select="$currentLanguage"/>
						</mods:languageTerm>
					</mods:language>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise> </xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- tmee added 20100106 for 045$b BC and CE date range info -->
	<xsl:template name="dates045b">
		<xsl:param name="str"/>
		<xsl:variable name="first-char" select="substring($str,1,1)"/>
		<xsl:choose>
			<xsl:when test="$first-char ='c'">
				<xsl:value-of select="concat ('-', substring($str, 2))"/>
			</xsl:when>
			<xsl:when test="$first-char ='d'">
				<xsl:value-of select="substring($str, 2)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="scriptCode">
		<xsl:variable name="sf06" select="normalize-space(child::marc:subfield[@code='6'])"/>
		<xsl:variable name="sf06a" select="substring($sf06, 1, 3)"/>
		<xsl:variable name="sf06b" select="substring($sf06, 5, 2)"/>
		<xsl:variable name="sf06c" select="substring($sf06, 7)"/>
		<xsl:variable name="scriptCode" select="substring($sf06, 8, 2)"/>
		<xsl:if test="//marc:datafield/marc:subfield[@code='6']">
			<xsl:attribute name="script">
				<xsl:choose>
					<xsl:when test="$scriptCode=''">Latn</xsl:when>
					<xsl:when test="$scriptCode='(3'">Arab</xsl:when>
					<xsl:when test="$scriptCode='(4'">Arab</xsl:when>
					<xsl:when test="$scriptCode='(B'">Latn</xsl:when>
					<xsl:when test="$scriptCode='!E'">Latn</xsl:when>
					<xsl:when test="$scriptCode='$1'">CJK</xsl:when>
					<xsl:when test="$scriptCode='(N'">Cyrl</xsl:when>
					<xsl:when test="$scriptCode='(Q'">Cyrl</xsl:when>
					<xsl:when test="$scriptCode='(2'">Hebr</xsl:when>
					<xsl:when test="$scriptCode='(S'">Grek</xsl:when>
				</xsl:choose>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<!-- tmee 20100927 for 880s & corresponding fields  20101123 scriptCode -->

	<xsl:template name="xxx880">
		<xsl:if test="child::marc:subfield[@code='6']">
			<xsl:variable name="sf06" select="normalize-space(child::marc:subfield[@code='6'])"/>
			<xsl:variable name="sf06a" select="substring($sf06, 1, 3)"/>
			<xsl:variable name="sf06b" select="substring($sf06, 5, 2)"/>
			<xsl:variable name="sf06c" select="substring($sf06, 7)"/>
			<xsl:variable name="scriptCode" select="substring($sf06, 8, 2)"/>
			<xsl:if test="//marc:datafield/marc:subfield[@code='6']">
				<xsl:attribute name="altRepGroup">
					<xsl:value-of select="$sf06b"/>
				</xsl:attribute>
				<xsl:attribute name="script">
					<xsl:choose>
						<xsl:when test="$scriptCode=''">Latn</xsl:when>
						<xsl:when test="$scriptCode='(3'">Arab</xsl:when>
						<xsl:when test="$scriptCode='(4'">Arab</xsl:when>
						<xsl:when test="$scriptCode='(B'">Latn</xsl:when>
						<xsl:when test="$scriptCode='!E'">Latn</xsl:when>
						<xsl:when test="$scriptCode='$1'">CJK</xsl:when>
						<xsl:when test="$scriptCode='(N'">Cyrl</xsl:when>
						<xsl:when test="$scriptCode='(Q'">Cyrl</xsl:when>
						<xsl:when test="$scriptCode='(2'">Hebr</xsl:when>
						<xsl:when test="$scriptCode='(S'">Grek</xsl:when>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="yyy880">
		<xsl:if test="preceding-sibling::marc:subfield[@code='6']">
			<xsl:variable name="sf06" select="normalize-space(preceding-sibling::marc:subfield[@code='6'])"/>
			<xsl:variable name="sf06a" select="substring($sf06, 1, 3)"/>
			<xsl:variable name="sf06b" select="substring($sf06, 5, 2)"/>
			<xsl:variable name="sf06c" select="substring($sf06, 7)"/>
			<xsl:if test="//marc:datafield/marc:subfield[@code='6']">
				<xsl:attribute name="altRepGroup">
					<xsl:value-of select="$sf06b"/>
				</xsl:attribute>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="z2xx880">
		<!-- Evaluating the 260 field -->
		<xsl:variable name="x260">
			<xsl:choose>
				<xsl:when test="@tag='260' and marc:subfield[@code='6']">
					<xsl:variable name="sf06260" select="normalize-space(child::marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06260a" select="substring($sf06260, 1, 3)"/>
					<xsl:variable name="sf06260b" select="substring($sf06260, 5, 2)"/>
					<xsl:variable name="sf06260c" select="substring($sf06260, 7)"/>
					<xsl:value-of select="$sf06260b"/>
				</xsl:when>
				<xsl:when test="@tag='250' and ../marc:datafield[@tag='260']/marc:subfield[@code='6']">
					<xsl:variable name="sf06260"
						select="normalize-space(../marc:datafield[@tag='260']/marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06260a" select="substring($sf06260, 1, 3)"/>
					<xsl:variable name="sf06260b" select="substring($sf06260, 5, 2)"/>
					<xsl:variable name="sf06260c" select="substring($sf06260, 7)"/>
					<xsl:value-of select="$sf06260b"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="x264">
			<xsl:choose>
				<xsl:when test="@tag='264' and marc:subfield[@code='6']">
					<xsl:variable name="sf06264" select="normalize-space(child::marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06264a" select="substring($sf06264, 1, 3)"/>
					<xsl:variable name="sf06264b" select="substring($sf06264, 5, 2)"/>
					<xsl:variable name="sf06264c" select="substring($sf06264, 7)"/>
					<xsl:value-of select="$sf06264b"/>
				</xsl:when>
				<xsl:when test="@tag='250' and ../marc:datafield[@tag='264']/marc:subfield[@code='6']">
					<xsl:variable name="sf06264"
						select="normalize-space(../marc:datafield[@tag='264']/marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06264a" select="substring($sf06264, 1, 3)"/>
					<xsl:variable name="sf06264b" select="substring($sf06264, 5, 2)"/>
					<xsl:variable name="sf06264c" select="substring($sf06264, 7)"/>
					<xsl:value-of select="$sf06264b"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="x250">
			<xsl:choose>
				<xsl:when test="@tag='250' and marc:subfield[@code='6']">
					<xsl:variable name="sf06250"
						select="normalize-space(../marc:datafield[@tag='250']/marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06250a" select="substring($sf06250, 1, 3)"/>
					<xsl:variable name="sf06250b" select="substring($sf06250, 5, 2)"/>
					<xsl:variable name="sf06250c" select="substring($sf06250, 7)"/>
					<xsl:value-of select="$sf06250b"/>
				</xsl:when>
				<xsl:when test="@tag='260' and ../marc:datafield[@tag='250']/marc:subfield[@code='6']">
					<xsl:variable name="sf06250"
						select="normalize-space(../marc:datafield[@tag='250']/marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06250a" select="substring($sf06250, 1, 3)"/>
					<xsl:variable name="sf06250b" select="substring($sf06250, 5, 2)"/>
					<xsl:variable name="sf06250c" select="substring($sf06250, 7)"/>
					<xsl:value-of select="$sf06250b"/>
				</xsl:when>
				<xsl:when test="@tag='264' and ../marc:datafield[@tag='250']/marc:subfield[@code='6']">
					<xsl:variable name="sf06250"
						select="normalize-space(../marc:datafield[@tag='250']/marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06250a" select="substring($sf06250, 1, 3)"/>
					<xsl:variable name="sf06250b" select="substring($sf06250, 5, 2)"/>
					<xsl:variable name="sf06250c" select="substring($sf06250, 7)"/>
					<xsl:value-of select="$sf06250b"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$x250!='' and $x260!=''">
				<xsl:attribute name="altRepGroup">
					<xsl:value-of select="concat($x250, $x260)"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="$x250!='' and $x264!=''">
				<xsl:attribute name="altRepGroup">
					<xsl:value-of select="concat($x250, $x264)"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="$x250!=''">
				<xsl:attribute name="altRepGroup">
					<xsl:value-of select="$x250"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="$x260!=''">
				<xsl:attribute name="altRepGroup">
					<xsl:value-of select="$x260"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="$x264!=''">
				<xsl:attribute name="altRepGroup">
					<xsl:value-of select="$x264"/>
				</xsl:attribute>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="//marc:datafield/marc:subfield[@code='6']"> </xsl:if>
	</xsl:template>

	<xsl:template name="z3xx880">
		<!-- Evaluating the 300 field -->
		<xsl:variable name="x300">
			<xsl:choose>
				<xsl:when test="@tag='300' and marc:subfield[@code='6']">
					<xsl:variable name="sf06300" select="normalize-space(child::marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06300a" select="substring($sf06300, 1, 3)"/>
					<xsl:variable name="sf06300b" select="substring($sf06300, 5, 2)"/>
					<xsl:variable name="sf06300c" select="substring($sf06300, 7)"/>
					<xsl:value-of select="$sf06300b"/>
				</xsl:when>
				<xsl:when test="@tag='351' and ../marc:datafield[@tag='300']/marc:subfield[@code='6']">
					<xsl:variable name="sf06300"
						select="normalize-space(../marc:datafield[@tag='300']/marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06300a" select="substring($sf06300, 1, 3)"/>
					<xsl:variable name="sf06300b" select="substring($sf06300, 5, 2)"/>
					<xsl:variable name="sf06300c" select="substring($sf06300, 7)"/>
					<xsl:value-of select="$sf06300b"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="x351">
			<xsl:choose>
				<xsl:when test="@tag='351' and marc:subfield[@code='6']">
					<xsl:variable name="sf06351"
						select="normalize-space(../marc:datafield[@tag='351']/marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06351a" select="substring($sf06351, 1, 3)"/>
					<xsl:variable name="sf06351b" select="substring($sf06351, 5, 2)"/>
					<xsl:variable name="sf06351c" select="substring($sf06351, 7)"/>
					<xsl:value-of select="$sf06351b"/>
				</xsl:when>
				<xsl:when test="@tag='300' and ../marc:datafield[@tag='351']/marc:subfield[@code='6']">
					<xsl:variable name="sf06351"
						select="normalize-space(../marc:datafield[@tag='351']/marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06351a" select="substring($sf06351, 1, 3)"/>
					<xsl:variable name="sf06351b" select="substring($sf06351, 5, 2)"/>
					<xsl:variable name="sf06351c" select="substring($sf06351, 7)"/>
					<xsl:value-of select="$sf06351b"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$x351!='' and $x300!=''">
				<xsl:attribute name="altRepGroup">
					<xsl:value-of select="concat($x351, $x300)"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="$x351!=''">
				<xsl:attribute name="altRepGroup">
					<xsl:value-of select="$x351"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="$x300!=''">
				<xsl:attribute name="altRepGroup">
					<xsl:value-of select="$x300"/>
				</xsl:attribute>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="//marc:datafield/marc:subfield[@code='6']"> </xsl:if>
	</xsl:template>



	<xsl:template name="true880">
		<xsl:variable name="sf06" select="normalize-space(marc:subfield[@code='6'])"/>
		<xsl:variable name="sf06a" select="substring($sf06, 1, 3)"/>
		<xsl:variable name="sf06b" select="substring($sf06, 5, 2)"/>
		<xsl:variable name="sf06c" select="substring($sf06, 7)"/>
		<xsl:if test="//marc:datafield/marc:subfield[@code='6']">
			<xsl:attribute name="altRepGroup">
				<xsl:value-of select="$sf06b"/>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template match="marc:datafield" mode="trans880">
		<xsl:variable name="dataField880" select="//marc:datafield"/>
		<xsl:variable name="sf06" select="normalize-space(marc:subfield[@code='6'])"/>
		<xsl:variable name="sf06a" select="substring($sf06, 1, 3)"/>
		<xsl:variable name="sf06b" select="substring($sf06, 4)"/>
		<xsl:choose>

			<!--tranforms 880 equiv-->

			<xsl:when test="$sf06a='047'">
				<xsl:call-template name="createGenreFrom047"/>
			</xsl:when>
			<xsl:when test="$sf06a='655'">
				<xsl:call-template name="createGenreFrom655"/>
			</xsl:when>

			<xsl:when test="$sf06a='090'">
				<xsl:call-template name="createClassificationFrom090"/>
			</xsl:when>

			<xsl:when test="$sf06a='050'">
				<xsl:call-template name="createClassificationFrom050"/>
			</xsl:when>
			<xsl:when test="$sf06a='060'">
				<xsl:call-template name="createClassificationFrom060"/>
			</xsl:when>
			<xsl:when test="$sf06a='080'">
				<xsl:call-template name="createClassificationFrom080"/>
			</xsl:when>
			<xsl:when test="$sf06a='082'">
				<xsl:call-template name="createClassificationFrom082"/>
			</xsl:when>
			<xsl:when test="$sf06a='084'">
				<xsl:call-template name="createClassificationFrom080"/>
			</xsl:when>
			<xsl:when test="$sf06a='086'">
				<xsl:call-template name="createClassificationFrom082"/>
			</xsl:when>
			<xsl:when test="$sf06a='100'">
				<xsl:call-template name="createNameFrom100"/>
			</xsl:when>
			<xsl:when test="$sf06a='110'">
				<xsl:call-template name="createNameFrom110"/>
			</xsl:when>
			<xsl:when test="$sf06a='111'">
				<xsl:call-template name="createNameFrom110"/>
			</xsl:when>
			<xsl:when test="$sf06a='710'">
				<xsl:call-template name="createNameFrom710"/>
			</xsl:when>
			<xsl:when test="$sf06a='711'">
				<xsl:call-template name="createNameFrom710"/>
			</xsl:when>
			<xsl:when test="$sf06a='210'">
				<xsl:call-template name="createTitleInfoFrom210"/>
			</xsl:when>
			<xsl:when test="$sf06a='245'">
				<xsl:call-template name="createTitleInfoFrom245"/>
				<xsl:call-template name="createNoteFrom245c"/>
			</xsl:when>
			<xsl:when test="$sf06a='246'">
				<xsl:call-template name="createTitleInfoFrom246"/>
			</xsl:when>
			<xsl:when test="$sf06a='240'">
				<xsl:call-template name="createTitleInfoFrom240"/>
			</xsl:when>

			<xsl:when test="$sf06a='130'">
				<xsl:call-template name="createTitleInfoFrom130"/>
			</xsl:when>
			<xsl:when test="$sf06a='730'">
				<xsl:call-template name="createTitleInfoFrom730"/>
			</xsl:when>

			<xsl:when test="$sf06a='505'">
				<xsl:call-template name="createTOCFrom505"/>
			</xsl:when>
			<xsl:when test="$sf06a='520'">
				<xsl:call-template name="createAbstractFrom520"/>
			</xsl:when>
			<xsl:when test="$sf06a='506'">
				<xsl:call-template name="createAccessConditionFrom506"/>
			</xsl:when>
			<xsl:when test="$sf06a='540'">
				<xsl:call-template name="createAccessConditionFrom540"/>
			</xsl:when>

			<!-- note 245 362 etc	-->

			<xsl:when test="$sf06a='245'">
				<xsl:call-template name="createNoteFrom245c"/>
			</xsl:when>
			<xsl:when test="$sf06a='362'">
				<xsl:call-template name="createNoteFrom362"/>
			</xsl:when>
			<xsl:when test="$sf06a='502'">
				<xsl:call-template name="createNoteFrom502"/>
			</xsl:when>
			<xsl:when test="$sf06a='504'">
				<xsl:call-template name="createNoteFrom504"/>
			</xsl:when>
			<xsl:when test="$sf06a='508'">
				<xsl:call-template name="createNoteFrom508"/>
			</xsl:when>
			<xsl:when test="$sf06a='511'">
				<xsl:call-template name="createNoteFrom511"/>
			</xsl:when>
			<xsl:when test="$sf06a='515'">
				<xsl:call-template name="createNoteFrom515"/>
			</xsl:when>
			<xsl:when test="$sf06a='518'">
				<xsl:call-template name="createNoteFrom518"/>
			</xsl:when>
			<xsl:when test="$sf06a='524'">
				<xsl:call-template name="createNoteFrom524"/>
			</xsl:when>
			<xsl:when test="$sf06a='530'">
				<xsl:call-template name="createNoteFrom530"/>
			</xsl:when>
			<xsl:when test="$sf06a='533'">
				<xsl:call-template name="createNoteFrom533"/>
			</xsl:when>
			<xsl:when test="$sf06a='534'">
				<xsl:call-template name="createNoteFrom534"/>
			</xsl:when>
			<xsl:when test="$sf06a='535'">
				<xsl:call-template name="createNoteFrom535"/>
			</xsl:when>
			<xsl:when test="$sf06a='536'">
				<xsl:call-template name="createNoteFrom536"/>
			</xsl:when>
			<xsl:when test="$sf06a='538'">
				<xsl:call-template name="createNoteFrom538"/>
			</xsl:when>
			<xsl:when test="$sf06a='541'">
				<xsl:call-template name="createNoteFrom541"/>
			</xsl:when>
			<xsl:when test="$sf06a='545'">
				<xsl:call-template name="createNoteFrom545"/>
			</xsl:when>
			<xsl:when test="$sf06a='546'">
				<xsl:call-template name="createNoteFrom546"/>
			</xsl:when>
			<xsl:when test="$sf06a='561'">
				<xsl:call-template name="createNoteFrom561"/>
			</xsl:when>
			<xsl:when test="$sf06a='562'">
				<xsl:call-template name="createNoteFrom562"/>
			</xsl:when>
			<xsl:when test="$sf06a='581'">
				<xsl:call-template name="createNoteFrom581"/>
			</xsl:when>
			<xsl:when test="$sf06a='583'">
				<xsl:call-template name="createNoteFrom583"/>
			</xsl:when>
			<xsl:when test="$sf06a='585'">
				<xsl:call-template name="createNoteFrom585"/>
			</xsl:when>

			<!--	note 5XX	-->

			<xsl:when test="$sf06a='501'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>
			<xsl:when test="$sf06a='507'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>
			<xsl:when test="$sf06a='513'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>
			<xsl:when test="$sf06a='514'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>
			<xsl:when test="$sf06a='516'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>
			<xsl:when test="$sf06a='522'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>
			<xsl:when test="$sf06a='525'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>
			<xsl:when test="$sf06a='526'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>
			<xsl:when test="$sf06a='544'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>
			<xsl:when test="$sf06a='552'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>
			<xsl:when test="$sf06a='555'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>
			<xsl:when test="$sf06a='556'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>
			<xsl:when test="$sf06a='565'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>
			<xsl:when test="$sf06a='567'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>
			<xsl:when test="$sf06a='580'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>
			<xsl:when test="$sf06a='584'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>
			<xsl:when test="$sf06a='586'">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:when>

			<!--  subject 034 043 045 255 656 662 752 	-->

			<xsl:when test="$sf06a='034'">
				<xsl:call-template name="createSubGeoFrom034"/>
			</xsl:when>
			<xsl:when test="$sf06a='045'">
				<xsl:call-template name="createSubTemFrom045"/>
			</xsl:when>
			<xsl:when test="$sf06a='255'">
				<xsl:call-template name="createSubGeoFrom255"/>
			</xsl:when>

			<xsl:when test="$sf06a='600'">
				<xsl:call-template name="createSubNameFrom600"/>
			</xsl:when>
			<xsl:when test="$sf06a='610'">
				<xsl:call-template name="createSubNameFrom610"/>
			</xsl:when>
			<xsl:when test="$sf06a='611'">
				<xsl:call-template name="createSubNameFrom611"/>
			</xsl:when>

			<xsl:when test="$sf06a='630'">
				<xsl:call-template name="createSubTitleFrom630"/>
			</xsl:when>

			<xsl:when test="$sf06a='648'">
				<xsl:call-template name="createSubChronFrom648"/>
			</xsl:when>
			<xsl:when test="$sf06a='650'">
				<xsl:call-template name="createSubTopFrom650"/>
			</xsl:when>
			<xsl:when test="$sf06a='651'">
				<xsl:call-template name="createSubGeoFrom651"/>
			</xsl:when>


			<xsl:when test="$sf06a='653'">
				<xsl:call-template name="createSubFrom653"/>
			</xsl:when>
			<xsl:when test="$sf06a='656'">
				<xsl:call-template name="createSubFrom656"/>
			</xsl:when>
			<xsl:when test="$sf06a='662'">
				<xsl:call-template name="createSubGeoFrom662752"/>
			</xsl:when>
			<xsl:when test="$sf06a='752'">
				<xsl:call-template name="createSubGeoFrom662752"/>
			</xsl:when>

			<!--  location  852 856 -->

			<!--		<xsl:when test="$sf06a='852'">
				<xsl:call-template name="createLocationFrom852"/>
			</xsl:when> -->
			<xsl:when test="$sf06a='856'">
				<xsl:call-template name="createLocationFrom856"/>
			</xsl:when>

			<!--			<xsl:when test="$sf06a='490'">
				<xsl:call-template name="createRelatedItemFrom490"/>
			</xsl:when> -->
		</xsl:choose>
	</xsl:template>

	<!-- titleInfo 130 730 245 246 240 740 210 -->

	<!-- 130 -->
	<xsl:template name="createTitleInfoFrom130">
		<xsl:for-each select="marc:datafield[@tag='130'][@ind2!='2']">
			<mods:titleInfo type="uniform">
				<mods:title>
					<xsl:variable name="str">
						<xsl:for-each select="marc:subfield">
							<xsl:if test="(contains('s',@code))">
								<xsl:value-of select="text()"/>
								<xsl:text> </xsl:text>
							</xsl:if>
							<xsl:if
								test="(contains('adfklmors',@code) and (not(../marc:subfield[@code='n' or @code='p']) or (following-sibling::marc:subfield[@code='n' or @code='p'])))">
								<xsl:value-of select="text()"/>
								<xsl:text> </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
						</xsl:with-param>
					</xsl:call-template>
				</mods:title>
				<xsl:call-template name="part"/>
			</mods:titleInfo>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="createTitleInfoFrom730">
		<mods:titleInfo type="uniform">
			<mods:title>
				<xsl:variable name="str">
					<xsl:for-each select="marc:subfield">
						<xsl:if test="(contains('s',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
						<xsl:if
							test="(contains('adfklmors',@code) and (not(../marc:subfield[@code='n' or @code='p']) or (following-sibling::marc:subfield[@code='n' or @code='p'])))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
					</xsl:with-param>
				</xsl:call-template>

			</mods:title>
			<xsl:call-template name="part"/>
		</mods:titleInfo>
	</xsl:template>

	<xsl:template name="createTitleInfoFrom210">
		<mods:titleInfo type="abbreviated">
			<xsl:if test="marc:datafield[@tag='210'][@ind2='2']">
				<xsl:attribute name="authority">
					<xsl:value-of select="marc:subfield[@code='2']"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="xxx880"/>
			<mods:title>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">a</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</mods:title>
			<xsl:call-template name="subtitle"/>
		</mods:titleInfo>
	</xsl:template>
	<!-- 1.79 -->
	<xsl:template name="createTitleInfoFrom245">
		<mods:titleInfo>
			<xsl:call-template name="xxx880"/>
			<xsl:variable name="title">
				<xsl:choose>
					<xsl:when test="marc:subfield[@code='b']">
						<xsl:call-template name="specialSubfieldSelect">
							<xsl:with-param name="axis">b</xsl:with-param>
							<xsl:with-param name="beforeCodes">afgks</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">abfgks</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="titleChop">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:value-of select="$title"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="@ind2&gt;0">
					<xsl:if test="@tag!='880'">
						<mods:nonSort>
							<xsl:value-of select="normalize-space(substring($titleChop,1,@ind2))"/>
						</mods:nonSort>
					</xsl:if>
					<mods:title>
						<xsl:value-of select="substring($titleChop,@ind2+1)"/>
					</mods:title>
				</xsl:when>
				<xsl:otherwise>
					<mods:title>
						<xsl:value-of select="$titleChop"/>
					</mods:title>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="marc:subfield[@code='b']">
				<mods:subTitle>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="axis">b</xsl:with-param>
								<xsl:with-param name="anyCodes">b</xsl:with-param>
								<xsl:with-param name="afterCodes">afgks</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</mods:subTitle>
			</xsl:if>
			<xsl:call-template name="part"/>
		</mods:titleInfo>
	</xsl:template>

	<xsl:template name="createTitleInfoFrom246">
		<mods:titleInfo type="alternative">
			<xsl:call-template name="xxx880"/>
			<xsl:for-each select="marc:subfield[@code='i']">
				<xsl:attribute name="displayLabel">
					<xsl:value-of select="text()"/>
				</xsl:attribute>
			</xsl:for-each>
			<mods:title>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<!-- 1/04 removed $h, $b -->
							<xsl:with-param name="codes">af</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</mods:title>
			<xsl:call-template name="subtitle"/>
			<xsl:call-template name="part"/>
		</mods:titleInfo>
	</xsl:template>

	<!-- 240 nameTitleGroup-->

	<xsl:template name="createTitleInfoFrom240">
		<mods:titleInfo type="uniform">
			<xsl:if test="//marc:datafield[@tag='100']|//marc:datafield[@tag='110']|//marc:datafield[@tag='111']">
				<xsl:attribute name="nameTitleGroup">
					<xsl:text>1</xsl:text>
				</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="xxx880"/>
			<mods:title>
				<xsl:variable name="str">
					<xsl:for-each select="marc:subfield">
						<xsl:if test="(contains('s',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
						<xsl:if
							test="(contains('adfklmors',@code) and (not(../marc:subfield[@code='n' or @code='p']) or (following-sibling::marc:subfield[@code='n' or @code='p'])))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
					</xsl:with-param>
				</xsl:call-template>
			</mods:title>
			<xsl:call-template name="part"/>
		</mods:titleInfo>
	</xsl:template>

	<!-- name 100 110 111 -->

	<xsl:template name="createNameFrom100">
		<mods:name type="personal">
			<xsl:call-template name="xxx880"/>
			<xsl:if test="//marc:datafield[@tag='240']">
				<xsl:attribute name="nameTitleGroup">
					<xsl:text>1</xsl:text>
				</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="nameABCDQ"/>
			<xsl:call-template name="affiliation"/>
			<xsl:call-template name="role"/>
		</mods:name>
	</xsl:template>

	<xsl:template name="createNameFrom110">
		<mods:name type="corporate">
			<xsl:call-template name="xxx880"/>
			<xsl:if test="//marc:datafield[@tag='240']">
				<xsl:attribute name="nameTitleGroup">
					<xsl:text>1</xsl:text>
				</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="nameABCDN"/>
			<xsl:call-template name="role"/>
		</mods:name>
	</xsl:template>

	<xsl:template name="createNameFrom111">
		<mods:name type="conference">
			<xsl:call-template name="xxx880"/>
			<xsl:if test="//marc:datafield[@tag='240']">
				<xsl:attribute name="nameTitleGroup">
					<xsl:text>1</xsl:text>
				</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="nameACDEQ"/>
			<xsl:call-template name="role"/>
		</mods:name>
	</xsl:template>

	<!-- name 700 710 711 720 -->

	<xsl:template name="createNameFrom700">
		<mods:namePart>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">aq</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="punctuation">
					<xsl:text>:,;/ </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</mods:namePart>
		<xsl:call-template name="termsOfAddress"/>
		<xsl:call-template name="nameDate"/>
	</xsl:template>

	<xsl:template name="createNameFrom710">
		<mods:name type="corporate">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="nameABCDN"/>
			<xsl:call-template name="role"/>
		</mods:name>
	</xsl:template>

	<xsl:template name="createNameFrom711">
		<mods:name type="conference">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="nameACDEQ"/>
			<xsl:call-template name="role"/>
		</mods:name>
	</xsl:template>

	<xsl:template name="createNameFrom720">
		<xsl:if test="marc:datafield[@tag='720'][not(marc:subfield[@code='t'])]">
			<mods:name>
				<xsl:if test="@ind1=1">
					<xsl:attribute name="type">
						<xsl:text>personal</xsl:text>
					</xsl:attribute>
				</xsl:if>
				<mods:namePart>
					<xsl:value-of select="marc:subfield[@code='a']"/>
				</mods:namePart>
				<xsl:call-template name="role"/>
			</mods:name>
		</xsl:if>
	</xsl:template>

	<!-- genre 047 655	-->

	<xsl:template name="createGenreFrom047">
		<mods:genre authority="marcgt">
			<xsl:attribute name="authority">
				<xsl:value-of select="marc:subfield[@code='2']"/>
			</xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">abcdef</xsl:with-param>
				<xsl:with-param name="delimeter">-</xsl:with-param>
			</xsl:call-template>
		</mods:genre>
	</xsl:template>
	<xsl:template name="createGenreFrom655">
		<xsl:if
			test="not(marc:subfield[@code='a']='Dime novels.') and not(marc:subfield[@code='a']='Dime novels')and not(marc:subfield[@code='a']='Nickel weeklies.') and not(marc:subfield[@code='a']='Nickel weeklies.')and not(marc:subfield[@code='a']='Penny dreadfuls.') and not(marc:subfield[@code='a']='Penny dreadfuls') and not(marc:subfield[@code='a']='Story papers.')">
			<mods:genre authority="marcgt">
				<xsl:attribute name="authority">
					<xsl:choose>
						<xsl:when test="@ind2='0'">
							<xsl:text>lcsh</xsl:text>
						</xsl:when>
						<xsl:when test="@ind2='4'">
							<xsl:text>local</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="marc:subfield[@code='2']"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:value-of select="translate(marc:subfield[@code='a'],'.','')"/>
				<!--	<xsl:call-template name="xxx880"/>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">abvxyz</xsl:with-param>
				<xsl:with-param name="delimeter">-</xsl:with-param>
			</xsl:call-template> -->
			</mods:genre>
		</xsl:if>
	</xsl:template>

	<!-- tOC 505 -->

	<xsl:template name="createTOCFrom505">
		<mods:tableOfContents>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">agrt</xsl:with-param>
			</xsl:call-template>
		</mods:tableOfContents>
	</xsl:template>

	<!-- abstract 520 -->

	<xsl:template name="createAbstractFrom520">
		<mods:abstract>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">ab</xsl:with-param>
			</xsl:call-template>
		</mods:abstract>
	</xsl:template>

	<!-- note 245c thru 585 -->

	<xsl:template name="createNoteFrom245c">
		<mods:note type="statement of responsibility">
			<xsl:call-template name="scriptCode"/>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">c</xsl:with-param>
			</xsl:call-template>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom362">
		<mods:note type="date/sequential designation">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom500">
		<mods:note>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:value-of select="marc:subfield[@code='a']"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom502">
		<mods:note type="thesis">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom504">
		<mods:note type="bibliography">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom508">
		<mods:note type="creation/production credits">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='u' and @code!='3' and @code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom511">
		<mods:note type="performers">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom515">
		<mods:note type="numbering">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom518">
		<mods:note type="venue">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='3' and @code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom524">
		<mods:note type="preferred citation">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom530">
		<mods:note type="additional physical form">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='u' and @code!='3' and @code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom533">
		<mods:note type="reproduction">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom534">
		<mods:note type="original version">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom535">
		<mods:note type="original location">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom536">
		<mods:note type="funding">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom538">
		<mods:note type="system details">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom541">
		<mods:note type="acquisition">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom545">
		<mods:note type="biographical/historical">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom546">
		<mods:note type="language">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom561">
		<mods:note type="ownership">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom562">
		<mods:note type="version identification">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom581">
		<mods:note type="publications">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom583">
		<mods:note type="action">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom585">
		<mods:note type="exhibitions">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<xsl:template name="createNoteFrom5XX">
		<mods:note>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</mods:note>
	</xsl:template>

	<!-- subject Geo 034 043 045 255 656 662 752 -->

	<xsl:template name="createSubGeoFrom034">
		<xsl:if test="marc:datafield[@tag=034][marc:subfield[@code='d' or @code='e' or @code='f' or @code='g']]">
			<mods:subject>
				<xsl:call-template name="xxx880"/>
				<mods:cartographics>
					<mods:coordinates>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">defg</xsl:with-param>
						</xsl:call-template>
					</mods:coordinates>
				</mods:cartographics>
			</mods:subject>
		</xsl:if>
	</xsl:template>

	<xsl:template name="createSubGeoFrom255">
		<mods:subject>
			<xsl:call-template name="xxx880"/>
			<xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c']">
				<mods:cartographics>
					<xsl:if test="@code='a'">
						<mods:scale>
							<xsl:value-of select="."/>
						</mods:scale>
					</xsl:if>
					<xsl:if test="@code='b'">
						<mods:projection>
							<xsl:value-of select="."/>
						</mods:projection>
					</xsl:if>
					<xsl:if test="@code='c'">
						<mods:coordinates>
							<xsl:value-of select="."/>
						</mods:coordinates>
					</xsl:if>
				</mods:cartographics>
			</xsl:for-each>
		</mods:subject>
	</xsl:template>

	<xsl:template name="createSubNameFrom600">
		<mods:subject>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="subjectAuthority"/>
			<mods:name type="personal">
				<mods:namePart>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">aq</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</mods:namePart>
				<xsl:call-template name="termsOfAddress"/>
				<xsl:call-template name="nameDate"/>
				<xsl:call-template name="affiliation"/>
				<xsl:call-template name="role"/>
			</mods:name>
			<xsl:if test="marc:subfield[@code='t']">
				<mods:titleInfo>
					<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">t</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:title>
					<xsl:call-template name="part"/>
				</mods:titleInfo>
			</xsl:if>
			<xsl:call-template name="subjectAnyOrder"/>
		</mods:subject>
	</xsl:template>

	<xsl:template name="createSubNameFrom610">
		<mods:subject>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="subjectAuthority"/>
			<mods:name type="corporate">
				<xsl:for-each select="marc:subfield[@code='a']">
					<mods:namePart>
						<xsl:value-of select="."/>
					</mods:namePart>
				</xsl:for-each>
				<xsl:for-each select="marc:subfield[@code='b']">
					<mods:namePart>
						<xsl:value-of select="."/>
					</mods:namePart>
				</xsl:for-each>
				<xsl:if test="marc:subfield[@code='c' or @code='d' or @code='n' or @code='p']">
					<mods:namePart>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">cdnp</xsl:with-param>
						</xsl:call-template>
					</mods:namePart>
				</xsl:if>
				<xsl:call-template name="role"/>
			</mods:name>
			<xsl:if test="marc:subfield[@code='t']">
				<mods:titleInfo>
					<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">t</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:title>
					<xsl:call-template name="part"/>
				</mods:titleInfo>
			</xsl:if>
			<xsl:call-template name="subjectAnyOrder"/>
		</mods:subject>
	</xsl:template>

	<xsl:template name="createSubNameFrom611">
		<mods:subject>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="subjectAuthority"/>
			<mods:name type="conference">
				<mods:namePart>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">abcdeqnp</xsl:with-param>
					</xsl:call-template>
				</mods:namePart>
				<xsl:for-each select="marc:subfield[@code='4']">
					<mods:role>
						<mods:roleTerm authority="marcrelator" type="code">
							<xsl:value-of select="."/>
						</mods:roleTerm>
					</mods:role>
				</xsl:for-each>
			</mods:name>
			<xsl:if test="marc:subfield[@code='t']">
				<mods:titleInfo>
					<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">tpn</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:title>
					<xsl:call-template name="part"/>
				</mods:titleInfo>
			</xsl:if>
			<xsl:call-template name="subjectAnyOrder"/>
		</mods:subject>
	</xsl:template>

	<xsl:template name="createSubTitleFrom630">
		<mods:subject>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="subjectAuthority"/>
			<mods:titleInfo>
				<mods:title>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">adfhklor</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</mods:title>
				<xsl:call-template name="part"/>
			</mods:titleInfo>
			<xsl:call-template name="subjectAnyOrder"/>
		</mods:subject>
	</xsl:template>

	<xsl:template name="createSubChronFrom648">
		<mods:subject>
			<xsl:call-template name="xxx880"/>
			<xsl:if test="marc:subfield[@code=2]">
				<xsl:attribute name="authority">
					<xsl:value-of select="marc:subfield[@code=2]"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="uri"/>
			<xsl:call-template name="subjectAuthority"/>
			<mods:temporal>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">abcd</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</mods:temporal>
			<xsl:call-template name="subjectAnyOrder"/>
		</mods:subject>
	</xsl:template>

	<xsl:template name="createSubTopFrom650">
		<mods:subject>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="subjectAuthority"/>
			<mods:topic>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">abcd</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</mods:topic>
			<xsl:call-template name="subjectAnyOrder"/>
		</mods:subject>
	</xsl:template>

	<xsl:template name="createSubGeoFrom651">
		<mods:subject>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="subjectAuthority"/>
			<xsl:for-each select="marc:subfield[@code='a']">
				<mods:geographic>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString" select="."/>
					</xsl:call-template>
				</mods:geographic>
			</xsl:for-each>
			<xsl:call-template name="subjectAnyOrder"/>
		</mods:subject>
	</xsl:template>

	<xsl:template name="createSubFrom653">

		<xsl:if test="@ind2=' '">
			<mods:subject>
				<mods:topic>
					<xsl:value-of select="."/>
				</mods:topic>
			</mods:subject>
		</xsl:if>
		<xsl:if test="@ind2='0'">
			<mods:subject>
				<mods:topic>
					<xsl:value-of select="."/>
				</mods:topic>
			</mods:subject>
		</xsl:if>

		<xsl:if test="@ind2='1'">
			<mods:subject>
				<mods:name type="personal">
					<mods:namePart>
						<xsl:value-of select="."/>
					</mods:namePart>
				</mods:name>
			</mods:subject>
		</xsl:if>
		<xsl:if test="@ind2='2'">
			<mods:subject>
				<mods:name type="corporate">
					<mods:namePart>
						<xsl:value-of select="."/>
					</mods:namePart>
				</mods:name>
			</mods:subject>
		</xsl:if>
		<xsl:if test="@ind2='3'">
			<mods:subject>
				<mods:name type="conference">
					<mods:namePart>
						<xsl:value-of select="."/>
					</mods:namePart>
				</mods:name>
			</mods:subject>
		</xsl:if>
		<xsl:if test="@ind2=4">
			<mods:subject>
				<mods:temporal>
					<xsl:value-of select="."/>
				</mods:temporal>
			</mods:subject>
		</xsl:if>
		<xsl:if test="@ind2=5">
			<mods:subject>
				<mods:geographic>
					<xsl:value-of select="."/>
				</mods:geographic>
			</mods:subject>
		</xsl:if>

		<xsl:if test="@ind2=6">
			<mods:subject>
				<mods:genre>
					<xsl:value-of select="."/>
				</mods:genre>
			</mods:subject>
		</xsl:if>
	</xsl:template>

	<xsl:template name="createSubFrom656">
		<mods:subject>
			<xsl:call-template name="xxx880"/>
			<xsl:if test="marc:subfield[@code=2]">
				<xsl:attribute name="authority">
					<xsl:value-of select="marc:subfield[@code=2]"/>
				</xsl:attribute>
			</xsl:if>
			<mods:occupation>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:value-of select="marc:subfield[@code='a']"/>
					</xsl:with-param>
				</xsl:call-template>
			</mods:occupation>
		</mods:subject>
	</xsl:template>

	<xsl:template name="createSubGeoFrom662752">
		<mods:subject>
			<xsl:call-template name="xxx880"/>
			<mods:hierarchicalGeographic>
				<xsl:for-each select="marc:subfield[@code='a']">
					<mods:country>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString" select="."/>
						</xsl:call-template>
					</mods:country>
				</xsl:for-each>
				<xsl:for-each select="marc:subfield[@code='b']">
					<mods:state>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString" select="."/>
						</xsl:call-template>
					</mods:state>
				</xsl:for-each>
				<xsl:for-each select="marc:subfield[@code='c']">
					<mods:county>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString" select="."/>
						</xsl:call-template>
					</mods:county>
				</xsl:for-each>
				<xsl:for-each select="marc:subfield[@code='d']">
					<mods:city>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString" select="."/>
						</xsl:call-template>
					</mods:city>
				</xsl:for-each>
				<xsl:for-each select="marc:subfield[@code='e']">
					<mods:citySection>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString" select="."/>
						</xsl:call-template>
					</mods:citySection>
				</xsl:for-each>
				<xsl:for-each select="marc:subfield[@code='g']">
					<mods:area>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString" select="."/>
						</xsl:call-template>
					</mods:area>
				</xsl:for-each>
				<xsl:for-each select="marc:subfield[@code='h']">
					<mods:extraterrestrialArea>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString" select="."/>
						</xsl:call-template>
					</mods:extraterrestrialArea>
				</xsl:for-each>
			</mods:hierarchicalGeographic>
		</mods:subject>
	</xsl:template>

	<xsl:template name="createSubTemFrom045">
		<xsl:if test="//marc:datafield[@tag=045 and @ind1='2'][marc:subfield[@code='b' or @code='c']]">
			<mods:subject>
				<xsl:call-template name="xxx880"/>
				<mods:temporal encoding="iso8601" point="start">
					<xsl:call-template name="dates045b">
						<xsl:with-param name="str" select="marc:subfield[@code='b' or @code='c'][1]"/>
					</xsl:call-template>
				</mods:temporal>
				<mods:temporal encoding="iso8601" point="end">
					<xsl:call-template name="dates045b">
						<xsl:with-param name="str" select="marc:subfield[@code='b' or @code='c'][2]"/>
					</xsl:call-template>
				</mods:temporal>
			</mods:subject>
		</xsl:if>
	</xsl:template>

	<!-- classification 090 050 060 080 082 084 086 -->

	<xsl:template name="createClassificationFrom090">
		<mods:classification authority="lcc">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">ab</xsl:with-param>
			</xsl:call-template>
		</mods:classification>
	</xsl:template>

	<xsl:template name="createClassificationFrom050">
		<xsl:for-each select="marc:subfield[@code='b']">
			<mods:classification authority="lcc">
				<xsl:call-template name="xxx880"/>
				<xsl:if test="../marc:subfield[@code='3']">
					<xsl:attribute name="displayLabel">
						<xsl:value-of select="../marc:subfield[@code='3']"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="preceding-sibling::marc:subfield[@code='a'][1]"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="text()"/>
			</mods:classification>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code='a'][not(following-sibling::marc:subfield[@code='b'])]">
			<mods:classification authority="lcc">
				<xsl:call-template name="xxx880"/>
				<xsl:if test="../marc:subfield[@code='3']">
					<xsl:attribute name="displayLabel">
						<xsl:value-of select="../marc:subfield[@code='3']"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="text()"/>
			</mods:classification>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="createClassificationFrom060">
		<mods:classification authority="nlm">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">ab</xsl:with-param>
			</xsl:call-template>
		</mods:classification>
	</xsl:template>
	<xsl:template name="createClassificationFrom080">
		<mods:classification authority="udc">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">abx</xsl:with-param>
			</xsl:call-template>
		</mods:classification>
	</xsl:template>

	<xsl:template name="createClassificationFrom082">
		<mods:classification authority="ddc">
			<xsl:call-template name="xxx880"/>
			<xsl:if test="marc:subfield[@code='2']">
				<xsl:attribute name="edition">
					<xsl:value-of select="marc:subfield[@code='2']"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">ab</xsl:with-param>
			</xsl:call-template>
		</mods:classification>
	</xsl:template>
	<xsl:template name="createClassificationFrom084">
		<mods:classification>
			<xsl:attribute name="authority">
				<xsl:value-of select="marc:subfield[@code='2']"/>
			</xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">ab</xsl:with-param>
			</xsl:call-template>
		</mods:classification>
	</xsl:template>
	<xsl:template name="createClassificationFrom086">
		<xsl:for-each select="marc:datafield[@tag=086][@ind1=0]">
			<mods:classification authority="sudocs">
				<xsl:call-template name="xxx880"/>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</mods:classification>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=086][@ind1=1]">
			<mods:classification authority="candoc">
				<xsl:call-template name="xxx880"/>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</mods:classification>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=086][@ind1!=1 and @ind1!=0]">
			<mods:classification>
				<xsl:call-template name="xxx880"/>
				<xsl:attribute name="authority">
					<xsl:value-of select="marc:subfield[@code='2']"/>
				</xsl:attribute>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</mods:classification>
		</xsl:for-each>
	</xsl:template>

	<!-- location 852 856 -->

	<xsl:template name="createLocationFrom856">
		<xsl:if test="//marc:datafield[@tag=856][@ind2!=2][marc:subfield[@code='u']]">
			<mods:location>
				<mods:url displayLabel="electronic resource">
					<!-- 1.41 tmee AQ1.9 added choice protocol for @usage="primary display" -->
					<xsl:variable name="primary">
						<xsl:choose>
							<xsl:when test="@ind2=0 and count(preceding-sibling::marc:datafield[@tag=856] [@ind2=0])=0"
								>true</xsl:when>

							<xsl:when
								test="@ind2=1 and 
							count(ancestor::marc:record//marc:datafield[@tag=856][@ind2=0])=0 and 
							count(preceding-sibling::marc:datafield[@tag=856][@ind2=1])=0"
								>true</xsl:when>

							<xsl:when
								test="@ind2!=1 and @ind2!=0 and 
							@ind2!=2 and count(ancestor::marc:record//marc:datafield[@tag=856 and 
							@ind2=0])=0 and count(ancestor::marc:record//marc:datafield[@tag=856 and 
							@ind2=1])=0 and 
							count(preceding-sibling::marc:datafield[@tag=856][@ind2])=0"
								>true</xsl:when>
							<xsl:otherwise>false</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:if test="$primary='true'">
						<xsl:attribute name="usage">primary display</xsl:attribute>
					</xsl:if>

					<xsl:if test="marc:subfield[@code='y' or @code='3']">
						<xsl:attribute name="displayLabel">
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">y3</xsl:with-param>
							</xsl:call-template>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="marc:subfield[@code='z']">
						<xsl:attribute name="note">
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">z</xsl:with-param>
							</xsl:call-template>
						</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="marc:subfield[@code='u']"/>
				</mods:url>
			</mods:location>
		</xsl:if>
	</xsl:template>

	<!-- accessCondition 506 540 -->

	<xsl:template name="createAccessConditionFrom506">
		<mods:accessCondition type="restrictionOnAccess">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">abcd35</xsl:with-param>
			</xsl:call-template>
		</mods:accessCondition>
	</xsl:template>

	<xsl:template name="createAccessConditionFrom540">
		<mods:accessCondition type="useAndReproduction">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">abcde35</xsl:with-param>
			</xsl:call-template>
		</mods:accessCondition>
	</xsl:template>

</xsl:stylesheet>
