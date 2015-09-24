import sys, urllib2, solr, csv
from eulfedora.server import Repository

HOST = 'http://localhost:8080'
fedoraUser = 'xxx'
fedoraPass = 'xxx'

def main(argv):

    pids = []    
    s = solr.SolrConnection('%s/solr' % HOST)
    repo = Repository(root='%s/fedora/' % HOST, username='%s' % fedoraUser, password='%s' % fedoraPass)
    results = repo.risearch.sparql_query('PREFIX dime: <http://dimenovels.org/ontology#> select ?pid where {?pid <fedora-rels-ext:isMemberOfCollection> <info:fedora/dimenovels:fame> . OPTIONAL { ?pid dime:IsCopyOf ?copy } FILTER (! BOUND(?copy)) }')
    for row in results:
        for k, v in row.items():
            pids.append(v.replace('info:fedora/', ''))

    with open('C:/Users/a1691506/Desktop/ffw_editions.csv', mode='r') as infile:
        reader = csv.reader(infile)
        editionDict = {rows[0]:rows[1] for rows in reader}

    for p in pids:

        print "Processing %s" % p

        try:
            response = s.query('PID:"%s"' % p)
            
            for hit in response.results:
                number = hit['mods_series_number_ms'][0].split(' ')[1]

            editionUri = editionDict[number]
                
            obj = repo.get_object(p)
            obj.add_relationship('http://dimenovels.org/ontology#IsCopyOf', editionUri)
            obj.save()
        except:
            print "%s failed. Check it!" % p
            continue

if __name__ == '__main__':
    sys.exit(main(sys.argv))
