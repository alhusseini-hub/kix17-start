// --
// Copyright (C) 2006-2017 c.a.p.e. IT GmbH, http://www.cape-it.de
//
// written/edited by:
//   Rene(dot)Boehm(at)cape(dash)it.de
//   Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
//   Ricky(dot)Kaiser(at)cape(dash)it.de
// --
// $Id$
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Core = Core || {};
Core.KIXBase = Core.KIXBase || {};

/**
 * @namespace
 * @exports TargetNS as Core.KIXBase.Agent
 * @description This namespace contains the special module functions for
 *              KIXBase
 */
Core.KIXBase.Agent = (function(TargetNS) {
    var SUPERAJAXContentUpdate = Core.AJAX.ContentUpdate;
    var SUPERAdminNotificationEventAddLanguage;

    TargetNS.Init = function() {

        // hide Toolbar
        if ($('#ToolBarToggle').length == 0 && $('#ToolBar').length > 0) {

            var Class = 'Show';

            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), 'Action=KIXBaseAJAXHandler;Subaction=GetToolBarToggleState', function(Result) {
                if (Result == 1) {
                    $('#ToolBar').removeClass('Hidden');
                    Class = 'Hide';
                }
                else {
                    $('#ToolBar').addClass('Hidden');
                }
            },
            'text', false);

            $('#Header').append('<div id="ToolBarToggle" class="' + Class + '">' + Core.Config.Get('ShowToolBarMsg') + '</div>');

            $('#ToolBarToggle').click(function() {
                if ($('#ToolBarToggle').hasClass('Show')) {
                    $('#ToolBar').show('fast');
                    $('#ToolBarToggle').removeClass('Show').addClass('Hide');

                    Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), 'Action=KIXBaseAJAXHandler;Subaction=SaveToolBarToggleState;ToolBarShown=1', null, 'text');
                }
                else {
                    $('#ToolBar').hide('fast');
                    $('#ToolBarToggle').removeClass('Hide').addClass('Show');

                    Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), 'Action=KIXBaseAJAXHandler;Subaction=SaveToolBarToggleState;ToolBarShown=0', null, 'text');
                }
            });
        }

        // combine dashboard stats
        var StatsElements = [
            '#Dashboard0250-TicketStats',
            '#Dashboard0251-TicketStats2Weeks',
            '#Dashboard0252-TicketStats1Month',
            '#Dashboard0510-CIC-TicketStats',
            '#Dashboard0520-CIC-TicketStats2Weeks',
            '#Dashboard0530-CIC-TicketStats1Month'
        ];

        // find out which element do we have to act as base element
        var $BaseElement = undefined;
        StatsElements.forEach(function(Selector) {
            Selector += '-box';
            if (!$BaseElement && $(Selector).length > 0) {
                $BaseElement = $(Selector);
            }
        });

        if ($BaseElement) {
            $BaseElement.children('.Content').prepend('<select id="DashboardCombinedStatsSelection"></select>');

            StatsElements.forEach(function(Selector) {
                var $Element = $(Selector);
                if ($Element.length > 0) {
                    $BaseElement.children('.Content').append('<div id="' + $Element.attr('id') + '-Container" class="SvgInvisible"></div>');
                    $Element.detach().appendTo($(Selector + '-Container'));
                    $('#DashboardCombinedStatsSelection').append(new Option($(Selector + '-box .Header h2 span').html(), Selector + '-Container'));

                    if ($(Selector + '-box').attr('id') != $BaseElement.attr('id')) {
                        $(Selector + '-box').remove();
                    }
                }
            });

            $BaseElement.find('.Header h2 span').html(Core.Config.Get('StatsMsg'));

            // select first stat
            $('#DashboardCombinedStatsSelection').find('option:first').attr('selected','selected');
            $('#DashboardCombinedStatsSelection').change(function() {
                $(this).parent().children('div:not(.SvgInvisible)').toggleClass('SvgInvisible');
                $($(this).val()).toggleClass('SvgInvisible');
            }).trigger('change');
        }

        // add CSS class to SearchProfileSelectionSaved
        $('#SearchProfileSelectionSaved').parent().addClass('SearchProfileSelectionButtons');

        // replace strings
        $('.MessageBox > p, h3, h2 > span, .AdminSupportDataCollector .ItemLabel, .AdminSupportDataCollector .CheckResultProblem').each(function() {
            $(this).html($(this).html().replace('OTRS', 'KIX'));
            $(this).html($(this).html().replace('KIX4KIX', 'KIX4OTRS'));
            $(this).html($(this).html().replace('KIXMasterSlave', 'OTRSMasterSlave'));
        });

        // select first article in ticket when no article is selected
        if ($('#ArticleTree').length > 0 && $('#ArticleTree').children().length > 0 && $('#ArticleItems').length > 0 && $('#ArticleItems').children().length == 0) {
            Core.Agent.TicketZoom.LoadArticleFromExternal($('#ArticleTable tbody tr:first-child').addClass('Active').find('input.ArticleID').val());
        }

        // special handling for CIGraph tab
        $('.CITabLinkGraph #LoadGraphStart').detach().insertAfter($('.CITabLinkGraph #UpdateDisplayedGraph')).parent().removeClass('Spacing');
        $('.CITabLinkGraph #IFrameParam').find('.Spacing.Top.RightAligned').remove();

        // special handling for AdminNotificationEvent
        $('#Language.LanguageAdd').on('change', function() {
            window.setTimeout(function() {
                Core.UI.InitWidgetActionToggle();
            }, 500);
        });

        // special handling for AdminState
        if ($(location).attr('href').match(/AdminState/)) {
            $('.SidebarColumn .WidgetSimple:last-child .Content .FieldExplanation:last-child').remove();
        }

        // special handling for MergeToCustomer
        if ($(location).attr('href').match(/AgentTicketMergeToCustomer/)) {
            $('table.TicketToMergeTable').removeClass('TicketToMergeTable TableSmall').addClass('DataTable');
        }

        // special handling for AdminPackageManeger
        if ($(location).attr('href').match(/AdminPackageManager/)) {
            $('form input[name=SysConfigGroup]').parents('li').remove();
        }

        $('#SelectedCustomerUser').bind('change',function() {
            window.setTimeout(function() {
                // check sidebars whether they should be opened
                Core.KIXBase.Agent.AutoToggleSidebars();
            }, 2000);
        });

        // closed sidebars withoout content
        Core.KIXBase.Agent.AutoToggleSidebars();

        // init Professional if exists
        if (typeof Core.KIXBase.Agent.InitPro == 'function') {
            Core.KIXBase.Agent.InitPro();
        }

        // move navigation left
        $('#NavigationContainer').css({"left":"100px"});

        // Change text from "phone ticket" to "ticket"
        $('#Dashboard0050-CIC-CustomerUserList table th:nth-of-type(5)').text('Ticket');
    }

    // hook Core.AJAX.ContentUpdate method
    Core.AJAX.ContentUpdate = function ($ElementToUpdate, URL, Callback, Async) {
        if ($ElementToUpdate.attr('id') == 'ArticleItems') {
            // add own callback
            SUPERAJAXContentUpdate($ElementToUpdate, URL, function() {
                // execute original callback
                if (typeof Callback == 'function')
                    Callback();

                // add padding to WidgetSimple Header h2 if Toggle element exists before
                $('#ArticleItems .WidgetSimple > .Header > h2').each(function () {
                    if ($(this).parent('.Header').children().index($(this)) > 0 && $(this).parent('.Header').children('.Toggle').length == 1) {
                        $(this).addClass('PaddingLeft15px');
                    }
                    // enclose text into span element for positioning (we have to check html() here, because otherwise it won't work in FAQ)
                    if ($(this).html().length > 0 && !$(this).html().indexOf('<span') == 0) {
                        $(this).html('<span>' + $(this).html() + '</span>');
                    }
                });

                /*
                 * deactivated 01-12-2016 (Ticket #2016111790000633)
                 * // add color to article body
                 * $('#ArticleItems .WidgetSimple > .Content iframe').load(function() {
                 *     $(this).contents().find('body').css('color', '#0A6491');
                 * });
                 */

                Core.KIXBase.Agent.AutoToggleSidebars();

            }, Async);
        }
        else {
            // call original method without change
            SUPERAJAXContentUpdate($ElementToUpdate, URL, Callback, Async);
            Core.KIXBase.Agent.AutoToggleSidebars();
        }
    }

    // redefine Core.KIX4OTRS.ResizePopup method
    Core.KIX4OTRS.ResizePopup = function (Action) {
        var PopupWidth,
            PopupHeight,
            PopupPositionX,
            PopupPositionY,
            Start = 1,
            ResizeDone = 0,
            URL = Core.Config.Get('Baselink');

        if (window.name.match(/OTRSPopup_.+/) && window.opener !== null) {
            if (Start) {
                // get data
                Data = {
                    Action : 'PopupSize',
                    Subaction : 'GetPopupSize',
                    CallingAction : Action
                };

                // get user preferences width and height of the popup window
                Core.AJAX.FunctionCall(URL, Data, function(Result) {
                    $.each(Result, function() {

                        PopupWidth = this.Width;
                        PopupHeight = this.Height;
                        PopupPositionX = this.PositionX;
                        PopupPositionY = this.PositionY;

                        // resize popup
                        if (PopupHeight && PopupWidth) {
                            window.resizeTo(PopupWidth, PopupHeight);
                            ResizeDone = 1;
                        }

                        // move popup
                        if (PopupPositionX && PopupPositionY) {
                            window.moveTo(PopupPositionX,PopupPositionY);
                            ResizeDone = 1;
                        }
                    });
                });

                if (!ResizeDone) {
                    Start = 0;
                }

            }

            // get end of resizing
            $(window).resize(function() {
                if (this.resizeTO) {
                    clearTimeout(this.resizeTO);
                }
                this.resizeTO = setTimeout(function() {
                    $(this).trigger('resizeEnd');
                }, 500);
            });

            var OldPositionX     = window.screenX,
                    OldPositionY = window.screenY;

            var Interval = setInterval(function(){
                if(OldPositionX != window.screenX || OldPositionY != window.screenY){
                    $(this).trigger('moveEnd');
                }
                OldPositionX = window.screenX;
                OldPositionY = window.screenY;
            }, 5000);

            // save new size every time the size has changed
            $(window).bind('resizeEnd', function() {

                if (!Start) {
                    var Height = window.outerHeight,
                        Width = window.outerWidth,
                        PositionX = window.screenX,
                        PositionY = window.screenY;

                    var URL = Core.Config.Get('Baselink'), Data = {
                        Action : 'PopupSize',
                        Subaction : 'UpdatePopupSize',
                        CallingAction : Action,
                        Width : Width,
                        Height : Height,
                        PositionX : PositionX,
                        PositionY : PositionY
                    };

                    Core.AJAX.FunctionCall(URL, Data, function() {}, 'text');
                } else {
                    Start = 0;
                }
            });

            // save new position every time the size has changed
            $(window).bind('moveEnd', function() {
                if (!Start) {
                    var Height = window.outerHeight,
                        Width = window.outerWidth,
                        PositionX = window.screenX,
                        PositionY = window.screenY;

                    var URL = Core.Config.Get('Baselink'), Data = {
                        Action : 'PopupSize',
                        Subaction : 'UpdatePopupSize',
                        CallingAction : Action,
                        Width : Width,
                        Height : Height,
                        PositionX : PositionX,
                        PositionY : PositionY
                    };

                    Core.AJAX.FunctionCall(URL, Data, function() {}, 'text');
                } else {
                    Start = 0;
                }
            });

        }
    }

    // expand or collapse sidebars if no content is available
    TargetNS.AutoToggleSidebars = function () {
        // close all widgets without content (special handling for ContactInfo sidebar)
        $('.WidgetSimple.Expanded').each(function() {
            if ($(this).children('.Content').last().children().length == 0 ||
                  ($(this).children('.Content').last().children().length == 1 && $(this).children('.Content').last().children('.CustomerDetailsMagnifier').length == 1) )
              {
                $(this).children('.Header').find('.Toggle a i:visible').click();
                $(this).addClass('KIXAutoCollapsed');
            }
        });

        // open all widgets with content that has been collapsed before (special handling for ContactInfo sidebar)
        $('.WidgetSimple.Collapsed.KIXAutoCollapsed').each(function() {
            if ($(this).children('.Content').last().children().length > 0 &&
                  !($(this).children('.Content').last().children().length == 1 && $(this).children('.Content').last().children('.CustomerDetailsMagnifier').length == 1) )
            {
                $(this).children('.Header').find('.Toggle a i:visible').click();
            }
        });
    }

    return TargetNS;
}(Core.KIXBase.Agent || {}));
