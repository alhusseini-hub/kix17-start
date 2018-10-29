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

# get helper object
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

# get customer user object
my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

# add two users
$Kernel::OM->Get('Kernel::Config')->Set(
    Key   => 'CheckEmailAddresses',
    Value => 0,
);

my $RandomID = $Helper->GetRandomID();

my @CustomerLogins;
for my $Key ( 1 .. 2 ) {

    my $UserRand = 'Duplicate' . $Key . $RandomID;

    my $UserID = $CustomerUserObject->CustomerUserAdd(
        Source         => 'CustomerUser',
        UserFirstname  => 'Firstname Test' . $Key,
        UserLastname   => 'Lastname Test' . $Key,
        UserCustomerID => $UserRand . '-Customer-Id',
        UserLogin      => $UserRand,
        UserEmail      => $UserRand . '-Email@example.com',
        UserPassword   => 'some_pass',
        ValidID        => 1,
        UserID         => 1,
    );

    push @CustomerLogins, $UserID;

    $Self->True(
        $UserID,
        "CustomerUserAdd() - $UserID",
    );

    my $Update = $CustomerUserObject->CustomerUserUpdate(
        Source         => 'CustomerUser',
        ID             => $UserRand,
        UserFirstname  => 'Firstname Test Update' . $Key,
        UserLastname   => 'Lastname Test Update' . $Key,
        UserCustomerID => $UserRand . '-Customer-Update-Id',
        UserLogin      => $UserRand,
        UserEmail      => $UserRand . '-Update@example.com',
        ValidID        => 1,
        UserID         => 1,
    );

    $Self->True(
        $Update,
        "CustomerUserUpdate$Key() - $UserID",
    );
}

my %CustomerData = $CustomerUserObject->CustomerUserDataGet(
    User => $CustomerLogins[0],
);

my $Customer1Email = $CustomerData{UserEmail};

# create a new customer with email address of customer 1
my $UserID = $CustomerUserObject->CustomerUserAdd(
    Source         => 'CustomerUser',
    UserFirstname  => "Firstname Add $RandomID",
    UserLastname   => "Lastname Add $RandomID",
    UserCustomerID => "CustomerID Add $RandomID",
    UserLogin      => "UserLogin Add $RandomID",
    UserEmail      => $Customer1Email,
    UserPassword   => 'some_pass',
    ValidID        => 1,
    UserID         => 1,
);

$Self->False(
    $UserID,
    "CustomerUserAdd() - not possible for duplicate email address",
);

%CustomerData = $CustomerUserObject->CustomerUserDataGet(
    User => $CustomerLogins[1],
);

# update user 1 with email address of customer 2
my $Update = $CustomerUserObject->CustomerUserUpdate(
    %CustomerData,
    Source    => 'CustomerUser',
    ID        => $CustomerData{UserLogin},
    UserEmail => $Customer1Email,
    UserID    => 1,
);

$Self->False(
    $Update,
    "CustomerUserUpdate() - not possible for duplicate email address",
);

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
