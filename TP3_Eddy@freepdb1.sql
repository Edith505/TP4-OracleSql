/*
 .----------------.  .----------------.  .----------------. 
| .--------------. || .--------------. || .--------------. |
| |  _________   | || |   ______     | || |    ______    | |
| | |  _   _  |  | || |  |_   __ \   | || |   / ____ `.  | |
| | |_/ | | \_|  | || |    | |__) |  | || |   `'  __) |  | |
| |     | |      | || |    |  ___/   | || |   _  |__ '.  | |
| |    _| |_     | || |   _| |_      | || |  | \____) |  | |
| |   |_____|    | || |  |_____|     | || |   \______.'  | |
| |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' |
  '----------------'  '----------------'  '----------------'
*/
-- TITRE : TP3 Administration et Sécurité
-- NOM    : Eddy Manoa Randrianarison
-- DA     : 2433177

/* INSTRUCTIONS :
   1. Répondez à toutes les questions dans les sections TODO.
   2. Ne modifiez pas les en-têtes de section.
   3. Script à exécuter initialement avec un compte SYSTEM ou ADMIN.
*/

SET SERVEROUTPUT ON;

-- =======================================================
-- PARTIE 1 : SÉCURITÉ ET PRIVILÈGES (DCL)
-- =======================================================

-- 1. Création du propriétaire GLOBAL_DATA et import des données
-- Note: Inclure seulement le CREATE USER et les GRANT nécessaires pour le propriétaire.
-- TODO: Écrire le code ici 
CREATE USER GLOBAL_DATA IDENTIFIED BY GlobalData123;
GRANT CONNECT, RESOURCE TO GLOBAL_DATA;


-- 2. Création du rôle ROLE_ANALYSTE et des utilisateurs FLORENCE et MICHEL
-- TODO: Écrire le code ici
CREATE ROLE ROLE_ANALYSTE;

GRANT SELECT ON COMMANDES TO ROLE_ANALYSTE;
GRANT SELECT ON CLIENTS TO ROLE_ANALYSTE;
GRANT SELECT ON PRODUITS TO ROLE_ANALYSTE;

CREATE USER FLORENCE IDENTIFIED BY mdpFlorence123;
GRANT CONNECT TO FLORENCE;
GRANT ROLE_ANALYSTE TO FLORENCE;

CREATE USER MICHEL IDENTIFIED BY mdpMichel123;
GRANT CONNECT TO MICHEL;
GRANT ROLE_ANALYSTE TO MICHEL;


-- 3. Création de l'utilisateur ROBERT (Développement)
-- TODO: Écrire le code ici
CREATE USER ROBERT IDENTIFIED BY mdpRobert123;
GRANT CONNECT TO ROBERT;
GRANT CREATE ANY TABLE TO ROBERT;
GRANT ALTER ANY TABLE TO ROBERT;
GRANT DROP ANY TABLE TO ROBERT;


-- 4. Création de l'utilisateur GUILLAUME (RH)
-- TODO: Écrire le code ici
CREATE USER GUILLAUME IDENTIFIED BY mdpGuillaume123;
GRANT CONNECT TO GUILLAUME;

GRANT SELECT, INSERT, UPDATE ON EMPLOYES TO GUILLAUME;
GRANT SELECT ON COMMANDES TO GUILLAUME;


-- 5. Création du rôle ROLE_VENDEUR avec les permissions spécifiques
-- TODO: Écrire le code ici
CREATE ROLE ROLE_VENDEUR;

GRANT INSERT ON COMMANDES TO ROLE_VENDEUR;
GRANT INSERT, UPDATE ON CLIENTS TO ROLE_VENDEUR;


-- =======================================================
-- PARTIE 2 : AUTOMATISATION (PL/SQL)
-- =======================================================

-- 1. Procédure PS_GENERER_VENDEURS
-- Description : Crée les users Oracle basés sur la table EMPLOYES.
-- TODO: Écrire le code ici
CREATE OR REPLACE PROCEDURE PS_GENERER_VENDEURS IS
    v_username VARCHAR2(100);
    v_user_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(v_user_exists, -1920);
    CURSOR c_vendeurs IS
        SELECT email FROM employees WHERE job_title = 'Sales Representative';
BEGIN
    FOR emp IN c_vendeurs LOOP
        v_username := UPPER(emp.email);
        BEGIN
            EXECUTE IMMEDIATE 'CREATE USER ' || v_username || ' IDENTIFIED BY "QWEqwe123123" PASSWORD EXPIRE';
            EXECUTE IMMEDIATE 'GRANT CONNECT TO ' || v_username;
            EXECUTE IMMEDIATE 'GRANT ROLE_VENDEUR TO ' || v_username;
            DBMS_OUTPUT.PUT_LINE('Utilisateur ' || v_username || ' creation reussie.');
        EXCEPTION
            WHEN v_user_exists THEN
                DBMS_OUTPUT.PUT_LINE('Utilisateur ' || v_username || ' existe déja.');
        END;
    END LOOP;
END;
/

-- 2. Procédure PS_PURGE_USER_TABLES
-- Description : Supprime toutes les tables d'un utilisateur donné (SQL Dynamique).
CREATE OR REPLACE PROCEDURE PS_PURGE_USER_TABLES (
    p_utilisateur VARCHAR2
) IS
    v_sql VARCHAR2(1000);
BEGIN
    FOR tab IN (SELECT table_name FROM all_tables WHERE owner = p_utilisateur) LOOP
        v_sql := 'DROP TABLE ' || p_utilisateur || '.' || tab.table_name;
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('Table ' || tab.table_name || ' supprimee.');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Tous les tables utilisateur ' || p_utilisateur || ' ont été supprimées.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
END;
/


-- 3. Procédure PS_GRANT_SELECT_ALL
/*Creez une procedure qui donne a un p_utilisateur le privilege SELECT sur 
tous les tables d'un p_schema. 
(EXECUTE IMMEDIATE permet d'executer une instruction GRANT en pl-sql). 
Gerer les cas d'erreurs si l'utilisateur ou le schema n'existent pas. 
(Les informations sur le nom des tables se trouvent dans la table systeme 
all_tables et colonne owner)*/
CREATE OR REPLACE PROCEDURE PS_GRANT_SELECT_ALL (
    p_utilisateur VARCHAR2,
    p_schema  VARCHAR2
) IS
    v_sql VARCHAR2(1000);
    v_user_not_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(v_user_not_exists, -1918);
    v_schema_not_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(v_schema_not_exists, -942);
BEGIN
    FOR tab IN (SELECT table_name FROM all_tables WHERE owner = p_schema) LOOP
        v_sql := 'GRANT SELECT ON ' || p_schema || '.' || tab.table_name || ' TO ' || p_utilisateur;
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('GRANT SELECT SUR ' || tab.table_name || ' pour ' || p_utilisateur);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('All SELECT privileges granted to ' || p_utilisateur || ' on schema ' || p_schema);
EXCEPTION
    WHEN v_user_not_exists THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: Utilisateur ' || p_utilisateur || ' n''existe pas.');
    WHEN v_schema_not_exists THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: Schema ' || p_schema || ' n''existe pas.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
END;
/


-- =======================================================
-- PARTIE 3 : REQUÊTES AVANCÉES ET VUES
-- =======================================================

-- 1. Analyse des ventes (GROUP BY / HAVING)
-- TODO: Écrire la requête ici
SELECT
    EXTRACT(YEAR FROM o.order_date) AS year,
    e.email AS sales_representative,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM
    orders o
JOIN
    employees e ON o.employee_id = e.employee_id
JOIN
    order_items oi ON o.order_id = oi.order_id
GROUP BY
    EXTRACT(YEAR FROM o.order_date), e.email
HAVING
    SUM(oi.quantity * oi.unit_price) > 50000
ORDER BY
    year DESC;


-- 2. Clients VIP (Sous-requête)
-- TODO: Écrire la requête ici
SELECT
    c.customer_id,
    c.name,
    c.email
FROM
    customers c
WHERE
    c.customer_id IN (
        SELECT
            o.customer_id
        FROM
            orders o
        JOIN
            order_items oi ON o.order_id = oi.order_id
        GROUP BY
            o.customer_id
        HAVING
            SUM(oi.quantity * oi.unit_price) > (SELECT AVG(total) FROM (SELECT SUM(oi2.quantity * oi2.unit_price) AS total FROM order_items oi2 JOIN orders o2 ON oi2.order_id = o2.order_id GROUP BY o2.customer_id))
    );


-- 3. Vue V_MES_COMMANDES (Sécurité niveau ligne)
-- Description : Un vendeur ne voit que ses propres commandes via la variable USER.
-- TODO: Écrire le code de création de la vue ici
CREATE OR REPLACE VIEW V_MES_COMMANDES AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status
FROM
    orders o
JOIN
    employees e ON o.employee_id = e.employee_id
WHERE
    UPPER(e.email) = USER;

-- TODO: Écrire le GRANT nécessaire pour que le rôle vendeur puisse lire cette vue.

GRANT SELECT ON V_MES_COMMANDES TO ROLE_VENDEUR;

-- FIN DU SCRIPT