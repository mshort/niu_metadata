import sys, urllib2
from lxml import etree
from eulfedora.server import Repository

HOST = 'http://localhost:8080'
fedoraUser = 'xxx'
fedoraPass = 'xxx'
passwordManager = urllib2.HTTPPasswordMgrWithDefaultRealm()
gsearch = "%s/fedoragsearch/rest" % HOST
passwordManager.add_password(None, gsearch, fedoraUser, fedoraPass)
handler = urllib2.HTTPBasicAuthHandler(passwordManager)
gsearchOpener = urllib2.build_opener(handler)

def main(argv):

    collection = 'rhrc:002'
    pids = []
    repo = Repository(root='%s/fedora/' % HOST, username='%s' % fedoraUser, password='%s' % fedoraPass)
    results = repo.risearch.sparql_query('select ?pid where {?pid <fedora-rels-ext:isMemberOfCollection> <info:fedora/%s>}' % collection)
    for row in results:
	for k, v in row.items():
		pids.append(v.replace('info:fedora/', ''))

    for p in pids:

        pid = repo.get_object(p)
        mods = pid.getDatastreamObject('MODS').content
        xsl = '''<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" version="1.0">
    <xsl:output omit-xml-declaration="yes"/>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="accessCondition">
        <accessCondition type="useAndReproduction"> Property rights in the collection belong to the
            Regional History Center; literary rights are dedicated to the public. Print
            reproductions and high-resolution scans can be obtained for a small fee. For more
            information about rights and reproductions, visit http://rhc.lib.niu.edu/rights
        </accessCondition>
    </xsl:template>
    <xsl:template match="mods:accessCondition">
        <mods:accessCondition type="useAndReproduction"> Property rights in the collection belong to the
            Regional History Center; literary rights are dedicated to the public. Print
            reproductions and high-resolution scans can be obtained for a small fee. For more
            information about rights and reproductions, visit http://rhc.lib.niu.edu/rights
        </mods:accessCondition>
    </xsl:template>
</xsl:stylesheet>
'''
        new = mods.xsl_transform(xsl=xsl)
        obj = pid.getDatastreamObject('MODS')
        obj.content = new.serialize(pretty=True)
        obj.save()

        # Because GSearch isn't listening, we have to index the update
        url = '%s/fedoragsearch/rest?operation=updateIndex&action=fromPid&value=%s' % (HOST, pid)
        gsearchOpener.open(url)

if __name__ == '__main__':
    sys.exit(main(sys.argv))
