CREATE DATABASE nautobot;
CREATE USER nautobot WITH PASSWORD 'nautobot123';
\connect nautobot
GRANT CREATE ON SCHEMA public TO nautobot;
