#!/usr/bin/awk -f

function basename(file) {
	sub(".*/", "", file)
	return file
}

BEGIN { 

	FS=";"

	if ( ARGC == 1 ){
		print "Usage: compliance_inv.awk [file_to_parse]"
		exit;
	}
	if ( FILENAME !~ /INV_compliance_bpas_.+\.csv$/){
		print "========================================================================\n"
		print "This script is intended to process only files INV_compliance_bpas_*csv.\n"
		print "You have to rename it and add the \".csv\" extension!\nSorry :("
		print "========================================================================\n"
		exit; 
	}
	print "File to parse: " FILENAME
	
	# Build output base filename...
	ofname=FILENAME
	gsub(".*/", "", ofname)   # drop pathname
	gsub(/.csv/, "", ofname)  # drop .csv extension
	
	# build output filenames: 
	file1 = ofname "-not-null-wholeline.csv"
	file2 = ofname "-not-null-prtf-navdate.csv"
	file2_test = file2 "-onthefly"
	
	file3 = ofname "-null-wholeline.csv"
	file4 = ofname "-null-prtf-navdate.csv"

	# delete previous files if present
	list=file1 " " file2 " " file3 " " file4 ; cmd="rm -f " list; print "Deleting files: " list
	system(cmd)
}

#########################################################
#                                                       #
#    actions of this AWK script begin here....          #
#                                                       #
#########################################################

###  $2 is NAV date; $3 is portfolio code; 
###  $107 and $108 are the fields under investigation

{	
	mykey = $3 ";" $2

	if ( ( $107 !~ /^ +$/ ) && ( $108 !~ /^ +$/ ) ) {
		print $0 >> file1	
		
		# writing the file "on the fly".  But without the extra sugar info of the counting 
		if ( ! keys2[mykey] )  {
			print mykey >> file2_test
		}
		keys2[mykey]++
		
	}else{
		print $0 >> file3
		keys4[mykey]++
	}

}

END{	
	
	#	
	for (k in keys2) {
		print k ";" keys2[k] >> file2
	}
	for (k in keys4) {
		print k ";" keys4[k] >> file4
	}	
}
