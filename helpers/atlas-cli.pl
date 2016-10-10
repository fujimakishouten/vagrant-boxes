#!/usr/bin/perl
# uploads a vagrant base to atlas

# all necessaries perl modules should already be present in a standard debian installation
# except libjson-perl which should be installed manually

use feature 'say';
use strict;
use warnings;
use English;

use JSON;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use Cwd;
use Getopt::Long;
use File::Basename;

use Data::Dumper;

# see https://vagrantcloud.com/docs/versions
# put an atlas token in your env like this
# export ATLAS_TOKEN=$(gpg --decrypt ../helpers/token.gpg)
#

#script defaults
my $atlas_token = $ENV{'ATLAS_TOKEN'} or die "please export ATLAS_TOKEN as environment variable\n";
my $builder_dir = getcwd;
my $end_point   = 'https://atlas.hashicorp.com/api/v1/box/debian';
my $ua          = LWP::UserAgent->new();
my $JSONprinter = JSON->new()->canonical->pretty;
my $verbose     = 1;

#exit codes from sysexits.h
use constant EXIT_OK => 0;
use constant EXIT_USAGE => 64;


# defaults for command line switches
my $box = '';
my $version = '';
my $changelog = '';
my $provider = 'virtualbox';
my $need_help = '';
my $debug = '';

sub main {

	my $parsing_success = GetOptions('box=s' => \$box,
			'version=s' => \$version,
			'changelog=s' => \$changelog,
			'provider=s' => \$provider,
			'debug' => \$debug,
			'help' => \$need_help,
	);

	print_help(EXIT_USAGE) if (! $parsing_success);
	print_help(EXIT_OK) if $need_help;

	$box or die ("please provide a path to a box with --box\n");
	-e $box or die("box $box not found\n");
	my ($codename) = split /\.box/, $box;
	my $cloudname  = join('', $codename, '64');

	if (! $version || ! $changelog) {
		my $manifest   = join( '', $builder_dir, '/', $codename, '.json');
		-f $manifest or die("uname to open a manifest $manifest for $box, use command line switches\n");
		$version    = json_fileread('box_version', $manifest);
		$changelog  = json_fileread('box_changelog', $manifest);
	}

	if (! is_version_existing($cloudname, $version)) {
		createver($cloudname, $version, $changelog) or die("unable to create version $version for $codename\n");
	}

	if (! is_provider_existing($cloudname, $version, $provider)) {
		createprovider($cloudname, $version, $provider) or die("unable to create $cloudname, $version, $provider\n");
	}

	uploadbox(get_uploadpath($cloudname, $version, $provider), $box);
}

main();

sub print_help {
		my ($exit_code) = @_;
		my $help = basename($0) . "\n";
		$help .= "\t--box  path to box to upload (defaults to $box)\n";
		$help .= "\t--version version string\n";
		$help .= "\t--changelog changelog string in Markdown format (defaults to \"$changelog\")\n";
		$help .= "\t--provider virtualization provider (default to $provider)\n";
		$help .= "\t--debug print internal perl data structures \n";
		$help .= "\t--help display this text \n";
		$help .= <<EOD;

example1: uploading a lxc box to the debian/sandox64 namespace
namespace is computed as debian/\$box_filename64

atlas-cli.pl \\
 --box sandbox.box \\
 --version 10.1  \\
 --changelog "* uploading to debian/sandbox64" \\
 --provider lxc

example2: uploading a virtualbox box to the debian/jessie64 namespace
version and changelog are infered from the presence of \$box_filename.json file,
provider is not set and defaults to virtualbox

atlas-cli.pl --box jessie.box

EOD
		print $help;
		exit($exit_code);
}

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
    my $value = undef; 
	$value = $manifest->{'variables'}->{$key}
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
	my $url = join('/',	$end_point,	$cloudname,	"version", "$version?access_token=$atlas_token");

	my $response = $ua->get($url);
	return $response->is_success();
}

sub createver {
	my ($cloudname, $version, $changelog) = @_;

	my $url = join('/', $end_point,	$cloudname,	"versions");

	my $response = $ua->post(
		$url,
		[
			'version[version]'     => "$version",
			'version[description]' => "$changelog",
			'access_token'         => "$atlas_token"
		]
	);

	printJSON($response);
	return $response->is_success();
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
	return $response->is_success();
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
	return $response->is_success();
}

sub createprovider {
	my ($cloudname, $version, $provider) = @_;
	my $url =
	  join('/', $end_point, $cloudname, "version", $version, "providers");
	my $response =
	  $ua->post($url,
		[ 'provider[name]', "$provider", 'access_token', "$atlas_token" ]);
	printJSON($response);
	return $response->is_success();
}

sub is_provider_existing {
	my ($cloudname, $version, $provider) = @_;
	my $url = join('/',
		$end_point, $cloudname, "version", $version, "provider", $provider,
		"?access_token=$atlas_token");
	my $response = $ua->get($url);
	return $response->is_success();
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
	$curl .= " --verbose" if $debug;
	$OUTPUT_AUTOFLUSH = 1;

	open my $curl_output, '-|', $curl or die "error: $ERRNO";
	while (<$curl_output>) { say; }
	close $curl_output;
}
