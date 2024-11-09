DROP TABLE empleado;
DROP TABLE empresa;
DROP TABLE lista;
DROP TABLE detalle_bonos;
DROP TABLE resumen_bonos;
DROP TABLE asignacion_emp;
DROP TABLE errores;
DROP SEQUENCE sq_errores;

CREATE SEQUENCE sq_errores; 

CREATE TABLE asignacion_emp (
  rut VARCHAR2(10) NOT NULL,
  nombre VARCHAR2(40) NOT NULL,
  sueldo NUMBER(8) NOT NULL,
  asignacion NUMBER(8) NOT NULL,
  CONSTRAINT pk_asignacion_emp PRIMARY KEY (rut)
);

CREATE TABLE detalle_bonos (
  mes_anno_proceso VARCHAR2(6) NOT NULL,
  rut VARCHAR2(10) NOT NULL,
  nombre VARCHAR2(40) NOT NULL,
  empresa VARCHAR2(50) NOT NULL,
  sueldo NUMBER(8) NOT NULL,  
  edad NUMBER(2) NOT NULL,
  antiguedad NUMBER(2) NOT NULL,
  bono_antig NUMBER(8) NOT NULL,
  comision NUMBER(8) NOT NULL,
  asig_edad NUMBER(8) NOT NULL,
  asig_categ NUMBER(8) NOT NULL,
  total_asignaciones NUMBER(8) NOT NULL,
  CONSTRAINT pk_detalle PRIMARY KEY (rut, mes_anno_proceso)
);


CREATE TABLE resumen_bonos (
 mes_anno_proceso VARCHAR2(6) NOT NULL,
 empresa VARCHAR2(50),
 numempleados NUMBER,
 tot_sueldos NUMBER,
 tot_bonoantig NUMBER NOT NULL,
 tot_comision NUMBER NOT NULL,
 tot_asigedad NUMBER NOT NULL,
 tot_asigcat NUMBER NOT NULL,
 total_asignaciones NUMBER NOT NULL,
 CONSTRAINT pk_resumen PRIMARY KEY (mes_anno_proceso,empresa)
);
 
CREATE TABLE errores (
  num_error NUMBER,
  subprograma VARCHAR2(30),
  msg_error VARCHAR2(300),
  msg_usr VARCHAR2(400),
  CONSTRAINT pk_errores PRIMARY KEY (num_error)
);

CREATE TABLE lista (
  lista VARCHAR2(10),
  punt_min NUMBER(3),
  punt_max number(3),
  pct number,
  CONSTRAINT pk_lista PRIMARY KEY (lista)
);

CREATE TABLE empresa ( 
  rut NUMBER NOT NULL,
  dv VARCHAR2(1) NOT NULL,
  razonsocial VARCHAR2(50) NOT NULL,
  CONSTRAINT empresa_pk PRIMARY KEY (rut)   
);

CREATE TABLE empleado ( 
  rut NUMBER NOT NULL,
  dv CHAR(1) NOT NULL,
  nombres VARCHAR2(20) NOT NULL,
  apellidos VARCHAR2(20) NOT NULL,
  rutempresa NUMBER,
  numproyectos NUMBER NULL,
  puntaje NUMBER NULL,
  sueldo NUMBER NOT NULL,
  email VARCHAR2(30),
  zona VARCHAR2(12),
  fecingreso DATE,
  fecnac DATE,
  numcargas NUMBER(3),
  numinterno VARCHAR2(6), 
  CONSTRAINT pk_empleado PRIMARY KEY (rut),
  CONSTRAINT ak_empleado_numero UNIQUE (numinterno), 
  CONSTRAINT ak_empleado_email UNIQUE (email)
); 

ALTER TABLE empleado
   ADD CONSTRAINT empresa_empleado_fk1 FOREIGN KEY (rutempresa)
   REFERENCES empresa (rut);
   
/* Inserta datos en la tabla Empresa */

INSERT INTO empresa VALUES (90147888,'6','Almacenes Torre Eiffel');
INSERT INTO empresa VALUES (92024905,'2','Net-Tel');
INSERT INTO empresa VALUES (92436124,'7','Comunicaciones Bruce Lee');
INSERT INTO empresa VALUES (93350895,'1','Farmacias Oriente, donde lo que paga no se siente');
INSERT INTO empresa VALUES (93741395,'3','Luchezzi');
INSERT INTO empresa VALUES (96874487,'8','NesWatt S.A.');
INSERT INTO empresa VALUES (97923132,'2','Hotel Paraíso');
INSERT INTO empresa VALUES (97948160,'2','Panaderia Rebeca');
INSERT INTO empresa VALUES (98484732,'K','Supermercado Redil');
INSERT INTO empresa VALUES (98691599,'3','CenterHome Camidos');
INSERT INTO empresa VALUES (74363623,'4','Ferretería Portales');

/* Inserta datos en la tabla Empleado*/

INSERT INTO empleado VALUES (6057969,'6','Elena','Miranda',97948160,4,431,950843,'e.miranda',NULL,to_date('12/01/02','DD/MM/RR'),to_date('17/11/60','DD/MM/RR'),1,'EM0001');
INSERT INTO empleado VALUES (6269943,'8','Rachael','Parsons',93741395,5,494,1445178,'r.parsons',NULL,to_date('14/02/94','DD/MM/RR'),to_date('15/02/71','DD/MM/RR'),0,'EM0002');
INSERT INTO empleado VALUES (6275202,'0','Sheryl','Richards',98484732,9,350,898739,'s.richards',NULL,to_date('25/02/91','DD/MM/RR'),to_date('31/12/75','DD/MM/RR'),5,'EM0003');
INSERT INTO empleado VALUES (6419034,'9','Marci','Frost',90147888,0,491,670765,'m.frost',NULL,to_date('29/10/04','DD/MM/RR'),to_date('06/08/81','DD/MM/RR'),6,'EM0004');
INSERT INTO empleado VALUES (6502066,'1','Timothy','Petty',97923132,5,353,1930422,'t.petty',NULL,to_date('27/04/94','DD/MM/RR'),to_date('24/02/52','DD/MM/RR'),3,'EM0005');
INSERT INTO empleado VALUES (6506702,'K','Leonard','Wilcox',97923132,4,334,335111,'l.wilcox',NULL,to_date('16/05/88','DD/MM/RR'),to_date('06/06/66','DD/MM/RR'),6,'EM0006');
INSERT INTO empleado VALUES (6694138,'K','Leonard','Chambers',92024905,1,453,614416,'l.chambers',NULL,to_date('18/02/97','DD/MM/RR'),to_date('02/06/52','DD/MM/RR'),0,'EM0007');
INSERT INTO empleado VALUES (6756480,'2','Marcie','Phelps',96874487,2,382,1383221,'m.phelps',NULL,to_date('08/06/89','DD/MM/RR'),to_date('02/07/59','DD/MM/RR'),6,'EM0008');
INSERT INTO empleado VALUES (6946767,'8','Seth','Carney',92436124,7,158,1026447,'s.carney',NULL,to_date('22/03/10','DD/MM/RR'),to_date('07/03/54','DD/MM/RR'),3,'EM0009');
INSERT INTO empleado VALUES (7005434,'0','Melissa','Walton',92024905,5,363,847075,'m.walton',NULL,to_date('13/10/86','DD/MM/RR'),to_date('21/11/51','DD/MM/RR'),5,'EM0010');
INSERT INTO empleado VALUES (7034898,'2','Carmen','Friedman',98691599,9,405,1681925,'c.friedman',NULL,to_date('23/02/99','DD/MM/RR'),to_date('04/01/85','DD/MM/RR'),5,'EM0011');
INSERT INTO empleado VALUES (7150191,'9','Travis','Gamble',97948160,6,173,1408071,'t.gamble',NULL,to_date('05/02/99','DD/MM/RR'),to_date('01/07/69','DD/MM/RR'),2,'EM0012');
INSERT INTO empleado VALUES (7168526,'9','Lewis','Villanueva',92436124,10,126,562049,'l.villanueva',NULL,to_date('07/04/89','DD/MM/RR'),to_date('27/11/81','DD/MM/RR'),2,'EM0013');
INSERT INTO empleado VALUES (7284220,'2','Latasha','Gordon',93741395,6,111,1307600,'l.gordon',NULL,to_date('19/09/84','DD/MM/RR'),to_date('17/06/59','DD/MM/RR'),5,'EM0014');
INSERT INTO empleado VALUES (7380283,'5','Marla','Mc Intyre',98691599,2,152,1346264,'m.mc intyre',NULL,to_date('16/07/06','DD/MM/RR'),to_date('03/01/78','DD/MM/RR'),3,'EM0015');
INSERT INTO empleado VALUES (7503210,'4','Alisa','Cruz',NULL,4,308,1869282,'a.cruz',NULL,to_date('24/08/96','DD/MM/RR'),to_date('24/10/71','DD/MM/RR'),4,'EM0016');
INSERT INTO empleado VALUES (7560327,'1','Dewayne','Rubio',97948160,9,475,1156358,'d.rubio',NULL,to_date('09/11/88','DD/MM/RR'),to_date('19/11/75','DD/MM/RR'),3,'EM0017');
INSERT INTO empleado VALUES (7744083,'0','Rochelle','Marquez',93350895,10,136,569319,'r.marquez',NULL,to_date('29/10/85','DD/MM/RR'),to_date('08/09/64','DD/MM/RR'),4,'EM0018');
INSERT INTO empleado VALUES (7860078,'9','Chris','Pittman',96874487,9,64,614938,'c.pittman',NULL,to_date('10/03/86','DD/MM/RR'),to_date('27/12/66','DD/MM/RR'),0,'EM0019');
INSERT INTO empleado VALUES (7873889,'0','Darius','Pineda',96874487,2,227,1209473,'d.pineda',NULL,to_date('05/08/83','DD/MM/RR'),to_date('26/10/58','DD/MM/RR'),5,'EM0020');
INSERT INTO empleado VALUES (7909083,'2','Teri','Harris',97923132,7,388,1585532,'t.harris',NULL,to_date('10/10/05','DD/MM/RR'),to_date('19/06/81','DD/MM/RR'),3,'EM0021');
INSERT INTO empleado VALUES (7981132,'6','Shauna','Key',NULL,5,175,795164,'s.key',NULL,to_date('16/01/94','DD/MM/RR'),to_date('01/08/83','DD/MM/RR'),6,'EM0022');
INSERT INTO empleado VALUES (8052875,'7','Luke','Shepherd',90147888,8,205,1846733,'l.shepherd',NULL,to_date('25/12/10','DD/MM/RR'),to_date('17/12/53','DD/MM/RR'),5,'EM0024');
INSERT INTO empleado VALUES (8226222,'4','Kris','Marquez',96874487,0,61,992859,'k.marquez',NULL,to_date('16/04/01','DD/MM/RR'),to_date('13/06/83','DD/MM/RR'),1,'EM0026');
INSERT INTO empleado VALUES (8267282,'9','Armando','Roman',97923132,3,153,408304,'a.roman',NULL,to_date('31/03/98','DD/MM/RR'),to_date('04/04/74','DD/MM/RR'),2,'EM0028');
INSERT INTO empleado VALUES (8283331,'3','Trevor','Livingston',96874487,8,296,832934,'t.livingston',NULL,to_date('26/08/09','DD/MM/RR'),to_date('14/09/61','DD/MM/RR'),0,'EM0030');
INSERT INTO empleado VALUES (8317567,'0','Courtney','Boyle',97923132,8,61,1367941,'c.boyle',NULL,to_date('26/06/90','DD/MM/RR'),to_date('14/12/81','DD/MM/RR'),6,'EM0032');
INSERT INTO empleado VALUES (8424780,'5','Jamie','Callahan',92436124,7,370,341899,'j.callahan',NULL,to_date('29/09/94','DD/MM/RR'),to_date('01/11/63','DD/MM/RR'),6,'EM0034');
INSERT INTO empleado VALUES (8430817,'4','Oscar','Clay',97948160,2,499,1450677,'o.clay',NULL,to_date('08/05/87','DD/MM/RR'),to_date('31/03/79','DD/MM/RR'),3,'EM0035');
INSERT INTO empleado VALUES (8562067,'5','Ramon','Mckay',NULL,2,441,1818838,'r.mckay',NULL,to_date('01/10/03','DD/MM/RR'),to_date('25/01/78','DD/MM/RR'),6,'EM0037');
INSERT INTO empleado VALUES (8629897,'K','Edward','Dominguez',92024905,6,171,750934,'e.dominguez',NULL,to_date('28/06/03','DD/MM/RR'),to_date('04/01/51','DD/MM/RR'),6,'EM0039');
INSERT INTO empleado VALUES (8827284,'4','Geoffrey','Richardson',90147888,2,200,613252,'g.richardson',NULL,to_date('03/01/80','DD/MM/RR'),to_date('20/04/77','DD/MM/RR'),3,'EM0041');
INSERT INTO empleado VALUES (9026650,'3','Karen','Tate',92024905,1,359,749126,'k.tate',NULL,to_date('19/07/82','DD/MM/RR'),to_date('22/10/76','DD/MM/RR'),6,'EM0043');
INSERT INTO empleado VALUES (9087132,'1','Jimmie','Lyons',98484732,6,83,1392359,'j.lyons',NULL,to_date('22/06/83','DD/MM/RR'),to_date('19/03/55','DD/MM/RR'),5,'EM0045');
INSERT INTO empleado VALUES (9320960,'1','Chadwick','Wilson',93741395,2,319,1262313,'c.wilson',NULL,to_date('01/03/02','DD/MM/RR'),to_date('25/11/56','DD/MM/RR'),0,'EM0047');
INSERT INTO empleado VALUES (9390658,'1','Benjamin','Gonzales',92024905,7,420,1771549,'b.gonzales',NULL,to_date('15/10/05','DD/MM/RR'),to_date('29/08/54','DD/MM/RR'),2,'EM0049');
INSERT INTO empleado VALUES (9469490,'K','Candy','Haley',92024905,6,396,1110938,'c.haley',NULL,to_date('21/08/90','DD/MM/RR'),to_date('07/08/67','DD/MM/RR'),2,'EM0051');
INSERT INTO empleado VALUES (9577214,'2','Rachel','Bradshaw',92436124,6,340,304813,'r.bradshaw',NULL,to_date('23/12/09','DD/MM/RR'),to_date('30/10/75','DD/MM/RR'),0,'EM0053');
INSERT INTO empleado VALUES (9807767,'8','Wendi','Mora',97923132,2,172,906320,'w.mora',NULL,to_date('06/10/09','DD/MM/RR'),to_date('20/11/67','DD/MM/RR'),4,'EM0055');
INSERT INTO empleado VALUES (9857992,'0','Linda','Chandler',92436124,9,378,1095310,'l.chandler',NULL,to_date('06/01/04','DD/MM/RR'),to_date('31/10/63','DD/MM/RR'),4,'EM0057');
INSERT INTO empleado VALUES (1005811,'3','Bart','Wall',98691599,9,110,1168475,'b.wall',NULL,to_date('28/07/03','DD/MM/RR'),to_date('04/06/75','DD/MM/RR'),2,'EM0059');
INSERT INTO empleado VALUES (1023286,'8','Monte','Baxter',98691599,3,98,986349,'m.baxter',NULL,to_date('29/10/93','DD/MM/RR'),to_date('31/01/66','DD/MM/RR'),3,'EM0061');
INSERT INTO empleado VALUES (1025328,'5','Tabatha','Barnett',90147888,0,175,1195280,'t.barnett',NULL,to_date('20/12/92','DD/MM/RR'),to_date('02/04/70','DD/MM/RR'),3,'EM0062');
INSERT INTO empleado VALUES (1056582,'7','Barbara','Rogers',98691599,6,213,1799127,'b.rogers',NULL,to_date('16/10/98','DD/MM/RR'),to_date('23/09/52','DD/MM/RR'),5,'EM0064');
INSERT INTO empleado VALUES (1071122,'8','Priscilla','Everett',96874487,3,361,1915515,'p.everett',NULL,to_date('09/04/02','DD/MM/RR'),to_date('31/10/78','DD/MM/RR'),3,'EM0066');
INSERT INTO empleado VALUES (1081176,'3','Ryan','Riggs',98691599,2,340,468516,'r.riggs',NULL,to_date('05/05/07','DD/MM/RR'),to_date('16/01/50','DD/MM/RR'),2,'EM0068');
INSERT INTO empleado VALUES (1098366,'0','Quentin','Calhoun',97923132,8,325,2075525,'q.calhoun',NULL,to_date('31/10/87','DD/MM/RR'),to_date('30/10/66','DD/MM/RR'),1,'EM0070');
INSERT INTO empleado VALUES (1107688,'6','Marlon','Espinoza',NULL,9,349,912593,'m.espinoza',NULL,to_date('01/05/02','DD/MM/RR'),to_date('01/08/81','DD/MM/RR'),5,'EM0072');
INSERT INTO empleado VALUES (1127932,'4','James','Bruce',98691599,2,468,2015156,'j.bruce',NULL,to_date('29/09/92','DD/MM/RR'),to_date('08/12/64','DD/MM/RR'),1,'EM0074');
INSERT INTO empleado VALUES (11429841,'0','Francis','Potts',96874487,8,195,2007464,'f.potts',NULL,to_date('11/08/00','DD/MM/RR'),to_date('10/10/71','DD/MM/RR'),3,'EM0076');
INSERT INTO empleado VALUES (11488488,'7','Evan','Moses',93350895,3,70,1572641,'e.moses',NULL,to_date('23/04/92','DD/MM/RR'),to_date('14/07/55','DD/MM/RR'),6,'EM0078');
INSERT INTO empleado VALUES (11571000,'5','Candice','Spencer',92436124,9,435,399656,'c.spencer',NULL,to_date('09/03/86','DD/MM/RR'),to_date('06/02/78','DD/MM/RR'),3,'EM0080');
INSERT INTO empleado VALUES (11652617,'3','Preston','Mc Neil',92024905,3,435,1479382,'p.mc neil',NULL,to_date('21/07/98','DD/MM/RR'),to_date('25/02/81','DD/MM/RR'),2,'EM0081');
INSERT INTO empleado VALUES (11744345,'3','Isaac','Boyd',97923132,9,208,2029891,'i.boyd',NULL,to_date('20/11/84','DD/MM/RR'),to_date('03/06/73','DD/MM/RR'),2,'EM0083');
INSERT INTO empleado VALUES (11766897,'9','Marvin','Graves',98691599,8,292,1782169,'m.graves',NULL,to_date('17/11/82','DD/MM/RR'),to_date('02/08/72','DD/MM/RR'),6,'EM0085');
INSERT INTO empleado VALUES (11856596,'9','Jeannette','Vazquez',98484732,2,137,525564,'j.vazquez',NULL,to_date('12/06/84','DD/MM/RR'),to_date('30/03/78','DD/MM/RR'),5,'EM0087');
INSERT INTO empleado VALUES (12021648,'9','Clayton','Downs',96874487,4,123,1143715,'c.downs',NULL,to_date('11/07/92','DD/MM/RR'),to_date('12/04/56','DD/MM/RR'),3,'EM0089');
INSERT INTO empleado VALUES (12343331,'9','Donald','Coffey',97948160,7,232,870278,'d.coffey',NULL,to_date('02/03/06','DD/MM/RR'),to_date('17/04/65','DD/MM/RR'),4,'EM0091');
INSERT INTO empleado VALUES (12413623,'8','Derrick','Butler',92024905,2,475,1584274,'d.butler',NULL,to_date('27/06/04','DD/MM/RR'),to_date('12/04/64','DD/MM/RR'),6,'EM0093');
INSERT INTO empleado VALUES (12483581,'0','Jenifer','Crosby',93741395,7,264,1053112,'j.crosby',NULL,to_date('28/10/85','DD/MM/RR'),to_date('10/07/54','DD/MM/RR'),2,'EM0095');
INSERT INTO empleado VALUES (12596096,'5','Patrick','Moran',98484732,4,65,843571,'p.moran',NULL,to_date('16/09/83','DD/MM/RR'),to_date('11/06/57','DD/MM/RR'),4,'EM0097');
INSERT INTO empleado VALUES (12675518,'1','Darren','Hardy',96874487,9,462,454995,'d.hardy',NULL,to_date('25/01/87','DD/MM/RR'),to_date('09/01/61','DD/MM/RR'),2,'EM0098');
INSERT INTO empleado VALUES (12739376,'0','Samantha','Cooper',98691599,6,253,1644000,'s.cooper',NULL,to_date('20/10/05','DD/MM/RR'),to_date('02/07/78','DD/MM/RR'),3,'EM0100');
INSERT INTO empleado VALUES (12822294,'7','Drew','Washington',97923132,10,352,874359,'d.washington',NULL,to_date('30/08/04','DD/MM/RR'),to_date('30/07/60','DD/MM/RR'),0,'EM0102');
INSERT INTO empleado VALUES (12877053,'1','Otis','Williamson',NULL,3,431,535672,'o.williamson',NULL,to_date('11/09/97','DD/MM/RR'),to_date('31/03/69','DD/MM/RR'),1,'EM0104');
INSERT INTO empleado VALUES (13031308,'K','Harry','ONeal',96874487,4,216,1829137,'h.oneal',NULL,to_date('10/04/10','DD/MM/RR'),to_date('02/02/73','DD/MM/RR'),2,'EM0106');
INSERT INTO empleado VALUES (13055585,'8','Jessie','Shannon',98691599,8,270,1708855,'j.shannon',NULL,to_date('24/10/99','DD/MM/RR'),to_date('02/08/71','DD/MM/RR'),2,'EM0108');
INSERT INTO empleado VALUES (13168994,'9','Kellie','Larson',92024905,7,143,1108912,'k.larson',NULL,to_date('26/07/00','DD/MM/RR'),to_date('04/10/81','DD/MM/RR'),6,'EM0110');
INSERT INTO empleado VALUES (13310609,'1','Ginger','Guzman',90147888,6,57,1423431,'g.guzman',NULL,to_date('26/09/80','DD/MM/RR'),to_date('13/03/83','DD/MM/RR'),5,'EM0112');
INSERT INTO empleado VALUES (13566392,'7','Rebecca','Butler',97948160,8,151,1636411,'r.butler',NULL,to_date('13/04/06','DD/MM/RR'),to_date('21/05/78','DD/MM/RR'),1,'EM0114');
INSERT INTO empleado VALUES (13616191,'1','Betsy','Cannon',96874487,10,187,1699190,'b.cannon',NULL,to_date('16/01/99','DD/MM/RR'),to_date('28/03/50','DD/MM/RR'),4,'EM0116');
INSERT INTO empleado VALUES (13659135,'2','Latasha','Henry',93741395,8,409,1708669,'l.henry',NULL,to_date('29/04/83','DD/MM/RR'),to_date('02/03/74','DD/MM/RR'),2,'EM0118');
INSERT INTO empleado VALUES (13875565,'2','Kathleen','Poole',97948160,7,378,1077654,'k.poole',NULL,to_date('31/12/86','DD/MM/RR'),to_date('16/03/73','DD/MM/RR'),6,'EM0120');
INSERT INTO empleado VALUES (14009838,'7','Rickey','Garza',96874487,2,124,1811746,'r.garza',NULL,to_date('05/03/98','DD/MM/RR'),to_date('25/12/82','DD/MM/RR'),5,'EM0122');
INSERT INTO empleado VALUES (14131935,'7','Guillermo','Buck',97923132,5,143,1801110,'g.buck',NULL,to_date('30/11/90','DD/MM/RR'),to_date('09/04/69','DD/MM/RR'),6,'EM0123');
INSERT INTO empleado VALUES (14197568,'3','Elizabeth','Arellano',90147888,5,413,433641,'e.arellano',NULL,to_date('30/04/90','DD/MM/RR'),to_date('28/05/62','DD/MM/RR'),1,'EM0125');
INSERT INTO empleado VALUES (14364117,'2','Kathleen','Lara',98484732,9,214,1682047,'k.lara',NULL,to_date('05/01/96','DD/MM/RR'),to_date('25/05/81','DD/MM/RR'),0,'EM0127');
INSERT INTO empleado VALUES (14497033,'9','Lakesha','Barnes',93741395,7,217,560586,'l.barnes',NULL,to_date('06/12/98','DD/MM/RR'),to_date('12/07/83','DD/MM/RR'),1,'EM0129');
INSERT INTO empleado VALUES (14669316,'4','Roy','Huang',NULL,1,78,1483173,'r.huang',NULL,to_date('16/11/07','DD/MM/RR'),to_date('14/12/74','DD/MM/RR'),4,'EM0131');
INSERT INTO empleado VALUES (14740596,'1','Claude','Rivers',97948160,6,189,1234155,'c.rivers',NULL,to_date('12/03/02','DD/MM/RR'),to_date('17/04/62','DD/MM/RR'),2,'EM0133');
INSERT INTO empleado VALUES (14809169,'1','Cristina','Hubbard',93741395,9,442,531888,'c.hubbard',NULL,to_date('12/12/08','DD/MM/RR'),to_date('14/12/74','DD/MM/RR'),2,'EM0135');
INSERT INTO empleado VALUES (14964616,'1','Gretchen','Moss',97923132,6,437,1951182,'g.moss',NULL,to_date('01/06/87','DD/MM/RR'),to_date('16/07/75','DD/MM/RR'),3,'EM0137');
INSERT INTO empleado VALUES (15112311,'3','Marie','Franco',98484732,9,145,953786,'m.franco',NULL,to_date('25/05/89','DD/MM/RR'),to_date('28/11/55','DD/MM/RR'),2,'EM0138');
INSERT INTO empleado VALUES (15218105,'7','Ana','Hale',93741395,2,70,445927,'a.hale',NULL,to_date('02/12/90','DD/MM/RR'),to_date('24/05/83','DD/MM/RR'),5,'EM0140');
INSERT INTO empleado VALUES (15228313,'8','Melody','Nelson',92436124,5,113,1759184,'m.nelson',NULL,to_date('08/06/92','DD/MM/RR'),to_date('09/09/55','DD/MM/RR'),3,'EM0142');
INSERT INTO empleado VALUES (15371480,'8','Daryl','Krueger',97923132,3,182,1983914,'d.krueger',NULL,to_date('11/10/96','DD/MM/RR'),to_date('09/12/58','DD/MM/RR'),4,'EM0143');
INSERT INTO empleado VALUES (15380367,'5','Forrest','Calderon',93741395,3,398,1199530,'f.calderon',NULL,to_date('20/07/06','DD/MM/RR'),to_date('18/06/69','DD/MM/RR'),3,'EM0144');
INSERT INTO empleado VALUES (15549123,'K','Ramona','Case',NULL,3,430,347305,'r.case',NULL,to_date('12/04/81','DD/MM/RR'),to_date('02/12/82','DD/MM/RR'),1,'EM0145');
INSERT INTO empleado VALUES (15641722,'3','Robbie','Singleton',98484732,5,358,383429,'r.singleton',NULL,to_date('17/06/89','DD/MM/RR'),to_date('27/09/56','DD/MM/RR'),5,'EM0146');
INSERT INTO empleado VALUES (15870757,'5','Irene','Mc Intyre',90147888,3,113,895866,'i.mc intyre',NULL,to_date('30/10/80','DD/MM/RR'),to_date('21/07/53','DD/MM/RR'),3,'EM0147');
INSERT INTO empleado VALUES (15922888,'7','Scottie','Patrick',98691599,6,198,1463198,'s.patrick',NULL,to_date('26/09/01','DD/MM/RR'),to_date('13/07/63','DD/MM/RR'),1,'EM0148');
INSERT INTO empleado VALUES (15959360,'2','Wallace','Simon',98484732,3,490,1682193,'w.simon',NULL,to_date('15/02/85','DD/MM/RR'),to_date('11/06/63','DD/MM/RR'),2,'EM0149');
INSERT INTO empleado VALUES (15980522,'1','Jolene','Flowers',92436124,3,376,1106190,'j.flowers',NULL,to_date('02/02/06','DD/MM/RR'),to_date('10/01/72','DD/MM/RR'),5,'EM0150');
INSERT INTO empleado VALUES (16285459,'K','Cameron','Maxwell',98691599,6,105,649622,'c.maxwell',NULL,to_date('10/01/92','DD/MM/RR'),to_date('02/09/84','DD/MM/RR'),6,'EM0151');
INSERT INTO empleado VALUES (16290553,'4','Lester','Meyers',92024905,8,319,1981387,'l.meyers',NULL,to_date('20/12/06','DD/MM/RR'),to_date('14/06/56','DD/MM/RR'),5,'EM0152');
INSERT INTO empleado VALUES (16309184,'3','Kristine','Mullins',90147888,6,231,401346,'k.mullins',NULL,to_date('07/09/07','DD/MM/RR'),to_date('07/07/82','DD/MM/RR'),5,'EM0153');
INSERT INTO empleado VALUES (16380579,'2','Jean','Gregory',92024905,9,239,483056,'j.gregory',NULL,to_date('12/04/08','DD/MM/RR'),to_date('09/06/58','DD/MM/RR'),0,'EM0154');
INSERT INTO empleado VALUES (16421520,'5','Damon','Young',93741395,10,474,1482229,'d.young',NULL,to_date('11/11/86','DD/MM/RR'),to_date('23/05/74','DD/MM/RR'),2,'EM0155');
INSERT INTO empleado VALUES (16612359,'8','Ronda','Booth',98691599,7,324,1192787,'r.booth',NULL,to_date('14/03/10','DD/MM/RR'),to_date('13/06/52','DD/MM/RR'),4,'EM0156');
INSERT INTO empleado VALUES (16641880,'0','Jonathan','Hendricks',97948160,9,476,626689,'j.hendricks',NULL,to_date('14/01/04','DD/MM/RR'),to_date('01/01/65','DD/MM/RR'),2,'EM0157');
INSERT INTO empleado VALUES (16723459,'7','Devin','Solis',90147888,7,208,1453403,'d.solis',NULL,to_date('23/12/80','DD/MM/RR'),to_date('27/08/50','DD/MM/RR'),1,'EM0158');
INSERT INTO empleado VALUES (16764496,'8','Sylvia','Mccoy',98484732,1,243,1836449,'s.mccoy',NULL,to_date('01/02/08','DD/MM/RR'),to_date('23/07/71','DD/MM/RR'),3,'EM0159');
INSERT INTO empleado VALUES (16809546,'5','Irene','Yoder',NULL,8,325,1770321,'i.yoder',NULL,to_date('11/06/04','DD/MM/RR'),to_date('17/06/59','DD/MM/RR'),0,'EM0160');
INSERT INTO empleado VALUES (16874219,'K','Christy','Huang',93741395,4,106,1846919,'c.huang',NULL,to_date('10/05/06','DD/MM/RR'),to_date('24/04/50','DD/MM/RR'),3,'EM0161');
INSERT INTO empleado VALUES (17067642,'7','Herman','Shepard',93350895,3,283,1919342,'h.shepard',NULL,to_date('23/02/98','DD/MM/RR'),to_date('02/05/75','DD/MM/RR'),4,'EM0162');
INSERT INTO empleado VALUES (17204426,'5','Aaron','Trujillo',93741395,10,354,1579127,'a.trujillo',NULL,to_date('16/04/83','DD/MM/RR'),to_date('31/03/58','DD/MM/RR'),1,'EM0163');
INSERT INTO empleado VALUES (17233467,'7','Josh','Velasquez',90147888,6,93,1968646,'j.velasquez',NULL,to_date('25/01/01','DD/MM/RR'),to_date('28/01/66','DD/MM/RR'),3,'EM0164');
INSERT INTO empleado VALUES (17248479,'4','Wanda','Hurst',98691599,3,342,752413,'w.hurst',NULL,to_date('19/08/96','DD/MM/RR'),to_date('20/06/85','DD/MM/RR'),3,'EM0166');
INSERT INTO empleado VALUES (17467536,'3','Justin','Jordan',97923132,7,71,1512959,'j.jordan',NULL,to_date('31/01/91','DD/MM/RR'),to_date('03/02/85','DD/MM/RR'),1,'EM0168');
INSERT INTO empleado VALUES (17567043,'0','Randall','Schultz',97923132,2,127,1902674,'r.schultz',NULL,to_date('12/12/90','DD/MM/RR'),to_date('29/03/83','DD/MM/RR'),1,'EM0170');
INSERT INTO empleado VALUES (17630361,'7','Felix','Murray',98484732,4,78,1866699,'f.murray',NULL,to_date('07/04/95','DD/MM/RR'),to_date('15/12/53','DD/MM/RR'),0,'EM0172');
INSERT INTO empleado VALUES (17721084,'8','Lea','Mc Bride',92436124,2,307,1332761,'l.mc bride',NULL,to_date('05/11/84','DD/MM/RR'),to_date('31/05/66','DD/MM/RR'),5,'EM0174');
INSERT INTO empleado VALUES (17814206,'2','Bridget','Mc Gee',98484732,8,411,1560208,'b.mc gee',NULL,to_date('04/03/81','DD/MM/RR'),to_date('20/06/51','DD/MM/RR'),1,'EM0176');
INSERT INTO empleado VALUES (17817690,'7','Felix','Hodges',92436124,8,179,1426367,'f.hodges',NULL,to_date('06/09/81','DD/MM/RR'),to_date('01/02/74','DD/MM/RR'),2,'EM0177');
INSERT INTO empleado VALUES (17889317,'3','Alvin','Stafford',NULL,9,175,1957658,'a.stafford',NULL,to_date('10/11/82','DD/MM/RR'),to_date('16/03/67','DD/MM/RR'),5,'EM0179');
INSERT INTO empleado VALUES (17909864,'1','Penny','Roth',92436124,8,213,1284041,'p.roth',NULL,to_date('30/07/05','DD/MM/RR'),to_date('14/11/64','DD/MM/RR'),2,'EM0181');
INSERT INTO empleado VALUES (17950830,'7','Roberto','Keller',93350895,5,436,827202,'r.keller',NULL,to_date('20/06/85','DD/MM/RR'),to_date('25/04/77','DD/MM/RR'),3,'EM0183');
INSERT INTO empleado VALUES (18156650,'6','Darlene','Larsen',96874487,3,215,1708535,'d.larsen',NULL,to_date('27/12/80','DD/MM/RR'),to_date('01/04/84','DD/MM/RR'),1,'EM0185');
INSERT INTO empleado VALUES (18280709,'7','Mark','Tucker',97923132,2,183,413286,'m.tucker',NULL,to_date('19/05/90','DD/MM/RR'),to_date('14/04/55','DD/MM/RR'),3,'EM0187');
INSERT INTO empleado VALUES (18352172,'6','Malcolm','Wells',97923132,3,493,1198405,'m.wells',NULL,to_date('20/02/04','DD/MM/RR'),to_date('08/01/55','DD/MM/RR'),3,'EM0189');
INSERT INTO empleado VALUES (18390208,'3','Juan','Bowers',92024905,3,479,352845,'j.bowers',NULL,to_date('23/03/91','DD/MM/RR'),to_date('04/06/56','DD/MM/RR'),3,'EM0190');
INSERT INTO empleado VALUES (18505021,'0','Lynette','Mc Millan',96874487,6,377,1221795,'l.mc millan',NULL,to_date('11/05/93','DD/MM/RR'),to_date('06/03/85','DD/MM/RR'),0,'EM0192');
INSERT INTO empleado VALUES (18659997,'1','Jimmie','Shepherd',93741395,8,478,1330158,'j.shepherd',NULL,to_date('02/08/03','DD/MM/RR'),to_date('26/04/78','DD/MM/RR'),2,'EM0194');
INSERT INTO empleado VALUES (18804511,'9','Jacob','Burke',92436124,1,251,751324,'j.burke',NULL,to_date('15/11/05','DD/MM/RR'),to_date('25/10/57','DD/MM/RR'),6,'EM0196');
INSERT INTO empleado VALUES (18835559,'4','Dora','Hardin',97923132,9,344,1045746,'d.hardin',NULL,to_date('15/01/84','DD/MM/RR'),to_date('20/06/55','DD/MM/RR'),1,'EM0198');
INSERT INTO empleado VALUES (18934168,'8','Sylvia','Ruiz',90147888,10,290,368766,'s.ruiz',NULL,to_date('14/02/93','DD/MM/RR'),to_date('08/03/59','DD/MM/RR'),4,'EM0200');
INSERT INTO empleado VALUES (19120175,'K','Helen','Robles',98691599,10,300,1689145,'h.robles',NULL,to_date('16/08/93','DD/MM/RR'),to_date('04/09/75','DD/MM/RR'),5,'EM0202');
INSERT INTO empleado VALUES (19435555,'8','Wendi','Reyes',90147888,4,422,576134,'w.reyes',NULL,to_date('01/04/03','DD/MM/RR'),to_date('30/09/84','DD/MM/RR'),5,'EM0204');
INSERT INTO empleado VALUES (19567994,'2','Rachel','Choi',NULL,8,374,2021384,'r.choi',NULL,to_date('06/12/01','DD/MM/RR'),to_date('23/10/83','DD/MM/RR'),3,'EM0206');
INSERT INTO empleado VALUES (19633374,'3','Nicolas','Daniels',96874487,8,482,733735,'n.daniels',NULL,to_date('20/07/82','DD/MM/RR'),to_date('28/03/81','DD/MM/RR'),3,'EM0208');
INSERT INTO empleado VALUES (19639001,'0','Clarence','Ware',98484732,5,94,738394,'c.ware',NULL,to_date('09/04/98','DD/MM/RR'),to_date('12/10/71','DD/MM/RR'),4,'EM0209');
INSERT INTO empleado VALUES (19743237,'9','Moses','Townsend',98484732,10,192,1417521,'m.townsend',NULL,to_date('28/05/88','DD/MM/RR'),to_date('09/05/59','DD/MM/RR'),3,'EM0211');
INSERT INTO empleado VALUES (19796164,'2','Bridget','Villegas',97948160,4,340,821633,'b.villegas',NULL,to_date('03/12/01','DD/MM/RR'),to_date('16/04/67','DD/MM/RR'),5,'EM0213');
INSERT INTO empleado VALUES (19833967,'5','Kendra','Trevino',92436124,8,158,1540414,'k.trevino',NULL,to_date('24/11/92','DD/MM/RR'),to_date('04/06/75','DD/MM/RR'),4,'EM0215');
INSERT INTO empleado VALUES (19952110,'7','Teresa','Meyers',92024905,1,220,1384358,'t.meyers',NULL,to_date('26/09/87','DD/MM/RR'),to_date('16/12/50','DD/MM/RR'),3,'EM0217');
INSERT INTO empleado VALUES (20007856,'3','Natalie','Briggs',98484732,7,57,1698330,'n.briggs',NULL,to_date('09/07/95','DD/MM/RR'),to_date('08/04/56','DD/MM/RR'),3,'EM0219');
INSERT INTO empleado VALUES (20318058,'K','Audrey','Ortiz',97948160,8,374,769273,'a.ortiz',NULL,to_date('16/08/06','DD/MM/RR'),to_date('09/10/62','DD/MM/RR'),2,'EM0221');
INSERT INTO empleado VALUES (20451244,'6','Bret','Khan',96874487,6,60,1803675,'b.khan',NULL,to_date('23/05/02','DD/MM/RR'),to_date('14/02/67','DD/MM/RR'),2,'EM0223');
INSERT INTO empleado VALUES (20528928,'1','Kelvin','Benitez',96874487,1,227,462468,'k.benitez',NULL,to_date('17/02/03','DD/MM/RR'),to_date('08/01/78','DD/MM/RR'),5,'EM0225');
INSERT INTO empleado VALUES (20608226,'K','Ricardo','Dillon',97923132,8,312,1347114,'r.dillon',NULL,to_date('27/01/86','DD/MM/RR'),to_date('23/05/63','DD/MM/RR'),4,'EM0227');
INSERT INTO empleado VALUES (20652299,'9','Bradford','Bolton',97923132,8,285,1926286,'b.bolton',NULL,to_date('10/03/03','DD/MM/RR'),to_date('14/10/62','DD/MM/RR'),5,'EM0229');
INSERT INTO empleado VALUES (20823138,'6','Noel','Morrow',97923132,3,200,485132,'n.morrow',NULL,to_date('09/10/81','DD/MM/RR'),to_date('16/03/81','DD/MM/RR'),0,'EM0231');
INSERT INTO empleado VALUES (20823222,'0','Devon','Morris',NULL,6,355,1224398,'d.morris',NULL,to_date('30/12/09','DD/MM/RR'),to_date('18/02/72','DD/MM/RR'),4,'EM0232');
INSERT INTO empleado VALUES (20930084,'4','Hilary','Joyce',93741395,1,213,1992670,'h.joyce',NULL,to_date('18/06/04','DD/MM/RR'),to_date('28/12/59','DD/MM/RR'),5,'EM0234');
INSERT INTO empleado VALUES (21047530,'8','Regina','Bates',97948160,8,188,1530799,'r.bates',NULL,to_date('28/08/83','DD/MM/RR'),to_date('30/06/52','DD/MM/RR'),1,'EM0236');
INSERT INTO empleado VALUES (14100530,'6','Terry','Gillespie',93350895,6,477,447193,'t.gillespie',NULL,to_date('27/10/07','DD/MM/RR'),to_date('29/07/71','DD/MM/RR'),0,'EM0238');
INSERT INTO empleado VALUES (14713617,'8','Brandie','Elliott',90147888,4,203,618359,'b.elliott',NULL,to_date('22/07/08','DD/MM/RR'),to_date('30/01/62','DD/MM/RR'),2,'EM0240');
INSERT INTO empleado VALUES (15160739,'0','Yvette','Diaz',90147888,3,202,2007026,'y.diaz',NULL,to_date('16/01/87','DD/MM/RR'),to_date('30/04/80','DD/MM/RR'),5,'EM0242');
INSERT INTO empleado VALUES (15771649,'5','Neil','Davis',93741395,4,245,1551645,'n.davis',NULL,to_date('04/09/92','DD/MM/RR'),to_date('26/02/60','DD/MM/RR'),1,'EM0244');
INSERT INTO empleado VALUES (16339454,'K','Taryn','Gilbert',93741395,3,367,1188618,'t.gilbert',NULL,to_date('09/01/09','DD/MM/RR'),to_date('21/04/50','DD/MM/RR'),3,'EM0246');
INSERT INTO empleado VALUES (17186610,'4','Yesenia','Fowler',NULL,6,166,728243,'y.fowler',NULL,to_date('12/11/03','DD/MM/RR'),to_date('20/04/84','DD/MM/RR'),1,'EM0248');
INSERT INTO empleado VALUES (17598097,'8','Christie','Dean',98691599,4,351,1671810,'c.dean',NULL,to_date('15/12/96','DD/MM/RR'),to_date('02/12/61','DD/MM/RR'),1,'EM0250');
INSERT INTO empleado VALUES (8001282,'9','Lakesha','Osborne',97948160,5,495,557431,'l.osborne',NULL,to_date('22/01/05','DD/MM/RR'),to_date('10/01/76','DD/MM/RR'),1,'EM0023');
INSERT INTO empleado VALUES (8172068,'9','Kara','Snow',92436124,2,374,1679951,'k.snow',NULL,to_date('01/08/94','DD/MM/RR'),to_date('09/10/59','DD/MM/RR'),1,'EM0025');
INSERT INTO empleado VALUES (8252210,'0','Felipe','Rios',93741395,5,99,1510118,'f.rios',NULL,to_date('18/04/94','DD/MM/RR'),to_date('09/12/55','DD/MM/RR'),6,'EM0027');
INSERT INTO empleado VALUES (8278301,'K','Gilbert','Acevedo',92436124,8,421,2067170,'g.acevedo',NULL,to_date('08/06/98','DD/MM/RR'),to_date('22/09/61','DD/MM/RR'),2,'EM0029');
INSERT INTO empleado VALUES (8312668,'6','Jeremy','Chung',98691599,7,82,1894021,'j.chung',NULL,to_date('02/10/05','DD/MM/RR'),to_date('16/05/77','DD/MM/RR'),2,'EM0031');
INSERT INTO empleado VALUES (8405509,'5','Margaret','Sawyer',92436124,4,248,958426,'m.sawyer',NULL,to_date('17/12/82','DD/MM/RR'),to_date('17/09/54','DD/MM/RR'),5,'EM0033');
INSERT INTO empleado VALUES (8520615,'1','Rachelle','Ponce',96874487,2,419,801641,'r.ponce',NULL,to_date('21/08/01','DD/MM/RR'),to_date('17/10/84','DD/MM/RR'),6,'EM0036');
INSERT INTO empleado VALUES (8627024,'8','Marisa','Khan',92024905,7,242,1001099,'m.khan',NULL,to_date('09/02/81','DD/MM/RR'),to_date('21/09/51','DD/MM/RR'),1,'EM0038');
INSERT INTO empleado VALUES (8768378,'3','Trevor','Gay',92024905,3,233,1552409,'t.gay',NULL,to_date('13/12/01','DD/MM/RR'),to_date('10/04/58','DD/MM/RR'),4,'EM0040');
INSERT INTO empleado VALUES (8894669,'7','Derick','Watts',92436124,5,411,1032278,'d.watts',NULL,to_date('22/02/05','DD/MM/RR'),to_date('12/07/62','DD/MM/RR'),4,'EM0042');
INSERT INTO empleado VALUES (9070412,'8','Nakia','Gibson',90147888,6,188,904182,'n.gibson',NULL,to_date('16/07/91','DD/MM/RR'),to_date('04/05/73','DD/MM/RR'),3,'EM0044');
INSERT INTO empleado VALUES (9267617,'2','Kelly','Vaughan',92024905,5,117,475542,'k.vaughan',NULL,to_date('16/05/06','DD/MM/RR'),to_date('07/09/68','DD/MM/RR'),4,'EM0046');
INSERT INTO empleado VALUES (9387207,'3','Anna','Nielsen',NULL,5,248,932628,'a.nielsen',NULL,to_date('18/08/96','DD/MM/RR'),to_date('21/05/51','DD/MM/RR'),1,'EM0048');
INSERT INTO empleado VALUES (9464133,'1','Lorna','Trujillo',92436124,9,298,331830,'l.trujillo',NULL,to_date('15/05/95','DD/MM/RR'),to_date('12/07/76','DD/MM/RR'),3,'EM0050');
INSERT INTO empleado VALUES (9544164,'4','Roy','Foley',90147888,1,287,310317,'r.foley',NULL,to_date('02/10/82','DD/MM/RR'),to_date('18/10/82','DD/MM/RR'),5,'EM0052');
INSERT INTO empleado VALUES (9733287,'6','Abel','Villa',92024905,10,152,1909524,'a.villa',NULL,to_date('10/03/82','DD/MM/RR'),to_date('06/08/74','DD/MM/RR'),2,'EM0054');
INSERT INTO empleado VALUES (9854603,'0','Gerard','Clarke',93350895,8,428,1480593,'g.clarke',NULL,to_date('15/07/97','DD/MM/RR'),to_date('25/09/53','DD/MM/RR'),3,'EM0056');
INSERT INTO empleado VALUES (1005133,'8','Cynthia','Barry',98691599,6,381,737896,'c.barry',NULL,to_date('16/11/09','DD/MM/RR'),to_date('03/11/65','DD/MM/RR'),2,'EM0058');
INSERT INTO empleado VALUES (1013420,'0','Vincent','Garza',97923132,5,276,1220011,'v.garza',NULL,to_date('16/04/03','DD/MM/RR'),to_date('19/09/68','DD/MM/RR'),1,'EM0060');
INSERT INTO empleado VALUES (1056475,'4','Stacie','Waller',93350895,3,400,1301466,'s.waller',NULL,to_date('19/07/99','DD/MM/RR'),to_date('22/10/54','DD/MM/RR'),1,'EM0063');
INSERT INTO empleado VALUES (1057752,'8','Jamison','Strickland',96874487,5,483,1398550,'j.strickland',NULL,to_date('17/03/95','DD/MM/RR'),to_date('24/01/54','DD/MM/RR'),2,'EM0065');
INSERT INTO empleado VALUES (1077759,'3','Max','Wheeler',93741395,6,70,313503,'m.wheeler',NULL,to_date('22/12/94','DD/MM/RR'),to_date('30/11/79','DD/MM/RR'),2,'EM0067');
INSERT INTO empleado VALUES (1096135,'1','Audra','Graves',NULL,7,256,1491720,'a.graves',NULL,to_date('30/08/92','DD/MM/RR'),to_date('27/02/51','DD/MM/RR'),6,'EM0069');
INSERT INTO empleado VALUES (1099913,'8','Jessie','Brandt',96874487,5,211,710221,'j.brandt',NULL,to_date('15/07/85','DD/MM/RR'),to_date('26/03/58','DD/MM/RR'),4,'EM0071');
INSERT INTO empleado VALUES (1119394,'7','Stephen','Andrade',97923132,9,325,750542,'s.andrade',NULL,to_date('01/09/97','DD/MM/RR'),to_date('17/02/52','DD/MM/RR'),1,'EM0073');
INSERT INTO empleado VALUES (1137361,'8','Steven','Huang',98484732,4,264,653946,'s.huang',NULL,to_date('01/11/85','DD/MM/RR'),to_date('14/07/68','DD/MM/RR'),2,'EM0075');
INSERT INTO empleado VALUES (11459405,'9','Erik','Brennan',92024905,3,293,1664537,'e.brennan',NULL,to_date('13/12/99','DD/MM/RR'),to_date('23/07/58','DD/MM/RR'),6,'EM0077');
INSERT INTO empleado VALUES (11501646,'8','Vicky','Wiggins',90147888,8,339,902387,'v.wiggins',NULL,to_date('23/10/01','DD/MM/RR'),to_date('21/07/78','DD/MM/RR'),5,'EM0079');
INSERT INTO empleado VALUES (11706645,'5','Patrick','Mac Donald',92024905,6,136,1127324,'p.mac donald',NULL,to_date('10/04/94','DD/MM/RR'),to_date('01/12/80','DD/MM/RR'),4,'EM0082');
INSERT INTO empleado VALUES (11754228,'3','Bart','Koch',97948160,1,384,1291286,'b.koch',NULL,to_date('05/04/94','DD/MM/RR'),to_date('07/04/68','DD/MM/RR'),4,'EM0084');
INSERT INTO empleado VALUES (11823453,'2','Leanne','Patterson',93350895,7,308,1564097,'l.patterson',NULL,to_date('03/09/90','DD/MM/RR'),to_date('03/12/65','DD/MM/RR'),2,'EM0086');
INSERT INTO empleado VALUES (11965598,'8','Loren','Malone',93350895,1,368,1817728,'l.malone',NULL,to_date('11/03/96','DD/MM/RR'),to_date('20/05/54','DD/MM/RR'),5,'EM0088');
INSERT INTO empleado VALUES (12256596,'5','Forrest','Blair',98484732,4,89,1235076,'f.blair',NULL,to_date('15/05/93','DD/MM/RR'),to_date('24/08/62','DD/MM/RR'),5,'EM0090');
INSERT INTO empleado VALUES (12399125,'2','Marcie','Curry',98484732,9,201,886566,'m.curry',NULL,to_date('12/08/86','DD/MM/RR'),to_date('26/04/70','DD/MM/RR'),6,'EM0092');
INSERT INTO empleado VALUES (12478477,'4','Jaime','Reynolds',98691599,10,445,1134594,'j.reynolds',NULL,to_date('29/05/96','DD/MM/RR'),to_date('30/08/81','DD/MM/RR'),1,'EM0094');
INSERT INTO empleado VALUES (12490167,'K','Evelyn','Potts',93350895,6,171,1789053,'e.potts',NULL,to_date('02/03/94','DD/MM/RR'),to_date('19/04/54','DD/MM/RR'),5,'EM0096');
INSERT INTO empleado VALUES (12678640,'3','Roman','Good',92436124,9,138,1143638,'r.good',NULL,to_date('11/12/07','DD/MM/RR'),to_date('22/09/50','DD/MM/RR'),4,'EM0099');
INSERT INTO empleado VALUES (12803030,'7','Jocelyn','Wolf',NULL,5,425,652709,'j.wolf',NULL,to_date('27/04/93','DD/MM/RR'),to_date('17/03/60','DD/MM/RR'),3,'EM0101');
INSERT INTO empleado VALUES (12837828,'0','Alisha','Hart',97923132,7,376,588816,'a.hart',NULL,to_date('24/12/89','DD/MM/RR'),to_date('23/09/76','DD/MM/RR'),0,'EM0103');
INSERT INTO empleado VALUES (12936916,'1','Dewayne','Patterson',92436124,9,92,1980862,'d.patterson',NULL,to_date('24/03/81','DD/MM/RR'),to_date('10/12/81','DD/MM/RR'),0,'EM0105');
INSERT INTO empleado VALUES (13038430,'2','Shane','Wallace',93741395,10,393,1203229,'s.wallace',NULL,to_date('01/02/03','DD/MM/RR'),to_date('25/10/81','DD/MM/RR'),4,'EM0107');
INSERT INTO empleado VALUES (13100208,'5','Kristin','Raymond',98691599,5,379,849736,'k.raymond',NULL,to_date('11/09/91','DD/MM/RR'),to_date('08/07/63','DD/MM/RR'),3,'EM0109');
INSERT INTO empleado VALUES (13194745,'2','Ann','Donaldson',98691599,7,411,1127687,'a.donaldson',NULL,to_date('28/08/95','DD/MM/RR'),to_date('03/10/68','DD/MM/RR'),5,'EM0111');
INSERT INTO empleado VALUES (13378661,'5','Candice','Glenn',93350895,8,290,1927645,'c.glenn',NULL,to_date('26/02/99','DD/MM/RR'),to_date('17/07/62','DD/MM/RR'),4,'EM0113');
INSERT INTO empleado VALUES (13588065,'3','Andrea','Watts',93350895,5,223,1262783,'a.watts',NULL,to_date('03/04/01','DD/MM/RR'),to_date('25/09/53','DD/MM/RR'),1,'EM0115');
INSERT INTO empleado VALUES (13642167,'4','Wanda','Spears',97948160,8,152,592526,'w.spears',NULL,to_date('04/03/08','DD/MM/RR'),to_date('16/03/65','DD/MM/RR'),1,'EM0117');
INSERT INTO empleado VALUES (13812651,'K','Donnie','Caldwell',92024905,7,162,1105867,'d.caldwell',NULL,to_date('20/01/08','DD/MM/RR'),to_date('04/03/61','DD/MM/RR'),0,'EM0119');
INSERT INTO empleado VALUES (13960297,'K','Beth','Cunningham',96874487,2,460,644387,'b.cunningham',NULL,to_date('08/11/97','DD/MM/RR'),to_date('05/12/78','DD/MM/RR'),5,'EM0121');
INSERT INTO empleado VALUES (14132653,'0','Gabriel','Benitez',93350895,3,89,785096,'g.benitez',NULL,to_date('07/10/02','DD/MM/RR'),to_date('26/06/56','DD/MM/RR'),5,'EM0124');
INSERT INTO empleado VALUES (14212863,'5','Tabatha','Santana',92436124,4,314,781665,'t.santana',NULL,to_date('02/12/05','DD/MM/RR'),to_date('14/03/58','DD/MM/RR'),2,'EM0126');
INSERT INTO empleado VALUES (14480675,'0','Alejandro','Myers',90147888,2,485,1998017,'a.myers',NULL,to_date('13/09/02','DD/MM/RR'),to_date('30/05/58','DD/MM/RR'),3,'EM0128');
INSERT INTO empleado VALUES (14505029,'8','Sean','Friedman',97923132,5,133,1864032,'s.friedman',NULL,to_date('28/07/95','DD/MM/RR'),to_date('02/10/53','DD/MM/RR'),4,'EM0130');
INSERT INTO empleado VALUES (14733648,'8','Marjorie','Brock',92436124,6,114,930889,'m.brock',NULL,to_date('27/07/84','DD/MM/RR'),to_date('07/10/75','DD/MM/RR'),5,'EM0132');
INSERT INTO empleado VALUES (14805984,'K','Rhonda','Holder',NULL,3,140,1076935,'r.holder',NULL,to_date('10/10/92','DD/MM/RR'),to_date('13/11/56','DD/MM/RR'),5,'EM0134');
INSERT INTO empleado VALUES (14957390,'0','Gerard','Armstrong',98484732,9,336,371398,'g.armstrong',NULL,to_date('19/08/91','DD/MM/RR'),to_date('06/04/79','DD/MM/RR'),3,'EM0136');
INSERT INTO empleado VALUES (15126006,'9','Glen','Houston',96874487,5,432,2066867,'g.houston',NULL,to_date('09/07/97','DD/MM/RR'),to_date('02/06/76','DD/MM/RR'),1,'EM0139');
INSERT INTO empleado VALUES (15220334,'5','Sherri','Koch',92024905,7,199,1088375,'s.koch',NULL,to_date('06/04/86','DD/MM/RR'),to_date('15/07/61','DD/MM/RR'),2,'EM0141');
INSERT INTO empleado VALUES (17237023,'3','Jody','Lang',98691599,8,250,1666911,'j.lang',NULL,to_date('09/10/96','DD/MM/RR'),to_date('10/10/59','DD/MM/RR'),2,'EM0165');
INSERT INTO empleado VALUES (17393265,'9','Kristen','Hanna',97948160,1,301,374174,'k.hanna',NULL,to_date('26/06/88','DD/MM/RR'),to_date('24/11/54','DD/MM/RR'),0,'EM0167');
INSERT INTO empleado VALUES (17511566,'6','Trisha','Gross',98691599,8,188,619873,'t.gross',NULL,to_date('14/01/94','DD/MM/RR'),to_date('09/07/61','DD/MM/RR'),2,'EM0169');
INSERT INTO empleado VALUES (17604208,'9','Iris','Herman',92024905,3,363,1779712,'i.herman',NULL,to_date('17/05/04','DD/MM/RR'),to_date('07/08/54','DD/MM/RR'),2,'EM0171');
INSERT INTO empleado VALUES (17682804,'8','Tricia','Howell',98691599,8,380,879810,'t.howell',NULL,to_date('24/11/97','DD/MM/RR'),to_date('09/05/69','DD/MM/RR'),5,'EM0173');
INSERT INTO empleado VALUES (17723898,'5','Enrique','Wallace',92436124,9,484,447382,'e.wallace',NULL,to_date('15/10/05','DD/MM/RR'),to_date('05/05/82','DD/MM/RR'),5,'EM0175');
INSERT INTO empleado VALUES (17862825,'8','Yvonne','Bowen',93741395,8,243,1333398,'y.bowen',NULL,to_date('02/05/95','DD/MM/RR'),to_date('25/11/77','DD/MM/RR'),5,'EM0178');
INSERT INTO empleado VALUES (17896457,'9','Bridgett','Mack',98484732,9,396,723575,'b.mack',NULL,to_date('02/04/08','DD/MM/RR'),to_date('20/08/76','DD/MM/RR'),3,'EM0180');
INSERT INTO empleado VALUES (17934688,'0','Rick','Gaines',97923132,7,159,301604,'r.gaines',NULL,to_date('26/05/07','DD/MM/RR'),to_date('01/07/63','DD/MM/RR'),2,'EM0182');
INSERT INTO empleado VALUES (18014045,'K','Rhonda','Alvarado',92024905,9,130,1344033,'r.alvarado',NULL,to_date('03/02/05','DD/MM/RR'),to_date('22/09/65','DD/MM/RR'),1,'EM0184');
INSERT INTO empleado VALUES (18184240,'0','Courtney','Cunningham',NULL,3,494,1762380,'c.cunningham',NULL,to_date('21/07/80','DD/MM/RR'),to_date('08/02/79','DD/MM/RR'),5,'EM0186');
INSERT INTO empleado VALUES (18336158,'9','Kendrick','Fletcher',98484732,10,497,1837200,'k.fletcher',NULL,to_date('14/06/08','DD/MM/RR'),to_date('19/11/53','DD/MM/RR'),4,'EM0188');
INSERT INTO empleado VALUES (18421225,'7','Martin','Fisher',98691599,9,96,1094832,'m.fisher',NULL,to_date('10/09/81','DD/MM/RR'),to_date('26/04/71','DD/MM/RR'),3,'EM0191');
INSERT INTO empleado VALUES (18550492,'7','Bryon','Cordova',93350895,4,451,1256438,'b.cordova',NULL,to_date('24/12/08','DD/MM/RR'),to_date('12/06/72','DD/MM/RR'),2,'EM0193');
INSERT INTO empleado VALUES (18699786,'7','Cassandra','Grant',97923132,7,159,535949,'c.grant',NULL,to_date('10/09/87','DD/MM/RR'),to_date('01/10/50','DD/MM/RR'),2,'EM0195');
INSERT INTO empleado VALUES (18829466,'0','Olivia','Kline',97923132,5,264,351351,'o.kline',NULL,to_date('04/12/80','DD/MM/RR'),to_date('26/05/85','DD/MM/RR'),3,'EM0197');
INSERT INTO empleado VALUES (18839556,'1','Karla','Beard',98691599,9,153,1447027,'k.beard',NULL,to_date('02/11/05','DD/MM/RR'),to_date('02/10/70','DD/MM/RR'),4,'EM0199');
INSERT INTO empleado VALUES (19100598,'0','Rick','Solomon',97923132,8,387,536553,'r.solomon',NULL,to_date('04/02/83','DD/MM/RR'),to_date('03/01/61','DD/MM/RR'),5,'EM0201');
INSERT INTO empleado VALUES (19303268,'2','Gabrielle','Reeves',90147888,4,177,978895,'g.reeves',NULL,to_date('20/09/87','DD/MM/RR'),to_date('22/02/83','DD/MM/RR'),5,'EM0203');
INSERT INTO empleado VALUES (19435837,'5','Kirsten','Moran',98484732,9,178,1698106,'k.moran',NULL,to_date('07/09/02','DD/MM/RR'),to_date('23/12/71','DD/MM/RR'),1,'EM0205');
INSERT INTO empleado VALUES (19607698,'K','Loretta','Landry',90147888,7,208,1197344,'l.landry',NULL,to_date('22/08/06','DD/MM/RR'),to_date('04/08/53','DD/MM/RR'),1,'EM0207');
INSERT INTO empleado VALUES (19664729,'4','Derek','Bolton',NULL,4,222,1892712,'d.bolton',NULL,to_date('07/06/93','DD/MM/RR'),to_date('20/09/76','DD/MM/RR'),3,'EM0210');
INSERT INTO empleado VALUES (19770211,'9','Autumn','Pugh',90147888,7,164,1911022,'a.pugh',NULL,to_date('25/08/08','DD/MM/RR'),to_date('12/11/54','DD/MM/RR'),4,'EM0212');
INSERT INTO empleado VALUES (19816444,'4','Oscar','Ballard',90147888,4,303,1828029,'o.ballard',NULL,to_date('18/12/89','DD/MM/RR'),to_date('24/03/64','DD/MM/RR'),5,'EM0214');
INSERT INTO empleado VALUES (19921273,'6','Tyler','White',97923132,3,275,638516,'t.white',NULL,to_date('01/10/83','DD/MM/RR'),to_date('21/06/65','DD/MM/RR'),0,'EM0216');
INSERT INTO empleado VALUES (19987871,'2','Victoria','Meyer',92436124,2,214,2000392,'v.meyer',NULL,to_date('30/05/89','DD/MM/RR'),to_date('23/12/61','DD/MM/RR'),6,'EM0218');
INSERT INTO empleado VALUES (20269498,'9','Bonnie','Hines',97923132,7,321,715441,'b.hines',NULL,to_date('17/09/99','DD/MM/RR'),to_date('21/06/78','DD/MM/RR'),1,'EM0220');
INSERT INTO empleado VALUES (20377241,'9','Roger','Burke',92436124,8,444,1222804,'r.burke',NULL,to_date('27/07/03','DD/MM/RR'),to_date('20/12/78','DD/MM/RR'),3,'EM0222');
INSERT INTO empleado VALUES (20451888,'6','Erica','Ward',97948160,1,213,849972,'e.ward',NULL,to_date('17/12/80','DD/MM/RR'),to_date('29/05/59','DD/MM/RR'),1,'EM0224');
INSERT INTO empleado VALUES (20559425,'9','Jeannette','Bean',98484732,3,185,314063,'j.bean',NULL,to_date('15/06/86','DD/MM/RR'),to_date('07/12/67','DD/MM/RR'),0,'EM0226');
INSERT INTO empleado VALUES (20624895,'4','Kisha','Lester',98484732,4,368,1091127,'k.lester',NULL,to_date('28/09/84','DD/MM/RR'),to_date('08/11/65','DD/MM/RR'),3,'EM0228');
INSERT INTO empleado VALUES (20718476,'8','Stephanie','Sweeney',92024905,7,181,711518,'s.sweeney',NULL,to_date('25/03/83','DD/MM/RR'),to_date('29/03/69','DD/MM/RR'),4,'EM0230');
INSERT INTO empleado VALUES (20899316,'4','Wanda','Randall',92024905,6,289,1327429,'w.randall',NULL,to_date('23/04/89','DD/MM/RR'),to_date('17/12/75','DD/MM/RR'),1,'EM0233');
INSERT INTO empleado VALUES (21043583,'2','Shane','Thornton',98691599,7,102,1567242,'s.thornton',NULL,to_date('13/11/01','DD/MM/RR'),to_date('28/09/79','DD/MM/RR'),5,'EM0235');
INSERT INTO empleado VALUES (13679297,'3','Holly','Tyler',98691599,5,283,1245447,'h.tyler',NULL,to_date('17/06/07','DD/MM/RR'),to_date('12/04/64','DD/MM/RR'),1,'EM0237');
INSERT INTO empleado VALUES (14316128,'6','Tyrone','Hamilton',96874487,2,221,767137,'t.hamilton',NULL,to_date('23/06/10','DD/MM/RR'),to_date('06/01/77','DD/MM/RR'),6,'EM0239');
INSERT INTO empleado VALUES (14930546,'7','Herman','Mora',93741395,7,338,1383479,'h.mora',NULL,to_date('04/06/87','DD/MM/RR'),to_date('01/06/72','DD/MM/RR'),2,'EM0241');
INSERT INTO empleado VALUES (15318020,'2','Jane','Garcia',NULL,1,186,1174958,'j.garcia',NULL,to_date('26/05/86','DD/MM/RR'),to_date('11/12/52','DD/MM/RR'),3,'EM0243');
INSERT INTO empleado VALUES (16073440,'2','Eva','Browning',92436124,5,437,1293501,'e.browning',NULL,to_date('20/02/81','DD/MM/RR'),to_date('07/12/75','DD/MM/RR'),2,'EM0245');
INSERT INTO empleado VALUES (16690718,'3','Billie','Christian',97923132,6,96,1344613,'b.christian',NULL,to_date('01/09/81','DD/MM/RR'),to_date('06/12/66','DD/MM/RR'),1,'EM0247');
INSERT INTO empleado VALUES (17264208,'K','Randy','Montgomery',93350895,1,448,319944,'r.montgomery',NULL,to_date('27/12/94','DD/MM/RR'),to_date('07/03/82','DD/MM/RR'),5,'EM0249');

INSERT INTO lista VALUES ('A', 480, 600, .22);
INSERT INTO lista VALUES ('B', 350, 479, .15); 
INSERT INTO lista VALUES ('C', 220, 349, .18); 
INSERT INTO lista VALUES ('D', 120, 219, .14); 
INSERT INTO lista VALUES ('E', 0, 119, .08); 
COMMIT;



