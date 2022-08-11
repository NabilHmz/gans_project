CREATE DATABASE IF NOT EXISTS gans;

USE gans;

CREATE TABLE IF NOT EXISTS cities (
    name VARCHAR(200),
    latitude text,
    longitude text,
    country text,
    population text,
    is_capital bool,
	municipality_iso_country varchar(200),
    PRIMARY KEY(municipality_iso_country));

select * from cities;

create table if not exists airports(
	name text, 
    latitude_deg float, 
    longitude_deg float, 
    iso_country varchar(10), 
    iso_region varchar(10),
    municipality text, 
    icao_code varchar(4), 
    iata_code varchar(6), 
    municipality_iso_country varchar(200),
    primary key(icao_code));
    -- foreign key (municipality_iso_country) references cities(municipality_iso_country));

select * from airports;
