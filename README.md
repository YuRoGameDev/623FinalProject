# 623FinalProject

This is a simple project utilizing a locally created PostgreSQL database which has several transactions executed on it using Python.

## Required Packages/Tools
- Python 3
- PostgreSQL 18
- Git Bash (to execute the bash file)

## How to Install
- Download the repo
- Create a .env in the project folder. Insert PGPASSWORD="(Your postgres user password)"
- Run the DataBaseSetUp bash file to install the Python PostgreSQL local packages and initalize the default database **
- Run the main.py Python script

**The database uses the default postgres username, hosted locally on port 5432. To change this if needed, you have to edit both the bash file and the subsequent main.py file

## Transactions
1. Delete product p1 from Product and Stock
2. Delete depot d1 from Depot and Stock
3. Rename product p1 to pp1 in Product and Stock
4. Rename depot d1 to dd1 in Depot and Stock
5. Add product (p100, cd, 5) to Product and (p100, d2, 50) to Stock
6. Add depot (d100, Chicago, 100) to Depot and (p1, d100, 100) to Stock

## Possible Issues
- "psql is not found" when running the bash file. Make sure the path to psql is set correctly
- Make sure there is no space between PGPASSWORD,=, and your password. 
