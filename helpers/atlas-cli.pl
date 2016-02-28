#!/usr/bin/perl
# uploads a vagrant base to atlas
# synthax is ./uploadBox.pl jessie64

use feature 'say';
use strict;
use warnings;
use English;

use JSON;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response; 
use Cwd;

use Data::Dumper;

# see https://vagrantcloud.com/docs/versions
# put an atlas token in your env like this
# export ATLAS_TOKEN=$(gpg --decrypt ../helpers/token.gpg)
my $atlas_token = $ENV{'ATLAS_TOKEN'} || die 'please set ATLAS_TOKEN';
my $builder_dir = getcwd;
my ($codename) = $ARGV[0] // 'testing64';

my $manifest =join('', $builder_dir, '/', $codename, '.json');
my $version = json_fileread('box_version', $manifest);
my $version_log = json_fileread('box_changelog', $manifest);
my $provider = 'virtualbox';
my $end_point = 'https://atlas.hashicorp.com/api/v1/box/debian';

my $ua = LWP::UserAgent->new;
my $JSONprinter = JSON->new()->canonical->pretty;
my $verbose = 1;

sub json_fileread {
	my ($key, $template) = @_;
	my $json;

	{
		local $INPUT_RECORD_SEPARATOR = undef;
		open (my $fh, "<", $template) or die "could not find $template";
		$json = <$fh>;
		close $fh;
	}

	my $manifest = decode_json($json);
	my $value = $manifest->{'variables'}->{$key} if $manifest->{'variables'}->{$key};
	defined($value) && return $value or die "unable to find $key in $template";
}

sub printJSON {
	my ($response, $debug) = @_;
	
	if (defined $debug) {
		print $response->status_line(), "\n";
		print Dumper($response);
		return;
	}	

	if ($response->is_success) {
			if ($verbose) {
				my $jsonref = decode_json($response->decoded_content);
				print $JSONprinter->encode($jsonref);
			} else {
				print $response->status_line(), "\n";
			} 
	} else {
		die $response->status_line();
	}
}

sub checkver {
	my $url = join('/', $end_point, $codename, "version", "$version?access_token=$atlas_token");
	my $response = $ua->get($url);
	printJSON($response);
}

sub createver {
	my $url = join('/', $end_point, $codename, "versions");
	my	$response = $ua->post($url, 
		[
			'version[version]' => "$version",
			'version[description]' => "$version_log",
			'access_token' => "$atlas_token"
		]
	);
	printJSON($response);
	return $response->is_success;
}

sub delver {
	my $url = join('/', $end_point, $codename, "version", $version);
	
	# Arguments in LWP::UserAgent::delete() are used to create headers not content. 
	# So Use HTTP:Request for that
	my $headers = HTTP::Headers->new('content-type' => 'application/x-www-form-urlencoded');
	my $content = "access_token=$atlas_token";
	my $req = HTTP::Request->new(DELETE => $url, $headers, $content);

	my $response = $ua->request($req);
	printJSON($response);
	return $response->is_success;
}

sub update {
	my $url = join('/', $end_point, $codename, "version", $version);
	my	$response = $ua->put($url, 
		[
			'version[version]' => "$version",
			'version[description]' => "$version_log",
			'access_token' => "$atlas_token"
		]
	);
	printJSON($response);
	return $response->is_success;
}

sub createprovider {
	my $url = join('/', $end_point, $codename, "version", $version, "providers");
	my	$response = $ua->post($url, 
		[ 'provider[name]', "$provider", 'access_token', "$atlas_token"]
	);
	printJSON($response);
	return $response->is_success;
}

sub checkprovider {
	my $url = join('/', $end_point, $codename, "version", $version, "provider", $provider, "?access_token=$atlas_token");
	my $response = $ua->get($url);
	printJSON($response);
	return $response->is_success;
}

sub get_uploadpath {
	my $url = join('/', $end_point, $codename, "version", $version, "provider", $provider, "upload", "?access_token=$atlas_token");
	my $response = $ua->get($url);
	printJSON($response);
	
	my $jsonref = decode_json($response->decoded_content);
	return $jsonref->{'upload_path'};
}

sub uploadbox {
	my ($url) = @_;
	my $curl = "curl -X PUT $url --upload-file $codename.box";
	$OUTPUT_AUTOFLUSH = 1;

    open(CURL,  '-|', $curl) or die "error: $ERRNO";
    while (<CURL>) { say; }
}

sub main {
#	delver() && exit(0);
#	createver();
#	checkver();
#	update();
#	createprovider();
#	checkprovider();
#	get_uploadpath();
#	uploadbox(get_uploadpath());

createver() && createprovider() && uploadbox(get_uploadpath());

}

main();