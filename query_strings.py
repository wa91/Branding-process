import os,psycopg2

ver= input("Enter new version:  ")

ver=ver.replace('.','_')

list=['can_brandname_dnb','aus_brandname_dnb','uk_brandname_dnb','usa_brandname_dnb']#,'can_brandname_tt','aus_brandname_tt','uk_brandname_tt','usa_brandname_tt']


conn1=psycopg2.connect(database='WPOI', user='postgres', password='password', host='localhost', port='5432')
c1=conn1.cursor()
c2=conn1.cursor()

for i in list:
	print('Processing '+i)
	try:
		c1.execute('drop table if exists '+i+';')
		conn1.commit()
	except:
		continue
	nm=i.replace('_brandname_dnb','').replace('_brandname_tt','').replace('uk','gbr')
	os.system("aws s3 cp s3://temp/share/v"+ver+"/brand_name_lookup/"+i+".txt E:\\brands\\ ")
	c2.execute('select wloaddelta(\''+i+'\',\''+nm+'\')')
	conn1.commit()
	


