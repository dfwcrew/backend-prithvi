#!/usr/bin/python
import MySQLdb
import requests

# Connect
db = MySQLdb.connect(host=host,
                     user=user,
                     passwd=passwd,
                     db=db)

cursor = db.cursor()

# Execute SQL select statement
cursor.execute("SELECT * FROM prithvidb.disastersFinal1")

# Commit your changes if writing
# In this case, we are only reading data
# db.commit()

# Get the number of rows in the resultset
numrows = cursor.rowcount


#tempQ = 'https://maps.googleapis.com/maps/api/elevation/json?locations=' + '39.7391536' + ',' + '-104.9847034' + 'APIKey'
#r = requests.get(tempQ)
#print r.json()['results'][0]['elevation']



finalYear = []
for row in cursor:
        #try:
        tempQ = 'https://maps.googleapis.com/maps/api/elevation/json?locations=' + row[6] + ',' + row[7] + '&key=AIzaSyB2wJhVtNJqCrK7tjB_tO7-IcWr2qkI6jc'
        print tempQ
        r=requests.get(tempQ)
        elevation=r.json()['results'][0]['elevation']
        UQuery = "UPDATE prithvidb.disastersFinal1 SET elevation='" + str(elevation) + "' WHERE country='" + row[4] +"' and city='" + row[5] + "'"
        print UQuery
        updateCursor = db.cursor()
        updateCursor.execute(UQuery)


        #query = 'https://api.open-elevation.com/api/v1/lookup?locations=' + row[4] + ',' + row[5]
        #r=requests.get(query)
        #elevation=r.json()['results'][0]['elevation']
        #if float(elevation)>0 and float(row[3])>0:
                #record={}
                #record['Station']=str(row[0])
                #record['MSL']=str(row[3])
                #record['Lat']=str(row[4])
