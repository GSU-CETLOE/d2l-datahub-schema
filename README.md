# gsu-cetloe/d2l-datahub-schema

Column definitions for every D2L Brightspace Data Hub data set, as JSON, plus the matching `CREATE TABLE` scripts for MySQL and Oracle and a small PHP library for reading them.

Georgia State University uses this as the shared source of truth for anything that lands Data Hub extracts in a database. The main consumer is the extract CLI (`gsu-d2l/dataset-extract-cli`), which uses it to find the right table for an incoming CSV, build the load table, and decide which columns are keys.

## What is in here

```
schema/
  datasets/   one JSON file per data set, plus dataset_map.json
  modules/    one JSON + one HTML file per D2L documentation page
  sql/
    mysql/    CREATE TABLE scripts and table_map.json
    oracle/   same, Oracle flavored
src/          the PHP library
```

**Datasets.** 142 data sets are mapped. The file name is the type prefix plus the name with spaces and punctuation stripped, so "Grade Schemes" lives at `schema/datasets/BDS_GradeSchemes.json`. Two types exist:

- `BDS`, Brightspace Data Sets. The bulk of the collection.
- `ADS`, Advanced Data Sets. Reports like All Grades, Attendance, and Learner Usage.

Each file records the type, the name, the D2L Knowledge Base URL it came from, a description, and a column list. Every column carries its name, description, SQL type, size, key flags, whether it can be null, and D2L's version history note for that field.

**Modules.** D2L documents data sets in groups (Grades, Quizzes, Users, and so on). Each module's JSON lists the data sets on that page. The HTML next to it is the downloaded page itself, kept so the JSON can be rebuilt without going back to the web.

**SQL.** For every data set there are two scripts per database: the real table and a `_LOAD` staging table. `table_map.json` ties the D2L name to the table name, which differs by database. "Accommodations Profile Log" becomes `AccommodationsProfileLog` in MySQL and `D2L_ACCOMMODATION_PROFILE_LOG` in Oracle.

**Overrides.** When D2L changes a data set and the published documentation lags, or when we need to diverge on purpose, drop a file next to the base one with the same name and an `.override` suffix. The library merges override columns onto the base by column name: a matching name replaces the column, a new name is appended. There is one in the repo today, `BDS_RubricAssessmentCriteria.override.json`, which demotes `UserId` from primary key after D2L removed it from the export in BDS major version 11.

The generator that produced the JSON from the D2L pages is not part of this repo.

## Installing

The package is not on Packagist under this name. Point Composer at the repository directly:

```json
{
  "repositories": [
    { "type": "vcs", "url": "https://github.com/GSU-CETLOE/d2l-datahub-schema" }
  ],
  "require": {
    "gsu-cetloe/d2l-datahub-schema": "^2.0"
  }
}
```

Requires PHP 8.1 or newer and the `dom` extension.

## Using the library

Everything goes through `SchemaRepository`, which implements `SchemaRepositoryInterface`. With no constructor arguments it reads the `schema/` directory shipped with the package.

```php
use GSU\D2L\DataHub\Schema\SchemaRepository;
use GSU\D2L\DataHub\Schema\Model\SQLType;

$repo = new SchemaRepository();

// Data set names are forgiving: "Grade Schemes" and "GradeSchemes" both work.
$schema = $repo->fetchDataset('BDS', 'Grade Schemes');

foreach ($schema->getPrimaryColumns() as $column) {
    echo "{$column->name} ({$column->type->value})\n";
}

// Where the CREATE TABLE script lives for this data set.
$repo->fetchSqlTableName(SQLType::MYSQL, $schema);          // GradeScheme
$repo->fetchSqlTablePath(SQLType::MYSQL, $schema);          // .../schema/sql/mysql/GradeScheme.sql
$repo->fetchSqlTablePath(SQLType::MYSQL, $schema, '_LOAD'); // .../schema/sql/mysql/GradeScheme_LOAD.sql
```

Other useful calls: `listDatasets()` for the full name map, `listModules()` and `fetchModule('GRADES')` for the documentation groupings, and `listSqlTables(SQLType::ORACLE)` for the table map. `storeDataset()` writes a schema back to disk, and the `cleanUp*` methods delete generated files. You will not need those unless you are regenerating the collection.

If you use the `cetloelib-php` container, register `SchemaDefinitionSource` and ask for `SchemaRepositoryInterface`. It honors three environment variables for pointing the repository at a different copy of the schema files: `DATASETS_DIR`, `MODULES_DIR`, and `SQL_TABLES_DIR`.

## Working on the package

```sh
composer install
composer phpstan   # level 9, must be clean
composer phpcs     # PSR-12
```

There is no test suite yet.

## History

This repository was `gsu-d2l/datahub-schema` until October 2026, when it moved to the GSU-CETLOE organization. The PHP namespace stayed `GSU\D2L\DataHub\Schema`, so consumers only need to change the package name in their `composer.json`.

## License

MIT. See [LICENSE.md](LICENSE.md).
