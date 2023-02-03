#pre req - install mysql, install connector of mysql (pip instlall *)

import mysql.connector
mydb = mysql.connector.connect(host="localhost", user="username", passwd="password", database="dbname")
mycursor = mydb.cursor()
mycursor.execute("select * from tables")
result = mycursor.fetchall() #fetchone() to fetch single record

for i in result:
    print(i)