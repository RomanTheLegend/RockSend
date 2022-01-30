Copy-Item src\getRegions.py tmp\lambda_function.py ; Compress-Archive -Force -LiteralPath tmp\lambda_function.py -DestinationPath packages\get_regions.zip
