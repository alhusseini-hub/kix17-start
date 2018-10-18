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

# get selenium object
my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');

$Selenium->RunTest(
    sub {

        # get helper object
        my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

        # enable ticket responsible and watch feature
        for my $SysConfigResWatch (qw( Responsible Watcher )) {
            $Helper->ConfigSettingChange(
                Valid => 1,
                Key   => "Ticket::$SysConfigResWatch",
                Value => 1
            );
        }

        # get menu config params
        my @TicketMenu = (
            {
                SysConfigItem => {
                    Active      => "AgentTicketMove",
                    Description => "Delete this ticket",
                    Link        => "Action=AgentTicketMove;TicketID=[% Data.TicketID %];DestQueue=Delete",
                    Module      => "Kernel::Output::HTML::TicketMenu::Generic",
                    Name        => "Delete",
                    PopupType   => "",
                    Target      => "",
                },
                Key => "Ticket::Frontend::MenuModule###460-Delete",
            },
            {
                SysConfigItem => {
                    Active      => "AgentTicketMove",
                    Description => "Mark this ticket as junk!",
                    Link        => "Action=AgentTicketMove;TicketID=[% Data.TicketID %];DestQueue=Junk",
                    Module      => "Kernel::Output::HTML::TicketMenu::Generic",
                    Name        => "Spam",
                    PopupType   => "",
                    Target      => "",
                },
                Key => "Ticket::Frontend::MenuModule###470-Junk",
            },
            {
                SysConfigItem => {
                    Active      => "AgentTicketMove",
                    Description => "Delete this ticket",
                    Link        => "Action=AgentTicketMove;TicketID=[% Data.TicketID %];DestQueue=Delete",
                    Module      => "Kernel::Output::HTML::TicketMenu::Generic",
                    Name        => "Delete",
                    PopupType   => "",
                    Target      => "",
                },
                Key => "Ticket::Frontend::PreMenuModule###450-Delete",
            },
            {
                SysConfigItem => {
                    Active      => "AgentTicketMove",
                    Description => "Mark as Spam!",
                    Link        => "Action=AgentTicketMove;TicketID=[% Data.TicketID %];DestQueue=Junk",
                    Module      => "Kernel::Output::HTML::TicketMenu::Generic",
                    Name        => "Spam",
                    PopupType   => "",
                    Target      => "",
                },
                Key => "Ticket::Frontend::PreMenuModule###460-Spam",
            },
        );

        # enable delete and spam menu in sysconfig
        for my $SysConfigItem (@TicketMenu) {
            $Helper->ConfigSettingChange(
                Key   => $SysConfigItem->{Key},
                Value => $SysConfigItem->{SysConfigItem},
            );
            $Helper->ConfigSettingChange(
                Valid => 1,
                Key   => $SysConfigItem->{Key},
                Value => $SysConfigItem->{SysConfigItem},
            );
        }

        # create test user and login
        my $TestUserLogin = $Helper->TestUserCreate(
            Groups => [ 'admin', 'users' ],
        ) || die "Did not get test user";

        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        # get test user ID
        my $TestUserID = $Kernel::OM->Get('Kernel::System::User')->UserLookup(
            UserLogin => $TestUserLogin,
        );

        # get ticket object
        my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

        # create test ticket
        my $TicketID = $TicketObject->TicketCreate(
            Title        => 'Some Ticket Title',
            Queue        => 'Raw',
            Lock         => 'unlock',
            Priority     => '3 normal',
            State        => 'new',
            CustomerID   => 'TestCustomer',
            CustomerUser => 'customer@example.com',
            OwnerID      => $TestUserID,
            UserID       => $TestUserID,
        );

        $Self->True(
            $TicketID,
            "TicketID $TicketID - created"
        );

        my $ScriptAlias = $Kernel::OM->Get('Kernel::Config')->Get('ScriptAlias');

        # go to raw queue view with focus on created test ticket
        $Selenium->VerifiedGet(
            "${ScriptAlias}index.pl?Action=AgentTicketQueue;Filter=Unlocked;OrderBy=Down;QueueID=2;SortBy=Age;View=Preview;"
        );

        # create pre menu module test params
        my @PreMenuModule = (
            {
                Name   => "Lock",
                Action => "AgentTicket"
            },
            {
                Name   => "Zoom",
                Action => "AgentTicketZoom",
            },
            {
                Name   => "History",
                Action => "AgentTicketHistory",
            },
            {
                Name   => "Priority",
                Action => "AgentTicketPriority",
            },
            {
                Name   => "Note",
                Action => "AgentTicketNote",
            },
            {
                Name   => "Move",
                Action => "AgentTicketMove",
            },
            {
                Name   => "Delete",
                Action => "AgentTicketMove;TicketID=$TicketID;DestQueue=Delete",
            },
            {
                Name   => "Spam",
                Action => "AgentTicketMove;TicketID=$TicketID;DestQueue=Junk",
            },
        );

        # check ticket pre menu modules
        for my $MenuModulePre (@PreMenuModule) {

            my $NameForID;
            if ( $MenuModulePre->{Name} eq 'Move' ) {
                $NameForID = 'DestQueueID';
            }
            else {
                $NameForID = $MenuModulePre->{Name};
                $NameForID =~ s/ /-/g if ( $NameForID =~ m/ / );
            }

            # check pre menu module link
            $Self->True(
                $Selenium->find_element("//a[contains(\@href, \'Action=$MenuModulePre->{Action}' )]"),
                "Ticket pre menu $MenuModulePre->{Name} is found"
            );

            # check pre menu module name
            $Self->True(
                $Selenium->find_element( "#$NameForID$TicketID", 'css' ),
                "Ticket menu name $MenuModulePre->{Name} is found"
            );
        }

        # go to test created ticket zoom
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentTicketZoom;TicketID=$TicketID");

        # create menu module test params
        my @MenuModule = (
            {
                Name   => "Back",
                Action => "AgentDashboard",
            },
            {
                Name   => "Lock",
                Action => "AgentTicket"
            },
            {
                Name   => "History",
                Action => "AgentTicketHistory",
            },
            {
                Name   => "Print",
                Action => "AgentTicketPrint",
            },
            {
                Name   => "Priority",
                Action => "AgentTicketPriority",
            },
            {
                Name   => "Free Fields",
                Action => "AgentTicketFreeText",
            },
            {
                Name   => "Link",
                Action => "AgentLinkObject",
            },
            {
                Name   => "Owner",
                Action => "AgentTicketOwner",
            },
            {
                Name   => "Responsible",
                Action => "AgentTicketResponsible",
            },
            {
                Name   => "Customer",
                Action => "AgentTicketCustomer",
            },
            {
                Name   => "Note",
                Action => "AgentTicketNote",
            },
            {
                Name   => "Phone Call Outbound",
                Action => "AgentTicketPhoneOutbound",
            },
            {
                Name   => "Phone Call Inbound",
                Action => "AgentTicketPhoneInbound",
            },
            {
                Name   => "E-Mail Outbound",
                Action => "AgentTicketEmailOutbound",
            },
            {
                Name   => "Merge",
                Action => "AgentTicketMerge",
            },
            {
                Name   => "Pending",
                Action => "AgentTicketPending",
            },
            {
                Name   => "Watch",
                Action => "AgentTicketWatcher",
            },
            {
                Name   => "Close",
                Action => "AgentTicketClose",
            },
            {
                Name   => "Delete",
                Action => "AgentTicketMove;TicketID=$TicketID;DestQueue=Delete",
            },
            {
                Name   => "Spam",
                Action => "AgentTicketMove;TicketID=$TicketID;DestQueue=Junk",
            },
            {
                Name => "People",
                Type => "Cluster",
            },
            {
                Name => "Communication",
                Type => "Cluster",
            },
            {
                Name => "Miscellaneous",
                Type => "Cluster",
            },
        );

        # check ticket menu modules
        for my $ZoomMenuModule (@MenuModule) {

            my $NameForID = $ZoomMenuModule->{Name};
            $NameForID =~ s/ /-/g if ( $NameForID =~ m/ / );

            if ( defined $ZoomMenuModule->{Type} && $ZoomMenuModule->{Type} eq 'Cluster' ) {

                # check menu module link
                $Self->True(
                    $Selenium->find_element( "li ul#nav-$NameForID-container", 'css' ),
                    "Ticket menu link $ZoomMenuModule->{Name} is found"
                );
            }
            else {

                # check menu module link
                $Self->True(
                    $Selenium->find_element("//a[contains(\@href, \'Action=$ZoomMenuModule->{Action}' )]"),
                    "Ticket menu link $ZoomMenuModule->{Name} is found"
                );
            }

            # check menu module name
            $Self->True(
                $Selenium->find_element( "li#nav-$NameForID", 'css' ),
                "Ticket menu name $ZoomMenuModule->{Name} is found"
            );
        }

        # delete created test tickets
        my $Success = $TicketObject->TicketDelete(
            TicketID => $TicketID,
            UserID   => $TestUserID,
        );
        $Self->True(
            $Success,
            "Delete ticket - $TicketID"
        );

        # make sure the cache is correct.
        $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
            Type => 'Ticket',
        );
    }
);

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the KIX project
(L<https://www.kixdesk.com/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see the enclosed file
LICENSE for license information (AGPL). If you did not receive this file, see

<https://www.gnu.org/licenses/agpl.txt>.

=cut
