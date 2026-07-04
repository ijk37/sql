CREATE TABLE LoanChild (
  ChildID varchar2(10) NOT NULL,
  ChildName varchar2(25),
  CustomerID varchar2(10),
  PRIMARY KEY (ChildID)
);

INSERT INTO LoanChild VALUES
('C1001','Philip','A2001');
INSERT INTO LoanChild VALUES
('C1002','Megan','A2001');
INSERT INTO LoanChild VALUES
('C1003','Julie','A2110');
INSERT INTO LoanChild VALUES
('C1004','Pierce','B1201');
INSERT INTO LoanChild VALUES
('C1005','Johnny','B1201');

CREATE TABLE LoanCustomer (
  CustomerID varchar2(10) NOT NULL,
  CustomerName varchar2(25),
  Phone varchar2(20),
  Amount decimal(10,2),
  Spouse varchar2(25),
  PRIMARY KEY (CustomerID)
);

INSERT INTO LoanCustomer VALUES
('A2001','John Bingo','330-528-6273',5000.00,'Jenny');
INSERT INTO LoanCustomer VALUES
('A2002','Philip Cusack','330-672-5432',7500.00,'');
INSERT INTO LoanCustomer VALUES
('A2004','Charles Dominic','330-654-0980',25000.00,'');
INSERT INTO LoanCustomer VALUES
('A2005','Chick Eduardo','440-752-6542',150000.00,'Bella');
INSERT INTO LoanCustomer VALUES
('A2110','Will Hanks','818-223-7809',2200000.00,'Lily');
INSERT INTO LoanCustomer VALUES
('A2117','Bruce Willis','828-457-1234',990000.00,'');
INSERT INTO LoanCustomer VALUES
('A2120','Remo Williams','425-217-5473',750000.00,'');
INSERT INTO LoanCustomer VALUES
('B1201','John Wit','312-765-9087',450000.00,'Lisa');
INSERT INTO LoanCustomer VALUES
('B1221','Tom Zack','330-298-1891',550000.00,'');

ALTER table LoanChild
  ADD FOREIGN KEY (CustomerID) REFERENCES LoanCustomer (CustomerID);
