import urllib, requests, re, sys
from lxml import etree
from eulfedora.server import Repository

HOST = 'http://localhost:8080'
fedoraUser = 'xxxx'
fedoraPass = 'xxxx'

def getURIs(subject):

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

def main(argv):

    pids = []
    repo = Repository(root='%s/fedora/' % HOST, username='%s' % fedoraUser, password='%s' % fedoraPass)
    results = repo.risearch.sparql_query('select ?pid where {?pid <fedora-rels-ext:isMemberOfCollection> <info:fedora/dimenovels:fame>}')
    for row in results:
        for k, v in row.items():
            pids.append(v.replace('info:fedora/', ''))

    for p in pids:

        print "Processing %s\n" % p

        pid = repo.get_object(p)

        try:
            ds = pid.getDatastreamObject('MODS')
            mods = pid.getDatastreamObject('MODS').content.serialize(pretty=True)
            root = etree.fromstring(mods)
            compare = etree.fromstring(mods)

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
                    authority, uri = getURIs(heading)

                    if uri is not False:
                        print "Retrieved URI: %s\n" % uri
                        #response = raw_input('Proceed with transformation? (y/n): ')

                        #if response == 'y':

                        subject.set('authorityURI', authority)
                        subject.set('valueURI', uri)
                        print "\n"
                    else:
                        print "Failed to retrieve URI\n"

            for subject in root.findall("{http://www.loc.gov/mods/v3}subject/{http://www.loc.gov/mods/v3}topic"):
                if 'valueURI' not in subject.attrib or subject.attrib['valueURI'] == "http://id.loc.gov/authorities/subjects/":
                    print "Fetching URI for: %s" % subject.text
                    authority, uri = getURIs(subject.text)

                    if uri is not False:
                        print "Retrieved URI: %s" % uri
                        #response = raw_input('Proceed with transformation? (y/n): ')

                        #if response == 'y':

                        subject.set('authorityURI', authority)
                        subject.set('valueURI', uri)
                        print "\n"
                    else:
                        print "Failed to retrieve URI\n"

            for subject in root.findall("{http://www.loc.gov/mods/v3}subject/{http://www.loc.gov/mods/v3}geographic"):
                if 'valueURI' not in subject.attrib or subject.attrib['valueURI'] == "http://id.loc.gov/authorities/subjects/":
                    print "Fetching URI for: %s" % subject.text
                    authority, uri = getURIs(subject.text)

                    if uri is not False:
                        print "Retrieved URI: %s" % uri
                        #response = raw_input('Proceed with transformation? (y/n): ')

                        #if response == 'y':

                        subject.set('authorityURI', authority)
                        subject.set('valueURI', uri)
                        print "\n"
                    else:
                        print "Failed to retrieve URI\n"
                            
            for subject in root.findall("{http://www.loc.gov/mods/v3}subject/{http://www.loc.gov/mods/v3}name"):
                if 'valueURI' not in subject.attrib or subject.attrib['valueURI'] == "http://id.loc.gov/authorities/subjects/":
                    nameList = []
                    for namePart in subject.findall('{http://www.loc.gov/mods/v3}namePart'):
                        nameList.append(namePart.text)

                    if nameList[-1] == '(Fictitious character)':
                        name =" ".join(str(item) for item in nameList)
                    else:
                        name =", ".join(str(item) for item in nameList)
                    print "Fetching URI for: %s" % name
                    authority, uri = getURIs(name)

                    if uri is not False:
                        print "Retrieved URI: %s\n" % uri
                        #response = raw_input('Proceed with transformation? (y/n): ')

                        #if response == 'y':

                        subject.set('authorityURI', authority)
                        subject.set('valueURI', uri)
                        print "\n"
                    else:
                        print "Failed to retrieve URI\n"

            new = etree.tostring(root)
            old = etree.tostring(compare)

            if new == old:
                print "No changes have been made to %s. Moving on.\n" % p
                print "----------------------------------------\n"
                
            else:
                ds.content = new
                ds.save()

                print "Finished processing %s\n" % p
                print "----------------------------------------\n"
                
        except:
            print "Failed to retrieve %s. Check it!\n\n" % p

if __name__ == '__main__':
    sys.exit(main(sys.argv))
