# --
# Kernel/Output/HTML/KIXSidebarTicketLinkCI.pm
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Stefan(dot)Mehlig(at)cape(dash)it(dot)de
# * Mario(dot)Illinger(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::KIXSidebar::TicketLinkCI;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout'
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{LayoutObject} = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $AdditionalClasses = '';
    if (   $Param{Config}->{'InitialCollapsed'}
        && $Param{Action} =~ /$Param{Config}->{'InitialCollapsed'}/ )
    {
        $AdditionalClasses .= 'Collapsed';
    }

    $Self->{LayoutObject}->Block(
        Name => 'SidebarFrame',
        Data => {
            %{$Param{Ticket} || {}},
            %{$Param{Config}},
            AdditionalClasses => $AdditionalClasses,
        },
    );

    # output result
    my $Content = $Self->{LayoutObject}->Output(
        TemplateFile   => 'KIXSidebar/TicketLinkCISearch',
        Data           => {
            %{$Param{Ticket} || {}},
            %{$Param{Config}},
        },
        KeepScriptTags => $Param{AJAX},
    );

    return $Content;
}

1;
