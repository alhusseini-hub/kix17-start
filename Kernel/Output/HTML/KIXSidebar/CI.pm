# --
# Kernel/Output/HTML/KIXSidebarCI.pm
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Frank(dot)Oberender(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# * Mario(dot)Illinger(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::KIXSidebar::CI;

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

    $Param{Config}->{QueryMinLength} = $Param{Config}->{QueryMinLength} || 1;
    $Param{Config}->{QueryDelay}     = $Param{Config}->{QueryDelay}     || 300;

    my $AdditionalClasses = '';
    if (   $Param{Config}->{'NoActionWithoutSelection'}
        && $Param{Action} =~ /$Param{Config}->{'NoActionWithoutSelection'}/ )
    {
        $AdditionalClasses .= 'NoActionWithoutSelection';
    }
    if (   $Param{Config}->{'InitialCollapsed'}
        && $Param{Action} =~ /$Param{Config}->{'InitialCollapsed'}/ )
    {
        if ( $AdditionalClasses ne '' ) {
            $AdditionalClasses .= ' ';
        }
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

    if ( !$Param{Config}->{SearchInputDisabled} ) {
        $Self->{LayoutObject}->Block(
            Name => 'SearchBox',
            Data => {
                %{$Param{Ticket} || {}},
                %{$Param{Config}},
            },
        );
        $Self->{LayoutObject}->Block(
            Name => 'SearchJS',
            Data => {
                %{$Param{Ticket} || {}},
                %{$Param{Config}},
            },
        );
    }
    if ( $Param{Config}->{'AutoSearch'} && $Param{Action} =~ /$Param{Config}->{'AutoSearch'}/ ) {
        my $LinkType = $Self->{Config}->{'LinkType'} || 'RelevantTo';
        $Self->{LayoutObject}->Block(
            Name => 'AutoSearch',
            Data => {
                %{$Param{Ticket} || {}},
                %{$Param{Config}},
                LinkType => $LinkType,
            },
        );
    }
    if (   $Param{Config}->{'AutoSelectOne'}
        && $Param{Action} =~ /$Param{Config}->{'AutoSelectOne'}/ )
    {
        $Self->{LayoutObject}->Block(
            Name => 'AutoSelectOne',
            Data => {
                %{$Param{Ticket} || {}},
                %{$Param{Config}},
            },
        );
    }
    if (   $Param{Config}->{'CustomerDependend'}
        && $Param{Action} =~ /$Param{Config}->{'CustomerDependend'}/ )
    {
        $Self->{LayoutObject}->Block(
            Name => 'CustomerDependend',
            Data => {
                %{$Param{Ticket} || {}},
                %{$Param{Config}},
            },
        );
    }

    # output result
    my $Content = $Self->{LayoutObject}->Output(
        TemplateFile   => 'KIXSidebar/CISearch',
        Data           => {
            %{$Param{Ticket} || {}},
            %{$Param{Config}},
        },
        KeepScriptTags => $Param{AJAX},
    );

    return $Content;
}

1;
