import pymarc, codecs, urllib, requests, sys, re
from datetime import datetime
from collections import defaultdict
from lxml import etree

class FileResolver(etree.Resolver):
    def resolve(self, url, pubid, context):
        return self.resolve_filename(url, context)

parser = etree.XMLParser()
parser.resolvers.add(FileResolver())

xmlschema = etree.XMLSchema(etree.parse(urllib.urlopen('http://www.loc.gov/standards/mods/v3/mods-3-5.xsd')))

def getSubjectUri(subject):

    try:
        response = requests.get('http://id.loc.gov/authorities/subjects/label/%s' % subject)
        link = response.url
        pattern = re.compile(r'(.+)\.html$')
        value = pattern.findall(link)[0].encode('utf-8')
        return ('http://id.loc.gov/authorities/subjects', value)   
    except:
        try:

            response = requests.get('http://id.loc.gov/authorities/names/label/%s' % subject)
            link = response.url
            pattern = re.compile(r'(.+)\.html$')
            value = pattern.findall(link)[0].encode('utf-8')
            return ('http://id.loc.gov/authorities/names', value)        
        except:
            return (False, False)

def getGenreFormUri(subject):

    try:
        response = requests.get('http://id.loc.gov/authorities/genreForm/label/%s' % subject)
        link = response.url
        pattern = re.compile(r'(.+)\.html$')
        value = pattern.findall(link)[0].encode('utf-8')
        return ('http://id.loc.gov/authorities/genreForm', value)         
    except:
        return (False, False)

def getNameUri(subject):

    try:

        response = requests.get('http://id.loc.gov/authorities/names/label/%s' % subject)
        link = response.url
        pattern = re.compile(r'(.+)\.html$')
        value = pattern.findall(link)[0].encode('utf-8')
        return ('http://id.loc.gov/authorities/names', value)        
    except:
        return (False, False)

with codecs.open('G://Metadata Projects/sheet_music/sheet_music.bib', 'rb') as fh:
    regexpNS = 'http://exslt.org/regular-expressions'
    modsNS = 'http://www.loc.gov/mods/v3'
    nameDict = defaultdict(int)
    reader = pymarc.MARCReader(fh, to_unicode=True)
    for record in reader:
        root = etree.XML(pymarc.record_to_xml(record, namespace=True))
        xslt_root = etree.parse(open('G:/Metadata Projects/sheet_music/sheet.xsl','r'), parser)
        transform = etree.XSLT(xslt_root)
        root = transform(root)

        title = root.xpath('/mods:mods/mods:titleInfo[not(@*)]/mods:title', namespaces={'mods': modsNS})[0].text
        bib = root.xpath('/mods:mods/mods:recordInfo/mods:recordIdentifier', namespaces={'mods': modsNS})[0].text
        print "----------------------------------------\nTransformation started for '%s.'\n" % title

        try:

            ## Get name URIs

            print "... Retrieving URIs for names and titles ...\n"

            pattern = re.compile("\s[A-Za-z]{2,}\.$")

            for name in root.findall(".//{http://www.loc.gov/mods/v3}name"):

                ## Strips period from end of name when the end of name is not an initial
                ##for namePart in name.findall('{http://www.loc.gov/mods/v3}namePart'):
                ##    if pattern.search(namePart.text):
                ##        namePart.text = namePart.text[:-1]
                
                ## First make sure that the URI hasn't already been added
                if 'valueURI' not in name.attrib or name.attrib['valueURI'] == "http://id.loc.gov/authorities/names/":
                    headingList = []
                    ## Assemble the name string to search
                    for namePart in name.findall('{http://www.loc.gov/mods/v3}namePart'):
                        headingList.append(namePart.text)
                        if headingList[-1] == '(Fictitious character)':
                            heading =" ".join(item.encode('utf-8') for item in headingList)
                        else:
                            heading =", ".join(item.encode('utf-8') for item in headingList)
                    ## Check whether we've previously matched the heading with a URI
                    if heading not in nameDict:

                        print "Fetching URI for: %s" % heading
                        authorityUri, valueUri = getNameUri(heading)

                        if valueUri is not False:
                            print "Retrieved URI: %s\n" % valueUri
                            name.set('authority', 'naf')
                            name.set('authorityURI', authorityUri)
                            name.set('valueURI', valueUri)
                            nameDict[heading] = ['naf', authorityUri, valueUri]
                            print "\n"
                        else:
                            print "No URI found."
                            name.set('authority', 'local')
                            print "\n"
                    else:
                        if heading in nameDict:
                            name.set('authority', nameDict[heading][0])
                            name.set('authorityURI', nameDict[heading][1])
                            name.set('valueURI', nameDict[heading][2])
                            print "Fetching URI for: %s" % heading
                            print "Retrieved URI: %s\n" % nameDict[heading][2]

            # Get uniform title

            for title in root.findall(".//{http://www.loc.gov/mods/v3}titleInfo[@type='uniform']"):
                ## First make sure that the URI hasn't already been added
                if 'valueURI' not in title.attrib or title.attrib['valueURI'] == "http://id.loc.gov/authorities/names/":
                    heading = title.find("{http://www.loc.gov/mods/v3}title").text
                    ## Check whether we've previously matched the heading with a URI
                    if heading not in nameDict:

                        print "Fetching URI for: %s" % heading
                        authorityUri, valueUri = getNameUri(heading)

                        if valueUri is not False:
                            print "Retrieved URI: %s\n" % valueUri
                            title.set('authority', 'naf')
                            title.set('authorityURI', authorityUri)
                            title.set('valueURI', valueUri)
                            nameDict[heading] = ['naf', authorityUri, valueUri]
                            print "\n"
                        else:
                            print "No URI found or supplied."
                            title.set('authority', 'local')
                            print "\n"

                    else:
                        if heading in nameDict:
                            title.set('authority', nameDict[heading][0])
                            title.set('authorityURI', nameDict[heading][1])
                            title.set('valueURI', nameDict[heading][2])
                            print "Fetching URI for: %s" % heading
                            print "Retrieved URI: %s\n" % nameDict[heading][2]

            ## Get genre and subject URIs

            print "... Retrieving URIs for genres and subjects ...\n"

            for genre in root.findall("{http://www.loc.gov/mods/v3}genre[@authority='lcsh']"):
                if 'valueURI' not in genre.attrib or genre.attrib['valueURI'] == "http://id.loc.gov/authorities/subjects/":
                    print "Fetching URI for: %s" % genre.text
                    authority, uri = getSubjectUri(genre.text)
                    if uri is not False:
                        print "Retrieved URI: %s\n" % uri

                        genre.set('authorityURI', authority)
                        genre.set('valueURI', uri)
                        print "\n"
                    else:      
                        print "Failed to retrieve URI\n"

            for genre in root.findall("{http://www.loc.gov/mods/v3}genre[@authority='lcgft']"):
                if 'valueURI' not in genre.attrib or genre.attrib['valueURI'] == "http://id.loc.gov/authorities/subjects/":
                    print "Fetching URI for: %s" % genre.text
                    authority, uri = getGenreFormUri(genre.text)
                    if uri is not False:
                        print "Retrieved URI: %s\n" % uri

                        genre.set('authorityURI', authority)
                        genre.set('valueURI', uri)
                        print "\n"
                    else:      
                        print "Failed to retrieve URI\n"
            
            for subject in root.findall("{http://www.loc.gov/mods/v3}subject[@authority='lcsh']"):
                if 'valueURI' not in subject.attrib or subject.attrib['valueURI'] == "http://id.loc.gov/authorities/subjects/":
                    headingList = []
                    for part in subject.findall('./*'):
                        if part.tag == '{http://www.loc.gov/mods/v3}name':
                            nameList = []
                            for namePart in part.findall('{http://www.loc.gov/mods/v3}namePart'):
                                nameList.append(namePart.text)

                            if nameList[-1] == '(Fictitious character)':
                                name =" ".join(str(item) for item in nameList)
                            else:
                                name =", ".join(str(item) for item in nameList)
                            headingList.append(name)
                        else:
                            headingList.append(part.text)

                    heading ="--".join(str(item) for item in headingList)

                    print "Fetching URI for: %s" % heading
                    authority, uri = getSubjectUri(heading)

                    if uri is not False:
                        print "Retrieved URI: %s\n" % uri

                        subject.set('authorityURI', authority)
                        subject.set('valueURI', uri)
                        print "\n"
                    else:
                        print "Failed to retrieve URI\n"

            for subject in root.findall("{http://www.loc.gov/mods/v3}subject[@authority='lcsh']/{http://www.loc.gov/mods/v3}topic"):
                if 'valueURI' not in subject.attrib or subject.attrib['valueURI'] == "http://id.loc.gov/authorities/subjects/":
                    print "Fetching URI for: %s" % subject.text
                    authority, uri = getSubjectUri(subject.text)

                    if uri is not False:
                        print "Retrieved URI: %s" % uri

                        subject.set('authorityURI', authority)
                        subject.set('valueURI', uri)
                        print "\n"
                    else:
                        print "Failed to retrieve URI\n"

            for subject in root.findall("{http://www.loc.gov/mods/v3}subject[@authority='lcsh']/{http://www.loc.gov/mods/v3}geographic"):
                if 'valueURI' not in subject.attrib or subject.attrib['valueURI'] == "http://id.loc.gov/authorities/subjects/":
                    print "Fetching URI for: %s" % subject.text
                    authority, uri = getSubjectUri(subject.text)

                    if uri is not False:
                        print "Retrieved URI: %s" % uri

                        subject.set('authorityURI', authority)
                        subject.set('valueURI', uri)
                        print "\n"
                    else:
                        print "Failed to retrieve URI\n"


            # Validate record and save to file    
           
            if xmlschema.validate(root) is True:  
                print root
                with open('G://Metadata Projects/sheet_music/test/mods/%s.xml' % bib, 'w') as output_file:
                    output_file.write(etree.tostring(root, pretty_print = True))
                print "Transformation complete for '%s.'\n----------------------------------------\n" % title
            else:
                print "Record failed to validate."
        except:
            print "Transformation failed for '%s.'\n----------------------------------------\n" % title
            continue

print nameDict
