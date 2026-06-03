USE master;


IF EXISTS (SELECT name FROM sys.databases WHERE name = 'GymDB')
    DROP DATABASE GymDB;


CREATE DATABASE GymDB;


USE GymDB;