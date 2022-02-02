# RockSend-API

Backend REST-API services on AWS Lambda for RockSend application

| Endpoint    | Parameters | Function                                  |
|-------------|------------|-------------------------------------------|
| get-areas   | \<none\>   | Returns the list of known areas           |
| get-regions | area_id    | Returns the list of regions in the area   |
| get-sectors | region_id  | Returns the list of sectors in the region |
| get-walls   | sector_id  | Returns the list of walls in the sector   |
| get-routes  | wall_id    | Returns the list of routes on the wall    |

Written on Python 3 and deployed via Terraform

### Dependencies:
* PyMySQL

`pip install -r dependencies.txt`

### Packaging
Base layer package

```commandline
pip install -r dependencies.txt -t packages\base_layer\python
Compress-Archive -Force -LiteralPath packages\base_layer\python -DestinationPath packages\base_layer.zip
```

Lambda functions packaging

```commandline
cd src
.\pack_all_functions.ps1
```

