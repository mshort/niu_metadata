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
        link = response.headers['X-URI']
        pattern = re.compile(r'(.+)\.html$')
        value = pattern.findall(link)[0].encode('utf-8')
        return ('http://id.loc.gov/authorities/subjects', value)   
    except:
        try:

            response = requests.get('http://id.loc.gov/authorities/names/label/%s' % subject)
            link = response.headers['X-URI']
            pattern = re.compile(r'(.+)\.html$')
            value = pattern.findall(link)[0].encode('utf-8')
            return ('http://id.loc.gov/authorities/names', value)        
        except:
            return (False, False)

def getNameUri(subject):

    try:

        response = requests.get('http://id.loc.gov/authorities/names/label/%s' % subject)
        link = response.headers['X-URI']
        pattern = re.compile(r'(.+)\.html$')
        value = pattern.findall(link)[0].encode('utf-8')
        return ('http://id.loc.gov/authorities/names', value)        
    except:
        return (False, False)

with codecs.open('C://Users/a1691506/Desktop/carter2.mrc', 'rb') as fh:
    regexpNS = 'http://exslt.org/regular-expressions'
    modsNS = 'http://www.loc.gov/mods/v3'
    nameDict = defaultdict(int)
    localList = []
    reader = pymarc.MARCReader(fh, to_unicode=True)
    for record in reader:
        root = etree.XML(pymarc.record_to_xml(record, namespace=True))
        xslt_root = etree.parse(open('G:/Administrivia/scripts/dime_novels/revision/dime_marcxml2mods.xsl','r'), parser)
        transform = etree.XSLT(xslt_root)
        root = transform(root)

        number = root.xpath('/mods:mods/mods:relatedItem[@type="series"]/mods:titleInfo/mods:partNumber', namespaces={'mods': modsNS})[0].text
        print "----------------------------------------\nTransformation started for %s.\n" % number

        try:

            ## Get name URIs

            print "... Retrieving URIs for names and titles ...\n"

            pattern = re.compile("\s[A-Za-z]{2,}\.$")

            for name in root.findall(".//{http://www.loc.gov/mods/v3}name"):

                ## Strips period from end of name when the end of name is not an initial
                for namePart in name.findall('{http://www.loc.gov/mods/v3}namePart'):
                    if pattern.search(namePart.text):
                        namePart.text = namePart.text[:-1]
                
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
                    if (heading not in nameDict) and (heading not in localList):

                        print "Fetching URI for: %s" % heading
                        authorityUri, valueUri = getNameUri(heading)

                        if valueUri is not False:
                            print "Retrieved URI: %s\n" % valueUri
                            response = raw_input('Proceed with transformation? (y/n): ')
                            if response == 'y':
                                name.set('authority', 'naf')
                                name.set('authorityURI', authorityUri)
                                name.set('valueURI', valueUri)
                                nameDict[heading] = ['naf', authorityUri, valueUri]
                                print "\n"
                            else:
                                response = raw_input('Do you wish to supply the URI? (y/n): ')
                                if response == 'y':
                                    authority = raw_input('Supplied authority: ')
                                    authorityUri = raw_input('Supplied authority URI: ')
                                    valueUri = raw_input('Supplied value URI: ')
                                    name.set('authority', authority)
                                    name.set('authorityURI', authorityUri)
                                    name.set('valueURI', valueUri)
                                    nameDict[heading] = [authority, authorityUri, valueUri]
                                    print "\n"
                                else:
                                    print "No URI found or supplied."
                                    name.set('authority', 'local')
                                    localList.append(heading)
                                    print "\n"
                        else:
                            print "Failed to retrieve URI for %s\n" % heading
                            response = raw_input('Do you wish to supply the URI? (y/n): ')
                            if response == 'y':
                                authority = raw_input('Supplied authority: ')
                                authorityUri = raw_input('Supplied authority URI: ')
                                valueUri = raw_input('Supplied value URI: ')
                                name.set('authority', authority)
                                name.set('authorityURI', authorityUri)
                                name.set('valueURI', valueUri)
                                nameDict[heading] = [authority, authorityUri, valueUri]
                                print "\n"
                            else:
                                print "No URI found or supplied."
                                name.set('authority', 'local')
                                localList.append(heading)
                                print "\n"
                    else:
                        if heading in nameDict:
                            name.set('authority', nameDict[heading][0])
                            name.set('authorityURI', nameDict[heading][1])
                            name.set('valueURI', nameDict[heading][2])
                            print "Fetching URI for: %s" % heading
                            print "Retrieved URI: %s\n" % nameDict[heading][2]
                        if heading in localList:
                            print "Failed to retrieve URI for %s" % heading
                            print "No URI found or supplied.\n"
                            name.set('authority', 'local')


            # Get uniform title

            for title in root.findall(".//{http://www.loc.gov/mods/v3}titleInfo[@type='uniform']"):
                ## First make sure that the URI hasn't already been added
                if 'valueURI' not in title.attrib or title.attrib['valueURI'] == "http://id.loc.gov/authorities/names/":
                    heading = title.find("{http://www.loc.gov/mods/v3}title").text
                    ## Check whether we've previously matched the heading with a URI
                    if (heading not in nameDict) and (heading not in localList):

                        print "Fetching URI for: %s" % heading
                        authorityUri, valueUri = getNameUri(heading)

                        if valueUri is not False:
                            print "Retrieved URI: %s\n" % valueUri
                            response = raw_input('Proceed with transformation? (y/n): ')
                            if response == 'y':
                                title.set('authority', 'naf')
                                title.set('authorityURI', authorityUri)
                                title.set('valueURI', valueUri)
                                nameDict[heading] = ['naf', authorityUri, valueUri]
                                print "\n"
                            else:
                                response = raw_input('Do you wish to supply the URI? (y/n): ')
                                if response == 'y':
                                    authority = raw_input('Supplied authority: ')
                                    authorityUri = raw_input('Supplied authority URI: ')
                                    valueUri = raw_input('Supplied value URI: ')
                                    title.set('authority', authority)
                                    title.set('authorityURI', authorityUri)
                                    title.set('valueURI', valueUri)
                                    nameDict[heading] = [authority, authorityUri, valueUri]
                                    print "\n"
                                else:
                                    print "No URI found or supplied."
                                    title.set('authority', 'local')
                                    localList.append(heading)
                                    print "\n"
                        else:
                            print "Failed to retrieve URI\n"
                            response = raw_input('Do you wish to supply the URI? (y/n): ')
                            if response == 'y':
                                authority = raw_input('Supplied authority: ')
                                authorityUri = raw_input('Supplied authority URI: ')
                                valueUri = raw_input('Supplied value URI: ')
                                title.set('authority', authority)
                                title.set('authorityURI', authorityUri)
                                title.set('valueURI', valueUri)
                                nameDict[heading] = [authority, authorityUri, valueUri]
                                print "\n"
                            else:
                                print "No URI found or supplied."
                                title.set('authority', 'local')
                                localList.append(heading)
                                print "\n"
                    else:
                        if heading in nameDict:
                            title.set('authority', nameDict[heading][0])
                            title.set('authorityURI', nameDict[heading][1])
                            title.set('valueURI', nameDict[heading][2])
                            print "Fetching URI for: %s" % heading
                            print "Retrieved URI: %s\n" % nameDict[heading][2]
                        if heading in localList:
                            print "Failed to retrieve URI for %s" % heading
                            print "No URI found or supplied.\n"
                            title.set('authority', 'local')

            ## Get genre and subject URIs

            print "... Retrieving URIs for genres and subjects ...\n"

            for genre in root.findall("{http://www.loc.gov/mods/v3}genre"):
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
            
            for subject in root.findall("{http://www.loc.gov/mods/v3}subject"):
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

            for subject in root.findall("{http://www.loc.gov/mods/v3}subject/{http://www.loc.gov/mods/v3}topic"):
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

            for subject in root.findall("{http://www.loc.gov/mods/v3}subject/{http://www.loc.gov/mods/v3}geographic"):
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

            ## Get W3DT date from note

            print "... Retrieving date then validating ..."

            find_date = etree.XPath("/mods:mods/mods:originInfo/mods:dateIssued[text()]", namespaces={'mods':modsNS})
            current_date = find_date(root)[0].text

            print "Current date: %s" % current_date

            test = re.compile('^[0-9]{4}$')

            if test.match(current_date):
            
                find = etree.XPath("/mods:mods/mods:note[re:match(text(), '[0-9]{4}\.?\W{1}--.+\.$')]", namespaces={'re':regexpNS, 'mods':modsNS})

                date_note = find(root)[0].text

                print "Extracted date note: %s" % date_note
                
                ## Transform date note into W3CDT
                try:
                    d = date_note.split('--')[0]

                    ## Notes occasionally end with (.) when transcribed
                    if d.endswith('."'):
                        date_object = datetime.strptime(d, '"%B %d, %Y."')
                        
                    else:
                        date_object = datetime.strptime(d, '"%B %d, %Y"')

                    date = str(date_object).split(' ')[0]

                    ##date = date_object.strftime("%Y-%m-%d")   ## datetime.strftime can't handle dates earlier than 1900, so we'll take our chances with splitting the string

                    print "Transformed date: %s" % date

                except:
                    date = raw_input('Date extraction failed. Please supply the date: ')

                root.find(".//{http://www.loc.gov/mods/v3}dateIssued").text = date


            # Validate record and save to file    
           
            if xmlschema.validate(root) is True:  
                print root
                with open('C:/Users/a1691506/Desktop/carter_mods2/%s.xml' % number, 'w') as output_file:
                    output_file.write(etree.tostring(root, pretty_print = True))
                print "Transformation complete for %s.\n----------------------------------------\n" % number
            else:
                print "Record failed to validate."
        except:
            print "Transformation failed for %s.\n----------------------------------------\n" % number
            continue

print nameDict
print localList
