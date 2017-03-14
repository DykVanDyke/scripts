# collect all files into arrays

my @files_cpa = `find . -type f -name "res_irp_cpa*"`;
chomp @files_cpa;

my @files_frais = `find . -type f -name "res_irp_frais*"`;
chomp @files_frais;

# init the results hash struct
my $results = undef;

# loop into cpa files and read them to collect the keys (prtf;dateVL) alltogether with the filenames
foreach my $file (@files_cpa){
        my $filename = `basename $file`;
        chomp $filename;
	# print "\nOpenning $file\n";
	open my $fh, '<', $file;
	while (my $line = <$fh>) {
           my $fields = undef;
           @$fields = split(';',$line);
           my $key = $fields->[0].";".$fields->[3];
           if ( not defined $results->{$key}->{'cpa'} ) {
              $results->{$key}->{'cpa'} = $filename;
              $results->{$key}->{'frais'} = undef if ( not defined $results->{$key}->{'frais'} );
	   }
	}
        $fields = undef;
        close $fh;
}

#use Data::Dumper;
#print Dumper($results);

# loop into frais files and read them to collect the keys (prtf;dateVL) alltogether with the filenames
foreach my $file (@files_frais){
        my $filename = `basename $file`;
        chomp $filename;
        open my $fh, '<', $file;
        while (my $line = <$fh>) {
           my $fields = undef;
           @$fields = split(';',$line);
           my $key = $fields->[2].";".$fields->[4];
           if ( not defined $results->{$key}->{'frais'} ) {
              $results->{$key}->{'frais'} = $filename;
              $results->{$key}->{'cpa'} = undef if ( not defined $results->{$key}->{'cpa'} );
           }
        }
        $fields = undef;
        close $fh;
}

# print Dumper($results);

# write final CSV with following columns: prtf; dateVL; cpa file; frais file;

open my $fh,'>','index.csv'; 
my $flag = undef;
print $fh "prtf;date VL;cpa file;frais file";
foreach my $key (keys %$results){
	print $fh $key.";".$results->{$key}->{'cpa'}.";".$results->{$key}->{'frais'}."\n";
        $flag = 1;
}
close $fh;
print "Writen index file index.csv...\n" if (defined $flag);


