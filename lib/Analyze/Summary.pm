package Analyze::Summary;

sub new {
    my $type  = shift;
    my $class = ref $type || $type;
    my $self  = bless { @_ }, $class;

    $self->init;
}

sub init {
    my $s = shift;
    my $d = $s->{data};
    my $o = $s->{opt};

    my $times        = $d->{times};
    $s->{test_names} = [ map { $_->{name} } @$times ];

    my $groups       = $d->{config}{groups};
    my $compilers    = $d->{config}{compilers};

    my @compilers    = $s->enabled_compilers($groups,  $compilers);
    my @run_names    = map { $_->{run} || '' } @compilers;
    my @lang_names   = map { $_->{language} }  @compilers;
    my @comp_names   = map { $_->{compiler} }  @compilers;
    my @vm_names     = map { $_->{vm}       }  @compilers;

    $s->{compilers}  = \@compilers;
    $s->{run_names}  = \@run_names;
    $s->{lang_names} = \@lang_names;
    $s->{comp_names} = \@comp_names;
    $s->{vm_names}   = \@vm_names;

    my   @ignoring;
    push @ignoring, 'startup time' if $o->{'ignore-startup'};
    push @ignoring, 'compile time' if $o->{'ignore-compile'};
    $s->{ignoring}   = \@ignoring;

    return $s;
}

sub enabled_compilers {
    my ($self, $groups, $compilers) = @_;

    my %by_group;
    for my $comp (@$compilers) {
        push @{$by_group{$comp->{group}} ||= []}, $comp
            if $comp->{enabled};
    }

    return
      sort { ($a->{key} || $a->{name}) cmp ($b->{key} || $b->{name}) }
      map { @{$by_group{$_} || []} }
      @$groups;
}


package Analyze::Summary::Compare;
our @ISA = qw( Analyze::Summary );

use List::MoreUtils 'uniq';


sub init {
    my $s = shift->SUPER::init;
    my $d = $s->{data};
    my $o = $s->{opt};

    my %lang_count;
       $lang_count{$_}++ for @{$s->{lang_names}};
    my @langs        =  uniq @{$s->{lang_names}};
    $s->{lang_count} = \%lang_count;
    $s->{langs}      = \@langs;

    my   @showing = ('PEAK RATE (/s)');
    push @showing, 'TIMES SLOWER THAN FASTEST (x)' if $o->{compare};
    if ($d->{score}) {
        my $skip = $o->{'skip-incomplete'} ? ' (skipping incomplete data)' : '';
        push @showing, "SUMMARY SCORES$skip";
    }
    $s->{showing} = \@showing;

    return $s;
}
