package Acme::Incorporated;

use strict;
use IO::File;
use File::Spec;

use vars '$VERSION';
$VERSION = '0.10';

sub import
{
	unshift @INC, \&fine_products;
}

sub fine_products
{
	my ($code, $module) = @_;
	(my $modfile = $module . '.pm') =~ s{::}{/}g;
	my $fh = bad_product()->( $module, $modfile );
	return unless $fh;

	$INC{$modfile} = 1;
	$fh->seek( 0, 0 );
	return $fh;
}

sub empty_box
{
	my ($module, $modpath) = @_;

	return fake_module_fh(<<END_MODULE);
package $module;

sub AUTOLOAD
{
	return 1;
}

1;
END_MODULE

}

sub breaks_when_needed
{
	my ($module, $modfile) = @_;

	my $file;
	local   @INC = @INC;
	unshift @INC;
	for my $path (@INC)
	{
		local @ARGV = File::Spec->catfile( $path, $modfile );
		next unless -e $ARGV[0];

		$file = do { local $/; <> } or return;
	}

	$file =~ s/(while\s*\()/$1 Acme::Incorporated::breaks() && /g;
	$file =~ s[(for[^;]+{)(\s*)]
		      [$1$2last unless Acme::Incorporated::breaks();$2]xsg;
	return unless $file;
	return fake_module_fh( $file );
}

sub out_of_stock
{
	my ($module, $modfile) = @_;
	return fake_module_fh(<<END_MODULE);
print "$module is out of stock at the moment.\n"
delete \$INC{$modfile};
END_MODULE

}

sub fake_module_fh
{
	my $text = shift;

	my $fh = IO::File->new_tmpfile() or return;
	$fh->print( $text );

	$fh->seek( 0, 0 );
	return $fh;
}

sub bad_product
{
	my $weight = rand();
	return \&empty_box          if $weight <= 0.10;
	return \&breaks_when_needed if $weight <= 0.20;
	return \&out_of_stock       if $weight <= 0.30;
	return sub {};
}

sub breaks
{
	return rand() <= 0.10;
}

1;
__END__

=head1 NAME

Acme, Inc. produces fine and wonderful products for your pleasure. 

=head1 SYNOPSIS

  use Acme::Incorporated;

  # your code as normal

=head1 DESCRIPTION

Acme, Inc. produces fine and wonderful products for your pleasure.  We have a
huge catalog of products for your enjoyment, including many CPAN modules.
Remember to go to Acme, Inc. first.

=head1 USAGE

Just use Acme::Incorporated before any other Perl module and we'll rush our
version right to you at the right price and at the right time.

*WARNING* Supplies are limited.  Please act fast.  Some modules may be
unavailable.

=head1 BUGS

As you'd expect.

=head1 SUPPORT

We're so sure you'll be pleased that we offer a satisfaction-guaranteed
money-back guarantee.  (Some restrictions apply.)

=head1 AUTHOR

	chromatic
	chromatic@wgz.org
	http://wgz.org/chromatic/

You should also blame people like Mark Fowler, Leon Brocard, James Duncan, and
Adam Turoff who were there at the time and did nothing to dissuade me.

=head1 COPYRIGHT

Copyright (c) 2003, chromatic.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included with
this module.

=head1 SEE ALSO

perl(1).
