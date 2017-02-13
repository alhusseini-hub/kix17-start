# Change log of KIX
* Copyright (C) 2006-2017 c.a.p.e. IT GmbH, http://www.cape-it.de/
* $Id$

#17.0.0 (2017/xx/xx)
 * (2017/02/13) - Bugfix: T2016102090001575 (skins in custom packages are ignored) (rkaiser)
 * (2017/02/10) - CR: T2017020290001194 (changed 'customer user' to 'contact' and only translation for 'owner') (rkaiser)
 * (2017/02/07) - Bugfix: T2017011190000661 (unnecessary requests delay form input for DynamicFieldRemoteDB and DynamicFieldITSMConfigItem) (millinger)
 * (2017/02/07) - Bugfix: T2017013190000712 (missing handling of CustomerIDRaw in Kernel::System::CustomerUser::DB::CustomerSearch) (rkaiser)
 * (2017/01/31) - Bugfix: T2017012490000913 (missing empty state value in AgentTicketPhoneCommon) (ddoerffel)
 * (2017/01/31) - Bugfix: T2017011290000276 (fixed text label in customer user list) (uboehm)
 * (2017/01/31) - Bugfix: T2017013190000678 (when creating tickets in customer frontend only services for primary CustomerID are available in dropdown) (rbo)
 * (2017/01/31) - Bugfix: T2017011990001057 (use of multiple customer ids could result in wrong customer user list in customer information center) (rkaiser)
 * (2017/01/30) - Bugfix: T2017011090001126 (js-error in CI graph if Loader::Enabled::JS is deactivated) (rkaiser)
 * (2017/01/27) - CR: T2016121190001552 (added migration scripts from OTRS and KIX 2016) (rbo)
 * (2017/01/26) - Bugfix: T2017011790001561 (customer frontend fixed formatting) (uboehm)
 * (2017/01/26) - Bugfix: T2017012490000833 (changed functionality in Core.Agent.HidePendingTimeInput) (fjacquemin)
 * (2017/01/24) - CR: T2016021990000594 (changes for windows installations) (rbo)
 * (2017/01/20) - Bugfix: T2017011190000625 (redundant box in new ticket view in customer frontend) (rkaiser)
 * (2017/01/18) - Bugfix: T2017011190000607 (ConfigItemDelete not possible to use from CI zoom mask) (ddoerffel)
 * (2017/01/18) - Bugfix: T2017011390000391 (wrong column title in config item compare mask) (ddoerffel)
 * (2017/01/02) - CR: T2016122890000451 (added customer ticket template portal) (rbo)
 * (2016/12/23) - CR: T2016121990002948 (address address book functionality) (rbo)
 * (2016/12/06) - CR: T2016121190001552 (code merge of all packages and changes for KIX 2017) (ddoerffel)
