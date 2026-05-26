DROP TABLE IF EXISTS acquisitions;

CREATE TABLE acquisitions (
    deal_id                 INTEGER,
    parent_company          TEXT,
    acquisition_year        INTEGER,
    acquisition_month       TEXT,
    acquired_company        TEXT,
    business                TEXT,
    country                 TEXT,
    acquisition_price       TEXT,
    category                TEXT,
    derived_products        TEXT
);