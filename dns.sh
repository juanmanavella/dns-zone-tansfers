# This script takes a domain or top level domain list as an argument and then, 
# tries to get full domain zones using zone transfers by querying each of its DNS.
#
# It will create a sucess dir inside the working dir specified path and a
# txt timestamped file for each successful zone transfer in format:
#
# DOMAIN_at_queried-name-serve-axfr-timestamp.txt
#
# By default it will query the entire internet namespace using IANA's TLD lists at:
# http://data.iana.org/TLD/tlds-alpha-by-domain.txt
#
# Feel free to fork or contact me at juanmanavella at gmail dot com.
#
#!/bin/bash


### Script constants, edit below:

# URL from where to fetch the Domains or TLDs list:
DOMAINS_LIST=http://data.iana.org/TLD/tlds-alpha-by-domain.txt


# Define local paths:
WORKING_DIR=/root/DNS 	# The dir where all the files will be stored.
LOCAL_DOMAINS_LIST=tlds.txt  # the local file containing a copy of the domains list.

# Wich DNS Server to query:
SERVER=8.8.8.8

### Stop editing here.


# Create the working dir if not exists:
mkdir -p $WORKING_DIR

# Create the local TLDs database:
echo "Getting the TLDs database..."
curl $DOMAINS_LIST | tee $WORKING_DIR/$LOCAL_DOMAINS_LIST > /dev/null 2&>1
echo "Done!"


# Create a dir for storing tld nameservers:
mkdir -p $WORKING_DIR/ns

# Create a dir to store successful zone transfers:
mkdir -p $WORKING_DIR/success

# Create a dir for temporary files:
mkdir -p $WORKING_DIR/tmp

while read t; 
	
do 
 echo "Getting $t Name Servers"
 dig +noall +answer $t ns @$SERVER | awk '{print $NF}' > "${WORKING_DIR}/ns/${t}.tld.ns"
 
  while read n
  do
    QUERY=`dig +noall +answer axfr $t @$n | grep -v ";" | tee $WORKING_DIR/tmp/cache.txt`
      if [ -n "$QUERY" ]
      then
       cat $WORKING_DIR/tmp/cache.txt >> "${WORKING_DIR}/success/${t}_at_${n}axfr-`date +%Y-%m-%d-%H-%M`.txt"
      fi
  done < "${WORKING_DIR}/ns/${t}.tld.ns"

done < $WORKING_DIR/$LOCAL_DOMAINS_LIST

# Cleanup
rm -fr $WORKING_DIR/tmp

# Delete all unsuccesful transfer files from root-servers:
find ${WORKING_DIR}/success/ -size 481c -delete

exit 0
