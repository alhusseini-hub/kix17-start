# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# Extensions Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
#
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::SupportDataCollector::Plugin::KIX::SystemID;

use strict;
use warnings;

use base qw(Kernel::System::SupportDataCollector::PluginBase);

use Kernel::Language qw(Translatable);

our @ObjectDependencies = (
    'Kernel::Config',
);

sub GetDisplayPath {
    return Translatable('KIX');
}

sub Run {
    my $Self = shift;

    # Get the configured SystemID
    my $SystemID = $Kernel::OM->Get('Kernel::Config')->Get('SystemID');

    # Does the SystemID contain non-digits?
    if ( $SystemID !~ /^\d+$/ ) {
        $Self->AddResultProblem(
            Label   => Translatable('SystemID'),
            Value   => $SystemID,
            Message => Translatable('Your SystemID setting is invalid, it should only contain digits.'),
        );
    }
    else {
        $Self->AddResultOk(
            Label => Translatable('SystemID'),
            Value => $SystemID,
        );
    }

    return $Self->GetResults();
}

1;
