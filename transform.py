import sys, urllib
from lxml import etree
from fcrepo.connection import *
from fcrepo.client import *
import logging
import time

## Create logger
logging.basicConfig(filename='mods_conversion.txt',
                            filemode='a',
                            format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s',
                            datefmt='%H:%M:%S',
                            level=logging.INFO)

logging.info("Running MODS conversion on niu-gildedage:collection collection")

HOSTURL = 'localhost'
style = 'lincoln_mods2mods.xsl'

def getPidsFromCollection(collection):

    # Format collection pid for RI query
    if not (collection.startswith('<') or collection.endswith('>')):
        collection = '<info:fedora/%s>' % collection

    # Query for objects in a particular collection
    query_string = 'select $object from <#ri> where $object <fedora-rels-ext:isMemberOfCollection> %s' % collection
    url = urllib.urlopen('http://%s:8080/fedora/risearch?type=tuples&flush=TRUE&format=Sparql&lang=itql&stream=on&query=%s' % (HOSTURL, urllib.quote_plus(query_string)))

    # Create the xml parser to retrieve the results
    parser = etree.XMLParser(remove_blank_text=True)
    xmlFile = etree.parse(url, parser)
    xmlFileRoot = xmlFile.getroot()

    # Create array for pids
    results = []
    pids = []
    ns = { 'results' : 'http://www.w3.org/2001/sw/DataAccess/rf1/result' }
    xmlPids = xmlFileRoot.xpath('/results:sparql/results:results/results:result/results:object', namespaces=ns)
    pids = [p.attrib['uri'] for p in xmlPids]
    return pids

def main(argv):

    # Make Fedora connection
    fedora = Connection('http://localhost:8080/fedora',
  		username='fedoraAdmin',
			password='password')
    if not fedora:
        logging.error('Failed to connect to fedora instance')
        return 1

    # Create REST client
    client = FedoraClient(fedora)

    # Retreive pids from collection
    collection_pids = getPidsFromCollection('niu-gildedage:collection')
    logging.info('Found %d objects to transform' % len(collection_pids))

    # Loop through collection pids and retreive each object
    for pid in collection_pids:
        strippedPid = pid.replace('info:fedora/', '')
        logging.info((strippedPid) + ' ...',)
        try:
            obj = client.getObject(strippedPid)
        except FedoraConnectionException, fcx:
            logging.exception('Failed to connect to object %s' % pid)
            continue

        # Apply xsl to MODS datastream using saxon, then read output to memory

        mods = urllib.urlopen('http://localhost:8080/saxon/SaxonServlet?source=http://localhost/islandora/object/%s/datastream/MODS&style=%s' % (strippedPid, style))
        xml = mods.read()

        # Python 2.7 makes no string/byte distinction, so decode
        # into unicode, then to ascii to unicode
        xml = xml.decode('utf-8')
        xml = xml.encode('ascii', 'xmlcharrefreplace').decode('utf-8')
        

        # Retreive MODS datastream

        try:
            ds = obj['MODS']

        # If no MODS, log and continue    
        except FedoraConnectionException, fcx:
            logging.exception('Failed to connect to MODS datastream for %s' % pid)
            continue
        
        ## Read MODS to memory      
        ds_string = ds.getContent().read()       
        ds_string = ds_string.decode('utf-8')
        ds_string = ds_string.encode('ascii', 'xmlcharrefreplace').decode('utf-8')


        ## Replace content of datastream
        ds_replacement = ds_string.replace(ds_string, xml)

        ds_replacement = ds_replacement.replace('[[pid]]',strippedPid)
        
        try:

            # HTTP PUT can sometimes be sent too quickly, in which case
            # HTML is sent and we get an XML validation error
            time.sleep(0.3)

            # Send replacement and validate
            ds.setContent(ds_replacement)
        except FedoraConnectionException, fx:

            # Log any XML validation errors (see above)
            logging.exception('Failed to replace content of MODS datastream for %s' % pid)
            continue
        
        logging.info('Done')

if __name__ == '__main__':
    sys.exit(main(sys.argv))
