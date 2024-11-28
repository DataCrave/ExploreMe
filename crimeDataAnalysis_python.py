import pymysql
import pandas as pd
import warnings
import matplotlib.pyplot as plt
import seaborn as sns

connection= pymysql.connect(
    host='localhost',
    user='root',
    password='Zaraki@7',
    database='crimes_data_capstone',

)
warnings.filterwarnings("ignore")

conn_check_query="select * from crime_data"
conn_check=pd.read_sql_query(conn_check_query,connection)
print(conn_check)

# Retrieve basic statistics on the dataset, such as the total number of records

total_records = "select count(*) as total_rec from crime_data"
total_rec = pd.read_sql_query(total_records,connection)
print(total_rec)

# Identify the distinct crime codes and their descriptions.

distinct_crime="select distinct crm_cd,crm_cd_desc from crime_data order by crm_cd asc"
distinct_data=pd.read_sql_query(distinct_crime,connection)
print(distinct_data)

sql_query = """
SELECT YEAR(DATE_OCC) AS Year, MONTH(DATE_OCC) AS Month, COUNT(*) AS Crime_Count
FROM crime_data WHERE DATE_OCC IS NOT NULL
GROUP BY Year, Month
ORDER BY Year, Month;
"""
crime_trends=pd.read_sql_query(sql_query,connection)
crime_trends['Date_OCC'] = pd.to_datetime(crime_trends['Date_occ'], format='%m/%d/%Y')
print(crime_trends)


#  Utilize the geographical information (Latitude and Longitude) to perform spatial analysis,
# Spatial Analysis:
# Where are the geographical hotspots for reported crimes?

geo_query = "SELECT LAT, LON FROM crime_data;"
geo_details=pd.read_sql_query(geo_query,connection)
plt.figure(figsize=(10, 6))
plt.scatter(geo_details['LON'], geo_details['LAT'], s=20, alpha=0.5,color='green')
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.title('Geographical information of crimes occured')
plt.show()

#What is the distribution of victim ages in reported crimes?

victim_query = "SELECT Vict_Age FROM crime_data;"
crime_data = pd.read_sql_query(victim_query, connection)

plt.figure(figsize=(10, 6))
plt.hist(crime_data['Vict_Age'], bins=25, color='skyblue', edgecolor='black')
plt.xlabel('Victim Age')
plt.ylabel('Frequency')
plt.title('Distribution of Victim Ages in Reported Crimes')
plt.grid(True)
plt.show()

#Is there a significant difference in crime rates between male and female victims?

gender_query = "SELECT Vict_Sex FROM crime_data WHERE Vict_Sex IN ('M', 'F');"
victim_gen = pd.read_sql_query(gender_query, connection)
sns.set(style="whitegrid")
plt.figure(figsize=(8, 6))
sns.countplot(data=victim_gen, x='Vict_Sex', palette='Set2',width=0.1)
plt.xlabel('Victim Gender')
plt.ylabel('Number of Crimes')
plt.title('Number of Crimes Based on Victim Gender')
plt.show()

#Where do most crimes occur based on the "Location" column?

location_query = """select location,count(*) as Crime_count
                    from crime_data group by location order by count(*) desc limit 5"""
location_data=pd.read_sql_query(location_query,connection)
print(location_data)
plt.figure(figsize=(10, 6))
plt.bar(location_data['location'], location_data['Crime_count'], color='skyblue',width=0.3)
plt.xlabel('Location')
plt.ylabel('Number of Crimes')
plt.title('Top 5 Locations with Most Crimes')
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.show()


# What is the distribution of reported crimes based on Crime Code?
query = "SELECT Crm_Cd FROM crime_data;"
crime_data = pd.read_sql_query(query, connection)

plt.figure(figsize=(10, 6))
plt.hist(crime_data['Crm_Cd'], bins=50, color='cyan', edgecolor='black',width=10)
plt.xlabel('Crime Code')
plt.ylabel('Frequency')
plt.title('Distribution of Reported Crimes Based on Crime Code')
plt.grid(True)
plt.show()






