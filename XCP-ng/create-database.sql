CREATE DATABASE guac_db;
CREATE USER 'guac_user'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT,INSERT,UPDATE,DELETE ON guac_db.* TO 'guac_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
