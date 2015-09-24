import sys, solr, csv
from eulfedora.server import Repository

HOST = 'http://localhost:8080'
fedoraUser = 'xxx'
fedoraPass = 'xxx'


def main(argv):

    repo = Repository(root='%s/fedora/' % HOST, username='%s' % fedoraUser, password='%s' % fedoraPass).risearch
    s = solr.SolrConnection('%s/solr' % HOST)
    query = 'select ?pid where {?pid <fedora-rels-ext:isMemberOfCollection> <info:fedora/dimenovels:40>}'

    pids = repo.find_statements(query, language='sparql', type='tuples', flush=None)

    csvfile = open ("C:/Users/a1691506/Desktop/bdn.csv", 'wb')
    csvwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)

    for dictionary in pids:

      for key in dictionary:

        p = dictionary[key]
        pid = p.replace('info:fedora/', '')
        print pid

        response = s.query('PID:"%s"' % pid)

        results = repo.sparql_query('select ?pid where {?pid <fedora-rels-ext:isMemberOf> <info:fedora/%s> }' % pid)

        rows = list(results)
        pages = len(rows)

        try:

            for hit in response.results:

                title = hit['mods_title_full_ms'][0]
                number = hit['mods_series_number_ms'][0]
                date = hit['mods_dateIssued_ms'][0]

                csvwriter.writerow([pid, title, number, date, pages])
        except:

            print "%s failed." % pid

    csvfile.close()
        

        
        
if __name__ == '__main__':
    sys.exit(main(sys.argv))
