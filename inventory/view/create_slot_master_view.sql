SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[slot_master_reference] AS 
SELECT
    sm.compid,
    ISNULL(th.reference_key, 'No Reference') AS theme_id,
    ISNULL(th.vendor_id, 'No Reference') AS vendor_id,
    ISNULL(th.cabinet_id, 'No Reference') AS cabinet_id,
    ISNULL(ca.state_id, 'No Reference') AS state_id,
    ISNULL(ca.tribe_id, 'No Reference') AS tribe_id,
    ISNULL(ca.reference_key, 'No Reference') AS casino_id,
    sm.assettype,
    sm.serial_no,
    sm.comment,
    sm.zone,
    sm.bank,
    sm.location,
    sm.asset_no,
    sm.denom,
    sm.vid_rl_pkr,
    sm.logic_box,
    sm.os_version,
    sm.theo_hold,
    sm.Hold,
    sm.prog_media,
    sm.paytable,
    sm.date_instl,
    sm.golive001,
    sm.lastconver,
    sm.rmvl_date,
    sm.class,
    sm.prog_type,
    sm.prog_level,
    sm.reset_1,
    sm.reset_2,
    sm.reset_3,
    sm.reset_4,
    sm.reset_5,
    sm.reset_6,
    sm.reset_7,
    sm.reset_8,
    sm.prog_1,
    sm.prog_2,
    sm.prog_3,
    sm.prog_4,
    sm.prog_5,
    sm.prog_6,
    sm.prog_7,
    sm.prog_8,
    sm.top_award,
    sm.reels,
    sm.no_lines,
    sm.bet_line,
    sm.maxcoinbet,
    sm.betconfig,
    sm.butt_panel,
    sm.top_boxtyp,
    ISNULL(pt.reference_key, 'No Reference') AS player_tracking_id,
    sm.boot_bios,
    ISNULL(pr.reference_key, 'No Reference') AS printer_id,
    sm.print_soft,
    ISNULL(bv.reference_key, 'No Reference') AS bill_validator_id,
    sm.billvalsft,
    sm.mon_type,
    sm.toppertype,
    sm.mach_cost,
    sm.ref_day001,
    sm.agror,
    sm.agrordate,
    sm.inv,
    sm.purch_date,
    sm.Sales_ORD,
    sm.active
FROM analytics.dbo.slot_master sm

LEFT JOIN vendors.dbo.themes th
    ON sm.theme = th.theme_name

LEFT JOIN clients.dbo.casinos ca
    ON sm.property = ca.casino_name

LEFT JOIN vendors.dbo.cabinets cab
    ON th.cabinet_id = cab.reference_key

LEFT JOIN vendors.dbo.player_tracking pt
    ON sm.back_os = pt.player_tracker

LEFT JOIN vendors.dbo.printers pr
    ON sm.printermod = pr.printer_name

LEFT JOIN vendors.dbo.bill_validators bv
    ON sm.bill_valid = bv.bill_validator_name

WHERE cab.cabinet_name = sm.model_no

-- USE inventory
-- GO
-- DROP VIEW IF EXISTS slot_master_reference
GO
