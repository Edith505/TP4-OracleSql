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
Create user GLOBAL_DATA IDENTIFIED BY GlobalData123;
    Grant create user to GLOBAL_DATA;
    


-- 2. Création du rôle ROLE_ANALYSTE et des utilisateurs FLORENCE et MICHEL
-- TODO: Écrire le code ici


-- 3. Création de l'utilisateur ROBERT (Développement)
-- TODO: Écrire le code ici


-- 4. Création de l'utilisateur GUILLAUME (RH)
-- TODO: Écrire le code ici


-- 5. Création du rôle ROLE_VENDEUR avec les permissions spécifiques
-- TODO: Écrire le code ici


-- =======================================================
-- PARTIE 2 : AUTOMATISATION (PL/SQL)
-- =======================================================

-- 1. Procédure PS_GENERER_VENDEURS
-- Description : Crée les users Oracle basés sur la table EMPLOYES.
-- TODO: Écrire le code ici


-- 2. Procédure PS_PURGE_USER_TABLES
-- Description : Supprime toutes les tables d'un utilisateur donné (SQL Dynamique).
CREATE OR REPLACE PROCEDURE PS_PURGE_USER_TABLES (
    p_utilisateur VARCHAR2
) IS
BEGIN
   NULL;--TODO: Écrire le code ici
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
BEGIN
   NULL;--TODO: Écrire le code ici

END;
/


-- =======================================================
-- PARTIE 3 : REQUÊTES AVANCÉES ET VUES
-- =======================================================

-- 1. Analyse des ventes (GROUP BY / HAVING)
-- TODO: Écrire la requête ici


-- 2. Clients VIP (Sous-requête)
-- TODO: Écrire la requête ici


-- 3. Vue V_MES_COMMANDES (Sécurité niveau ligne)
-- Description : Un vendeur ne voit que ses propres commandes via la variable USER.
-- TODO: Écrire le code de création de la vue ici

-- TODO: Écrire le GRANT nécessaire pour que le rôle vendeur puisse lire cette vue.

-- FIN DU SCRIPT