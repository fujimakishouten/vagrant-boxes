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
my $end_point   = 'https://atlas.hashicorp.com/api/v1/box/debian';
my $ua          = LWP::UserAgent->new();
my $JSONprinter = JSON->new()->canonical->pretty;
my $verbose     = 1;
my $debug       = 0;

sub main {
	my $box = $ARGV[0] // 'testing.box';
	my ($codename) = split /\.box/, $box;
	my $cloudname  = join( '', $codename, '64');

	my $manifest   = join( '', $builder_dir, '/', $codename, '.json');
	my $version    = json_fileread( 'box_version',   $manifest);
	my $changelog  = json_fileread( 'box_changelog', $manifest);
	my $provider   = 'virtualbox';

#	delver($cloudname, $version);

	createver($cloudname, $version, $changelog )
	  unless is_version_existing($cloudname, $version);

	createprovider($cloudname, $version, $provider )
	  unless is_provider_existing($cloudname, $version, $provider);

	uploadbox(get_uploadpath($cloudname, $version, $provider ), $box);

}

main();

sub json_fileread {
	my ($key, $template) = @_;
	my $json;

	{
		local $INPUT_RECORD_SEPARATOR = undef;
		open my $fh, "<", $template or die "could not find $template";
		$json = <$fh>;
		close $fh;
	}

	my $manifest = decode_json($json);
	my $value = $manifest->{'variables'}->{$key}
	  if $manifest->{'variables'}->{$key};
	defined($value) && return $value or die "unable to find $key in $template";
}

sub printJSON {
	my ($response) = @_;
	if ($debug) {
		print $response->status_line(), "\n";
		print Dumper($response);
		return;
	}

	if ($response->is_success && $verbose ) {
		my $jsonref = decode_json($response->decoded_content);
		print $JSONprinter->encode($jsonref);
	}
	else {
		print $response->status_line(), "\n";
	}
}

sub is_version_existing {
	my ($cloudname, $version) = @_;
	my $url = join('/',
		$end_point, $cloudname, "version",
		"$version?access_token=$atlas_token");
	my $response = $ua->get($url);
	return $response->is_success();
}

sub createver {
	my ($cloudname, $version, $changelog) = @_;
	my $url = join('/', $end_point, $cloudname, "versions");
	my $response = $ua->post(
		$url,
		[
			'version[version]'     => "$version",
			'version[description]' => "$changelog",
			'access_token'         => "$atlas_token"
		]
	);
	printJSON($response);
	return $response->is_success;
}

sub delver {
	my ($cloudname, $version) = @_;
	my $url = join('/', $end_point, $cloudname, "version", $version);

 # Arguments in LWP::UserAgent::delete() are used to create headers not content.
 # So Use HTTP:Request for that
	my $headers = HTTP::Headers->new(
		'content-type' => 'application/x-www-form-urlencoded');
	my $content = "access_token=$atlas_token";
	my $req = HTTP::Request->new(DELETE => $url, $headers, $content);

	my $response = $ua->request($req);
	printJSON($response);
	return $response->is_success;
}

sub update {
	my ($cloudname, $version, $changelog) = @_;
	my $url = join('/', $end_point, $cloudname, "version", $version);
	my $response = $ua->put(
		$url,
		[
			'version[version]'     => "$version",
			'version[description]' => "$changelog",
			'access_token'         => "$atlas_token"
		]
	);
	printJSON($response);
	return $response->is_success;
}

sub createprovider {
	my ($cloudname, $version, $provider) = @_;
	my $url =
	  join('/', $end_point, $cloudname, "version", $version, "providers");
	my $response =
	  $ua->post($url,
		[ 'provider[name]', "$provider", 'access_token', "$atlas_token" ]);
	printJSON($response);
	return $response->is_success;
}

sub is_provider_existing {
	my ($cloudname, $version, $provider) = @_;
	my $url = join('/',
		$end_point, $cloudname, "version", $version, "provider", $provider,
		"?access_token=$atlas_token");
	my $response = $ua->get($url);
	return $response->is_success;
}

sub get_uploadpath {
	my ($cloudname, $version, $provider) = @_;
	my $url = join('/',
		$end_point, $cloudname, "version", $version, "provider", $provider,
		"upload", "?access_token=$atlas_token");
	my $response = $ua->get($url);
	printJSON($response);

	my $jsonref = decode_json($response->decoded_content);
	return $jsonref->{'upload_path'};
}

sub uploadbox {
	my ($url, $box) = @_;
	my $curl = "curl -X PUT $url --upload-file $box";
	$OUTPUT_AUTOFLUSH = 1;

	open CURL, '-|', $curl or die "error: $ERRNO";
	while (<CURL>) { say; }
}
