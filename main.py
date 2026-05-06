import os
import sys
from dotenv import load_dotenv
import psycopg
from psycopg import sql, DatabaseError

# --- Loads .env file for DB password and the SQL transactions file
load_dotenv()
SQL_FILE = os.path.join(os.path.dirname(__file__), "transactions.sql")

# ---  Basic helpers for printing out the menu and transaction notices

def print_menu():
    print("\nMenu")
    print("  Q - Quit")
    print("  V - View tables")
    for i in range(1, 7):
        print(f"  {i} - Transaction {i}")


def handle_notice(notice):
    print(f"[NOTICE] {notice.message_primary}")
    
# ---  Main Database class

class projectDB:
    # --- Connects to the postgre database
    def __init__(self):
        self.conn = psycopg.connect(
            dbname="finalproject",
            user="postgres",
            password=os.getenv("PGPASSWORD"),
            host="localhost",
            port="5432"
        )
        self.conn.add_notice_handler(handle_notice) # Adds the notice handler
        self.conn.autocommit = False # Set autocommit to false as manually commiting
    
    # --- Closes the connection at the end
    def close(self):
        self.conn.close()

    # --- Loads the initial procedures from the transaction file
    def load_procedures(self):
        try:
            with open(SQL_FILE, "r") as fh:
                ddl = fh.read()
        except FileNotFoundError:
            print(f"[ERROR] SQL file not found: {SQL_FILE}")
            sys.exit(1)
            
        try:
            with self.conn.cursor() as cur:
                cur.execute(ddl)
            self.conn.commit()
            print(f"[OK] Stored procedures loaded from '{SQL_FILE}'.")
        except DatabaseError as exc:
            self.conn.rollback()
            print(f"[ERROR] Failed to load stored procedures: {exc}")
            sys.exit(1)
            
    # --- Calls the individual transaction procedure
    def _call_procedure(self, proc_name: str):
        try:
            with self.conn.cursor() as cur:
                # Isolation — must be set before any DML in the transaction.
                cur.execute(
                    "SET TRANSACTION ISOLATION LEVEL SERIALIZABLE"
                )
                # Execute the stored procedure (DML only, no internal COMMIT).
                cur.execute(
                    sql.SQL("CALL {}()").format(sql.Identifier(proc_name))
                )
            # Durability — persist all changes made by the procedure.
            self.conn.commit()
            print(f"[OK] {proc_name}() completed successfully.")
 
        except DatabaseError as exc:
            # Atomicity — roll back every statement the procedure ran.
            self.conn.rollback()
            print(f"[ERROR] {proc_name}() failed and was rolled back: {exc}")

    # --- Table Viewer
    def run_view_tables(self):
        tables = [
            ("PRODUCT", "SELECT prodid, pname, price FROM product ORDER BY prodid"),
            ("DEPOT",   "SELECT depid, addr, volume FROM depot ORDER BY depid"),
            ("STOCK",   "SELECT prodid, depid, quantity FROM stock ORDER BY prodid, depid"),
        ]

        try:
            with self.conn.cursor() as cur:
                for name, query in tables:
                    print(f"\n--- {name} ---")
                    cur.execute(query)
                    rows = cur.fetchall()

                    for row in rows:
                        print(" | ".join(str(x) for x in row))

                    if not rows:
                        print("(no rows)")

            self.conn.commit()
            print("\n[OK] view_tables() completed successfully.")

        except DatabaseError as exc:
            self.conn.rollback()
            print(f"[ERROR] view_tables() failed: {exc}")


# --- Main script
COMMANDS = {str(i): f"transaction{i}" for i in range(1, 7)}

if __name__ == "__main__":
    db = projectDB()
    db.load_procedures()

    while(True):
        print_menu()
        inp = input("Command? ").strip().upper()
        
        if inp == "Q":
            break
        elif inp == "V":
            db.run_view_tables()
        elif inp in COMMANDS:
            db._call_procedure(COMMANDS[inp])

    db.close()    
