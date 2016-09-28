This script takes a domain or top level domain list as an argument and then, 
tries to get full domain zones using zone transfers by querying each of its DNS.

It will create a sucess dir inside the working dir specified path and a
txt timestamped file for each successful zone transfer in format:

DOMAIN_at_queried-name-serve-axfr-timestamp.txt

By default it will query the entire internet namespace using IANA's TLD lists at:
http://data.iana.org/TLD/tlds-alpha-by-domain.txt

Feel free to fork or contact me at juanmanavella at gmail dot com.
