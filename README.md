#NIU Metadata Creation and Remediation

This repository contains scripts and stylesheets developed by Technical Services at NIU to make metadata creation and remediation easier in Fedora. Canonical versions of the NIU Data Dictionary, as well as project specifications, are also included.

add_pid_location.py is executed after ingest to add mods:url with the pid to each object in a particular collection.

apply_xsl.py is equivalent to a batch edit and will apply an XSL transformation to the MODS datastream of every object in a collection. This is useful when a problem is identified after ingest with all of the records in a collection.

dime_novel_transform.py is used to convert MARC records (.mrc) into MODS for the dime novel collection. It does some limited string-to-URI reconciliation with LCNAF and LCSH and also extracts structured dates in w3cdt from 500 notes. Catalogers run the script on a batch of MARC records and are prompted to approve URIs or to submit alternatives. This script contains versions of retrieve_subject_uris.py and structured_dates.py.

transform.py was the original script used to transform records with local stylesheets, using fcrepo. This required a bit of string encoding/decoding. eul-fedora is now used instead (see apply_xsl.py above).

undo_last.py is used when a mistake is made with a batch edit, typically after running appy_xsl.py. It reverts the MODS datastream to the previous version.

solr_query.py is useful for quickly pulling out data from the index into a CSV file. This makes it easier to generate reports and to quickly identify recurring problems.

add_edition_uri.py was written specifically for the dime novel collection. It will read edition URIs from a CSV, retrieve data about the issues from Solr, and add edition URIs to the RELS-EXT of matching objects.
