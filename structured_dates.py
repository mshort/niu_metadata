## Transforms unstructured date notes into structured mods:dateIssued in w3cdt

import sys, urllib2, re
from lxml import etree
from datetime import datetime
from eulfedora.server import Repository

HOST = 'http://polaris-dev.lib.niu.edu:8080'
fedoraUser = 'xxxx'
fedoraPass = 'xxxx'
passwordManager = urllib2.HTTPPasswordMgrWithDefaultRealm()
gsearch = "%s/fedoragsearch/rest" % HOST
passwordManager.add_password(None, gsearch, fedoraUser, fedoraPass)
handler = urllib2.HTTPBasicAuthHandler(passwordManager)
gsearchOpener = urllib2.build_opener(handler)

def main(argv):

    pids = []
    repo = Repository(root='%s/fedora/' % HOST, username='%s' % fedoraUser, password='%s' % fedoraPass)
    results = repo.risearch.sparql_query('select ?pid where {?pid <fedora-rels-ext:isMemberOfCollection> <info:fedora/dimenovels:pluckluck>}')
    for row in results:
        for k, v in row.items():
            pids.append(v.replace('info:fedora/', ''))

    not_found = []
    failed = []

    for p in pids:

        print "Currently processing: %s" % p

        pid = repo.get_object(p)

        try:
            mods = pid.getDatastreamObject('MODS').content
            mods_string = mods.serializeDocument(pretty=True)

            ## Get date note
            root = etree.XML(mods_string)
            regexpNS = 'http://exslt.org/regular-expressions'
            modsNS = 'http://www.loc.gov/mods/v3'

            ## Check to see if date needs transforming
            find_date = etree.XPath("/mods:mods/mods:originInfo/mods:dateIssued[text()]", namespaces={'mods':modsNS})
            current_date = find_date(root)[0].text

            print "Current date: %s" % current_date

            test = re.compile('^[0-9]{4}$')

            if test.match(current_date):
            
                find = etree.XPath("/mods:mods/mods:note[re:match(text(), '[0-9]{4}\W{1}--.+\.$')]", namespaces={'re':regexpNS, 'mods':modsNS})

                try:
                    date_note = find(root)[0].text

                    print "Extracted date note: %s" % date_note
                    
                    ## Transform date note into W3CDT
                    d = date_note.split('--')[0]
                    date_object = datetime.strptime(d, '"%B %d, %Y"')
                    date = date_object.strftime("%Y-%m-%d")

                    print "Transformed date: %s" % date

                    y = 'yes'

                    response = input('Proceed with transformation? (y/n): ')

                    if response is 'yes':
                    
                        xsl = '''<?xml version="1.0" encoding="UTF-8"?>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3" version="2.0">
                <xsl:output omit-xml-declaration="yes" method="xml" indent="yes"/>
                <xsl:template match="@*|node()">
                    <xsl:copy>
                        <xsl:apply-templates select="@*|node()"/>
                    </xsl:copy>
                </xsl:template>
                
                <xsl:template match="mods:dateIssued">
                    <mods:dateIssued encoding="w3cdtf" keyDate="yes">%s</mods:dateIssued>
                </xsl:template>

                <xsl:strip-space elements="*"/>

            </xsl:stylesheet>''' % date
                        new = mods.xsl_transform(xsl=xsl)
                        obj = pid.getDatastreamObject('MODS')
                        obj.content = new.serialize(pretty=True)
                        obj.save()

                        # Because GSearch isn't listening, we have to index the update
                        url = '%s/fedoragsearch/rest?operation=updateIndex&action=fromPid&value=%s' % (HOST, pid)
                        gsearchOpener.open(url)

                        print "Successfully transformed %s.\n\n" % p

                    else:
                        continue
                except:
                    print "Date note not found for %s." % p
                    not_found.append(p)
            else:
                print "There is no need to transform %s. Moving on.\n\n" % p
                continue

        except:
            print "%s failed. Check it!\n\n" % p
            failed.append(p)

    print 'No date note could be found for these pids: %s' % not_found
    print 'Failed to retreive MODS for these pids: %s' % failed

if __name__ == '__main__':
    sys.exit(main(sys.argv))
