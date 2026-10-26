-- Adds the three columns D2L appended to the LTI Links data set to an existing
-- 28-column D2L_LTI_LINK / D2L_LTI_LINK_LOAD pair. Use instead of the DROP/CREATE
-- scripts when the table already holds data you want to keep.
ALTER TABLE D2L_LTI_LINK ADD (
  CreatedDate TIMESTAMP WITH LOCAL TIME ZONE DEFAULT NULL,
  DeploymentId VARCHAR2(36 CHAR) DEFAULT NULL,
  LinkSubType NUMBER(10) DEFAULT NULL
);
ALTER TABLE D2L_LTI_LINK_LOAD ADD (
  CreatedDate TIMESTAMP WITH LOCAL TIME ZONE DEFAULT NULL,
  DeploymentId VARCHAR2(36 CHAR) DEFAULT NULL,
  LinkSubType NUMBER(10) DEFAULT NULL
);
QUIT;
