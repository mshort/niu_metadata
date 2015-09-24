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

        obj = pid.getDatastreamObject('MODS')
        obj.undo_last_save()

        # Because GSearch isn't listening, we have to index the update
        url = '%s/fedoragsearch/rest?operation=updateIndex&action=fromPid&value=%s' % (HOST, pid)
        gsearchOpener.open(url)

if __name__ == '__main__':
    sys.exit(main(sys.argv))
