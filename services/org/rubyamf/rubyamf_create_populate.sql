-- phpMyAdmin SQL Dump
-- version 2.8.2.4
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generation Time: Jan 12, 2007 at 05:24 AM
-- Server version: 5.0.24
-- PHP Version: 5.1.6
-- 
-- Database: 'rubyamf'
-- 

-- --------------------------------------------------------

-- 
-- Table structure for table 'datas'
-- 

CREATE TABLE datas (
  id int(11) NOT NULL auto_increment,
  document_id int(11) default NULL,
  page_id int(11) default NULL,
  contents text,
  binaryfile varchar(255) default NULL,
  expiration date default NULL,
  page_in_document_index int(11) default NULL,
  PRIMARY KEY  (id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- 
-- Dumping data for table 'datas'
-- 

INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (1, 1, 1, 'this is some serialized content and stuff', NULL, NULL, 1);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (2, 1, 2, 'this is some serialized content and stuff', NULL, NULL, 2);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (3, 1, 3, 'this is some serialized content and stuff', NULL, NULL, 3);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (4, 1, 4, 'this is some serialized content and stuff', NULL, NULL, 4);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (5, 1, 5, 'this is some serialized content and stuff', NULL, NULL, 5);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (6, 1, 6, 'this is some serialized content and stuff', NULL, NULL, 6);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (7, 2, 7, 'this is some serialized content and stuff', NULL, NULL, 1);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (8, 2, 8, 'this is some serialized content and stuff', NULL, NULL, 2);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (9, 2, 9, 'this is some serialized content and stuff', NULL, NULL, 3);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (10, 2, 10, 'this is some serialized content and stuff', NULL, NULL, 4);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (11, 2, 11, 'this is some serialized content and stuff', NULL, NULL, 5);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (12, 2, 12, 'this is some serialized content and stuff', NULL, NULL, 6);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (13, 1, 1, 'this is some serialized content and stuff', NULL, NULL, 1);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (14, 1, 2, 'this is some serialized content and stuff', NULL, NULL, 2);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (15, 1, 3, 'this is some serialized content and stuff', NULL, NULL, 3);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (16, 1, 4, 'this is some serialized content and stuff', NULL, NULL, 4);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (17, 1, 5, 'this is some serialized content and stuff', NULL, NULL, 5);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (18, 1, 6, 'this is some serialized content and stuff', NULL, NULL, 6);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (19, 2, 7, 'this is some serialized content and stuff', NULL, NULL, 1);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (20, 2, 8, 'this is some serialized content and stuff', NULL, NULL, 2);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (21, 2, 9, 'this is some serialized content and stuff', NULL, NULL, 3);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (22, 2, 10, 'this is some serialized content and stuff', NULL, NULL, 4);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (23, 2, 11, 'this is some serialized content and stuff', NULL, NULL, 5);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (24, 2, 12, 'this is some serialized content and stuff', NULL, NULL, 6);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (25, 1, 1, 'this is some serialized content and stuff', NULL, NULL, 1);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (26, 1, 2, 'this is some serialized content and stuff', NULL, NULL, 2);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (27, 1, 3, 'this is some serialized content and stuff', NULL, NULL, 3);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (28, 1, 4, 'this is some serialized content and stuff', NULL, NULL, 4);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (29, 1, 5, 'this is some serialized content and stuff', NULL, NULL, 5);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (30, 1, 6, 'this is some serialized content and stuff', NULL, NULL, 6);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (31, 2, 7, 'this is some serialized content and stuff', NULL, NULL, 1);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (32, 2, 8, 'this is some serialized content and stuff', NULL, NULL, 2);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (33, 2, 9, 'this is some serialized content and stuff', NULL, NULL, 3);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (34, 2, 10, 'this is some serialized content and stuff', NULL, NULL, 4);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (35, 2, 11, 'this is some serialized content and stuff', NULL, NULL, 5);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (36, 2, 12, 'this is some serialized content and stuff', NULL, NULL, 6);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (37, 1, 1, 'this is some serialized content and stuff', NULL, NULL, 1);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (38, 1, 2, 'this is some serialized content and stuff', NULL, NULL, 2);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (39, 1, 3, 'this is some serialized content and stuff', NULL, NULL, 3);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (40, 1, 4, 'this is some serialized content and stuff', NULL, NULL, 4);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (41, 1, 5, 'this is some serialized content and stuff', NULL, NULL, 5);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (42, 1, 6, 'this is some serialized content and stuff', NULL, NULL, 6);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (43, 2, 7, 'this is some serialized content and stuff', NULL, NULL, 1);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (44, 2, 8, 'this is some serialized content and stuff', NULL, NULL, 2);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (45, 2, 9, 'this is some serialized content and stuff', NULL, NULL, 3);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (46, 2, 10, 'this is some serialized content and stuff', NULL, NULL, 4);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (47, 2, 11, 'this is some serialized content and stuff', NULL, NULL, 5);
INSERT INTO datas (id, document_id, page_id, contents, binaryfile, expiration, page_in_document_index) VALUES (48, 2, 12, 'this is some serialized content and stuff', NULL, NULL, 6);
