CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE TABLE dataloadsimulation.seasonvariation
(
    Year              INTEGER        NOT NULL,
    Season            SMALLINT       NOT NULL,
    YearlyVariation   DOUBLE PRECISION NOT NULL,
    SeasonalVariation DOUBLE PRECISION NOT NULL,
    CONSTRAINT PK_DataLoadSimulation_SeasonVariation PRIMARY KEY (Year, Season)
);
