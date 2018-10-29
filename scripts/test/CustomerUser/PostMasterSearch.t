# --
# Modified version of the work: Copyright (C) 2006-2018 c.a.p.e. IT GmbH, https://www.cape-it.de
# based on the original work of:
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file LICENSE for license information (AGPL). If you
# did not receive this file, see https://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

# get needed objects
my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

# get helper object
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

my $CustomerUser = 'customer' . $Helper->GetRandomID();

# add two users
$ConfigObject->Set(
    Key   => 'CheckEmailAddresses',
    Value => 0,
);

my $CustomerUserID = $CustomerUserObject->CustomerUserAdd(
    Source         => 'CustomerUser',
    UserFirstname  => 'Firstname Test',
    UserLastname   => 'Lastname Test',
    UserCustomerID => $CustomerUser . '-Customer-Id',
    UserLogin      => $CustomerUser,
    UserEmail      => "john.doe.$CustomerUser\@example.com",
    UserPassword   => 'some_pass',
    ValidID        => 1,
    UserID         => 1,
);

$Self->True(
    $CustomerUserID,
    "CustomerUserAdd() - $CustomerUserID",
);

my @Tests = (
    {
        Name             => "Exact match",
        PostMasterSearch => "john.doe.$CustomerUser\@example.com",
        ResultCount      => 1,
    },
    {
        Name             => "Exact match with different casing",
        PostMasterSearch => "John.Doe.$CustomerUser\@example.com",
        ResultCount      => 1,
    },
    {
        Name             => "Partial string",
        PostMasterSearch => "doe.$CustomerUser\@example.com",
        ResultCount      => 0,
    },
    {
        Name             => "Partial string with different casing",
        PostMasterSearch => "Doe.$CustomerUser\@example.com",
        ResultCount      => 0,
    },
);

for my $Test (@Tests) {
    my %Result = $CustomerUserObject->CustomerSearch(
        PostMasterSearch => $Test->{PostMasterSearch},
    );

    $Self->Is(
        scalar keys %Result,
        $Test->{ResultCount},
        $Test->{Name},
    );
}

# cleanup is done by RestoreDatabase

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the KIX project
(L<https://www.kixdesk.com/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see the enclosed file
LICENSE for license information (AGPL). If you did not receive this file, see

<https://www.gnu.org/licenses/agpl.txt>.

=cut
