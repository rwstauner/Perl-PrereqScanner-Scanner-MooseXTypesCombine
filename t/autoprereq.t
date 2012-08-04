#!perl
use strict;
use warnings;

use File::Temp qw{ tempfile };
use Perl::PrereqScanner;
use PPI::Document;
use Try::Tiny;

use Test::More;

sub prereq_is {
  my ($str, $want, $comment) = @_;
  $comment ||= $str;

  my $scanner = Perl::PrereqScanner->new( extra_scanners => ['MooseXTypesCombine'] );

  # scan_ppi_document
  try {
    my $result  = $scanner->scan_ppi_document( PPI::Document->new(\$str) );
    is_deeply($result->as_string_hash, $want, $comment);
  } catch {
    fail("scanner died on: $comment");
    diag($_);
  };

  # scan_string
  try {
    my $result  = $scanner->scan_string( $str );
    is_deeply($result->as_string_hash, $want, $comment);
  } catch {
    fail("scanner died on: $comment");
    diag($_);
  };

  # scan_file
  try {
    my ($fh, $filename) = tempfile( UNLINK => 1 );
    print $fh $str;
    close $fh;
    my $result  = $scanner->scan_file( $filename );
    is_deeply($result->as_string_hash, $want, $comment);
  } catch {
    fail("scanner died on: $comment");
    diag($_);
  };
}

done_testing;