Hiển thị các collection
    show collections

Login to mongo: 
    mongosh -u user -p - -authenticationDatabase admin

backup: 
    mongodump -u username -p password --host=rs0/host1:port1,host2:port2 --authenticatioDatabase=admin --archive > "/mnt/hdd/data_backup/mongodb_dev/mongo-${current_date}.dump"

restore:    
    mongorestore --host 10.22.0.35 --port 27017 --username hieupc --password hieupc --authenticationDatabase admin --archive < "/mnt/hdd/data_backup/mongodb_dev/mongo.dump"

uri connect: mongodb://mongodev:NyUrSVlhXVNtkjc7QDyYF8@10.22.0.50:27017,10.22.0.51:27017,10.22.0.52:27017

create user: 
    db.createUser({
        user: "mbbankdev",
        pwd: "NyUrSVlhXVNtkjc7QDyYF8",
        roles: [ { role: "userAdmin", db: "mbbankdev" } ]
    })