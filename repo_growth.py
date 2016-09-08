import sys, urllib2, csv
from eulfedora.server import Repository

HOST = 'http://localhost:8080'
fedoraUser = 'xxx'
fedoraPass = 'xxx'

def main(argv):

    csvfile = open ("C:/Users/a1691506/Desktop/repo_size.csv", 'wb')
    csvwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)

    repo = Repository(root='%s/fedora/' % HOST, username='%s' % fedoraUser, password='%s' % fedoraPass)
    risearch = repo.risearch
    query = 'select ?pid ?date where {?pid <fedora-model:hasModel> <info:fedora/fedora-system:FedoraObject-3.0> ; <fedora-model:createdDate> ?date . } ORDER BY ASC(?date)'

    pids = risearch.find_statements(query, language='sparql', type='tuples', flush=None)

    repo_size = 0

    for dictionary in pids:

        p = dictionary['pid']
        pid = p.replace('info:fedora/', '')

        dateCreated = dictionary['date']

        total_size = 0
        obj = repo.get_object(pid)
        datastreams = obj.ds_list
        for datastream in datastreams:
            ds = obj.getDatastreamObject(datastream)
            size = ds.size
            total_size += size
        repo_size += total_size
        
        print "Total size for %s: %s" % (pid, total_size)

        csvwriter.writerow([pid, dateCreated, total_size, repo_size])


if __name__ == '__main__':
    sys.exit(main(sys.argv))
