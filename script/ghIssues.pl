#!/usr/bin/env perl
# Get the GH issues for DDG repos
#
#
use FindBin;
use lib $FindBin::Dir . "/../lib";
use JSON;
use DDGC;
use Data::Dumper;
use Try::Tiny;
my $d = DDGC->new;

# JSON response from GH API
my %json;

# results to go into DB
# |IA name|Repo|Issue#|title|Body|tags|created at|
my @results;

# the repos we care about
my @repos = (
    'zeroclickinfo-spice',
	'zeroclickinfo-goodies',
    'zeroclickinfo-longtail',
    'zeroclickinfo-fathead'
);

# get the GH issues
sub getIssues{
	foreach my $repo (@repos){
		$json->{$repo} = decode_json(`curl --silent https://api.github.com/repos/duckduckgo/$repo/issues?status=current`);

		next unless ref $json->{$repo} eq 'ARRAY';

		# add all the data we care about to an array
		for my $issue ( @{$json->{$repo}} ){

            # get the IA name from the link in the first comment
			# Update this later for whatever format we decide on
			my $link = '';
            if($issue->{'body'} =~ /(http(s)?:\/\/(duck\.co|duckduckgo.com))?\/ia\/(view)?\/(\w+)/im){
				$link = $5;
			}
			# remove special chars from title and body
			$issue->{'body'} =~ s/\'//g;
			$issue->{'title'} =~ s/\'//g;

			# get repo name
			$repo =~ s/zeroclickinfo-//;

			# add entry to result array
			my @entry = (
				$link || '',
				$repo || '',
				$issue->{'number'} || '',
				$issue->{'title'} || '',
				$issue->{'body'} || '',
				encode_json($issue->{'labels'}) || '',
				$issue->{'created_at'} || ''
			);
			push(@results, \@entry);
		}
	}
}

my $update = sub {

    $d->rs('InstantAnswer::Issues')->delete_all();

    foreach (@results){
        my ($id, $repo, $issue, $title, $body, $tags) = @$_;

        # check if the IA is in our table so we dont die on a foreign key error
        $ia = $d->rs('InstantAnswer')->find($id);

        if($id && $issue  && $ia){
            $d->rs('InstantAnswer::Issues')->create(
            {
                instant_answer_id => $id,
                repo => $repo,
                issue_id => $issue,
                title => $title,
                body => $body,
                tags => $tags,
	        });

        }
    }
};

getIssues;

try {
    $d->db->txn_do($update);
} catch {
    print "Update error $_ \n rolling back\n";
    $d->errorlog("Error updating ghIssues: '$_'...");
}
