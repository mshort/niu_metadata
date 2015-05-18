import sys, urllib2
from lxml import etree
from eulfedora.server import Repository

HOST = 'xxxx'
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
    results = repo.risearch.sparql_query('select ?pid where {?pid <fedora-rels-ext:isMemberOfCollection> <info:fedora/dimenovels:fame>}')
    for row in results:
        for k, v in row.items():
            pids.append(v.replace('info:fedora/', ''))

    for p in pids:

        print p

        pid = repo.get_object(p)
        try:
            mods = pid.getDatastreamObject('MODS').content
            xsl = '''<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mods="http://www.loc.gov/mods/v3" version="1.0">
    <xsl:output omit-xml-declaration="yes" method="xml" indent="yes"/>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mods:url">
        <mods:url access="object in context" usage="primary display">http://dimenovels.lib.niu.edu/islandora/object/dimenovels:%s</mods:url>
    </xsl:template>

    <xsl:strip-space elements="*"/>

</xsl:stylesheet>
''' % p
            new = mods.xsl_transform(xsl=xsl)
            obj = pid.getDatastreamObject('MODS')
            obj.content = new.serialize(pretty=True)
            obj.save()

            # Because GSearch isn't listening, we have to index the update
            url = '%s/fedoragsearch/rest?operation=updateIndex&action=fromPid&value=%s' % (HOST, pid)
            gsearchOpener.open(url)
        except:
            print "%s failed. Check it!" % p

if __name__ == '__main__':
    sys.exit(main(sys.argv))
