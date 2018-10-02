package Curry::Site;

use Carp;
use Dancer ':syntax';
use Dancer::Plugin::Ajax;
use JSON qw();
use strict;
use lib::abs qw(
    ../../lib
);
use Curry::DB;

hook 'before' => sub {

    if ($ENV{TOKEN}) {

        my $auth = request->{headers}->{authorization} // '';
        $auth =~ /^TOKEN key="(.*?)"$/;
        my $got_token = $1 // '';

        if ( $ENV{TOKEN} eq $got_token ) {
            # auth is correct
        } else {
            content_type('application/json');

            my $content = JSON::to_json({
                success => JSON::false,
                error_message => 'No access',
            });

            return halt($content);
        }
    }
};

get '/' => sub {
    return '<a href="https://github.com/bessarabov/curry">curry</a>';
};

=head2 /ping
=cut

ajax '/ping' => sub {

    content_type('application/json');

    return JSON::to_json({
        success => JSON::true,
        result => "OK"
    });
};




=head2 /wordfinder
=cut

ajax '/wordfinder' => sub {

    if (not defined param('chars')) {
        return JSON::to_json({
             success => JSON::false,
             error_message => "You must specify 'chars' in querystring",
        });
    }

    content_type('application/json');

    return JSON::to_json({
        success => JSON::true,
        result => {
            dic => getdicvalues(param('chars')),
        },
    });
};

sub getdicvalues {
    my %countexp;
    #my $jumble = 'DGO';
    my $jumble = $_[0];
    my @pieces = sort split //, lc $jumble;

    foreach my $cnt(@pieces) {
        if($countexp {$cnt}){
        $countexp {$cnt}++;
        }else{
        $countexp {$cnt} = 1;
        }
    }

    open FILE, "/curry/lib/Curry/testfile.txt";
    my $n = length $jumble;
    my @possible_words = grep /^[$jumble]{2,$n}$/i, map {chomp; lc $_} <FILE>  ;
    my @uniq = keys %{ {map {$_ => 1} @possible_words} };
    #print @uniq;

    my $count;
    my $counter;
    my @finalarray;

    my $string;
    foreach my $xyz(@uniq) {
    $counter = 0;

        foreach my $x(@pieces) {
        $count = () = $xyz =~ /$x/g;

             if ($count > $countexp {$x}){
            $counter = 1;
            last;
            }
        }

        if ($counter != 1){
        push (@finalarray, $xyz);
        }
    }
    @finalarray = sort(@finalarray);
    my $result = {
        values => \@finalarray,
    };

    return $result;
}

true;