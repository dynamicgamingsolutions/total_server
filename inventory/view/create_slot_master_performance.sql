USE inventory
GO

CREATE VIEW slot_master_performance AS

    SELECT
        reference_key,
        casino_id,
        asset_id,
        theme_id,
        asset_number,
        [zone],
        bank,
        [location],
        denom,
        rtp,
        hold,
        date_instl,
        golive,
        lastconver,
        active
    FROM slot_master_update
