-- SELECT * FROM slot_master_update

SELECT
    sm.uuid,
    sm.index_key,
    sm.reference_key,
    sm.insert_date,
    sm.update_date,
    sm.update_by,
    sm.change_log,
    tr.tribe_name,
    cn.casino_name,
    a.serial_number,
    v.vendor_name,
    cab.cabinet_name,
    sm.theme_id,
    sm.zone,
    sm.bank,
    sm.location,
    sm.asset_number,
    sm.denom,
    sm.os_version,
    sm.rtp,
    sm.hold,
    sm.prog_media,
    sm.paytable,
    sm.date_instl,
    sm.golive,
    sm.lastconver,
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
    sm.boot_bios,
    sm.print_id,
    sm.print_soft,
    sm.bill_validator_id,
    sm.billvalsft,
    sm.mon_type,
    sm.toppertype,
    sm.active
FROM slot_master_update sm

JOIN clients.dbo.casinos cn
ON sm.casino_id = cn.reference_key

JOIN clients.dbo.tribes tr
ON cn.tribe_id = tr.reference_key

JOIN assets a
ON sm.asset_id = a.reference_key

JOIN vendors.dbo.vendors v
ON a.vendor_id = v.reference_key

JOIN vendors.dbo.cabinets cab
ON a.cabinet_id = cab.reference_key