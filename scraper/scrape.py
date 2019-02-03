#!/usr/bin/python3
import pymysql
import os

conn = pymysql.connect(
    host="127.0.0.1",
    database="flagship_production",
    user="root",
    password="password",
)

category_name = ""
cur = conn.cursor()
c2 = conn.cursor()
c3 = conn.cursor()
c4 = conn.cursor()

# get all category ids to build directory structure
cur.execute("SELECT id from categories")
for category_id in cur:
    category_id[0]
    # Place a directory for each flagship directory
    c2.execute("SELECT name from categories where id = %s", category_id[0])
    for res in c2:
        print("Creating " + res[0] + "_" + str(category_id[0]))
        try:
            if(not os.path.exists("senate/" + res[0] + "_" + str(category_id[0]))):
                os.makedirs("senate/" + res[0] + "_" + str(category_id[0]))
        except OSError as e:
            print(e)
            if e.errno != errno.EEXIST:
                raise
    c4.execute("SELECT id from documents where category_id = %s", category_id[0])
    for doc_id in c4:
        c3.execute("select upload_file_name,upload_content_type,upload_file from revisions where document_id = %s", doc_id[0])
        for r in c3:
            f = open("senate/" + res[0] + "_" + str(category_id[0]) + "/" + r[0],"wb")
            f.write(r[2])
            f.close()
