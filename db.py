import mysql.connector
mydb=mysql.connector.connect(
    host='localhost',
    user='root',
    password='BUbs3456@',
    port='3306',
    database='globe_trotter1',
)
mycursor=mydb.cursor()
mycursor.execute('SELECT*FROM users')
users = mycursor.fetchall()
for users in users:
    print(users)
    print('Username'+ users[1])
    print('password' + users[2])


