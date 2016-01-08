#!/usr/bin/perl
# uploads a vagrant base to atlas
# synthax is ./uploadBox.pl jessie64 8.3.0
# TODO: move changelog into json manifest instead of hardcoding it here

use feature 'say';
use strict;
use warnings;
use JSON;
use LWP::UserAgent;
use HTTP::Request::Common;
use Data::Dumper; 
use Cwd;
use URI::Escape;

# see https://vagrantcloud.com/docs/versions
# put an atlas token in your env like this
# export ATLAS_TOKEN=$(gpg --decrypt ../helpers/token.gpg)
my $ua = LWP::UserAgent->new;

my $atlas_token = $ENV{'ATLAS_TOKEN'} || die 'ATLAS_TOKEN needed';

my ($codename, $version, $version_log) = @ARGV;
$codename //= $ENV{'CODENAME'} || die 'CODENAME needed';
$version //= $ENV{'BOX_VERSION'} || die 'BOX_VERSION needed';
if (defined $version_log) {
    $version_log = uri_escape($version_log);
} else {
    $version_log = uri_escape('* various build chain improvements, see http://anonscm.debian.org/cgit/cloud/debian-vm-templates.git/ for details');
}

my $provider = $ENV{'PROVIDER'} || 'virtualbox';
my $end_point = 'https://atlas.hashicorp.com/api/v1/box/debian';
my $auth_param = "-d access_token=$atlas_token";
my $builder_dir = getcwd;

my $json_printer = JSON->new();
my $verbose = 1;

sub dump_json {
	my $json_struct = shift;
	say  $json_printer->canonical->pretty->encode($json_struct);
}

sub curl2json {
	my $curl = shift;
	open(CURL, $curl) or die "Can't open '$curl': $!";
	
	my $answer = '';
	while (<CURL>) {
		$answer .= $_;
	}
	my $json = JSON::decode_json($answer);
	dump_json($json) if $verbose;
	return $json;
}


sub check_version {
	my $url = "$end_point/$codename/version/$version";
	my $curl = 'curl --silent "'
	  . $url
	  . '?'
	  . "access_token=$atlas_token\""
      . " |";

	# decode an utf-8 formatted string, parse this at json, returns reference
	my $answer = curl2json($curl);
	
	if ( defined($answer->{'version'}) ) {
		return $answer->{'version'};
	} else {
		return 0;
	}
}

sub delete_version {
	my $url= "$end_point/$codename/version/$version";
	my $curl = "curl --silent -X DELETE"
		. " $url"
        . " $auth_param"
        . " |";

    my $json_struct = curl2json($curl);

}		

sub create_version {
	my $url = "$end_point/$codename/versions";
	my $curl = "curl --silent -X POST"
		. " $url"
		. " -d version[version]=$version"
		. " -d version[description]=$version_log"
        . " $auth_param"
        . " |";
        
	my $json_struct = curl2json($curl);
	
	if ( defined($json_struct->{'version'}) ) {
		return ($json_struct->{'version'} eq $version); 
	} else {
		say dump_json($json_struct);
		return 0;
	}

}

sub create_provider {
	my $url = "$end_point/$codename/version/$version/providers";
	my $curl = "curl --silent -X POST"
		. " $url -d provider[name]=$provider"
        . " $auth_param"
        . " |";
	
	my $json_struct = curl2json($curl);
        
	if ( defined($json_struct->{'name'}) ) {
		return ($json_struct->{'name'} eq $provider); 
	} else {
		say dump_json($json_struct);
		return 0;
	}
    
}

sub get_upload_path {
	my $url = "$end_point/$codename/version/$version/provider/$provider/upload";
	my $curl = "curl --silent -X GET"
		. " $url"
        . " $auth_param"
        . " |";
        
    my $json_struct = curl2json($curl);
	return $json_struct->{'upload_path'};    
}

sub upload_box {
	my ($url) = @_;
	my $curl = "curl  -X PUT"
		. " $url"
		. " --upload-file $builder_dir/$codename.box"
        . " |";

    open(CURL, $curl) or die "error: $!";
    while (<CURL>) { say; }
}

if (create_version() && create_provider()) {
	upload_box(get_upload_path());
} else {
	print "unable to upload new box\n";
	exit(255);
}
