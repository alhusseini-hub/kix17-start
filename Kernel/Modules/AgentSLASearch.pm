# --
# Copyright (C) 2006-2017 c.a.p.e. IT GmbH, http://www.cape-it.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentSLASearch;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Encode',
    'Kernel::System::Package',
    'Kernel::System::Service',
    'Kernel::System::SLA',
    'Kernel::System::Web::Request'
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    $Self->{LayoutObject}  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    $Self->{EncodeObject}  = $Kernel::OM->Get('Kernel::System::Encode');
    $Self->{PackageObject} = $Kernel::OM->Get('Kernel::System::Package');
    $Self->{ServiceObject} = $Kernel::OM->Get('Kernel::System::Service');
    $Self->{SLAObject}     = $Kernel::OM->Get('Kernel::System::SLA');
    $Self->{ParamObject}   = $Kernel::OM->Get('Kernel::System::Web::Request');

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $JSON = '';

    # get needed params
    my $Search              = $Self->{ParamObject}->GetParam( Param => 'Term' )                || '';
    my $ServiceData         = $Self->{ParamObject}->GetParam( Param => 'ServiceData' )         || '';
    my $CustomerLoginData   = $Self->{ParamObject}->GetParam( Param => 'CustomerLoginData' )   || '';
    my $CustomerCompanyData = $Self->{ParamObject}->GetParam( Param => 'CustomerCompanyData' ) || '';

    # check if KIXServiceCatalog is installed
    my $KIXServCatalogInstalled = 0;
    my @InstalledPackages = $Self->{PackageObject}->RepositoryList();
    for my $Package (@InstalledPackages) {
        if ( $Package->{Name}->{Content} eq 'KIXServiceCatalog' ) {
            $KIXServCatalogInstalled = 1;
        }
    }

    # get all valid SLAs
    my %AllValidSLAs = $Self->{SLAObject}->SLAList(
        Valid  => 1,
        UserID => $Self->{UserID},
    );
    my %SLAs = %AllValidSLAs;

    #-------------------------------------------------------------------------------
    # if ServiceData is given -> get SLAs that are configured for ALL given services
    if ( $ServiceData && $ServiceData ne 'NONE' ) {
        my @Services = split( ';', $ServiceData );
        if (@Services) {
            for my $ServiceID (@Services) {
                my %SLAsForService = $Self->{SLAObject}->SLAList(
                    Valid     => 1,
                    ServiceID => $ServiceID,
                    UserID    => $Self->{UserID},
                );

                # delete SLA from result if it is not configured for one of Services
                for my $SLA ( keys %SLAs ) {
                    delete $SLAs{$SLA} if !$SLAsForService{$SLA};
                }
            }
        }
        else {
            %SLAs = ();
        }
    }

    # if CustomerLoginData is given -> get SLAs that are configured for ALL CustomerUser's Services
    #----------------------------------------------------------------------------------------------
    if ( $CustomerLoginData && $CustomerLoginData ne 'NONE' ) {
        my @CustomerUsers = split( ';', $CustomerLoginData );
        if (@CustomerUsers) {
            for my $CustomerUserLogin (@CustomerUsers) {
                my %SLAsForCustomerUser = ();

                # get Services for CustomerUser
                my %Services = $Self->{ServiceObject}->CustomerUserServiceMemberList(
                    CustomerUserLogin => $CustomerUserLogin,
                    Result            => 'HASH',
                    DefaultServices   => 0,
                );

                # get SLAs for each Service (SLAs for CUstomerUser)
                for my $ServiceID ( keys %Services ) {
                    my %SLAsForService = $Self->{SLAObject}->SLAList(
                        Valid     => 1,
                        ServiceID => $ServiceID,
                        UserID    => $Self->{UserID},
                    );
                    %SLAsForCustomerUser = ( %SLAsForCustomerUser, %SLAsForService );
                }

                # delete SLA from result if it is not configured for one of CustomerUsers
                for my $SLA ( keys %SLAs ) {
                    delete $SLAs{$SLA} if !$SLAsForCustomerUser{$SLA};
                }
            }
        }
        else {
            %SLAs = ();
        }
    }

    # if CustomerCompanyData is given AND KIXServiceCatalog installiert
    # -> get SLAs that are configured for ALL given CustomerIDs
    #------------------------------------------------------------------
    elsif ( $CustomerCompanyData && $CustomerCompanyData ne 'NONE' && $KIXServCatalogInstalled ) {
        my @CustomerUsers = ();
        my @CustomerCompanyList = split( ';', $CustomerCompanyData );
        if (@CustomerCompanyList) {
            for my $CustomerCompany (@CustomerCompanyList) {

                # get CustomerServiceSLA entries that have this CustomerID
                my @CustomerServiceSLAs = $Self->{ServiceObject}->CustomerServiceMemberSearch(
                    CustomerID => $CustomerCompany,
                    Result     => 'HASH',
                );

                # get SLAs for this CustomerCompany (CustomerID)
                my %SLAsForCustomerCompany = ();
                for my $CatalogEntry (@CustomerServiceSLAs) {
                    next if ( ref($CatalogEntry) ne 'HASH' );
                    if ( $CatalogEntry->{SLAID} ) {
                        $SLAsForCustomerCompany{ $CatalogEntry->{SLAID} } = 1,
                    }
                }

                # delete SLA from result if it is not configured for one of CustomerIDs
                for my $SLA ( keys %SLAs ) {
                    delete $SLAs{$SLA} if !$SLAsForCustomerCompany{$SLA};
                }
            }
        }
        else {
            %SLAs = ();
        }
    }

    # get SLAs for DEFAULT-Services
    my %SLAsForDefaultServices = ();
    if ( !$KIXServCatalogInstalled ) {
        my %DefaultServices = $Self->{ServiceObject}->CustomerUserServiceMemberList(
            CustomerUserLogin => '<DEFAULT>',
            Result            => 'HASH',
            DefaultServices   => 0,
        );
        for my $ServiceID ( keys %DefaultServices ) {
            my %SLAsForService = $Self->{SLAObject}->SLAList(
                Valid     => 1,
                ServiceID => $ServiceID,
                UserID    => $Self->{UserID},
            );
            %SLAsForDefaultServices = ( %SLAsForDefaultServices, %SLAsForService );
        }
    }
    else {
        my @CustomerServiceSLAs = $Self->{ServiceObject}->CustomerServiceMemberSearch(
            CustomerID => 'DEFAULT',
            Result     => 'HASH',
        );
        for my $CatalogEntry (@CustomerServiceSLAs) {
            next if ( ref($CatalogEntry) ne 'HASH' );
            if ( $CatalogEntry->{SLAID} ) {
                $SLAsForDefaultServices{ $CatalogEntry->{SLAID} }
                    = $AllValidSLAs{ $CatalogEntry->{SLAID} },
            }
        }
    }
    %SLAs = ( %SLAs, %SLAsForDefaultServices );



    $Search =~ s/\_/\./g;
    $Search =~ s/\%/\.\*/g;
    $Search =~ s/\*/\.\*/g;

    # build data
    my @Data;
    for my $SLAID ( keys %SLAs ) {
        if ( $SLAs{$SLAID} =~ /$Search/i ) {
            push @Data, {
                SLAKey   => $SLAID,
                SLAValue => $SLAs{$SLAID},
            };
        }
    }

    # build JSON output
    $JSON = $Self->{LayoutObject}->JSONEncode(
        Data => \@Data,
    );

    # send JSON response
    return $Self->{LayoutObject}->Attachment(
        ContentType => 'application/json; charset=' . $Self->{LayoutObject}->{Charset},
        Content     => $JSON || '',
        Type        => 'inline',
        NoCache     => 1,
    );
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the KIX project
(L<http://www.kixdesk.com/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see the enclosed file
COPYING for license information (AGPL). If you did not receive this file, see

<http://www.gnu.org/licenses/agpl.txt>.

=cut
