

# Connecting to DocumentDB

To connect to Amazon Document DB, we have to create a tunnel between our EC2 machine and your connection like this:

`ssh -i tf-cherx-api-ec2 -L 27018:tf-cherx-api.cluster-c9gvm17pgarr.us-east-1.docdb.amazonaws.com:27017  ubuntu@ec2-54-162-133-99.compute-1.amazonaws.com -N` 

Then you can normally connect to the cluster using port 27018 with login and password defined