SET SCHEMA 'Herbivorie';

alter domain Date_eco drop constraint Date_eco_check ;
alter domain Date_eco add constraint Date_eco_check
  check ((extract(year from value) between 2016 and 2030));

--
-- == Vérification et conversion de Date_eco
--

-- Vérification
create or replace function Date_eco_verif (argument text)
returns boolean -- vrai SSI valide
language sql as
$$
with
  syntaxe as (
    select argument,
      argument similar to '[0-9]{4}-[0-9]{2}-[0-9]{2}' as syntaxe_ok,
      split_part(argument, '-', 1) as annee_p,
      split_part(argument, '-', 2) as mois_p,
      split_part(argument, '-', 3) as jour_p
    ),
  evaluation as (
    select *,
      case when syntaxe_ok then annee_p::int else 1900 end annee,
      case when syntaxe_ok then mois_p::int else 1 end mois,
      case when syntaxe_ok then jour_p::int else 1 end jour
    from syntaxe),
  verification as (
    select *,
      case
      when mois in (1,3,5,7,8,10,12) then jour between 1 and 31
      when mois in (4,6,9,11) then jour between 1 and 30
      when mois = 2 then
        case when annee/4*4 = annee and (annee/100*100 <> annee or annee/400*400 = annee)
        then jour between 1 and 29
        else jour between 1 and 28 end
      else false end as valide
    from evaluation)
select
  syntaxe_ok and valide and (annee between 2016 and 2030) as resultat
from verification
$$;

-- Petit test Date_eco_verif
with
  A (d) as (values ('2021-12-03'), ('2021-02-29'), ('0000-12-31'), ('2015-12-31'), ('2031-01-01'))
select
  d as date , Date_eco_verif(d) as valide
from A ;

-- Conversion
create or replace function Date_eco_conv (v text)
returns date_eco
language sql as
$$
select to_date(v, 'yyyy-mm-dd')
$$;


create or replace function Entier_verif (v text, min integer, max integer)
returns boolean -- vrai SSI valide
language sql as
$$
select
  case
    when v similar to '(-)?[0-9]{1,6}' then
      cast (v as integer) between min and max
    else
      false
  end
$$;

-- Plant_id
CREATE OR REPLACE FUNCTION Plant_verif(v text)
RETURNS boolean
LANGUAGE sql AS $$
select v in (select id from megantic);
$$;

create or replace function Plant_CONV(v text)
returns Plant_id
language sql as $$
 select CAST(v as Plant_id);
$$;

-- Parcelle
create or replace function parcelle_verif(v text)
returns boolean
language sql as $$
select Entier_verif(v, 0, 99)
$$;

create or replace function Parcelle_CONV(v text)
returns parcelle
language sql as $$
 select CAST(v as parcelle)
$$;

-- Placette_id
create or replace function Placette_verif(v text)
returns boolean
language sql as $$
select v in (select placette from megantic)
$$;

create or replace function Placette_CONV(v text)
returns Placette_id
language sql as $$
 select CAST(v as placette_id);
$$;

-- Dim_mm
create or replace function longueur_verif(v text)
returns boolean
language sql as $$
 select Entier_Verif(v, 0, 10000);
 $$;

create or replace function longueur_CONV(v text)
returns dim_mm
language sql as $$
 select CAST (v as dim_mm);
$$;

create or replace function largeur_verif(v text)
returns boolean
language sql as $$
 select Entier_Verif(v, 0, 10000);
 $$;

create or replace function largeur_CONV(v text)
returns dim_mm
language sql as $$
 select CAST (v as dim_mm);
$$;




-- Description
create or replace function Description_verif(v text)
returns boolean
language sql as
$$
 select v in (select note from plant);
$$;

create or replace function Description_CONV(v text)
returns Description
language sql as
$$
select CAST(v as description)
$$;

-- Fleur
create or replace function Fleur_CONF(v text) returns boolean
language plpgsql as $$
begin
  if v is null or lower(v) = 'na' then return false; end if;
  return lower(v) in ('true', 'false', '1', '0');
end $$;

create or replace function Fleur_VAL(v text) returns boolean
language sql as $$
  select CAST(v as boolean);
$$;

create or replace function Fleur_CONV(v text) returns boolean
language plpgsql as $$
begin
  if v is null or lower(v) = 'na' then return null; end if;
  return CAST(v as boolean);
exception when others then return null;
end $$;


-- JJ
create or replace function JJ_CONF(v text) returns boolean
language plpgsql as $$
begin
  if v is null or lower(v) = 'na' then return false; end if;
  return v ~ '^[0-9]+$';
exception when others then return false;
end $$;

create or replace function JJ_VAL(v text) returns integer
language sql as $$
  select CAST(v as integer);
$$;

create or replace function JJ_CONV(v text) returns integer
language plpgsql as $$
begin
  if v is null or lower(v) = 'na' then return null; end if;
  return CAST(v as integer);
exception when others then return null;
end $$;

-- Etat_id
create or replace function Etat_id_CONF(v text) returns boolean
language plpgsql as $$
begin
  if v is null or lower(v) = 'na' then return false; end if;
  return v ~ '^[A-Z]{1}$';
end $$;

create or replace function Etat_id_VAL(v text) returns Etat_id
language sql as $$
  select CAST(v as Etat_id);
$$;

create or replace function Etat_id_CONV(v text) returns Etat_id
language plpgsql as $$
begin
  if v is null or lower(v) = 'na' then return null; end if;
  return CAST(v as Etat_id);
exception when others then return null;
end $$;

