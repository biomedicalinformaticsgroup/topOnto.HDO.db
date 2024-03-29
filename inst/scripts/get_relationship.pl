#!/usr/bin/perl
###################################
# Adapted from the DO.db package.
###################################
use strict;
use warnings;


#my $usage=<<USAGE;
#perl $0 inputfile
#		--inputfile is the obo format file
#		  for example perl $0 HumanDO.obo
#USAGE
#
##check the parameter
#if(@ARGV<1){
#	print $usage;
#	exit(1);
#}

my $infile=$ARGV[0];
#my $infile='my.obo';


#read the inputed file and fetch the information we wanted.
#finally we will get three files
open(IN,$infile) or die $!;
open(O1,">child2parent.txt") or die $!;
open(O2,">parent2offspring.txt");
print O1 "id\tparent_id\n";
print O2 "Father_node\toffsprint_node\n";

my $str="";
my $is_finish=0;
my %parent2child;
my %ids;
while(<IN>){
	if($is_finish){last;}
	if(/^\[Term\]/ || /^\[Typedef\]/ || eof){
		if($str){
			#get the id and names
			unless($str=~/^\[Term\]/ ){$str=$_;next ;}
			my ($id,$name);
			if($str=~/id: (.*)\n/){
				$id=$1;
			}
			if($str=~/name: (.*?)\n/){
				$name=$1;
			}
			
			my $flag=0;
			#determine whether have string "is_obsolete: true"
			if($str=~/is_obsolete/){
				$flag=1;
			}else{
				##handle is_a
				while($str=~/(is_a: .*?)\n/g){
					my $tmp=$1;
					if($tmp=~/is_a: (.*)\s!\s/){
						if($id ne $1){
							print O1 join "\t",($id,$1);
							print O1 "\n";
							$parent2child{$1}->{$id}=1;
							$ids{$id}=1;
							$ids{$1}=1;
						}
					}
				}
				
				##handle part_of
				while($str=~/(relationship: part_of .*?)\n/g){
					my $tmp=$1;
					if($tmp=~/relationship: part_of (.*)\s!\s/){
						if($id ne $1){
							print O1 join "\t",($id,$1);
							print O1 "\n";
							$parent2child{$1}->{$id}=1;
							$ids{$id}=1;
							$ids{$1}=1;
						}
					}
				}
				
				
			}
		
		}
		$str=$_;
		if( /^\[Typedef\]/){
			$is_finish=1;
		}
	}else{
		$str.=$_;
	}
}
my $index=0;
foreach my $p(keys %ids){
	$index++;
	#print "Doing $index with $p\n";
	my $rr={};
	findnodes($p,\%parent2child,$rr);
	if(keys %{$rr}){
		foreach my $c(keys %{$rr}){
			print O2 join "\t",($p,$c);
			print O2 "\n";
		}
	}
}


close O1;
close O2;
close IN;
sub findnodes{
        my($search,$ref,$resultref)=@_;
        if(exists($ref->{$search})){
                foreach my $node(keys %{$ref->{$search}}){
                        $resultref->{$node}=1;
                        findnodes($node,$ref,$resultref);
                }
        }else{
                return $resultref;
        }
}



=head sample data from Disease Ontology
format-version: 1.2
date: 06:04:2010 14:44
saved-by: laronhughes
auto-generated-by: OBO-Edit 2.1-beta3
default-namespace: disease_ontology
remark: This is an alpha version and is only for experimental implementation.

[Term]
id: DOID:0000000
name: gallbladder disease
xref: GeneRIF:14567398
xref: UMLS_ST:T047
is_a: DOID:77 ! gastrointestinal system disease

[Term]
id: DOID:0000109
name: maturation disease
is_obsolete: true

[Term]
id: DOID:0000634
name: body growth disease
is_obsolete: true

[Term]
id: DOID:0050012
name: chikungunya
synonym: "Chikungunya fever" RELATED []
synonym: "Chikungunya virus disease " RELATED []
xref: ICD10:A92.0
is_a: DOID:1329 ! arbovirus infectious disease
=cut
