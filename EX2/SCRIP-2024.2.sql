drop table VOTACION;
drop table PARTIDO_POLITICO;
drop table REGION_PERU;
drop table VOTOS_PARTIDO;

create table REGION_PERU
( idregion number primary key,
  nombre varchar2(10) not null );

create table PARTIDO_POLITICO
( idpartido number primary key,
  nombre varchar2(6) not null );

create table VOTACION
( idregion number,
  idpartido number,
  votos number,
  primary key (idregion,idpartido),
  foreign key (idregion) references REGION_PERU(idregion),
  foreign key (idpartido) references PARTIDO_POLITICO(idpartido) );

create table VOTOS_PARTIDO
( nombre_region varchar2(10) not null,
  votos number not null );
  
  
  insert into REGION_PERU ( idregion, nombre ) values ( 1, 'CUZCO' );
insert into REGION_PERU ( idregion, nombre ) values ( 2, 'PIURA' );
insert into REGION_PERU ( idregion, nombre ) values ( 3, 'HUANUCO' );
insert into REGION_PERU ( idregion, nombre ) values ( 4, 'TACNA' );

insert into PARTIDO_POLITICO ( idpartido, nombre ) values ( 1, 'BLANCO' );
insert into PARTIDO_POLITICO ( idpartido, nombre ) values ( 2, 'NULO' );
insert into PARTIDO_POLITICO ( idpartido, nombre ) values ( 3, 'ABC' );
insert into PARTIDO_POLITICO ( idpartido, nombre ) values ( 4, 'PQR' );
insert into PARTIDO_POLITICO ( idpartido, nombre ) values ( 5, 'XYZ' );

insert into VOTACION ( idregion, idpartido, votos ) values( 1, 1, 1210 );
insert into VOTACION ( idregion, idpartido, votos ) values( 1, 2, 897 );
insert into VOTACION ( idregion, idpartido, votos ) values( 1, 3, 5890 );
insert into VOTACION ( idregion, idpartido, votos ) values( 1, 4, 8163 );
insert into VOTACION ( idregion, idpartido, votos ) values( 1, 5, 2356 );

insert into VOTACION ( idregion, idpartido, votos ) values( 2, 1, 701 );
insert into VOTACION ( idregion, idpartido, votos ) values( 2, 2, 542 );
insert into VOTACION ( idregion, idpartido, votos ) values( 2, 3, 4872 );
insert into VOTACION ( idregion, idpartido, votos ) values( 2, 4, 6312 );
insert into VOTACION ( idregion, idpartido, votos ) values( 2, 5, 7125 );

insert into VOTACION ( idregion, idpartido, votos ) values( 3, 1, 432 );
insert into VOTACION ( idregion, idpartido, votos ) values( 3, 2, 924 );
insert into VOTACION ( idregion, idpartido, votos ) values( 3, 3, 3587 );
insert into VOTACION ( idregion, idpartido, votos ) values( 3, 4, 4128 );
insert into VOTACION ( idregion, idpartido, votos ) values( 3, 5, 2574 );

insert into VOTACION ( idregion, idpartido, votos ) values( 4, 1, 301 );
insert into VOTACION ( idregion, idpartido, votos ) values( 4, 2, 587 );
insert into VOTACION ( idregion, idpartido, votos ) values( 4, 3, 2803 );
insert into VOTACION ( idregion, idpartido, votos ) values( 4, 4, 5121 );
insert into VOTACION ( idregion, idpartido, votos ) values( 4, 5, 4799 );

  
  

  
  
  