USE master;
GO

DROP DATABASE IF EXISTS GrafDB;
GO

CREATE DATABASE GrafDB;
GO

USE GrafDB;
GO

CREATE TABLE Students (
    ID INT NOT NULL PRIMARY KEY,
    [Name] VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50) NOT NULL
) AS NODE;

INSERT INTO Students (ID, [Name], LastName, MiddleName) VALUES
(1, '����', '������', '���������'),
(2, '����', '��������', '�������������'),
(3, '������', '��������', '����������'),
(4, '�����', '������', '����������'),
(5, '�������', '������', '��������'),
(6, '�����', '�������', '���������'),
(7, '�������', '�������', '����������'),
(8, '�����', '��������', '������������'),
(9, '�������', '������', '��������'),
(10, '�������', '��������', '����������');

SELECT * FROM Students;

CREATE TABLE Books (
    ID INT NOT NULL PRIMARY KEY,
    [Name] VARCHAR(100) NOT NULL,
    ReleaseDate INT NOT NULL
) AS NODE;

INSERT INTO Books(ID, [Name], ReleaseDate) VALUES
(1, '����� � ���', 1869),
(2, '����� ������ � ����������� ������', 1997),
(3, '��� �� �����', 2003),
(4, '1984', 1949),
(5, '������������ � ���������', 1866),
(6, '������ � ���������', 1967),
(7, '���� ��������', 1877),
(8, '��������� ������', 1936),
(9, '����� � ������ �����', 1865),
(10, '������ ��������', 1883);

SELECT * FROM Books;

CREATE TABLE Courses (
    ID INT NOT NULL PRIMARY KEY,
    [Name] VARCHAR(100) NOT NULL,
    Town VARCHAR(50) NOT NULL
) AS NODE;

INSERT INTO Courses (ID, [Name], Town) VALUES
(1, '�������������� ������', '������'),
(2, '������', '�����-���������'),
(3, '����� �����', '�����������'),
(4, '��������', '������������'),
(5, '�������', '������'),
(6, '�����������', '������ ��������'),
(7, '���������', '���������'),
(8, '����������', '������'),
(9, '����������', '������-��-����'),
(10, '���������', '���');

SELECT * FROM Courses;

CREATE TABLE StudyOn AS EDGE;
CREATE TABLE [Read] AS EDGE;
CREATE TABLE BelongsToCourse AS EDGE; 

ALTER TABLE StudyOn
ADD CONSTRAINT EC_StudyOn CONNECTION (Students TO Courses);

ALTER TABLE [Read]
ADD CONSTRAINT EC_Read CONNECTION (Students TO Books);

ALTER TABLE BelongsToCourse
ADD CONSTRAINT EC_BelongsToCourse CONNECTION (Books TO Courses);

INSERT INTO StudyOn ($from_id, $to_id)
VALUES ((SELECT $node_id FROM Students WHERE id = 1), (SELECT $node_id FROM Courses WHERE id = 1)),
       ((SELECT $node_id FROM Students WHERE id = 2), (SELECT $node_id FROM Courses WHERE id = 2)),
       ((SELECT $node_id FROM Students WHERE id = 3), (SELECT $node_id FROM Courses WHERE id = 3)),
       ((SELECT $node_id FROM Students WHERE id = 4), (SELECT $node_id FROM Courses WHERE id = 4)),
       ((SELECT $node_id FROM Students WHERE id = 5), (SELECT $node_id FROM Courses WHERE id = 5)),
       ((SELECT $node_id FROM Students WHERE id = 6), (SELECT $node_id FROM Courses WHERE id = 6)),
       ((SELECT $node_id FROM Students WHERE id = 7), (SELECT $node_id FROM Courses WHERE id = 7)),
       ((SELECT $node_id FROM Students WHERE id = 8), (SELECT $node_id FROM Courses WHERE id = 8)),
       ((SELECT $node_id FROM Students WHERE id = 9), (SELECT $node_id FROM Courses WHERE id = 9)),
       ((SELECT $node_id FROM Students WHERE id = 10), (SELECT $node_id FROM Courses WHERE id = 10));

SELECT * FROM StudyOn;

INSERT INTO [Read] ($from_id, $to_id)
VALUES ((SELECT $node_id FROM Students WHERE id = 1), (SELECT $node_id FROM Books WHERE id = 1)),
       ((SELECT $node_id FROM Students WHERE id = 2), (SELECT $node_id FROM Books WHERE id = 3)),
       ((SELECT $node_id FROM Students WHERE id = 3), (SELECT $node_id FROM Books WHERE id = 2)),
       ((SELECT $node_id FROM Students WHERE id = 4), (SELECT $node_id FROM Books WHERE id = 1)),
       ((SELECT $node_id FROM Students WHERE id = 5), (SELECT $node_id FROM Books WHERE id = 1)),
       ((SELECT $node_id FROM Students WHERE id = 6), (SELECT $node_id FROM Books WHERE id = 5)),
       ((SELECT $node_id FROM Students WHERE id = 7), (SELECT $node_id FROM Books WHERE id = 6)),
       ((SELECT $node_id FROM Students WHERE id = 8), (SELECT $node_id FROM Books WHERE id = 7)),
       ((SELECT $node_id FROM Students WHERE id = 9), (SELECT $node_id FROM Books WHERE id = 8)),
       ((SELECT $node_id FROM Students WHERE id = 10), (SELECT $node_id FROM Books WHERE id = 9));

SELECT * FROM [Read];

INSERT INTO BelongsToCourse ($from_id, $to_id)
VALUES ((SELECT $node_id FROM Books WHERE id = 1), (SELECT $node_id FROM Courses WHERE id = 2)),
       ((SELECT $node_id FROM Books WHERE id = 1), (SELECT $node_id FROM Courses WHERE id = 3)),
       ((SELECT $node_id FROM Books WHERE id = 2), (SELECT $node_id FROM Courses WHERE id = 4)),
       ((SELECT $node_id FROM Books WHERE id = 3), (SELECT $node_id FROM Courses WHERE id = 5)),
       ((SELECT $node_id FROM Books WHERE id = 4), (SELECT $node_id FROM Courses WHERE id = 6)),
       ((SELECT $node_id FROM Books WHERE id = 5), (SELECT $node_id FROM Courses WHERE id = 7)),
       ((SELECT $node_id FROM Books WHERE id = 6), (SELECT $node_id FROM Courses WHERE id = 8)),
       ((SELECT $node_id FROM Books WHERE id = 7), (SELECT $node_id FROM Courses WHERE id = 9)),
       ((SELECT $node_id FROM Books WHERE id = 8), (SELECT $node_id FROM Courses WHERE id = 10));

SELECT * FROM BelongsToCourse;


-- ����� ��� �����, �� ������� ������ ������� � ������ ����
SELECT s.Name AS StudentName, c.Name AS CourseName
FROM Students s, Courses c, StudyOn so
WHERE MATCH(s-(so)->c)
AND s.Name = '����';

-- ����� ��� �����, ������� ������ ������� � �������� ��������
SELECT s.Name AS StudentName, b.Name AS BookName
FROM Students s, Books b, [Read] r
WHERE MATCH(s-(r)->b)
AND s.LastName = '��������';

-- ����� ���� ���������, ������� ������ ����� "����� � ���"
SELECT s.Name AS StudentName, b.Name AS BookName
FROM Students s, Books b, [Read] r
WHERE MATCH(s-(r)->b)
AND b.Name = '����� � ���';

-- ����� ��� �����, ������� ������������ � ����� "������"
SELECT b.Name AS BookName, c.Name AS CourseName
FROM Books b, Courses c, BelongsToCourse bc
WHERE MATCH(b-(bc)->c)
AND c.Name = '������';

-- ����� ��� �����, ������� �������� ��������, �������� ����� "����� � ���"
SELECT DISTINCT c.Name AS CourseName
FROM Students s, Courses c, Books b, StudyOn so, [Read] r
WHERE MATCH(s-(so)->c)
AND MATCH(s-(r)->b)
AND b.Name = '����� � ���';